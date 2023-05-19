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

DROP SCHEMA IF EXISTS LBD2023G03;
CREATE SCHEMA IF NOT EXISTS LBD2023G03;

USE LBD2023G03;

-- 
-- TABLE: usuarios 
--

-- DROP TABLE IF EXISTS usuarios;
CREATE TABLE IF NOT EXISTS usuarios(
    IdUsuario      INT UNSIGNED    AUTO_INCREMENT,
    Apellidos      VARCHAR(60)     NOT NULL,
    Nombres        VARCHAR(60)     NOT NULL,
    CUIL           VARCHAR(11)     NOT NULL,
    DNI            VARCHAR(10)     NOT NULL,
    Email          VARCHAR(100)    NOT NULL,
    Telefono       VARCHAR(15)     NOT NULL,
    Domicilio      VARCHAR(100)    NOT NULL,
    Cuenta         VARCHAR(20)     NOT NULL,
    Contrasenia    CHAR(60)        NOT NULL,
    PRIMARY KEY (IdUsuario), 
    UNIQUE INDEX UI_Cuenta(Cuenta),
    INDEX IX_ApellidosNombres(Apellidos, Nombres),
    INDEX IX_Nombres(Nombres),
    UNIQUE INDEX UI_CUIL(CUIL)
)ENGINE=INNODB
;

-- 
-- TABLE: clientes 
--

-- DROP TABLE IF EXISTS clientes;
CREATE TABLE IF NOT EXISTS clientes(
    IdUsuario        INT UNSIGNED   NOT NULL,
    Localidad        VARCHAR(60)    NOT NULL,
    Comuna           VARCHAR(60)    NOT NULL,
    Observaciones    TEXT,
    EstadoCliente    CHAR(1)        DEFAULT 'P' NOT NULL
                     CHECK (EstadoCliente = 'P' OR EstadoCliente = 'A' OR EstadoCliente = 'B'),
    PRIMARY KEY (IdUsuario), 
    CONSTRAINT Refusuarios41 FOREIGN KEY (IdUsuario)
    REFERENCES usuarios(IdUsuario)
)ENGINE=INNODB
;

-- 
-- TABLE: entradas 
--

-- DROP TABLE IF EXISTS entradas;
CREATE TABLE IF NOT EXISTS entradas(
    IdEntrada        INT UNSIGNED  AUTO_INCREMENT,
    FechaEntrada     DATETIME    NOT NULL,
    Observaciones    TEXT,
    EstadoEntrada    CHAR(1)     DEFAULT 'E' NOT NULL
                     CHECK (EstadoEntrada = 'E' OR EstadoEntrada = 'F'),
    PRIMARY KEY (IdEntrada), 
    INDEX IX_FechaEntrada(FechaEntrada)
)ENGINE=INNODB
;

-- 
-- TABLE: productos 
--

-- DROP TABLE IF EXISTS productos;
CREATE TABLE IF NOT EXISTS productos(
    IdProducto        INT UNSIGNED   AUTO_INCREMENT,
    Producto          VARCHAR(60)    NOT NULL,
    Marca             VARCHAR(60),
    EstadoProducto    CHAR(1)        DEFAULT 'A' NOT NULL
                      CHECK (EstadoProducto = 'A' OR EstadoProducto = 'B'),
    PRIMARY KEY (IdProducto)
)ENGINE=INNODB
;

-- 
-- TABLE: lineasEntrada 
--

-- DROP TABLE IF EXISTS lineasEntrada;
CREATE TABLE IF NOT EXISTS lineasEntrada(
    IdLineaEntrada    INT UNSIGNED      AUTO_INCREMENT,
    IdEntrada         INT UNSIGNED      NOT NULL,
    IdProducto        INT UNSIGNED      NOT NULL,
    CostoUnitario     DECIMAL(12, 2)    NOT NULL
                      CHECK (CostoUnitario >= 0),
    Cantidad          SMALLINT          NOT NULL,
    PRIMARY KEY (IdLineaEntrada, IdEntrada, IdProducto), 
    UNIQUE INDEX UI_IdLineaEntrada(IdLineaEntrada), 
    CONSTRAINT Refproductos81 FOREIGN KEY (IdProducto)
    REFERENCES productos(IdProducto),
    CONSTRAINT Refentradas91 FOREIGN KEY (IdEntrada)
    REFERENCES entradas(IdEntrada)
)ENGINE=INNODB
;

