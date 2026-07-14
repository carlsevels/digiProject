//Obtiene la lista de folios del dia de hoy
String folioId() {
  return '''
   SELECT 
f.id, 
f."folioId", 
f.created_at,
f.cantidad,
t.nombre as tipoFolio,
c."nombreComercial", 
tr.nombre as tipoRefaccion,
cp.nombre as "condicionPago",
s.nombre as status,
cr.nombre AS creador,
rp.nombre AS repartidor,
m.nombre as municipio,
s.color as statusColor
FROM folios f
  INNER JOIN tipos as t ON f."tipoFolioId" = t.id
  INNER JOIN clientes as c ON f."clienteId" = c.id
  INNER JOIN tipos as tr ON f."typeRefaccionId" = tr.id
  INNER JOIN "condicionPago" as cp ON f."condicionDePagoId" = cp.id
  INNER JOIN status as s ON f."statusId" = s.id
  INNER JOIN "datosPersonales" cr ON f."creadorId" = cr."userId"
  INNER JOIN "datosPersonales" rp ON f."repartidorId" = rp."userId"
  INNER JOIN direcciones as d ON c.id = d."clienteId"
  INNER JOIN municipios as m ON d."municipioId" = m."id"
WHERE f.id = ?
    ''';
}
