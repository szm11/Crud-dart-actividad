import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';

class Ruta {
  final int id;
  final int capacidad;
  final String estado;
  final double kilometraje;

  Ruta(this.id, this.capacidad, this.estado, this.kilometraje);

  Map<String, dynamic> toJson() => {
    'id': id,
    'capacidad': capacidad,
    'estado': estado,
    'kilometraje': kilometraje,
  };

  static Ruta fromJson(Map<String, dynamic> json) => Ruta(
    json['id'],
    json['capacidad'],
    json['estado'],
    json['kilometraje'],
  );

  @override
  String toString() {
    return '| ${id.toString().padRight(4)} | ${capacidad.toString().padRight(10)} | ${estado.padRight(10)} | ${kilometraje.toStringAsFixed(2).padLeft(8)} |';
  }
}

class Contrato {
  final int id;
  final String fechaInicio;
  final String fechaFin;
  final String modalidad;
  final double tarifa;
  final int? rutaId;

  Contrato(this.id, this.fechaInicio, this.fechaFin, this.modalidad, this.tarifa, [this.rutaId]);

  Map<String, dynamic> toJson() => {
    'id': id,
    'fechaInicio': fechaInicio,
    'fechaFin': fechaFin,
    'modalidad': modalidad,
    'tarifa': tarifa,
    'rutaId': rutaId,
  };

  static Contrato fromJson(Map<String, dynamic> json) => Contrato(
    json['id'],
    json['fechaInicio'],
    json['fechaFin'],
    json['modalidad'],
    json['tarifa'],
    json['rutaId'],
  );

  @override
  String toString() {
    return '| ${id.toString().padRight(4)} | ${fechaInicio.padRight(12)} | ${fechaFin.padRight(12)} | ${modalidad.padRight(15)} | ${tarifa.toStringAsFixed(2).padLeft(8)} | ${(rutaId?.toString() ?? 'Sin ruta').padRight(8)} |';
  }
}

class RutaManager {
  final List<Ruta> rutas = [];
  int nextId = 1;
  late Database database;

  RutaManager() {
    _initialize();
  }

  void _initialize() {
    final dbPath = join(Directory.current.path, 'rutas.db');
    database = sqlite3.open(dbPath);
    database.execute('CREATE TABLE IF NOT EXISTS rutas(id INTEGER PRIMARY KEY, capacidad INTEGER, estado TEXT, kilometraje REAL)');
    loadRutas();
  }

  void loadRutas() {
    final ResultSet resultSet = database.select('SELECT * FROM rutas');
    for (final Row row in resultSet) {
      final ruta = Ruta(row['id'] as int, row['capacidad'] as int, row['estado'] as String, row['kilometraje'] as double);
      rutas.add(ruta);
      nextId = nextId > ruta.id ? nextId : ruta.id + 1;
    }
  }

  void saveRuta(Ruta ruta) {
    database.execute('INSERT INTO rutas (id, capacidad, estado, kilometraje) VALUES (?, ?, ?, ?)', [ruta.id, ruta.capacidad, ruta.estado, ruta.kilometraje]);
  }

  void createRuta() {
    print('--- Crear nueva ruta ---');
    stdout.write('Capacidad: ');
    final capacidad = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
    stdout.write('Estado: ');
    final estado = stdin.readLineSync() ?? '';
    stdout.write('Kilometraje: ');
    final kilometraje = double.tryParse(stdin.readLineSync() ?? '') ?? 0.0;

    final nuevaRuta = Ruta(nextId++, capacidad, estado, kilometraje);
    rutas.add(nuevaRuta);
    saveRuta(nuevaRuta);
    print('Ruta creada con éxito.');
  }

  void listRutas() {
    print('--- Lista de rutas ---');
    if (rutas.isEmpty) {
      print('No hay rutas registradas.');
    } else {
      print(_tableHeader());
      for (var ruta in rutas) {
        print(ruta.toString());
      }
    }
  }

  String _tableHeader() {
    return '| ID   | Capacidad  | Estado     | Kilom.   |';
  }