-- 
-- TABLE: tecnicos 
--

-- DROP TABLE IF EXISTS tecnicos;
CREATE TABLE IF NOT EXISTS tecnicos(
    IdUsuario         INT UNSIGNED    NOT NULL,
    HorarioTrabajo    VARCHAR(100)    NOT NULL,
    EstadoTecnico     CHAR(1)         DEFAULT 'A' NOT NULL
                      CHECK (EstadoTecnico = 'A' OR EstadoTecnico = 'B'),
    PRIMARY KEY (IdUsuario), 
    CONSTRAINT Refusuarios31 FOREIGN KEY (IdUsuario)
    REFERENCES usuarios(IdUsuario)
)ENGINE=INNODB
;

-- 
-- TABLE: vendedores 
--

-- DROP TABLE IF EXISTS vendedores;
CREATE TABLE IF NOT EXISTS vendedores(
    IdUsuario    INT UNSIGNED  NOT NULL,
    PRIMARY KEY (IdUsuario), 
    CONSTRAINT Refusuarios21 FOREIGN KEY (IdUsuario)
    REFERENCES usuarios(IdUsuario)
)ENGINE=INNODB
;

-- 
-- TABLE: tiposServicio 
--

-- DROP TABLE IF EXISTS tiposServicio;
CREATE TABLE IF NOT EXISTS tiposServicio(
    IdTipoServicio     SMALLINT UNSIGNED  AUTO_INCREMENT,
    TipoServicio       VARCHAR(100)    NOT NULL,
    FechaAlta          DATETIME        DEFAULT NOW() NOT NULL,
    Contenido          TEXT            NOT NULL,
    EstadoTServicio    CHAR(1)         DEFAULT 'A' NOT NULL
                       CHECK (EstadoTServicio = 'A' OR EstadoTServicio = 'B'),
    PRIMARY KEY (IdTipoServicio), 
    UNIQUE INDEX UI_TipoServicio(TipoServicio)
)ENGINE=INNODB
;

-- 
-- TABLE: servicios 
--

-- DROP TABLE IF EXISTS servicios;
CREATE TABLE IF NOT EXISTS servicios(
    IdServicio           INT UNSIGNED   AUTO_INCREMENT,
    IdUsuario            INT UNSIGNED   NOT NULL,
    IdTecnico            INT UNSIGNED,
    IdVendedor           INT UNSIGNED   NOT NULL,
    IdTipoServicio       SMALLINT UNSIGNED  NOT NULL,
    Titulo               VARCHAR(60)    NOT NULL,
    FechaAlta            DATETIME       NOT NULL,
    FechaBaja            DATETIME,
    FechaFinalizacion    DATETIME,
    FechaPago            DATETIME,
    Observaciones        TEXT,
    PRIMARY KEY (IdServicio, IdUsuario), 
    UNIQUE INDEX UI_IdServicio(IdServicio),
    INDEX IX_FechaAlta(FechaAlta), 
    CONSTRAINT Reftecnicos121 FOREIGN KEY (IdTecnico)
    REFERENCES tecnicos(IdUsuario),
    CONSTRAINT Refvendedores141 FOREIGN KEY (IdVendedor)
    REFERENCES vendedores(IdUsuario),
    CONSTRAINT Refclientes151 FOREIGN KEY (IdUsuario)
    REFERENCES clientes(IdUsuario),
    CONSTRAINT ReftiposServicio161 FOREIGN KEY (IdTipoServicio)
    REFERENCES tiposServicio(IdTipoServicio)
)ENGINE=INNODB
;

-- 
-- TABLE: lineasServicio 
--

