-- ══════════════════════════════════════════
-- Ventas_Tech_DB
-- Autor: Alejo Uslenghi
-- Fecha: 10/07/2026
-- ══════════════════════════════════════════

--Paso 1: Crear la base de datos
CREATE DATABASE Ventas_Tech_DB;
USE Ventas_Tech_DB; --Le digo que base de datos usar

--Paso 2: Desarrollá el script con las siguientes secciones
--2.1 DROP TABLES - Si existen previamente estas tablas, las elimina.
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

--2.2 Crear las tablas que voy a usar

 --TABLA DE CATEGORÍAS
CREATE TABLE categorias(
id_categoria	INT  NOT NULL	PRIMARY KEY,
nombre_categoria	VARCHAR(50)	NOT NULL,
descripcion	VARCHAR(200));	

--TABLA DE CLIENTES
CREATE TABLE clientes( 
id_cliente	INT NOT NULL PRIMARY KEY,
nombre	VARCHAR(100) NOT NULL,
email	VARCHAR(100) UNIQUE,
ciudad VARCHAR(50),
fecha_registro	DATE NOT NULL);

--TABLA DE PRODUCTOS
CREATE TABLE productos(
id_producto	INT PRIMARY KEY,
nombre_producto	VARCHAR(100)	NOT NULL,
id_categoria	INT	FOREIGN KEY REFERENCES categorias (id_categoria),
precio	DECIMAL(10,2)	NOT NULL,
stock	INT	DEFAULT 0,
activo	TINYINT	DEFAULT 1);

--TABLA DE VENTAS
CREATE TABLE ventas(
id_venta	INT	PRIMARY KEY,
id_cliente	INT	FOREIGN KEY REFERENCES clientes(id_cliente),
id_producto	INT	FOREIGN KEY REFERENCES productos(id_producto),
cantidad	INT	NOT NULL,
precio_unitario	DECIMAL(10,2)	NOT NULL,
fecha_venta	DATE	NOT NULL);

--2.3 agregarle a las tablas la información que voy a usar

--Datos para TABLA CATEGORÍAS
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion)
VALUES 
(1,	'Computación',			'Laptops, PCs y monitores'),
(2,	'Accesorios',			'Periféricos y complementos'),
(3,	'Audio',				'Auriculares y parlantes'),
(4,	'Almacenamiento',		'Discos y memorias');

--Datos para TABLA CLIENTES
INSERT INTO clientes (id_cliente, nombre, email,  ciudad, fecha_registro)
VALUES 
(1,		'María López',		'maria@mail.com',		'Buenos Aires',		'2024-01-05'),
(2,		'Carlos Ruiz',		'carlos@mail.com',		'Córdoba',			'2024-01-10'),
(3,		'Ana Gómez',		'ana@mail.com',			'Rosario',			'2024-02-01'),
(4,		'Pedro Sanz',		'pedro@mail.com',		'Mendoza',			'2024-02-15'),
(5,		'Laura Torres',		'laura@mail.com',		'Tucumán',			'2024-03-01');

--Datos para TABLA PRODUCTOS
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES 
(1,		'Laptop Pro 15',			1,		1200.00,		15,		1),
(2,		'Mouse Inalámbrico',		2,		28.00,			80,		1),
(3,		'Monitor 4K 27"',			1,		450.00,			12,		1),
(4,		'Auriculares BT Pro',		3,		120.00,			35,		1),
(5,		'SSD Externo 1TB',			4,		130.00,			18,		1),
(6,		'Teclado Mecánico',			2,		95.00,			40,		1);

--Datos para TABLA VENTAS
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario,fecha_venta)
VALUES 
(1,		1,		1,		2,		1200.00,		'2024-03-05'),
(2,		2,		2,		5,		28.00,			'2024-03-06'),
(3,		3,		3,		1,		450.00,			'2024-03-07'),
(4,		1,		4,		2,		120.00,			'2024-03-08'),
(5,		4,		5,		3,		130.00,			'2024-03-10'),
(6,		2,		6,		4,		95.00,			'2024-03-11'),
(7,		5,		1,		1,		1200.00,		'2024-03-12'),
(8,		3,		2,		8,		28.00,			'2024-03-13'),
(9,		4,		4,		1,		120.00,			'2024-03-14'),
(10,	5,		3,		2,		450.00,			'2024-03-15');

--Paso 3: Verificación de integridad, confirmá que cada tabla se cargó correctamente.
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;

-- ==============================================================================
-- Archivo: m4_consultas_negocio.sql
-- Base de Datos: Ventas_Tech_DB
-- Descripción: Consultas de negocio para la extracción de métricas clave (Módulo 4)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Consulta 1 — Resumen ejecutivo mensual
-- ------------------------------------------------------------------------------
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- ------------------------------------------------------------------------------
-- Consulta 2 — Ranking de productos
-- ------------------------------------------------------------------------------
SELECT TOP 5id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;

-- ------------------------------------------------------------------------------
-- Consulta 3 — Clientes recurrentes
-- ------------------------------------------------------------------------------
SELECT  id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY  id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC;

-- ------------------------------------------------------------------------------
-- Consulta 4 — Meses por encima/por debajo del promedio
-- ------------------------------------------------------------------------------
WITH TotalesMensuales AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY  MONTH(fecha_venta))
SELECT mes, total_facturado,
    CASE 
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM TotalesMensuales) THEN 'Por encima'
        WHEN total_facturado < (SELECT AVG(total_facturado) FROM TotalesMensuales) THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparativa_promedio
FROM TotalesMensuales
ORDER BY mes;

-- ------------------------------------------------------------------------------
-- Bloque de cierre: Hallazgos concretos
-- ------------------------------------------------------------------------------
-- 1. Concentración de ingresos: El producto 1 (Laptop Pro 15) es el claro líder de 
--    facturación. Con tan solo 3 unidades vendidas en 2 transacciones, generó un 
--    total de $3600, lo que representa más del 50% de la facturación total del 
--    período analizado ($6444).
--
-- 2. Alta retención inicial: El 100% de la base de clientes actual (los 5 registrados) 
--    son recurrentes. Todos los clientes realizaron exactamente 2 pedidos durante 
--    el mes de marzo, lo que indica un excelente comportamiento de compra inicial.
--
-- 3. Datos concentrados: Todas las ventas registradas corresponden al mes de marzo 
--    de 2024 (Mes 3). Al haber un único mes en el dataset actual, la comparativa de 
--    la consulta 4 muestra que la facturación del mes es lógicamente "Igual al promedio".