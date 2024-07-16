import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/image.dart';
import 'package:petcare_record/pages/add_pet_page.dart';

class Pet {
  final String name;
  final String gender;
  final String birthday;
  final String type;
  final String weight;
  final String note;
  final String petImage;
  final String id;

  Pet({
    required this.name,
    required this.gender,
    required this.birthday,
    required this.type,
    required this.weight,
    required this.note,
    required this.petImage,
    required this.id,
  });
}

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({Key? key}) : super(key: key);

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  List<Pet> pets = [];

  Future<void> fetchPetsData() async {
    var user = FirebaseAuth.instance.currentUser;
    String documentName = user?.uid ?? '';
    String collectionName = 'Pets';

    final DocumentReference documentRef =
        FirebaseFirestore.instance.collection(collectionName).doc(documentName);

    DocumentSnapshot documentSnapshot = await documentRef.get();

    if (documentSnapshot.exists) {
      List<Pet> loadedPets = [];
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      List<dynamic> filesData = data['files'] ?? [];

      for (var fileData in filesData) {
        String petImage = fileData['Image'] ?? '';
        loadedPets.add(Pet(
          name: fileData['name'] ?? '',
          gender: fileData['gender'] ?? '',
          birthday: fileData['birthday'] ?? '',
          type: fileData['type'] ?? '',
          weight: fileData['weight'] ?? '',
          note: fileData['note'] ?? '',
          petImage: petImage,
          id: fileData['id'] ?? '',
        ));
      }

      setState(() {
        pets = loadedPets;
      });
    } else {
      print("Document does not exist");
    }
    print(pets);
  }

  @override
  void initState() {
    super.initState();
    fetchPetsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Pets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: PetRecordColor.theme,
                size: 40,
                weight: 600,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPetPage()),
                );
              },
            ),
          )
        ],
      ),
      body: Center(
        child: pets.isEmpty
            ? CircularProgressIndicator() // Placeholder for loading state
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  Pet pet = pets[index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: pet.petImage.isEmpty
                            ? CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                child: Icon(
                                  Icons.pets,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(pet.petImage),
                              ),
                        title: Text(
                          pet.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        onTap: () {
                          // Handle tap on pet item
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