-- DROP TABLE IF EXISTS lineasServicio;
CREATE TABLE IF NOT EXISTS lineasServicio(
    NroLinea          INT UNSIGNED      AUTO_INCREMENT,
    IdServicio        INT UNSIGNED      NOT NULL,
    IdUsuario         INT UNSIGNED      NOT NULL,
    IdProducto        INT UNSIGNED,
    PrecioUnitario    DECIMAL(12, 2)    NOT NULL
                      CHECK (PrecioUnitario >= 0),
    Cantidad          SMALLINT          NOT NULL,
    Detalle           TEXT,
    PRIMARY KEY (NroLinea, IdServicio, IdUsuario), 
    UNIQUE INDEX UI_NroLinea(NroLinea), 
    CONSTRAINT Refservicios171 FOREIGN KEY (IdServicio, IdUsuario)
    REFERENCES servicios(IdServicio, IdUsuario),
    CONSTRAINT Refservicios172 FOREIGN KEY (IdServicio)
    REFERENCES servicios(IdServicio),
    CONSTRAINT Refservicios173 FOREIGN KEY (IdUsuario)
    REFERENCES servicios(IdUsuario),
    CONSTRAINT Refproductos191 FOREIGN KEY (IdProducto)
    REFERENCES productos(IdProducto)
)ENGINE=INNODB
;


