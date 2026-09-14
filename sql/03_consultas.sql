-- ============================================================
-- Preguntas de negocio
-- Organizadas de lo más básico a lo más avanzado. Cada consulta
-- responde a una pregunta concreta que haría un stakeholder real.
-- ============================================================

USE tienda_online;

-- ============================================================
-- SECCIÓN 1 — Agregaciones y joins básicos
-- ============================================================

-- P1. ¿Cuál es el ingreso total, el número de pedidos y el ticket
--     medio para los pedidos completados?
SELECT
    COUNT(DISTINCT p.pedido_id)                       AS total_pedidos,
    ROUND(SUM(lp.cantidad * lp.precio_unitario), 2)   AS ingresos_totales,
    ROUND(SUM(lp.cantidad * lp.precio_unitario) / COUNT(DISTINCT p.pedido_id), 2) AS ticket_medio
FROM pedidos p
JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
WHERE p.estado = 'completado';

-- P2. Ingresos y número de pedidos por categoría, ordenados por ingresos.
SELECT
    c.nombre_categoria,
    COUNT(DISTINCT p.pedido_id)                     AS pedidos,
    SUM(lp.cantidad)                                AS unidades_vendidas,
    ROUND(SUM(lp.cantidad * lp.precio_unitario), 2) AS ingresos
FROM lineas_pedido lp
JOIN pedidos p       ON p.pedido_id = lp.pedido_id
JOIN productos pr    ON pr.producto_id = lp.producto_id
JOIN categorias c    ON c.categoria_id = pr.categoria_id
WHERE p.estado = 'completado'
GROUP BY c.nombre_categoria
ORDER BY ingresos DESC;

-- P3. Top 10 productos por ingresos, incluyendo el margen porcentual.
SELECT
    pr.nombre_producto,
    SUM(lp.cantidad)                                                    AS unidades_vendidas,
    ROUND(SUM(lp.cantidad * lp.precio_unitario), 2)                     AS ingresos,
    ROUND(SUM(lp.cantidad * (lp.precio_unitario - pr.coste_unitario)), 2) AS beneficio_bruto,
    ROUND(100 * SUM(lp.cantidad * (lp.precio_unitario - pr.coste_unitario)) / SUM(lp.cantidad * lp.precio_unitario), 1) AS margen_pct
FROM lineas_pedido lp
JOIN pedidos p    ON p.pedido_id = lp.pedido_id
JOIN productos pr ON pr.producto_id = lp.producto_id
WHERE p.estado = 'completado'
GROUP BY pr.producto_id, pr.nombre_producto
ORDER BY ingresos DESC
LIMIT 10;

-- P4. ¿Qué comunidad autónoma genera más ingresos por cliente (no solo
--     en total, esto normaliza por tamaño de mercado)?
SELECT
    cl.comunidad_autonoma,
    COUNT(DISTINCT cl.cliente_id)                   AS clientes,
    ROUND(SUM(lp.cantidad * lp.precio_unitario), 2) AS ingresos,
    ROUND(SUM(lp.cantidad * lp.precio_unitario) / COUNT(DISTINCT cl.cliente_id), 2) AS ingresos_por_cliente
FROM clientes cl
JOIN pedidos p        ON p.cliente_id = cl.cliente_id AND p.estado = 'completado'
JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
GROUP BY cl.comunidad_autonoma
ORDER BY ingresos_por_cliente DESC;

-- ============================================================
-- SECCIÓN 2 — Análisis de series temporales
-- ============================================================

-- P5. Evolución mensual de ingresos.
SELECT
    DATE_FORMAT(p.fecha_pedido, '%Y-%m')            AS mes,
    ROUND(SUM(lp.cantidad * lp.precio_unitario), 2) AS ingresos
FROM pedidos p
JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
WHERE p.estado = 'completado'
GROUP BY mes
ORDER BY mes;

