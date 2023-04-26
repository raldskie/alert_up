import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' as io;

Future<String?> uploadFile(
    {required PlatformFile file, required String folder}) async {
  // Create a Reference to the file
  try {
    Reference ref =
        FirebaseStorage.instance.ref().child(folder).child('/${file.name}');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path!},
    );

    final TaskSnapshot snapshot =
        await ref.putFile(io.File(file.path!), metadata);

    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    return null;
  }
}
