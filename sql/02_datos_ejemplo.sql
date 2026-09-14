-- ============================================================
-- Datos sintéticos de ejemplo
-- Genera ~500 clientes, ~110 productos, ~6.000 pedidos,
-- ~14.000 líneas de pedido, pagos coherentes y ~4% de devoluciones.
-- Todo en SQL puro (sin scripts externos), para que el proyecto
-- completo se reproduzca ejecutando estos archivos con `mysql < `.
-- ============================================================

USE tienda_online;

-- ------------------------------------------------------------
-- 1. Categorías
-- ------------------------------------------------------------

INSERT INTO categorias (nombre_categoria) VALUES
('Electrónica'), ('Hogar y Cocina'), ('Deporte y Aire Libre'), ('Libros'),
('Belleza y Cuidado Personal'), ('Juguetes y Juegos'), ('Moda'), ('Alimentación'),
('Material de Oficina'), ('Mascotas');

-- ------------------------------------------------------------
-- 2. Productos (nombres curados a mano para que el catálogo
--    parezca una tienda real, no "Producto 001")
-- ------------------------------------------------------------

INSERT INTO productos (categoria_id, nombre_producto, coste_unitario, precio_unitario, fecha_lanzamiento) VALUES
-- Electrónica
(1,'Auriculares Inalámbricos con Cancelación de Ruido', 48.00, 129.99, '2022-01-15'),
(1,'Reproductor de Streaming 4K',                       14.00,  39.99, '2021-11-01'),
(1,'Altavoz Bluetooth Portátil',                        18.00,  49.99, '2022-03-10'),
(1,'Cargador Rápido USB-C 65W',                          9.00,  24.99, '2021-06-20'),
(1,'Reloj Inteligente con Monitor de Actividad',        35.00,  89.99, '2022-05-01'),
(1,'Teclado Mecánico para Gaming',                      30.00,  79.99, '2021-09-15'),
(1,'Ratón Inalámbrico Ergonómico',                      10.00,  27.99, '2021-09-15'),
(1,'Monitor 27" 2K',                                   110.00, 249.99, '2022-02-01'),
(1,'Robot Aspirador',                                  140.00, 299.99, '2022-07-01'),
(1,'Cámara de Acción 4K',                               55.00, 149.99, '2021-12-01'),
(1,'Batería Externa 20000mAh',                          12.00,  34.99, '2021-08-10'),
(1,'Tira de LED Inteligente',                            8.00,  22.99, '2022-04-01'),
-- Hogar y Cocina
(2,'Set de Ollas de Acero Inoxidable',                  55.00, 139.99, '2021-05-01'),
(2,'Freidora de Aire 5,5L',                             40.00,  99.99, '2022-01-10'),
(2,'Hervidor de Agua Eléctrico',                        12.00,  29.99, '2021-04-01'),
(2,'Almohada Viscoelástica',                             9.00,  24.99, '2021-03-15'),
(2,'Cortinas Opacas (Par)',                             14.00,  36.99, '2021-10-01'),
(2,'Sartén Antiadherente 28cm',                         10.00,  26.99, '2021-06-01'),
(2,'Cafetera de Goteo 12 Tazas',                        28.00,  69.99, '2022-02-15'),
(2,'Set de Tablas de Cortar de Bambú',                   8.00,  21.99, '2021-07-01'),
(2,'Vajilla de Cerámica (16 piezas)',                   32.00,  84.99, '2021-11-20'),
(2,'Aspiradora de Mano Inalámbrica',                    35.00,  89.99, '2022-06-01'),
-- Deporte y Aire Libre
(3,'Esterilla de Yoga Premium',                          8.00,  22.99, '2021-01-10'),
(3,'Set de Mancuernas Ajustables',                      60.00, 149.99, '2021-09-01'),
(3,'Botella de Agua Térmica 1L',                         5.00,  16.99, '2021-02-01'),
(3,'Tienda de Campaña 4 Personas',                      65.00, 159.99, '2022-03-01'),
(3,'Set de Bandas de Resistencia',                       6.00,  17.99, '2021-05-15'),
(3,'Zapatillas de Running',                             35.00,  89.99, '2021-08-01'),
(3,'Mochila de Senderismo Plegable 40L',                25.00,  64.99, '2022-04-15'),
(3,'Casco de Ciclismo',                                 18.00,  44.99, '2021-06-15'),
(3,'Comba de Velocidad',                                 3.00,   9.99, '2021-01-20'),
-- Libros
(4,'Hábitos Atómicos (Tapa blanda)',                     5.00,  14.99, '2021-01-01'),
(4,'Psicología del Dinero',                              5.00,  13.99, '2021-02-01'),
(4,'SQL para Análisis de Datos (Guía)',                  6.00,  19.99, '2021-06-01'),
(4,'Novela de Fantasía Moderna Vol. 1',                  4.00,  12.99, '2021-04-01'),
(4,'Set de Cuentos Ilustrados Infantiles',               7.00,  18.99, '2021-09-01'),
(4,'Historia Universal Ilustrada',                       8.00,  22.99, '2021-11-01'),
-- Belleza y Cuidado Personal
(5,'Sérum de Vitamina C 30ml',                           4.00,  18.99, '2021-03-01'),
(5,'Cepillo de Dientes Eléctrico',                      14.00,  39.99, '2021-07-01'),
(5,'Secador de Pelo Iónico',                            20.00,  49.99, '2021-10-01'),
(5,'Crema Facial Hidratante',                            5.00,  17.99, '2021-05-01'),
(5,'Kit de Arreglo de Barba',                            9.00,  24.99, '2022-01-01'),
(5,'Afeitadora Eléctrica',                              18.00,  44.99, '2021-12-15'),
-- Juguetes y Juegos
(6,'Set de Bloques de Construcción 500pz',              14.00,  34.99, '2021-04-01'),
(6,'Coche Teledirigido',                                16.00,  39.99, '2021-10-15'),
(6,'Juego de Mesa Estrategia Clásico',                  10.00,  27.99, '2021-08-01'),
(6,'Puzzle 1000 Piezas Paisaje',                          5.00,  14.99, '2021-06-01'),
(6,'Peluche Oso Grande',                                  6.00,  17.99, '2021-02-15'),
-- Moda
(7,'Vaqueros Ajustados de Hombre',                      15.00,  44.99, '2021-03-01'),
(7,'Vestido Floral de Verano de Mujer',                 12.00,  39.99, '2021-05-01'),
(7,'Sudadera Unisex de Algodón',                        10.00,  32.99, '2021-09-01'),
(7,'Cartera de Piel',                                    7.00,  24.99, '2021-11-01'),
(7,'Gafas de Sol Polarizadas',                           6.00,  22.99, '2021-06-15'),
(7,'Chaqueta de Plumas de Invierno',                    28.00,  79.99, '2021-10-01'),
-- Alimentación
(8,'Café en Grano Ecológico 1kg',                        7.00,  16.99, '2021-01-05'),
(8,'Aceite de Oliva Virgen Extra 1L',                    6.00,  15.99, '2021-01-05'),
(8,'Proteína en Polvo Chocolate 1kg',                   18.00,  39.99, '2021-07-15'),
(8,'Pack de Frutos Secos Variados 500g',                 5.00,  12.99, '2021-02-10'),
(8,'Bolsitas de Té Verde (100u)',                        3.00,   9.99, '2021-03-05'),
-- Material de Oficina
(9,'Silla de Oficina Ergonómica',                       70.00, 179.99, '2021-08-15'),
(9,'Elevador de Escritorio Convertible',                55.00, 139.99, '2022-01-05'),
(9,'Set de Libretas A5 (3 uds)',                          3.00,   9.99, '2021-01-15'),
(9,'Mando Presentador Inalámbrico',                      6.00,  17.99, '2021-05-10'),
(9,'Organizador de Escritorio de Bambú',                 8.00,  21.99, '2021-06-05'),
-- Mascotas
(10,'Juguete Masticable para Perro',                     3.00,   9.99, '2021-02-20'),
(10,'Rascador para Gatos',                              14.00,  34.99, '2021-04-10'),
(10,'Cepillo de Aseo para Mascotas',                     4.00,  12.99, '2021-05-20'),
(10,'Comedero Automático para Mascotas',                22.00,  54.99, '2021-11-05'),
(10,'Correa Reflectante para Perro',                     5.00,  14.99, '2021-03-20');

