String listFoliosQuery() {
  return '''
SELECT 
    f.id, 
    f."folioId", 
    f.created_at,
    f.cantidad,
    t.nombre as tipofolioid,
    c."nombreComercial", 
    tr.nombre as tipoRefaccion,
    cp.nombre as "condicionPago",
    cr.nombre AS creador,
    rp.nombre AS repartidor,
    m.nombre as municipio,
    st.nombre as status,
    st.color as statusColor,
    h."folioId" as folio_id_historial
FROM folios f
  LEFT JOIN tipos as t ON f."tipoFolioId" = t.id
  LEFT JOIN clientes as c ON f."clienteId" = c.id
  LEFT JOIN tipos as tr ON f."typeRefaccionId" = tr.id
  LEFT JOIN "condicionPago" as cp ON f."condicionDePagoId" = cp.id
  LEFT JOIN "datosPersonales" cr ON f."creadorId" = cr."userId"
  LEFT JOIN "datosPersonales" rp ON f."repartidorId" = rp."userId"
  LEFT JOIN direcciones as d ON c.id = d."clienteId"
  LEFT JOIN municipios as m ON d."municipioId" = m."id"
  LEFT JOIN (
      SELECT h1.* FROM historialestados h1
      INNER JOIN (
          SELECT "folioId", MAX("created_at") as max_date 
          FROM historialestados 
          GROUP BY "folioId"
      ) h2 ON h1."folioId" = h2."folioId" AND h1."created_at" = h2.max_date
  ) as h ON f."id" = h."folioId"
  LEFT JOIN "status" st ON h."statusId" = st."id"

WHERE 
    /* 
       Ajuste a zona horaria de Monterrey (UTC-6) 
       Se desplaza la fecha de creación y la fecha actual -6 horas 
       para asegurar que coincidan en el mismo día natural local.
    */
    date(f.created_at, '-6 hours') = date('now', '-6 hours')
    
    AND (? = 1 OR (? = 2 AND (st.id IS NULL OR st.id != 3)))
''';
}