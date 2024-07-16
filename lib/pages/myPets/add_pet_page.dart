import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AddPetPage extends StatefulWidget {
  @override
  _AddPetPageState createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  double height = 0.00;
  double width = 0.00;

  TextEditingController petNameController = TextEditingController();
  TextEditingController bDayController = TextEditingController();
  TextEditingController petTypeController = TextEditingController();
  TextEditingController petWeightController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  Uint8List? _selectedImage;
  late DateTime selectedDate;
  String? selectedGender;
  String selectedWeightUnit = 'kg';
  bool dontKnowBirthday = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    bDayController.text =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!dontKnowBirthday) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
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
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          bDayController.text =
              "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
        });
      }
    } else {
      // Handle "Don't know" birthday scenario
      setState(() {
        bDayController.text = "Don't know";
      });
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
    String petId = Uuid().v4();

    String name = petNameController.text;
    String? gender = selectedGender;
    String birthday = bDayController.text;
    String type = petTypeController.text;
    String weight = petWeightController.text;
    String note = noteController.text;

    // Check if "Don't know" birthday is selected
    if (dontKnowBirthday) {
      // Set birthday to a placeholder value
      birthday = "Don't know";
    }

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

    String petImage = '';

    if (_selectedImage != null) {
      petImage = await uploadPetImage(_selectedImage!, petId);
    }

    var user = FirebaseAuth.instance.currentUser;
    String documentName = user?.uid ?? '';
    String collectionName = 'Pets';

    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collectionName);

    try {
      // Check if the document already exists
      DocumentSnapshot docSnapshot =
          await collectionRef.doc(documentName).get();

      if (docSnapshot.exists) {
        // Document exists, update it
        await collectionRef.doc(documentName).update({
          'files': FieldValue.arrayUnion([
            {
              'id': petId,
              'name': name,
              'gender': gender,
              'birthday': birthday,
              'type': type,
              'weight': weight,
              'weightUnit': selectedWeightUnit,
              'note': note,
              'image': petImage,
            }
          ])
        });
      } else {
        // Document does not exist, create it
        await collectionRef.doc(documentName).set({
          'files': [
            {
              'id': petId,
              'name': name,
              'gender': gender,
              'birthday': birthday,
              'type': type,
              'weight': weight,
              'weightUnit': selectedWeightUnit,
              'note': note,
              'image': petImage,
            }
          ]
        });
      }

      // Navigate back to previous screen
      Navigator.pop(context, 'refresh');
    } catch (e) {
      print("Error saving pet: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to save pet information."),
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
    height = size.height;
    width = size.width;

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
          'Add Pet',
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
              SizedBox(height: height / 56),
              Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextField(
                controller: petNameController,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                cursorColor: PetRecordColor.grey,
                style: TextStyle(
                  fontSize: 15,
                  color: PetRecordColor.black,
                ),
                decoration: InputDecoration(
                  hintText: "Pet's name",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: PetRecordColor.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  prefixIcon:
                      Icon(Icons.pets_outlined, color: PetRecordColor.theme),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.theme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.focusColor),
                  ),
                ),
                onChanged: (value) {},
              ),
              SizedBox(height: height / 56),
              Text('Gender',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Radio(
                            value: 'Male',
                            groupValue: selectedGender,
                            activeColor: PetRecordColor.theme,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value as String?;
                              });
                            }),
                        Text('Male'),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Radio(
                            value: 'Female',
                            groupValue: selectedGender,
                            activeColor: PetRecordColor.theme,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value as String?;
                              });
                            }),
                        Text('Female'),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Radio(
                            value: 'No Setting',
                            groupValue: selectedGender,
                            activeColor: PetRecordColor.theme,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value as String?;
                              });
                            }),
                        Text('No Setting'),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: dontKnowBirthday,
                        onChanged: (value) {
                          setState(() {
                            dontKnowBirthday = value!;
                            if (dontKnowBirthday) {
                              bDayController.text = "";
                            } else {
                              // Reset to current date or initial value if needed
                              bDayController.text =
                                  "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                            }
                          });
                        },
                        // height:30,
                        activeColor: PetRecordColor.theme,
                      ),
                      Text("Don't know"),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: TextFormField(
                  controller: bDayController,
                  readOnly:
                      dontKnowBirthday, // Make readonly if "Don't know" is checked
                  onTap: () {
                    if (dontKnowBirthday) {
                      // Show a message or handle as per your requirement
                    } else {
                      _selectDate(context); // Allow date selection
                    }
                  },
                  cursorColor: PetRecordColor.grey,
                  style: TextStyle(
                    fontSize: 15,
                    color:
                        dontKnowBirthday ? Colors.grey : PetRecordColor.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "yyyy - mm - dd",
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: PetRecordColor.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    prefixIcon:
                        Icon(Icons.cake_outlined, color: PetRecordColor.theme),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: PetRecordColor.theme),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: PetRecordColor.focusColor),
                    ),
                    filled: true,
                    fillColor:
                        dontKnowBirthday ? Colors.grey[200] : Colors.white,
                  ),
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: height / 56),
              Text(
                "Pet Type",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextField(
                controller: petTypeController,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                cursorColor: PetRecordColor.grey,
                style: TextStyle(
                  fontSize: 15,
                  color: PetRecordColor.black,
                ),
                decoration: InputDecoration(
                  hintText: "Cat, Dog, Bird...",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: PetRecordColor.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  prefixIcon: Icon(Icons.pets, color: PetRecordColor.theme),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.theme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.focusColor),
                  ),
                ),
                onChanged: (value) {},
              ),
              SizedBox(height: height / 56),
              Text(
                "Weight",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: petWeightController,
                      scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      cursorColor: PetRecordColor.grey,
                      style: TextStyle(
                        fontSize: 15,
                        color: PetRecordColor.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Pet weight",
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: PetRecordColor.grey,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        prefixIcon: Icon(Icons.monitor_weight_outlined,
                            color: PetRecordColor.theme),
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
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedWeightUnit,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedWeightUnit = newValue!;
                          });
                        },
                        items: <String>['kg', 'lb']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height / 56),
              Text('Note',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextFormField(
                controller: noteController,
                minLines: 3, // Minimum number of lines to display
                maxLines:
                    3, // Maximum number of lines to display before scrolling
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                cursorColor: PetRecordColor.grey,
                style: TextStyle(
                  fontSize: 15,
                  color: PetRecordColor.black,
                ),
                decoration: InputDecoration(
                  hintText: "Additional information about your pet",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: PetRecordColor.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  prefixIcon:
                      Icon(Icons.book_outlined, color: PetRecordColor.theme),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.theme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: PetRecordColor.focusColor),
                  ),
                ),
                onChanged: (value) {},
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  await savePet();
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