  Ruta? getRutaById(int id) {
    try {
      return rutas.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  void deleteRuta() {
    print('--- Borrar ruta ---');
    stdout.write('ID de la ruta a borrar: ');
    final idInput = stdin.readLineSync();
    final id = int.tryParse(idInput ?? '');
    
    if (id != null) {
      final ruta = getRutaById(id);
      if (ruta != null) {
        rutas.remove(ruta);
        database.execute('DELETE FROM rutas WHERE id = ?', [id]);
        print('Ruta borrada con éxito.');
      } else {
        print('Ruta no encontrada.');
      }
    } else {
      print('ID inválido.');
    }
  }

  void searchRutas() {
    print('--- Buscar rutas ---');
    stdout.write('Ingrese el término a buscar: ');
    final searchTerm = stdin.readLineSync() ?? '';

    final rutasEncontradas = rutas.where((r) =>
      r.capacidad.toString().contains(searchTerm) ||
      r.estado.contains(searchTerm) ||
      r.kilometraje.toString().contains(searchTerm)
    ).toList();

    if (rutasEncontradas.isEmpty) {
      print('No se encontraron rutas con el término: $searchTerm');
    } else {
      for (var ruta in rutasEncontradas) {
        print(ruta.toString());
      }
    }
  }
}

class ContratoManager {
  final List<Contrato> contratos = [];
  final RutaManager rutaManager;
  int nextId = 1;
  late Database database;

  ContratoManager(this.rutaManager) {
    _initialize();
  }

  void _initialize() {
    final dbPath = join(Directory.current.path, 'contratos.db');
    database = sqlite3.open(dbPath);
    database.execute(
      'CREATE TABLE IF NOT EXISTS contratos(id INTEGER PRIMARY KEY, fechaInicio TEXT, fechaFin TEXT, modalidad TEXT, tarifa REAL, rutaId INTEGER)',
    );
    loadContratos();
  }

  void loadContratos() {
    final ResultSet resultSet = database.select('SELECT * FROM contratos');
    for (final Row row in resultSet) {
      final contrato = Contrato.fromJson(row);
      contratos.add(contrato);
      nextId = nextId > contrato.id ? nextId : contrato.id + 1;
    }
  }

  void saveContrato(Contrato contrato) {
    database.execute('INSERT INTO contratos (id, fechaInicio, fechaFin, modalidad, tarifa, rutaId) VALUES (?, ?, ?, ?, ?, ?)', 
      [contrato.id, contrato.fechaInicio, contrato.fechaFin, contrato.modalidad, contrato.tarifa, contrato.rutaId]);
  }

  void createContrato() {
    print('--- Crear nuevo contrato ---');
    stdout.write('Fecha inicio (YYYY-MM-DD): ');
    final fechaInicio = stdin.readLineSync() ?? '';
    stdout.write('Fecha fin (YYYY-MM-DD): ');
    final fechaFin = stdin.readLineSync() ?? '';
    stdout.write('Modalidad: ');
    final modalidad = stdin.readLineSync() ?? '';
    stdout.write('Tarifa: ');
    final tarifa = double.tryParse(stdin.readLineSync() ?? '') ?? 0.0;
    stdout.write('ID de la ruta (opcional, presione Enter para omitir): ');
    final rutaIdInput = stdin.readLineSync();
    int? rutaId;
    
    if (rutaIdInput != null && rutaIdInput.isNotEmpty) {
      rutaId = int.tryParse(rutaIdInput);
      if (rutaId != null && rutaManager.getRutaById(rutaId) == null) {
        print('Advertencia: La ruta especificada no existe.');
        rutaId = null;
      }
    }

    final nuevoContrato = Contrato(nextId++, fechaInicio, fechaFin, modalidad, tarifa, rutaId);
    contratos.add(nuevoContrato);
    saveContrato(nuevoContrato);
    print('Contrato creado con éxito.');
  }

  void deleteContrato() {
    print('--- Borrar contrato ---');
    stdout.write('ID del contrato a borrar: ');
    final idInput = stdin.readLineSync();
    final id = int.tryParse(idInput ?? '');
    
    if (id != null) {
      final contrato = contratos.firstWhere((c) => c.id == id, orElse: () => Contrato(0, '', '', '', 0.0, null));
      if (contrato.id != 0) {
        contratos.remove(contrato);
        database.execute('DELETE FROM contratos WHERE id = ?', [id]);
        print('Contrato borrado con éxito.');
      } else {
        print('Contrato no encontrado.');
      }
    } else {
      print('ID inválido.');
    }
  }

  void readContrato() {
    print('--- Consultar contrato ---');
    stdout.write('ID del contrato a consultar: ');
    final idInput = stdin.readLineSync();
    final id = int.tryParse(idInput ?? '');

    if (id != null) {
      final contrato = contratos.firstWhere((c) => c.id == id, orElse: () => Contrato(0, '', '', '', 0.0, null));
      if (contrato.id != 0) {
        print(contrato.toString());
      } else {
        print('Contrato no encontrado.');
      }
    } else {
      print('ID inválido.');
    }
  }

  void updateContrato() {
    print('--- Actualizar contrato ---');
    stdout.write('ID del contrato a actualizar: ');
    final idInput = stdin.readLineSync();
    final id = int.tryParse(idInput ?? '');

    if (id != null) {
      final contrato = contratos.firstWhere((c) => c.id == id, orElse: () => Contrato(0, '', '', '', 0.0, null));
      if (contrato.id != 0) {
        stdout.write('Nueva fecha inicio (YYYY-MM-DD) [actual: ${contrato.fechaInicio}]: ');
        final nuevaFechaInicio = stdin.readLineSync() ?? contrato.fechaInicio;
        stdout.write('Nueva fecha fin (YYYY-MM-DD) [actual: ${contrato.fechaFin}]: ');
        final nuevaFechaFin = stdin.readLineSync() ?? contrato.fechaFin;
        stdout.write('Nueva modalidad [actual: ${contrato.modalidad}]: ');
        final nuevaModalidad = stdin.readLineSync() ?? contrato.modalidad;
        stdout.write('Nueva tarifa [actual: ${contrato.tarifa}]: ');
        final nuevaTarifa = double.tryParse(stdin.readLineSync() ?? '') ?? contrato.tarifa;

        final contratoActualizado = Contrato(contrato.id, nuevaFechaInicio, nuevaFechaFin, nuevaModalidad, nuevaTarifa, contrato.rutaId);
        contratos[contratos.indexOf(contrato)] = contratoActualizado;
        database.execute('UPDATE contratos SET fechaInicio = ?, fechaFin = ?, modalidad = ?, tarifa = ? WHERE id = ?', 
          [nuevaFechaInicio, nuevaFechaFin, nuevaModalidad, nuevaTarifa, contrato.id]);
        print('Contrato actualizado con éxito.');
      } else {
        print('Contrato no encontrado.');
      }
    } else {
      print('ID inválido.');
    }
  }

  void listContratos() {
    print('--- Lista de contratos ---');
    if (contratos.isEmpty) {
      print('No hay contratos registrados.');
    } else {
      for (var contrato in contratos) {
        print(contrato.toString());
      }
    }
  }

  void searchContratos() {
    print('--- Buscar contratos ---');
    stdout.write('Ingrese el término a buscar: ');
    final searchTerm = stdin.readLineSync() ?? '';

    final contratosEncontrados = contratos.where((c) =>
      c.fechaInicio.contains(searchTerm) ||
      c.fechaFin.contains(searchTerm) ||
      c.modalidad.contains(searchTerm) ||
      c.tarifa.toString().contains(searchTerm) ||
      (c.rutaId?.toString() ?? '').contains(searchTerm)
    ).toList();

    if (contratosEncontrados.isEmpty) {
      print('No se encontraron contratos con el término: $searchTerm');
    } else {
      for (var contrato in contratosEncontrados) {
        print(contrato.toString());
      }
    }
  }
}

void main() {
  final rutaManager = RutaManager();
  final contratoManager = ContratoManager(rutaManager);
  
  while (true) {
    print('--- Menú Principal ---');
    print('1. Crear contrato');
    print('2. Consultar contrato');
    print('3. Actualizar contrato');
    print('4. Listar contratos');
    print('5. Buscar contratos');
    print('6. Crear ruta');
    print('7. Listar rutas');
    print('8. Buscar rutas');
    print('9. Borrar contrato');
    print('10. Borrar ruta');
    print('11. Salir');
    stdout.write('Seleccione una opción: ');
    final opcion = stdin.readLineSync();

    switch (opcion) {
      case '1':
        contratoManager.createContrato();
        break;
      case '2':
        contratoManager.readContrato();
        break;
      case '3':
        contratoManager.updateContrato();
        break;
      case '4':
        contratoManager.listContratos();
        break;
      case '5':
        contratoManager.searchContratos();
        break;
      case '6':
        rutaManager.createRuta();
        break;
      case '7':
        rutaManager.listRutas();
        break;
      case '8':
        rutaManager.searchRutas();
        break;
      case '9':
        contratoManager.deleteContrato();
        break;
      case '10':
        rutaManager.deleteRuta();
        break;
      case '11':
        print('Saliendo del programa. ¡Hasta luego!');
        return;
      default:
        print('Opción no válida. Intente nuevamente.');
    }
    print('');
  }
}
