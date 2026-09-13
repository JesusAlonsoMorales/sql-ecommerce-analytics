-- ============================================================
-- ShopSphere — Analítica de Ventas Online — Esquema
-- MySQL 8.0+
-- ============================================================

DROP DATABASE IF EXISTS tienda_online;
CREATE DATABASE tienda_online CHARACTER SET utf8mb4;
USE tienda_online;

-- ------------------------------------------------------------
-- Tablas maestras
-- ------------------------------------------------------------

CREATE TABLE categorias (
    categoria_id     INT PRIMARY KEY AUTO_INCREMENT,
    nombre_categoria VARCHAR(60) NOT NULL
);

CREATE TABLE productos (
    producto_id      INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id     INT NOT NULL,
    nombre_producto  VARCHAR(120) NOT NULL,
    coste_unitario   DECIMAL(10,2) NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    fecha_lanzamiento DATE NOT NULL,
    CONSTRAINT fk_productos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
    CONSTRAINT chk_precio_mayor_coste CHECK (precio_unitario >= coste_unitario)
);

CREATE TABLE clientes (
    cliente_id       INT PRIMARY KEY AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    apellidos        VARCHAR(50) NOT NULL,
    email            VARCHAR(120) NOT NULL UNIQUE,
    ciudad           VARCHAR(80) NOT NULL,
    comunidad_autonoma VARCHAR(60) NOT NULL,
    fecha_alta       DATE NOT NULL,
    acepta_marketing TINYINT(1) NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------
-- Tablas transaccionales
-- ------------------------------------------------------------

CREATE TABLE pedidos (
    pedido_id        INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id       INT NOT NULL,
    fecha_pedido     DATETIME NOT NULL,
    estado           ENUM('completado','cancelado','reembolsado') NOT NULL DEFAULT 'completado',
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

CREATE TABLE lineas_pedido (
    linea_pedido_id  INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id        INT NOT NULL,
    producto_id      INT NOT NULL,
    cantidad         INT NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,   -- precio en el momento de la venta (puede diferir del precio actual del catálogo)
    CONSTRAINT fk_lineas_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
    CONSTRAINT fk_lineas_producto FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0)
);

CREATE TABLE pagos (
    pago_id          INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id        INT NOT NULL,
    fecha_pago       DATETIME NOT NULL,
    importe          DECIMAL(10,2) NOT NULL,
    metodo_pago      ENUM('tarjeta_credito','paypal','transferencia','tarjeta_regalo') NOT NULL,
    CONSTRAINT fk_pagos_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id)
);

CREATE TABLE devoluciones (
    devolucion_id    INT PRIMARY KEY AUTO_INCREMENT,
    linea_pedido_id  INT NOT NULL,
    fecha_devolucion DATE NOT NULL,
    motivo           ENUM('defectuoso','articulo_incorrecto','no_es_como_se_describe','ya_no_lo_necesita') NOT NULL,
    CONSTRAINT fk_devoluciones_linea FOREIGN KEY (linea_pedido_id) REFERENCES lineas_pedido(linea_pedido_id)
);

-- ------------------------------------------------------------
-- Índices que apoyan las consultas analíticas de 03_consultas.sql
-- ------------------------------------------------------------

CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha_pedido);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_lineas_pedido_pedido ON lineas_pedido(pedido_id);
CREATE INDEX idx_lineas_pedido_producto ON lineas_pedido(producto_id);
CREATE INDEX idx_pagos_pedido ON pagos(pedido_id);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
