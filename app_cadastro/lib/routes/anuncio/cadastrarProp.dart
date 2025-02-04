import 'package:app_cadastro/models/user.dart';
import 'package:app_cadastro/services/cepService.dart';
import 'package:flutter/material.dart';
import 'package:app_cadastro/models/property.dart';
import 'package:app_cadastro/services/dbService.dart';

class CadastrarProp extends StatefulWidget {
  const CadastrarProp({super.key});

  @override
  State<CadastrarProp> createState() => _CadastrarPropState();
}

class _CadastrarPropState extends State<CadastrarProp> {
  late User userAtual;
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return;
    }
    userAtual = args as User;
  }

  void _logout() {
    Navigator.pushNamed(context, '/login');
  }

  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _estadoController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestController = TextEditingController();
  final _thumbnailController = TextEditingController();
  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _localidadeController.dispose();
    _ufController.dispose();
    _estadoController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _priceController.dispose();
    _maxGuestController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _fetchCep() async {
    try {
      final address = await ViaCepService().viaCep(_cepController.text);
      _logradouroController.text = address.logradouro;
      _bairroController.text = address.bairro;
      _localidadeController.text = address.localidade;
      _ufController.text = address.uf;
      _estadoController.text = address.estado;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço preenchido')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar CEP')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _databaseService.addProperty(
        userAtual.id,
        _cepController.text,
        _logradouroController.text,
        _bairroController.text,
        _localidadeController.text,
        _ufController.text,
        _estadoController.text,
        _titleController.text,
        _descriptionController.text,
        int.parse(_numberController.text),
        _complementController.text,
        double.parse(_priceController.text),
        int.parse(_maxGuestController.text),
        _thumbnailController.text,
      );
      Navigator.pushReplacementNamed(context, '/verProps',
          arguments: userAtual);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar propriedade: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRIV Reservas - Cadastre uma propriedade'),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.w400, color: Colors.white),
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
                Navigator.pushNamed(context, '/verProps', arguments: userAtual);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // CEP e botão de buscar
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o CEP' : null,
              ),
              ElevatedButton(
                onPressed: _fetchCep,
                child: const Text('Buscar CEP'),
              ),
              // Campos de endereço
              TextFormField(
                controller: _logradouroController,
                decoration: const InputDecoration(labelText: 'Logradouro'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o logradouro'
                    : null,
              ),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o bairro' : null,
              ),
              TextFormField(
                controller: _localidadeController,
                decoration: const InputDecoration(labelText: 'Localidade'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe a localidade'
                    : null,
              ),
              TextFormField(
                controller: _ufController,
                decoration: const InputDecoration(labelText: 'UF'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe a Unidade Federativa'
                    : null,
              ),
              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(labelText: 'Estado'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o estado' : null,
              ),
              // Dados da propriedade
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o título' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe a descrição'
                    : null,
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o número' : null,
              ),
              TextFormField(
                controller: _complementController,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o preço' : null,
              ),
              TextFormField(
                controller: _maxGuestController,
                decoration:
                    const InputDecoration(labelText: 'Máximo de Hóspedes'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o máximo de hóspedes'
                    : null,
              ),
              TextFormField(
                controller: _thumbnailController,
                decoration: const InputDecoration(labelText: 'Thumbnail'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o link da thumbnail'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Adicionar Propriedade'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
