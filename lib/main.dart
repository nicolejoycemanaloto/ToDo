import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled2/homepage.dart';
import 'Signup.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox('database');
  await box.clear();

  print(box.get("username"));

  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final box = Hive.box("database");
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        theme: CupertinoThemeData(
            primaryColor: CupertinoColors.label,
            brightness: Brightness.dark
        ),
        debugShowCheckedModeBanner: false,
        home: CupertinoPageScaffold(child: (box.get("username") != null) ? LoginPage() : SignupPage()));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String msg = "";
  bool hidePassword = true;
  final box = Hive.box("database");
  TextEditingController _username = TextEditingController();
  TextEditingController _password =  TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200),),
          SizedBox(height: 10,),
          CupertinoTextField(
            controller: _username,
            placeholder: "username",
            prefix: Icon(CupertinoIcons.person),
            padding: EdgeInsets.all(10),
          ),
          SizedBox(height: 3,),
          CupertinoTextField(
            controller: _password,
            placeholder: "password",
            prefix: Icon(CupertinoIcons.padlock),
            padding: EdgeInsets.all(10),
            obscureText: hidePassword,
            suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(hidePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash), onPressed: (){
              setState(() {
                hidePassword = !hidePassword;
              });
            }),
          ),

          Center(
            child: Column(
              children: [
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Sign In'), onPressed: (){
                  if (_username.text.trim() == box.get("username") && _password.text.trim() == box.get("password")){
                    setState(() {
                      msg = "";
                      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=> Homepage()));
                    });
                  }else{
                    setState(() {
                      msg = "Invalid username or password";
                    });
                  }
                }),
                (box.get("biometrics")) ? CupertinoButton(
                  child: const Icon(Icons.fingerprint_rounded),
                  onPressed: () async {
                    try {
                      final bool canAuthenticate =
                          await auth.canCheckBiometrics || await auth.isDeviceSupported();

                      if (!canAuthenticate) {
                        print('Biometrics not available');
                        return;
                      }

                      final bool didAuthenticate = await auth.authenticate(
                        localizedReason: 'Please authenticate to login your local account',
                        biometricOnly: true,
                      );

                      if (didAuthenticate) {
                        setState(() {
                          _username.text = box.get("username");
                          _password.text = box.get("password");
                        });
                      } else {
                        setState(() {
                          msg = "Authentication Failed";
                        });
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                ) : Text(""),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Reset Data'), onPressed: (){
                  showCupertinoDialog(context: context, builder: (context){
                    return CupertinoAlertDialog(
                      title: Text("Are you sure to delete all registered local data?"),
                      actions: [
                        CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text('Yes'), onPressed: () async {
                          Navigator.pop(context);

                          // Only authenticate if biometrics is enabled
                          if (box.get("biometrics") == true) {
                            try {
                              final bool canAuthenticate =
                                  await auth.canCheckBiometrics || await auth.isDeviceSupported();

                              if (!canAuthenticate) {
                                print('Biometrics not available');
                                return;
                              }

                              final bool didAuthenticate = await auth.authenticate(
                                localizedReason: 'Please authenticate to reset data',
                                biometricOnly: true,
                              );

                              if (didAuthenticate) {
                                box.delete("username");
                                box.delete("password");
                                box.delete("biometrics");
                                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=> SignupPage()));
                              } else {
                                setState(() {
                                  msg = "Authentication Failed";
                                });
                              }
                            } catch (e) {
                              setState(() {
                                msg = e.toString();
                              });
                            }
                          } else {
                            // No biometrics enabled, proceed directly
                            box.delete("username");
                            box.delete("password");
                            box.delete("biometrics");
                            Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=> SignupPage()));
                          }
                        }),
                        CupertinoButton(
                            child: Text('Close'), onPressed: (){
                          Navigator.pop(context);
                        })
                      ],
                    );
                  });
                }),

                Text(msg, style: TextStyle(color: CupertinoColors.destructiveRed),)
              ],
            ),
          )

        ],
      ),
    ));
  }
}