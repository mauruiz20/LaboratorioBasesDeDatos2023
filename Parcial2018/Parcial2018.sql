DROP SCHEMA IF EXISTS parcial_2018;
CREATE SCHEMA IF NOT EXISTS parcial_2018;
USE parcial_2018;

DROP TABLE IF EXISTS Personas;
CREATE TABLE IF NOT EXISTS Personas
(
    dni       INT         NOT NULL,
    apellidos VARCHAR(40) NOT NULL,
    nombres   VARCHAR(40) NOT NULL,
    PRIMARY KEY (dni)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Alumnos;
CREATE TABLE IF NOT EXISTS Alumnos
(
    dni INT     NOT NULL,
    cx  CHAR(7) NOT NULL,
    PRIMARY KEY (dni),
    UNIQUE INDEX UX_cx (cx),
    CONSTRAINT FK_Personas20
        FOREIGN KEY (dni)
            REFERENCES Personas (dni)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Cargos;
CREATE TABLE IF NOT EXISTS Cargos
(
    idCargo INT         NOT NULL,
    cargo   VARCHAR(20) NOT NULL,
    PRIMARY KEY (idCargo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Profesores;
CREATE TABLE IF NOT EXISTS Profesores
(
    dni     INT NOT NULL,
    idCargo INT NOT NULL,
    PRIMARY KEY (dni),
    CONSTRAINT FK_Personas37
        FOREIGN KEY (dni)
            REFERENCES Personas (dni),
    CONSTRAINT FK_Cargos40
        FOREIGN KEY (idCargo)
            REFERENCES Cargos (idCargo),
    INDEX IX_idCargo43 (idCargo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Trabajos;
CREATE TABLE IF NOT EXISTS Trabajos
(
    idTrabajo         INT          NOT NULL,
    titulo            VARCHAR(100) NOT NULL,
    duracion          INT          NOT NULL DEFAULT 6,
    area              VARCHAR(10)  NOT NULL CHECK (area IN ('Hardware', 'Redes', 'Software')),
    fechaPresentacion DATE         NOT NULL,
    fechaAprobacion   DATE         NOT NULL,
    fechaFinalizacion DATE         NULL,
    PRIMARY KEY (idTrabajo),
    UNIQUE INDEX UX_titulo (titulo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS RolesEnTrabajos;
CREATE TABLE IF NOT EXISTS RolesEnTrabajos
(
    idTrabajo INT          NOT NULL,
    dni       INT          NOT NULL,
    rol       VARCHAR(7)   NOT NULL CHECK (rol IN ('Tutor', 'Cotutor', 'Jurado')),
    desde     DATE         NOT NULL,
    hasta     DATE         NULL,
    razon     VARCHAR(100) NULL,
    PRIMARY KEY (idTrabajo, dni),
    CONSTRAINT FK_Trabajos67
        FOREIGN KEY (idTrabajo)
            REFERENCES Trabajos (idTrabajo),
    INDEX IX_idTrabajo67 (idTrabajo),
    CONSTRAINT FK_Profesores70
        FOREIGN KEY (dni)
            REFERENCES Profesores (dni),
    INDEX IX_dni70 (dni)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS AlumnosEnTrabajos;
CREATE TABLE IF NOT EXISTS AlumnosEnTrabajos
(
    idTrabajo INT          NOT NULL,
    dni       INT          NOT NULL,
    desde     DATE         NOT NULL,
    hasta     DATE         NULL,
    razon     VARCHAR(100) NULL,
    PRIMARY KEY (idTrabajo, dni),
    CONSTRAINT FK_Trabajos92
        FOREIGN KEY (idTrabajo)
            REFERENCES Trabajos (idTrabajo),
    INDEX IX_idTrabajo92 (idTrabajo),
    CONSTRAINT FK_Alumnos_96
        FOREIGN KEY (dni)
            REFERENCES Alumnos (dni),
    INDEX IX_dni99 (dni)
) ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- 2
-- -----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS DetalleRoles;
DELIMITER //
CREATE PROCEDURE DetalleRoles(pFechaInicio date, pFechaFin date)
SALIR:
BEGIN
    -- Descripcion
    /*
    Crear un procedimiento llamado DetalleRoles, que reciba un rango de años y que muestre:
    Año, DNI, Apellidos, Nombres, Tutor, Cotutor y Jurado, donde Tutor, Cotutor y Jurado muestran
    la cantidad de trabajos en los que un profesor participó en un trabajo con ese rol entre el rango
    de fechas especificado. El listado se mostrará ordenado por año, apellidos, nombres y DNI (se
    pueden emplear vistas u otras estructuras para lograr la funcionalidad solicitada. Para obtener
    el año de una fecha se puede emplear la función YEAR().
    */
    SELECT YEAR(desde) AS                 'Año',
           Apellidos,
           pe.DNI,
           Nombres,
           SUM(IF(rol = 'Tutor', 1, 0))   'Tutor',
           SUM(IF(rol = 'Cotutor', 1, 0)) 'Cotutor',
           SUM(IF(rol = 'Jurado', 1, 0))  'Jurado'
    FROM Personas pe
             INNER JOIN Profesores pr on pe.dni = pr.dni
             INNER JOIN RolesEnTrabajos r on pr.dni = r.dni
    WHERE desde BETWEEN pFechaInicio AND pFechaFin
    GROUP BY Año, Apellidos, pe.DNI, Nombres
    ORDER BY Año, Apellidos, Nombres, DNI;
END //
DELIMITER ;

CALL DetalleRoles('2000-01-01', '2025-12-31');