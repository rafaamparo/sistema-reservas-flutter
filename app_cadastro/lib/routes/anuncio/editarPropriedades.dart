import 'package:flutter/material.dart';
import 'package:app_cadastro/models/property.dart';
import 'package:app_cadastro/models/adress.dart';
import 'package:app_cadastro/services/dbService.dart';
import 'package:app_cadastro/services/cepService.dart';

class EditarProp extends StatefulWidget {
  const EditarProp({super.key});

  @override
  State<EditarProp> createState() => _EditarPropState();
}

class _EditarPropState extends State<EditarProp> {
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
  final DatabaseService _databaseService = DatabaseService.instance;
  late Property _property;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return;
    }
    _property = args as Property;
    _loadPropertyData();
  }

  Future<void> _loadPropertyData() async {
    final address = await _databaseService.getAdressById(_property.address_id);
    setState(() {
      _cepController.text = address.cep;
      _logradouroController.text = address.logradouro;
      _bairroController.text = address.bairro;
      _localidadeController.text = address.localidade;
      _ufController.text = address.uf;
      _estadoController.text = address.estado;
      _titleController.text = _property.title;
      _descriptionController.text = _property.description;
      _numberController.text = _property.number.toString();
      _complementController.text = _property.complement;
      _priceController.text = _property.price.toString();
      _maxGuestController.text = _property.max_guest.toString();
      _thumbnailController.text = _property.thumbnail;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _databaseService.editProperty(
        propertyId: _property.id,
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        bairro: _bairroController.text,
        localidade: _localidadeController.text,
        uf: _ufController.text,
        estado: _estadoController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        number: int.parse(_numberController.text),
        complement: _complementController.text,
        price: double.parse(_priceController.text),
        max_guest: int.parse(_maxGuestController.text),
        thumbnail: _thumbnailController.text,
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao editar propriedade: $e')),
      );
    }
  }

  Future<void> _deleteProperty() async {
    try {
      await _databaseService.deletePropertyAndImages(_property.id);
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar propriedade: $e')),
      );
    }
  }

  Future<void> _fetchCep() async {
    try {
      final address = await ViaCepService().viaCep(_cepController.text);
      setState(() {
        _logradouroController.text = address.logradouro;
        _bairroController.text = address.bairro;
        _localidadeController.text = address.localidade;
        _ufController.text = address.uf;
        _estadoController.text = address.estado;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço preenchido')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar CEP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Propriedade'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o CEP' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchCep,
                child: const Text('Buscar CEP'),
              ),
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
                child: const Text('Salvar Alterações'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteProperty,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Deletar Propriedade'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
