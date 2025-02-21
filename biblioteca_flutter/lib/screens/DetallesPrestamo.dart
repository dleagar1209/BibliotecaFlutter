import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DetallesPrestamoScreen extends StatelessWidget {
  const DetallesPrestamoScreen({Key? key}) : super(key: key);

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

  // Método para generar y guardar el PDF
  Future<void> generarPDF(BuildContext context) async {
    // Obtener los libros prestados
    List<Map<String, dynamic>> libros = await obtenerLibrosPrestados();

    if (libros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay préstamos activos para descargar')),
      );
      return;
    }

    // Crear el documento PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Detalles de Préstamos',
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            ...libros.map((libro) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('📖 Título: ${libro['titulo'] ?? 'Desconocido'}',
                          style: const pw.TextStyle(fontSize: 18)),
                      pw.Text('✍ Autor: ${libro['autor'] ?? 'Desconocido'}',
                          style: const pw.TextStyle(fontSize: 16)),
                      pw.Text('📅 Fecha de préstamo: ${libro['fechaPrestamo']}',
                          style: const pw.TextStyle(fontSize: 16)),
                      pw.Divider(),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );

    // Guardar el PDF en el directorio de documentos de la aplicación
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Préstamos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Título: ${libro['titulo'] ?? 'Desconocido'}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
