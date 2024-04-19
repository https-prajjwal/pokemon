import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prajj Pokemon GO!',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial route
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the MainScreen after a delay
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpg',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Pokemon TCG!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prajj Pokemon Cards'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Cards'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PokemonList(drawer: Drawer())),
                );
              },
            ),
          ],
        ),
      ),
      body: CardPage(),
    );
  }
}

class PokemonList extends StatelessWidget {
  final Widget drawer;

  PokemonList({required this.drawer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon List'),
      ),
      drawer: drawer,
      body: FutureBuilder(
        future: fetchPokemonData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> pokemonData = snapshot.data!;
            return Material(
              child: ListView.builder(
                itemCount: (pokemonData.length / 2).ceil(),
                itemBuilder: (BuildContext context, int index) {
                  final int firstIndex = index * 2;
                  final int secondIndex = firstIndex + 1;
                  return Row(
                    children: [
                      Expanded(
                        child: _buildPokemonTile(context, pokemonData, firstIndex),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: secondIndex < pokemonData.length
                            ? _buildPokemonTile(context, pokemonData, secondIndex)
                            : Container(),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<dynamic>> fetchPokemonData() async {
    final Uri url = Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:gardevoir');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  Widget _buildPokemonTile(BuildContext context, List<dynamic> pokemonData, int index) {
    final pokemon = pokemonData[index];
    final marketPrice = pokemon['tcgplayer']?['prices']?['holofoil']?['market'] ?? 0.0;
    return GestureDetector(
      onTap: () {
        _showPokemonDetailsDialog(context, pokemon);
      },
      child: Container(
        height: 180,
        child: Card(
          color: Colors.grey[200],
          elevation: 2,
          child: Center(
            child: ListTile(
              leading: Image.network(pokemon['images']['small']),
              title: Text(pokemon['name']),
              subtitle: Text('Market Price: \$${marketPrice.toStringAsFixed(2)}'),
            ),
          ),
        ),
      ),
    );
  }

  void _showPokemonDetailsDialog(BuildContext context, dynamic pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(pokemon['images']['large']),
              SizedBox(height: 16),
              Text(
                pokemon['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Market Price: \$${pokemon['tcgplayer']['prices']['holofoil']['market'].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
              child: Text('Buy Now'),
            ),
          ],
        );
      },
    );
  }
}

class PaymentPage extends StatelessWidget {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/card.jpg',
            ),
            SizedBox(height: 16),
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            TextField(
              controller: _cvvController,
              decoration: InputDecoration(labelText: 'CVV'),
            ),
            TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(labelText: 'Expiry Date'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitPaymentDetails(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPaymentDetails(BuildContext context) {
    // Simulate payment processing
    // You can add your payment processing logic here
    // For demonstration, let's assume payment is successful
    _showPaymentConfirmation(context);
  }

  void _showPaymentConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Payment Done'),
          content: Text('Your payment was successful.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Navigate back two pages
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expiryDateController.dispose();
  }
}

class CardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Pokemon TCG!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
