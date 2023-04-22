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

DROP DATABASE IF EXISTS LBD2023G03;
CREATE DATABASE IF NOT EXISTS LBD2023G03;

USE LBD2023G03;

-- 
-- TABLE: clientes 
--

CREATE TABLE clientes(
    IdUsuario        INT UNSIGNED   NOT NULL,
    Localidad        VARCHAR(60)    NOT NULL,
    Comuna           VARCHAR(60)    NOT NULL,
    Observaciones    TEXT,
    EstadoCliente    CHAR(1)        DEFAULT 'P' NOT NULL,
    PRIMARY KEY (IdUsuario)
)ENGINE=INNODB
;



-- 
-- TABLE: entradas 
--

CREATE TABLE entradas(
    IdEntrada        INT UNSIGNED  AUTO_INCREMENT,
    FechaEntrada     DATETIME    NOT NULL,
    Observaciones    TEXT,
    EstadoEntrada    CHAR(1)     DEFAULT 'E' NOT NULL,
    PRIMARY KEY (IdEntrada)
)ENGINE=INNODB
;



-- 
-- TABLE: lineasEntrada 
--

CREATE TABLE lineasEntrada(
    IdLineaEntrada    INT UNSIGNED      AUTO_INCREMENT,
    IdEntrada         INT UNSIGNED      NOT NULL,
    IdProducto        INT UNSIGNED      NOT NULL,
    CostoUnitario     DECIMAL(12, 2)    NOT NULL CHECK (CostoUnitario >= 0),
    Cantidad          SMALLINT          NOT NULL,
    PRIMARY KEY (IdLineaEntrada, IdEntrada, IdProducto)
)ENGINE=INNODB
;



-- 
-- TABLE: lineasServicio 
--

CREATE TABLE lineasServicio(
    NroLinea          INT UNSIGNED      AUTO_INCREMENT,
    IdServicio        INT UNSIGNED      NOT NULL,
    IdUsuario         INT UNSIGNED      NOT NULL,
    IdProducto        INT UNSIGNED,
    PrecioUnitario    DECIMAL(12, 2)    NOT NULL CHECK (PrecioUnitario >= 0),
    Cantidad          SMALLINT          NOT NULL,
    Detalle           TEXT,
    PRIMARY KEY (NroLinea, IdServicio, IdUsuario)
)ENGINE=INNODB
;



-- 
-- TABLE: productos 
--

CREATE TABLE productos(
    IdProducto        INT UNSIGNED   AUTO_INCREMENT,
    Producto          VARCHAR(60)    NOT NULL,
    Marca             VARCHAR(60),
    EstadoProducto    CHAR(1)        DEFAULT 'A' NOT NULL,
    PRIMARY KEY (IdProducto)
)ENGINE=INNODB
;



-- 
-- TABLE: servicios 
--

CREATE TABLE servicios(
    IdServicio           INT UNSIGNED  AUTO_INCREMENT,
    IdUsuario            INT UNSIGNED  NOT NULL,
    IdTecnico            INT UNSIGNED,
    IdVendedor           INT UNSIGNED  NOT NULL,
    IdTipoServicio       SMALLINT UNSIGNED  NOT NULL,
    FechaAlta            DATETIME    NOT NULL,
    FechaBaja            DATETIME,
    FechaFinalizacion    DATETIME,
    FechaPago            DATETIME,
    Observaciones        TEXT,
    PRIMARY KEY (IdServicio, IdUsuario)
)ENGINE=INNODB
;



-- 
-- TABLE: tecnicos 
--

CREATE TABLE tecnicos(
    IdUsuario         INT UNSIGNED    NOT NULL,
    HorarioTrabajo    VARCHAR(100)    NOT NULL,
    EstadoTecnico     CHAR(1)         DEFAULT 'A' NOT NULL,
    PRIMARY KEY (IdUsuario)
)ENGINE=INNODB
;



-- 
-- TABLE: tiposServicio 
--

