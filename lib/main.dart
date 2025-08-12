import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'camaraLogica.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Incidencias',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MAPA'),
      themeMode: ThemeMode.system,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CamaraController camara = CamaraController();
  String? fotoTomada;

  LatLng? obtencionLocalizacion;
  String obtencionUbicacion = 'Cargando ubicación';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

// Obtiene la ubicacion actual para mostrarla 
  Future<void> obtenerUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        obtencionUbicacion = 'Los servicios de ubicación están desactivados';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          obtencionUbicacion = 'Los permisos de ubicación fueron denegados';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        obtencionUbicacion =
            'Los permisos de ubicación están permanentemente denegados';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        obtencionLocalizacion = LatLng(position.latitude, position.longitude);
      });
      await ubicacionConCoordenadas();
    } catch (e) {
      setState(() {
        obtencionUbicacion = 'Error al obtener la ubicación';
      });
    }
  }

// LLama a la funcion para obtener la ubicacion desde las coordenadas y obtener la ubicacion mas especifica
  Future<void> ubicacionConCoordenadas() async {
    if (obtencionLocalizacion != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          obtencionLocalizacion!.latitude,
          obtencionLocalizacion!.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            obtencionUbicacion =
                '${place.street ?? 'Calle sin nombre'} ${place.subThoroughfare ?? 'S/N'}, ${place.subLocality ?? 'Colonia'}, ${place.locality ?? 'Ciudad'}, ${place.administrativeArea ?? 'Estado'}';
          });
        }
      } catch (e) {
        setState(() {
          obtencionUbicacion = 'No se pudo obtener la dirección';
        });
      }
    }
  }

// Funcion para la navegacion entre las pantallas
  void navegacion(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        navegarMisIncidencias();
        break;
      case 2:
        navegarAjustes();
        break;
    }
  }

// Navega a la pantalla de las incidencias
  void navegarMisIncidencias() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de Mis Incidencias próximamente'),
      ),
    );
  }

// Navega a la pantalla de ajustes
  void navegarAjustes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de Ajustes próximamente')),
    );
  }

// Construye el mapa de donde se esta ubicado 
  Widget widgetMapa() {
    return obtencionLocalizacion == null
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: MapOptions(
              initialCenter: obtencionLocalizacion!,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mapa_proyecto',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: obtencionLocalizacion!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ],
          );
  }

// Construccion de la pantalla principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),

      body: widgetMapa(),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIncidenciaForm(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.crisis_alert, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: navegacion,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ubicación'),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Mis Incidencias',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  void _showIncidenciaForm(BuildContext context) {
    String? incidencia;
    final TextEditingController controlador = TextEditingController();

    showModalBottomSheet(

      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Textos del formulario 
                    const Text(
                      'Reportar Incidencia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tipo de incidencia:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Row para las opciones de las incidencias 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIncidenciaOption(
                          'Bache',
                          Icons.construction,
                          Colors.orange,
                          incidencia == 'Bache',
                          () => setModalState(() => incidencia = 'Bache'),
                        ),
                        _buildIncidenciaOption(
                          'Fuga de Agua',
                          Icons.water_drop,
                          Colors.blue,
                          incidencia == 'Fuga de Agua',
                          () =>
                              setModalState(() => incidencia = 'Fuga de Agua'),
                        ),
                        _buildIncidenciaOption(
                          'Obstrucción Vial',
                          Icons.block,
                          Colors.red,
                          incidencia == 'Obstrucción Vial',
                          () => setModalState(
                            () => incidencia = 'Obstrucción Vial',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Mostrar la ubicación actual
                    const Text(
                      'Ubicación Actual:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Contenedor para escribir la ubicacion
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              obtencionUbicacion,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: obtenerUbicacion,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Mapa de la ubicacion actual
                    SizedBox(
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widgetMapa(),
                      ),
                    ),

                    // Box para la descripcion del problema
                    const Text(
                      'Descripción del problema:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controlador,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe el problema que encontraste...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botones para tomar foto y seleccionar de galeria
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => tomarFoto(),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Tomar Foto'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => galeria(),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galería'),
                          ),
                        ),
                      ],
                    ),
                    if (fotoTomada != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(fotoTomada!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),

                    // Boton para el envio del reporte 
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: incidencia != null
                            ? () => enviarReporte(
                                  incidencia!,
                                  controlador.text,
                                  context,
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: incidencia != null
                              ? Colors.green
                              : Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Enviar Reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// Construccion de las opciones de las incidencias
// Son las opciones del row de la parte de arriba 
  Widget _buildIncidenciaOption(
    String titulo,
    IconData icono,
    Color color,
    bool estaSeleccionada,
    VoidCallback alTocar,
  ) {
    return GestureDetector(
      onTap: alTocar,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: estaSeleccionada ? color.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: estaSeleccionada ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 30,
              color: estaSeleccionada ? color : Colors.grey[600],
            ),
            const SizedBox(height: 5),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: estaSeleccionada ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Funcion para tomar fotos, aun no me queda esta parte
// Esta funcion es la que aun no me queda pero voy a checarla 
  Future<void> tomarFoto() async {
   /* String? path = await camara.tomarFoto();
    if (path != null) {
      setState(() {
        fotoTomada = path;
      });
    }*/
  }

// Lo mismo pero para la seleccion de imagenes 
  void galeria() async {
   /* String? path = await camara.seleccionarDesdeGaleria();
    if (path != null) {
      setState(() {
        fotoTomada = path;
      });
    }*/
  }

  void enviarReporte(
    String tipoIncidencia,
    String descripcion,
    BuildContext context,
  ) {
    // Aqui se implementaaria la logica para enviar el reporte a la base de datos
    // Tambien estan los parametros que se ocupan para el envio 
  }
}
