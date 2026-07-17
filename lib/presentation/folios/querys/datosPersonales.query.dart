String datosPersonalesQuery() {
  return '''
SELECT * FROM "datosPersonales" WHERE "userId" = ?
''';
}