INSERT INTO usuarios (Apellidos,Nombres,CUIL,DNI,Email,Telefono,Domicilio,Cuenta,Contrasenia)
VALUES
    ('Owens Harrison','Tanek',22316773859,31677385,'o.tanek@hotmail.com','3811881541','6981 Diam Avenue','WhitakerVernon','LGS84SSK4WJN2HJY7VUV2PUX'),
    ('Smith Hendrix','Noah',21382570837,38257083,'s_noah@hotmail.com','3817249504','318-5377 Sapien Av.','JeffersonThor','ONZ29GHE8LYC8CKO1RWX4EFS'),
    ('Austin Ferrell','Brynn',17327447327,32744732,'austinferrell-brynn@gmail.com','3863747556','4922 Nulla. Street','HornHilda','CPP29YCB3CPH8XEC3TQH8VYK'),
    ('Crosby','Nomlanga',12353936166,35393616,'n_crosby@gmail.com','3863848807','3060 Lobortis Road','SandersPreston','GCP89SYO8IMM9INF3RBT7UDY'),
    ('Justice Mclean','Aileen',31245159569,24515956,'aileen.justicemclean1445@gmail.com','3863852843','P.O. Box 817, 7550 Sem Avenue','TaylorAbel','CRM72FIT8YWX3FCB7KTK7TFY'),
    ('Kane','Raya',13210123186,21012318,'r-kane@hotmail.com','3811565113','Ap #234-7589 Ornare, Avenue','CarterKameko','CDP23CFI6LQN4DOX8XBZ0HHD'),
    ('Gilmore Charles','Cassady',31300159015,30015901,'cassady-gilmorecharles@gmail.com','3863781162','953-5978 Lobortis, Street','DaughertyDrew','QAY28UZD3YJG8MBJ3WQX7QWJ'),
    ('Ferguson Mcbride','Beatrice',16209381719,20938171,'beatricefergusonmcbride@gmail.com','3863438045','P.O. Box 308, 6620 Neque Rd.','HornImogene','IOK82NUJ2YUL1VXY4SDB1MGH'),
    ('Mcgowan','Tamekah',31323468012,32346801,'tamekah-mcgowan6815@hotmail.com','3816352177','Ap #598-2817 A, Street','WilliamHyatt','ISO50QWX8XKQ0VPV1LNK7OOJ'),
    ('Hancock Valenzuela','Maia Garrett',41342424831,34242483,'m-hancockvalenzuela@gmail.com','3812011602','Ap #842-5374 Eu Road','AyersClayton','WMX66CRT9GCY5HJJ1YLV8HUP'),
    ('Barton','Chaney Sophia',31359947796,35994779,'barton.chaneysophia7003@gmail.com','3863611410','515-9619 Ut St.','McgowanRhona','ACL64HLC2LUK1YEG5SYG2YJM'),
    ('Lloyd','Fiona',21216153859,21615385,'l.fiona5649@hotmail.com','3817172016','P.O. Box 681, 3900 Lectus St.','LancasterKevyn','AGC74TOI6KUF9ENF3OSY7ZIT'),
    ('Yang','Isabelle',13376971835,37697183,'isabelleyang6671@hotmail.com','3816657268','976-1256 Blandit St.','LambertBlake','EXL22ZDB7JTR3PIY2FRI8DLO'),
    ('Welch','Sean Jillian',31326902164,32690216,'swelch@hotmail.com','3811539566','Ap #911-288 Nec, Ave','PowersHammett','FKJ52YHP7PMK3DEN1LGS3JEH'),
    ('Riddle Ratliff','Cally',15227365138,22736513,'riddleratliff_cally@hotmail.com','3815415610','P.O. Box 543, 8920 Dui Ave','LangZenia','CVC41KRL2YBS3HBT2URV8CFP'),
    ('Melton Bennett','Donovan',14383062191,38306219,'d.meltonbennett@hotmail.com','3863177517','Ap #531-6485 Adipiscing. St.','BenjaminIsabelle','HCB91MFQ6VRK4IDR3ZEJ6PRM'),
    ('Weber Spears','Leo Joseph',23311174357,31117435,'w_leojoseph@hotmail.com','3863466104','615-6384 Vivamus Rd.','CastilloClark','XZH23SVJ6WDA3EOR2LXL2EWG'),
    ('Rios','Joshua',18336154091,33615409,'joshua.rios@gmail.com','3818682689','Ap #768-537 Tristique St.','SantanaIna','PWY39VFO4XDV4MJI8VXQ6AQC'),
    ('Dotson','Price Knox',12399548779,39954877,'d_priceknox@hotmail.com','3814462615','2261 Sed Av.','CurryGregory','ZJH35BWC7MKV2JJX8CMU7GBX'),
    ('Tanner Dudley','Shellie',10369330083,36933008,'shellie.tannerdudley@gmail.com','3811803552','Ap #148-8426 Ut, Av.','JacobsonBryar','FNI24BRC3DUD4BPE4YPQ5BJI'),
    ('Walters Marshall','Blossom',12281949761,28194976,'bmarshallwalters@gmail.com','3863139091','8346 Cursus Av.','LeeLynn','KTH51DRO2WJQ3MVN7YKU3BGI'),
    ('Douglas','Merritt Michelle',17303507854,30350785,'michelle.douglas6558@gmail.com','3863890019','Ap #543-2665 Elit, Rd.','NguyenJelani','HRI95WKG8MOT9QAE6NJS5UEZ'),
    ('Stafford Mcintosh','Kylee',16306034719,30603471,'kyleestaffordmcintosh5476@hotmail.com','3863556348','P.O. Box 146, 9044 Euismod St.','ReidChava','BIF84SQR2VWJ8ZEN4JSC4BXO'),
    ('Bates','Noah Luna',12360408847,36040884,'noahbatesluna6632@hotmail.com','3863632537','Ap #248-6259 Nulla Rd.','GriffinNayda','AMW89HNI6GDC5FQU1VEJ5UYT'),
    ('Morales Hall','Astra',13231585395,23158539,'a.moraleshall8522@hotmail.com','3811810328','P.O. Box 778, 2720 Ligula. St.','BooneAriana','QPT51ZJF4BGM7EDS5LAW6CXO'),
    ('Sweeney','Sacha Phelan',12392378347,39237834,'sacha.sweeneyphelan@gmail.com','3863918463','P.O. Box 636, 2249 Non, Av.','GrantAnjolie','BWM80HJC3IQP0VVP1ZDY6RTE'),
    ('Ruiz Mcgee','Zenaida Hedy',20305451439,30545143,'zhedyruizmcgee4780@hotmail.com','3863102908','6478 Vitae Av.','McfaddenSalvador','IBG87NYT1VOJ2KUZ0AEF1MHX'),
    ('Parks','Tana Asher',19333693311,33369331,'tana_parksasher@yahoo.com','3816201217','8315 Tincidunt Rd.','VelezJacinda','IJK48QLU6CWT2KOA9XRY9EFS'),
    ('Blackburn Mejia','Shaeleigh Jeanette',12312278384,31227838,'shaeleigh.blackburnmejia@hotmail.com','3863558011','Ap #584-6746 Urna. Av.','HawkinsBrinley','FZU37VKL2TMX4SNJ5GBN0CPE'),
    ('Mcfadden','Sage Gwendolyn',45375258689,37525868,'sage.mcfadden4742@hotmail.com','3863447341','Ap #665-3859 Sodales Av.','GutierrezTanner','CNG13TLP5IUO8HK'),
    ('Barker','Azaria',13324375542,32437554,'azariabarker@gmail.com','3863704388','Ap #331-3051 Eget Av.','WalkerMackenzie','WPK87BVN3MHX9QTY0JAR6FES'),
    ('Nolan','Armando Phillip',15300707661,30070766,'armando.nolanphilip7531@hotmail.com','3863197094','P.O. Box 940, 7108 Nunc. Rd.','MendezValerie','APC19QYO8JZM5ELX7TUI2RGF'),
    ('Morton','Zola Erika',19371210381,37121038,'zola.mortonerika7414@hotmail.com','3863201236','P.O. Box 381, 2662 Id Rd.','FuentesHeath','NBI54GWT2FQL7EOZ8KUA3VXP'),
    ('Graham Ellis','Teegan Alexandra',20318073949,31807394,'teegan.grahamellis6953@gmail.com','3863405539','P.O. Box 416, 5152 Auctor. St.','ShafferClara','DHY25OBZ7NFG9XUK6AWR1EJP'),
    ('Holmes','Catherine Belle',21282041624,28204162,'catherineholmesbelle@gmail.com','3814385325','853-3636 Amet St.','PierceKyler','FVN63ZLY4EWG2CJS9QAI1XOB');

