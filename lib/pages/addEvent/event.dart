import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/image.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';
import 'package:petcare_record/pages/myPets/pet_detail_page.dart';
import 'package:uuid/uuid.dart';

class Event extends StatefulWidget {
  final Pet pet;
  final Map<String, dynamic>? existingEvent;

  Event({required this.pet, this.existingEvent});
  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> {
  String? _selectedRecordType;
  String _weight = '';
  String _temperature = '';
  String _description = '';
  String _memo = '';
  String _selectedWeightUnit = 'kg';
  String _selectedTempUnit = '°C';
  DateTime _eventDate = DateTime.now();
  Uint8List? _selectedImage;
  late String eventId;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      eventId = widget.existingEvent!['eventId'];
      _selectedRecordType = widget.existingEvent!['type'];

      // Ensure eventDate is properly cast
      _eventDate = widget.existingEvent!['eventDate'] is Timestamp
          ? (widget.existingEvent!['eventDate'] as Timestamp).toDate()
          : widget.existingEvent!['eventDate'];

      // Handle null memo
      _memo = widget.existingEvent!['memo'] ??
          ''; // Provide a default value if null
      _memoController.text = _memo; // Provide a default value if null
      if (_selectedRecordType == 'Weight') {
        _weight = widget.existingEvent!['weight'];
        _selectedWeightUnit = widget.existingEvent!['weightUnit'];
        _weightController.text = _weight; // Initialize the weight controller
      } else if (_selectedRecordType == 'Temperature') {
        _temperature = widget.existingEvent!['temperature'];
        _selectedTempUnit = widget.existingEvent!['temperatureUnit'];
        _tempController.text =
            _temperature; // Initialize the temperature controller
      } else if (_selectedRecordType == 'Other') {
        _description = widget.existingEvent!['description'];
        _descriptionController.text =
            _description; // Initialize the description controller
      }
      // Handle other properties if necessary
    } else {
      eventId = Uuid().v4();
    }
  }

  Future<void> _pickImageAndDisplay(ImageSource source) async {
    Uint8List? imageData = await pickImage(source);
    if (imageData != null) {
      setState(() {
        _selectedImage = imageData;
      });
    }
  }

  Future<String> _saveImageLocally() async {
    if (_selectedImage == null) {
      return '';
    }

    final directory = await getApplicationDocumentsDirectory();
    final imagePath =
        '${directory.path}/pet_image_${DateTime.now().millisecondsSinceEpoch}.png';

    final file = File(imagePath);
    await file.writeAsBytes(_selectedImage!);

    return imagePath;
  }

  Future<void> saveEvent() async {
    if (_selectedRecordType == null || _selectedRecordType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record type is required.')),
      );
      return;
    }

    // Check for required fields based on selected record type
    if ((_selectedRecordType == 'Weight' && _weightController.text.isEmpty) ||
        (_selectedRecordType == 'Temperature' &&
            _tempController.text.isEmpty) ||
        (_selectedRecordType == 'Picture' && _selectedImage == null) ||
        (_selectedRecordType == 'Other' &&
            _descriptionController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    try {
      Map<String, dynamic> eventData = {
        'eventId': eventId,
        'type': _selectedRecordType,
        'eventDate': _eventDate,
        'memo': _memo,
        'petName': widget.pet.name,
        'petId': widget.pet.id
      };

      switch (_selectedRecordType) {
        case 'Weight':
          eventData['weight'] = _weightController.text;
          eventData['weightUnit'] = _selectedWeightUnit;
          break;
        case 'Temperature':
          eventData['temperature'] = _tempController.text;
          eventData['temperatureUnit'] = _selectedTempUnit;
          break;
        case 'Picture':
          // Save the image locally and store the path
          final imagePath = await _saveImageLocally();
          eventData['imagePath'] = imagePath;
          break;
        case 'Other':
          eventData['description'] = _descriptionController.text;
          break;
      }

      var user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      DocumentReference eventDocRef = FirebaseFirestore.instance
          .collection('Events And Reminders')
          .doc(user.uid)
          .collection('PetEvents')
          .doc(widget.pet.id);

      if (widget.existingEvent != null) {
        await eventDocRef.update({
          'events': FieldValue.arrayRemove([widget.existingEvent])
        });
        await eventDocRef.update({
          'events': FieldValue.arrayUnion([eventData])
        });
      } else {
        await eventDocRef.set({
          'events': FieldValue.arrayUnion([eventData])
        }, SetOptions(merge: true));
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PetDetailPage(pet: widget.pet)),
        (Route<dynamic> route) => route.isFirst,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save event: $e')),
      );
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _tempController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecordTypeDropdown(),
            SizedBox(height: 20),
            _buildDynamicContent(),
            SizedBox(height: 20),
            _buildEventDatePicker(),
            SizedBox(height: 20),
            _buildMemoField(),
            SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRecordType,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRecordType = newValue;
        });
      },
      items: ['Weight', 'Temperature', 'Picture', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Record Type',
        labelStyle: TextStyle(color: PetRecordColor.theme),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PetRecordColor.theme),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PetRecordColor.focusColor),
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    switch (_selectedRecordType) {
      case 'Weight':
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight ($_selectedWeightUnit)',
                  labelStyle: TextStyle(color: PetRecordColor.theme),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.theme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.focusColor),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedWeightUnit,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWeightUnit = newValue!;
                });
              },
              items: <String>['kg', 'lb']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      case 'Picture':
        return _buildImagePicker();
      case 'Temperature':
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tempController,
                decoration: InputDecoration(
                  labelText: 'Temperature ($_selectedTempUnit)',
                  labelStyle: TextStyle(color: PetRecordColor.theme),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.theme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.focusColor),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedTempUnit,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTempUnit = newValue!;
                });
              },
              items: <String>['°C', '°F']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        );

      case 'Other':
        return TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Event Title',
            labelStyle: TextStyle(color: PetRecordColor.theme),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: PetRecordColor.theme),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: PetRecordColor.focusColor),
            ),
          ),
          onChanged: (value) {
            _description = value;
          },
        );
      default:
        return Container();
    }
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await _pickImageAndDisplay(ImageSource.gallery);
          },
          child: Text(
            'Select Picture',
            style: TextStyle(color: Colors.white),
          ),
          style:
              ElevatedButton.styleFrom(backgroundColor: PetRecordColor.theme),
        ),
        if (_selectedImage != null)
          Image.memory(
            _selectedImage!,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
      ],
    );
  }

  Widget _buildEventDatePicker() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Event Date',
        labelStyle: TextStyle(color: PetRecordColor.theme),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PetRecordColor.theme),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PetRecordColor.focusColor),
        ),
      ),
      controller: TextEditingController(
        text: "${_eventDate.toLocal()}".split(' ')[0],
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _eventDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: PetRecordColor.theme,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null && pickedDate != _eventDate)
          setState(() {
            _eventDate = pickedDate;
          });
      },
    );
  }

  Widget _buildMemoField() {
    return TextFormField(
      controller: _memoController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Memo',
        labelStyle: TextStyle(color: PetRecordColor.theme),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PetRecordColor.theme),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PetRecordColor.focusColor),
        ),
      ),
      onChanged: (value) {
        _memo = value;
      },
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
        onTap: saveEvent,
        child: Center(
          child: Container(
            height: 40.h,
            width: 100.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: PetRecordColor.theme,
            ),
            child: Center(
              child: Text(
                'Save',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ));
  }
}
