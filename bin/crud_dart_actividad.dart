import 'dart:convert';
import 'dart:io';

class Ruta {
  final int id;
  final int capacidad;
  final String estado;
  final double kilometraje;

  Ruta(this.id, this.capacidad, this.estado, this.kilometraje);

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

  @override
  String toString() {
    return '| ${id.toString().padRight(4)} | ${fechaInicio.padRight(12)} | ${fechaFin.padRight(12)} | ${modalidad.padRight(15)} | ${tarifa.toStringAsFixed(2).padLeft(8)} | ${(rutaId?.toString() ?? 'Sin ruta').padRight(8)} |';
  }
}

class RutaManager {
  final List<Ruta> rutas = [];
  int nextId = 1;

  void createRuta() {
    print('--- Crear nueva ruta ---');
    stdout.write('Capacidad: ');
    final capacidad = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
    stdout.write('Estado: ');
    final estado = stdin.readLineSync() ?? '';
    stdout.write('Kilometraje: ');
    final kilometraje = double.tryParse(stdin.readLineSync() ?? '') ?? 0.0;

    rutas.add(Ruta(nextId++, capacidad, estado, kilometraje));
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
}

class ContratoManager {
  final List<Contrato> contratos = [];
  final RutaManager rutaManager;
  int nextId = 1;

  ContratoManager(this.rutaManager);

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

    contratos.add(Contrato(nextId++, fechaInicio, fechaFin, modalidad, tarifa, rutaId));
    print('Contrato creado con éxito.');
  }

  void readContrato() {
    print('--- Consultar contrato ---');
    stdout.write('ID del contrato: ');
    final id = int.tryParse(stdin.readLineSync() ?? '');
    
    // Buscar el contrato de manera segura
    final contrato = contratos.where((c) => c.id == id).firstOrNull;

    if (contrato != null) {
      print('Contrato encontrado:');
      print(_tableHeader());
      print(contrato.toString());
    } else {
      print('Contrato no encontrado.');
    }
  }

  void updateContrato() {
    print('--- Actualizar contrato ---');
    stdout.write('ID del contrato: ');
    final id = int.tryParse(stdin.readLineSync() ?? '');
    final Contrato? contrato = contratos.firstWhere(
      (c) => c.id == id,
      orElse: () => null as Contrato,
    );

    if (contrato != null) {
      stdout.write('Nueva fecha inicio (actual: ${contrato.fechaInicio}): ');
      final fechaInicio = stdin.readLineSync() ?? contrato.fechaInicio;
      stdout.write('Nueva fecha fin (actual: ${contrato.fechaFin}): ');
      final fechaFin = stdin.readLineSync() ?? contrato.fechaFin;
      stdout.write('Nueva modalidad (actual: ${contrato.modalidad}): ');
      final modalidad = stdin.readLineSync() ?? contrato.modalidad;
      stdout.write('Nueva tarifa (actual: ${contrato.tarifa}): ');
      final tarifa = double.tryParse(stdin.readLineSync() ?? '') ?? contrato.tarifa;

      contratos[contratos.indexOf(contrato)] =
          Contrato(contrato.id, fechaInicio, fechaFin, modalidad, tarifa, contrato.rutaId);
      print('Contrato actualizado con éxito.');
    } else {
      print('Contrato no encontrado.');
    }
  }

  void listContratos() {
    print('--- Lista de contratos ---');
    if (contratos.isEmpty) {
      print('No hay contratos registrados.');
    } else {
      print(_tableHeader());
      for (var contrato in contratos) {
        print(contrato.toString());
      }
    }
  }

  void searchContratos() {
    print('--- Buscar contratos ---');
    stdout.write('Ingrese término de búsqueda: ');
    final term = stdin.readLineSync()?.toLowerCase() ?? '';
    final resultados = contratos.where((c) =>
        c.fechaInicio.toLowerCase().contains(term) ||
        c.fechaFin.toLowerCase().contains(term) ||
        c.modalidad.toLowerCase().contains(term) ||
        c.tarifa.toString().contains(term) ||
        c.id.toString().contains(term)).toList();

    if (resultados.isEmpty) {
      print('No se encontraron contratos que coincidan con el término.');
    } else {
      print('Resultados de la búsqueda:');
      print(_tableHeader());
      for (var contrato in resultados) {
        print(contrato.toString());
      }
    }
  }

  String _tableHeader() {
    return '| ID   | Fecha Inicio  | Fecha Fin    | Modalidad       | Tarifa  | Ruta ID |';
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
    print('8. Salir');
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
        print('Saliendo del programa. ¡Hasta luego!');
        return;
      default:
        print('Opción no válida. Intente nuevamente.');
    }
    print('');
  }
}
