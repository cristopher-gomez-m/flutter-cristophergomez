import 'package:flutter/material.dart';
import '../services/cita_service.dart';

class CitaList extends StatefulWidget {
  const CitaList({Key? key}) : super(key: key);

  @override
  State<CitaList> createState() => _CitaListState();
}

class _CitaListState extends State<CitaList> {
  final CitaService _citaService = CitaService();
  bool _loading = true;
  List<dynamic> _citas = [];
  String? _error;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  Future<void> _loadCitas({String query = ''}) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Puedes adaptar el query si tu API lo acepta, por ejemplo ?search=...
      final citas = await _citaService.getAll(
        qs: query.isNotEmpty ? '?search=$query' : '',
      );
      setState(() {
        _citas = citas;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteCita(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Deseas eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _citaService.delete(id);
      _loadCitas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCitas),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔍 Buscador
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar cita...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => searchText = value,
                    onSubmitted: (_) => _loadCitas(query: searchText),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _loadCitas(query: searchText),
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🧾 Contenido principal
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _citas.isEmpty
                  ? const Center(child: Text('No hay citas'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Hora')),
                          DataColumn(label: Text('Cliente')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: _citas.map((cita) {
                          return DataRow(
                            cells: [
                              DataCell(Text(cita['fecha'] ?? '')),
                              DataCell(Text(cita['hora'] ?? '')),
                              DataCell(Text(cita['cliente']?['nombres'] ?? '')),
                              DataCell(
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/cita/editar',
                                          arguments: {'id': cita['id']},
                                        ).then((_) {
                                          _loadCitas(); // Esto se ejecuta al volver de la pantalla de edición
                                        });
                                      },

                                      child: const Text('Editar'),
                                    ),
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: () => _deleteCita(cita['id']),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cita/agregar');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
