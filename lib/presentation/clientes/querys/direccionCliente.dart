String direccionClienteQuery() {
  return '''
SELECT *, municipios.nombre as municipio FROM direcciones 
LEFT JOIN municipios on direcciones."municipioId" = municipios.id
WHERE "clienteId" = ?
  ''';
}