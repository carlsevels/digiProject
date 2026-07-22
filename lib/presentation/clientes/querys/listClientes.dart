String listClientesQuery() {
  return '''
  SELECT 
      c.id, 
      c."nombreComercial",
      m."nombre" as "municipio"
    FROM "clientes" c
    LEFT JOIN "direcciones" d ON c.id = d."clienteId"
    LEFT JOIN "municipios" m ON d."municipioId" = m.id
  ''';
}
