import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Map<String, dynamic> book;

  @override
  void initState() {
    super.initState();
    // Se copia el libro recibido para poder actualizarlo localmente
    book = widget.book;
  }

  Future<void> prestamoLibro() async {
    // Verifica si el libro ya no está disponible
    if (book['estado'] != 'disponible') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El libro ya está prestado')),
      );
      return;
    }

    try {
      // Actualiza la disponibilidad en la colección 'libros'
      await FirebaseFirestore.instance
          .collection('libros')
          .doc(book['id'])
          .update({'estado': 'no disponible'});

      // Inserta un nuevo documento en la colección 'prestamos'
      await FirebaseFirestore.instance.collection('prestamos').add({
        'estado': 'en préstamo',
        'fechaPrestamo': DateTime.now(), // Fecha y hora actual
        'lectorId': '12345', // Identificador del lector (valor fijo para este ejemplo)
        'libroId': book['id'], // ID del libro
      });

      // Actualiza el estado local para reflejar el cambio en la UI
      setState(() {
        book['estado'] = 'no disponible';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro prestado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al prestar el libro: $e')),
      );
    }
  }

  Future<void> devolverLibro() async {
    // Verifica si el libro ya está disponible
    if (book['estado'] == 'disponible') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El libro ya está disponible')),
      );
      return;
    }
    try {
      // Actualiza la disponibilidad en la colección 'libros'
      await FirebaseFirestore.instance
          .collection('libros')
          .doc(book['id'])
          .update({'estado': 'disponible'});

      // Busca y elimina el documento correspondiente en la colección 'prestamos'
      QuerySnapshot prestamosSnapshot = await FirebaseFirestore.instance
          .collection('prestamos')
          .where('libroId', isEqualTo: book['id'])
          .get();

      for (var doc in prestamosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Actualiza el estado local para reflejar el cambio en la UI
      setState(() {
        book['estado'] = 'disponible';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro devuelto exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al devolver el libro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['titulo'] ?? 'Detalles del libro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                book['portada'] ?? '',
                width: 200,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Título: ${book['titulo'] ?? 'Desconocido'}',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Autor: ${book['autor'] ?? 'Desconocido'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Materia: ${book['materia'] ?? 'No especificado'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Disponibilidad: ${book['estado'] ?? 'No disponible'}',
              style: TextStyle(
                fontSize: 18,
                color: book['estado'] == 'disponible'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: prestamoLibro,
                      child: const Text('Préstamo'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: devolverLibro,
                      child: const Text('Devolver'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
