import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'dart:typed_data';

class GestureControlScreen extends StatefulWidget {
  const GestureControlScreen({super.key});

  @override
  _GestureControlScreenState createState() => _GestureControlScreenState();
}

class _GestureControlScreenState extends State<GestureControlScreen> with WidgetsBindingObserver {
  late IO.Socket socket;
  bool isCameraOn = false;
  String gestureAction = "Waiting for gesture...";
  Uint8List? cameraFrame;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io("http://192.168.83.185:5000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.onConnect((_) {
      setState(() => isConnected = true);
      print("✅ Connected to Socket.IO");
    });

    socket.onDisconnect((_) {
      setState(() => isConnected = false);
      print("❌ Disconnected from Socket.IO");
    });

    socket.onConnectError((data) => print("⚠️ Connection Error: $data"));
    socket.onError((data) => print("❗ Socket Error: $data"));

    socket.on("frame", (data) {
      setState(() => cameraFrame = base64Decode(data["frame"]));
    });

    socket.on("action", (data) {
      setState(() => gestureAction = data["action"]);
    });

    socket.on("camera_stopped", (data) {
      setState(() {
        isCameraOn = false;
      });
      print("📴 Camera has been stopped by the server.");
    });

    socket.connect();
  }

  void toggleCamera(bool start) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Not connected to server"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    socket.emit(start ? "start_camera" : "stop_camera");
    setState(() => isCameraOn = start);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(start ? "🎥 Camera Started" : "📴 Camera Stopped"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      socket.emit("stop_camera");  // Stop the camera only when the app is fully closed
      socket.disconnect();
      print("📴 App is closing. Camera stopped.");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gesture Control"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            isConnected ? "🟢 Connected" : "🔴 Disconnected",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Gesture Detected: $gestureAction",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Display Camera Feed
          isCameraOn
              ? cameraFrame != null
                  ? Image.memory(cameraFrame!, height: 300, fit: BoxFit.cover)
                  : const CircularProgressIndicator()
              : Container(
                  height: 300,
                  color: Colors.black12,
                  child: const Center(child: Text("Camera Off")),
                ),

          const SizedBox(height: 10),

          // Start/Stop Camera Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => toggleCamera(true),
                icon: const Icon(Icons.videocam, color: Colors.white),
                label: const Text("Start Camera"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton.icon(
                onPressed: () => toggleCamera(false),
                icon: const Icon(Icons.videocam_off, color: Colors.white),
                label: const Text("Stop Camera"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
