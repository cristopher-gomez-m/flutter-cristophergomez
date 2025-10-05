import 'package:flutter/material.dart';
import 'package:flutter_cristopher_gomez/services/atencion_service.dart';
import 'package:intl/intl.dart';
import '../services/cita_service.dart';
import '../services/cliente_service.dart';

class CitaEdit extends StatefulWidget {
  const CitaEdit({super.key});

  @override
  State<CitaEdit> createState() => _CitaEditState();
}

class _CitaEditState extends State<CitaEdit> {
  final CitaService _citaService = CitaService();
  final ClienteService _clienteService = ClienteService();
  final AtencionService _atencionService = AtencionService();

  bool _loading = false;

  late int citaId;
  DateTime? _fecha;
  TimeOfDay? _hora;
  int? _clienteId;
  List<Map<String, dynamic>> _detallesExistentes = [];
  List<Map<String, dynamic>> _detallesNuevo = [];
  List<int> _detallesEliminar = [];

  List<Map<String, dynamic>> _clientes = [];
  List<dynamic> atenciones = [];
  int? _atencionId;

  @override
  void initState() {
    super.initState();
    _loadClientes();
    _loadAtenciones();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      citaId = args['id'];
      _loadCita();
    });
  }

  Future<void> _loadClientes() async {
    try {
      final data = await _clienteService.getAll(qs: '?per_page=100');
      setState(() {
        _clientes = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print('Error cargando clientes: $e');
    }
  }

  Future<void> _loadAtenciones() async {
    try {
      final atencionesRes = await _atencionService.getAll(qs: '?per_page=100');
      setState(() {
        atenciones = atencionesRes;
      });
    } catch (e) {
      print('Error cargando atenciones: $e');
    }
  }

  Future<void> _loadCita() async {
    setState(() => _loading = true);
    try {
      final data = await _citaService.getById(citaId);

      setState(() {
        _fecha = DateTime.parse(data['fecha']);
        final horaParts = data['hora'].split(':');
        _hora = TimeOfDay(
          hour: int.parse(horaParts[0]),
          minute: int.parse(horaParts[1]),
        );
        _clienteId = data['cliente_id'];
        _detallesExistentes = List<Map<String, dynamic>>.from(data['detalles']);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cargar la cita')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _agregarDetalle() {
    if (_atencionId == null) return;
    final atencion = atenciones.firstWhere((a) => a['id'] == _atencionId);
    if (_detallesExistentes.any((d) => d['atencion_id'] == atencion['id']))
      return;

    final nuevoDetalle = {
      'atencion_id': atencion['id'],
      'nombre': atencion['nombre'],
      'precio': atencion['precio'],
    };

    setState(() {
      _detallesExistentes.add(nuevoDetalle);
      _detallesNuevo.add(nuevoDetalle);
      _atencionId = null;
    });
  }

  void _eliminarDetalle(Map<String, dynamic> d) {
    setState(() {
      _detallesExistentes.removeWhere(
        (x) => x['id'] == d['id'] || x['atencion_id'] == d['atencion_id'],
      );
      _detallesNuevo.removeWhere((x) => x['atencion_id'] == d['atencion_id']);
      if (d['id'] != null) _detallesEliminar.add(d['id']);
    });
  }

  Future<void> _saveCita() async {
    if (_fecha == null || _hora == null || _clienteId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos')),
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      // Convertir fecha a string yyyy-MM-dd
      final fechaLocal = _fecha!.toIso8601String().split('T')[0];

      // Convertir TimeOfDay a string HH:mm
      final horaLocal =
          '${_hora!.hour.toString().padLeft(2, '0')}:${_hora!.minute.toString().padLeft(2, '0')}';

      final body = {
        'fecha': fechaLocal,
        'hora': horaLocal,
        'cliente_id': _clienteId,
        'detalleNuevo': _detallesNuevo
            .map((d) => {'atencion_id': d['atencion_id']})
            .toList(),
        'detalleEliminar': _detallesEliminar,
      };

      await _citaService.edit(citaId, body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita actualizada con éxito')),
        );
        Navigator.pop(context); // Volver a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar la cita')),
        );
      }
      print('Error al actualizar cita: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cita')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('ID Cita: $citaId'),
                  // Fecha
                  ListTile(
                    title: const Text('Fecha'),
                    trailing: Text(
                      _fecha != null
                          ? DateFormat('dd/MM/yyyy').format(_fecha!)
                          : '',
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fecha ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _fecha = picked);
                    },
                  ),
                  // Hora
                  ListTile(
                    title: const Text('Hora'),
                    trailing: Text(_hora != null ? _hora!.format(context) : ''),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _hora ?? TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => _hora = picked);
                    },
                  ),
                  // Cliente
                  DropdownButton<int>(
                    value: _clienteId,
                    hint: const Text('Selecciona un cliente'),
                    isExpanded: true,
                    items: _clientes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c['id'] as int,
                            child: Text(c['nombres']),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _clienteId = v),
                  ),
                  const SizedBox(height: 16),
                  // Seleccionar atención y agregar
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: _atencionId,
                          hint: const Text('Selecciona una atención'),
                          isExpanded: true,
                          items: atenciones
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a['id'] as int,
                                  child: Text(a['nombre']),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _atencionId = v),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _agregarDetalle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabla de detalles
                  if (_detallesExistentes.isNotEmpty)
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Atención')),
                        DataColumn(label: Text('Precio')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: _detallesExistentes
                          .map(
                            (d) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    d['nombre'] != null
                                        ? d['nombre'].toString()
                                        : (d['atencion']?['nombre'] ?? ''),
                                  ),
                                ),

                                DataCell(
                                  Text(
                                    d['precio'] != null
                                        ? d['precio'].toString()
                                        : (d['atencion']?['precio'] ?? ''),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _eliminarDetalle(d),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveCita,
                    child: const Text('Actualizar Cita'),
                  ),
                ],
              ),
            ),
    );
  }
}
