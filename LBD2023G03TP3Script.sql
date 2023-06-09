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

USE LBD2023G03;

-- -----------------------------------------------------
-- Tabla auditoría de usuarios - aud_usuarios
-- -----------------------------------------------------

DROP TABLE IF EXISTS aud_usuarios;
CREATE TABLE IF NOT EXISTS aud_usuarios (
Id 			BIGINT NOT NULL AUTO_INCREMENT,
FechaAud 	DATETIME NOT NULL,
UsuarioAud 	VARCHAR(30) NOT NULL,
IP 			VARCHAR(40) NOT NULL,
UserAgent 	VARCHAR(255) NULL,
TipoAud		CHAR(1) NOT NULL, 		-- Tipo de auditoria (I: Inserción, B: Borrado, A: Modificación (Antes), D: Modificación (Después))
  IdUsuario 	INT UNSIGNED NOT NULL,
  Apellidos 	VARCHAR(60) NOT NULL,
  Nombres 		VARCHAR(60) NOT NULL,
  CUIL 			VARCHAR(11) NOT NULL,
  DNI 			VARCHAR(10) NOT NULL,
  Email 		VARCHAR(100) NOT NULL,
  Telefono 		VARCHAR(15) NOT NULL,
  Domicilio 	VARCHAR(100) NOT NULL,
  Cuenta 		VARCHAR(20) NOT NULL,
  Contrasenia 	CHAR(60) NOT NULL,
PRIMARY KEY (Id),
INDEX IX_FechaAud (FechaAud ASC),
INDEX IX_Usuario (UsuarioAud ASC),
INDEX IX_IP (IP ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- TRIGGERS
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Implementar la lógica para llevar una auditoría para todos los apartados
-- siguientes de las operaciones de:
-- -----------------------------------------------------

-- -----------------------------------------------------
-- 1 - Creación
-- -----------------------------------------------------

DROP TRIGGER IF EXISTS trig_usuarios_creacion;

DELIMITER //
CREATE TRIGGER trig_usuarios_creacion 
AFTER INSERT ON usuarios FOR EACH ROW 
BEGIN
	INSERT INTO aud_usuarios VALUES(
		0, 
        NOW(), 
        SUBSTRING_INDEX(USER(),'@',1), 
        SUBSTRING_INDEX(USER(),'@',-1), 
        NULL,
        'I',
		NEW.IdUsuario,
        NEW.Apellidos,
        NEW.Nombres,
        NEW.CUIL,
        NEW.DNI,
        NEW.Email,
        NEW.Telefono,
        NEW.Domicilio,
        NEW.Cuenta,
        NEW.Contrasenia
        );
END //
DELIMITER ;

-- -----------------------------------------------------
-- 2 - Modificación
-- -----------------------------------------------------

DROP TRIGGER IF EXISTS trig_usuarios_modificacion;

DELIMITER //
CREATE TRIGGER trig_usuarios_modificacion 
AFTER UPDATE ON usuarios 
FOR EACH ROW BEGIN
	INSERT INTO aud_usuarios VALUES(
		0, 
        NOW(), 
        SUBSTRING_INDEX(USER(),'@',1), 
        SUBSTRING_INDEX(USER(),'@',-1), 
        NULL,
        'A',
		OLD.IdUsuario,
        OLD.Apellidos,
        OLD.Nombres,
        OLD.CUIL,
        OLD.DNI,
        OLD.Email,
        OLD.Telefono,
        OLD.Domicilio,
        OLD.Cuenta,
        OLD.Contrasenia
        );
	INSERT INTO aud_usuarios VALUES(
		0, 
        NOW(), 
        SUBSTRING_INDEX(USER(),'@',1), 
        SUBSTRING_INDEX(USER(),'@',-1), 
        NULL,
        'D',
		NEW.IdUsuario,
        NEW.Apellidos,
        NEW.Nombres,
        NEW.CUIL,
        NEW.DNI,
        NEW.Email,
        NEW.Telefono,
        NEW.Domicilio,
        NEW.Cuenta,
        NEW.Contrasenia
        );
END//
DELIMITER ;

-- -----------------------------------------------------
-- 3 - Borrado
-- -----------------------------------------------------

DROP TRIGGER IF EXISTS trig_usuarios_borrado;

DELIMITER //
CREATE TRIGGER trig_usuarios_borrado 
AFTER DELETE ON usuarios 
FOR EACH ROW BEGIN
	INSERT INTO aud_usuarios VALUES(
		0, 
        NOW(), 
        SUBSTRING_INDEX(USER(),'@',1), 
        SUBSTRING_INDEX(USER(),'@',-1), 
        NULL,
        'B',
		OLD.IdUsuario,
        OLD.Apellidos,
        OLD.Nombres,
        OLD.CUIL,
        OLD.DNI,
        OLD.Email,
        OLD.Telefono,
        OLD.Domicilio,
        OLD.Cuenta,
        OLD.Contrasenia
        );
END//
DELIMITER ;

-- -----------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Realizar (lo más eficientemente posible) los siguientes procedimientos almacenados, 
-- incluyendo el control de errores lógicos y mensajes de error:
-- -----------------------------------------------------

-- -----------------------------------------------------
-- 4 - Creación de un usuario vendedor
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS sp_crear_vendedor;

DELIMITER //
CREATE PROCEDURE sp_crear_vendedor (IN pApellidos varchar(60), IN pNombres varchar(60), IN pCUIL varchar(11), IN pDNI varchar(10), IN pEmail varchar(100), 
										IN pTelefono varchar(15), IN pDomicilio varchar(100), IN pCuenta varchar(20), IN pContrasenia char(60), 
                                        OUT pMensaje varchar(100))
SALIR:BEGIN
	-- Declarar variables auxiliares
	DECLARE pIdUsuario int;
    
    -- Controla que los campos no sean nulos ni vacíos
    IF (pApellidos IS NULL OR pApellidos = '' OR
		pNombres IS NULL OR pNombres = '' OR
        pCUIL IS NULL OR pCUIL = '' OR
        pDNI IS NULL OR pDNI = '' OR
        pEmail IS NULL OR pEmail = '') THEN
        SET pMensaje = 'Campos obligatorios.';
        LEAVE SALIR;
	END IF;
    
    IF (pTelefono IS NULL OR pTelefono = '' OR
        pDomicilio IS NULL OR pDomicilio = '' OR
        pCuenta IS NULL OR pCuenta = '' OR
        pContrasenia IS NULL OR pContrasenia = '') THEN
        SET pMensaje = 'Campos obligatorios.';
        LEAVE SALIR;
	END IF;
    
    -- Controla que la Contraseña tenga por lo menos 6 caracteres
    IF CHAR_LENGTH(pContrasenia) < 6 THEN
		SET pMensaje = 'Error. La contraseña debe tener por lo menos 6 caracteres.';
        LEAVE SALIR;
	END IF;
    
    -- Controla que el CUIL y la Cuenta no existan ya
    IF EXISTS (SELECT IdUsuario FROM usuarios WHERE CUIL = pCUIL OR Cuenta = pCuenta) THEN
		SET pMensaje = 'Error. Cuenta o CUIL ya existentes.';
        LEAVE SALIR;
	END IF;
    
    -- Crea al usuario vendedor
    START TRANSACTION;
		INSERT INTO usuarios (Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Contrasenia) VALUES
							(pApellidos, pNombres, pCUIL, pDNI, pEmail, pTelefono, pDomicilio, pCuenta, pContrasenia);
                            
		SET pIdUsuario = LAST_INSERT_ID();
        
        INSERT INTO vendedores (IdUsuario) VALUES (pIdUsuario);        
	COMMIT;
    
    -- Mensaje de éxito
    SET pMensaje = CONCAT('Vendedor ', pIdUsuario, ' creado con éxito.');
END//
DELIMITER ;

-- Llamadas
SET @pMensaje = '';
CALL LBD2023G03.sp_crear_vendedor('Perez', 'Juan', '20343653719', '34365371', 'perezjuan@gmail.com', '3811234567', 'San Juan 720', 'perezj', '123456', @pMensaje);		-- Vendedor creado con éxito
CALL LBD2023G03.sp_crear_vendedor('Perez', 'Juan', '20343653719', '34365371', 'perezjuan@gmail.com', '3811234567', 'San Juan 720', 'juanperez', '123456', @pMensaje);	-- Vendedor con CUIL repetido
CALL LBD2023G03.sp_crear_vendedor('Perez', 'Juan', '20343653719', '34365371', null, '3811234567', 'San Juan 720', 'juanperez', '123456', @pMensaje);					-- Campos obligatorios
CALL LBD2023G03.sp_crear_vendedor('Perez', 'Juan', '20343653719', '34365371', 'perezjuan@gmail.com', '3811234567', 'San Juan 720', 'juanperez', '123', @pMensaje);		-- Contraseña menor a 6 caracteres
SELECT @pMensaje AS Mensaje;

SELECT * FROM aud_usuarios;

-- -----------------------------------------------------
-- 5 - Modificación de un usuario vendedor
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS sp_modificar_vendedor;

DELIMITER //
CREATE PROCEDURE sp_modificar_vendedor (IN pIdUsuario int, IN pApellidos varchar(60), IN pNombres varchar(60), 
										IN pCUIL varchar(11), IN pDNI varchar(10), IN pEmail varchar(100), IN pTelefono varchar(15), 
                                        IN pDomicilio varchar(100), IN pCuenta varchar(20), IN pContrasenia char(60), 
                                        OUT pMensaje varchar(100))
SALIR:BEGIN    
    -- Controla que los campos no sean nulos ni vacíos
    IF (pApellidos IS NULL OR pApellidos = '' OR
		pNombres IS NULL OR pNombres = '' OR
        pCUIL IS NULL OR pCUIL = '' OR
        pDNI IS NULL OR pDNI = '') THEN
        SET pMensaje = 'Campos obligatorios.';
        LEAVE SALIR;
	END IF;
    
    IF (pEmail IS NULL OR pEmail = '' OR
		pTelefono IS NULL OR pTelefono = '' OR
        pDomicilio IS NULL OR pDomicilio = '' OR
        pCuenta IS NULL OR pCuenta = '') THEN
		SET pMensaje = 'Campos obligatorios.';
        LEAVE SALIR;
	END IF;
    
    -- Controla que la Contraseña tenga por lo menos 6 caracteres si es que es no nula
    IF pContrasenia IS NOT NULL AND CHAR_LENGTH(pContrasenia) < 6 THEN
		SET pMensaje = 'Error. La contraseña debe tener por lo menos 6 caracteres.';
        LEAVE SALIR;
	END IF;
    
    -- Controla que el CUIL y la Cuenta no existan ya
    IF EXISTS (SELECT IdUsuario FROM usuarios WHERE (CUIL = pCUIL OR Cuenta = pCuenta) AND IdUsuario != pIdUsuario) THEN
		SET pMensaje = 'Error. Cuenta o CUIL ya existentes.';
        LEAVE SALIR;
	END IF;
    
	-- Controla que exista el vendedor para modificarlo
    IF NOT EXISTS (SELECT u.IdUsuario FROM usuarios u INNER JOIN vendedores v ON u.IdUsuario = v.IdUsuario WHERE u.IdUsuario = pIdUsuario) THEN
		SET pMensaje = 'Error. Vendedor no existente.';
        LEAVE SALIR;
	END IF;
    
    -- Modifica al usuario vendedor
    -- Si la contraseña es nula o vacía no se la modifica
    IF pContrasenia IS NULL OR pContrasenia = '' THEN
		UPDATE usuarios SET Apellidos = pApellidos, Nombres = pNombres, CUIL = pCUIL, DNI = pDNI, Email = pEmail, Telefono = pTelefono, 
							Domicilio = pDomicilio, Cuenta = pCuenta
		WHERE IdUsuario = pIdUsuario;
    ELSE
		UPDATE usuarios SET Apellidos = pApellidos, Nombres = pNombres, CUIL = pCUIL, DNI = pDNI, Email = pEmail, Telefono = pTelefono, 
							Domicilio = pDomicilio, Cuenta = pCuenta, Contrasenia = pContrasenia
		WHERE IdUsuario = pIdUsuario;
	END IF;
    
    -- Mensaje de éxito
    SET pMensaje = 'Vendedor modificado con éxito.';
END//
DELIMITER ;

-- Llamadas
SET @pMensaje = '';
CALL LBD2023G03.sp_modificar_vendedor(72, 'Rodriguez', 'Juan', '20343653719', '34365371', 'perezjuan@gmail.com', '3811234567', 'San Juan 720', 'juanperez', '123456', @pMensaje);	-- Vendedor modificado con éxito
CALL LBD2023G03.sp_modificar_vendedor(72, 'Perez', 'Juan', '20343653719', '34365371', 'perezjuan@gmail.com', '3811234567', 'San Juan 720', 'JeffersonThor', '123456', @pMensaje);	-- Cuenta repetida
CALL LBD2023G03.sp_modificar_vendedor(72, 'Perez', 'Juan', '20343653719', '34365371', 'perezjuan@gmail.com', '3811234567', 'San Juan 720', '', '123456', @pMensaje);				-- Campos obligatorios
CALL LBD2023G03.sp_modificar_vendedor(5000, 'Perez', 'Juan', '13143653715', '14365371', 'perezjuan@gmail.com', '3811234567', 'San Juan 720', '123456', '123456', @pMensaje);		-- Se intentó modificar a un vendedor no existente
SELECT @pMensaje AS Mensaje;

SELECT * FROM aud_usuarios;

-- -----------------------------------------------------
-- 6 - Borrado de un usuario vendedor
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS sp_borrar_vendedor;

DELIMITER //
CREATE PROCEDURE sp_borrar_vendedor (IN pIdUsuario int, OUT pMensaje varchar(100))
SALIR:BEGIN
	-- Controla que no existan servicios asociados
    IF EXISTS (SELECT IdServicio FROM servicios WHERE IdVendedor = pIdUsuario) THEN
		SET pMensaje = 'Error. Existen servicios asociados.';
        LEAVE SALIR;
	END IF;
    
    -- Controla que exista el vendedor para borrarlo
    IF NOT EXISTS (SELECT u.IdUsuario FROM usuarios u INNER JOIN vendedores v ON u.IdUsuario = v.IdUsuario WHERE u.IdUsuario = pIdUsuario) THEN
		SET pMensaje = 'Vendedor no existente.';
        LEAVE SALIR;
	END IF;
    
    -- Borra al usuario vendedor
    START TRANSACTION;
		DELETE FROM vendedores WHERE IdUsuario = pIdUsuario;
        
        DELETE FROM usuarios WHERE IdUsuario = pIdUsuario;    
    COMMIT;
    
    -- Mensaje de éxito
    SET pMensaje = 'Vendedor borrado con éxito.';
END//
DELIMITER ;


-- Llamadas
SET @pMensaje = '';
CALL LBD2023G03.sp_borrar_vendedor(72, @pMensaje); 				-- Vendedor borrado con éxito
CALL LBD2023G03.sp_borrar_vendedor(27, @pMensaje);				-- Existen servicios asociados
CALL LBD2023G03.sp_borrar_vendedor(1, @pMensaje);				-- Se intentó borrar un vendedor (cuyo ID es un cliente)
CALL LBD2023G03.sp_borrar_vendedor(5000, @pMensaje);			-- Se intentó borrar un vendedor que no existe
SELECT @pMensaje AS Mensaje;

SELECT * FROM aud_usuarios;

-- -----------------------------------------------------
-- 7 - Búsqueda de un usuario vendedor
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS sp_obtener_vendedor;

DELIMITER //
CREATE PROCEDURE sp_obtener_vendedor (IN pApellidos varchar(60), IN pNombres varchar(60), IN pCUIL varchar(11), OUT pMensaje varchar(100))
BEGIN
	CREATE TEMPORARY TABLE tmp_vendedor
	SELECT		Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Contrasenia, u.IdUsuario
    FROM		usuarios u
    INNER JOIN 	vendedores v ON v.IdUsuario = u.IdUsuario
    WHERE		(pApellidos IS NULL OR Apellidos LIKE CONCAT(pApellidos, '%')) AND
				(pNombres IS NULL OR Nombres LIKE CONCAT(pNombres, '%')) AND
				(pCUIL IS NULL OR CUIL LIKE CONCAT(pCUIL, '%'));
                
	IF NOT EXISTS (SELECT IdUsuario FROM tmp_vendedor) THEN
		SET pMensaje = 'No se encontró el vendedor buscado.';
	ELSE 
		SELECT * FROM tmp_vendedor;
	END IF;
    
    DROP TEMPORARY TABLE tmp_vendedor;
END//
DELIMITER ;

-- Llamadas
SET @pMensaje = '';
CALL LBD2023G03.sp_obtener_vendedor('Nolan', null, null, @pMensaje);	-- Se obtiene un vendedor
CALL LBD2023G03.sp_obtener_vendedor('Dip', null, null, @pMensaje);		-- No existe el vendedor
CALL LBD2023G03.sp_obtener_vendedor(null, 'Nicolas', null, @pMensaje);	-- No existe el vendedor
CALL LBD2023G03.sp_obtener_vendedor(null, null, null, @pMensaje);		-- Lista todos los vendedores
SELECT @pMensaje AS Mensaje;

-- -----------------------------------------------------
-- 8 - Listado de usuarios vendedores, ordenados por el 
-- criterio que considere más adecuado
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS sp_listar_vendedores;

DELIMITER //
CREATE PROCEDURE sp_listar_vendedores ()
BEGIN
	SELECT		Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Contrasenia, u.IdUsuario
    FROM		usuarios u
    INNER JOIN 	vendedores v ON v.IdUsuario = u.IdUsuario
    ORDER BY	Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Contrasenia, IdUsuario
    ;
END//
DELIMITER ;

-- Llamadas
CALL  LBD2023G03.sp_listar_vendedores();

-- -----------------------------------------------------
-- 9 - Dado un rango de fechas y un usuario vendedor, mostrar todos los servicios y sus
-- líneas para ese vendedor y rango
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS sp_listar_servicios_vendedor;

DELIMITER //
CREATE PROCEDURE sp_listar_servicios_vendedor (IN pIdUsuario int, IN pFechaInicio datetime, IN pFechaFin datetime, OUT pMensaje varchar(100))
SALIR:BEGIN
	-- Variable auxiliar
	DECLARE pFechaAux datetime;
    
    -- Control de parámetros de entrada
	IF pIdUsuario IS NULL THEN
		SET pMensaje = 'Falta el Id del vendedor.';
        LEAVE SALIR;
	ELSEIF NOT EXISTS (SELECT u.IdUsuario FROM usuarios u INNER JOIN vendedores v ON u.IdUsuario = v.IdUsuario WHERE u.IdUsuario = pIdUsuario) THEN
		SET pMensaje = 'Vendedor no existente.';
        LEAVE SALIR;
    END IF;
    
    IF (pFechaInicio IS NULL AND pFechaFin IS NULL) THEN
		SET pMensaje = 'Ingrese un rango fechas.';
        LEAVE SALIR;
	END IF;
    
    IF (pFechaInicio IS NULL AND pFechaFin IS NOT NULL) THEN
    
		SET pFechaInicio = DATE_SUB(pFechaFin, INTERVAL 1 YEAR); -- 1 Año para atrás
        
	ELSEIF (pFechaInicio IS NOT NULL AND pFechaFin IS NULL) THEN
    
		SET pFechaFin = DATE_ADD(pFechaInicio, INTERVAL 1 YEAR); -- 1 Año para adelante
        
	ELSEIF (pFechaInicio > pFechaFin) THEN
    
		SET pFechaAux = pFechaInicio;
        SET pFechaInicio = pFechaFin;
        SET pFechaFin = pFechaAux;
	
    END IF;
		
	CREATE TEMPORARY TABLE tmp_servicios_vendedor
	SELECT		s.IdServicio, s.IdUsuario, IdTecnico, IdTipoServicio, Titulo, Observaciones, FechaAlta, FechaBaja, FechaFinalizacion, FechaPago, NroLinea, PrecioUnitario, IdProducto, Cantidad, Detalle
    FROM		servicios s
    LEFT JOIN 	lineasServicio ls ON ls.IdServicio = s.IdServicio
    WHERE 		IdVendedor = pIdUsuario AND
				FechaAlta BETWEEN pFechaInicio AND pFechaFin
    ;
    
    IF NOT EXISTS (SELECT IdServicio FROM tmp_servicios_vendedor) THEN
		SET pMensaje = 'No se encontraron servicios del vendedor.';
	ELSE 
		SELECT * FROM tmp_servicios_vendedor;
	END IF;
    
    DROP TEMPORARY TABLE tmp_servicios_vendedor;
END//
DELIMITER ;

-- Llamadas
SET @pMensaje = '';
CALL  LBD2023G03.sp_listar_servicios_vendedor(27, "2023-01-01", "2023-12-31", @pMensaje);		-- Se obtiene los servicios de un vendedor
CALL  LBD2023G03.sp_listar_servicios_vendedor(40, "2023-01-01", "2023-12-31", @pMensaje);		-- No se encontraron servicios del vendedor
CALL  LBD2023G03.sp_listar_servicios_vendedor(27, null, null, @pMensaje);						-- Sin rango de fechas
CALL  LBD2023G03.sp_listar_servicios_vendedor(5000, "2023-01-01", "2023-12-31", @pMensaje);		-- Vendedor no existente
SELECT @pMensaje AS Mensaje;

-- -----------------------------------------------------
-- 10 - Realizar un procedimiento almacenado con alguna funcionalidad que considere
-- de interés
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS sp_listar_servicios_impagos;

DELIMITER //
CREATE PROCEDURE sp_listar_servicios_impagos ()
BEGIN
    SELECT			FechaFinalizacion, Titulo, CONCAT(Apellidos, ', ', Nombres) AS Cliente, Telefono, COALESCE(SUM(Cantidad * PrecioUnitario), 0) AS Deuda, s.IdServicio
	FROM			servicios AS s
	INNER JOIN		usuarios AS u ON u.IdUsuario = s.IdUsuario
	LEFT OUTER JOIN	lineasServicio AS ls ON ls.IdServicio = s.IdServicio AND ls.IdUsuario = s.IdUsuario
	WHERE			FechaBaja IS NULL AND 
					FechaFinalizacion IS NOT NULL AND 
                    FechaPago IS NULL
	GROUP BY		FechaFinalizacion, Titulo, Cliente, Telefono, s.IdServicio
    ORDER BY		FechaFinalizacion, Titulo, Cliente, Telefono, Deuda, s.IdServicio;
END//
DELIMITER ;

-- Llamadas
CALL LBD2023G03.sp_listar_servicios_impagos();