import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/pages/myPets/pet_detail_page.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';
import 'package:uuid/uuid.dart';

class Reminder extends StatefulWidget {
  final Pet pet;
  final Map<String, dynamic>? existingReminder;

  Reminder({required this.pet, this.existingReminder});
  @override
  _ReminderState createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  String? _selectedReminderType;
  bool _isOnce = true;
  bool _setEndDate = false;
  DateTime _selectedStartDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime? _selectedEndDate;
  int _frequencyNumber = 1;
  String _frequencyUnit = 'Day';
  String _note = '';
  late String reminderId;

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      reminderId = widget.existingReminder!['reminderId'];
      _selectedReminderType = widget.existingReminder!['type'];
      _isOnce = widget.existingReminder!['isOnce'];

      if (widget.existingReminder!['startDate'] is Timestamp) {
        _selectedStartDate =
            (widget.existingReminder!['startDate'] as Timestamp).toDate();
      } else if (widget.existingReminder!['startDate'] is DateTime) {
        _selectedStartDate = widget.existingReminder!['startDate'];
      }

      if (widget.existingReminder!['time'] is String) {
        final timeParts = widget.existingReminder!['time'].split(" ");
        final timeOfDayParts = timeParts[0].split(":");
        int hour = int.parse(timeOfDayParts[0]);
        final minute = int.parse(timeOfDayParts[1]);
        final period = timeParts[1] == "AM" ? DayPeriod.am : DayPeriod.pm;
        if (timeParts[1] == "PM" && hour != 12) {
          hour += 12;
        } else if (timeParts[1] == "AM" && hour == 12) {
          hour = 0;
        }

        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }

      _note = widget.existingReminder!['note'];

      if (widget.existingReminder!['endDate'] != null) {
        _setEndDate = true;
        if (widget.existingReminder!['endDate'] is Timestamp) {
          _selectedEndDate =
              (widget.existingReminder!['endDate'] as Timestamp).toDate();
        } else if (widget.existingReminder!['endDate'] is DateTime) {
          _selectedEndDate = widget.existingReminder!['endDate'];
        }
      }

      if (!_isOnce) {
        _frequencyNumber = widget.existingReminder!['frequencyNumber'];
        _frequencyUnit = widget.existingReminder!['frequencyUnit'];
      }
    } else {
      reminderId = Uuid().v4();
    }
  }

  Future<void> saveReminder() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference remindersRef = FirebaseFirestore.instance
        .collection('Events And Reminders')
        .doc(user.uid)
        .collection('PetReminders')
        .doc(widget.pet.id);

    Map<String, dynamic> reminderData = {
      'reminderId': reminderId,
      'type': _selectedReminderType,
      'isOnce': _isOnce,
      'startDate': _selectedStartDate,
      'time': _selectedTime.format(context),
      'note': _note,
      'petName': widget.pet.name,
      'petId': widget.pet.id,
    };

    if (_isOnce || _selectedReminderType == 'Appointment / Surgery') {
      DateTime notificationTime = _selectedStartDate;
      reminderData['notificationTimes'] = [notificationTime];
    } else {
      List<DateTime> notificationTimes = [];
      DateTime startDate = _selectedStartDate;

      DateTime endDate =
          _selectedEndDate ?? _selectedStartDate.add(Duration(days: 2000));

      while (startDate.isBefore(endDate)) {
        DateTime notificationTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        notificationTimes.add(notificationTime);

        switch (_frequencyUnit) {
          case 'Day':
            startDate = startDate.add(Duration(days: _frequencyNumber));
            break;
          case 'Week':
            startDate = startDate.add(Duration(days: 7 * _frequencyNumber));
            break;
          case 'Month':
            startDate = DateTime(startDate.year,
                startDate.month + _frequencyNumber, startDate.day);
            break;
          case 'Year':
            startDate = DateTime(startDate.year + _frequencyNumber,
                startDate.month, startDate.day);
            break;
        }
      }

      reminderData['notificationTimes'] = notificationTimes;
    }

    if (widget.existingReminder != null) {
      await remindersRef.update({
        'reminders': FieldValue.arrayRemove([widget.existingReminder])
      });
      await remindersRef.update({
        'reminders': FieldValue.arrayUnion([reminderData])
      });
    } else {
      await remindersRef.set({
        'reminders': FieldValue.arrayUnion([reminderData])
      }, SetOptions(merge: true));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder saved successfully!')),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PetDetailPage(pet: widget.pet)),
      (Route<dynamic> route) => route.isFirst,
    );
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
            if (_isOnce)
              _buildDateTimePicker()
            else ...[
              _buildDateTimePicker(),
              SizedBox(height: 20),
              _buildSetEndDateCheckbox(),
              if (_setEndDate) _buildEndDatePicker(),
            ],
            SizedBox(height: 20),
            _buildNoteField(),
            SizedBox(height: 20),
            _buildReviewButton(),
          ],
        )),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    return DropdownButtonFormField<String>(
      value: _selectedReminderType,
      onChanged: (String? newValue) {
        setState(() {
          _selectedReminderType = newValue;
          if (_selectedReminderType == 'Birthday') {
            _isOnce = true;
            _setEndDate = false;
            _frequencyNumber = 1;
            _frequencyUnit = 'Day';
          }
        });
      },
      items: <String>[
        'Appointment / Surgery',
        'Grooming & Care',
        'Exercise & Activity',
        'Vaccine / Deworming',
        'Medication',
        'Weight Measurement',
        'Take a Photo',
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
    return !['Appointment / Surgery'].contains(_selectedReminderType);
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
    if (_isOnce) {
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
            initialDate: _selectedStartDate,
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
                _selectedStartDate = DateTime(
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
              '${_selectedStartDate.year}/${_selectedStartDate.month}/${_selectedStartDate.day} ${_selectedTime.format(context)}',
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "Every",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _frequencyNumber,
                      onChanged: (int? newValue) {
                        setState(() {
                          _frequencyNumber = newValue!;
                        });
                      },
                      items: List<int>.generate(30, (index) => index + 1)
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _frequencyUnit,
                      onChanged: (String? newValue) {
                        setState(() {
                          _frequencyUnit = newValue!;
                        });
                      },
                      items: <String>['Day', 'Week', 'Month']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: GestureDetector(
                      onTap: () async {
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
                            _selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            size: 16,
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select Starting Date',
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
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedStartDate,
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
                setState(() {
                  _selectedStartDate = pickedDate;
                });
              }
            },
            controller: TextEditingController(
              text:
                  '${_selectedStartDate.year}/${_selectedStartDate.month}/${_selectedStartDate.day}',
            ),
          ),
        ],
      );
    }
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
              initialDate: _selectedStartDate,
              firstDate: _selectedStartDate,
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

  Widget _buildNoteField() {
    return TextFormField(
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Note',
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
        setState(() {
          _note = value;
        });
      },
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
