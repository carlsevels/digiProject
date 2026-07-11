// Ejemplo de cómo suele verse la configuración
import 'dart:convert';

import 'package:powersync/powersync.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBackendConnector extends PowerSyncBackendConnector {
  PowerSyncDatabase db;

  MyBackendConnector(this.db);
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Implement fetchCredentials to obtain a JWT from your authentication service
    // If you're using Supabase or Firebase, you can re-use the JWT from those clients, see
    // - https://docs.powersync.com/installation/authentication-setup/supabase-auth
    // - https://docs.powersync.com/installation/authentication-setup/firebase-auth
    final supabase = Supabase.instance.client;
    // Forzamos el refresco para obtener un token nuevo compatible
    final session = await supabase.auth.refreshSession();
    final token = session.session!.accessToken;
    final parts = token.split('.');
    final header = String.fromCharCodes(
      base64Decode(base64.normalize(parts[0])),
    );
    print("HEADER DEL TOKEN: $header");
    if (session.session == null) return null;

    return PowerSyncCredentials(
      endpoint: "https://6a4e6c7849dca2d8a417eda2.powersync.journeyapps.com",
      token: session.session!.accessToken,
    );
  }

  // Implement uploadData to send local changes to your backend servicenull;
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

    // The data that needs to be changed in the remote db
    for (var op in transaction.crud) {
      switch (op.op) {
        case UpdateType.put:
        // TODO: Instruct your backend API to CREATE a record
        case UpdateType.patch:
        // TODO: Instruct your backend API to PATCH a record
        case UpdateType.delete:
        //TODO: Instruct your backend API to DELETE a record
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
    Column.integer('entregaId'),
  ]),
  Table('clientes', [
    Column.text('created_at'),
    Column.text('razonSocial'),
    Column.text('nombreComercial'),
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
  Table('comentarios', [
    Column.text('created_at'),
    Column.text('userId'),
    Column.integer('folioId'),
    Column.text('comentario'),
  ]),
  Table('entregas', [
    Column.text('created_at'),
    Column.text('horaInicial'),
    Column.text('llegada'),
    Column.text('salida'),
    Column.text('fechaEntrega'),
    Column.text('recibidoPor'),
  ]),
]);