CREATE TABLE tiposServicio(
    IdTipoServicio     SMALLINT UNSIGNED  AUTO_INCREMENT,
    TipoServicio       VARCHAR(100)    NOT NULL,
    FechaAlta          DATETIME        DEFAULT NOW() NOT NULL,
    Contenido          TEXT            NOT NULL,
    EstadoTServicio    CHAR(1)         DEFAULT 'A' NOT NULL,
    PRIMARY KEY (IdTipoServicio)
)ENGINE=INNODB
;



-- 
-- TABLE: usuarios 
--

CREATE TABLE usuarios(
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
    PRIMARY KEY (IdUsuario)
)ENGINE=INNODB
;



-- 
-- TABLE: vendedores 
--

CREATE TABLE vendedores(
    IdUsuario    INT UNSIGNED  NOT NULL,
    PRIMARY KEY (IdUsuario)
)ENGINE=INNODB
;



-- 
-- INDEX: IX_FechaEntrada 
--

CREATE INDEX IX_FechaEntrada ON entradas(FechaEntrada)
;
-- 
-- INDEX: UI_IdLineaEntrada 
--

CREATE UNIQUE INDEX UI_IdLineaEntrada ON lineasEntrada(IdLineaEntrada)
;
-- 
-- INDEX: UI_NroLinea 
--

CREATE UNIQUE INDEX UI_NroLinea ON lineasServicio(NroLinea)
;
-- 
-- INDEX: UI_IdServicio 
--

CREATE UNIQUE INDEX UI_IdServicio ON servicios(IdServicio)
;
-- 
-- INDEX: IX_FechaAlta 
--

CREATE INDEX IX_FechaAlta ON servicios(FechaAlta)
;
-- 
-- INDEX: UI_TipoServicio 
--

CREATE UNIQUE INDEX UI_TipoServicio ON tiposServicio(TipoServicio)
;
-- 
-- INDEX: UI_Cuenta 
--

CREATE UNIQUE INDEX UI_Cuenta ON usuarios(Cuenta)
;
-- 
-- INDEX: IX_ApellidosNombres 
--

CREATE INDEX IX_ApellidosNombres ON usuarios(Apellidos, Nombres)
;
-- 
-- INDEX: IX_Nombres 
--

CREATE INDEX IX_Nombres ON usuarios(Nombres)
;
-- 
-- TABLE: clientes 
--

ALTER TABLE clientes ADD CONSTRAINT Refusuarios41 
    FOREIGN KEY (IdUsuario)
    REFERENCES usuarios(IdUsuario)
;


-- 
-- TABLE: lineasEntrada 
--

ALTER TABLE lineasEntrada ADD CONSTRAINT Refproductos81 
    FOREIGN KEY (IdProducto)
    REFERENCES productos(IdProducto)
;

ALTER TABLE lineasEntrada ADD CONSTRAINT Refentradas91 
    FOREIGN KEY (IdEntrada)
    REFERENCES entradas(IdEntrada)
;


-- 
-- TABLE: lineasServicio 
--

ALTER TABLE lineasServicio ADD CONSTRAINT Refservicios171 
    FOREIGN KEY (IdServicio, IdUsuario)
    REFERENCES servicios(IdServicio, IdUsuario)
;

ALTER TABLE lineasServicio ADD CONSTRAINT Refproductos191 
    FOREIGN KEY (IdProducto)
    REFERENCES productos(IdProducto)
;


-- 
-- TABLE: servicios 
--

ALTER TABLE servicios ADD CONSTRAINT Reftecnicos121 
    FOREIGN KEY (IdTecnico)
    REFERENCES tecnicos(IdUsuario)
;

ALTER TABLE servicios ADD CONSTRAINT Refvendedores141 
    FOREIGN KEY (IdVendedor)
    REFERENCES vendedores(IdUsuario)
;

ALTER TABLE servicios ADD CONSTRAINT Refclientes151 
    FOREIGN KEY (IdUsuario)
    REFERENCES clientes(IdUsuario)
;

ALTER TABLE servicios ADD CONSTRAINT ReftiposServicio161 
    FOREIGN KEY (IdTipoServicio)
    REFERENCES tiposServicio(IdTipoServicio)
;


-- 
-- TABLE: tecnicos 
--

ALTER TABLE tecnicos ADD CONSTRAINT Refusuarios31 
    FOREIGN KEY (IdUsuario)
    REFERENCES usuarios(IdUsuario)
