import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';
import 'package:petcare_record/pages/myPets/pet_detail_page.dart';

class AddReminder extends StatefulWidget {
  final Pet pet;

  AddReminder({required this.pet});
  @override
  _AddReminderState createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  String? _selectedReminderType;
  bool _isOnce = true;
  bool _setEndDate = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime? _selectedEndDate;
  int _frequencyNumber = 1;
  String _frequencyUnit = 'Day';

  Future<void> saveReminder() async {
    if (_selectedReminderType == null || _selectedReminderType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder type is required.')),
      );
      return;
    }

    try {
      Map<String, dynamic> reminderData = {
        'type': _selectedReminderType,
        'isOnce': _isOnce,
        'dateTime': _selectedDate,
        'time': _selectedTime.format(context),
        'frequencyNumber': _frequencyNumber,
        'frequencyUnit': _frequencyUnit,
        'startDate': _selectedDate,
        'endDate': _isOnce ? null : _selectedEndDate,
      };

      DocumentReference petDocRef =
          FirebaseFirestore.instance.collection('Reminders').doc(widget.pet.id);

      DocumentSnapshot petDocSnapshot = await petDocRef.get();
      if (!petDocSnapshot.exists) {
        await petDocRef.set({'reminders': []});
      }

      await petDocRef.update({
        'reminders': FieldValue.arrayUnion([reminderData]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PetDetailPage(pet: widget.pet),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildDropdownMenu(),
              SizedBox(height: 20),
              if (_shouldShowFrequencySelector()) _buildFrequencySelector(),
              SizedBox(height: 20),
              _buildDateTimePicker(),
              if (!_isOnce) ...[
                SizedBox(height: 20),
                _buildSetEndDateCheckbox(),
                if (_setEndDate) _buildEndDatePicker(),
              ],
              SizedBox(height: 20),
              _buildReviewButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    return DropdownButtonFormField<String>(
      value: _selectedReminderType,
      onChanged: (String? newValue) {
        setState(() {
          _selectedReminderType = newValue;
        });
      },
      items: <String>[
        'Appointment',
        'Bath',
        'Birthday',
        'Exercise',
        'Food',
        'Grooming',
        'Medication',
        'Picture',
        'Surgery',
        'Treatment',
        'Vaccine',
        'Walk',
        'Weight',
        'Deworming',
        'Other'
      ]
          .map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: 'Select a reminder type',
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

  bool _shouldShowFrequencySelector() {
    return !['Appointment', 'Birthday', 'Surgery']
        .contains(_selectedReminderType);
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Radio(
              value: true,
              groupValue: _isOnce,
              activeColor: PetRecordColor.theme,
              onChanged: (bool? value) {
                setState(() {
                  _isOnce = value!;
                });
              },
            ),
            Text('Once'),
            Radio(
              value: false,
              groupValue: _isOnce,
              activeColor: PetRecordColor.theme,
              onChanged: (bool? value) {
                setState(() {
                  _isOnce = value!;
                });
              },
            ),
            Text('Repeat'),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Schedule Date and Time',
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
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: PetRecordColor.theme,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: _selectedTime,
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: PetRecordColor.theme,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedTime != null) {
            setState(() {
              _selectedDate = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              _selectedTime = pickedTime;
            });
          }
        }
      },
      controller: TextEditingController(
        text:
            '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day} ${_selectedTime.format(context)}',
      ),
    );
  }

  Widget _buildSetEndDateCheckbox() {
    return CheckboxListTile(
      title: Text("Set Ending Date"),
      value: _setEndDate,
      onChanged: (bool? value) {
        setState(() {
          _setEndDate = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: PetRecordColor.theme,
    );
  }

  Widget _buildEndDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Select Ending Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Select Date',
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
          readOnly: true,
          onTap: () async {
            DateTime? pickedEndDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: _selectedDate,
              lastDate: DateTime(2101),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: PetRecordColor.theme,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );

            if (pickedEndDate != null) {
              setState(() {
                _selectedEndDate = pickedEndDate;
              });
            }
          },
          controller: TextEditingController(
            text: _selectedEndDate != null
                ? '${_selectedEndDate!.year}/${_selectedEndDate!.month}/${_selectedEndDate!.day}'
                : '',
          ),
        ),
      ],
    );
  }

  Widget _buildReviewButton() {
    return InkWell(
        onTap: () async {
          saveReminder();
        },
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
