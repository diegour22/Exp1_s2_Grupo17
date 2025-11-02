-- =============================================================
-- EXP1 - Semana 2: Uso de Funciones SQL
-- Grupo : 17
-- Asignatura : Consulta Base de Datos (PRY2205)
-- Institución : Duoc UC
-- Fecha : 2025-11-01
-- =============================================================


-- =============================================================
-- CASO 1 : Análisis de Facturas
-- =============================================================

SELECT
    LPAD(rut_cliente, 10, '0') AS RUT_CLIENTE,
    TO_CHAR(fecha_factura, 'DD/MM/YYYY') AS FECHA_FACTURA,
    ROUND(monto_neto, 0) AS MONTO_NETO,
    CASE
        WHEN monto_neto <= 50000 THEN 'Bajo'
        WHEN monto_neto <= 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS CLASIFICACION_MONTO,
    CASE codigo_pago
        WHEN 1 THEN 'Efectivo'
        WHEN 2 THEN 'Tarjeta Débito'
        WHEN 3 THEN 'Tarjeta Crédito'
        ELSE 'Otro'
    END AS FORMA_PAGO,
    NVL(observaciones, 'SIN_COMENTARIOS') AS OBSERVACIONES
FROM FACTURA
WHERE EXTRACT(YEAR FROM fecha_factura) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY fecha_factura DESC, monto_neto DESC;



-- =============================================================
-- CASO 2 : Clasificación de Clientes
-- =============================================================

SELECT
    nombre_cliente AS NOMBRE,
    REVERSE(rut_cliente) AS RUT_INVERSO,
    NVL(telefono, 'Sin teléfono') AS TELEFONO,
    NVL(comuna, 'Sin comuna') AS COMUNA,
    NVL(correo, 'Sin correo') AS CORREO,
    CASE
        WHEN INSTR(correo, '@') > 0 THEN SUBSTR(correo, INSTR(correo, '@') + 1)
        ELSE 'SIN_DOMINIO'
    END AS DOMINIO_CORREO,
    CASE
        WHEN credito > 0 AND (saldo / credito) < 0.5 THEN 'Bueno'
        WHEN credito > 0 AND (saldo / credito) BETWEEN 0.5 AND 0.8 THEN 'Regular'
        WHEN credito > 0 AND (saldo / credito) > 0.8 THEN 'Crítico'
        ELSE 'Sin datos'
    END AS ESTADO_CREDITO,
    CASE
        WHEN credito > 0 AND (saldo / credito) < 0.5 THEN TO_CHAR(credito - saldo, 'FM999G999D00')
        WHEN credito > 0 AND (saldo / credito) BETWEEN 0.5 AND 0.8 THEN TO_CHAR(saldo, 'FM999G999D00')
        WHEN credito > 0 AND (saldo / credito) > 0.8 THEN 'CRITICO'
        ELSE 'N/A'
    END AS VALOR
FROM CLIENTE
WHERE estado = 'A'
ORDER BY nombre_cliente;



-- =============================================================
-- CASO 3 : Stock de Productos
-- =============================================================

SELECT
    id_producto,
    descripcion,
    NVL(TO_CHAR(valor_compra_usd, 'FM999G999D00'), 'Sin registro') AS VALOR_USD,
    CASE
        WHEN valor_compra_usd IS NULL THEN 'Sin registro'
        ELSE TO_CHAR(valor_compra_usd * &TIPOCAMBIO_DOLAR, 'FM999G999D00')
    END AS VALOR_CLP,
    totalstock,
    CASE
        WHEN totalstock IS NULL THEN 'Sin datos'
        WHEN totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN totalstock BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        WHEN totalstock > &UMBRAL_ALTO THEN 'Stock OK'
        ELSE 'Revisar'
    END AS ALERTA,
    CASE
        WHEN totalstock > 80 THEN TO_CHAR(precio_unitario * 0.1, 'FM999G999D00')
        ELSE '0'
    END AS DESCUENTO,
    TO_CHAR(
        precio_unitario -
        CASE WHEN totalstock > 80 THEN precio_unitario * 0.1 ELSE 0 END,
        'FM999G999D00'
    ) AS PRECIO_FINAL
FROM PRODUCTO
WHERE LOWER(descripcion) LIKE '%zapato%'
AND procedencia = 'i'
ORDER BY id_producto DESC;
