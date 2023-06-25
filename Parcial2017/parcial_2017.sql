DROP SCHEMA IF EXISTS parcial_2017;
CREATE SCHEMA IF NOT EXISTS parcial_2017;
USE parcial_2017;

DROP TABLE IF EXISTS Categorias;
CREATE TABLE IF NOT EXISTS Categorias
(
    IdCategoria INT         NOT NULL,
    Nombre      VARCHAR(50) NOT NULL,
    PRIMARY KEY (IdCategoria),
    UNIQUE INDEX UI_Nombre (Nombre)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Productos;
CREATE TABLE IF NOT EXISTS Productos
(
    IdProducto  INT            NOT NULL,
    Nombre      VARCHAR(50)    NOT NULL,
    Color       VARCHAR(15)    NULL,
    Precio      DECIMAL(10, 4) NOT NULL,
    IdCategoria INT            NULL,
    PRIMARY KEY (IdProducto),
    UNIQUE INDEX UI_Nombre (Nombre),
    CONSTRAINT FK_Categorias_23
        FOREIGN KEY (IdCategoria)
            REFERENCES Categorias (IdCategoria),
    INDEX IX_IdCategoria26 (IdCategoria)
) ENGINE = InnoDB;


DROP TABLE IF EXISTS Ofertas;
CREATE TABLE IF NOT EXISTS Ofertas
(
    IdOferta       INT      NOT NULL,
    Descuento      FLOAT    NOT NULL DEFAULT 0.05,
    FechaInicio    DATETIME NOT NULL DEFAULT NOW(),
    FechaFin       DATETIME NOT NULL,
    CantidadMinima INT      NOT NULL DEFAULT 1,
    CantidadMaxima INT      NULL,
    PRIMARY KEY (IdOferta),
    INDEX IX_FechaInicio23 (FechaInicio),
    INDEX IX_FechaFin24 (FechaFin)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS OfertasDelProducto;
CREATE TABLE IF NOT EXISTS OfertasDelProducto
(
    IdProducto INT NOT NULL,
    IdOferta   INT NOT NULL,
    PRIMARY KEY (IdProducto, IdOferta),
    CONSTRAINT FK_Productos_50
        FOREIGN KEY (IdProducto)
            REFERENCES Productos (IdProducto),
    INDEX IX_IdProducto53 (IdProducto),
    CONSTRAINT FK_Ofertas_54
        FOREIGN KEY (IdOferta)
            REFERENCES Ofertas (IdOferta),
    INDEX IX_IdOferta57 (IdOferta)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Clientes;
CREATE TABLE IF NOT EXISTS Clientes
(
    IdCliente INT         NOT NULL,
    Apellidos VARCHAR(50) NOT NULL,
    Nombres   VARCHAR(50) NOT NULL,
    Telefono  VARCHAR(25) NOT NULL,
    PRIMARY KEY (IdCliente),
    UNIQUE INDEX UI_Telefono (Telefono)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Ventas;
CREATE TABLE IF NOT EXISTS Ventas
(
    IdVenta   INT      NOT NULL,
    Fecha     DATETIME NOT NULL DEFAULT NOW(),
    IdCliente INT      NOT NULL,
    PRIMARY KEY (IdVenta),
    CONSTRAINT FK_Clientes_45
        FOREIGN KEY (IdCliente)
            REFERENCES Clientes (IdCliente),
    INDEX IX_IdCliente48 (IdCliente),
    INDEX IX_Fecha49 (Fecha)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS Detalles;
CREATE TABLE IF NOT EXISTS Detalles
(
    IdDetalle  INT            NOT NULL,
    IdVenta    INT            NOT NULL,
    IdProducto INT            NOT NULL,
    Cantidad   INT            NOT NULL,
    Precio     DECIMAL(10, 4) NOT NULL,
    Descuento  FLOAT          NOT NULL DEFAULT 0,
    IdOferta   INT            NOT NULL,
    PRIMARY KEY (IdDetalle, IdVenta),
    INDEX IX_IdDetalle96 (IdDetalle),
    CONSTRAINT FK_Ventas_97
        FOREIGN KEY (IdVenta)
            REFERENCES Ventas (IdVenta),
    INDEX IX_IdVenta100 (IdVenta),
    CONSTRAINT FK_OfertasDelProducto_102
        FOREIGN KEY (IdProducto, IdOferta)
            REFERENCES OfertasDelProducto (IdProducto, IdOferta),
    INDEX IX_IdProductoIdOferta105 (IdProducto, IdOferta),
    CONSTRAINT FK_OfertasDelProducto_101
        FOREIGN KEY (IdProducto)
            REFERENCES OfertasDelProducto (IdProducto),
    INDEX IX_IdProducto104 (IdProducto),
    CONSTRAINT FK_OfertasDelProducto_105
        FOREIGN KEY (IdOferta)
            REFERENCES OfertasDelProducto (IdOferta),
    INDEX IX_IdOferta108 (IdOferta)
) ENGINE = InnoDB;

-- -------------------------------------
-- 2)
-- -------------------------------------
DROP PROCEDURE IF EXISTS sp_CargarProducto;
DELIMITER //
CREATE PROCEDURE sp_CargarProducto(pNombre varchar(50), pColor varchar(15), pPrecio decimal(10, 4), pIdCategoria int,
                                   OUT pMensaje varchar(100))
SALIR:
BEGIN
    DECLARE vUltimoIdInsertado int;

    IF pNombre IS NULL OR pNombre = '' THEN
        SET pMensaje = 'El nombre es obligatorio.';
        LEAVE SALIR;
    END IF;
    IF pPrecio IS NULL THEN
        SET pMensaje = 'El precio es obligatorio.';
        LEAVE SALIR;
    END IF;
    IF pPrecio < 0 THEN
        SET pMensaje = 'El precio no debe ser negativo.';
        LEAVE SALIR;
    END IF;

    IF EXISTS (SELECT Nombre FROM Productos WHERE Nombre = pNombre) THEN
        SET pMensaje = 'El nombre ya está usado, elija otro.';
        LEAVE SALIR;
    END IF;

    IF pIdCategoria IS NOT NULL AND
       NOT EXISTS (SELECT IdCategoria FROM Categorias WHERE IdCategoria = pIdCategoria) THEN
        SET pMensaje = 'La categoría no existe.';
        LEAVE SALIR;
    END IF;

    SET vUltimoIdInsertado = (SELECT MAX(COALESCE(IdProducto, 0)) FROM Productos);

    INSERT INTO Productos (IdProducto, Nombre, Color, Precio, IdCategoria)
    VALUES (vUltimoIdInsertado + 1, pNombre, pColor, pPrecio, pIdCategoria);

    SET pMensaje = 'Producto creado con éxito.';
END //
DELIMITER ;

SET @Mensaje = '';
CALL sp_CargarProducto('Notebook1', null, 300000, null, @Mensaje);
CALL sp_CargarProducto('Celular', 'Azul', 200000, 10, @Mensaje);
CALL sp_CargarProducto(null, 'Azul', 200000, 10, @Mensaje);
CALL sp_CargarProducto('Celular', 'Azul', -100, 10, @Mensaje);
CALL sp_CargarProducto('Celular', 'Azul', null, 10, @Mensaje);
SELECT @Mensaje;

SELECT *
FROM Categorias;
SELECT *
FROM Productos;

-- -------------------------------------
-- 3)
-- -------------------------------------

CREATE VIEW VTotalVentas AS
(SELECT V.IdVenta                      AS NroVenta,
        DATE_FORMAT(Fecha, '%d/%m/%Y') AS FechaVenta,
        Apellidos,
        Nombres,
        P.Nombre                       AS Producto,
        COALESCE(C2.Nombre, 'S/C')     AS Categoria,
        SUM(Cantidad)                  AS CantidadProductos,
        D.Precio                       AS PrecioUnitario
 FROM Ventas V
          INNER JOIN Clientes C ON V.IdCliente = C.IdCliente
          INNER JOIN Detalles D on V.IdVenta = D.IdVenta
          INNER JOIN Productos P on D.IdProducto = P.IdProducto
          LEFT JOIN Categorias C2 on P.IdCategoria = C2.IdCategoria
 GROUP BY NroVenta, FechaVenta, Apellidos, Nombres, Producto, Categoria, PrecioUnitario)
UNION
(SELECT null,
        null,
        null,
        null,
        null,
        null,
        null,
        SUM(Cantidad * D.Precio) AS Total
 FROM Ventas V
          INNER JOIN Clientes C ON V.IdCliente = C.IdCliente
          INNER JOIN Detalles D on V.IdVenta = D.IdVenta
          INNER JOIN Productos P on D.IdProducto = P.IdProducto
          LEFT JOIN Categorias C2 on P.IdCategoria = C2.IdCategoria)
;

SELECT *
FROM VTotalVentas;

-- -------------------------------------
-- 4)
-- -------------------------------------

DROP TABLE IF EXISTS AUD_Ofertas;
CREATE TABLE IF NOT EXISTS `AUD_Ofertas`
(
    Id             BIGINT      NOT NULL AUTO_INCREMENT,
    FechaAud       DATETIME    NOT NULL,
    UsuarioAud     VARCHAR(30) NOT NULL,
    IP             VARCHAR(40) NOT NULL,
    TipoAud        CHAR(1)     NOT NULL, -- Insercion(I), Borrado(B), Modificacion(A:Antes o D:Despues)
    IdOferta       INT         NOT NULL,
    Descuento      FLOAT       NOT NULL DEFAULT 0.05,
    FechaInicio    DATETIME    NOT NULL DEFAULT NOW(),
    FechaFin       DATETIME    NOT NULL,
    CantidadMinima INT         NOT NULL DEFAULT 1,
    CantidadMaxima INT         NULL,
    PRIMARY KEY (Id),
    INDEX IX_Id228 (Id),
    INDEX IX_FechaAud229 (FechaAud),
    INDEX `IX_UsuarioAud` (`UsuarioAud`)
) ENGINE = InnoDB;

DROP TRIGGER IF EXISTS Ofertas_AFTER_INSERT;
DELIMITER //
CREATE TRIGGER Ofertas_AFTER_INSERT AFTER INSERT ON Ofertas FOR EACH ROW BEGIN
	IF (NEW.Descuento >= 0.1) THEN
		INSERT INTO AUD_Ofertas VALUES (
			0,
			NOW(),
			SUBSTRING_INDEX(USER(),'@',1),
			SUBSTRING_INDEX(USER(),'@',-1),
			'I',
			NEW.IdOferta,
            NEW.Descuento,
            NEW.FechaInicio,
            NEW.FechaFin,
            NEW.CantidadMinima,
            NEW.CantidadMaxima
        );
    END IF;
END //
DELIMITER ;

insert into Ofertas values(18, 0.40, '2008-05-01 00:00:00.000', '2008-06-30 00:00:00.000', 0, NULL);
SELECT * FROM Ofertas;
SELECT * FROM AUD_Ofertas;