String getHistorialFolio() {
  return '''
SELECT 
  h."id",
  h."folioId", 
  h."statusId", 
  h."created_at",
  s."nombre" AS status,       
  s."color" AS statuscolor    
FROM historialestados as h
INNER JOIN status AS s ON h."statusId" = s.id
WHERE h."folioId" = ?
ORDER BY h."created_at" DESC
''';
}