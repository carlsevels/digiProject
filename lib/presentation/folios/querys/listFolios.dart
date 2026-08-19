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
    d."calle",
    d."colonia",
    d."codigoPostal",
    d."numExt",
    d."numInt",
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

LEFT JOIN (
    SELECT "folioId", "statusId"
    FROM (
        SELECT 
            h2."folioId", 
            h2."statusId",
            ROW_NUMBER() OVER(PARTITION BY h2."folioId" ORDER BY h2."created_at" DESC) as rn
        FROM historialestados h2
    ) sub
    WHERE sub.rn = 1
) ultimo_estado ON ultimo_estado."folioId" = f.id

LEFT JOIN status st
    ON st.id = ultimo_estado."statusId"

WHERE
    DATE(f."created_at") = DATE(?)
    AND f."isArchived" = FALSE

ORDER BY f."created_at" DESC;
''';
}