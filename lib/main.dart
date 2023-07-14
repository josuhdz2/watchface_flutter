import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wear/wear.dart';
import 'package:pedometer/pedometer.dart';
//import 'package:battery/battery_info.dart';
//import 'package:battery_info/battery_info_plugin.dart';
//import 'package:battery_info/model/android_battery_info.dart';
//import 'package:battery_info/enums/charging_status.dart';
//import 'package:battery_info/model/iso_battery_info.dart';
//import 'package:battery_plus/battery_plus.dart';

void main()
{
  runApp(const MyApp());
}
class MyApp extends StatelessWidget
{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp
    (
      debugShowCheckedModeBanner: false,
      title: 'Watch Face',
      theme: ThemeData
      (
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget
{
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return WatchShape
    (
      builder: (context, shape, child)
      {
        return AmbientMode
        (
          builder: (context, mode, child)
          {
            return TimerScreen(mode);
          }
        );
      }
    );
  }
}

class TimerScreen extends StatefulWidget
{
  final WearMode mode;

  const TimerScreen(this.mode, {super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
{
  late Stream<StepCount> _stepCountStream;//pasos
  late Stream<PedestrianStatus> _pedestrianStatusStream;//pasos
  String _status = '?', _steps = '?';//pasos
  late DateTime tiempoActual;
  @override
  void initState()
  {
    super.initState();
    initPlatformState();//pasos
    actualizarHora();
  }
  void onStepCount(StepCount event)//pasos
  {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }
  void onPedestrianStatusChanged(PedestrianStatus event)//pasos
  {
    print(event);
    setState(() {
      _status = event.status;
    });
  }
  void onPedestrianStatusError(error)//pasos
  {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }
  void onStepCountError(error)//pasos
  {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }
  void initPlatformState()
  {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }
  void actualizarHora()
  {
    setState(()
    {
      tiempoActual=DateTime.now().toUtc().subtract(const Duration(hours: 6));
    });
    Timer(const Duration(seconds: 1)-Duration(milliseconds: tiempoActual.microsecond), actualizarHora);
  }
  @override
  Widget build(BuildContext context)
  {
    final formatoHora=DateFormat('hh:mm:ss a');
    final fechaString=DateFormat('MMM dd, yyyy').format(tiempoActual);
    final horaString=formatoHora.format(tiempoActual);
    return Scaffold
    (
      backgroundColor:widget.mode==WearMode.active?Colors.yellow[800]:Colors.black,
      body:Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        [
          Row
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  widget.mode==WearMode.active?Text
                  (
                    fechaString.substring(0,6),
                    style: const TextStyle
                    (
                      color:Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),
                  ):const SizedBox(),
                  Text
                  (
                    horaString.substring(0,2),
                    style: TextStyle
                    (
                      color:widget.mode==WearMode.active?Colors.black:Colors.yellow[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 50
                    ),
                  )
                ],
              ),
              Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  widget.mode==WearMode.active?const SizedBox(height: 20):const SizedBox(),
                  Text
                  (
                    ':',
                    style: TextStyle
                    (
                      color:widget.mode==WearMode.active?Colors.black:Colors.yellow[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 50
                    )
                  ),
                ],
              ),
              Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  widget.mode==WearMode.active?Text
                  (
                    fechaString.substring(8,12),
                    style: const TextStyle
                    (
                      color:Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),
                  ):const SizedBox(),
                  Text
                  (
                    horaString.substring(3,5),
                    style: TextStyle
                    (
                      color:widget.mode==WearMode.active?Colors.black:Colors.yellow[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 50
                    )
                  ),
                ],
              )
            ]
          ),
          widget.mode==WearMode.active?SizedBox
          (
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children:
              [
                const Icon
                (
                  Icons.directions_walk,
                  color: Colors.black,
                  size: 20,
                ),
                Text
                (
                  "$_steps Pasos",
                  style:const TextStyle
                  (
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )
          ):const SizedBox()
        ]
      )
    );
  }
}