import 'package:flutter/material.dart';

class BookDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
