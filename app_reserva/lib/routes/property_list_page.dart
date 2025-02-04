import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import '../services/dbService.dart';

class PropertyListPage extends StatefulWidget {
  const PropertyListPage({Key? key}) : super(key: key);

  @override
  _PropertyListPageState createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  Future<List<Property>>? _futureProperties;
  late var userAtual;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      userAtual = null;
    } else {
      userAtual = args;
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  Future<List<Property>> _searchProperties() async {
    final db = await DatabaseService.instance.database;
    List<String> conditions = [];
    List<dynamic> args = [];
    if (_ufController.text.isNotEmpty) {
      conditions.add("a.uf = ?");
      args.add(_ufController.text.toUpperCase());
    }
    if (_cityController.text.isNotEmpty) {
      conditions.add("a.localidade = ?");
      args.add(_cityController.text);
    }
    if (_neighborhoodController.text.isNotEmpty) {
      conditions.add("a.bairro = ?");
      args.add(_neighborhoodController.text);
    }
    if (_guestsController.text.isNotEmpty) {
      conditions.add("p.max_guest >= ?");
      args.add(int.tryParse(_guestsController.text) ?? 0);
    }
    String bookingClause = "";
    if (_checkIn != null && _checkOut != null) {
      // Exclui propriedades com reservas com datas conflitantes
      bookingClause =
          " AND p.id NOT IN (SELECT property_id FROM booking WHERE (checkin_date < ? AND checkout_date > ?))";
      args.add(DateFormat('yyyy-MM-dd').format(_checkOut!));
      args.add(DateFormat('yyyy-MM-dd').format(_checkIn!));
    }
    final whereClause =
        conditions.isNotEmpty ? "WHERE " + conditions.join(" AND ") : "";
    final query = '''
      SELECT p.*, COALESCE(ra.avg_rating, 0.0) as avg_rating
      FROM property p
      JOIN address a ON p.address_id = a.id
      LEFT JOIN (
        SELECT property_id, AVG(rating) as avg_rating
        FROM booking
        WHERE rating IS NOT NULL
        GROUP BY property_id
      ) ra ON ra.property_id = p.id
      $whereClause $bookingClause
    ''';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return List.generate(maps.length, (i) {
      return Property(
        id: maps[i]['id'],
        user_id: maps[i]['user_id'],
        address_id: maps[i]['address_id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        number: maps[i]['number'],
        complement: maps[i]['complement'] ?? "",
        price: maps[i]['price'],
        max_guest: maps[i]['max_guest'],
        thumbnail: maps[i]['thumbnail'],
        rating: maps[i]['avg_rating'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Propriedades')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(1, 24, 26, 33),
              ),
              accountName:
                  Text(userAtual != null ? userAtual.name : "Sem conta"),
              accountEmail:
                  Text(userAtual != null ? userAtual.email : "-------"),
              currentAccountPicture: const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 37, 3, 67),
                  child: Icon(Icons.person, size: 40)),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: _logout,
            ),
            ListTile(
              leading: const Icon(Icons.home_filled),
              title: const Text('Minhas Reservas'),
              onTap: () => Navigator.pushNamed(context, '/minhasReservas'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _ufController,
                    decoration: const InputDecoration(labelText: 'UF'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _neighborhoodController,
                    decoration: const InputDecoration(labelText: 'Bairro'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _checkIn == null
                                ? 'Check-in'
                                : DateFormat('yyyy-MM-dd').format(_checkIn!),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _checkIn = date;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _checkOut == null
                                ? 'Check-out'
                                : DateFormat('yyyy-MM-dd').format(_checkOut!),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _checkIn ?? DateTime.now(),
                              firstDate: _checkIn ?? DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _checkOut = date;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _guestsController,
                    decoration: const InputDecoration(
                      labelText: 'Número de hóspedes',
                      suffixIcon: Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _futureProperties = _searchProperties();
                        });
                      }
                    },
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _futureProperties == null
                ? const Center(
                    child: Text(
                        'Preencha os filtros e pressione Buscar para listar as propriedades'))
                : FutureBuilder<List<Property>>(
                    future: _futureProperties,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Nenhuma propriedade encontrada'));
                      } else {
                        final properties = snapshot.data!;
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: properties.length,
                          itemBuilder: (context, index) {
                            final property = properties[index];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: InkWell(
                                onTap: () {
                                  if (userAtual == null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Atenção'),
                                        content: const Text(
                                            'Você precisa estar logado para ver os detalhes da propriedade.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/detalhes', // Ensure your route exists
                                      arguments: {
                                        'property': property,
                                        'user': userAtual,
                                      },
                                    );
                                  }
                                },
                                child: ListTile(
                                  leading: Image.network(
                                    property.thumbnail == 'image_path'
                                        ? 'https://png.pngtree.com/png-vector/20240528/ourmid/pngtree-elegant-modern-mansion-with-parked-car-illustration-png-image_12509753.png'
                                        : property.thumbnail,
                                  ),
                                  title: Text(property.title),
                                  subtitle: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(property.rating.toStringAsFixed(1)),
                                    ],
                                  ),
                                  trailing: Text(
                                      'R\$ ${property.price.toStringAsFixed(2)}'),
                                ),
                              ),
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

  @override
  void dispose() {
    _ufController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _guestsController.dispose();
    super.dispose();
  }
}