;


-- 
-- TABLE: vendedores 
--

ALTER TABLE vendedores ADD CONSTRAINT Refusuarios21 
    FOREIGN KEY (IdUsuario)
    REFERENCES usuarios(IdUsuario)
;




INSERT INTO usuarios (Apellidos,Nombres,CUIL,DNI,Email,Telefono,Domicilio,Cuenta,Contrasenia)
VALUES
    ('Owens Harrison','Tanek',22617186042,31677385,'o.tanek@hotmail.com','3811881541','6981 Diam Avenue','WhitakerVernon','LGS84SSK4WJN2HJY7VUV2PUX'),
    ('Smith Hendrix','Noah',37983468345,38257083,'s_noah@hotmail.com','3817249504','318-5377 Sapien Av.','JeffersonThor','ONZ29GHE8LYC8CKO1RWX4EFS'),
    ('Austin Ferrell','Brynn',32225688882,32744732,'austinferrell-brynn@gmail.com','3863747556','4922 Nulla. Street','HornHilda','CPP29YCB3CPH8XEC3TQH8VYK'),
    ('Crosby','Nomlanga',35834510233,35393616,'n_crosby@gmail.com','3863848807','3060 Lobortis Road','SandersPreston','GCP89SYO8IMM9INF3RBT7UDY'),
    ('Justice Mclean','Aileen',39146242092,24515956,'aileen.justicemclean1445@gmail.com','3863852843','P.O. Box 817, 7550 Sem Avenue','TaylorAbel','CRM72FIT8YWX3FCB7KTK7TFY'),
    ('Kane','Raya',36549766353,21012318,'r-kane@hotmail.com','3811565113','Ap #234-7589 Ornare, Avenue','CarterKameko','CDP23CFI6LQN4DOX8XBZ0HHD'),
    ('Gilmore Charles','Cassady',38528786172,30015901,'cassady-gilmorecharles@gmail.com','3863781162','953-5978 Lobortis, Street','DaughertyDrew','QAY28UZD3YJG8MBJ3WQX7QWJ'),
    ('Ferguson Mcbride','Beatrice',21363314357,20938171,'beatricefergusonmcbride@gmail.com','3863438045','P.O. Box 308, 6620 Neque Rd.','HornImogene','IOK82NUJ2YUL1VXY4SDB1MGH'),
    ('Mcgowan','Tamekah',20327308413,32346801,'tamekah-mcgowan6815@hotmail.com','3816352177','Ap #598-2817 A, Street','WilliamHyatt','ISO50QWX8XKQ0VPV1LNK7OOJ'),
    ('Hancock Valenzuela','Maia Garrett',29690696953,34242483,'m-hancockvalenzuela@gmail.com','3812011602','Ap #842-5374 Eu Road','AyersClayton','WMX66CRT9GCY5HJJ1YLV8HUP'),
    ('Barton','Chaney Sophia',34591222857,35994779,'barton.chaneysophia7003@gmail.com','3863611410','515-9619 Ut St.','McgowanRhona','ACL64HLC2LUK1YEG5SYG2YJM'),
    ('Lloyd','Fiona',29217081103,21615385,'l.fiona5649@hotmail.com','3817172016','P.O. Box 681, 3900 Lectus St.','LancasterKevyn','AGC74TOI6KUF9ENF3OSY7ZIT'),
    ('Yang','Isabelle',28127534477,37697183,'isabelleyang6671@hotmail.com','3816657268','976-1256 Blandit St.','LambertBlake','EXL22ZDB7JTR3PIY2FRI8DLO'),
    ('Welch','Sean Jillian',29282643761,32690216,'swelch@hotmail.com','3811539566','Ap #911-288 Nec, Ave','PowersHammett','FKJ52YHP7PMK3DEN1LGS3JEH'),
    ('Riddle Ratliff','Cally',21670045274,22736513,'riddleratliff_cally@hotmail.com','3815415610','P.O. Box 543, 8920 Dui Ave','LangZenia','CVC41KRL2YBS3HBT2URV8CFP'),
    ('Melton Bennett','Donovan',27813058667,38306219,'d.meltonbennett@hotmail.com','3863177517','Ap #531-6485 Adipiscing. St.','BenjaminIsabelle','HCB91MFQ6VRK4IDR3ZEJ6PRM'),
    ('Weber Spears','Leo Joseph',25886628079,31117435,'w_leojoseph@hotmail.com','3863466104','615-6384 Vivamus Rd.','CastilloClark','XZH23SVJ6WDA3EOR2LXL2EWG'),
    ('Rios','Joshua',33376618458,33615409,'joshua.rios@gmail.com','3818682689','Ap #768-537 Tristique St.','SantanaIna','PWY39VFO4XDV4MJI8VXQ6AQC'),
    ('Dotson','Price Knox',34675893175,39954877,'d_priceknox@hotmail.com','3814462615','2261 Sed Av.','CurryGregory','ZJH35BWC7MKV2JJX8CMU7GBX'),
    ('Tanner Dudley','Shellie',21268056227,36933008,'shellie.tannerdudley@gmail.com','3811803552','Ap #148-8426 Ut, Av.','JacobsonBryar','FNI24BRC3DUD4BPE4YPQ5BJI'),
    ('Walters Marshall','Blossom',21374836413,28194976,'bmarshallwalters@gmail.com','3863139091','8346 Cursus Av.','LeeLynn','KTH51DRO2WJQ3MVN7YKU3BGI'),
    ('Douglas','Merritt Michelle',37148143852,30350785,'michelle.douglas6558@gmail.com','3863890019','Ap #543-2665 Elit, Rd.','NguyenJelani','HRI95WKG8MOT9QAE6NJS5UEZ'),
    ('Stafford Mcintosh','Kylee',28083272113,30603471,'kyleestaffordmcintosh5476@hotmail.com','3863556348','P.O. Box 146, 9044 Euismod St.','ReidChava','BIF84SQR2VWJ8ZEN4JSC4BXO'),
    ('Bates','Noah Luna',34814470129,36040884,'noahbatesluna6632@hotmail.com','3863632537','Ap #248-6259 Nulla Rd.','GriffinNayda','AMW89HNI6GDC5FQU1VEJ5UYT'),
    ('Morales Hall','Astra',27736173768,23158539,'a.moraleshall8522@hotmail.com','3811810328','P.O. Box 778, 2720 Ligula. St.','BooneAriana','QPT51ZJF4BGM7EDS5LAW6CXO'),
    ('Sweeney','Sacha Phelan',34897336971,39237834,'sacha.sweeneyphelan@gmail.com','3863918463','P.O. Box 636, 2249 Non, Av.','GrantAnjolie','BWM80HJC3IQP0VVP1ZDY6RTE'),
    ('Ruiz Mcgee','Zenaida Hedy',34812477696,30545143,'zhedyruizmcgee4780@hotmail.com','3863102908','6478 Vitae Av.','McfaddenSalvador','IBG87NYT1VOJ2KUZ0AEF1MHX'),
    ('Parks','Tana Asher',35686912360,33369331,'tana_parksasher@yahoo.com','3816201217','8315 Tincidunt Rd.','VelezJacinda','IJK48QLU6CWT2KOA9XRY9EFS'),
    ('Blackburn Mejia','Shaeleigh Jeanette',34713374269,31227838,'shaeleigh.blackburnmejia@hotmail.com','3863558011','Ap #584-6746 Urna. Av.','HawkinsBrinley','FZU37VKL2TMX4SNJ5GBN0CPE'),
    ('Mcfadden','Sage Gwendolyn',27918809736,37525868,'sage.mcfadden4742@hotmail.com','3863447341','Ap #665-3859 Sodales Av.','GutierrezTanner','CNG13TLP5IUO8HK'),
    ('Barker','Azaria',34949757936,32437554,'azariabarker@gmail.com','3863704388','Ap #331-3051 Eget Av.','WalkerMackenzie','WPK87BVN3MHX9QTY0JAR6FES'),
    ('Nolan','Armando Phillip',34129693755,30070766,'armando.nolanphilip7531@hotmail.com','3863197094','P.O. Box 940, 7108 Nunc. Rd.','MendezValerie','APC19QYO8JZM5ELX7TUI2RGF'),
    ('Morton','Zola Erika',37322356250,37121038,'zola.mortonerika7414@hotmail.com','3863201236','P.O. Box 381, 2662 Id Rd.','FuentesHeath','NBI54GWT2FQL7EOZ8KUA3VXP'),
    ('Graham Ellis','Teegan Alexandra',37312089002,31807394,'teegan.grahamellis6953@gmail.com','3863405539','P.O. Box 416, 5152 Auctor. St.','ShafferClara','DHY25OBZ7NFG9XUK6AWR1EJP'),
    ('Holmes','Catherine Belle',27541174935,28204162,'catherineholmesbelle@gmail.com','3814385325','853-3636 Amet St.','PierceKyler','FVN63ZLY4EWG2CJS9QAI1XOB');

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

