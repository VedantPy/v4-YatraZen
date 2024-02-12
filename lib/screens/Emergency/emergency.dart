import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v4/controllers/location_controller.dart';
import 'package:shake/shake.dart';

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  _EmergencyState createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  ShakeDetector? detector;
  bool isShakeDetected = false;

  @override
  void initState() {
    super.initState();
    detector = ShakeDetector.autoStart(onPhoneShake: () {
      print("Shake detected");
      Get.find<LocationController>().getCurrentLocation();
      setState(() {
        isShakeDetected = true;
      });
    });
  }

  @override
  void dispose() {
    detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
        init: LocationController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
                title: Text(
                  "Emergency",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                backgroundColor: const Color(0xff0E1219),
                iconTheme: const IconThemeData(color: Color(0xffffffff)),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
            body: Center(
              child: controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            controller.currentLocation == null
                                ? 'Location not found'
                                : controller.currentLocation!,
                            style: TextStyle(
                                fontSize: 23,
                                color: isShakeDetected
                                    ? Colors.red
                                    : Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          );
        });
  }
}
