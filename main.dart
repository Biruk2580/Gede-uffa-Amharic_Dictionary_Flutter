import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gede\'uffa-Amharic Dictionary',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: DictionaryScreen(toggleTheme: _toggleTheme),
    );
  }
}

class DictionaryEntry {
  final String word;
  final String definition;
  final String type;
  final String example;

  DictionaryEntry({
    required this.word,
    required this.definition,
    required this.type,
    required this.example,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      word: json['word'],
      definition: json['definition'],
      type: json['type'],
      example: json['example'],
    );
  }
}

Future<List<DictionaryEntry>> loadDictionary() async {
  final String response = await rootBundle.loadString('assets/words.json');
  final List<dynamic> data = json.decode(response);
  return data.map((entry) => DictionaryEntry.fromJson(entry)).toList();
}

class DictionaryScreen extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;

  const DictionaryScreen({super.key, required this.toggleTheme});

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late Future<List<DictionaryEntry>> futureEntries;
  List<DictionaryEntry> allEntries = [];
  List<DictionaryEntry> filteredEntries = [];

  @override
  void initState() {
    super.initState();
    futureEntries = loadDictionary();
    futureEntries.then((entries) {
      setState(() {
        allEntries = entries;
        filteredEntries = entries;
      });
    });
  }

  void _filterEntries(String query) {
    setState(() {
      filteredEntries = allEntries.where((entry) {
        final wordMatches =
            entry.word.toLowerCase().contains(query.toLowerCase());
        final definitionMatches =
            entry.definition.toLowerCase().contains(query.toLowerCase());
        return wordMatches || definitionMatches;
      }).toList();
    });
  }

  void _showDetails(DictionaryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsScreen(entry: entry),
      ),
    );
  }

  void _navigateToAbout() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AboutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Gede\'uffa-Amharic Dictionary'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 39, 73, 41),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gede\'uffa Amharic Dictionary',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                  SizedBox(height: 9),
                  Text('ጌዴኡፋ - አማረኛ መዝገበ ቃላት',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  SizedBox(height: 6),
                  Text('Learn, Define - Discover',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mobile_friendly),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToAbout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download for Windows'),
              onTap: () {
                Navigator.of(context).pop();
                // Add action for Download for Windows
              },
            ),
            ListTile(
              leading: const Icon(Icons.apple),
              title: const Text('Get it on App Store'),
              onTap: () {
                Navigator.of(context).pop();
                // Add action for App Store
              },
            ),
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Get it on Google Play'),
              onTap: () {
                Navigator.of(context).pop();
                // Add action for Google Play
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rate Us'),
              onTap: () {
                Navigator.of(context).pop();
                // Add action for Rate Us
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact'),
              onTap: () {
                Navigator.of(context).pop();
                // Add action for Contact
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.of(context).pop();
                // Add action for Share
              },
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Dark Theme'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                widget.toggleTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterEntries,
              decoration: const InputDecoration(
                hintText: 'Search.....',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DictionaryEntry>>(
              future: futureEntries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredEntries[index].word),
                        subtitle: Text(filteredEntries[index].definition),
                        onTap: () => _showDetails(filteredEntries[index]),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final DictionaryEntry entry;

  const DetailsScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.word),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Definition: ${entry.definition}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Type: ${entry.type}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Example: ${entry.example}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About This App",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "This is a Gede'uffa-Amharic dictionary app designed to help users translate between the gede'uffa and amharic languages easily. It provides definitions, examples, and more.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "My goal is to create a platform that fosters language learning, promotes cultural exchange, and connects communities around the world. I'm excited to share my progress and invite developers, authors, and QA professionals to join me in building this community-empowering project.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Text(
              "Developer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Biruk Afework. - Certified Programmer and RTO",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "E-mail: bkmen2580@gmail.com.",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Github: https://github.com/bkmen2580.",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Linkedin: https://linkedin.com/birukafework.",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Telegram: Rbiruk_buraa.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              "©Copyright 2024 Biruk Afework",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
