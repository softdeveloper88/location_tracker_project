import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/phone_track_location_screen.dart';
import 'dart:convert';

import 'odoo_connector.dart';

class EmployeeSearchScreen extends StatefulWidget {
  @override
  _EmployeeSearchScreenState createState() => _EmployeeSearchScreenState();
}

class _EmployeeSearchScreenState extends State<EmployeeSearchScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  String? _employeeData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchEmployee() async {
    setState(() {
      _isLoading = true;
      _employeeData = null;
      _errorMessage = null;
    });

    final employeeId = _employeeIdController.text;
    if (employeeId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter an Employee ID';
      });
      return;
    }

    try {
      // Replace with your Odoo server details
      var odooConnector = OdooConnector(
        'http://13.58.175.151:8017', // Odoo URL
        'staging',                   // Database name
        'mobile_app',                // Username
        '123',                       // Password
      );
    var response= await odooConnector.fetchEmployeeData(int.parse(employeeId));

      if (response !=null) {
        setState(() async {
          final data = jsonEncode(response);
          _employeeData = json.decode(data)['name'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('barcode', employeeId);
          await prefs.setString('employeeName', _employeeData.toString());
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PhoneTrackLocationScreen(),
              ));
          // Adjust based on your Odoo response

        });
      } else {
        setState(() {
          _errorMessage = 'Employee not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text("Login",style: GoogleFonts.poppins(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Image.asset(
                  'assets/images/app_logo.png', // Replace with your logo path
                  height: 100,
                ),
              ),
              SizedBox(height: 40),
              Container(
                child: TextField(
                  controller: _employeeIdController,
                  decoration: InputDecoration(
                    labelText: 'Enter Employee ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: MaterialButton(
                  color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  textColor: Colors.white,
                  onPressed: _searchEmployee,
                  child: _isLoading
                      ? Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                      )
                      : Text('Search'),
                ),
              ),
              SizedBox(height: 20),
              if (_employeeData != null) ...[
                Text(
                  'Employee Name: $_employeeData',
                  style: TextStyle(fontSize: 16),
                ),
              ] else if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