-- P6. Tasa de crecimiento mensual de ingresos usando LAG().
WITH ingresos_mensuales AS (
    SELECT
        DATE_FORMAT(p.fecha_pedido, '%Y-%m')            AS mes,
        SUM(lp.cantidad * lp.precio_unitario)           AS ingresos
    FROM pedidos p
    JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
    WHERE p.estado = 'completado'
    GROUP BY mes
)
SELECT
    mes,
    ROUND(ingresos, 2) AS ingresos,
    ROUND(ingresos - LAG(ingresos) OVER (ORDER BY mes), 2) AS variacion_ingresos,
    ROUND(100 * (ingresos - LAG(ingresos) OVER (ORDER BY mes)) / LAG(ingresos) OVER (ORDER BY mes), 1) AS crecimiento_pct_mes_anterior
FROM ingresos_mensuales
ORDER BY mes;

-- P7. Ingresos acumulados (running total) a lo largo de todo el periodo.
WITH ingresos_mensuales AS (
    SELECT
        DATE_FORMAT(p.fecha_pedido, '%Y-%m') AS mes,
        SUM(lp.cantidad * lp.precio_unitario) AS ingresos
    FROM pedidos p
    JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
    WHERE p.estado = 'completado'
    GROUP BY mes
)
SELECT
    mes,
    ROUND(ingresos, 2) AS ingresos,
    ROUND(SUM(ingresos) OVER (ORDER BY mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS ingresos_acumulados
FROM ingresos_mensuales
ORDER BY mes;

-- P8. Retención por cohorte de alta: de los clientes que se dieron
--     de alta en un mes concreto, ¿qué % hizo un pedido en cada uno
--     de los siguientes meses?
WITH cohortes AS (
    SELECT cliente_id, DATE_FORMAT(fecha_alta, '%Y-%m') AS mes_cohorte
    FROM clientes
),
actividad AS (
    SELECT
        c.mes_cohorte,
        c.cliente_id,
        TIMESTAMPDIFF(MONTH, STR_TO_DATE(CONCAT(c.mes_cohorte,'-01'), '%Y-%m-%d'), p.fecha_pedido) AS mes_relativo
    FROM cohortes c
    JOIN pedidos p ON p.cliente_id = c.cliente_id AND p.estado = 'completado'
)
SELECT
    mes_cohorte,
    mes_relativo,
    COUNT(DISTINCT cliente_id) AS clientes_activos
FROM actividad
WHERE mes_relativo BETWEEN 0 AND 6
GROUP BY mes_cohorte, mes_relativo
ORDER BY mes_cohorte, mes_relativo;

-- ============================================================
-- SECCIÓN 3 — Segmentación de clientes (RFM) y rankings
-- ============================================================

-- P9. Segmentación RFM: Recencia (días desde el último pedido),
--     Frecuencia (número de pedidos) y Valor Monetario (gasto total)
--     por cliente, puntuados en cuartiles con NTILE y combinados
--     en una etiqueta de segmento.
WITH pedidos_cliente AS (
    SELECT
        cl.cliente_id,
        CONCAT(cl.nombre, ' ', cl.apellidos) AS nombre_cliente,
        DATEDIFF((SELECT MAX(fecha_pedido) FROM pedidos), MAX(p.fecha_pedido)) AS dias_desde_ultimo_pedido,
        COUNT(DISTINCT p.pedido_id) AS frecuencia,
        SUM(lp.cantidad * lp.precio_unitario) AS valor_monetario
    FROM clientes cl
    JOIN pedidos p        ON p.cliente_id = cl.cliente_id AND p.estado = 'completado'
    JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
    GROUP BY cl.cliente_id, nombre_cliente
),
puntuado AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY dias_desde_ultimo_pedido DESC) AS puntuacion_r,  -- menos días = más reciente = puntuación más alta
        NTILE(4) OVER (ORDER BY frecuencia ASC)                 AS puntuacion_f,
        NTILE(4) OVER (ORDER BY valor_monetario ASC)            AS puntuacion_m
    FROM pedidos_cliente
)
SELECT
    cliente_id,
    nombre_cliente,
    dias_desde_ultimo_pedido,
    frecuencia,
    ROUND(valor_monetario, 2) AS valor_monetario,
    puntuacion_r, puntuacion_f, puntuacion_m,
    CASE
        WHEN puntuacion_r >= 3 AND puntuacion_f >= 3 AND puntuacion_m >= 3 THEN 'Campeón'
        WHEN puntuacion_r >= 3 AND puntuacion_f <= 2 THEN 'Nuevo / Prometedor'
        WHEN puntuacion_r <= 2 AND puntuacion_f >= 3 AND puntuacion_m >= 3 THEN 'En riesgo (alto valor)'
        WHEN puntuacion_r <= 2 AND puntuacion_f <= 2 THEN 'Perdido / Fugado'
        ELSE 'Regular'
    END AS segmento
