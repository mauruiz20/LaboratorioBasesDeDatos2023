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

/* --------------------------------------------------------------------- */
/* 1. Dado un cliente, listar todos sus servicios en un rango de fechas. */
/* --------------------------------------------------------------------- */
SET @IdUsuario_1 = 1;
SET @FechaInicio_1 = '2023-05-01T00:00:00';
SET @FechaFin_1 = '2023-10-20T23:59:59';

SELECT		Titulo, FechaAlta, FechaBaja, FechaFinalizacion, FechaPago, Observaciones, IdServicio, IdUsuario, IdTecnico, IdVendedor, IdTipoServicio
FROM		servicios
WHERE		IdUsuario = @IdUsuario_1 AND
			FechaAlta BETWEEN @FechaInicio_1 AND @FechaFin_1
ORDER BY	Titulo, FechaAlta, FechaBaja, FechaFinalizacion, FechaPago, Observaciones, IdServicio, IdUsuario, IdTecnico, IdVendedor, IdTipoServicio
;

/* -------------------------------------------------------------------------------- */
/* 2. Realizar un listado de servicios realizados agrupados por tipos de servicios. */
/* -------------------------------------------------------------------------------- */

SELECT		TipoServicio, Titulo, s.FechaAlta, FechaFinalizacion, FechaPago, Observaciones, IdServicio, IdUsuario, IdTecnico, IdVendedor, s.IdTipoServicio
FROM		servicios AS s
INNER JOIN	tiposServicio AS t ON s.IdTipoServicio = t.IdTipoServicio
WHERE		FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL
ORDER BY	TipoServicio, Titulo, s.FechaAlta DESC, FechaFinalizacion DESC, FechaPago DESC, Observaciones, IdServicio, IdUsuario, IdTecnico, IdVendedor, s.IdTipoServicio
;

/* ----------------------------------------------------------------------------------------------------------------------------------------------------- */
/* 3. Mostrar la diferencia entre el total de productos de entradas y el total de productos asignados a servicios para un rango de fechas en particular. */
/* ----------------------------------------------------------------------------------------------------------------------------------------------------- */
SET @FechaInicio_3 = '2023-01-01T00:00:00';
SET @FechaFin_3 = '2024-12-31T23:59:59';

-- Creación de tabla temporal
DROP TABLE IF EXISTS tmp_productos;
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_productos (
	IdProducto 	INT NOT NULL,
    Entradas 	SMALLINT DEFAULT 0,
    Salidas 	SMALLINT DEFAULT 0
)ENGINE = InnoDB;

-- Inserción de cantidad de productos en entradas finalizadas entre fechas
INSERT INTO tmp_productos (IdProducto, Entradas) 
SELECT 		IdProducto, SUM(Cantidad) AS Entradas													
FROM 		lineasEntrada AS le 
INNER JOIN 	entradas AS e ON le.IdEntrada = e.IdEntrada 
WHERE 		EstadoEntrada = 'F' AND FechaEntrada BETWEEN @FechaInicio_3 AND @FechaFin_3
GROUP BY 	IdProducto;

-- Inserción de cantidad de productos en servicios realizados entre fechas
INSERT INTO tmp_productos (IdProducto, Salidas) 
SELECT 		IdProducto, SUM(Cantidad) AS Salidas 
FROM 		lineasServicio AS ls
INNER JOIN 	servicios AS s ON ls.IdServicio = s.IdServicio
WHERE 		FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL AND FechaFinalizacion BETWEEN @FechaInicio_3 AND @FechaFin_3
GROUP BY 	IdProducto;

-- Listado final de cantidad de productos
SELECT 		p.Producto, COALESCE(Marca, 'Genérico') AS Marca, SUM(Entradas - Salidas) AS Stock, p.IdProducto
FROM 		tmp_productos AS tp
INNER JOIN	productos AS p ON tp.IdProducto = p.IdProducto
GROUP BY	Producto, Marca, IdProducto
ORDER BY	Producto, Marca, Stock DESC, IdProducto
;
-- Eliminación de tabla temporal
DROP TABLE IF EXISTS tmp_productos;

