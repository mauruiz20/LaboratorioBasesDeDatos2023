-- Creación de la tabla de auditoría

DROP TABLE IF EXISTS aud_usuarios;
CREATE TABLE IF NOT EXISTS `aud_usuarios` (
`Id` BIGINT NOT NULL AUTO_INCREMENT,
`FechaAud` DATETIME NOT NULL,
`UsuarioAud` VARCHAR(30) NOT NULL,
`IP` VARCHAR(40) NOT NULL,
`UserAgent` VARCHAR(255) NULL,
`Aplicacion` VARCHAR(50) NOT NULL,
`TipoAud` CHAR(1) NOT NULL,
  `IdUsuario` int unsigned NOT NULL,
  `Apellidos` varchar(60) NOT NULL,
  `Nombres` varchar(60) NOT NULL,
  `CUIL` varchar(11) NOT NULL,
  `DNI` varchar(10) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Telefono` varchar(15) NOT NULL,
  `Domicilio` varchar(100) NOT NULL,
  `Cuenta` varchar(20) NOT NULL,
  `Contrasenia` char(60) NOT NULL,
PRIMARY KEY (`Id`),
INDEX `IX_FechaAud` (`FechaAud` ASC),
INDEX `IX_Usuario` (`UsuarioAud` ASC),
INDEX `IX_IP` (`IP` ASC),
INDEX `IX_Aplicacion` (`Aplicacion` ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Creación de Triggers

DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `usuarios_AFTER_INSERT` AFTER INSERT ON `usuarios` FOR EACH ROW BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` TRIGGER `usuarios_AFTER_UPDATE` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` TRIGGER `usuarios_AFTER_DELETE` AFTER DELETE ON `usuarios` FOR EACH ROW BEGIN
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
END$$
DELIMITER ;

-- Creación de Stored Procedures

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_vendedor`(pApellidos varchar(60), pNombres varchar(60), pCUIL varchar(11), pDNI varchar(10), pEmail varchar(100), 
										pTelefono varchar(15), pDomicilio varchar(100), pCuenta varchar(20), pContrasenia char(60), 
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
END$$
DELIMITER ;


-- Llamadas
SET @pMensaje = '';
CALL lbd2023g03.sp_crear_vendedor('Perez', 'Juan', 'CUIL1234', 'DNI1324', 'perezjuan@gmail.com', 'Telefono1234', 'Domicilio1234', 'perezj', '123456', @pMensaje);		-- Vendedor creado con éxito
CALL lbd2023g03.sp_crear_vendedor('Perez', 'Juan', 'CUIL1234', 'DNI1324', 'perezjuan@gmail.com', 'Telefono1234', 'Domicilio1234', 'juanperez', '123456', @pMensaje);	-- Vendedor con CUIL repetido
CALL lbd2023g03.sp_crear_vendedor('Perez', 'Juan', 'CUIL1234', 'DNI1324', null, 'Telefono1234', 'Domicilio1234', 'juanperez', '123456', @pMensaje);						-- Campos obligatorios
CALL lbd2023g03.sp_crear_vendedor('Perez', 'Juan', 'CUIL1234', 'DNI1324', 'perezjuan@gmail.com', 'Telefono1234', 'Domicilio1234', 'juanperez', '123', @pMensaje);		-- Contraseña menor a 6 caracteres
SELECT @pMensaje;

SELECT * FROM aud_usuarios;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modificar_vendedor`(pIdUsuario int, pApellidos varchar(60), pNombres varchar(60), 
										pCUIL varchar(11), pDNI varchar(10), pEmail varchar(100), pTelefono varchar(15), 
                                        pDomicilio varchar(100), pCuenta varchar(20), pContrasenia char(60), 
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
    
    -- Controla que la Contraseña tenga por lo menos 6 caracteres
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
END$$
DELIMITER ;


-- Llamadas
SET @pMensaje = '';
CALL lbd2023g03.sp_modificar_vendedor(76, 'Perez', 'Juan', 'CUIL1234', 'DNI1324', 'perezjuan@gmail.com', 'Telefono1234', 'Domicilio1234', 'juanperez', '123456', @pMensaje);		-- Vendedor modificado con éxito
CALL lbd2023g03.sp_modificar_vendedor(76, 'Perez', 'Juan', 'CUIL1234', 'DNI1324', 'perezjuan@gmail.com', 'Telefono1234', 'Domicilio1234', 'JeffersonThor', '123456', @pMensaje);	-- Cuenta repetida
CALL lbd2023g03.sp_modificar_vendedor(76, 'Perez', 'Juan', 'CUIL1234', 'DNI1324', 'perezjuan@gmail.com', 'Telefono1234', 'Domicilio1234', '', '123456', @pMensaje);					-- Campos obligatorios
CALL lbd2023g03.sp_modificar_vendedor(5000, 'Perez', 'Juan', 'CUIL789', 'DNI1324', 'perezjuan@gmail.com', 'Telefono1234', 'Domicilio1234', '123456', '123456', @pMensaje);		-- Se intentó modificar a un vendedor no existente
SELECT @pMensaje;

SELECT * FROM aud_usuarios;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_borrar_vendedor`(pIdUsuario int, OUT pMensaje varchar(100))
SALIR:BEGIN
	-- Controla que no existan servicios asociados
    IF EXISTS (SELECT IdServicio FROM servicios WHERE IdVendedor = pIdUsuario) THEN
		SET pMensaje = 'Error. Existen servicios asociados.';
        LEAVE SALIR;
	END IF;
    
    -- Controla que exista el vendedor para borrarlo
    IF NOT EXISTS (SELECT u.IdUsuario FROM usuarios u INNER JOIN vendedores v ON u.IdUsuario = v.IdUsuario WHERE u.IdUsuario = pIdUsuario) THEN
		SET pMensaje = 'Error. Vendedor no existente.';
        LEAVE SALIR;
	END IF;
    
    -- Borra al usuario vendedor
    START TRANSACTION;
		DELETE FROM vendedores WHERE IdUsuario = pIdUsuario;
        
        DELETE FROM usuarios WHERE IdUsuario = pIdUsuario;    
    COMMIT;
    
    -- Mensaje de éxito
    SET pMensaje = 'Vendedor borrado con éxito.';
END$$
DELIMITER ;


-- Llamadas
SET @pMensaje = '';
CALL lbd2023g03.sp_borrar_vendedor(76, @pMensaje); 				-- Vendedor borrado con éxito
CALL lbd2023g03.sp_borrar_vendedor(27, @pMensaje);				-- Existen servicios asociados
CALL lbd2023g03.sp_borrar_vendedor(1, @pMensaje);				-- Se intentó borrar un vendedor (cuyo ID es un cliente)
CALL lbd2023g03.sp_borrar_vendedor(5000, @pMensaje);			-- Se intentó borrar un vendedor que no existe
SELECT @pMensaje;

SELECT * FROM aud_usuarios;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_vendedor`(pIdUsuario int)
BEGIN
	SELECT		Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Contrasenia, u.IdUsuario
    FROM		usuarios u
    INNER JOIN 	vendedores v ON v.IdUsuario = u.IdUsuario
    WHERE		u.IdUsuario = pIdUsuario
    ;
END$$
DELIMITER ;

-- Llamadas
CALL lbd2023g03.sp_obtener_vendedor(30);			-- Se obtiene un vendedor
CALL lbd2023g03.sp_obtener_vendedor(5000);			-- No existe el vendedor (Se devuelve vacío)

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_vendedores`()
BEGIN
	SELECT		Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Contrasenia, u.IdUsuario
    FROM		usuarios u
    INNER JOIN 	vendedores v ON v.IdUsuario = u.IdUsuario
    ORDER BY	Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Contrasenia, IdUsuario
    ;
END$$
DELIMITER ;

-- Llamadas
CALL  lbd2023g03.sp_listar_vendedores();

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_servicios_vendedor`(pIdUsuario int, pFechaInicio datetime, pFechaFin datetime)
BEGIN
	SELECT		*
    FROM		servicios s
    LEFT JOIN 	lineasServicio ls ON ls.IdServicio = s.IdServicio
    WHERE 		IdVendedor = pIdUsuario AND
				FechaAlta BETWEEN pFechaInicio AND pFechaFin
    ;
END$$
DELIMITER ;

-- Llamadas
CALL  lbd2023g03.sp_listar_servicios_vendedor(27, "2023-01-01", "2023-12-31");		-- Se obtiene los servicios de un vendedor
CALL  lbd2023g03.sp_listar_servicios_vendedor(5000, "2023-01-01", "2023-12-31");		-- No existe el vendedor (Se devuelve vacío)

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_servicios_impagos`()
BEGIN
    SELECT			FechaFinalizacion, Titulo, CONCAT(Apellidos, ', ', Nombres) AS Cliente, Telefono, COALESCE(SUM(Cantidad * PrecioUnitario), 0) AS Deuda, s.IdServicio
	FROM			servicios AS s
	INNER JOIN		usuarios AS u ON u.IdUsuario = s.IdUsuario
	LEFT OUTER JOIN	lineasServicio AS ls ON ls.IdServicio = s.IdServicio AND ls.IdUsuario = s.IdUsuario
	WHERE			FechaBaja IS NULL AND FechaFinalizacion IS NOT NULL AND FechaPago IS NULL
	GROUP BY		FechaFinalizacion, Titulo, Cliente, Telefono, s.IdServicio
    ORDER BY		FechaFinalizacion, Titulo, Cliente, Telefono, Deuda, s.IdServicio;
END$$
DELIMITER ;

-- Llamadas
CALL lbd2023g03.sp_listar_servicios_impagos();



