--
-- Año: 2023 
-- Grupo Nro: 03 
-- Integrantes: Juarez Yelamos Fausto, Ruiz Francisco Mauricio
-- Tema: LyMInternet
-- Nombre del Esquema: LBD2023G03
-- Plataforma (SO + Versión): Windows 10
-- Motor y Versión: MySQL Server 8.0.31
-- GitHub Repositorio: LBD2023G03
-- GitHub Usuario: FaustoJuarez, mauruiz20

/* 1. Dado un cliente, listar todos sus servicios en un rango de fechas. */

SELECT		*
FROM		servicios
WHERE		IdUsuario = 1 AND
			FechaAlta BETWEEN '2023-05-01' AND '2023-08-31'
;

/* 2. Realizar un listado de servicios realizados agrupados por tipos de servicios. */

-- No se entiende el enunciado

SELECT		TipoServicio, s.*
FROM		servicios s
JOIN		tiposservicio t ON s.IdTipoServicio = t.IdTipoServicio
WHERE		FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL
ORDER BY	TipoServicio
;

/* 3. Mostrar la diferencia entre el total de productos de entradas y el total de productos asignados a servicios para un rango de fechas en particular. */

SELECT * FROM lineasEntrada;
SELECT * FROM lineasServicio;

-- Opcion 1
SET @TotalEntrada = (SELECT 		SUM(Cantidad) Cantidad
					 FROM			lineasEntrada);
                     
SET @TotalServicio = (SELECT		SUM(Cantidad) Cantidad
					  FROM			lineasServicio);
                      
SELECT @TotalEntrada - @TotalServicio AS Total;

-- ¿Que fecha?
-- Entradas -> FechaEntrada
-- Servicios -> FechaFinalizacion

-- Opcion 2
SELECT 
	(SELECT SUM(Cantidad) Cantidad 
		FROM lineasEntrada l 
		JOIN entradas e ON l.IdEntrada = e.IdEntrada 
        WHERE EstadoEntrada = 'F'
	) - 
    (SELECT SUM(Cantidad) Cantidad 
		FROM lineasServicio 
		WHERE IdProducto IS NOT NULL
	) AS Total
;

/* 4. Dado un rango de fechas, mostrar mes a mes el total de entradas y el total de servicios. 
 		El formato deberá ser: mes, total de productos en entradas, total de productos asignados a servicios, 
 		total de servicios sin productos asignados, total de servicios. */
        
-- ¿Como calculo el mes a mes de un producto asignado y servicios?
-- Productos asignados en que fecha?

SELECT		MONTH(FechaEntrada) Mes, SUM(Cantidad) 'Total de productos en entradas'
FROM		entradas
JOIN		lineasEntrada USING (IdEntrada)
GROUP BY	Mes
ORDER BY 	Mes
;
-- Fecha de alta o fecha de finalizacion
SELECT      MONTH(FechaFinalizacion) Mes, SUM(Cantidad) 'Total de productos asignados'
FROM        servicios
JOIN        lineasServicio USING (IdServicio)
GROUP BY    Mes
HAVING      Mes IS NOT NULL
ORDER BY    Mes
;

SELECT      MONTH(FechaFinalizacion) Mes, COUNT(IdServicio) 'Total de servicios sin productos asignados'
FROM        servicios
LEFT JOIN   lineasServicio USING (IdServicio)
WHERE       NroLinea IS NULL
GROUP BY    Mes
HAVING      Mes IS NOT NULL
ORDER BY    Mes
;

SELECT      MONTH(FechaAlta) Mes, COUNT(IdServicio) 'Total de servicios'
FROM        servicios
GROUP BY    Mes
ORDER BY    Mes
;

-- consulta grande
SELECT
t1.Mes,
COALESCE(t1.`Total de productos en entradas`,0) 'Total de productos en entradas',
COALESCE(t2.`Total de productos asignados`,0) 'Total de productos asignados',
COALESCE(t3.`Total de servicios sin productos asignados`,0) 'Total de servicios sin productos asignados',
COALESCE(t4.`Total de servicios`,0) 'Total de servicios' 
FROM
(SELECT
MONTH(FechaEntrada) Mes,
SUM(Cantidad) 'Total de productos en entradas'
FROM entradas
JOIN lineasEntrada USING (IdEntrada)
GROUP BY Mes) t1

LEFT JOIN
(SELECT
MONTH(FechaFinalizacion) Mes,
SUM(Cantidad) 'Total de productos asignados'
FROM servicios
JOIN lineasServicio USING (IdServicio)
GROUP BY Mes
HAVING Mes IS NOT NULL) t2 ON t1.Mes = t2.Mes

