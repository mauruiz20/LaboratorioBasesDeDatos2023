DROP SCHEMA IF EXISTS parcial_2020_2;
CREATE SCHEMA IF NOT EXISTS parcial_2020_2;
USE parcial_2020_2;

DROP TABLE IF EXISTS Exhibiciones;
CREATE TABLE IF NOT EXISTS Exhibiciones
(
    IDExhibicion INT          NOT NULL,
    Titulo       VARCHAR(50)  NOT NULL,
    Descripcion  VARCHAR(200) NULL,
    Inauguracion DATE         NOT NULL,
    Clausura     DATE         NULL,
    PRIMARY KEY (IDExhibicion),
    INDEX IX_Titulo14 (Titulo),
    CHECK (Clausura IS NOT NULL AND Inauguracion < Clausura)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Pintores;
CREATE TABLE IF NOT EXISTS Pintores
(
    IDPintor     INT         NOT NULL,
    Apellidos    VARCHAR(30) NOT NULL,
    Nombres      VARCHAR(30) NOT NULL,
    Nacionalidad VARCHAR(30) NOT NULL,
    PRIMARY KEY (IDPintor),
    INDEX IX_ApellidosNombres24 (Apellidos, Nombres)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Metodos;
CREATE TABLE IF NOT EXISTS Metodos
(
    IDMetodo INT         NOT NULL,
    Metodo   VARCHAR(30) NOT NULL,
    PRIMARY KEY (IDMetodo),
    UNIQUE INDEX UI_Metodo (Metodo)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Cuadros;
CREATE TABLE IF NOT EXISTS Cuadros
(
    IDCuadro INT            NOT NULL,
    IDPintor INT            NOT NULL,
    IDMetodo INT            NOT NULL,
    Titulo   VARCHAR(60)    NOT NULL,
    Fecha    DATE           NOT NULL,
    Precio   DECIMAL(12, 2) NOT NULL CHECK (Precio > 0),
    PRIMARY KEY (IDCuadro, IDPintor),
    UNIQUE INDEX UI_IDCuadro (IDCuadro),
    CONSTRAINT FK_Pintores_45
        FOREIGN KEY (IDPintor)
            REFERENCES Pintores (IDPintor),
    INDEX IX_IDPintor48 (IDPintor),
    CONSTRAINT FK_Metodos_49
        FOREIGN KEY (IDMetodo)
            REFERENCES Metodos (IDMetodo),
    INDEX IX_IDMetodo52 (IDMetodo),
    INDEX IX_Titulo56 (Titulo),
    INDEX IX_Fecha57 (Fecha)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Certamenes;
CREATE TABLE IF NOT EXISTS Certamenes
(
    IDCuadro     INT NOT NULL,
    IDPintor     INT NOT NULL,
    IDExhibicion INT NOT NULL,
    PRIMARY KEY (IDCuadro, IDPintor, IDExhibicion),
    CONSTRAINT FK_Cuadros_62
        FOREIGN KEY (IDCuadro, IDPintor)
            REFERENCES Cuadros (IDCuadro, IDPintor),
    INDEX IX_IDCuadro65 (IDCuadro, IDPintor),
    INDEX IX_IDPintor69 (IDPintor),
    CONSTRAINT FK_Exhibiciones_70
        FOREIGN KEY (IDExhibicion)
            REFERENCES Exhibiciones (IDExhibicion),
    INDEX IX_IDExhibicion73 (IDExhibicion)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Propuestas;
CREATE TABLE IF NOT EXISTS Propuestas
(
    IDPropuesta  CHAR(10)       NOT NULL,
    IDCuadro     INT            NOT NULL,
    IDPintor     INT            NOT NULL,
    IDExhibicion INT            NOT NULL,
    Fecha        DATE           NULL,
    Importe      DECIMAL(12, 2) NOT NULL CHECK (Importe > 0),
    Persona      VARCHAR(100)   NOT NULL,
    Vendido      CHAR(1)        NOT NULL CHECK (Vendido IN ('S', 'N')),
    PRIMARY KEY (IDPropuesta, IDCuadro, IDPintor, IDExhibicion),
    UNIQUE INDEX UI_IDPropuesta (IDPropuesta),
    CONSTRAINT FK_Certamenes_88
        FOREIGN KEY (IDCuadro, IDPintor, IDExhibicion)
            REFERENCES Certamenes (IDCuadro, IDPintor, IDExhibicion),
    INDEX IX_CuadroPintorExhibicion (IDCuadro, IDPintor, IDExhibicion),
    INDEX IX_IDPintor95 (IDPintor),
    INDEX IX_IDExhibicion99 (IDExhibicion),
    INDEX IX_Fecha93 (Fecha),
    INDEX IX_Persona96 (Persona)
) ENGINE = InnoDB;

-- -----------------------------------
-- 2)
-- -----------------------------------

DROP PROCEDURE IF EXISTS BorrarCuadro;
DELIMITER //
CREATE PROCEDURE BorrarCuadro(pIDCuadro int, OUT pMensaje varchar(100))
SALIR:
BEGIN
    IF pIDCuadro IS NULL OR NOT EXISTS (SELECT IDCuadro FROM Cuadros WHERE IDCuadro = pIDCuadro) THEN
        SET pMensaje = 'El cuadro no existe.';
        LEAVE SALIR;
    END IF;

    IF EXISTS (SELECT IDCuadro FROM Certamenes WHERE IDCuadro = pIDCuadro) THEN
        SET pMensaje = 'No se puede borrar el cuadro por que posee certamenes asociados.';
        LEAVE SALIR;
    END IF;

    DELETE FROM Cuadros WHERE IDCuadro = pIDCuadro;

    SET pMensaje = 'Cuadro borrado con éxito.';
END //
DELIMITER ;

SET @mensaje = '';
CALL BorrarCuadro(20, @mensaje); -- Certamen asociado
SELECT @mensaje;
CALL BorrarCuadro(100, @mensaje); -- Cuadro no existente
SELECT @mensaje;
CALL BorrarCuadro(null, @mensaje); -- Cuadro no existente
SELECT @mensaje;
INSERT INTO Cuadros
VALUES (31, 6, 3, 'Música y Danza', '1936-04-19', 3500000);
CALL BorrarCuadro(31, @mensaje); -- OK
SELECT @mensaje;

-- -----------------------------------
-- 3)
-- -----------------------------------

DROP PROCEDURE IF EXISTS EstadoCuadros;
DELIMITER //
CREATE PROCEDURE EstadoCuadros(pIDPintor int)
SALIR:
BEGIN
    SELECT C.IDCuadro,
       Titulo,
       Precio,
       COALESCE(MAX(Importe), 0)                                                                          AS MejorPropuesta,
       (SELECT P.Vendido FROM Propuestas P WHERE P.IDCuadro = C.IDCuadro ORDER BY P.Importe DESC LIMIT 1) AS Vendido,
       MAX(Importe - Precio)                                                                              AS Ganancia
    FROM Cuadros C
             LEFT JOIN Propuestas P on C.IDCuadro = P.IDCuadro
    WHERE P.IDPintor = pIDPintor
    GROUP BY C.IDCuadro, Titulo, Precio;
END //
DELIMITER ;

CALL EstadoCuadros(1);

-- -----------------------------------
-- 4)
-- -----------------------------------

CREATE VIEW VentasCuadros AS
SELECT C.IDCuadro,
       C.Titulo AS                      TituloCuadro,
       Metodo,
       C.IDPintor,
       CONCAT(Apellidos, ', ', Nombres) Pintor,
       E.IDExhibicion,
       E.Titulo AS                      TituloExhibicion,
       P.Fecha  AS                      FechaVenta,
       Persona  AS                      Comprador,
       Importe
FROM Cuadros C
         INNER JOIN Propuestas P on C.IDCuadro = P.IDCuadro AND C.IDPintor = P.IDPintor
         INNER JOIN Metodos M on C.IDMetodo = M.IDMetodo
         INNER JOIN Pintores PI on C.IDPintor = PI.IDPintor
         INNER JOIN Exhibiciones E on P.IDExhibicion = E.IDExhibicion
WHERE Vendido = 'S';

SELECT *
FROM VentasCuadros;

-- -----------------------------------
-- 5)
-- -----------------------------------

DROP TABLE IF EXISTS AUD_Cuadros;
CREATE TABLE IF NOT EXISTS AUD_Cuadros
(
    Id         BIGINT         NOT NULL AUTO_INCREMENT,
    FechaAud   DATETIME       NOT NULL,
    UsuarioAud VARCHAR(30)    NOT NULL,
    Maquina    VARCHAR(40)    NOT NULL,
    TipoAud    CHAR(1)        NOT NULL, -- Insercion(I), Borrado(B), Modificacion (A: Antes - D: Despues)
    IDCuadro   INT            NOT NULL,
    IDPintor   INT            NOT NULL,
    IDMetodo   INT            NOT NULL,
    Titulo     VARCHAR(60)    NOT NULL,
    Fecha      DATE           NOT NULL,
    Precio     DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (Id),
    INDEX IX_FechaAud (FechaAud),
    INDEX IX_UsuarioAud (UsuarioAud),
    INDEX IX_Titulo56 (Titulo),
    INDEX IX_Fecha57 (Fecha)
) ENGINE = InnoDB;

CREATE TRIGGER Cuadros_AFTER_DELETE
    AFTER DELETE
    ON Cuadros
    FOR EACH ROW
BEGIN
    INSERT INTO AUD_Cuadros
    VALUES (0,
            NOW(),
            SUBSTRING_INDEX(USER(), '@', 1),
            SUBSTRING_INDEX(USER(), '@', -1),
            'B',
            OLD.IDCuadro,
            OLD.IDPintor,
            OLD.IDMetodo,
            OLD.Titulo,
            OLD.Fecha,
            OLD.Precio);
END;

INSERT INTO Cuadros
VALUES (31, 6, 3, 'Música y Danza', '1936-04-19', 3500000);
CALL BorrarCuadro(31, @mensaje); -- OK
SELECT @mensaje;
SELECT *
FROM AUD_Cuadros;