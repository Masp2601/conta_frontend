import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIAN App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaisesScreen(),
    );
  }
}

class PaisesScreen extends StatefulWidget {
  const PaisesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaisesScreenState createState() => _PaisesScreenState();
}

class _PaisesScreenState extends State<PaisesScreen> {
  List<dynamic> paises = [];
  List<dynamic> filteredPaises = [];
  String sortBy = 'codigo';
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPaises();
  }

  Future<void> fetchPaises() async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:5000/paises?order_by=$sortBy'));
    if (response.statusCode == 200) {
      setState(() {
        paises = json.decode(response.body);
        filteredPaises = paises;
      });
    }
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredPaises = paises.where((pais) {
        return pais['nombre'].toLowerCase().contains(query.toLowerCase()) ||
            pais['codigo'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paises DIAN')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => filterSearchResults(value),
              decoration: const InputDecoration(
                  labelText: 'Buscar...', suffixIcon: Icon(Icons.search)),
            ),
          ),
          DropdownButton<String>(
            value: sortBy,
            onChanged: (newValue) {
              setState(() {
                sortBy = newValue!;
                fetchPaises();
              });
            },
            items: ['codigo', 'nombre', 'nombre_moneda', 'codigo_moneda']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPaises.length,
              itemBuilder: (context, index) {
                final pais = filteredPaises[index];
                return ListTile(
                  title: Text(pais['nombre']),
                  subtitle: Text('Código: ${pais['codigo']}'),
                  onTap: () => _showPaisDetails(context, pais),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPaisDetails(BuildContext context, dynamic pais) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pais['nombre']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${pais['codigo']}'),
            Text('Moneda: ${pais['nombre_moneda']} (${pais['codigo_moneda']})'),
            Text('TRM: ${pais['trm']}'),
            // Mostrar todos los campos requeridos
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaisFormScreen()),
    );
  }
}

class PaisFormScreen extends StatefulWidget {
  const PaisFormScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaisFormScreenState createState() => _PaisFormScreenState();
}

class _PaisFormScreenState extends State<PaisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {}; // Cambiado a dynamic para números

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo País')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Código País'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^\d{3}$').hasMatch(value)) {
                      return 'Debe ser 3 dígitos';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['codigo_pais'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obligatorio';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['nombre'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre Moneda'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obligatorio'
                      : null,
                  onSaved: (value) => _formData['nombre_moneda'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Código Moneda'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
                      return '3 letras mayúsculas';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['codigo_moneda'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Código UPS'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[A-Z0-9]{2}$').hasMatch(value)) {
                      return '2 caracteres alfanuméricos';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['codigo_ups'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Código IATA'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[A-Z0-9]{2}$').hasMatch(value)) {
                      return '2 caracteres alfanuméricos';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['codigo_iata'] = value!,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Código Telefónico'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^\d{3}$').hasMatch(value)) {
                      return '3 dígitos';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['codigo_telefonico'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'TRM'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
                      return 'Formato: 1234.56';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['trm'] = double.parse(value!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Guardar'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Enviar datos al backend
      try {
        final response = await http.post(
          Uri.parse('https://conta-backend.onrender.com:10000/paises'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_formData),
        );

        if (response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context); // Cerrar formulario
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('País creado exitosamente')),
          );
        } else {
          throw Exception('Error al crear país');
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