INSERT INTO clientes (IdUsuario,Localidad,Comuna,Observaciones,EstadoCliente)
VALUES
	(1, 'Monteros', 'Cercado', null, 'A'),
	(2, 'Monteros', 'Monteros', null, 'B'),
	(3, 'Monteros', 'Soldado Maldonado', null, 'B'),
	(4, 'Monteros', 'Capitan Caceres', null, 'P'),
	(5, 'Monteros', 'Monteros', null, 'P'),
	(6, 'Monteros', 'Monteros', null, 'A'),
	(7, 'Monteros', 'Cercado', null, 'A'),
	(8, 'Monteros', 'Cercado', 'Ninguna', 'B'),
	(9, 'Monteros', 'Capitan Caceres', null, 'P'),
	(10, 'Monteros', 'Soldado Maldonado', null, 'A'),
	(11, 'Monteros', 'Cercado', 'Ninguna', 'A'),
	(12, 'Monteros', 'Monteros', 'Ninguna', 'B'),
	(13, 'Monteros', 'Monteros', null, 'P'),
	(14, 'Monteros', 'Soldado Maldonado', null, 'A'),
	(15, 'Monteros', 'Capitan Caceres', '-', 'A');

INSERT INTO vendedores (IdUsuario)
VALUES
	(16),
	(17),
	(18),
	(19),
	(20),
	(21),
	(22),
	(23),
	(24),
	(25);

INSERT INTO tecnicos (IdUsuario,HorarioTrabajo,EstadoTecnico)
VALUES
	(26, '8 a 12 - 14 a 18', 'A'),
	(27, '12 a 16 - 18 a 21', 'B'),
	(28, '8 a 12 - 14 a 18', 'A'),
	(29, '12 a 16 - 18 a 21', 'B'),
	(30, '12 a 16 - 18 a 21', 'A'),
	(31, '8 a 12 - 14 a 18', 'A'),
	(32, '8 a 12 - 14 a 18', 'B'),
	(33, '12 a 16 - 18 a 21', 'A'),
	(34, '8 a 12 - 14 a 18', 'B'),
	(35, '12 a 16 - 18 a 21', 'A');

