import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const SkyyApp());

class SkyyApp extends StatelessWidget {
  const SkyyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skyy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF5A1F),
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(55.75, 37.61);
  bool _isRiding = false;
  String _serverStatus = 'Подключение...';
  bool _serverOnline = false;

  final String apiUrl = 'https://skyy-server.onrender.com/api/scooter/KA547X/command';

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    try {
      final r = await http.get(Uri.parse('https://skyy-server.onrender.com/api/scooters'));
      if (r.statusCode == 200) {
        setState(() {
          _serverOnline = true;
          _serverStatus = 'Сервер онлайн';
        });
      }
    } catch (e) {
      setState(() {
        _serverOnline = false;
        _serverStatus = 'Сервер офлайн';
      });
    }
  }

  Future<void> sendCommand(String cmd) async {
    try {
      await http.post(Uri.parse(apiUrl), body: cmd);
      setState(() {
        _isRiding = (cmd == 'START');
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Команда $cmd отправлена!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка: сервер не отвечает')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skyy.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _center,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.electric_scooter, color: Color(0xFFFF5A1F), size: 50),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Skyy', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 8),
                        Text('Куда поедем?', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Самокат рядом', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF2D2D2D),
                        radius: 30,
                        child: Icon(Icons.electric_scooter, color: Color(0xFFFF5A1F), size: 30),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KA547X', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Ninebot Max', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text('Заряд: 100%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.white),
                        onPressed: () => sendCommand('CALL'),
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF3D3D3D), padding: const EdgeInsets.all(16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRiding ? null : () => sendCommand('START'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5A1F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(_isRiding ? 'В пути...' : 'Старт', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      _serverStatus,
                      style: TextStyle(color: _serverOnline ? Colors.green : Colors.red, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
