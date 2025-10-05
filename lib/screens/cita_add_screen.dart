import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cita_service.dart';
import '../services/cliente_service.dart';
import '../services/atencion_service.dart';

class CitaAdd extends StatefulWidget {
  const CitaAdd({Key? key}) : super(key: key);

  @override
  State<CitaAdd> createState() => _CitaAddState();
}

class _CitaAddState extends State<CitaAdd> {
  final CitaService _citaService = CitaService();
  final ClienteService _clienteService = ClienteService();
  final AtencionService _atencionService = AtencionService();

  DateTime? fecha;
  TimeOfDay? hora;
  int? clienteId;
  int? atencionId;

  List<dynamic> clientes = [];
  List<dynamic> atenciones = [];
  List<Map<String, dynamic>> detalles = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final clientesRes = await _clienteService.getAll(qs: '?per_page=100');
    final atencionesRes = await _atencionService.getAll(qs: '?per_page=100');
    setState(() {
      clientes = clientesRes;
      atenciones = atencionesRes;
    });
  }

  void agregarDetalle() {
    if (atencionId == null) return;
    final atencion = atenciones.firstWhere(
      (a) => a['id'] == atencionId,
      orElse: () => {},
    );

    if (atencion.isEmpty) return;

    // Evitar duplicados
    if (detalles.any((d) => d['atencion_id'] == atencion['id'])) return;

    setState(() {
      detalles.add({
        'atencion_id': atencion['id'],
        'nombre': atencion['nombre'],
        'precio': atencion['precio'],
      });
      atencionId = null;
    });
  }

  void eliminarDetalle(int index) {
    setState(() {
      detalles.removeAt(index);
    });
  }

  Future<void> save() async {
    if (fecha == null || hora == null || clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final fechaLocal = DateFormat('yyyy-MM-dd').format(fecha!);
    final horaLocal =
        '${hora!.hour.toString().padLeft(2, '0')}:${hora!.minute.toString().padLeft(2, '0')}';

    final body = {
      'fecha': fechaLocal,
      'hora': horaLocal,
      'cliente_id': clienteId,
      'detalle': detalles
          .map((d) => {'atencion_id': d['atencion_id']})
          .toList(),
    };

    setState(() => _loading = true);

    try {
      await _citaService.save(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita creada con éxito')),
        );
        Navigator.pushReplacementNamed(context, '/cita/list');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear cita: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ==========================================
  // ============= UI PRINCIPAL ===============
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Cita')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Fecha
                  ListTile(
                    title: const Text('Fecha'),
                    trailing: Text(
                      fecha != null
                          ? DateFormat('dd/MM/yyyy').format(fecha!)
                          : 'Seleccionar',
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => fecha = picked);
                    },
                  ),
                  const Divider(),

                  // Hora
                  ListTile(
                    title: const Text('Hora'),
                    trailing: Text(
                      hora != null
                          ? '${hora!.hour.toString().padLeft(2, '0')}:${hora!.minute.toString().padLeft(2, '0')}'
                          : 'Seleccionar',
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => hora = picked);
                    },
                  ),
                  const Divider(),

                  // Cliente
                  DropdownButtonFormField<int>(
                    value: clienteId,
                    decoration:
                        const InputDecoration(labelText: 'Seleccionar cliente'),
                    items: clientes
                        .map<DropdownMenuItem<int>>(
                          (c) => DropdownMenuItem(
                            value: c['id'],
                            child: Text(c['nombres']),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => clienteId = value),
                  ),
                  const SizedBox(height: 16),

                  // Seleccionar atención
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: atencionId,
                          decoration: const InputDecoration(
                            labelText: 'Seleccionar atención',
                          ),
                          items: atenciones
                              .map<DropdownMenuItem<int>>(
                                (a) => DropdownMenuItem(
                                  value: a['id'],
                                  child: Text(a['nombre']),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => atencionId = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: agregarDetalle,
                        child: const Text('+'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tabla de detalles
                  if (detalles.isNotEmpty)
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Atención')),
                        DataColumn(label: Text('Precio')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: detalles
                          .asMap()
                          .entries
                          .map(
                            (entry) => DataRow(
                              cells: [
                                DataCell(Text(entry.value['nombre'] ?? '')),
                                DataCell(Text(
                                    entry.value['precio'].toString())),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () =>
                                        eliminarDetalle(entry.key),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 24),

                  // Botón guardar
                  ElevatedButton.icon(
                    onPressed: save,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
