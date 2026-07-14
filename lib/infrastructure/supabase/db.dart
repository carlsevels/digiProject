// Ejemplo de cómo suele verse la configuración
import 'dart:convert';

import 'package:powersync/powersync.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powersync/powersync.dart';

class MyBackendConnector extends PowerSyncBackendConnector {
  PowerSyncDatabase db;

  MyBackendConnector(this.db);
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Implement fetchCredentials to obtain a JWT from your authentication service
    // If you're using Supabase or Firebase, you can re-use the JWT from those clients, see
    // - https://docs.powersync.com/installation/authentication-setup/supabase-auth
    // - https://docs.powersync.com/installation/authentication-setup/firebase-auth

    // See example implementation here: https://pub.dev/documentation/powersync/latest/powersync/DevConnector/fetchCredentials.html
    final supabase = Supabase.instance.client;

    // 1. Obtén la sesión actual sin refrescar innecesariamente
    var session = supabase.auth.currentSession;

    // 2. Si no hay sesión, intenta un refresco (solo si es necesario)
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
      // Opcional: Proporcionar expiresAt ayuda a PowerSync a refrescar antes de que expire
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null,
    );
  }

  // Implement uploadData to send local changes to your backend service
  // You can omit this method if you only want to sync data from the server to the client
  // See example implementation here: https://docs.powersync.com/client-sdk-references/flutter#3-integrate-with-your-backend
  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    // This function is called whenever there is data to upload, whether the
    // device is online or offline.
    // If this call throws an error, it is retried periodically.

    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) {
      return;
    }
    if (transaction == null) return;

    final supabase = Supabase.instance.client;
    // The data that needs to be changed in the remote db
    for (var op in transaction.crud) {
      final table = op.table;
      // AQUÍ ESTÁ EL CAMBIO: usa opData en lugar de record
      final data = op.opData;

      data!['id'] = op.id; // <--- ESTO ES LO QUE FALTA

      // 3. Verificamos antes de enviar (para depurar)
      print("Enviando a $table el registro con ID: ${data['id']}");

      if (op.op == UpdateType.put) {
        await supabase.from(table).upsert(data);
      } else if (op.op == UpdateType.patch) {
        await supabase.from(table).update(data).eq('id', op.id);
      } else if (op.op == UpdateType.delete) {
        await supabase.from(table).delete().eq('id', op.id);
      }
    }

    // Completes the transaction and moves onto the next one
    await transaction.complete();
  }
}

class AppDatabase {
  static late PowerSyncDatabase db;
  static Future<void> initialize() async {
    // Obtener el directorio seguro en Android
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'database.sqlite');

    db = PowerSyncDatabase(schema: schema, path: path);
    await db.initialize();
    await db.connect(connector: MyBackendConnector(db));
  }
}

final schema = Schema([
  Table('roles', [
    Column.text('created_at'),
    Column.text('name'),
    Column.text('color'),
  ]),
  Table('municipios', [Column.text('created_at'), Column.text('nombre')]),
  Table('condicionPago', [Column.text('created_at'), Column.text('nombre')]),
  Table('status', [
    Column.text('created_at'),
    Column.text('nombre'),
    Column.text('color'),
  ]),
  Table('tipos', [
    Column.text('created_at'),
    Column.text('nombre'),
    Column.text('color'),
  ]),
  Table('clientes', [
    Column.text('created_at'),
    Column.text('razonSocial'),
    Column.text('nombreComercial'),
  ]),
  Table('datosPersonales', [
    Column.text('created_at'),
    Column.text('nombre'),
    Column.text('apellidoPaterno'),
    Column.text('apellidoMaterno'),
    Column.text('userId'),
    Column.integer('rolId'),
  ]),
  Table('folios', [
    Column.text('created_at'),
    Column.integer('tipoFolioId'),
    Column.integer('clienteId'),
    Column.text('cantidad'),
    Column.integer('typeRefaccionId'),
    Column.integer('condicionDePagoId'),
    Column.integer('statusId'),
    Column.text('creadorId'),
    Column.text('repartidorId'),
    Column.text('folioId'),
  ]),
  Table('historialestados', [
    Column.text('created_at'),
    Column.integer('statusId'),
    Column.text('hora'),
    Column.text('descripcion'),
    Column.text('folioId'),
  ]),
  Table('comentarios', [
    Column.text('created_at'),
    Column.text('userId'),
    Column.text('folioId'),
    Column.text('comentario'),
  ]),
  Table('direcciones', [
    Column.text('created_at'),
    Column.text('calle'),
    Column.text('colonia'),
    Column.text('codigoPostal'),
    Column.text('numExt'),
    Column.text('numInt'),
    Column.integer('municipioId'),
    Column.integer('clienteId'),
  ]),
]);
