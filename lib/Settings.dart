import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:untitled2/main.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final box = Hive.box("database");
  Widget tiles(dynamic trailing, String title, Color color, IconData icon, String additionalInfo){
    return CupertinoListTile(
      title: Text(title),
      additionalInfo: Text(additionalInfo),
      trailing: trailing,
      leading: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color
        ),
        child: Icon(icon, size: 17,),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: ListView(
      children: [
        CupertinoListSection.insetGrouped(
          children: [
            tiles(CupertinoSwitch(value: box.get("biometrics"), onChanged: (value){
              setState(() {
                box.put("biometrics", !box.get("biometrics"));
                print(box.get("biometrics"));
              });
            }),'Biometrics', CupertinoColors.systemGreen, Icons.fingerprint_rounded, ""),
            GestureDetector(
                onTap: (){
                  showCupertinoDialog(context: context, builder: (context){
                    return CupertinoAlertDialog(
                      title: Text("logout?"),
                      actions: [
                        CupertinoButton(child: Text('Yes'), onPressed: (){
                          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=> LoginPage()));
                        }),
                        CupertinoButton(child: Text('Close'), onPressed: (){
                          Navigator.pop(context);
                        })
                      ],
                    );
                  });
                },

                child: tiles(Icon(CupertinoIcons.chevron_forward), "Sign out", CupertinoColors.systemPurple, Icons.logout, box.get("username")))
          ],
        )
      ],
    ));
  }
}