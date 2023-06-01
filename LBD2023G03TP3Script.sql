CREATE TABLE `aud_vendedores` (
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
        pTelefono IS NULL OR pTelefono = '' OR
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
		INSERT INTO usuarios (Apellidos, Nombres, CUIL, DNI, Email, Telefono, Domicilio, Cuenta, Clave) VALUES
							(pApellidos, pNombres, pCUIL, pDNI, pEmail, pTelefono, pDomicilio, pCuenta, pClave);
                            
		SET pIdUsuario = LAST_INSERT_ID();
        
        INSERT INTO vendedores (IdUsuario) VALUES (pIdUsuario);        
	COMMIT;
    
    -- Mensaje de éxito
    SET pMensaje = CONCAT('Vendedor ', pIdUsuario, ' creado con éxito.');
END$$
DELIMITER ;

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
        pDNI IS NULL OR pDNI = '' OR
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
    
    -- Modifica al usuario vendedor
    -- Si la contraseña es nula o vacía se la modifica
    IF pContrasenia IS NULL OR pContrasenia = '' THEN
		UPDATE usuarios SET Apellidos = pApellidos, Nombres = pNombres, CUIL = pCUIL, DNI = pDNI, Email = pEmail, Telefono = pTelefono, 
							Domicilio = pDomicilio, Cuenta = pCuenta;
    ELSE
		UPDATE usuarios SET Apellidos = pApellidos, Nombres = pNombres, CUIL = pCUIL, DNI = pDNI, Email = pEmail, Telefono = pTelefono, 
							Domicilio = pDomicilio, Cuenta = pCuenta, Clave = pClave;
	END IF;
    
    -- Mensaje de éxito
    SET pMensaje = 'Vendedor modificado con éxito.';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_borrar_vendedor`(pIdUsuario int, OUT pMensaje varchar(100))
SALIR:BEGIN
	-- Controla que no existan servicios asociados
    IF EXISTS (SELECT IdServicio FROM servicios WHERE IdVendedor = pIdUsuario) THEN
		SET pMensaje = 'Error. Existen servicios asociados.';
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
DELIMITER 

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