INSERT INTO tiposServicio (TipoServicio,FechaAlta,Contenido,EstadoTServicio)
VALUES
    ('Dolor Quisque PC','2022-12-19 02:04:56','elit,','A'),
    ('Cras Interdum Foundation','2022-09-29 01:53:55','euismod mauris eu elit. Nulla facilisi. Sed','A'),
    ('Odio Auctor Limited','2022-11-12 09:28:34','risus','B'),
    ('Quisque Libero Lacus Foundation','2023-04-30 16:41:08','magna. Praesent interdum ligula eu','B'),
    ('Iaculis Ltd','2024-02-05 12:02:11','pretium neque. Morbi quis urna. Nunc quis arcu','A'),
    ('Etiam Ltd','2022-11-15 13:59:55','eget magna. Suspendisse tristique neque venenatis','A'),
    ('Nisi Cum Corp.','2022-05-04 03:27:48','Ut semper pretium neque. Morbi quis urna. Nunc','B'),
    ('Orci Sem Limited','2024-02-15 17:22:12','vestibulum','B'),
    ('Lobortis Risus In Industries','2022-08-11 07:28:23','ipsum non','A'),
    ('Eu Nibh Vulputate Corporation','2022-04-25 02:03:12','Phasellus in felis. Nulla tempor augue','A'),
    ('Egestas Duis Ac Corporation','2022-06-17 08:44:37','amet, diam in','A'),
    ('Nullam Scelerisque Neque Corporation','2023-01-02 10:22:16','magna, tincidunt','B'),
    ('Dolor Nonummy Foundation','2022-07-11 21:17:09','amet, ultricies','A'),
    ('Aenean Malesuada Consulting','2023-03-08 14:12:43','Nulla eu neque','A'),
    ('In Aliquet Inc.','2022-10-24 05:31:09','vel, venenatis','B'),
    ('Sed Tortor Integer Corporation','2023-02-15 09:18:29','ac, feugiat','A'),
    ('Semper Egestas Urna Corporation','2022-09-18 03:45:12','magna, a','A'),
    ('Praesent Interdum Ligula Ltd','2022-11-09 13:36:42','eu, odio','B'),
    ('Nullam Lobortis Quam Corp.','2023-04-01 20:07:37','Morbi accumsan','B'),
    ('Eget Ipsum Suspendisse Industries','2023-01-15 06:55:21','arcu. Sed et','A');

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
    ('2023-03-15','-','E'),
    ('2023-04-10','Ninguna','E'),
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
    (1,1,15000,5),
    (1,3,25000,1),
    (2,6,100000,1),
    (3,5,2000,20),
    (4,3,25000,2),
    (4,4,30000,2),
    (5,2,50000,2),
    (5,7,80000,1),
    (6,9,15000,10),
    (6,11,35000,5),
    (7,12,20000,3),
    (8,15,40000,2),
    (9,13,30000,3),
    (9,16,50000,1),
    (10,17,10000,15),
    (10,18,20000,5),
    (11,19,15000,10),
    (12,1,10000,5),
    (13,8,50000,2),
    (14,20,100000,1);