LEFT JOIN
(SELECT
MONTH(FechaFinalizacion) Mes,
COUNT(IdServicio) 'Total de servicios sin productos asignados'
FROM servicios
LEFT JOIN lineasServicio USING (IdServicio)
WHERE NroLinea IS NULL
GROUP BY Mes
HAVING Mes IS NOT NULL) t3 ON t1.Mes = t3.Mes

LEFT JOIN
(SELECT
MONTH(FechaAlta) Mes,
COUNT(IdServicio) 'Total de servicios'
FROM servicios
GROUP BY Mes) t4 ON t1.Mes = t4.Mes

ORDER BY t1.Mes;

/* 5. Hacer un ranking con los técnicos que más servicios realizan (por cantidad) en un rango de fechas. */

-- ¿Que fecha?
SELECT * FROM tecnicos t JOIN servicios s ON t.IdUsuario = s.IdTecnico;

SELECT			t.IdUsuario, Apellidos, Nombres, COUNT(IdServicio) 'Cantidad de servicios'
FROM			tecnicos t
JOIN			usuarios u ON t.IdUsuario = u.IdUsuario
LEFT JOIN		servicios s ON t.IdUsuario = s.IdTecnico
WHERE			(FechaFinalizacion IS NOT NULL OR FechaBaja IS NOT NULL) AND FechaAlta BETWEEN '2021-04-01' AND '2024-08-31'
GROUP BY		IdUsuario, Apellidos, Nombres
ORDER BY 		4 DESC
;

/* 6. Hacer un ranking con los tipos de servicios más realizados (por importe) en un rango de fechas. */

SELECT			ts.IdTipoServicio, TipoServicio, SUM(Cantidad * PrecioUnitario) 'Importe'
FROM			tiposServicio ts
LEFT JOIN		servicios s ON s.IdTipoServicio = ts.IdTipoServicio
JOIN			lineasServicio ls ON s.IdServicio = ls.IdServicio
WHERE			FechaFinalizacion IS NOT NULL AND s.FechaAlta BETWEEN '2021-04-01' AND '2024-08-31'
GROUP BY		IdTipoServicio, TipoServicio
ORDER BY 		3 DESC
;

/* 7. Hacer un ranking con los tipos de servicios más realizados (por cantidad) en un rango de fechas. */

SELECT			t.IdTipoServicio, TipoServicio, COUNT(s.IdServicio) 'Tipos de servicios más realizados'
FROM			tiposServicio t
JOIN			servicios s ON t.IdTipoServicio = s.IdTipoServicio
WHERE			FechaFinalizacion IS NOT NULL AND s.FechaAlta BETWEEN '2021-04-01' AND '2024-08-31'
GROUP BY		IdTipoServicio, TipoServicio
ORDER BY		3 DESC;

/*- 8. Crear una vista con la funcionalidad del apartado 2. */

CREATE VIEW v_servicios_agrupados_tipo AS
	SELECT		TipoServicio, s.*
	FROM		servicios s
	JOIN		tiposservicio t ON s.IdTipoServicio = t.IdTipoServicio
	WHERE		FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL
	ORDER BY	TipoServicio
;

SELECT * FROM v_servicios_agrupados_tipo;

/* 9. Crear una copia de la tabla productos, que además tenga una columna del tipo JSON para guardar el detalle de las entradas (lineasEntrada). 
 		Llenar esta tabla con los mismos datos del TP1 y resolver la consulta: Dado un producto listar todas las lineasEntradas del producto. */

