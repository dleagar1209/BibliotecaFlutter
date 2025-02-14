import 'package:flutter/material.dart';

void main() {
  runApp(BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biblioteca'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CatalogScreen()),
                  );
                },
                child: Text('Ver Catálogo'),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoanScreen()),
                  );
                },
                child: Text('Realizar Préstamo'),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReturnScreen()),
                  );
                },
                child: Text('Devolver Libro'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Libros'),
      ),
      body: Center(
        child: Text('Listado de libros aquí...'),
      ),
    );
  }
}

class LoanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizar Préstamo'),
      ),
      body: Center(
        child: Text('Formulario de préstamo aquí...'),
      ),
    );
  }
}

class ReturnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devolver Libro'),
      ),
      body: Center(
        child: Text('Formulario de devolución aquí...'),
      ),
    );
  }
}
