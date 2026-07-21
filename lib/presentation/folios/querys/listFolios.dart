String listFoliosQuery() {
  return '''
SELECT
    f.id,
    f."folioId",
    f."created_at",
    f."cantidad",
    f."isArchived",
    t.nombre AS tipofolio,
    c."nombreComercial",
    tr.nombre AS tipoRefaccion,
    cp.nombre AS "condicionPago",
    cr.nombre AS creador,
    rp.nombre AS repartidor,
    m.nombre AS municipio,
    st.nombre AS status,
    st.id AS statusid,
    st.color AS statuscolor
FROM folios f

LEFT JOIN tipos t
    ON f."tipoFolioId" = t.id

LEFT JOIN clientes c
    ON f."clienteId" = c.id

LEFT JOIN tipos tr
    ON f."typeRefaccionId" = tr.id

LEFT JOIN "condicionPago" cp
    ON f."condicionDePagoId" = cp.id

LEFT JOIN "datosPersonales" cr
    ON f."creadorId" = cr."userId"

LEFT JOIN "datosPersonales" rp
    ON f."repartidorId" = rp."userId"

LEFT JOIN direcciones d
    ON d."clienteId" = c.id

LEFT JOIN municipios m
    ON m.id = d."municipioId"

LEFT JOIN historialestados h
    ON h.id = (
        SELECT h2.id
        FROM historialestados h2
        WHERE h2."folioId" = f.id
        ORDER BY h2."created_at" DESC
        LIMIT 1
    )

LEFT JOIN status st
    ON st.id = h."statusId"

WHERE
    DATE(f."created_at") = DATE(?)
    AND (
        ? = 1
        OR st.id IS NULL
        OR st.id <> 3
    )
    AND f."isArchived" = FALSE

ORDER BY f."created_at" DESC;
''';
}