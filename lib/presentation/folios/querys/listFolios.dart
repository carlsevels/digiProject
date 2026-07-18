String listFoliosQuery() {
  return '''
SELECT 
    f.id, f."folioId", f.created_at, f.cantidad,
    t.nombre AS tipofolioid,
    c."nombreComercial",
    tr.nombre AS tipoRefaccion,
    cp.nombre AS "condicionPago",
    cr.nombre AS creador,
    rp.nombre AS repartidor,
    m.nombre AS municipio,
    st.nombre AS status,
    st.color AS statusColor
FROM folios f
LEFT JOIN tipos t ON f."tipoFolioId" = t.id
LEFT JOIN clientes c ON f."clienteId" = c.id
LEFT JOIN tipos tr ON f."typeRefaccionId" = tr.id
LEFT JOIN "condicionPago" cp ON f."condicionDePagoId" = cp.id
LEFT JOIN "datosPersonales" cr ON f."creadorId" = cr."userId"
LEFT JOIN "datosPersonales" rp ON f."repartidorId" = rp."userId"
LEFT JOIN direcciones d ON c.id = d."clienteId"
LEFT JOIN municipios m ON d."municipioId" = m.id
LEFT JOIN (
    SELECT h1.*
    FROM historialestados h1
    INNER JOIN (
        SELECT "folioId", MAX(created_at) AS max_date
        FROM historialestados
        GROUP BY "folioId"
    ) h2 ON h1."folioId" = h2."folioId" AND h1.created_at = h2.max_date
) h ON f.id = h."folioId"
LEFT JOIN status st ON h."statusId" = st.id
WHERE
    TRIM(f.created_at) = TRIM(?)
    AND (
        ? = 1  -- Si es admin, esta condición es verdadera y se muestran todos
        OR 
        (st.id != 3 OR st.id IS NULL) -- Si no es admin, filtra el status 3
    )
''';
}