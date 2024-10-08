import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/image.dart';
import 'package:petcare_record/pages/myPets/add_pet_page.dart';
import 'package:petcare_record/pages/myPets/edit_page.dart';
import 'package:petcare_record/pages/myPets/pet_detail_page.dart';

class Pet {
  final String name;
  final String gender;
  final String birthday;
  final String type;
  final String weight;
  final String note;
  final String petImageName;
  final String weightUnit;
  final String id;
  Uint8List? petImage;

  Pet({
    required this.name,
    required this.gender,
    required this.birthday,
    required this.type,
    required this.weight,
    required this.weightUnit,
    required this.note,
    required this.petImageName,
    required this.id,
    this.petImage,
  });
}

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({Key? key}) : super(key: key);

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  double height = 0.00;
  double width = 0.00;

  List<Pet> pets = [];
  bool isLoading = true;

  Future<void> fetchPetsData() async {
    var user = FirebaseAuth.instance.currentUser;
    String documentName = user?.uid ?? '';
    String collectionName = 'Pets';

    final DocumentReference documentRef =
        FirebaseFirestore.instance.collection(collectionName).doc(documentName);

    try {
      DocumentSnapshot documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        List<Pet> loadedPets = [...pets]; // Maintain existing pets
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        List<dynamic> filesData = data['files'] ?? [];

        // Add new pets that are not already in the pets list
        for (var fileData in filesData) {
          String petImageName = fileData['image'] ?? '';
          Uint8List? petImage;
          print(petImageName);
          if (petImageName != '') {
            print("Profile image name: $petImageName");
            Uint8List? imageBytes =
                await downloadImage("petImages/$petImageName");
            if (imageBytes != null) {
              petImage = imageBytes;
              print("Image set successfully");
            } else {
              print("Image download returned null");
            }
          } else {
            petImage = null;
            print("No profile image found");
          }

          // Check if pet already exists in pets list
          bool petExists = loadedPets.any((pet) => pet.id == fileData['id']);
          if (!petExists) {
            loadedPets.add(Pet(
              name: fileData['name'] ?? '',
              gender: fileData['gender'] ?? '',
              birthday: fileData['birthday'] ?? '',
              type: fileData['type'] ?? '',
              weight: fileData['weight'] ?? '',
              note: fileData['note'] ?? '',
              petImageName: petImageName,
              weightUnit: fileData['weightUnit'] ?? '',
              id: fileData['id'] ?? '',
              petImage: petImage,
            ));
          }
        }

        setState(() {
          pets = loadedPets;
          isLoading = false;
        });
      } else {
        print("Document does not exist");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching pets: $e");
      // Handle error fetching pets data
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchEditPetData(String petId) async {
    var user = FirebaseAuth.instance.currentUser;
    String documentName = user?.uid ?? '';
    String collectionName = 'Pets';

    final DocumentReference documentRef =
        FirebaseFirestore.instance.collection(collectionName).doc(documentName);

    try {
      DocumentSnapshot documentSnapshot = await documentRef.get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        List<dynamic> filesData = data['files'] ?? [];

        for (var fileData in filesData) {
          if (fileData['id'] == petId) {
            String petImageName = fileData['image'] ?? '';
            Uint8List? petImage;
            if (petImageName.isNotEmpty) {
              Uint8List? imageBytes =
                  await downloadImage("petImages/$petImageName");
              petImage = imageBytes ?? null;
            }

            Pet updatedPet = Pet(
              name: fileData['name'] ?? '',
              gender: fileData['gender'] ?? '',
              birthday: fileData['birthday'] ?? '',
              type: fileData['type'] ?? '',
              weight: fileData['weight'] ?? '',
              note: fileData['note'] ?? '',
              petImageName: petImageName,
              weightUnit: fileData['weightUnit'] ?? '',
              id: fileData['id'] ?? '',
              petImage: petImage,
            );

            setState(() {
              int index = pets.indexWhere((pet) => pet.id == petId);
              if (index != -1) {
                pets[index] = updatedPet;
              }
            });
            break;
          }
        }
      }
    } catch (e) {
      print("Error fetching pet data: $e");
    }
  }

  Future<void> deletePet(String id, String petImageName) async {
    var user = FirebaseAuth.instance.currentUser;
    String documentName = user?.uid ?? '';
    String collectionName = 'Pets';

    DocumentReference docRef =
        FirebaseFirestore.instance.collection(collectionName).doc(documentName);

    // Fetch the current pet data
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> petsData = data['files'] ?? [];

      // Filter out the pet with the specified ID
      List<dynamic> updatedPetsData =
          petsData.where((pet) => pet['id'] != id).toList();

      // Update the document with the modified pet data
      await docRef.update({
        'files': updatedPetsData,
      });

      // Update local pets list
      setState(() {
        pets.removeWhere((pet) => pet.id == id);
      });

      // Delete the associated image from Firebase Storage
      if (petImageName.isNotEmpty) {
        try {
          await FirebaseStorage.instance
              .ref('petImages/$petImageName')
              .delete();
          print('Image deleted successfully');
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
    } else {
      print('Document does not exist');
    }
  }

  Future<void> refreshPetsData() async {
    setState(() {
      isLoading = true;
    });
    await fetchPetsData();
  }

  @override
  void initState() {
    super.initState();
    refreshPetsData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PetRecordColor.theme,
        title: Text(
          'My Pets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: PetRecordColor.white,
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
                weight: 600,
              ),
              onPressed: () async {
                String refresh = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddPetPage()));
                if (refresh == 'refresh') {
                  refreshPetsData();
                }
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(PetRecordColor.theme),
                )
              : pets.isEmpty
                  ? Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddPetPage()),
                          ).then((refresh) {
                            if (refresh == 'refresh') {
                              // Refresh data here
                              refreshPetsData();
                            }
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: PetRecordColor.theme,
                          ),
                          child: Center(
                            child: Text(
                              'Add a Pet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        Pet pet = pets[index];
                        return Dismissible(
                          key: Key(pet.id),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            deletePet(pet.id, pet.petImageName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 10.0),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: ListTile(
                                      leading: pet.petImage != null
                                          ? CircleAvatar(
                                              radius: 30,
                                              backgroundImage:
                                                  MemoryImage(pet.petImage!),
                                            )
                                          : CircleAvatar(
                                              radius: 30,
                                              backgroundColor: Colors.grey[200],
                                              child: Icon(
                                                Icons.pets,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      title: Text(
                                        pet.name,
                                        style: TextStyle(
                                          fontSize: 20, // Adjusted font size
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PetDetailPage(pet: pet),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      iconSize: 16,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Theme(
                                              data: ThemeData(
                                                dialogBackgroundColor:
                                                    Colors.white,
                                              ),
                                              child: AlertDialog(
                                                title: Text("Delete Pet"),
                                                content: Text(
                                                    "Are you sure you want to delete this pet?"),
                                                actions: [
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          PetRecordColor.theme,
                                                    ),
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          PetRecordColor.theme,
                                                    ),
                                                    child: Text('Delete'),
                                                    onPressed: () {
                                                      deletePet(pet.id,
                                                          pet.petImageName);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: TextButton(
                                      onPressed: () async {
                                        // Handle edit pet action
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditPetPage(petId: pet.id),
                                          ),
                                        ).then((refresh) {
                                          if (refresh == 'refresh') {
                                            fetchEditPetData(pet.id);
                                          }
                                        });
                                      },
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: PetRecordColor.theme,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
