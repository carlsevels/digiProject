String insertStatusFolio() {
  return '''
INSERT INTO historialestados (id, "folioId", "statusId", "created_at")
VALUES (?, ?, ?, ?);
''';
}
