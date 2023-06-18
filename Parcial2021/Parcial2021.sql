-- --------------------------------------------------------
-- 1) Según el modelo lógico de la figura, crear los objetos necesarios. Los nombres de los
-- géneros, las direcciones de correo, los títulos de las películas y la calle y número de una
-- dirección deben ser únicos. La clasificación de una película puede tomar los valores
-- 'G','PG','PG-13','R' o 'NC-17' (por defecto ‘G’). El estado de un personal puede tomar los
-- valores 'E' o 'D' (por defecto ‘E’). Deberá haber índices por las claves primarias y
-- propagadas. Finalmente, ejecutar el script Datos.sql.
-- --------------------------------------------------------

-- -----------------------------------------------------
-- Schema parcial_2021
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS parcial_2021 ;
CREATE SCHEMA IF NOT EXISTS parcial_2021 ;
USE parcial_2021 ;

-- -----------------------------------------------------
-- Table Peliculas
-- -----------------------------------------------------
DROP TABLE IF EXISTS Peliculas ;

CREATE TABLE IF NOT EXISTS Peliculas (
  idPelicula INT NOT NULL,
  titulo VARCHAR(128) NOT NULL,
  estreno INT NULL,
  duracion INT NULL,
  clasificacion VARCHAR(10) NOT NULL DEFAULT 'G' CHECK (clasificacion IN ('G','PG','PG-13','R','NC-17')),
  PRIMARY KEY (idPelicula),
  UNIQUE INDEX UI_Titulo (titulo ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Generos
-- -----------------------------------------------------
DROP TABLE IF EXISTS Generos ;

CREATE TABLE IF NOT EXISTS Generos (
  idGenero CHAR(10) NOT NULL,
  nombre VARCHAR(25) NOT NULL,
  PRIMARY KEY (idGenero),
  UNIQUE INDEX UI_Nombre (nombre ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Direcciones
-- -----------------------------------------------------
DROP TABLE IF EXISTS Direcciones ;

CREATE TABLE IF NOT EXISTS Direcciones (
  idDireccion INT NOT NULL,
  calleYNumero VARCHAR(50) NOT NULL,
  municipio VARCHAR(20) NOT NULL,
  codigoPostal VARCHAR(10) NULL,
  telefono VARCHAR(20) NOT NULL,
  PRIMARY KEY (idDireccion),
  UNIQUE INDEX UI_CalleYNumero (calleYNumero ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Personal
-- -----------------------------------------------------
DROP TABLE IF EXISTS Personal ;

CREATE TABLE IF NOT EXISTS Personal (
  idPersonal INT NOT NULL,
  nombres VARCHAR(45) NOT NULL,
  apellidos VARCHAR(45) NOT NULL,
  idDireccion INT NOT NULL,
  correo VARCHAR(50) NULL,
  estado CHAR(1) NOT NULL DEFAULT 'E' CHECK (estado = 'E' OR estado = 'D'),
  PRIMARY KEY (idPersonal),
  UNIQUE INDEX UI_Correo (correo ASC) VISIBLE,
  INDEX FK_Personal_Direcciones_idx (idDireccion ASC) VISIBLE,
  CONSTRAINT FK_Personal_Direcciones
    FOREIGN KEY (idDireccion)
    REFERENCES Direcciones (idDireccion)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Sucursales
-- -----------------------------------------------------
DROP TABLE IF EXISTS Sucursales ;

CREATE TABLE IF NOT EXISTS Sucursales (
  idSucursal CHAR(10) NOT NULL,
  idGerente INT NOT NULL,
  idDireccion INT NOT NULL,
  PRIMARY KEY (idSucursal),
  INDEX FK_Sucursales_Personal1_idx (idGerente ASC) VISIBLE,
  INDEX FK_Sucursales_Direcciones1_idx (idDireccion ASC) VISIBLE,
  CONSTRAINT FK_Sucursales_Personal1
    FOREIGN KEY (idGerente)
    REFERENCES Personal (idPersonal)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT FK_Sucursales_Direcciones1
    FOREIGN KEY (idDireccion)
    REFERENCES Direcciones (idDireccion)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Inventario
-- -----------------------------------------------------
DROP TABLE IF EXISTS Inventario ;

CREATE TABLE IF NOT EXISTS Inventario (
  idInventario INT NOT NULL,
  idPelicula INT NOT NULL,
  IdSucursal CHAR(10) NOT NULL,
  PRIMARY KEY (idInventario),
  INDEX FK_Inventario_Sucursales1_idx (IdSucursal ASC) VISIBLE,
  INDEX FK_Inventario_Peliculas1_idx (idPelicula ASC) VISIBLE,
  CONSTRAINT FK_Inventario_Sucursales1
    FOREIGN KEY (IdSucursal)
    REFERENCES Sucursales (idSucursal)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT FK_Inventario_Peliculas1
    FOREIGN KEY (idPelicula)
    REFERENCES Peliculas (idPelicula)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table GenerosDePeliculas
-- -----------------------------------------------------
DROP TABLE IF EXISTS GenerosDePeliculas ;

CREATE TABLE IF NOT EXISTS GenerosDePeliculas (
  idPelicula INT NOT NULL,
  idGenero CHAR(10) NOT NULL,
  PRIMARY KEY (idPelicula, idGenero),
  INDEX FK_GenerosDePeliculas_Peliculas1_idx (idPelicula ASC) VISIBLE,
  CONSTRAINT FK_GenerosDePeliculas_Generos1
    FOREIGN KEY (idGenero)
    REFERENCES Generos (idGenero)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT FK_GenerosDePeliculas_Peliculas1
    FOREIGN KEY (idPelicula)
    REFERENCES Peliculas (idPelicula)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- --------------------------------------------------------
-- 2) Crear una vista llamada VCantidadPeliculas que muestre por cada película su código,
-- título y la cantidad total entre las distintas sucursales. La salida deberá estar ordenada
-- alfabéticamente según el título de las películas. Incluir el código con la consulta a la vista.
-- --------------------------------------------------------

DROP VIEW IF EXISTS VCantidadPeliculas;
CREATE VIEW VCantidadPeliculas AS
	SELECT		p.idPelicula, titulo AS Título, COUNT(p.idPelicula) AS Cantidad
	FROM		Peliculas p
	INNER JOIN	Inventario i ON i.idPelicula = p.idPelicula
	INNER JOIN	Sucursales s ON s.idSucursal = i.idSucursal
	GROUP BY	titulo
	ORDER BY	titulo
;
SELECT * FROM VCantidadPeliculas;

-- --------------------------------------------------------
-- 3) Realizar un procedimiento almacenado llamado NuevaDireccion para dar de alta una
-- dirección, incluyendo el control de errores lógicos y mensajes de error necesarios
-- (implementar la lógica del manejo de errores empleando parámetros de salida). Incluir el
-- código con la llamada al procedimiento probando todos los casos con datos incorrectos y
-- uno con datos correctos.
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS NuevaDireccion;
DELIMITER $$
CREATE PROCEDURE NuevaDireccion(pCalleYNumero varchar(50), pMunicipio varchar(20), pCodigoPostal varchar(10), pTelefono varchar(20), OUT mensaje varchar(100))
SALIR:BEGIN
	-- Variable auxiliar
	DECLARE ultimoIdInsertado int;
    
    -- Control de campos obligatorios
	IF (pCalleYNumero IS NULL OR pCalleYNumero = '') THEN
		SET mensaje = 'Calle y número obligatorio';
        LEAVE SALIR;
	ELSEIF (pMunicipio IS NULL OR pMunicipio = '') THEN
		SET mensaje = 'Municipio obligatorio';
        LEAVE SALIR;
	ELSEIF (pTelefono IS NULL OR pTelefono = '') THEN
		SET mensaje = 'Teléfono obligatorio';
        LEAVE SALIR;
	END IF;
    
    -- Control de calle y número únicos
    IF EXISTS (SELECT idDireccion FROM Direcciones WHERE calleYNumero = pCalleYNumero) THEN
		SET mensaje = 'Calle y número ya existentes, seleccione otro';
        LEAVE SALIR;
	END IF;
    
    -- Averiguo el último id insertado
    SET ultimoIdInsertado = (SELECT COALESCE(MAX(idDireccion), 0) FROM Direcciones);
    
    -- Se da de alta una nueva dirección
    INSERT INTO Direcciones (idDireccion, calleYNumero, municipio, codigoPostal, telefono) VALUES
							(ultimoIdInsertado + 1, pCalleYNumero, pMunicipio, pCodigoPostal, pTelefono);
                            
	-- Mensaje de éxito
    SET mensaje = 'Dirección dada de alta correctamente';
END$$
DELIMITER ;


SET @mensaje = '';
CALL NuevaDireccion("San Juan 750", "San Miguel de Tuc", "4000", "3811234567", @mensaje); 	-- OK
CALL NuevaDireccion("San Juan 750", "San Miguel de Tuc", "4000", "3811234567", @mensaje); 	-- Calle y número duplicados
CALL NuevaDireccion(null, "San Miguel de Tuc", "4000", "3811234567", @mensaje); 			-- Calle y número obligatorio
CALL NuevaDireccion("San Juan 750", null, "4000", "3811234567", @mensaje); 					-- Municipio obligatorio
CALL NuevaDireccion("San Juan 750", "San Miguel de Tuc", "4000", null, @mensaje); 			-- Telefono obligatorio
SELECT @mensaje AS Mensaje;

-- --------------------------------------------------------
-- 4) Realizar un procedimiento almacenado llamado BuscarPeliculasPorGenero que reciba
-- el código de un género y muestre sucursal por sucursal, película por película, la cantidad
-- con el mismo. Por cada película del género especificado se deberá mostrar su código y
-- título, el código de la sucursal, la cantidad y la calle y número de la sucursal. La salida
-- deberá estar ordenada alfabéticamente según el título de las películas. Incluir en el código
-- la llamada al procedimiento.
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS BuscarPeliculasPorGenero;
DELIMITER $$
CREATE PROCEDURE BuscarPeliculasPorGenero(pIdGenero char(10))
BEGIN
	SELECT		p.idPelicula, titulo AS Título, s.idSucursal, COUNT(p.idPelicula) AS Cantidad, calleYNumero AS 'Calle y número'
	FROM		Peliculas p
	INNER JOIN	GenerosDePeliculas gp ON gp.idPelicula = p.idPelicula
	INNER JOIN	Inventario i ON i.idPelicula = p.idPelicula
	INNER JOIN	Sucursales s ON s.idSucursal = i.idSucursal
	INNER JOIN	Direcciones d ON d.idDireccion = s.idDireccion
	WHERE		idGenero = pIdGenero
	GROUP BY	titulo, idSucursal, calleYNumero
	ORDER BY	titulo
	;
END$$
DELIMITER ;

CALL BuscarPeliculasPorGenero(6);
CALL BuscarPeliculasPorGenero(1);
CALL BuscarPeliculasPorGenero(0);

-- --------------------------------------------------------
-- 5) Utilizando triggers, implementar la lógica para que en caso que se quiera borrar una
-- dirección referenciada por una sucursal o un personal se informe mediante un mensaje de
-- error que no se puede. Incluir el código con los borrados de una dirección para la cual no
-- hay sucursales ni personal, y otro para la que sí.
-- --------------------------------------------------------

DELIMITER $$
CREATE TRIGGER Direcciones_BEFORE_DELETE BEFORE DELETE ON Direcciones FOR EACH ROW BEGIN
	IF EXISTS (SELECT idPersonal FROM Personal WHERE idDireccion = OLD.idDireccion) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: no se puede borrar la dirección por que está asociada a un personal';
	END IF;
    
    IF EXISTS (SELECT idSucursal FROM Sucursales WHERE idDireccion = OLD.idDireccion) THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Error: no se puede borrar la dirección por que está asociada a una sucursal';
	END IF;
END$$
DELIMITER ;

SELECT * FROM Sucursales;
SELECT * FROM Personal;

DELETE FROM Direcciones WHERE idDireccion = 1;		-- Tiene sucursal
DELETE FROM Direcciones WHERE idDireccion = 3;		-- Tiene personal
DELETE FROM Direcciones WHERE idDireccion = 606;	-- No tiene sucursal ni personal