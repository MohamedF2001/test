import 'package:flutter/material.dart';

import 'node_edit.dart';
import '../model/note.dart';
import 'note_details.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditScreen()),
    );
    if (result != null) {
      setState(() {
        notes.add(result);
      });
    }
  }

  void _viewNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
    if (result != null) {
      setState(() {
        if (result == 'delete') {
          notes.removeWhere((item) => item.id == note.id);
        } else {
          int index = notes.indexWhere((item) => item.id == note.id);
          if (index != -1) {
            notes[index] = result;
          }
        }
      });
    }
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                notes.removeWhere((item) => item.id == note.id);
              });
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _reorderNotes(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Note item = notes.removeAt(oldIndex);
      notes.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Mes Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: ReorderableListView(
        onReorder: _reorderNotes,
        children: notes.map((note) {
          return Dismissible(
            key: Key(note.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                notes.removeWhere((item) => item.id == note.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${note.title} supprimée')),
              );
            },
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirmer la suppression'),
                    content: const Text(
                        'Êtes-vous sûr de vouloir supprimer cette note ?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(note.title),
                onTap: () => _viewNote(note),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteNote(note),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.black,
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