INSERT INTO tiposServicio (TipoServicio, FechaAlta, Contenido, EstadoTServicio)
VALUES
('Instalación de Redes', '2022-12-19 02:04:56', 'Instalación de redes de internet', 'A'),
('Mantenimiento de Redes', '2022-09-29 01:53:55', 'Mantenimiento de redes de internet', 'A'),
('Soporte Técnico', '2022-11-12 09:28:34', 'Soporte técnico para redes de internet', 'B'),
('Configuración de Redes', '2023-04-30 16:41:08', 'Configuración de redes de internet', 'B'),
('Redes Inalámbricas', '2024-02-05 12:02:11', 'Instalación y configuración de redes inalámbricas', 'A'),
('Seguridad de Redes', '2022-11-15 13:59:55', 'Implementación de medidas de seguridad para redes de internet', 'A'),
('Virtualización de Redes', '2022-05-04 03:27:48', 'Creación y administración de redes virtuales', 'B'),
('Redes Privadas Virtuales', '2024-02-15 17:22:12', 'Configuración y administración de redes privadas virtuales', 'B'),
('Fibra Óptica', '2022-08-11 07:28:23', 'Instalación y mantenimiento de redes de fibra óptica', 'A'),
('Ancho de Banda', '2022-04-25 02:03:12', 'Ampliación del ancho de banda para redes de internet', 'A'),
('Firewall', '2022-06-17 08:44:37', 'Implementación y configuración de firewalls para redes de internet', 'A'),
('VPN', '2023-01-02 10:22:16', 'Configuración y administración de redes privadas virtuales (VPN)', 'B'),
('Servidores de Red', '2022-07-11 21:17:09', 'Instalación y configuración de servidores para redes de internet', 'A'),
('DNS', '2023-03-08 14:12:43', 'Configuración y administración de servidores DNS para redes de internet', 'A'),
('Router', '2022-10-24 05:31:09', 'Configuración y administración de routers para redes de internet', 'B'),
('Switch', '2023-02-15 09:18:29', 'Configuración y administración de switches para redes de internet', 'A'),
('VLAN', '2022-09-18 03:45:12', 'Configuración y administración de VLAN para redes de internet', 'A'),
('Nube', '2022-11-09 13:36:42', 'Implementación y configuración de soluciones de nube para redes de internet', 'B'),
('Backup', '2023-04-01 20:07:37', 'Implementación y administración de soluciones de backup para redes de internet', 'B'),
('Balanceo de carga', '2023-02-15 09:18:29', 'Implementación de soluciones de balanceo de carga para redes de internet', 'A');

INSERT INTO productos (Producto,Marca,EstadoProducto)
VALUES
    ('Switch',null,'A'),
    ('Switch','Cisco','A'),
    ('Router','Cisco','B'),
    ('Router','Mikrotik','B'),
    ('Cable','UTP','A'),
    ('Servidor',null,'A'),
    ('Switch','Cisco','A'),
    ('Switch','HP','A'),
    ('Switch','Dell','B'),
    ('Router','Cisco','A'),
    ('Router','Juniper','B'),
    ('Firewall','Fortinet','A'),
    ('Firewall','Palo Alto','B'),
    ('Access Point','Aruba','A'),
    ('Access Point','Ubiquiti','A'),
    ('Access Point','Ruckus','B'),
    ('Cable UTP','Belden','A'),
    ('Cable UTP','Panduit','A'),
    ('Patch Panel','Leviton','A'),
    ('Patch Panel','Belden','B');
  
INSERT INTO entradas (FechaEntrada,Observaciones,EstadoEntrada)
VALUES
    ('2023-01-01',null,'F'),
    ('2023-02-02','Observaciones2','F'),
    ('2023-05-05',null,'F'),
    ('2023-01-20',null,'E'),
    ('2023-03-15','-','F'),
    ('2023-04-10','Ninguna','F'),
    ('2023-06-06','Ninguna','F'),
    ('2023-07-12',null,'E'),
    ('2023-08-21','Observaciones9','F'),
    ('2023-09-09',null,'E'),
    ('2023-10-05',null,'F'),
    ('2023-11-11','Ninguna','E'),
    ('2023-12-25',null,'F'),
    ('2024-01-01',null,'F'),
    ('2024-02-14',null,'E'),
    ('2024-03-17','-','E'),
    ('2024-04-22','Ninguna','F'),
    ('2024-05-01',null,'E'),
    ('2024-06-10',null,'F'),
    ('2024-07-04','Observaciones20','E');
    
INSERT INTO lineasEntrada (IdEntrada,IdProducto,CostoUnitario,Cantidad)
VALUES
    (1,1,15000,10),
    (1,3,25000,5),
    (1,6,100000,2),
    (2,5,2000,20),
    (2,3,25000,2),
    (5,4,30000,2),
    (5,2,50000,2),
    (5,7,80000,1),
    (6,9,15000,10),
    (6,11,35000,5),
    (6,12,20000,3),
    (6,15,40000,2),
    (9,13,30000,3),
    (9,16,50000,1),
    (9,17,10000,15),
    (9,18,20000,5),
    (9,19,15000,10),
    (10,1,10000,5),
    (10,8,50000,2),
    (10,20,100000,1);

