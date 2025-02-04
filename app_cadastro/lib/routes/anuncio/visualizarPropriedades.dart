import 'package:app_cadastro/models/user.dart';
import 'package:app_cadastro/services/dbService.dart';
import 'package:flutter/material.dart';
import 'package:app_cadastro/models/property.dart'; // Import the Property model

class VerProps extends StatefulWidget {
  const VerProps({super.key});

  @override
  State<VerProps> createState() => _VerPropsState();
}

class _VerPropsState extends State<VerProps> {
  late User userAtual;
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Property>> _propertiesFuture =
      _databaseService.getPropertiesByUserId(0);
  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return;
    }
    userAtual = args as User;
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    // final propriedades =
    //     await _databaseService.getPropertiesByUserId(userAtual.id);
    setState(() {
      _propertiesFuture = _databaseService.getPropertiesByUserId(userAtual.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRIV Reservas - Minhas Propriedades'),
        backgroundColor: Colors.purple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userAtual.name),
              accountEmail: Text(userAtual.email),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Property>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text('Error loading properties'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No properties found'));
          } else {
            final properties = snapshot.data!;
            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(property.thumbnail),
                    title: Text(property.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(property.description)],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