-- ------------------------------------------------------------
-- 3. Clientes — generados de forma procedural para tener volumen,
--    con un reparto realista de ciudades y comunidades autónomas
--    españolas, y fechas de alta repartidas en ~2,5 años para que
--    las consultas de cohortes y retención tengan algo que mostrar.
-- ------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE generar_clientes(IN n INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE ciudades_comunidades VARCHAR(2000) DEFAULT CONCAT(
        'Madrid|Comunidad de Madrid,Barcelona|Cataluña,Valencia|Comunidad Valenciana,',
        'Sevilla|Andalucía,Málaga|Andalucía,Granada|Andalucía,Zaragoza|Aragón,',
        'Bilbao|País Vasco,Vitoria-Gasteiz|País Vasco,San Sebastián|País Vasco,',
        'Murcia|Región de Murcia,Palma de Mallorca|Illes Balears,Las Palmas de Gran Canaria|Canarias,',
        'Santa Cruz de Tenerife|Canarias,Vigo|Galicia,A Coruña|Galicia,Gijón|Asturias,',
        'Oviedo|Asturias,Santander|Cantabria,Pamplona|Comunidad Foral de Navarra,',
        'Logroño|La Rioja,Toledo|Castilla-La Mancha,Valladolid|Castilla y León,',
        'Salamanca|Castilla y León,Badajoz|Extremadura,Elche|Comunidad Valenciana,',
        'Alicante|Comunidad Valenciana,Córdoba|Andalucía');
    DECLARE nombres VARCHAR(1000) DEFAULT CONCAT(
        'María,Carlos,Laura,Javier,Ana,David,Sofía,Pablo,Lucía,Diego,',
        'Elena,Marc,Clara,Hugo,Nora,Leo,Alicia,Sergio,Irene,Adrián');
    DECLARE apellidos VARCHAR(1000) DEFAULT CONCAT(
        'García,Martínez,López,Sánchez,Pérez,Gómez,Fernández,Díaz,Torres,Ruiz,',
        'Moreno,Álvarez,Romero,Navarro,Molina,Ortiz,Delgado,Castro,Suárez,Vega');
    DECLARE elegido_ciudad_comunidad VARCHAR(60);
    DECLARE elegido_ciudad VARCHAR(40);
    DECLARE elegido_comunidad VARCHAR(40);
    DECLARE elegido_nombre VARCHAR(30);
    DECLARE elegido_apellido VARCHAR(30);
    DECLARE longitud_lista INT;

    WHILE i < n DO
        SET longitud_lista = 1 + (LENGTH(ciudades_comunidades) - LENGTH(REPLACE(ciudades_comunidades, ',', '')));
        SET elegido_ciudad_comunidad = SUBSTRING_INDEX(SUBSTRING_INDEX(ciudades_comunidades, ',', 1 + FLOOR(RAND()*longitud_lista)), ',', -1);
        SET elegido_ciudad = SUBSTRING_INDEX(elegido_ciudad_comunidad, '|', 1);
        SET elegido_comunidad = SUBSTRING_INDEX(elegido_ciudad_comunidad, '|', -1);

        SET longitud_lista = 1 + (LENGTH(nombres) - LENGTH(REPLACE(nombres, ',', '')));
        SET elegido_nombre = SUBSTRING_INDEX(SUBSTRING_INDEX(nombres, ',', 1 + FLOOR(RAND()*longitud_lista)), ',', -1);

        SET longitud_lista = 1 + (LENGTH(apellidos) - LENGTH(REPLACE(apellidos, ',', '')));
        SET elegido_apellido = SUBSTRING_INDEX(SUBSTRING_INDEX(apellidos, ',', 1 + FLOOR(RAND()*longitud_lista)), ',', -1);

        INSERT INTO clientes (nombre, apellidos, email, ciudad, comunidad_autonoma, fecha_alta, acepta_marketing)
        VALUES (
            elegido_nombre,
            elegido_apellido,
            CONCAT(LOWER(elegido_nombre), '.', LOWER(elegido_apellido), i, '@ejemplo.com'),
            elegido_ciudad,
            elegido_comunidad,
            DATE_ADD('2021-01-01', INTERVAL FLOOR(RAND()*900) DAY),
            IF(RAND() < 0.55, 1, 0)
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL generar_clientes(500);
DROP PROCEDURE generar_clientes;

-- ------------------------------------------------------------
-- 4. Pedidos + líneas de pedido + pagos — generados juntos para
--    que el importe de cada pago cuadre con sus líneas, y las
--    fechas de pedido caigan siempre después del alta del cliente.
-- ------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE generar_pedidos(IN n INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_cliente_id INT;
    DECLARE v_fecha_alta DATE;
    DECLARE v_fecha_pedido DATETIME;
    DECLARE v_pedido_id INT;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_num_lineas INT;
    DECLARE j INT;
    DECLARE v_producto_id INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_cantidad INT;
    DECLARE v_total_pedido DECIMAL(10,2);
    DECLARE v_metodo VARCHAR(20);
    DECLARE max_cliente_id INT;
    DECLARE max_producto_id INT;

    SELECT MAX(cliente_id) INTO max_cliente_id FROM clientes;
    SELECT MAX(producto_id) INTO max_producto_id FROM productos;

    WHILE i < n DO
        SET v_cliente_id = 1 + FLOOR(RAND() * max_cliente_id);
        SELECT fecha_alta INTO v_fecha_alta FROM clientes WHERE cliente_id = v_cliente_id;

        -- fecha de pedido: siempre después del alta, muestreada dentro
        -- de la ventana disponible hasta el cierre del histórico
        SET v_fecha_pedido = DATE_ADD(
            v_fecha_alta,
            INTERVAL FLOOR(RAND() * GREATEST(DATEDIFF('2023-12-31', v_fecha_alta), 1)) DAY
        );
        SET v_fecha_pedido = v_fecha_pedido + INTERVAL FLOOR(RAND()*24) HOUR + INTERVAL FLOOR(RAND()*60) MINUTE;

        SET v_estado = CASE
            WHEN RAND() < 0.05 THEN 'cancelado'
            WHEN RAND() < 0.08 THEN 'reembolsado'
            ELSE 'completado'
        END;

        INSERT INTO pedidos (cliente_id, fecha_pedido, estado) VALUES (v_cliente_id, v_fecha_pedido, v_estado);
        SET v_pedido_id = LAST_INSERT_ID();

        SET v_num_lineas = 1 + FLOOR(RAND() * 4); -- de 1 a 4 líneas por pedido
        SET v_total_pedido = 0;
        SET j = 0;
        WHILE j < v_num_lineas DO
            SET v_producto_id = 1 + FLOOR(RAND() * max_producto_id);
            SELECT precio_unitario INTO v_precio FROM productos WHERE producto_id = v_producto_id;
            SET v_cantidad = 1 + FLOOR(RAND() * 3);

            INSERT INTO lineas_pedido (pedido_id, producto_id, cantidad, precio_unitario)
            VALUES (v_pedido_id, v_producto_id, v_cantidad, v_precio);

            SET v_total_pedido = v_total_pedido + (v_precio * v_cantidad);
            SET j = j + 1;
        END WHILE;

        IF v_estado != 'cancelado' THEN
            SET v_metodo = CASE FLOOR(RAND()*4)
                WHEN 0 THEN 'tarjeta_credito'
                WHEN 1 THEN 'paypal'
                WHEN 2 THEN 'transferencia'
                ELSE 'tarjeta_regalo'
            END;
            INSERT INTO pagos (pedido_id, fecha_pago, importe, metodo_pago)
            VALUES (v_pedido_id, v_fecha_pedido + INTERVAL FLOOR(RAND()*3) HOUR, v_total_pedido, v_metodo);
        END IF;

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL generar_pedidos(6000);
DROP PROCEDURE generar_pedidos;

-- ------------------------------------------------------------
-- 5. Devoluciones — ~4% de las líneas de pedidos completados/reembolsados
-- ------------------------------------------------------------

INSERT INTO devoluciones (linea_pedido_id, fecha_devolucion, motivo)
SELECT
    lp.linea_pedido_id,
    DATE_ADD(p.fecha_pedido, INTERVAL 1 + FLOOR(RAND()*14) DAY),
    CASE FLOOR(RAND()*4)
        WHEN 0 THEN 'defectuoso'
        WHEN 1 THEN 'articulo_incorrecto'
        WHEN 2 THEN 'no_es_como_se_describe'
        ELSE 'ya_no_lo_necesita'
    END
FROM lineas_pedido lp
JOIN pedidos p ON p.pedido_id = lp.pedido_id
WHERE p.estado IN ('completado','reembolsado')
  AND RAND() < 0.04;

-- ------------------------------------------------------------
-- Comprobación de recuento de filas
-- ------------------------------------------------------------

SELECT 'categorias' AS tabla, COUNT(*) AS num_filas FROM categorias
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'clientes', COUNT(*) FROM clientes
UNION ALL SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL SELECT 'lineas_pedido', COUNT(*) FROM lineas_pedido
UNION ALL SELECT 'pagos', COUNT(*) FROM pagos
UNION ALL SELECT 'devoluciones', COUNT(*) FROM devoluciones;
