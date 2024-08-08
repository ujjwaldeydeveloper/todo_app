import 'package:flutter/material.dart';

import '../../data/local_data/notes_database.dart';
import '../../domain/model/note.dart';
import 'edit_note_details_page.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo App'),
        actions: [
          SizedBox(
            width: 200,
            child: TextField(
              onChanged: (value) async {
                notes = await NotesDatabase.instance.searchNotes(value);
                setState(() {});
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Search...',
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : notes.isEmpty
                ? const Text('No Notes')
                : buildNotes(notes),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditNotePage()),
          );

          refreshNotes();
        },
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.3),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildNotes(List<Note> notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          color: note.isComplete ? Colors.yellow : Colors.white,
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: note.isComplete
                ? IconButton(
                    icon: const Icon(Icons.check_box),
                    onPressed: () async {
                      await NotesDatabase.instance.update(note.copyWith(
                        isComplete: !note.isComplete,
                      ));
                      refreshNotes();
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.check_box_outline_blank),
                    onPressed: () async {
                      await NotesDatabase.instance.update(note.copyWith(
                        isComplete: !note.isComplete,
                      ));
                      refreshNotes();
                    },
                  ),
            title: Text(note.title),
            subtitle: Text(note.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await NotesDatabase.instance.delete(note.id!);
                    refreshNotes();
                  },
                ),
                IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddEditNotePage(note: note),
                      // NoteDetailPage(noteId: note.id!),
                    ));
                    refreshNotes();
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