FROM puntuado
ORDER BY valor_monetario DESC;

-- P10. Top 3 clientes por gasto dentro de cada comunidad autónoma,
--      usando RANK() para que los empates compartan posición (función
--      de ventana particionada).
WITH gasto_cliente AS (
    SELECT
        cl.comunidad_autonoma,
        cl.cliente_id,
        CONCAT(cl.nombre, ' ', cl.apellidos) AS nombre_cliente,
        SUM(lp.cantidad * lp.precio_unitario) AS gasto_total
    FROM clientes cl
    JOIN pedidos p        ON p.cliente_id = cl.cliente_id AND p.estado = 'completado'
    JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
    GROUP BY cl.comunidad_autonoma, cl.cliente_id, nombre_cliente
),
clasificado AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY comunidad_autonoma ORDER BY gasto_total DESC) AS posicion_gasto
    FROM gasto_cliente
)
SELECT comunidad_autonoma, nombre_cliente, ROUND(gasto_total, 2) AS gasto_total, posicion_gasto
FROM clasificado
WHERE posicion_gasto <= 3
ORDER BY comunidad_autonoma, posicion_gasto;

-- P11. Clientes que no han hecho ningún pedido en los últimos 90 días
--      (respecto al pedido más reciente del histórico) — una lista
--      de riesgo de fuga, usando una subconsulta correlacionada.
SELECT
    cl.cliente_id,
    CONCAT(cl.nombre, ' ', cl.apellidos) AS nombre_cliente,
    cl.email,
    (SELECT MAX(p.fecha_pedido) FROM pedidos p WHERE p.cliente_id = cl.cliente_id) AS fecha_ultimo_pedido,
    DATEDIFF((SELECT MAX(fecha_pedido) FROM pedidos), (SELECT MAX(p.fecha_pedido) FROM pedidos p WHERE p.cliente_id = cl.cliente_id)) AS dias_sin_comprar
FROM clientes cl
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = cl.cliente_id)
HAVING dias_sin_comprar > 90
ORDER BY dias_sin_comprar DESC;

-- ============================================================
-- SECCIÓN 4 — Análisis de producto y devoluciones
-- ============================================================

-- P12. Tasa de devolución por categoría: unidades devueltas /
--      unidades vendidas. Saca a la luz problemas de calidad que
--      unas ventas brutas altas podrían estar ocultando.
SELECT
    c.nombre_categoria,
    SUM(lp.cantidad)                                          AS unidades_vendidas,
    COUNT(d.devolucion_id)                                    AS unidades_devueltas,
    ROUND(100 * COUNT(d.devolucion_id) / SUM(lp.cantidad), 2) AS tasa_devolucion_pct
FROM lineas_pedido lp
JOIN pedidos p              ON p.pedido_id = lp.pedido_id
JOIN productos pr           ON pr.producto_id = lp.producto_id
JOIN categorias c           ON c.categoria_id = pr.categoria_id
LEFT JOIN devoluciones d     ON d.linea_pedido_id = lp.linea_pedido_id
WHERE p.estado IN ('completado','reembolsado')
GROUP BY c.nombre_categoria
ORDER BY tasa_devolucion_pct DESC;

