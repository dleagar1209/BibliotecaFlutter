import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para cargar la imagen desde assets
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart'; // Importa el paquete para abrir archivos
import 'dart:io';

class DetallesPrestamoScreen extends StatelessWidget {
  const DetallesPrestamoScreen({super.key});

  // Método para obtener los libros prestados desde Firestore
  Future<List<Map<String, dynamic>>> obtenerLibrosPrestados() async {
    // Obtener los préstamos desde la colección 'prestamos'
    QuerySnapshot prestamosSnapshot =
        await FirebaseFirestore.instance.collection('prestamos').get();

    if (prestamosSnapshot.docs.isEmpty) {
      return [];
    }

    List<String> librosPrestadosIds = [];
    Map<String, String> fechasPrestamo = {};

    // Recorrer los documentos de préstamos y extraer los IDs de libros y fechas
    for (var doc in prestamosSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String libroId = data['libroId'];
      if (libroId.isNotEmpty) {
        librosPrestadosIds.add(libroId);
        if (data['fechaPrestamo'] is Timestamp) {
          fechasPrestamo[libroId] =
              (data['fechaPrestamo'] as Timestamp).toDate().toString();
        } else {
          fechasPrestamo[libroId] = 'Fecha desconocida';
        }
      }
    }

    // Obtener los detalles de los libros usando los IDs
    QuerySnapshot librosSnapshot = await FirebaseFirestore.instance
        .collection('libros')
        .where(FieldPath.documentId, whereIn: librosPrestadosIds)
        .get();

    List<Map<String, dynamic>> librosConPrestamo = [];

    // Combinar los datos de los libros con las fechas de préstamo
    for (var doc in librosSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      data['fechaPrestamo'] = fechasPrestamo[doc.id] ?? 'Fecha desconocida';
      librosConPrestamo.add(data);
    }

    return librosConPrestamo;
  }

  // Método para generar, guardar y abrir el PDF, que incluye una gráfica de barras y el logo en la parte superior derecha
  Future<void> generarPDF(BuildContext context) async {
    // Cargar la imagen del logo desde assets
    final logoBytes = (await rootBundle.load('Assets/Images/logoBiblioteca.jpg'))
        .buffer
        .asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    // Obtener los libros prestados
    List<Map<String, dynamic>> libros = await obtenerLibrosPrestados();

    if (libros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay préstamos activos para descargar')),
      );
      return;
    }

    // Preparar datos para la gráfica: contar los préstamos por título de libro
    final Map<String, int> chartData = {};
    for (var libro in libros) {
      final title = libro['titulo'] ?? 'Desconocido';
      chartData[title] = (chartData[title] ?? 0) + 1;
    }
    final maxValue = chartData.values.isEmpty
        ? 1
        : chartData.values.reduce((a, b) => a > b ? a : b);

    // Crear el documento PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado con el título y el logo a la derecha
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Detalles de Préstamos',
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.Image(logoImage, width: 80, height: 80),
                ],
              ),
              pw.SizedBox(height: 20),
              // Lista de préstamos
              ...libros.map((libro) => pw.Padding(
                    padding:
                        const pw.EdgeInsets.symmetric(vertical: 8.0),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            '\uD83D\uDCD6 Título: ${libro['titulo'] ?? 'Desconocido'}',
                            style: const pw.TextStyle(fontSize: 18)),
                        pw.Text(
                            '\u270D Autor: ${libro['autor'] ?? 'Desconocido'}',
                            style: const pw.TextStyle(fontSize: 16)),
                        pw.Text(
                            '\uD83D\uDCC5 Fecha de préstamo: ${libro['fechaPrestamo']}',
                            style: const pw.TextStyle(fontSize: 16)),
                        pw.Divider(),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 30),
              // Sección de la gráfica
              pw.Text('Gráfica de Préstamos por Libro',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 200,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: chartData.entries.map((entry) {
                    // Escalar la altura de la barra según el valor máximo
                    final barHeight = (entry.value / maxValue) * 150;
                    return pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment:
                            pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            height: barHeight,
                            width: 20,
                            color: const PdfColor.fromInt(0xFF2196F3),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(entry.key,
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center),
                          pw.Text('${entry.value}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Guardar el PDF en el directorio de descargas de la aplicación
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      print("No se pudo acceder a la carpeta de descargas.");
      return;
    }
    final filePath = '${directory.path}/Prestamos_Libros.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF guardado en: $filePath')),
    );

    // Abrir el PDF automáticamente
    OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Préstamos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_sharp),
            onPressed: () => generarPDF(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerLibrosPrestados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los préstamos'));
          }
          final libros = snapshot.data ?? [];
          if (libros.isEmpty) {
            return const Center(child: Text('No hay préstamos activos'));
          }
          return ListView.builder(
            itemCount: libros.length,
            itemBuilder: (context, index) {
              final libro = libros[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Título: ${libro['titulo'] ?? 'Desconocido'}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Autor: ${libro['autor'] ?? 'Desconocido'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Fecha de préstamo: ${libro['fechaPrestamo']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
