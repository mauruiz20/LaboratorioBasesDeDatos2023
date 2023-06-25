DROP SCHEMA IF EXISTS parcial_2022;
CREATE SCHEMA IF NOT EXISTS parcial_2022;
USE parcial_2022;

DROP TABLE IF EXISTS Autores;
CREATE TABLE IF NOT EXISTS Autores (
	idAutor		VARCHAR(11) NOT NULL,
    apellido	VARCHAR(40) NOT NULL,
    nombre		VARCHAR(20) NOT NULL,
    telefono	CHAR(12) NOT NULL DEFAULT 'UNKNOWN',
    domicilio 	VARCHAR(40) NULL,
    ciudad		VARCHAR(20) NULL,
    estado		CHAR(29) NULL,
    codigoPostal CHAR(5) NULL,
    PRIMARY KEY (idAutor)
);

DROP TABLE IF EXISTS Editoriales;
CREATE TABLE IF NOT EXISTS Editoriales (
	idEditorial CHAR(4) NOT NULL,
    nombre VARCHAR(40) NOT NULL,
    ciudad VARCHAR(20) NULL,
    estado CHAR(2) NULL,
    pais VARCHAR(30) NOT NULL DEFAULT 'USA',
    PRIMARY KEY (idEditorial),
    UNIQUE INDEX (nombre)
);

DROP TABLE IF EXISTS Tiendas;
CREATE TABLE IF NOT EXISTS Tiendas (
	idTienda CHAR(4) NOT NULL,
    nombre VARCHAR(40) NOT NULL,
    domicilio VARCHAR(40) NULL,
    ciudad VARCHAR(20) NULL,
    estado CHAR(2) NULL,
    codigoPostal CHAR(5) NULL,
    PRIMARY KEY (idTienda),
    UNIQUE INDEX (nombre)
);

DROP TABLE IF EXISTS Ventas;
CREATE TABLE IF NOT EXISTS Ventas (
	codigoVenta VARCHAR(20) NOT NULL,
    idTienda CHAR(4) NOT NULL,
    fecha DATETIME NOT NULL,
    tipo VARCHAR(12) NOT NULL,
    PRIMARY KEY (codigoVenta),
    CONSTRAINT FK_idTienda 
		FOREIGN KEY (idTienda)
		REFERENCES Tiendas(idTienda),
	INDEX FK_idTienda_IX (idTienda)
);

DROP TABLE IF EXISTS Titulos;
CREATE TABLE IF NOT EXISTS Titulos (
	idTitulo VARCHAR(6) NOT NULL,
    titulo VARCHAR(80) NOT NULL,
    genero CHAR(12) NOT NULL DEFAULT 'UNDECIDED', 
    idEditorial CHAR(4) NOT NULL,
    precio DECIMAL(8,2) NULL CHECK ((precio IS NOT NULL AND precio >= 0) OR precio IS NULL),
    sinopsis VARCHAR(200) NULL,
    fechaPublicacion DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (idTitulo),
    CONSTRAINT FK_idEditorial 
		FOREIGN KEY (idEditorial)
		REFERENCES Editoriales(idEditorial),
	INDEX FK_idEditorial_IX (idEditorial)
);

DROP TABLE IF EXISTS TitulosDelAutor;
CREATE TABLE IF NOT EXISTS TitulosDelAutor (
	idAutor VARCHAR(11) NOT NULL,
	idTitulo VARCHAR(6) NOT NULL,
    PRIMARY KEY (idAutor, idTitulo),
    CONSTRAINT FK_idAutor 
		FOREIGN KEY (idAutor)
		REFERENCES Autores(idAutor),
	INDEX FK_idAutor_IX (idAutor),
    CONSTRAINT FK_idTitulo 
		FOREIGN KEY (idTitulo)
		REFERENCES Titulos(idTitulo),
	INDEX FK_idTitulo_IX (idTitulo)
);

DROP TABLE IF EXISTS Detalles;
CREATE TABLE IF NOT EXISTS Detalles (
	idDetalle INT AUTO_INCREMENT,
	codigoVenta VARCHAR(20) NOT NULL,
    idTitulo VARCHAR(6) NOT NULL,
    cantidad SMALLINT NOT NULL CHECK (cantidad >= 0),
    PRIMARY KEY (idDetalle),
    CONSTRAINT FK_codigoVenta 
		FOREIGN KEY (codigoVenta)
		REFERENCES Ventas(codigoVenta),
	INDEX FK_codigoVenta_IX (codigoVenta),
    CONSTRAINT FK_idTitulo2 
		FOREIGN KEY (idTitulo)
		REFERENCES Titulos(idTitulo),
	INDEX FK_idTitulo_IX2 (idTitulo)
);

