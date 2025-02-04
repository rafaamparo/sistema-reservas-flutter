import 'package:app_cadastro/models/user.dart';
import 'package:app_cadastro/services/dbService.dart';
import 'package:flutter/material.dart';
import 'package:app_cadastro/models/property.dart';

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
    setState(() {
      _propertiesFuture = _databaseService.getPropertiesByUserId(userAtual.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('TRIV Reservas - Minhas Propriedades',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.purple,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                  accountName: Text(userAtual.name),
                  accountEmail: Text(userAtual.email)),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Minhas Propriedades'),
                onTap: () {
                  Navigator.pushNamed(context, '/verProps',
                      arguments: userAtual);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Sair'),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/cadastrarProp',
                    arguments: userAtual),
                child: const Text('Cadastrar nova propriedade')),
            const SizedBox(height: 16),
            const Text('Selecione uma propriedade para editá-la',
                style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            FutureBuilder<List<Property>>(
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
                  return Expanded(
                      child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/editarProp',
                                arguments: property);
                          },
                          child: ListTile(
                            leading: Image.network(property.thumbnail ==
                                    'image_path'
                                ? 'https://png.pngtree.com/png-vector/20240528/ourmid/pngtree-elegant-modern-mansion-with-parked-car-illustration-png-image_12509753.png'
                                : property.thumbnail),
                            title: Text(property.title),
                            subtitle: Text(property.description),
                            trailing: Text('R\$ ${property.price}'),
                          ),
                        ),
                      );
                    },
                  ));
                }
              },
            )
          ],
        ));
  }
}
