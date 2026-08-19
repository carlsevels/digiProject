import 'package:powersync/powersync.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class MyBackendConnector extends PowerSyncBackendConnector {
  PowerSyncDatabase db;

  MyBackendConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final supabase = Supabase.instance.client;

    var session = supabase.auth.currentSession;

    if (session == null || session.isExpired) {
      try {
        final response = await supabase.auth.refreshSession();
        session = response.session;
      } catch (e) {
        print("Error refrescando sesión: $e");
        return null;
      }
    }

    return PowerSyncCredentials(
      endpoint: "https://6a4e6c7849dca2d8a417eda2.powersync.journeyapps.com",
      token: session!.accessToken,
      userId: session.user.id,
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    final supabase = Supabase.instance.client;

    try {
      for (var op in transaction.crud) {
        final table = op.table;
        final data = Map<String, dynamic>.from(op.opData ?? {});

        // Asegurar explícitamente que el ID esté presente en los datos
        data['id'] = op.id;

        if (op.op == UpdateType.put) {
          // Usar onConflict para garantizar que si ya existe el registro, se actualice en lugar de duplicar
          await supabase.from(table).upsert(data, onConflict: 'id');
        } else if (op.op == UpdateType.patch) {
          await supabase.from(table).update(data).eq('id', op.id);
        } else if (op.op == UpdateType.delete) {
          final List<String> tablasConFolioId = [
            'folios',
            'historialestados',
            'comentarios',
          ];

          if (tablasConFolioId.contains(table)) {
            final registro = await supabase
                .from(table)
                .select('folioId')
                .eq('id', op.id)
                .maybeSingle();

            if (registro != null && registro['folioId'] != null) {
              final folioId = registro['folioId'];
              await supabase.from(table).delete().eq('folioId', folioId);
              print("🗑️ Eliminado en Supabase usando folioId: $folioId");
            } else {
              await supabase.from(table).delete().eq('id', op.id);
              print("🗑️ Eliminado en Supabase usando id por respaldo: ${op.id}");
            }
          } else {
            await supabase.from(table).delete().eq('id', op.id);
            print("🗑️ Eliminado en Supabase usando id: ${op.id}");
          }
        }
      }

      // Marcar la transacción como completada solo si todo salió bien
      await transaction.complete();
    } catch (e, st) {
      print("❌ Error en uploadData de PowerSync: $e");
      print(st);
      rethrow; // Permite que PowerSync reintente la transacción de forma segura más adelante
    }
  }
}

class AppDatabase {
  static late PowerSyncDatabase _db;
  static bool _isInitialized = false;

  static PowerSyncDatabase get db {
    if (!_isInitialized) {
      throw Exception(
        "AppDatabase no ha sido inicializada. Llama a initialize() primero.",
      );
    }
    return _db;
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    String dbPath;

    if (kIsWeb) {
      dbPath = 'database.sqlite';
    } else {
      final dir = await getApplicationDocumentsDirectory();
      dbPath = join(dir.path, 'database.sqlite');
    }

    _db = PowerSyncDatabase(schema: schema, path: dbPath);
    await _db.initialize();

    await _db.connect(connector: MyBackendConnector(_db));

    _isInitialized = true;
    print("PowerSync inicializado correctamente.");
  }
}

final schema = Schema([
  Table('roles', [
    Column.text('created_at'),
    Column.text('name'),
    Column.text('color')
  ]),
  Table('municipios', [
    Column.text('created_at'),
    Column.text('nombre')
  ]),
  Table('condicionPago', [
    Column.text('created_at'),
    Column.text('nombre')
  ]),
  Table('status', [
    Column.text('created_at'),
    Column.text('nombre'),
    Column.text('color')
  ]),
  Table('tipos', [
    Column.text('created_at'),
    Column.text('nombre'),
    Column.text('color')
  ]),
  Table('clientes', [
    Column.text('created_at'),
    Column.text('razonSocial'),
    Column.text('nombreComercial')
  ]),
  Table('direcciones', [
    Column.text('created_at'),
    Column.text('calle'),
    Column.text('colonia'),
    Column.text('codigoPostal'),
    Column.text('numExt'),
    Column.text('numInt'),
    Column.integer('municipioId'),
    Column.integer('clienteId')
  ]),
  Table('datosPersonales', [
    Column.text('created_at'),
    Column.text('nombre'),
    Column.text('apellidoPaterno'),
    Column.text('apellidoMaterno'),
    Column.text('userId'),
    Column.integer('rolId')
  ]),
  Table('folios', [
    Column.text('created_at'),
    Column.integer('tipoFolioId'),
    Column.integer('clienteId'),
    Column.text('cantidad'),
    Column.integer('typeRefaccionId'),
    Column.integer('condicionDePagoId'),
    Column.text('creadorId'),
    Column.text('repartidorId'),
    Column.text('folioId'),
    Column.integer('isArchived'),
  ]),
  Table('historialestados', [
    Column.text('created_at'),
    Column.integer('statusId'),
    Column.text('hora'),
    Column.text('descripcion'),
    Column.text('folioId')
  ]),
  Table('comentarios', [
    Column.text('created_at'),
    Column.text('userId'),
    Column.text('folioId'),
    Column.text('comentario')
  ]),
  Table('organigrama', [
    Column.text('created_at'),
    Column.integer('parent'),
    Column.text('name'),
    Column.text('color'),
    Column.text('employee_id')
  ])
]);