-- P13. Productos de margen alto pero baja rotación: buen margen
--      pero en la mitad inferior de unidades vendidas — candidatos
--      para una promoción.
WITH estadisticas_producto AS (
    SELECT
        pr.producto_id,
        pr.nombre_producto,
        c.nombre_categoria,
        ROUND(100 * (pr.precio_unitario - pr.coste_unitario) / pr.precio_unitario, 1) AS margen_pct,
        COALESCE(SUM(lp.cantidad), 0) AS unidades_vendidas
    FROM productos pr
    JOIN categorias c ON c.categoria_id = pr.categoria_id
    LEFT JOIN lineas_pedido lp ON lp.producto_id = pr.producto_id
    LEFT JOIN pedidos p        ON p.pedido_id = lp.pedido_id AND p.estado = 'completado'
    GROUP BY pr.producto_id, pr.nombre_producto, c.nombre_categoria, margen_pct
)
SELECT *
FROM estadisticas_producto
WHERE margen_pct >= (SELECT AVG(margen_pct) FROM estadisticas_producto)
  AND unidades_vendidas <= (SELECT AVG(unidades_vendidas) FROM estadisticas_producto)
ORDER BY margen_pct DESC;

-- P14. Productos que nunca han sido devueltos y han vendido al menos
--      20 unidades — bestsellers fiables dignos de destacar.
SELECT
    pr.nombre_producto,
    SUM(lp.cantidad) AS unidades_vendidas
FROM lineas_pedido lp
JOIN productos pr ON pr.producto_id = lp.producto_id
JOIN pedidos p    ON p.pedido_id = lp.pedido_id AND p.estado = 'completado'
WHERE pr.producto_id NOT IN (
    SELECT DISTINCT lp2.producto_id
    FROM lineas_pedido lp2
    JOIN devoluciones d ON d.linea_pedido_id = lp2.linea_pedido_id
)
GROUP BY pr.producto_id, pr.nombre_producto
HAVING unidades_vendidas >= 20
ORDER BY unidades_vendidas DESC;

-- ============================================================
-- SECCIÓN 5 — Objetos reutilizables: vista, procedimiento e índice
-- ============================================================

-- P15. Una vista que expone el valor de vida del cliente (LTV), para
--      que herramientas de BI o analistas puedan consultarla
--      directamente sin repetir los joins.
CREATE OR REPLACE VIEW vista_valor_vida_cliente AS
SELECT
    cl.cliente_id,
    CONCAT(cl.nombre, ' ', cl.apellidos) AS nombre_cliente,
    cl.comunidad_autonoma,
    cl.fecha_alta,
    COUNT(DISTINCT p.pedido_id)                        AS pedidos_totales,
    COALESCE(SUM(lp.cantidad * lp.precio_unitario), 0) AS valor_vida_cliente
FROM clientes cl
LEFT JOIN pedidos p        ON p.cliente_id = cl.cliente_id AND p.estado = 'completado'
LEFT JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
GROUP BY cl.cliente_id, nombre_cliente, cl.comunidad_autonoma, cl.fecha_alta;

-- uso:
SELECT * FROM vista_valor_vida_cliente ORDER BY valor_vida_cliente DESC LIMIT 10;

-- P16. Procedimiento almacenado: historial completo de pedidos de un
--      cliente, parametrizado — el tipo de consulta reutilizable que
--      usaría un equipo de soporte o un dashboard interno.
DELIMITER $$

CREATE PROCEDURE obtener_historial_pedidos_cliente(IN p_cliente_id INT)
BEGIN
    SELECT
        p.pedido_id,
        p.fecha_pedido,
        p.estado,
        pr.nombre_producto,
        lp.cantidad,
        lp.precio_unitario,
        ROUND(lp.cantidad * lp.precio_unitario, 2) AS importe_linea
    FROM pedidos p
    JOIN lineas_pedido lp ON lp.pedido_id = p.pedido_id
    JOIN productos pr     ON pr.producto_id = lp.producto_id
    WHERE p.cliente_id = p_cliente_id
    ORDER BY p.fecha_pedido DESC;
END$$

DELIMITER ;

-- uso:
CALL obtener_historial_pedidos_cliente(1);

-- P17. Comprobación con EXPLAIN de que el índice compuesto definido
--      en 01_schema.sql (idx_pedidos_cliente_fecha) se usa realmente
--      para el patrón de consulta del historial de cliente anterior,
--      en lugar de hacer un escaneo completo de la tabla.
EXPLAIN SELECT * FROM pedidos WHERE cliente_id = 1 ORDER BY fecha_pedido DESC;