INSERT INTO servicios (IdUsuario,IdTecnico,IdVendedor,IdTipoServicio,Titulo,FechaAlta,FechaBaja,FechaFinalizacion,FechaPago,Observaciones)
VALUES
    (1,26,16,1,'Instalación','2023-07-27 15:02:15',null,null,null,'Zona dificil de acceder.'),
	(1,null,17,2,'Mantenimiento','2023-10-28 01:36:34','2023-11-05 12:18:19',null,null,'Servicio incompleto, cliente insatisfecho.'),
	(2,27,18,3,'Soporte','2023-04-03 13:35:46',null,'2023-07-08 01:11:26',null,'Reparación realizada con rapidez.'),
	(3,null,17,1,'Instalación','2023-11-12 08:30:00',null,'2023-12-28 06:00:00','2023-12-29 17:30:04','Cliente feliz con el servicio.'),
	(4,26,17,2,'Mantenimiento','2022-04-28 23:10:13',null,'2022-08-21 07:30:49','2022-10-21 14:30:10','Servicio terminado con éxito.'),
	(5,30,20,5,'Wireless','2022-10-17 19:11:16',null,'2024-02-12 23:08:15','2023-10-07 14:30:19','Servicio excepcional, cliente contento.'),
	(6,29,21,6,'Seguridad','2023-09-30 13:40:48',null,null,null,'Cambio de sistema operativo.'),
	(1,null,16,9,'Cableado','2023-08-10 12:00:00',null,null,null,null),
	(1,null,17,2,'Mantenimiento','2023-10-28 01:36:34','2022-09-02 06:18:19',null,null,'Servicio incompleto, cliente insatisfecho.'),
	(2,27,18,6,'Seguridad','2023-04-03 13:35:46',null,'2023-07-08 01:11:26',null,'Cambio de sistema operativo.'),
	(3,null,17,1,'Instalación','2023-11-12 03:27:41',null,'2023-11-25 06:03:48','2023-11-26 17:30:04','Cliente feliz con el servicio.'),
	(4,26,17,2,'Mantenimiento','2022-04-28 23:10:13',null,'2022-08-21 07:30:49','2022-10-21 14:30:10','Servicio terminado con éxito.'),
	(4,30,16,4,'Configuración','2022-12-28 15:42:58',null,'2023-08-20 12:40:12','2023-06-22 21:14:16','Cliente satisfecho con el servicio.'),
	(5,30,16,5,'Wireless','2022-10-17 19:11:16',null,'2024-02-12 23:08:15','2023-10-07 14:30:19','Servicio excepcional.'),
    (5,null,19,6,'Seguridad','2023-04-28 13:47:16',null,null,null, null),
    (6,null,21,6,'Seguridad','2023-09-30 13:40:48',null,null,null,'Servicio incompleto, cliente insatisfecho.'),
    (7,28,24,7,'Virtualización','2023-03-15 21:57:16',null,null,null,null),
    (8,null,25,8,'Redes','2023-06-10 08:08:53','2023-09-11 17:26:22',null,null,'Dificultad en movilidad.'),
    (9,27,16,9,'Cableado','2023-08-17 14:09:32','2023-12-02 00:08:01',null,null,null),
    (13,null,24,5,'Wireless','2023-11-25 07:45:39',null,'2023-07-30 04:02:28',null,'Problema resuelto con éxito.');

INSERT INTO lineasServicio (IdServicio,IdUsuario,IdProducto,PrecioUnitario,Cantidad,Detalle)
VALUES
	(1,1,1,20000,5,null),
	(1,1,3,30000,2,null),
	(1,1,6,30000,1,null),
	(1,1,5,35000,10,null),
	(1,1,3,20000,1,null),    
	(2,1,4,20000,1,null),
	(2,1,2,30000,1,null),
	(2,1,7,35000,1,null),
	(2,1,9,50000,7,null),  
	(3,2,1,30000,2,null),
	(4,3,3,35000,1,null),
	(4,3,6,100000,1,null),
	(5,4,11,20000,2,null),
	(5,4,12,30000,1,null),
	(5,4,15,30000,1,null),
	(5,4,13,35000,1,null),
	(5,4,16,20000,1,null),
	(6,5,17,20000,12,null),
	(6,5,18,20000,3,null),
	(7,6,19,20000,9,null);