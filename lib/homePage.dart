import 'package:flutter/material.dart';
import 'package:sql_demo/Data/local/db_helper.dart';
import 'package:sql_demo/Utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  int? currentNoteSno;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: allNotes.isNotEmpty
            ? ListView.builder(
            itemCount: allNotes.length,
            itemBuilder: (_, index) {
              return Card(
                elevation: 8,
                color: Colors.white70,
                margin: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent.shade400,
                    child: Text(
                      // Use the list index for numbering
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    allNotes[index][dbRef!.COLUMN_NOTE_TITLE],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    allNotes[index][dbRef!.COLUMN_NOTE_DESC],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          currentNoteSno = allNotes[index]
                          [dbRef!.COLUMN_NOTE_SNO];
                          titleController.text = allNotes[index]
                          [dbRef!.COLUMN_NOTE_TITLE];
                          descController.text = allNotes[index]
                          [dbRef!.COLUMN_NOTE_DESC];
                          showBottomSheet(context, isUpdate: true);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          dbRef!.deleteNote(
                              sno: allNotes[index]
                              [dbRef!.COLUMN_NOTE_SNO]);
                          getNotes();
                        },
                      ),
                    ],
                  ),
                ),
              );
            })
            : const Center(
          child: Text(
            'No Notes Yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleController.clear();
          descController.clear();
          currentNoteSno = null;
          showBottomSheet(context);
        },
        child: const Icon(Icons.add, size: 30),
        backgroundColor: Colors.deepPurpleAccent.shade400,
        elevation: 8,
      ),
    );
  }

  void showBottomSheet(BuildContext context, {bool isUpdate = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: 5,
                blurRadius: 15,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: BottomSheetView(
              titleController: titleController,
              descController: descController,
              getNotes: getNotes,
              isUpdate: isUpdate,
              currentNoteSno: currentNoteSno,
            ),
          ),
        );
      },
    );
  }
}

class BottomSheetView extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final VoidCallback getNotes;
  final bool isUpdate;
  final int? currentNoteSno;

  const BottomSheetView({
    Key? key,
    required this.titleController,
    required this.descController,
    required this.getNotes,
    this.isUpdate = false,
    this.currentNoteSno,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BottomSheetViewState();
}

class _BottomSheetViewState extends State<BottomSheetView> {
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isUpdate ? 'Update Note' : 'Add Note',
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: "Enter Your Title",
              hintStyle: const TextStyle(color: Colors.black38),
              label: const Text('Title *', style: TextStyle(color: Colors.black87)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(width: 1, color: Colors.black54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(width: 2, color: Colors.deepPurpleAccent),
              ),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter Your Description",
              hintStyle: const TextStyle(color: Colors.black38),
              label: const Text('Description *', style: TextStyle(color: Colors.black87)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(width: 1, color: Colors.black54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(width: 2, color: Colors.deepPurpleAccent),
              ),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    var title = widget.titleController.text;
                    var desc = widget.descController.text;
                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check;
                      if (widget.isUpdate && widget.currentNoteSno != null) {
                        check = await DBHelper.getInstance.updateNote(
                          mTitle: title,
                          mDesc: desc,
                          sno: widget.currentNoteSno!,
                        );
                      } else {
                        check = await DBHelper.getInstance.addNote(
                          mTitle: title,
                          mDesc: desc,
                        );
                      }
                      if (check) {
                        widget.getNotes();
                        Navigator.pop(context);
                      }
                    } else {
                      setState(() {
                        errorMsg = "*Please fill all the required fields";
                      });
                    }
                  },
                  child: Text(widget.isUpdate ? 'Update Note' : 'Add Note'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(errorMsg, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
