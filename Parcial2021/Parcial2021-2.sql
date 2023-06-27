DROP SCHEMA IF EXISTS parcial_2021_2;
CREATE SCHEMA IF NOT EXISTS parcial_2021_2;
USE parcial_2021_2;

DROP TABLE IF EXISTS Actores;
CREATE TABLE IF NOT EXISTS Actores
(
    idActor   CHAR(10)    NOT NULL,
    apellidos VARCHAR(50) NULL,
    nombres   VARCHAR(50) NOT NULL,
    PRIMARY KEY (idActor)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Peliculas;
CREATE TABLE IF NOT EXISTS Peliculas
(
    idPelicula    INT          NOT NULL,
    titulo        VARCHAR(128) NOT NULL,
    clasificacion VARCHAR(5)   NOT NULL DEFAULT 'G' CHECK (clasificacion IN ('G', 'PG', 'PG-13', 'R', 'NC-17')),
    estreno       INT          NULL,
    durecion      INT          NULL,
    PRIMARY KEY (idPelicula),
    UNIQUE INDEX UI_titulo (titulo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS ActoresDePeliculas;
CREATE TABLE IF NOT EXISTS ActoresDePeliculas
(
    idActor    CHAR(10) NOT NULL,
    idPelicula INT      NOT NULL,
    PRIMARY KEY (idActor, idPelicula),
    CONSTRAINT FK_Actores_31
        FOREIGN KEY (idActor)
            REFERENCES Actores (idActor),
    INDEX IX_idActor34 (idActor),
    CONSTRAINT FK_Peliculas_35
        FOREIGN KEY (idPelicula)
            REFERENCES Peliculas (idPelicula),
    INDEX IX_idPelicula38 (idPelicula)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Direcciones;
CREATE TABLE IF NOT EXISTS Direcciones
(
    idDireccion  INT         NOT NULL,
    calleYNumero VARCHAR(50) NOT NULL,
    codigoPostal VARCHAR(10) NULL,
    telefono     VARCHAR(25) NOT NULL,
    municipio    VARCHAR(25) NULL,
    PRIMARY KEY (idDireccion),
    UNIQUE INDEX UI_calleYNumero (calleYNumero)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Empleados;
CREATE TABLE IF NOT EXISTS Empleados
(
    idEmpleado  INT         NOT NULL,
    apellidos   VARCHAR(50) NOT NULL,
    nombres     VARCHAR(50) NOT NULL,
    correo      VARCHAR(50) NULL,
    estado      CHAR(1)     NOT NULL DEFAULT 'E' CHECK (estado IN ('E', 'D')),
    idDireccion INT         NOT NULL,
    PRIMARY KEY (idEmpleado),
    CONSTRAINT FK_Direcciones_62
        FOREIGN KEY (idDireccion)
            REFERENCES Direcciones (idDireccion),
    INDEX IX_idDireccion65 (idDireccion),
    UNIQUE INDEX UI_correo (correo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Sucursales;
CREATE TABLE IF NOT EXISTS Sucursales
(
    idSucursal  CHAR(10) NOT NULL,
    idDireccion INT      NOT NULL,
    idGerente   INT      NOT NULL,
    PRIMARY KEY (idSucursal),
    CONSTRAINT FK_Direcciones_75
        FOREIGN KEY (idDireccion)
            REFERENCES Direcciones (idDireccion),
    INDEX IX_idDireccion78 (idDireccion),
    CONSTRAINT FK_Empleados_79
        FOREIGN KEY (idGerente)
            REFERENCES Empleados (IdEmpleado),
    INDEX IX_idGerente82 (idGerente)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Inventario;
CREATE TABLE IF NOT EXISTS Inventario
(
    idInventario INT      NOT NULL,
    idPelicula   INT      NOT NULL,
    idSucursal   CHAR(10) NOT NULL,
    PRIMARY KEY (idInventario),
    CONSTRAINT FK_Peliculas_92
        FOREIGN KEY (idPelicula)
            REFERENCES Peliculas (idPelicula),
    INDEX IX_idPelicula95 (idPelicula),
    CONSTRAINT FK_Sucursales_96
        FOREIGN KEY (idSucursal)
            REFERENCES Sucursales (idSucursal),
    INDEX IX_idSucursal99 (idSucursal)
) ENGINE = InnoDB;

-- ---------------------------------------------
-- 2)
-- ---------------------------------------------

DROP VIEW IF EXISTS VCantidadPeliculasEnSucursales;
CREATE VIEW VCantidadPeliculasEnSucursales AS
SELECT titulo                           AS 'Título',
       I.idSucursal,
       calleYNumero                     AS 'Calle y número',
       COUNT(I.idInventario)            AS Cantidad,
       CONCAT(apellidos, ', ', nombres) AS Gerente
FROM Peliculas P
         INNER JOIN Inventario I ON P.idPelicula = I.idPelicula
         INNER JOIN Sucursales S ON I.idSucursal = S.idSucursal
         INNER JOIN Direcciones D ON S.idDireccion = D.idDireccion
         INNER JOIN Empleados E ON S.idGerente = E.idEmpleado
GROUP BY titulo, I.idSucursal, calleYNumero, Gerente
ORDER BY titulo;

SELECT *
FROM VCantidadPeliculasEnSucursales;

-- ---------------------------------------------
-- 3)
-- ---------------------------------------------

DROP PROCEDURE IF EXISTS ModificarDireccion;
DELIMITER //
CREATE PROCEDURE ModificarDireccion(pIdDireccion int, pCalleyNumero varchar(50), pCodigoPostal varchar(10),
                                    pTelefono varchar(25),
                                    pMunicipio varchar(25), OUT pMensaje varchar(100))
SALIR:
BEGIN
    IF pCalleyNumero IS NOT NULL AND TRIM(pCalleyNumero) = '' THEN
        SET pMensaje = 'La calle y el número es obligatorio.';
        LEAVE SALIR;
    END IF;

    IF pTelefono IS NOT NULL AND TRIM(pTelefono) = '' THEN
        SET pMensaje = 'El teléfono es obligatorio.';
        LEAVE SALIR;
    END IF;

    IF NOT EXISTS(SELECT idDireccion FROM Direcciones WHERE idDireccion = pIdDireccion) THEN
        SET pMensaje = 'La dirección que se quiere modificar no existe.';
        LEAVE SALIR;
    END IF;

    IF pCalleyNumero IS NOT NULL AND
       EXISTS (SELECT idDireccion
               FROM Direcciones
               WHERE calleYNumero = pCalleyNumero
                 AND idDireccion != pIdDireccion) THEN
        SET pMensaje = 'La calle y el número ya están usados, elija otros.';
        LEAVE SALIR;
    END IF;

    UPDATE Direcciones
    SET calleYNumero = COALESCE(pCalleyNumero, calleYNumero),
        codigoPostal = pCodigoPostal,
        telefono     = COALESCE(pTelefono, telefono),
        municipio    = pMunicipio
    WHERE idDireccion = pIdDireccion;

    SET pMensaje = 'Dirección modificada con éxito.';
END //
DELIMITER ;

SET @mensaje = '';
CALL ModificarDireccion(1, 'San Juan 730', '4000', '3811234567', 'San Miguel', @mensaje);
SELECT @mensaje;
CALL ModificarDireccion(5000, 'San Juan 730', '4000', '3811234567', 'San Miguel', @mensaje);
SELECT @mensaje;
CALL ModificarDireccion(-1, 'San Juan 730', '4000', '3811234567', 'San Miguel', @mensaje);
SELECT @mensaje;
CALL ModificarDireccion(1, '28 MySQL Boulevard', '4000', '3811234567', 'San Miguel', @mensaje);
SELECT @mensaje;
CALL ModificarDireccion(1, '', '4000', '3811234567', 'San Miguel', @mensaje);
SELECT @mensaje;
CALL ModificarDireccion(1, 'San Juan 730', '4000', '', 'San Miguel', @mensaje);
SELECT @mensaje;

-- ---------------------------------------------
-- 4) Realizar un procedimiento almacenado llamado TotalPeliculas que muestre por cada
-- actor su código, apellido y nombre (formato: apellido, nombre) y cantidad de películas en las
-- que participó. Al final del listado se deberá mostrar también la cantidad total de películas. La
-- salida deberá estar ordenada alfabéticamente según el apellido y nombre del actor. Incluir
-- en el código la llamada al procedimiento.
-- ---------------------------------------------

DROP PROCEDURE IF EXISTS TotalPeliculas;

DELIMITER //
CREATE PROCEDURE TotalPeliculas()
SALIR:
BEGIN
    (SELECT A.idActor, CONCAT(apellidos, ', ', nombres) AS Autor, COUNT(ADP.idPelicula) AS Cantidad
     FROM Actores A
              INNER JOIN ActoresDePeliculas ADP ON A.idActor = ADP.idActor
              INNER JOIN Peliculas P ON ADP.idPelicula = P.idPelicula
     GROUP BY A.idActor, Autor
     )

    UNION

    (SELECT null, null, COUNT(ADP.idPelicula) AS Cantidad
     FROM Actores A
              INNER JOIN ActoresDePeliculas ADP ON A.idActor = ADP.idActor
              INNER JOIN Peliculas P ON ADP.idPelicula = P.idPelicula
     )
    ORDER BY (Autor IS NULL), Autor;
END //
DELIMITER ;

CALL TotalPeliculas();

-- ---------------------------------------------
-- 5) Utilizando triggers, implementar la lógica para que en caso que se quiera modificar una
-- película especificando el título de otra película existente se informe mediante un mensaje
-- de error que no se puede. Incluir el código con la modificación del título de una película con
-- un valor distinto a cualquiera de las que ya hubiera definidas y otro con un valor igual a otra
-- que ya hubiera definida.
-- ---------------------------------------------

DROP TRIGGER IF EXISTS Peliculas_BEFORE_UPDATE;

DELIMITER //
CREATE TRIGGER Peliculas_BEFORE_UPDATE BEFORE UPDATE ON Peliculas FOR EACH ROW
BEGIN
	IF EXISTS (SELECT idPelicula FROM Peliculas WHERE titulo = NEW.titulo AND idPelicula != NEW.idPelicula) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: no se puede modificar el título por que ya está usado.';
    END IF;
END //
DELIMITER ;

UPDATE Peliculas SET titulo = 'ACADEMY DINOSAUR' WHERE idPelicula = 2;  -- Error
UPDATE Peliculas SET titulo = 'San Martin 500' WHERE idPelicula = 2;    -- OK