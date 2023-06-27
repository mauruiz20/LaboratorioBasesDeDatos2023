DROP SCHEMA IF EXISTS parcial_2020;
CREATE SCHEMA IF NOT EXISTS parcial_2020;
USE parcial_2020;

DROP TABLE IF EXISTS Clientes;
CREATE TABLE IF NOT EXISTS Clientes
(
    IDCliente    INT         NOT NULL,
    Nombre       VARCHAR(45) NOT NULL,
    Apellido     VARCHAR(45) NOT NULL,
    Direccion    VARCHAR(45) NOT NULL,
    CodigoPostal VARCHAR(8)  NOT NULL,
    Localidad    VARCHAR(45) NOT NULL,
    PRIMARY KEY (IDCliente)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Sucursales;
CREATE TABLE IF NOT EXISTS Sucursales
(
    IDSucursal INT         NOT NULL,
    Domicilio  VARCHAR(45) NOT NULL,
    Localidad  VARCHAR(45) NOT NULL,
    PRIMARY KEY (IDSucursal)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Empleados;
CREATE TABLE IF NOT EXISTS Empleados
(
    Legajo       INT         NOT NULL,
    DNI          INT         NOT NULL,
    Nombre       VARCHAR(45) NOT NULL,
    Apellido     VARCHAR(45) NOT NULL,
    FechaIngreso DATE        NOT NULL,
    Tipo         VARCHAR(14) NOT NULL CHECK (Tipo IN ('Cartero', 'Administrativo')),
    IDSucursal   INT         NOT NULL,
    PRIMARY KEY (Legajo),
    CONSTRAINT FK_Sucursales_37
        FOREIGN KEY (IDSucursal)
            REFERENCES Sucursales (IDSucursal),
    INDEX IX_IDSucursal40 (IDSucursal),
    UNIQUE INDEX UI_DNI (DNI)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Envios;
CREATE TABLE IF NOT EXISTS Envios
(
    CodigoRastreo  VARCHAR(20)   NOT NULL,
    IDRemitente    INT           NOT NULL,
    IDDestinatario INT           NOT NULL,
    Legajo         INT           NOT NULL,
    Precio         DECIMAL(5, 2) NOT NULL,
    PRIMARY KEY (CodigoRastreo),
    CONSTRAINT FK_Clientes_52
        FOREIGN KEY (IDRemitente)
            REFERENCES Clientes (IDCliente),
    INDEX IX_IDRemitente55 (IDRemitente),
    CONSTRAINT FK_Clientes_56
        FOREIGN KEY (IDDestinatario)
            REFERENCES Clientes (IDCliente),
    INDEX IX_IDDestinatario59 (IDDestinatario),
    CONSTRAINT FK_Empleados_60
        FOREIGN KEY (Legajo)
            REFERENCES Empleados (Legajo),
    INDEX IX_Legajo63 (Legajo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Pasan;
CREATE TABLE IF NOT EXISTS Pasan
(
    IDSucursal    INT         NOT NULL,
    CodigoRastreo VARCHAR(20) NOT NULL,
    FechaYHora    DATETIME    NOT NULL,
    PRIMARY KEY (IDSucursal, CodigoRastreo),
    CONSTRAINT FK_Sucursales_73
        FOREIGN KEY (IDSucursal)
            REFERENCES Sucursales (IDSucursal),
    INDEX IX_IDSucursal76 (IDSucursal),
    CONSTRAINT FK_Envios_77
        FOREIGN KEY (CodigoRastreo)
            REFERENCES Envios (CodigoRastreo),
    INDEX IX_CodigoRastreo80 (CodigoRastreo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Encomiendas;
CREATE TABLE IF NOT EXISTS Encomiendas
(
    CodigoRastreo VARCHAR(20) NOT NULL,
    Tipo          VARCHAR(20) NOT NULL CHECK (Tipo IN ('Armada por cliente', 'Armada en el correo')),
    PRIMARY KEY (CodigoRastreo),
    CONSTRAINT FK_Envios89
        FOREIGN KEY (CodigoRastreo)
            REFERENCES Envios (CodigoRastreo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Cartas;
CREATE TABLE IF NOT EXISTS Cartas
(
    CodigoRastreo VARCHAR(20) NOT NULL,
    Tipo          VARCHAR(12) NOT NULL CHECK (Tipo IN ('Simple', 'Certificada', 'Express')),
    Sellado       VARCHAR(5)  NOT NULL CHECK (Sellado IN ('Negro', 'Rojo')),
    PRIMARY KEY (CodigoRastreo),
    CONSTRAINT FK_Envios101
        FOREIGN KEY (CodigoRastreo)
            REFERENCES Envios (CodigoRastreo)
) ENGINE = InnoDB;

--
-- 2)
--

CREATE VIEW RutaEncomienda AS
    SELECT E.CodigoRastreo,
           CONCAT(Rem.Apellido, ', ', Rem.Nombre) AS Remitente,
           CONCAT(Des.Apellido, ', ', Des.Nombre)    Destinatario,
           Domicilio,
           S.Localidad,
           FechaYHora
    FROM Encomiendas E
             INNER JOIN Envios EN ON E.CodigoRastreo = EN.CodigoRastreo
             INNER JOIN Clientes Rem ON EN.IDRemitente = Rem.IDCliente
             INNER JOIN Clientes Des ON EN.IDDestinatario = Des.IDCliente
             INNER JOIN Pasan P ON EN.CodigoRastreo = P.CodigoRastreo
             INNER JOIN Sucursales S ON P.IDSucursal = S.IDSucursal
    ORDER BY FechaYHora DESC
;
SELECT * FROM RutaEncomienda;

--
-- 3)
--

SELECT      IDCliente, CONCAT(Apellido, ', ', Nombre) Cliente, COUNT(E.CodigoRastreo) AS 'Cantidad de envios realizados'
FROM        Clientes C
INNER JOIN  Envios E ON C.IDCliente = E.IDDestinatario
INNER JOIN  Pasan P on E.CodigoRastreo = P.CodigoRastreo
GROUP BY    IDCliente, Cliente
ORDER BY    3 DESC;
