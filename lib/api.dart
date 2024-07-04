import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String apiUrl = 'http://api.binderbyte.com/wilayah/';
  static const String apiKey = '2a0fc45f2523da84bb178a2f43d3b4f6f761a1d3fa484ca1a5427b27b847f202';

  Future<List<dynamic>> fetchProvinsi() async {
    final response = await http.get(Uri.parse('${apiUrl}provinsi?api_key=${apiKey}'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body)["value"];
    } else {
      // If the server does not return a 200 OK response, throw an exception
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchKota(String idProvinsi) async {
    final response = await http.get(Uri.parse('${apiUrl}kabupaten?api_key=${apiKey}&id_provinsi=${idProvinsi}'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body)["value"];
    } else {
      // If the server does not return a 200 OK response, throw an exception
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchKecamatan(String idKabupaten) async {
    final response = await http.get(Uri.parse('${apiUrl}kecamatan?api_key=${apiKey}&id_kabupaten=${idKabupaten}'));

    print('${apiUrl}kecamatan?api_key=${apiKey}&id_kabupaten=${idKabupaten}');


    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body)["value"];
    } else {
      // If the server does not return a 200 OK response, throw an exception
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchKelurahan(String idKecamatan) async {
    final response = await http.get(Uri.parse('${apiUrl}kelurahan?api_key=${apiKey}&id_kecamatan=${idKecamatan}'));

    // print('${apiUrl}kelurahan?api_key=${apiKey}&id_kecamatan=${idKecamatan}');

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body)["value"];
    } else {
      // If the server does not return a 200 OK response, throw an exception
      throw Exception('Failed to load data');
    }
  }
}