/* ---------------------------------------------------------------------------------------------------- */
/* 4. Dado un rango de fechas, mostrar mes a mes el total de entradas y el total de servicios. 
	El formato deberá ser: mes, total de productos en entradas, total de productos asignados a servicios, 
 	total de servicios sin productos asignados, total de servicios. */
/* ---------------------------------------------------------------------------------------------------- */
SET @FechaInicio_4 = '2022-01-01T00:00:00';
SET @FechaFin_4 = '2024-12-31T23:59:59';

-- Creación de tabla temporal
DROP TABLE IF EXISTS tmp_resumen_meses;
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_resumen_meses (
	Anio					SMALLINT NOT NULL,
	Mes 					TINYINT NOT NULL,
    ProductosEntradas 		SMALLINT DEFAULT 0,
    ProductosServicios		SMALLINT DEFAULT 0,
    ServiciosSinProductos	SMALLINT DEFAULT 0,
    Servicios				SMALLINT DEFAULT 0
)ENGINE = InnoDB;

INSERT INTO tmp_resumen_meses (Anio, Mes, ProductosEntradas)
SELECT		Year(FechaEntrada) AS Anio, MONTH(FechaEntrada) AS Mes, SUM(Cantidad)
FROM		entradas AS e
INNER JOIN	lineasEntrada AS le ON e.IdEntrada = le.IdEntrada
WHERE 		FechaEntrada BETWEEN @FechaInicio_4 AND @FechaFin_4
GROUP BY	Anio, Mes
;

INSERT INTO tmp_resumen_meses (Anio, Mes, ProductosServicios)
SELECT      Year(FechaFinalizacion) AS Anio, MONTH(FechaFinalizacion) AS Mes, SUM(Cantidad)
FROM        servicios AS s
INNER JOIN  lineasServicio AS ls ON s.IdServicio = ls.IdServicio
WHERE 		FechaBaja IS NULL AND FechaFinalizacion BETWEEN @FechaInicio_4 AND @FechaFin_4
GROUP BY    Anio, Mes
HAVING      Mes IS NOT NULL
;

INSERT INTO 	tmp_resumen_meses (Anio, Mes, ServiciosSinProductos)
SELECT      	Year(FechaFinalizacion) AS Anio, MONTH(FechaFinalizacion) AS Mes, COUNT(s.IdServicio)
FROM        	servicios AS s
LEFT OUTER JOIN lineasServicio AS ls ON s.IdServicio = ls.IdServicio
WHERE       	NroLinea IS NULL AND FechaBaja IS NULL AND FechaFinalizacion BETWEEN @FechaInicio_4 AND @FechaFin_4
GROUP BY    	Anio, Mes
HAVING      	Mes IS NOT NULL
;

INSERT INTO tmp_resumen_meses (Anio, Mes, Servicios)
SELECT      Year(FechaAlta) AS Anio, MONTH(FechaAlta) AS Mes, COUNT(IdServicio)
FROM        servicios
WHERE 		FechaAlta BETWEEN @FechaInicio_4 AND @FechaFin_4
GROUP BY    Anio, Mes
;

-- Listado final
SELECT 		Anio AS Año,
			Mes, 
            SUM(ProductosEntradas) AS 'Total de productos en entradas', 
            SUM(ProductosServicios) AS 'Total de productos asignados a servicios', 
            SUM(ServiciosSinProductos) AS 'Total de servicios sin productos asignados', 
            SUM(Servicios) AS 'Total de servicios'
FROM 		tmp_resumen_meses AS tr
GROUP BY	Anio, Mes
ORDER BY	Anio, Mes ASC
;

-- Eliminación de tabla temporal
DROP TABLE IF EXISTS tmp_resumen_meses;

