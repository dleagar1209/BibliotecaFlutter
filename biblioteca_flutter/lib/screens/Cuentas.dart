import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DetallesLibro.dart'; // Pantalla de detalles del libro
import 'DetallesPrestamo.dart'; // Asegúrate de crear e importar la pantalla de detalles de préstamo

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se utiliza un Scaffold para tener una pantalla completa
      body: Column(
        children: [
          // Encabezado con imagen
          Image.network(
            'https://img.freepik.com/vector-gratis/interior-biblioteca-sala-vacia-leer-libros-estantes-madera_33099-1722.jpg',
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
          // Lista de libros prestados (filtrando la colección "libros")
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('libros')
                    .where('estado', isEqualTo: 'no disponible')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error al cargar los libros prestados"),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final libros = snapshot.data!.docs;
                  if (libros.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay libros prestados',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: libros.length,
                    itemBuilder: (context, index) {
                      final data = libros[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          // Navega a la pantalla de detalles del libro, pasando sus datos
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsScreen(book: data),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Image.network(
                                    data['portada'] ?? '',
                                    width: 150,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported, size: 100),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Título: ${data['titulo'] ?? 'Desconocido'}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Autor: ${data['autor'] ?? 'Desconocido'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Materia: ${data['materia'] ?? 'No especificado'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Botón en la parte inferior para navegar a la pantalla de detalles de préstamos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetallesPrestamoScreen()),
                );
              },
              child: const Text('Ver detalles de préstamos'),
            ),
          ),
        ],
      ),
    );
  }
}
