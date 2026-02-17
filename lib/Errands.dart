import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Errands extends StatefulWidget {
  const Errands({super.key});

  @override
  State<Errands> createState() => _ErrandsState();
}

class _ErrandsState extends State<Errands> {
  final box = Hive.box("database");
  List<dynamic> todo = [];
  TextEditingController _task = TextEditingController();

  @override
  void initState() {
    setState(() {
      todo = box.get("todo", defaultValue: []);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: Stack(
      children: [
        (todo.isEmpty) ? ListView(
          children: [
            Center(child: Text("No Errands Today", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30),))
          ],
        ): ListView.builder(
            itemCount: todo.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onLongPress: (){
                  showCupertinoDialog(context: context, builder: (context){
                    return CupertinoActionSheet(
                      message: Text("Delete \"${todo[i]["task"]}\" ?"),
                      actions: [
                        CupertinoButton(child: Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed),), onPressed: (){
                          setState(() {
                            todo.removeAt(i);
                            box.put("todo", todo);
                          });
                          Navigator.pop(context);
                        }),
                        CupertinoButton(child: Text("Cancel",), onPressed: (){
                          Navigator.pop(context);
                        })
                      ],
                    );
                  });
                },
                onTap: (){
                  setState(() {
                    todo[i]["isDone"] = !todo[i]["isDone"];
                    box.put("todo", todo);
                  });
                  print(todo[i]["isDone"]);
                },
                child: CupertinoListTile(
                    leading: Icon((todo[i]["isDone"] ? CupertinoIcons.check_mark_circled : CupertinoIcons.circle), size: 19,),
                    title: Text(todo[i]["task"], style: TextStyle(decoration: (todo[i]["isDone"] ? TextDecoration.lineThrough : TextDecoration.none)),)
                ),
              );
            }
        ),
        Positioned(
          bottom:  60,
          right: 0,
          child: CupertinoButton(child: Icon(CupertinoIcons.plus), onPressed: (){
              showCupertinoDialog(context: context, builder: (context){
                return CupertinoActionSheet(
                  title: Text("Add ToDo"),
                  message: CupertinoTextField(
                    controller: _task,
                  ),
                  actions: [
                    CupertinoButton(child: Text("Save"), onPressed: (){
                     if (_task.text != "") {
                       setState(() {
                         todo.add({
                           "task" : _task.text,
                           "isDone" : false
                         });
                         box.put("todo", todo);
                       });
                       _task.text = "";
                       Navigator.pop(context);
                     }
                    }),
                    CupertinoButton(child: Text("Cancel", style: TextStyle(color: CupertinoColors.destructiveRed)), onPressed: (){
                      _task.text = "";
                      Navigator.pop(context);
                    })
                  ],
                );
              });
          }),
        )
      ],
    ));
  }
}
