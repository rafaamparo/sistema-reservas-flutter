import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import '../services/dbService.dart';

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({Key? key}) : super(key: key);
  @override
  _PropertyDetailsPageState createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  late Property property;
  dynamic user;
  final _guestsController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    property = args['property'];
    user = args['user'];
  }

  void _showReservationDialog() {
    DateTime? checkIn;
    DateTime? checkOut;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Fazer Reserva'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _guestsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Número de hóspedes'),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            checkIn = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(labelText: 'Check-in'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(checkIn == null
                              ? 'Selecione a data'
                              : DateFormat('yyyy-MM-dd').format(checkIn!)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: checkIn ?? DateTime.now(),
                          firstDate: checkIn ?? DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            checkOut = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(labelText: 'Check-out'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(checkOut == null
                              ? 'Selecione a data'
                              : DateFormat('yyyy-MM-dd').format(checkOut!)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (checkIn == null ||
                        checkOut == null ||
                        _guestsController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Preencha todos os campos')));
                      return;
                    }
                    final amountGuest =
                        int.tryParse(_guestsController.text) ?? 1;
                    if (amountGuest <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'O número de hóspedes deve ser maior que zero.')));
                      return;
                    }
                    if (amountGuest > property.max_guest) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'O número de hóspedes não pode exceder ${property.max_guest}')));
                      return;
                    }
                    await DatabaseService.instance.createBooking(
                      userId: user.id,
                      property: property,
                      checkin: checkIn!,
                      checkout: checkOut!,
                      amountGuest: amountGuest,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Reserva realizada com sucesso!')));
                  },
                  child: const Text('Confirmar Reserva'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _guestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Propriedade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem (se disponível)
            Image.network(
              property.thumbnail == 'image_path'
                  ? 'https://png.pngtree.com/png-vector/20240528/ourmid/pngtree-elegant-modern-mansion-with-parked-car-illustration-png-image_12509753.png'
                  : property.thumbnail,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(property.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(property.description),
            const SizedBox(height: 8),
            Text('Número: ${property.number}'),
            Text(
                'Complemento: ${property.complement.isNotEmpty ? property.complement : '-'}'),
            Text('Preço: R\$ ${property.price.toStringAsFixed(2)}'),
            Text('Máx. hóspedes: ${property.max_guest}'),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(property.rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Faça o login para reservar')),
                    );
                  } else {
                    _showReservationDialog();
                  }
                },
                child: const Text('Fazer Reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
