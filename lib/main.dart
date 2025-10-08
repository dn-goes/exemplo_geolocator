import 'package:exemplo_geolocator/clima_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LocationScreen(),
  ));
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Estado da tela
  String mensagem = "Toque em um botão para começar";
  bool carregando = false;

  /// 🧭 Obtém a localização atual do dispositivo
  Future<void> getLocation() async {
    setState(() => carregando = true);
    try {
      // Verifica se o serviço está habilitado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => mensagem = "Serviço de localização desabilitado");
        return;
      }

      // Verifica e solicita permissão
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => mensagem = "Permissão de localização negada");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => mensagem = "Permissão de GPS permanentemente negada");
        return;
      }

      // Obtém posição
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        mensagem =
            "Latitude: ${position.latitude.toStringAsFixed(4)}\nLongitude: ${position.longitude.toStringAsFixed(4)}";
      });
    } catch (e) {
      setState(() => mensagem = "Erro ao obter localização: $e");
    } finally {
      setState(() => carregando = false);
    }
  }

  /// 🌦️ Busca cidade e clima atual
  Future<void> getCityWeather() async {
    setState(() => carregando = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => mensagem = "Serviço de GPS não habilitado");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => mensagem = "Permissão de GPS negada");
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();

      // Chama o serviço de clima
      final cidade = await ClimaService.getCityWeatherByPosition(position);
      final temperatura = (cidade["main"]["temp"] - 273.15).toStringAsFixed(1);

      setState(() {
        mensagem = "📍 ${cidade["name"]}\n🌡️ Temperatura: $temperatura°C";
      });
    } catch (e) {
      setState(() => mensagem = "Erro ao obter clima: $e");
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Localização & Clima"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (carregando)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Text(
                    mensagem,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: getLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.my_location),
                  label: const Text("Obter Localização"),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: getCityWeather,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.cloud),
                  label: const Text("Obter Clima"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