/* ----------------------------------------------------------------------------------------------------- */
/* 5. Hacer un ranking con los técnicos que más servicios realizan (por cantidad) en un rango de fechas. */
/* ----------------------------------------------------------------------------------------------------- */
SET @FechaInicio_5 = '2022-01-01T00:00:00';
SET @FechaFin_5 = '2024-12-31T23:59:59';

SELECT			COUNT(IdServicio) AS Cantidad, Apellidos, Nombres, t.IdUsuario
FROM			tecnicos AS t
JOIN			usuarios AS u ON t.IdUsuario = u.IdUsuario
LEFT OUTER JOIN	servicios AS s ON t.IdUsuario = s.IdTecnico
WHERE			(FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL) AND FechaAlta BETWEEN @FechaInicio_5 AND @FechaFin_5
GROUP BY		IdUsuario, Apellidos, Nombres
ORDER BY 		Cantidad DESC, Apellidos, Nombres, t.IdUsuario
;

/* -------------------------------------------------------------------------------------------------- */
/* 6. Hacer un ranking con los tipos de servicios más realizados (por importe) en un rango de fechas. */
/* -------------------------------------------------------------------------------------------------- */
SET @FechaInicio_6 = '2021-01-01T00:00:00';
SET @FechaFin_6 = '2024-12-31T23:59:59';

SELECT			SUM(Cantidad * PrecioUnitario) AS Importe, TipoServicio, ts.IdTipoServicio
FROM			tiposServicio AS ts
INNER JOIN		servicios AS s ON s.IdTipoServicio = ts.IdTipoServicio
INNER JOIN		lineasServicio AS ls ON s.IdServicio = ls.IdServicio AND s.IdUsuario = ls.IdUsuario
WHERE			(FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL) AND s.FechaAlta BETWEEN @FechaInicio_6 AND @FechaFin_6
GROUP BY		TipoServicio, IdTipoServicio
ORDER BY 		Importe DESC, TipoServicio, ts.IdTipoServicio
;

/* --------------------------------------------------------------------------------------------------- */
/* 7. Hacer un ranking con los tipos de servicios más realizados (por cantidad) en un rango de fechas. */
/* --------------------------------------------------------------------------------------------------- */
SET @FechaInicio_7 = '2021-01-01T:00:00:00';
SET @FechaFin_7 = '2024-12-31T23:59:59';

SELECT			COUNT(s.IdServicio) AS Cantidad, TipoServicio, t.IdTipoServicio
FROM			tiposServicio AS t
INNER JOIN		servicios AS s ON t.IdTipoServicio = s.IdTipoServicio
WHERE			FechaFinalizacion IS NOT NULL AND s.FechaAlta BETWEEN @FechaInicio_7 AND @FechaFin_7
GROUP BY		TipoServicio, IdTipoServicio
ORDER BY		Cantidad DESC, TipoServicio, t.IdTipoServicio
;

/* ------------------------------------------------------- */
/* 8. Crear una vista con la funcionalidad del apartado 2. */
/* ------------------------------------------------------- */

DROP VIEW IF EXISTS v_servicios_agrupados_tipo;
CREATE VIEW  v_servicios_agrupados_tipo AS
	SELECT		TipoServicio, Titulo, s.FechaAlta, FechaFinalizacion, FechaPago, Observaciones, IdServicio, IdUsuario, IdTecnico, IdVendedor, s.IdTipoServicio
	FROM		servicios AS s
	INNER JOIN	tiposServicio AS t ON s.IdTipoServicio = t.IdTipoServicio
	WHERE		FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL
	ORDER BY	TipoServicio, Titulo, s.FechaAlta DESC, FechaFinalizacion DESC, FechaPago DESC, Observaciones, IdServicio, IdUsuario, IdTecnico, IdVendedor, s.IdTipoServicio
;

SELECT * FROM v_servicios_agrupados_tipo;

/* ------------------------------------------------------------------------------------------------------------------------------------------ */
/* 9. Crear una copia de la tabla productos, que además tenga una columna del tipo JSON para guardar el detalle de las entradas (lineasEntrada). 
	Llenar esta tabla con los mismos datos del TP1 y resolver la consulta: Dado un producto listar todas las lineasEntradas del producto. */
