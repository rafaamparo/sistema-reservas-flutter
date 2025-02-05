import 'package:app_reserva/models/booking.dart';
import 'package:app_reserva/models/property.dart';
import 'package:flutter/material.dart';
import '../services/dbService.dart';

class UserReservationsPage extends StatefulWidget {
  const UserReservationsPage({Key? key}) : super(key: key);

  @override
  _UserReservationsPageState createState() => _UserReservationsPageState();
}

class _UserReservationsPageState extends State<UserReservationsPage> {
  Future<List<Booking>> _futureReservations = Future.value([]);
  late var userAtual;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || args['user'] == null) {
      Future.microtask(
          () => Navigator.pushReplacementNamed(context, '/welcome'));
      return;
    } else {
      userAtual = args['user'];
      _futureReservations = _fetchReservations();
    }
  }

  Future<List<Booking>> _fetchReservations() async {
    print(userAtual.id);
    return DatabaseService.instance.getBookings(userAtual.id);
  }

  Future<void> _cancelReservation(int bookingId) async {
    await DatabaseService.instance.cancelBooking(bookingId);
    setState(() {
      _futureReservations = _fetchReservations();
    });
  }

  Future<void> _submitRating(int bookingId, int rating) async {
    final db = await DatabaseService.instance.database;
    await db.update('booking', {'rating': rating},
        where: 'id = ?', whereArgs: [bookingId]);
    setState(() {
      _futureReservations = _fetchReservations();
    });
  }

  void _showRatingDialog(int bookingId) {
    int selectedRating = 5;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Avalie sua reserva'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  icon: Icon(
                    star <= selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setStateDialog(() {
                      selectedRating = star;
                    });
                  },
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitRating(bookingId, selectedRating);
                  Navigator.pop(context);
                },
                child: const Text('Enviar'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Reservas')),
      body: FutureBuilder<List<Booking>>(
        future: _futureReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma reserva encontrada'));
          } else {
            final reservations = snapshot.data!;
            print('AAAAAAAAAAAAAAAAAAAAAAAAA');
            return ListView.builder(
              shrinkWrap: true,
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final res = reservations[index];
                print(res);
                final checkIn = DateTime.parse(res.checkin_date);
                final checkOut = DateTime.parse(res.checkout_date);
                final bool isPast = now.isAfter(checkOut);
                final bool isUpcoming = now.isBefore(checkIn);
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Property?>(
                          future: DatabaseService.instance
                              .getPropertyById(res.property_id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Carregando propriedade...');
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const Text('Propriedade: Indisponível');
                            } else {
                              return Text(
                                'Propriedade: ${snapshot.data!.title}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                            'Valor Total: R\$${res.total_price.toStringAsFixed(2)}'),
                        const SizedBox(height: 4),
                        Text(
                            'Check-in: ${checkIn.toLocal().toString().split(' ')[0]}'),
                        Text(
                            'Check-out: ${checkOut.toLocal().toString().split(' ')[0]}'),
                        const SizedBox(height: 8),
                        if (isPast)
                          ElevatedButton(
                            onPressed: () => _showRatingDialog(res.id),
                            child: const Text('Avaliar Reserva'),
                          ),
                        if (isUpcoming)
                          ElevatedButton(
                            onPressed: () => _cancelReservation(res.id),
                            child: const Text('Cancelar Reserva'),
                          ),
                      ],
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
