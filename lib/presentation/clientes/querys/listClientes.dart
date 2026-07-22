String listClientesQuery() {
  return '''
  SELECT 
      c.id, 
      c."nombreComercial",
      c."razonSocial",
      COALESCE(NULLIF(m."nombre", ''), 'Sin municipio') as "municipio"
    FROM "clientes" c
    LEFT JOIN "direcciones" d ON c.id = d."clienteId"
    LEFT JOIN "municipios" m ON d."municipioId" = m.id
    WHERE (? = '' 
           OR CAST(c."nombreComercial" AS TEXT) LIKE '%' || ? || '%' 
           OR CAST(c."razonSocial" AS TEXT) LIKE '%' || ? || '%');
  ''';
}