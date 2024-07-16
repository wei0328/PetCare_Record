import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

final storageRef =
    FirebaseStorage.instanceFor(bucket: 'gs://petcarerecord.appspot.com').ref();

Future<Uint8List?> pickImage(ImageSource source) async {
  try {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);

    if (file != null) {
      return await file.readAsBytes();
    } else {
      print("No Image Selected");
      return null;
    }
  } catch (e) {
    print("Error picking image: $e");
    return null;
  }
}

Future<Uint8List?> downloadImage(String imageName) async {
  try {
    print("Attempting to download image with name: $imageName");
    final ref = storageRef.child(imageName);
    final imageUrl = await ref.getDownloadURL();
    print("Image URL: $imageUrl");
    final http.Response response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print("Failed to download image, status code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    if (e is firebase_storage.FirebaseException &&
        e.code == 'object-not-found') {
      print("No object exists at the desired reference.");
    } else {
      print("Error downloading image: $e");
    }
    return null;
  }
}

Future<void> uploadUserImage() async {
  Uint8List? img = await pickImage(ImageSource.gallery);
  if (img != null) {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName = 'profile_image_$userId.jpg';
      firebase_storage.Reference reference =
          firebase_storage.FirebaseStorage.instance.ref('userImages/$fileName');

      firebase_storage.SettableMetadata metadata =
          firebase_storage.SettableMetadata(
              contentType: 'image/jpeg', customMetadata: {'overwrite': 'true'});

      await reference.putData(img, metadata);

      String downloadUrl = await reference.getDownloadURL();
      print("Image uploaded successfully: $downloadUrl");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }
}

Future<String> uploadPetImage(Uint8List imgData, String petId) async {
  if (imgData != null) {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName = 'pets_image_$userId _$petId.jpg';
      firebase_storage.Reference reference =
          firebase_storage.FirebaseStorage.instance.ref('petImages/$fileName');

      firebase_storage.SettableMetadata metadata =
          firebase_storage.SettableMetadata(
              contentType: 'image/jpeg', customMetadata: {'overwrite': 'true'});

      await reference.putData(imgData, metadata);

      String downloadUrl = await reference.getDownloadURL();
      print("Image uploaded successfully: $downloadUrl");
      return downloadUrl; // Return the download URL
    } catch (e) {
      print("Error uploading image: $e");
      return ''; // Handle error case, returning an empty string
    }
  }
  return ''; // Handle case where imgData is null
}
