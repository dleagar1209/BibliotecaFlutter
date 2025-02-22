import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Opciones en una lista vertical
    final options = [
      {'label': 'My Account', 'icon': Icons.account_circle},
      {'label': 'Search Catalog', 'icon': Icons.search},
      {'label': 'Locations & Hours', 'icon': Icons.location_on},
      {'label': 'Digital Collections', 'icon': Icons.cloud},
      {'label': 'Events', 'icon': Icons.event},
      {'label': 'New Arrivals', 'icon': Icons.new_releases},
      {'label': 'How Do I?', 'icon': Icons.help_outline},
      {'label': 'Spotlight', 'icon': Icons.star},
    ];

    return Column(
      children: [
        // Imagen en el encabezado
        Image.network(
          'https://img.freepik.com/vector-gratis/interior-biblioteca-sala-vacia-leer-libros-estantes-madera_33099-1722.jpg',
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
        // Lista de opciones
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: Icon(options[index]['icon'] as IconData),
                  title: Text(options[index]['label'].toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Maneja la acción para cada opción
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
