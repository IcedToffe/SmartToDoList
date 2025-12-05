import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ToDoPage extends StatefulWidget {
const ToDoPage({super.key});

@override
State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
final TextEditingController taskController = TextEditingController();
final TextEditingController searchController = TextEditingController();

List<Map<String, dynamic>> tasks = [];
Uint8List? selectedImage;

String selectedCategory = "General";
String selectedPriority = "Medium";

final categoryColors = {
"General": Colors.blue,
"Work": Colors.green,
"School": Colors.orange,
"Personal": Colors.purple,
};

final priorities = ["High", "Medium", "Low"];

Future<void> pickTaskImage() async {
final picker = ImagePicker();
final picked = await picker.pickImage(source: ImageSource.gallery);


if (picked != null) {
  final bytes = await picked.readAsBytes();
  setState(() => selectedImage = bytes);
}


}

void addTask() {
final text = taskController.text.trim();
if (text.isEmpty) return;


setState(() {
  tasks.add({
    "name": text,
    "done": false,
    "imageBytes": selectedImage,
    "category": selectedCategory,
    "priority": selectedPriority,
  });
  taskController.clear();
  selectedImage = null;
  selectedCategory = "General";
  selectedPriority = "Medium";
});


}

void toggleTask(int index) {
setState(() => tasks[index]["done"] = !tasks[index]["done"]);
}

void confirmDelete(int index) {
showDialog(
context: context,
builder: (_) => AlertDialog(
title: const Text("Delete Task"),
content: const Text("Are you sure you want to delete this task?"),
actions: [
TextButton(
child: const Text("Cancel"),
onPressed: () => Navigator.pop(context),
),
ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
child: const Text("Delete"),
onPressed: () {
setState(() => tasks.removeAt(index));
Navigator.pop(context);
},
),
],
),
);
}

void editTask(int index) {
final editController = TextEditingController(text: tasks[index]["name"]);
String newCategory = tasks[index]["category"];
String newPriority = tasks[index]["priority"];


showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text("Edit Task"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: editController),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: newCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: categoryColors.keys
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(Icons.label, color: categoryColors[c]),
                        const SizedBox(width: 8),
                        Text(c),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => newCategory = v!),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: newPriority,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: priorities
              .map((p) {
                Color color;
                switch (p) {
                  case "High":
                    color = Colors.redAccent;
                    break;
                  case "Medium":
                    color = Colors.orange;
                    break;
                  default:
                    color = Colors.green;
                }
                return DropdownMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Icon(Icons.priority_high, color: color),
                      const SizedBox(width: 8),
                      Text(p),
                    ],
                  ),
                );
              })
              .toList(),
          onChanged: (v) => setState(() => newPriority = v!),
        ),
      ],
    ),
    actions: [
      TextButton(
        child: const Text("Cancel"),
        onPressed: () => Navigator.pop(context),
      ),
      ElevatedButton(
        child: const Text("Save"),
        onPressed: () {
          setState(() {
            tasks[index]["name"] = editController.text;
            tasks[index]["category"] = newCategory;
            tasks[index]["priority"] = newPriority;
          });
          Navigator.pop(context);
        },
      ),
    ],
  ),
);


}

String getAiSuggestion() {
final total = tasks.length;
final completed = tasks.where((t) => t["done"]).length;
final incomplete = total - completed;
final withImages = tasks.where((t) => t["imageBytes"] != null).length;


if (total == 0) return "Start by adding your first task!";
if (incomplete >= 5) return "You have many pending tasks. Try finishing the easiest one!";
if (completed > incomplete) return "Great job! You're completing tasks quickly!";
if (withImages >= 3) return "Nice! You added many image-based tasks.";
if (incomplete == 1) return "Only one task left! You can do it!";
return "Keep going — you're doing great!";


}

@override
Widget build(BuildContext context) {
final filteredTasks = tasks
.where((t) => t["name"].toLowerCase().contains(searchController.text.toLowerCase()))
.toList();


return Scaffold(
  backgroundColor: const Color(0xFFF6E9C8),
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: const Text(
      "Smart To-Do",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.brown,
        fontSize: 26,
      ),
    ),
  ),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        // AI suggestion box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE6C6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  getAiSuggestion(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search tasks...",
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 20),
        if (selectedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              selectedImage!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 20),
        // Task input
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: taskController,
                  decoration: const InputDecoration(
                    hintText: "Enter a task...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.image, color: Colors.orange),
              onPressed: pickTaskImage,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: addTask,
              child: const Text("Add"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Cute dropdowns
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categoryColors.keys
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(Icons.label, color: categoryColors[c]),
                              const SizedBox(width: 8),
                              Text(c),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: priorities
                    .map((p) {
                      Color color;
                      switch (p) {
                        case "High":
                          color = Colors.redAccent;
                          break;
                        case "Medium":
                          color = Colors.orange;
                          break;
                        default:
                          color = Colors.green;
                      }
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Icon(Icons.priority_high, color: color),
                            const SizedBox(width: 8),
                            Text(p),
                          ],
                        ),
                      );
                    })
                    .toList(),
                onChanged: (v) => setState(() => selectedPriority = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Task list
        Expanded(
          child: filteredTasks.isEmpty
              ? const Center(
                  child: Text(
                    "No tasks found 📝",
                    style: TextStyle(color: Colors.brown, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final t = filteredTasks[index];
                    final realIndex = tasks.indexOf(t);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: t["imageBytes"] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  t["imageBytes"],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.task_alt,
                                color: Colors.orange,
                              ),
                        title: Text(
                          t["name"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown,
                            decoration: t["done"]
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColors[t["category"]]!
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                t["category"],
                                style: TextStyle(
                                  color: categoryColors[t["category"]],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Priority: ${t["priority"]}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                t["done"]
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: Colors.green,
                              ),
                              onPressed: () => toggleTask(realIndex),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () => editTask(realIndex),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => confirmDelete(realIndex),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  ),
);


}
}