INSERT INTO servicios (IdUsuario,IdTecnico,IdVendedor,IdTipoServicio,FechaAlta,FechaBaja,FechaFinalizacion,FechaPago,Observaciones)
VALUES
    (1,26,16,1,'2023-07-27 15:02:15',null,null,null,'risus odio, auctor vitae, aliquet nec, imperdiet nec, leo.'),
    (1,null,17,2,'2023-10-28 01:36:34','2022-09-02 06:18:19',null,null,'non'),
    (2,27,18,3,'2023-04-03 13:35:46','2023-12-08 22:38:08','2023-07-08 01:11:26',null,'Sed auctor odio a purus. Duis elementum,'),
    (3,null,17,1,'2023-11-12 03:27:41','2024-03-10 18:00:03','2023-07-28 06:03:48','2023-06-26 17:30:04','mauris id sapien. Cras dolor dolor,'),
    (4,26,17,2,'2022-04-28 23:10:13','2022-10-20 10:33:02','2022-08-21 07:30:49','2022-10-21 14:30:10','amet luctus'),
    (5,30,20,5,'2022-10-17 19:11:16','2023-01-17 06:49:39','2024-02-12 23:08:15','2023-10-07 14:30:19','eu, placerat eget,'),
    (6,29,21,6,'2023-09-30 13:40:48',null,null,null,'et, rutrum eu, ultrices sit'),
    (1,null,16,1,'2023-07-27 15:02:15',null,null,null,'risus odio, auctor vitae, aliquet nec, imperdiet nec, leo.'),
    (1,null,17,2,'2023-10-28 01:36:34','2022-09-02 06:18:19',null,null,'non'),
    (2,27,18,3,'2023-04-03 13:35:46','2023-12-08 22:38:08','2023-07-08 01:11:26',null,'Sed auctor odio a purus. Duis elementum,'),
    (3,null,17,1,'2023-11-12 03:27:41','2024-03-10 18:00:03','2023-07-28 06:03:48','2023-06-26 17:30:04','mauris id sapien. Cras dolor dolor,'),
    (4,26,17,2,'2022-04-28 23:10:13','2022-10-20 10:33:02','2022-08-21 07:30:49','2022-10-21 14:30:10','amet luctus'),
    (4,30,16,4,'2022-12-28 15:42:58','2022-10-20 12:30:00','2023-08-20 12:40:12','2023-06-22 21:14:16','neque tellus, imperdiet non, vestibulum nec, euismod'),
    (5,30,16,5,'2022-10-17 19:11:16','2023-01-17 06:49:39','2024-02-12 23:08:15','2023-10-07 14:30:19','eu, placerat eget,'),
    (5,null,19,6,'2023-04-28 13:47:16',null,null,null, 'nulla facilisi. Cras non velit nec'),
    (6,null,21,6,'2023-09-30 13:40:48',null,null,null,'et, rutrum eu, ultrices sit'),
    (7,28,24,7,'2023-03-15 21:57:16',null,null,null,'ut nisi. Aenean eget metus. In'),
    (8,null,25,8,'2023-06-10 08:08:53','2023-09-11 17:26:22',null,null,'et, rutrum non, hendrerit id,'),
    (9,27,16,9,'2023-08-17 14:09:32','2023-12-02 00:08:01',null,null,'at, velit. Pellentesque ultricies dignissim lacus.'),
    (13,null,24,5,'2023-11-25 07:45:39','2024-03-15 05:45:10','2023-07-30 04:02:28',null,'eros. Nam consequat dolor vitae dolor.');

INSERT INTO lineasServicio (IdServicio,IdUsuario,IdProducto,PrecioUnitario,Cantidad,Detalle)
VALUES
	(1,1,1,20000,1,null),
	(1,1,2,30000,2,null),
	(1,1,3,30000,1,null),
	(1,1,4,35000,1,null),
	(1,1,7,20000,2,null),
	(2,1,1,20000,1,null),
	(2,1,2,30000,1,null),
	(2,1,3,35000,10,null),
	(2,1,4,50000,7,null),
	(3,2,3,30000,1,null),
	(4,3,4,35000,5,null),
	(4,3,6,100000,1,null),
	(5,4,1,20000,10,null),
	(5,4,2,30000,1,null),
	(5,4,3,30000,20,null),
	(5,4,4,35000,5,null),
	(5,4,7,20000,2,null),
	(6,5,1,20000,1,null),
	(6,5,7,20000,2,null),
	(7,6,1,20000,12,null);