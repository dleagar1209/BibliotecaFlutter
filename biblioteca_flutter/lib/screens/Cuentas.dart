import 'package:flutter/material.dart';
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> libraryCards = []; // Lista de tarjetas de ejemplo

    return Column(
      children: [
        // Imagen en el encabezado
        Image.network(
          'https://img.freepik.com/vector-gratis/interior-biblioteca-sala-vacia-leer-libros-estantes-madera_33099-1722.jpg', // Cambia la ruta a tu imagen
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
        // Contenido principal
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: libraryCards.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No hay tarjetas registradas',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para agregar una tarjeta de biblioteca
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add a library card'),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: libraryCards.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Tarjeta #${index + 1}'),
                        subtitle: Text(libraryCards[index]),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

