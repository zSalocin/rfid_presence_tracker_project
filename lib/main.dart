import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:rfid/rfid_interface.dart';
import 'excel_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  late Excel excel;
  PlatformFile? file;
  String? filePath;
  List item = [];
  String? selectedItem;
  String? nameColumn;
  String? rfidColumn;
  String? id;
  String? espIp;
  late Sheet? table;
  bool espconnect = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/circuit.jpg', // Replace with your image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.4,
                heightFactor: 0.4,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Form(
                    key: formKey,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 45,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text("Selecione o arquivo:  ",
                                        overflow: TextOverflow
                                            .visible // Specify how to handle overflow
                                        ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        item = [];
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['xlsx'],
                                          allowMultiple: false,
                                        );

                                        if (result != null) {
                                          setState(() {
                                            filePath = result.files.single.path;
                                            excel = getExcel(filePath!);
                                            table = getSheetFromExcel(excel);
                                            item = getFirstColumnValues(table);
                                          });
                                        }
                                      },
                                      child: const Text('Select File'),
                                    ),
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Text(
                                  'File Path: ${filePath ?? "No file selected"}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  labelText: 'Presence Column',
                                ),
                                value: selectedItem, // Current selected item
                                items: item.map<DropdownMenuItem<String>>(
                                    (dynamic value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => selectedItem = value!,
                                validator: (value) {
                                  if (value == null) {
                                    return 'please select a Presence column';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  labelText: 'Esp IP',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a ESP IP';
                                  }
                                  return null;
                                },
                                onSaved: (value) => espIp = value!,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          flex: 5,
                          child: VerticalDivider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                        ),
                        Expanded(
                          flex: 45,
                          child: Column(
                            children: [
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  labelText: 'Name Column',
                                ),
                                value: nameColumn, // Current selected item
                                items: item.map<DropdownMenuItem<String>>(
                                    (dynamic value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => nameColumn = value!,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  labelText: 'Registration Column',
                                ),
                                value: id, // Current selected item
                                items: item.map<DropdownMenuItem<String>>(
                                    (dynamic value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => id = value!,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  labelText: 'RFID Column',
                                ),
                                value: rfidColumn, // Current selected item
                                items: item.map<DropdownMenuItem<String>>(
                                    (dynamic value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => rfidColumn = value!,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    //TODO add verifica;'ao de IP
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RFID(
                                          sheet: table,
                                          selectedItem: selectedItem,
                                          espIP: espIp,
                                          nameColumn: nameColumn,
                                          rfidColumn: rfidColumn,
                                          idColumn: id,
                                          filePath: filePath,
                                          excel: excel,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Go ->'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
