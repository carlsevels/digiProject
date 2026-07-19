String listClientesQuery() {
  return '''
    SELECT 
      c.id, 
      c."nombreComercial", 
      c."razonSocial", 
      c."created_at",
      d."calle" as "dirCalle", 
      d."colonia" as "dirColonia", 
      d."codigoPostal" as "dirCp",
      d."numExt" as "dirNumExt",
      d."numInt" as "dirNumInt",
      m."nombre" as "nombreMunicipio"
    FROM "clientes" c
    LEFT JOIN "direcciones" d ON c.id = d."clienteId"
    LEFT JOIN "municipios" m ON d."municipioId" = m.id
  ''';
}
