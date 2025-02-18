import 'package:flutter/material.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Datos de ejemplo
  final List<Map<String, String>> _allBooks = [
    {'title': 'Dune: The Duke of Caladan', 'author': 'Herbert Brian'},
    {'title': 'Dune: The Machine Crusade', 'author': 'Herbert Brian'},
    {'title': 'Dune: The Battle of Corrin', 'author': 'Herbert Brian'},
    {'title': 'Dune: The Butlerian Jihad', 'author': 'Herbert Brian'},
  ];

  List<Map<String, String>> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _filteredBooks = _allBooks;
  }

  void _searchBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _allBooks;
      } else {
        _filteredBooks = _allBooks
            .where((book) =>
                book['title']!.toLowerCase().contains(query.toLowerCase()) ||
                book['author']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Imagen en el encabezado
        Image.network(
          'https://img.freepik.com/vector-gratis/interior-biblioteca-sala-vacia-leer-libros-estantes-madera_33099-1722.jpg', // Cambia la ruta a tu imagen
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
        // Contenido principal (campo de búsqueda + lista)
        Expanded(
          child: Column(
            children: [
              // Campo de texto para búsqueda
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar en el catálogo',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _searchBooks,
                ),
              ),
              // Lista de resultados
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = _filteredBooks[index];
                    return ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(book['title'] ?? ''),
                      subtitle: Text(book['author'] ?? ''),
                      onTap: () {
                        // Acción al tocar un libro
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

