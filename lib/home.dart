import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_list/list_item.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late String newTodo = "";
  Set<ListItem> items = Set<ListItem>();
  final TextEditingController editingController = TextEditingController();
  ListItem? selectedItem;
  final int listLength = 30;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final int remainingTodoNotificationId = 0;

  Future<void> showToDoNotification(Set<ListItem> items) async {
    final Set<ListItem> pendingList = items.where((element) => !element.checked).toSet(); 

    if (pendingList.isNotEmpty) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id', // Change this to your own channel ID
        'ToDo List Notifications',
        'Get notified about pending to-do items',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      final StringBuffer messageBuffer = StringBuffer();
      for (final item in pendingList){
        messageBuffer.write("${item.item}\n");
      }

      await flutterLocalNotificationsPlugin.show(
        remainingTodoNotificationId, // Unique ID for the notification
        'Pending To-Do Items',
        'You have a pending to-do items:\n ${messageBuffer.toString()}',
        notificationDetails,
      );
    }
}

  var buttonStyle = ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 8, 115, 202)),
                      fixedSize: MaterialStateProperty.all(const Size(100, 40)),
                      shape: MaterialStateProperty.all(const LinearBorder())
                    );

  void _addNewTodo(String value){
    if(value.isNotEmpty){
      setState(() {
        items.add(ListItem(value, false));
        items.remove(selectedItem);
        editingController.clear();
        showToDoNotification(items);
        newTodo = "";
      });
    }
  }

  void _deleteTodo(){
    setState(() {
      items.remove(selectedItem);
    });
    if(items.isEmpty){
      clearTodoNotification();
    }
  }

  void _clearTodo(){
    editingController.clear();
  }

  void clearTodoNotification(){
    flutterLocalNotificationsPlugin.cancel(remainingTodoNotificationId);
  }

  void toggleCheckbox(ListItem item, bool value){
    setState(() {
      item.checked = value;
    });
    if(items.any((element) => !element.checked)){
      showToDoNotification(items);
    } else {
      clearTodoNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: editingController,
                onChanged: (value) {
                  if(value.isNotEmpty){
                    setState(() {
                      newTodo = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter new TODO item',
                ),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Row(
                children: [
                  TextButton(
                    style: buttonStyle,
                    child: const Text("Add"),
                    onPressed: () => _addNewTodo(newTodo),
                  ),
                  const Spacer(),
                  TextButton(
                    style: buttonStyle,
                    child: const Text("Delete"),
                    onPressed: () => _deleteTodo(),
                  ),
                  const Spacer(),
                  TextButton(
                    style: buttonStyle,
                    child: const Text("Clear"),
                    onPressed: () => _clearTodo(),
                  ),
                  const Spacer(flex: 100,),
                ],
              ),
              SizedBox(
                height: 450,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final todoItem = items.elementAt(index);
                    final isChecked = todoItem.checked;
                    final isSelected = todoItem == selectedItem;
                    return ListTile(
                      onTap: () {
                        if(selectedItem != todoItem){
                          setState(() {
                            selectedItem = todoItem;
                          });
                        } else {
                          setState(() {
                            selectedItem = null;
                          });
                        }
                      },
                      title: Text(todoItem.item),
                      tileColor: isSelected ? const Color.fromARGB(255, 137, 189, 231) : null,
                      trailing: Checkbox(
                        onChanged: (value) {
                          toggleCheckbox(todoItem, value!);
                        },
                        value: isChecked,
                        ),
                    );
                  },
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
