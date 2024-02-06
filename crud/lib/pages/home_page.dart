import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crud/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}





class _HomePageState extends State<HomePage> {

// firestore
final FirestoreService  firestoreService = FirestoreService();

  // Text Controller
final TextEditingController textController = TextEditingController();

  // Open a dialog to add notes
  void openNoteBox({String? docId}){
    showDialog(context: context, builder: (context) => AlertDialog(
      content: TextField(
        controller: textController,
      ),
      actions: [
        // bottom to save
        ElevatedButton(
          onPressed:  () {
            // Add a new note
            if(docId==null) {
              firestoreService.addNote(textController.text);
            }

            // update on existing note
            else{
              firestoreService.updateNote(docId, textController.text);
            }

            // Clear the textController
            textController.clear();

            // Close the box
            Navigator.pop(context);
          }, 
          child: Text("Add")
        )
      ],
    ),);
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // If we have data get all the notes
          if(snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
            itemCount: noteList.length,
            itemBuilder: (context, index) {
              // get each individual doc
              DocumentSnapshot document = noteList[index];
              String docId = document.id;

              // get note from each doc
              Map<String, dynamic> data = document.data() as  Map<String, dynamic>;
              String noteText = data["note"];

              // display as a list tile
              return ListTile(
                title: Text(noteText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      // update button
                      IconButton(
                      onPressed: () => openNoteBox(docId: docId),
                      icon: const Icon(Icons.settings)

                    ),
                    // delete button
                    IconButton(
                      onPressed: () => firestoreService.deleteNote(docId),
                      icon: const Icon(Icons.delete)
                    ),
                  ],
                )
              );

              // display as a list title

            },);
          }

          // if there is no data return 
          else {
            return const Text("No notes...");
          }
        },
      ),
    );
  }
}