DROP TABLE IF EXISTS productos_copia;        
CREATE TABLE productos_copia (
  IdProducto int unsigned NOT NULL AUTO_INCREMENT,
  Producto varchar(60) NOT NULL,
  Marca varchar(60) DEFAULT NULL,
  Detalle JSON NULL,
  EstadoProducto char(1) NOT NULL DEFAULT 'A',
  PRIMARY KEY (IdProducto)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO productos_copia (Producto,Marca,Detalle,EstadoProducto)
VALUES
    ('Switch',null,'[
    {
      "IdEntrada": 1,
      "CostoUnitario": 15000,
      "Cantidad": 5
    },
    {
      "IdEntrada": 12,
      "CostoUnitario": 10000,
      "Cantidad": 5
    }
  ]','A'),
    ('Switch','Cisco','[
    {
      "IdEntrada": 5,
      "CostoUnitario": 50000,
      "Cantidad": 2
    }
  ]','A'),
    ('Router','Cisco','[
    {
      "IdEntrada": 1,
      "CostoUnitario": 25000,
      "Cantidad": 1
    },
    {
      "IdEntrada": 4,
      "CostoUnitario": 25000,
      "Cantidad": 2
    }
  ]','B'),
    ('Router','Mikrotik','[
    {
      "IdEntrada": 4,
      "CostoUnitario": 30000,
      "Cantidad": 2
    }
  ]','B'),
    ('Cable','UTP','[
    {
      "IdEntrada": 3,
      "CostoUnitario": 2000,
      "Cantidad": 20
    }
  ]','A'),
    ('Servidor',null,'[
    {
      "IdEntrada": 2,
      "CostoUnitario": 100000,
      "Cantidad": 1
    }
  ]','A'),
    ('Switch','Cisco','[
    {
      "IdEntrada": 5,
      "CostoUnitario": 80000,
      "Cantidad": 1
    }
  ]','A'),
    ('Switch','HP','[
    {
      "IdEntrada": 13,
      "CostoUnitario": 50000,
      "Cantidad": 2
    }
  ]','A'),
    ('Switch','Dell','[
    {
      "IdEntrada": 6,
      "CostoUnitario": 15000,
      "Cantidad": 10
    },
    {
      "IdEntrada": 9,
      "CostoUnitario": 30000,
      "Cantidad": 3
    }
  ]','B'),
    ('Router','Cisco',null,'A'),
    ('Router','Juniper','[
    {
      "IdEntrada": 6,
      "CostoUnitario": 35000,
      "Cantidad": 5
    }
  ]','B'),
    ('Firewall','Fortinet','[
    {
      "IdEntrada": 7,
      "CostoUnitario": 20000,
      "Cantidad": 3
    }
  ]','A'),
    ('Firewall','Palo Alto','[
    {
      "IdEntrada": 9,
      "CostoUnitario": 30000,
      "Cantidad": 3
    }
  ]','B'),
    ('Access Point','Aruba',null,'A'),
    ('Access Point','Ubiquiti','[
    {
      "IdEntrada": 8,
      "CostoUnitario": 40000,
      "Cantidad": 2
    }
  ]','A'),
    ('Access Point','Ruckus','[
    {
      "IdEntrada": 9,
      "CostoUnitario": 50000,
      "Cantidad": 1
    }
  ]','B'),
    ('Cable UTP','Belden','[
    {
      "IdEntrada": 10,
      "CostoUnitario": 10000,
      "Cantidad": 15
    }
  ]','A'),
    ('Cable UTP','Panduit','[
    {
      "IdEntrada": 10,
      "CostoUnitario": 20000,
      "Cantidad": 5
    }
  ]','A'),
    ('Patch Panel','Leviton','[
    {
      "IdEntrada": 11,
      "CostoUnitario": 15000,
      "Cantidad": 10
    }
  ]','A'),
    ('Patch Panel','Belden','[
    {
		"IdEntrada": 14,
		"CostoUnitario": 100000,
		"Cantidad": 1
	}
  ]','B');
  
SELECT * FROM productos_copia;
SELECT * FROM lineasEntrada WHERE IdProducto = 1;
  
-- NroLinea ORDINALITY ?
SELECT		NroLinea, IdEntrada, CostoUnitario, Cantidad
FROM		productos_copia
JOIN		JSON_TABLE(Detalle, '$[*]' COLUMNS(
					NroLinea	  	FOR ORDINALITY,
					IdEntrada 		int 			PATH '$.IdEntrada',
					CostoUnitario 	decimal(12,2) 	PATH '$.CostoUnitario',
					Cantidad 		smallint		PATH '$.Cantidad'
					)
			) AS lineasEntrada
WHERE			IdProducto = 1
;

/* 10: Realizar una vista que considere importante para su modelo. También dejar escrito el enunciado de la misma. */

-- Enunciado: Mostrar una lista de los servicios que no están pagados indicando quién es el cliente, su teléfono y cúal es la deuda.

DROP VIEW IF EXISTS v_servicios_impagos;
CREATE VIEW	v_servicios_impagos AS
	SELECT		IdServicio, CONCAT(Apellidos, ', ', Nombres) Cliente, Telefono, COALESCE(SUM(Cantidad * PrecioUnitario), 0) Deuda
	FROM		servicios s
	JOIN		usuarios u USING (IdUsuario)
	JOIN		lineasServicio ls USING (IdServicio)
	WHERE		FechaBaja IS NULL AND FechaPago IS NULL
	GROUP BY	IdServicio, s.IdUsuario
;

SELECT * FROM v_servicios_impagos;