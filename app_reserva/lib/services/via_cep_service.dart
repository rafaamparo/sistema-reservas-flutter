// lib/services/via_cep_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';

class ViaCepService {
  Future<Address?> getAddressByCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanCep.length != 8) return null;

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cleanCep/json/')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['erro'] == true) return null;

        return Address(
          cep: data['cep'],
          logradouro: data['logradouro'],
          bairro: data['bairro'],
          localidade: data['localidade'],
          uf: data['uf'],
          estado: _getEstadoFromUF(data['uf']),
        );
      }
    } catch (e) {
      print('Erro ao buscar CEP: $e');
    }
    return null;
  }

  String _getEstadoFromUF(String uf) {
    final estados = {
      'AC': 'Acre',
      'AL': 'Alagoas',
      'AP': 'Amapá',
      'AM': 'Amazonas',
      'BA': 'Bahia',
      'CE': 'Ceará',
      'DF': 'Distrito Federal',
      'ES': 'Espírito Santo',
      'GO': 'Goiás',
      'MA': 'Maranhão',
      'MT': 'Mato Grosso',
      'MS': 'Mato Grosso do Sul',
      'MG': 'Minas Gerais',
      'PA': 'Pará',
      'PB': 'Paraíba',
      'PR': 'Paraná',
      'PE': 'Pernambuco',
      'PI': 'Piauí',
      'RJ': 'Rio de Janeiro',
      'RN': 'Rio Grande do Norte',
      'RS': 'Rio Grande do Sul',
      'RO': 'Rondônia',
      'RR': 'Roraima',
      'SC': 'Santa Catarina',
      'SP': 'São Paulo',
      'SE': 'Sergipe',
      'TO': 'Tocantins',
    };
    return estados[uf] ?? uf;
  }
}