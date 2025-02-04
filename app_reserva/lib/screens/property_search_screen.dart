import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../models/property_model.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  _PropertySearchScreenState createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedUF;
  String? selectedCity;
  String? selectedNeighborhood;
  DateTime? checkIn;
  DateTime? checkOut;
  int? guests;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Propriedades'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reservas',
                child: Text('Minhas Reservas'),
              ),
              const PopupMenuItem(
                value: 'sair',
                child: Text('Sair'),
              ),
            ],
            onSelected: (value) {
              if (value == 'reservas') {
                // Navegar para tela de reservas
              } else if (value == 'sair') {
                Navigator.pushReplacementNamed(context, '/welcome');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedUF,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: const [
                      // Adicionar lista de estados
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedUF = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Check-in',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          checkIn = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Número de hóspedes',
                      suffixIcon: Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        guests = int.tryParse(value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<PropertyProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.properties.length,
                  itemBuilder: (context, index) {
                    final property = provider.properties[index];
                    return PropertyCard(property: property);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            context.read<PropertyProvider>().searchProperties(
              uf: selectedUF,
              city: selectedCity,
              neighborhood: selectedNeighborhood,
              checkIn: checkIn,
              checkOut: checkOut,
              guests: guests,
            );
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navegar para detalhes da propriedade
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.thumbnail != null)
              Image.network(
                property.thumbnail!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        property.rating?.toStringAsFixed(1) ?? 'Novo',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Text(
                        'R\$ ${property.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}