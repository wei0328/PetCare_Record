import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/pages/addEvent/add_new.dart';
import 'package:petcare_record/pages/myPets/event_tab.dart';
import 'package:intl/intl.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';

class PetDetailPage extends StatelessWidget {
  final Pet pet;

  const PetDetailPage({Key? key, required this.pet}) : super(key: key);

  String _calculateAge(String birthday) {
    if (birthday.toLowerCase() == "don't know" || birthday.isEmpty) {
      return "Unknown";
    }

    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    final DateTime birthDate = dateFormat.parse(birthday);
    final DateTime currentDate = DateTime.now();

    int years = currentDate.year - birthDate.year;
    int months = currentDate.month - birthDate.month;
    int days = 0;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years == 0 && months == 0) {
      days = currentDate.day - birthDate.day;
      if (days == 0) {
        days = 1;
      }
    }

    String yearPart = years > 0 ? "$years y " : "";
    String monthPart = months > 0 ? "$months m" : "";
    String dayPart = days > 0 ? "$days days" : "";

    return "$yearPart$monthPart$dayPart".trim();
  }

  @override
  Widget build(BuildContext context) {
    IconData genderIcon;
    Color genderColor;

    if (pet.gender.toLowerCase() == 'male') {
      genderIcon = Icons.male;
      genderColor = Color.fromARGB(255, 130, 181, 219);
    } else if (pet.gender.toLowerCase() == 'female') {
      genderIcon = Icons.female;
      genderColor = Color.fromARGB(255, 225, 162, 187);
    } else {
      genderIcon = Icons.question_mark_rounded;
      genderColor = Colors.grey[600]!;
    }

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
          pet.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: PetRecordColor.white,
                size: 30,
              ),
              onPressed: () async {
                String refresh = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddNew(pet: pet)));
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                child: pet.petImage != null
                    ? Image.memory(
                        pet.petImage!,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )
                    : Icon(
                        Icons.pets,
                        size: 180,
                        color: Colors.grey,
                      ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -30),
              child: Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                pet.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: PetRecordColor.theme,
                                ),
                              ),
                              SizedBox(width: 15),
                              Text(
                                pet.type,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            genderIcon,
                            color: genderColor,
                            size: 40,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Age: ',
                            style: TextStyle(
                              color: PetRecordColor.textgray,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            _calculateAge(pet.birthday),
                            style: TextStyle(
                              color: PetRecordColor.textgray,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 40),
                          Text(
                            'Weight: ',
                            style: TextStyle(
                              color: PetRecordColor.textgray,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            _displayWeight(pet.weight, pet.weightUnit),
                            style: TextStyle(
                              color: PetRecordColor.textgray,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (pet.note.isNotEmpty) ...[
                        SizedBox(height: 5),
                        Divider(
                          color: Colors.grey[400],
                          thickness: 1.0,
                        ),
                        Text(
                          'Note: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: PetRecordColor.textgray,
                          ),
                        ),
                        Text(
                          pet.note,
                          style: TextStyle(
                            fontSize: 16,
                            color: PetRecordColor.textgray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double appBarHeight = AppBar().preferredSize.height;

                final double screenHeight = MediaQuery.of(context).size.height;
                final double availableHeight = screenHeight - appBarHeight - 60;

                return Container(
                  height: availableHeight,
                  child: EventTab(
                    pet: pet,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _displayWeight(String weight, String weightUnit) {
    if (weight.isEmpty || weight.toLowerCase() == "unknown") {
      return "Unknown";
    }
    return "$weight $weightUnit";
  }
}
