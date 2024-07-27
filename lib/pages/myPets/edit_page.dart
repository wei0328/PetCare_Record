import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/image.dart';
import 'package:uuid/uuid.dart';

class EditPetPage extends StatefulWidget {
  final String petId;

  const EditPetPage({Key? key, required this.petId}) : super(key: key);

  @override
  _EditPetPageState createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  TextEditingController petNameController = TextEditingController();
  TextEditingController bDayController = TextEditingController();
  TextEditingController petTypeController = TextEditingController();
  TextEditingController petWeightController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  Uint8List? _selectedImage;
  DateTime selectedDate = DateTime.now();
  String? selectedGender;
  String selectedWeightUnit = 'kg';
  bool dontKnowBirthday = false;
  bool dontKnowBirthdayChecked = false;
  String petImageName = '';

  @override
  void initState() {
    super.initState();
    fetchPetDetails();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: PetRecordColor.theme),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        bDayController.text =
            "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
      });
    }
  }

  Future<void> fetchPetDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    String documentName = user?.uid ?? '';
    String collectionName = 'Pets';

    final DocumentReference documentRef =
        FirebaseFirestore.instance.collection(collectionName).doc(documentName);

    try {
      DocumentSnapshot documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? petData =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (petData != null) {
          List<dynamic>? petFiles = petData['files'] as List<dynamic>?;

          if (petFiles != null) {
            Map<String, dynamic>? pet = petFiles.firstWhere(
              (pet) => pet['id'] == widget.petId,
              orElse: () => null,
            );

            if (pet != null) {
              petNameController.text = pet['name'] ?? '';
              petTypeController.text = pet['type'] ?? '';
              petWeightController.text = pet['weight'] ?? '';
              noteController.text = pet['note'] ?? '';
              selectedGender = pet['gender'];
              selectedWeightUnit = pet['weightUnit'] ?? 'kg';
              petImageName = pet['image'] ?? '';

              String? birthday = pet['birthday'];
              if (birthday != null) {
                if (birthday.toLowerCase() == "don't know") {
                  setState(() {
                    dontKnowBirthday = true;
                    dontKnowBirthdayChecked = true;
                    bDayController.text = "Don't know";
                  });
                } else {
                  try {
                    dontKnowBirthdayChecked = false;
                    selectedDate = DateTime.parse(birthday);
                    bDayController.text =
                        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                  } catch (e) {
                    print("Error parsing birthday: $e");
                  }
                }
              } else {
                setState(() {
                  dontKnowBirthday = true;
                  dontKnowBirthdayChecked = true;
                  bDayController.text = "Don't know";
                });
              }

              if (petImageName != '') {
                Uint8List? imageBytes =
                    await downloadImage("petImages/$petImageName");
                if (imageBytes != null) {
                  setState(() {
                    _selectedImage = imageBytes;
                  });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching pet details: $e");
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

  Future<void> savePet() async {
    var user = FirebaseAuth.instance.currentUser;
    String documentName = user?.uid ?? '';
    String collectionName = 'Pets';

    String petId = widget.petId;
    String name = petNameController.text;
    String? gender = selectedGender;
    String birthday =
        dontKnowBirthday ? "Don't know" : selectedDate.toIso8601String();
    String type = petTypeController.text;
    String weight = petWeightController.text;
    String note = noteController.text;

    // Validate fields
    if (name.isEmpty || gender == null || birthday.isEmpty) {
      // Handle required fields not filled
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data: ThemeData(
              dialogBackgroundColor: Colors.white,
            ),
            child: AlertDialog(
              title: Text("Required Fields"),
              content: Text("Name, gender, and date of birth are required."),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: PetRecordColor.theme,
                  ),
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    // Validate weight if provided
    if (weight.isNotEmpty) {
      try {
        double weightValue = double.parse(weight);
        if (weightValue <= 0) {
          // Weight must be a positive number
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Invalid Weight"),
                content: Text("Weight must be a positive number."),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: PetRecordColor.theme,
                    ),
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
      } catch (e) {
        // Invalid format for weight
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Invalid Weight"),
              content: Text("Weight must be a valid number."),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: PetRecordColor.theme,
                  ),
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    // Update pet details in Firestore
    final DocumentReference documentRef =
        FirebaseFirestore.instance.collection(collectionName).doc(documentName);

    try {
      // Fetch current pet data
      DocumentSnapshot docSnapshot = await documentRef.get();
      if (docSnapshot.exists) {
        // Document exists, update the pet entry in the 'files' array
        Map<String, dynamic>? petData =
            docSnapshot.data() as Map<String, dynamic>?;

        if (petData != null) {
          List<dynamic>? petFiles = petData['files'] as List<dynamic>?;
          if (petFiles != null) {
            int index = petFiles.indexWhere((pet) => pet['id'] == petId);
            if (index != -1) {
              petFiles[index] = {
                'id': petId,
                'name': name,
                'gender': gender,
                'birthday': birthday,
                'type': type,
                'weight': weight,
                'weightUnit': selectedWeightUnit,
                'note': note,
                'image': petImageName,
              };
              await documentRef.update({
                'files': petFiles,
              });
            } else {
              print('Pet with id $petId not found in Firestore');
              return;
            }
          } else {
            print('No "files" array found in Firestore document');
            return;
          }
        }
      } else {
        print('Document $documentName does not exist in Firestore');
        return;
      }

      // Optionally, update the pet image if it has changed
      if (_selectedImage != null) {
        petImageName = await uploadPetImage(_selectedImage!, petId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pet details updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to previous screen
      Navigator.pop(context, 'refresh');
    } catch (e) {
      print("Error updating pet details: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to update pet information."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PetRecordColor.theme,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        title: Text(
          'Edit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    _selectedImage != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: MemoryImage(_selectedImage!),
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () async {
                          await _pickImageAndDisplay(ImageSource.gallery);
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: petNameController,
                decoration: InputDecoration(
                  labelText: "Pet's Name",
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
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: bDayController,
                      decoration: InputDecoration(
                        labelText: 'Birthday',
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
                          borderSide:
                              BorderSide(color: PetRecordColor.focusColor),
                        ),
                      ),
                      readOnly: true,
                      onTap:
                          dontKnowBirthday ? null : () => _selectDate(context),
                    ),
                  ),
                  SizedBox(width: 10),
                  Checkbox(
                    value: dontKnowBirthdayChecked,
                    onChanged: (value) {
                      setState(() {
                        dontKnowBirthdayChecked = value!;
                        dontKnowBirthday = dontKnowBirthdayChecked;
                        bDayController.text = dontKnowBirthday
                            ? "Don't know"
                            : "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                      });
                    },
                    activeColor: PetRecordColor.theme,
                  ),
                  Text("Don't know"),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: petTypeController,
                decoration: InputDecoration(
                  labelText: 'Type',
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
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: petWeightController,
                      decoration: InputDecoration(
                        labelText: 'Weight ($selectedWeightUnit)',
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
                          borderSide:
                              BorderSide(color: PetRecordColor.focusColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedWeightUnit,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedWeightUnit = newValue!;
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
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                items: <String>['Male', 'Female', "Don't Know"]
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Gender',
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
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
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
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: savePet,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(PetRecordColor.theme),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