/* ------------------------------------------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS productos_copia;        
CREATE TABLE IF NOT EXISTS productos_copia (
  IdProducto int unsigned NOT NULL AUTO_INCREMENT,
  Producto varchar(60) NOT NULL,
  Marca varchar(60) DEFAULT NULL,
  Detalle JSON NULL,
  EstadoProducto char(1) NOT NULL DEFAULT 'A',
  PRIMARY KEY (IdProducto)
) ENGINE=InnoDB AUTO_INCREMENT=1;

INSERT INTO productos_copia (Producto,Marca,Detalle,EstadoProducto)
VALUES
    ('Switch',null,'[
      {
        "IdEntrada": 1,
        "CostoUnitario": 15000,
        "Cantidad": 11
      },
      {
        "IdEntrada": 6,
        "CostoUnitario": 20000,
        "Cantidad": 3
      },
      {
        "IdEntrada": 11,
        "CostoUnitario": 10000,
        "Cantidad": 5
      },
      {
        "IdEntrada": 13,
        "CostoUnitario": 10000,
        "Cantidad": 12
      }
	]','A'),
    ('Switch','Cisco','[
      {
        "IdEntrada": 2,
        "CostoUnitario": 50000,
        "Cantidad": 2
      },
      {
        "IdEntrada": 6,
        "CostoUnitario": 10000,
        "Cantidad": 2
      },
      {
        "IdEntrada": 14,
        "CostoUnitario": 10000,
        "Cantidad": 7
      }
    ]','A'),
    ('Router','Cisco','[
      {
        "IdEntrada": 1,
        "CostoUnitario": 25000,
        "Cantidad": 5
      },
      {
        "IdEntrada": 2,
        "CostoUnitario": 25000,
        "Cantidad": 2
      },
      {
        "IdEntrada": 6,
        "CostoUnitario": 20000,
        "Cantidad": 3
      },
      {
        "IdEntrada": 17,
        "CostoUnitario": 30000,
        "Cantidad": 20
      }
    ]','B'),
    ('Router','Mikrotik','[
      {
        "IdEntrada": 5,
        "CostoUnitario": 30000,
        "Cantidad": 2
      },
      {
        "IdEntrada": 19,
        "CostoUnitario": 40000,
        "Cantidad": 4
      }
    ]','B'),
    ('Cable','UTP','[
      {
        "IdEntrada": 2,
        "CostoUnitario": 2000,
        "Cantidad": 20
      },
      {
        "IdEntrada": 23,
        "CostoUnitario": 50000,
        "Cantidad": 9
      }
    ]','A'),
    ('Servidor',null,'[
      {
        "IdEntrada": 1,
        "CostoUnitario": 100000,
        "Cantidad": 13
      },
      {
        "IdEntrada": 24,
        "CostoUnitario": 60000,
        "Cantidad": 10
      }
    ]','A'),
    ('Switch','Cisco','[
      {
        "IdEntrada": 1,
        "CostoUnitario": 15000,
        "Cantidad": 10
      },
      {
        "IdEntrada": 5,
        "CostoUnitario": 80000,
        "Cantidad": 1
      }
    ]','A'),
    ('Switch','HP','[
      {
        "IdEntrada": 1,
        "CostoUnitario": 25000,
        "Cantidad": 10
      },
      {
        "IdEntrada": 11,
        "CostoUnitario": 50000,
        "Cantidad": 2
      }
    ]','A'),
    ('Switch','Dell','[
      {
        "IdEntrada": 1,
        "CostoUnitario": 100000,
        "Cantidad": 10
      },
      {
        "IdEntrada": 6,
        "CostoUnitario": 15000,
        "Cantidad": 10
      },
      {
        "IdEntrada": 9,
        "CostoUnitario": 30000,
        "Cantidad": 3
      },
      {
        "IdEntrada": 16,
        "CostoUnitario": 50000,
        "Cantidad": 10
      },
      {
        "IdEntrada": 17,
        "CostoUnitario": 10000,
        "Cantidad": 15
      },
      {
        "IdEntrada": 18,
        "CostoUnitario": 20000,
        "Cantidad": 5
      },
      {
        "IdEntrada": 19,
        "CostoUnitario": 15000,
        "Cantidad": 10
      }
    ]','B'),
    ('Router','Cisco','[
      {
        "IdEntrada": 8,
        "CostoUnitario": 20000,
        "Cantidad": 15
      }
    ]','A'),
    ('Router','Juniper','[
      {
        "IdEntrada": 6,
        "CostoUnitario": 35000,
        "Cantidad": 5
      }
    ]','B'),
    ('Firewall','Fortinet','[
      {
        "IdEntrada": 6,
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
        "IdEntrada": 6,
        "CostoUnitario": 40000,
        "Cantidad": 2
      }
    ]','A'),
    ('Access Point','Ruckus','[
      {
        "IdEntrada": 9,
        "CostoUnitario": 50000,
        "Cantidad": 10
      }
    ]','B'),
    ('Cable UTP','Belden','[
      {
        "IdEntrada": 9,
        "CostoUnitario": 10000,
        "Cantidad": 15
      }
    ]','A'),
    ('Cable UTP','Panduit','[
      {
        "IdEntrada": 9,
        "CostoUnitario": 20000,
        "Cantidad": 5
      }
    ]','A'),
    ('Patch Panel','Leviton','[
      {
        "IdEntrada": 9,
        "CostoUnitario": 15000,
        "Cantidad": 10
      }
    ]','A'),
    ('Patch Panel','Belden','[
      {
        "IdEntrada": 11,
        "CostoUnitario": 100000,
        "Cantidad": 10
      }
    ]','B');
  
-- Tabla productos copia
SELECT * FROM productos_copia;

SET @IdProducto_9 = 1;

-- Listado de la tabla original lineas entrada
SELECT * FROM lineasEntrada WHERE IdProducto = @IdProducto_9;

-- Listado de la tabla productos_copia
SELECT		NroLinea, IdEntrada, CostoUnitario, Cantidad
FROM		productos_copia
INNER JOIN	JSON_TABLE(Detalle, '$[*]' COLUMNS(
					NroLinea	  	FOR ORDINALITY,
					IdEntrada 		int 			PATH '$.IdEntrada',
					CostoUnitario 	decimal(12,2) 	PATH '$.CostoUnitario',
					Cantidad 		smallint		PATH '$.Cantidad'
					)
			) AS lineasEntrada
WHERE		IdProducto = @IdProducto_9
;

/* --------------------------------------------------------------------------------------------------------------- */
/* 10: Realizar una vista que considere importante para su modelo. También dejar escrito el enunciado de la misma. */
/* --------------------------------------------------------------------------------------------------------------- */

/* Enunciado: Mostrar un listado de los servicios realizados que no están pagados indicando quién es el cliente, su teléfono y cúal es la deuda. */

DROP VIEW IF EXISTS v_servicios_impagos;
CREATE VIEW	v_servicios_impagos AS
	SELECT			FechaFinalizacion, Titulo, CONCAT(Apellidos, ', ', Nombres) AS Cliente, Telefono, COALESCE(SUM(Cantidad * PrecioUnitario), 0) AS Deuda, s.IdServicio
	FROM			servicios AS s
	INNER JOIN		usuarios AS u ON u.IdUsuario = s.IdUsuario
	LEFT OUTER JOIN	lineasServicio AS ls ON ls.IdServicio = s.IdServicio AND ls.IdUsuario = s.IdUsuario
	WHERE			FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL AND FechaPago IS NULL
	GROUP BY		FechaFinalizacion, Titulo, Cliente, Telefono, s.IdServicio
    ORDER BY		FechaFinalizacion, Titulo, Cliente, Telefono, Deuda, s.IdServicio
;

SELECT * FROM v_servicios_impagos;