-- --------------------------------------------
-- 2)
-- --------------------------------------------
SELECT		t.idTienda, COUNT(v.codigoVenta) AS 'Cantidad de ventas', SUM(cantidad * precio) AS 'Importe total de ventas'
FROM		Tiendas t
INNER JOIN	Ventas v ON v.idTienda = t.idTienda
INNER JOIN	Detalles d ON d.codigoVenta = v.codigoVenta
INNER JOIN	Titulos ti ON ti.idTitulo = d.idTitulo
GROUP BY	idTienda
ORDER BY	2 DESC
;

-- --------------------------------------------
-- 3)
-- --------------------------------------------

DROP PROCEDURE IF EXISTS NuevaEditorial;
DELIMITER $$
CREATE PROCEDURE NuevaEditorial(pIdEditorial char(4), pNombre varchar(40), pCiudad varchar(20), pEstado char(2), pPais varchar(30), OUT pMensaje varchar(100))
SALIR:BEGIN    
    -- Control de campos obligatorios
    IF (pIdEditorial IS NULL) THEN
		SET pMensaje = 'Código de la editorial obligatoria';
        LEAVE SALIR;
	ELSEIF (pNombre IS NULL OR pNombre = '') THEN
		SET pMensaje = 'Nombre obligatorio';
        LEAVE SALIR;
	ELSEIF (pPais IS NULL OR pPais = '') THEN
		SET pMensaje = 'Pais obligatorio';
        LEAVE SALIR;
	END IF;
    
    -- Control del nombre único
    IF EXISTS (SELECT idEditorial FROM Editoriales WHERE nombre = pNombre) THEN
		SET pMensaje = 'Nombre de la editorial ya existente, seleccione otro';
        LEAVE SALIR;
	END IF;
    
    -- Se da de alta una nueva editorial
    INSERT INTO Editoriales (idEditorial, nombre, ciudad, estado, pais) VALUES
							(pIdEditorial, pNombre, pCiudad, pEstado, pPais);
                            
	-- Mensaje de éxito
    SET pMensaje = 'Editorial dada de alta correctamente';
END$$
DELIMITER ;

SET @mensaje = '';
CALL NuevaEditorial("1234", "Editorial prueba 1", "Ciudad prueba 1", "A", "USA", @mensaje); 	-- OK
CALL NuevaEditorial(null, "Editorial prueba 1", "Ciudad prueba 1", "A", "USA", @mensaje); 		-- Código obligatorio
CALL NuevaEditorial("1234", null, "Ciudad prueba 1", "A", "Argentina", @mensaje); 				-- Nombre obligatorio
CALL NuevaEditorial("1234", "Editorial prueba 1", "Ciudad prueba 1", "A", null, @mensaje); 		-- País obligatorio
CALL NuevaEditorial("9874", "Editorial prueba 1", "Ciudad prueba 2", "US", "USA", @mensaje); 	-- Nombre repetido
SELECT @mensaje AS Mensaje;

-- --------------------------------------------
-- 4) Realizar un procedimiento almacenado llamado BuscarTitulosPorAutor que reciba el
-- código de un autor y muestre los títulos del mismo. Por cada título del autor especificado se
-- deberá mostrar su código y título, género, nombre de la editorial, precio, sinopsis y fecha de
-- publicación. La salida, mostrada en la siguiente tabla, deberá estar ordenada
-- alfabéticamente según el título. Incluir en el código la llamada al procedimiento.
-- --------------------------------------------

DROP PROCEDURE IF EXISTS BuscarTitulosPorAutor;
DELIMITER $$
CREATE PROCEDURE BuscarTitulosPorAutor(pIdAutor varchar(11))
BEGIN
	SELECT 		ti.idTitulo AS Código, titulo AS Título, genero AS Género, nombre AS Editorial, precio AS Precio, sinopsis AS Sinopsis, DATE(fechaPublicacion) AS Fecha
	FROM		Titulos ti
	INNER JOIN	TitulosDelAutor ta ON ta.idTitulo = ti.idTitulo
	INNER JOIN	Editoriales e ON e.idEditorial = ti.idEditorial
	WHERE 		idAutor = pIdAutor
	ORDER BY	titulo
	;
END$$
DELIMITER ;

CALL BuscarTitulosPorAutor('213-46-8915');
CALL BuscarTitulosPorAutor('409-56-7008');

-- --------------------------------------------
-- 5)
-- --------------------------------------------

DROP TRIGGER IF EXISTS Editoriales_BEFORE_DELETE;

DELIMITER $$
CREATE TRIGGER Editoriales_BEFORE_DELETE BEFORE DELETE ON Editoriales FOR EACH ROW BEGIN
	IF EXISTS (SELECT idTitulo FROM Titulos WHERE idEditorial = OLD.idEditorial) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: no se puede borrar la editorial por que está referenciada a un título';
	END IF;
END$$
DELIMITER ;

DELETE FROM Editoriales WHERE idEditorial = '0736';
DELETE FROM Editoriales WHERE idEditorial = '1622';