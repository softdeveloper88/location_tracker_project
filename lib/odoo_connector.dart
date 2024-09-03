import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:xml_rpc/client.dart' as xml_rpc;
class OdooConnector {
  final String url;
  final String db;
  final String username;
  final String password;

  late OdooClient _client;
  late OdooSession _session;

  OdooConnector(this.url, this.db, this.username, this.password) {
    _client = OdooClient(url);

  }

  // Authenticate with Odoo and get the session
  Future<void> authenticate() async {
    try {
      _session = await _client.authenticate(db, username, password);
      print('Authenticated successfully. Session ID: ${_session.id}');
    } catch (e) {
      print('Failed to authenticate: $e');
      rethrow;
    }
  }

  // Create a record in the specified Odoo model (table)
  Future<int> createRecord(
      String modelName, // e.g., 'res.partner' for the Contacts table
      Map<String, dynamic> fields, // Fields to insert into the model
      ) async {
    try {
      final id = await _client.callKw({
        'model': modelName,
        'method': 'create',
        'args': [fields],
        'kwargs': <String, dynamic>{},
      });
      return id as int;
    } catch (e) {
      print('Failed to create record: $e');
      rethrow;
    }
  }
  Future<void> sendDataToOdoo({String? mac,String? androidId,String? time,String? date,String? dateTime,String? latitude,String? longitude}) async {


    try {
      // Authenticate and get the session
      await authenticate();
      print("lat::: $latitude, long::: $longitude ");
      // Prepare the data to send
          final fields = {
      'name': mac,
      'x_app_key': androidId,
      'time': time,
      'date': date,
      'date_time': dateTime,
      'latitude': latitude,
      'longitude': longitude,
    };

      // Send the data to the 'res.partner' model (Contacts table)
      final recordId = await createRecord(
        'user.app.location.history',
        fields,
      );

      print("Record created with ID: $recordId");
    } catch (e) {
      print("Failed to create record: $e");
    }
  }
}
// class OdooConnector {
//   final String url;
//   final String db;
//   final String username;
//   final String password;
//
//   OdooConnector(this.url, this.db, this.username, this.password);
//
//   Future<int> authenticate() async {
//     final serverUrl = Uri.parse('$url/xmlrpc/2/common');
//     final config = {
//       'database': db,
//       'username': username,
//       'password': password,
//     };
//
//     try {
//       final response = await xml_rpc.call(
//         serverUrl,
//         'authenticate',
//         [db, username, password, {}],
//       );
//       return response as int;
//     } catch (e) {
//       print('Failed to authenticate: $e');
//       return 0;
//     }
//   }
//
//   Future<int> createAttendanceRecord(
//       int uid,
//       String androidId,
//       String mac,
//       String date,
//       String? time,
//       String? datetime,
//       String? latitude,
//       String? longitude,
//       ) async {
//     final serverUrl = Uri.parse('$url/xmlrpc/2/object');
//     final fields = {
//       'name': mac,
//       'x_app_key': androidId,
//       'time': time,
//       'date': date,
//       'date_time': datetime,
//       'latitude': latitude,
//       'longitude': longitude,
//     };
//
//     try {
//       final response = await xml_rpc.call(
//         serverUrl,
//         'execute_kw',
//         [db, uid, password, 'user.app.location.history', 'create', [fields]],
//       );
//       print('create attendance record');
//       return response as int;
//     } catch (e) {
//       print('Failed to create attendance record: $e');
//       return 0;
//     }
//   }
// }
//
// Future<void> sendAttendanceDataInBackground(
//     String androidId,
//     String mac,
//     String date,
//     String? time,
//     String? datetime,
//     String? latitude,
//     String? longitude,
//     ) async {
//   final url = 'http://13.58.175.151:8069';
//   final db = 'staging';
//   final username = 'mobile_app';
//   final password = '123';
//
//   final odooConnector = OdooConnector(url, db, username, password);
//   print(androidId);
//   print("\n$mac");
//   print("\n$date");
//   print("\n$time");
//   print("\n$datetime");
//   print("\n$latitude");
//   print("\n$longitude");
//
//   try {
//     final uid = await odooConnector.authenticate();
//     if (uid != 0) {
//       final attendanceId = await odooConnector.createAttendanceRecord(
//           uid, androidId, mac, date, time, datetime, latitude, longitude);
//       print("Attendance record created with ID: $attendanceId");
//     } else {
//       print("Failed to authenticate with Odoo");
//     }
//   } catch (e) {
//     print("Failed to create attendance record: $e");
//   }
// }
