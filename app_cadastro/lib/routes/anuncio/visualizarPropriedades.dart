import 'package:app_cadastro/models/user.dart';
import 'package:flutter/material.dart';

class VerProps extends StatefulWidget {
  const VerProps({super.key});

  @override
  State<VerProps> createState() => _VerPropsState();
}

class _VerPropsState extends State<VerProps> {
  late User userAtual;

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userAtual = ModalRoute.of(context)!.settings.arguments as User;
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
    );
  }
}
