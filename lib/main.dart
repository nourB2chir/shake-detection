import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shake/shake.dart';
import 'package:sms_maintained/sms.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iot',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {

  ShakeDetector detector;
  String receiverPhoneNumber = "********" ;
  final myController = TextEditingController();
  String userAcceleromerX = '0.0';
  String userAcceleromerY = '0.0';
  String userAcceleromerZ = '0.0';
  bool stop =false;

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alerte", textAlign: TextAlign.center),
            content: Text("your phone is shaked !!! \nan SMS is send to $receiverPhoneNumber"),
          );
        });
  }

  Future<void> _showConfigurationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("change the receiver number", textAlign: TextAlign.center),
            content: TextField(
                  controller: myController,
                  decoration: new InputDecoration(
                      labelText: "Enter receiver number",
                      icon: Icon(Icons.phone_iphone)
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
          );
        });
  }

  void _sendSMS2(String msg, String number){
    SmsSender sender = new SmsSender();
    String address = number;
    sender.sendSms(new SmsMessage(address, msg));
  }

  @override
  Future<void> initState(){
    super.initState();

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        if (!stop) {
          userAcceleromerX = event.x.toStringAsFixed(5);
          userAcceleromerX = event.y.toStringAsFixed(5);
          userAcceleromerX = event.z.toStringAsFixed(5);
        }
      });
    });

    detector = ShakeDetector.autoStart(onPhoneShake: (){
      try{
        _sendSMS2("phone is shaked", receiverPhoneNumber);
        _showDialog(context);
      }catch(e){
        print(e);
      }
      print("shaked");
    });
    // To close: detector.stopListening();
    // ShakeDetector.waitForStart() waits for user to call detector.startListening();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text('Nour Bechir Zaghouani'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 175, 0, 0),
          child: Column(
            children: <Widget>[
              Text(
                'Receiver Phone Number : ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20,),
              Text(
                  receiverPhoneNumber,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
              ),
              SizedBox(height: 150,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('X $userAcceleromerX'),
                    SizedBox(width: 20,),
                    Text('Y $userAcceleromerY'),
                    SizedBox(width: 20,),
                    Text('Z $userAcceleromerZ'),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child : Icon(Icons.stop_circle_outlined, color: Colors.red,),
            onPressed:() {
              detector.stopListening();
              setState(() {
                stop = true;
              });
            }),
          SizedBox(height: 5,),
          FloatingActionButton(
            child : Icon(Icons.settings),
            onPressed:() async {
              await _showConfigurationDialog(context);
              setState(() {
                receiverPhoneNumber = myController.text;
              });
            } ,
          )
        ],
      ),
    );
  }
}