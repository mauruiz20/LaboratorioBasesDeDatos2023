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
    ('Holmes','Catherine Belle',21282041624,28204162,'catherineholmesbelle@gmail.com','3814385325','853-3636 Amet St.','PierceKyler','FVN63ZLY4EWG2CJS9QAI1XOB'),
		('Watson Grant','Ava',40361822214,36182221,'avawatsongrant@gmail.com','3816994238','719-8671 Sem Rd.','MendezLiam','XZY29VIF5BDO8UTA3EHN7SML'),
		('Reed','Nina',19328253048,32825304,'nina.reed@gmail.com','3812785042','Ap #114-5087 Ipsum St.','CarpenterMyah','MJH41VGR9ZOL8PYC6KTW3QAI'),
		('Harrington','Milo',25337361198,33736119,'milo.harrington@hotmail.com','3815471997','Ap #716-8987 Fermentum Rd.','MurphyEnzo','RVK65WOZ3SLD7FYT9IJG8NZQ'),
		('Hernandez','Evelyn',30316546132,31654613,'evelyn.hernandez@gmail.com','3818403751','Ap #545-1432 Ultrices Av.','MarshallDevon','CQJ75FHW6YSK1OPM2DBN9LTE'),
		('Frost','Landon',13307965855,30796585,'landon.frost@hotmail.com','3816723850','700-9367 Egestas Ave','SmithKinsley','YXB35IZF2CVP7UJT9ONQ4EHR'),
		('Simmons','Harmony',19318362378,31836237,'harmonysimmons@yahoo.com','3817105569','Ap #313-8464 Consectetuer Rd.','JordanRemington','HAT96RJD3KSX7LOZ2CEV5PUY'),
		('Gonzalez Pittman','Skyler Mariah',24300997336,30099733,'skyler.gonzalezpittman@yahoo.com','3863630621','460-5883 Suspendisse Rd.','WalterFreya','NFI42WTR6SVK9HJX3QLM8UYD'),
		('Lowe','Carson',17308241982,30824199,'carson.lowe@hotmail.com','3815924530','P.O. Box 581, 6216 Erat Avenue','FreemanRowan','PWX38UCM4TLK0GYF9ZSJ1BHE'),
		('Wheeler','Iris',16323205315,32320531,'iris.wheeler@gmail.com','3863978345','P.O. Box 256, 1871 Nunc Av.','FernandezJaylynn','HVA52KMN6PWU4SQO8LEJ7XYT'),
		('Ramirez Stokes','Xander Tyrese',20329116259,32911626,'xander.ramirezstokes@gmail.com','3863134080','Ap #109-8694 Dictum St.','WoodsMiley','DBR75YWH2JXZ4OUG6SFL7VKT'),
		('May','Ivy',13306733598,30673359,'ivymay@hotmail.com','3816673995','Ap #873-3089 Sem St.','HarrisElaina','JUP54YHF7FEM9VKA6XSQ3DBO'),
		('Vasquez','Cody',23324688176,32468817,'cody.vasquez@yahoo.com','3863175544','Ap #757-1421 Cursus Avenue','HartmanDemetrius','UZS85YKB9OQX4TRC2IMV3DWF'),
		('Chen','Alice',10329724081,32972409,'alicechen@hotmail.com','3818475668','Ap #673-4067 Nunc St.','MossLily','KXV79BAJ5ENH1PGO6WLI2USM'),
		('Holland','Maximilian',18311330308,31133031,'maximilianholland@hotmail.com','3812618355','Ap #935-3920 Amet St.','JohnstonKody','PLM93UHB6JQX5YEG8IVK3WZS'),
		('Sharp','Sawyer',15306061443,30606145,'sawyer.sharp@gmail.com','3812103802','P.O. Box 942, 8862 Non Ave','GomezEsperanza','BCF56HQY2ZRK3VUL4LSJ8OWI'),
		('Harding','Stella',14307378459,30737845,'stellaharding@yahoo.com','3819896296','P.O. Box 346, 2915 Vitae Av.','RiveraAri','YMH24XTN8KWQ2SDC6URG1BFO'),
		('Washington','Beckett',15322276305,32227631,'bwashington@yahoo.com','3817165783','8710 Consequat Ave','CarsonMiley','RVG32HPD4FZE9JWO6KNX0SCA'),
		('Nichols','Evangeline',31322361969,32236196,'evangeline.nichols@gmail.com','3863432356','Ap #287-6101 Convallis Av.','MaldonadoMikaela','PFB27SGI5YLK1JZU9OHQ8TXC'),
		('Rhodes Rivers','Jesse Antonia',14305372223,30537222,'jesse.rhodesrivers@yahoo.com','3863917310','Ap #929-3114 Enim St.','BishopKassandra','RMZ81QKI6SUJ7ODF2VLG9BHP'),
		('Dunn','Axel',13313567134,31356714,'axel.dunn@yahoo.com','3816331625','Ap #673-4451 Semper Ave','SantosKaelyn','JQL96TNF7MDZ4VPH2XEI0SGY'),
		('Underwood','Ophelia',27324493277,32449328,'opheliaunderwood@yahoo.com','3819910832','P.O. Box 110, 4383 Libero Avenue','CurtisMatteo','DKS68ZBR5UMI1GHN4WTE1PFO'),
		('Bolton','Zain',18314491123,31449111,'zain.bolton@yahoo.com','3817538115','Ap #799-7803 Ullamcorper. Rd.','StarkCamden','WEH12RCP5IUT8XNB4ZOJ5GQA'),
		('Curtis','Ember',26307943059,30794305,'embercurtis@hotmail.com','3816603012','Ap #880-5427 Nulla St.','OrtegaAnahi','ABN79WKZ2HCO5UER4MYQ7LPJ'),
		('Castro','Aliyah',27323309092,32330909,'aliyahcastro@hotmail.com','3818228483','P.O. Box 120, 7148 Euismod Street','AdamsCallie','JVE32KRW5SCM0IHY6PTA1LXF'),
		('Blevins','Kaidence',19373498849,37349884,'kaidence.blevins@hotmail.com','3819713812','P.O. Box 379, 3689 Nisi Av.','StephensAriah','PIL39DBU8ETR6XOW4NMK0QHC'),
		('Davidson','Dalia',22317403371,31740337,'dalia.davidson@yahoo.com','3818559806','P.O. Box 968, 2317 Euismod Rd.','MathisJaxon','IXG56BVA3NQS2MPZ8DWJ0KLO'),
		('Sanford','Cecelia',15302337413,30233741,'cecelia.sanford@hotmail.com','3817852642','P.O. Box 889, 2312 Diam. Avenue','WuOsvaldo','KBL68XSA9NYM1UCO2WEP7RJD'),
		('Woodard','Raylan',20323186662,32318666,'raylanwoodard@gmail.com','3819651385','Ap #343-7467 Odio Av.','BarajasWade','CJQ39GRN7YFD8OSI5HEM0KLB'),
		('Wilcox Wilcox','Elaina',11308334818,30833481,'elaina.wilcoxwilcox@gmail.com','3863347437','684-6971 Sit Rd.','BaxterFreddy','XSW26YAO4NHG9JCD2BPI1LKU'),
		('Savage','Madden',25320819332,32081933,'madden.savage@yahoo.com','3811799840','4531 Facilisis Av.','CarrollJanae','QOD34LFB6NSJ2WYR8HEP1VCG'),
		('Farrell','Noelani',11301310311,30131031,'noelani.farrell@hotmail.com','3814854297','P.O. Box 866, 5939 Malesuada Ave','LopezGabriella','UPA85VNC9MJD6EFQ4IWG1KBZ'),
		('Rivas','Natalya',17306597397,30659739,'natalya.rivas@hotmail.com','3819386179','1180 Non St.','PowersChloe','MQY54ZPB8IOJ7SWH3NVE6LXC'),
		('Cabrera','Emmy',10303817133,30381713,'emmycabrera@yahoo.com','3817609230','Ap #806-6693 Risus. Ave','CarrilloEliza','DHP56JSF3UTZ8EYV2AQN7WMC'),
		('Dillon','Aidyn',26314663536,31466353,'aidyn.dillon@gmail.com','3818459372','P.O. Box 295, 1364 Neque. St.','SullivanLawrence','DLG81QNE6OXU4JBS2YRM7PCH'),
		('Nelson','Arianna',13306213691,30621369,'arianna.nelson@gmail.com','3817644422','292-6463 Dui. Ave','LambertAlivia','HZP59NUL6FMD3WYO2VEK4XSA'),
		('Faulkner','Aliya',24322845811,32284581,'aliya.faulkner@yahoo.com','3863837081','P.O. Box 537, 4334 Ante Av.','GallowayJairo','FYB48UPN6XOM9VDC7JWR1ESK');

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
	(15, 'Monteros', 'Capitan Caceres', '-', 'A'),
		(16, 'Yerba Buena', 'San Javier', null, 'B'),
		(17, 'Yerba Buena', 'Cevil Redondo', null, 'A'),
		(18, 'Yerba Buena', 'Cevil Redondo', "Ninguna", 'P'),
		(19, 'Yerba Buena', 'San Javier', null, 'P'),
		(20, 'Yerba Buena', 'Cevil Redondo', "Ninguna", 'B'),
		(21, 'Yerba Buena', 'San Javier', null, 'A'),
		(22, 'Yerba Buena', 'Cevil Redondo', 'Ninguna', 'B'),
		(23, 'Yerba Buena', 'San Javier', '-', 'A');

INSERT INTO vendedores (IdUsuario)
VALUES
	(24),
	(25),
	(26),
	(27),
	(28),
	(29),
	(30),
	(31),
	(32),
	(33),
		(34),
		(35),
		(36),
		(37),
		(38),
		(39),
		(40),
		(41),
		(42),
		(43),
		(44),
		(45),
		(46),
		(47);

INSERT INTO tecnicos (IdUsuario,HorarioTrabajo,EstadoTecnico)
VALUES
	(48, '8 a 12 - 14 a 18', 'A'),
	(49, '12 a 16 - 18 a 21', 'B'),
	(50, '8 a 12 - 14 a 18', 'A'),
	(51, '12 a 16 - 18 a 21', 'B'),
	(52, '12 a 16 - 18 a 21', 'A'),
	(53, '8 a 12 - 14 a 18', 'A'),
	(54, '8 a 12 - 14 a 18', 'B'),
	(55, '12 a 16 - 18 a 21', 'A'),
	(56, '8 a 12 - 14 a 18', 'B'),
	(57, '12 a 16 - 18 a 21', 'A'),
    (58, '8 a 12 - 14 a 18', 'A'),
	(59, '12 a 16 - 18 a 21', 'B'),
	(60, '8 a 12 - 14 a 18', 'A'),
	(61, '12 a 16 - 18 a 21', 'B'),
	(62, '12 a 16 - 18 a 21', 'A'),
	(63, '8 a 12 - 14 a 18', 'A'),
	(64, '8 a 12 - 14 a 18', 'B'),
	(65, '12 a 16 - 18 a 21', 'A'),
	(66, '8 a 12 - 14 a 18', 'B'),
	(67, '12 a 16 - 18 a 21', 'A'),
    (68, '8 a 12 - 14 a 18', 'B'),
    (69, '12 a 16 - 18 a 21', 'A'),
    (70, '8 a 12 - 14 a 18', 'B');

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
    ('Switch','TP-Link','A'),
    ('Switch','HP','A'),
    ('Switch','Dell','B'),
    ('Router','TP-Link','B'),
    ('Router','Mikrotik','B'),
    ('Router','Cisco','A'),
    ('Router','Juniper','B'),    
    ('Cable UTP','Belden','A'),
    ('Cable UTP','Panduit','A'),
    ('Cable STP','Panduit','A'),
    ('Servidor',null,'A'),
    ('Firewall','Fortinet','A'),
    ('Firewall','Palo Alto','B'),
    ('Access Point','Aruba','A'),
    ('Access Point','Ubiquiti','A'),
    ('Access Point','Ruckus','B'),    
    ('Patch Panel','Leviton','A'),
    ('Patch Panel','Belden','B');
  
INSERT INTO entradas (FechaEntrada,Observaciones,EstadoEntrada)
VALUES
    ('2023-01-01',null,'F'),
    ('2022-12-05','Observaciones2','F'),
    ('2023-01-05',null,'F'),
    ('2023-01-20',null,'E'),
    ('2023-02-15','-','F'),
    ('2023-02-10','Ninguna','F'),
    ('2023-02-06','Ninguna','F'),
    ('2023-03-12',null,'E'),
    ('2023-03-21','Observaciones9','F'),
    ('2023-03-09',null,'E'),
    ('2023-04-05',null,'F'),
    ('2023-04-11','Ninguna','E'),
    ('2023-05-25',null,'F'),
    ('2023-07-01',null,'F'),
    ('2023-07-14',null,'E'),
    ('2023-08-17','-','E'),
    ('2023-08-22','Ninguna','F'),
    ('2023-10-01',null,'E'),
    ('2023-10-10',null,'F'),
    ('2023-10-14',null,'F'),
    ('2023-10-15',null,'F'),
    ('2023-10-16',null,'F'),
    ('2023-11-01',null,'F'),
    ('2023-12-01',null,'F'),
    ('2023-12-04',null,'F');
    
INSERT INTO lineasEntrada (IdEntrada,IdProducto,CostoUnitario,Cantidad)
VALUES
    (1,1,15000,11),
    (1,3,25000,5),
    (1,6,100000,13),
    (1,7,15000,10),
    (1,8,25000,10),
    (1,9,100000,10),
    (2,5,2000,20),
    (2,3,25000,2),
    (5,4,30000,2),
    (5,2,50000,2),
    (5,7,80000,1),
    (6,9,15000,10),
    (6,11,35000,5),
    (6,12,20000,3),
    (6,15,40000,2),
    (6,1,20000,3),
    (6,2,10000,2),
    (6,3,20000,3),
    (6,4,20000,2),
    (8,10,20000,15),
    (9,13,30000,3),
    (9,16,50000,10),
    (9,17,10000,15),
    (9,18,20000,5),
    (9,19,15000,10),    
    (11,1,10000,5),
    (11,8,50000,2),
    (11,20,100000,10),
    (13,1,10000,12),
    (14,2,10000,7),
    (17,3,30000,20),
    (19,4,40000,4),
    (23,5,50000,9),
    (24,6,60000,10)
    ;

INSERT INTO servicios (IdUsuario,IdTecnico,IdVendedor,IdTipoServicio,Titulo,FechaAlta,FechaBaja,FechaFinalizacion,FechaPago,Observaciones)
VALUES
    (1,48,24,1,'Instalación','2023-07-27 15:02:15',null,null,null,'Zona dificil de acceder.'),
	(1,null,24,2,'Mantenimiento','2023-10-28 01:36:34','2023-11-05 12:18:19',null,null,'Servicio incompleto, cliente insatisfecho.'),
    (2,48,24,3,'Soporte','2023-05-03 13:35:46',null,'2023-05-08 00:00:00',null,'Reparación realizada con rapidez.'),
    (3,null,24,1,'Instalación','2023-11-12 08:30:00',null,'2023-12-28 06:00:00','2023-12-29 17:30:04','Cliente feliz con el servicio.'),
    (4,50,27,2,'Mantenimiento','2023-04-28 23:10:13',null,'2023-08-21 07:30:49','2023-10-21 14:30:10','Servicio terminado con éxito.'),
    (5,49,25,5,'Wireless','2022-12-17 19:11:16',null,'2022-12-31 23:08:15','2023-10-07 14:30:19','Servicio excepcional, cliente contento.'),
    (6,49,25,6,'Seguridad','2023-09-30 13:40:48',null,null,null,'Cambio de sistema operativo.'),			
    (1,null,26,9,'Cableado','2023-08-10 12:00:00',null,null,null,null),
	(1,null,26,2,'Mantenimiento','2023-10-28 01:36:34','2022-09-02 06:18:19',null,null,'Servicio incompleto, cliente insatisfecho.'),    
    (2,50,27,6,'Seguridad','2023-04-03 10:30:00',null,'2023-04-08 01:11:26',null,'Cambio de sistema operativo.'),
	(3,null,27,1,'Instalación','2023-11-12 03:27:41',null,'2023-11-25 02:03:48','2023-11-26 05:30:00','Cliente feliz con el servicio.'),
    (4,51,27,4,'Configuración','2022-12-28 15:42:58',null,'2023-08-20 12:40:12','2023-08-22 21:14:16','Cliente satisfecho con el servicio.'),
    (4,48,25,2,'Mantenimiento','2022-11-28 23:10:13',null,'2022-11-29 01:30:59','2022-12-10 12:45:00','Servicio terminado con éxito.'),
    (5,52,28,5,'Wireless','2022-12-17 15:00:00',null,'2023-02-12 21:00:35','2023-10-07 10:30:00','Servicio excepcional.'),
    (5,null,29,6,'Seguridad','2023-04-28 13:47:16',null,null,null, null),
    (6,null,30,6,'Seguridad','2023-09-30 13:40:48',null,null,null,'Servicio incompleto, cliente insatisfecho.'),	
    (7,53,30,7,'Virtualización','2023-03-15 21:57:16',null,null,null,null),
    (8,null,31,8,'Redes','2023-06-10 08:08:53','2023-09-11 17:26:22',null,null,'Dificultad en movilidad.'),
    (9,54,32,9,'Cableado','2023-08-17 14:09:32','2023-12-02 00:08:01',null,null,null),
    (13,null,33,5,'Wireless','2023-11-25 07:45:39',null,'2023-11-30 04:02:28',null,'Problema resuelto con éxito.'),
    (1,null,24,1,'Colocación de equipos de red','2023-10-12 08:00:00',null,'2023-10-15 12:00:00','2023-10-30 12:30:10','Cliente feliz con el servicio.'),
    (1,null,24,13,'Colocación de servidores','2023-10-20 08:00:00',null,'2023-10-25 18:00:00','2023-11-10 10:45:00','Cliente feliz con el servicio.'),
    (2,50,27,6,'Seguridad','2023-08-03 13:35:46',null,'2023-08-08 01:11:26',null,'Cambio de sistema operativo.'),
	(2,48,24,3,'Soporte','2023-09-03 10:10:10',null,'2023-09-08 05:50:00',null,'Reparación realizada con rapidez.'),
    (6,48,24,3,'Soporte','2023-10-03 10:30:10',null,'2023-10-08 05:00:00',null,'Reparación realizada con rapidez.'),
    (7,52,24,3,'Soporte','2023-04-03 10:00:10',null,'2023-04-08 07:50:00',null,'Reparación realizada con rapidez.'),
    (8,49,24,1,'Instalación','2023-05-20 15:00:00',null,'2023-05-21 18:00:00',null,null),
    (4,59,24,1,'Instalación','2023-07-20 12:00:35',null,'2023-07-25 10:00:00',null,'Zona dificil de acceder.'),
    (1,null,24,1,'Colocación de equipos de red','2023-01-12 08:00:00',null,'2023-01-15 12:00:00','2023-04-30 12:30:10','Cliente feliz con el servicio.'),
    (1,null,24,1,'Colocación de equipos de red','2023-02-12 08:00:00',null,'2023-02-15 12:00:00','2023-03-30 12:30:10','Cliente feliz con el servicio.'),
    (5,52,28,5,'Wireless','2024-01-05 15:00:00',null,'2024-01-12 21:00:35','2024-01-13 10:30:00','Servicio excepcional.');

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
    (3,2,1,30000,7,null),
	(4,3,3,35000,1,null),
	(4,3,6,100000,10,null),
	(5,4,11,20000,2,null),
	(5,4,12,30000,1,null),
	(5,4,15,30000,1,null),
	(5,4,13,35000,1,null),
	(5,4,16,20000,2,null),
	(6,5,17,20000,12,null),
	(6,5,18,20000,3,null),
	(7,6,19,20000,9,null),
    (10,2,1,20000,6,null),    
    (13,4,2,30000,7,null),
    (20,13,9,20000,3,null),
    (21,1,3,20000,6,null),
    (26,7,1,50000,1,null),
    (29,1,6,20000,5,null),
    (30,1,7,20000,3,null),
    (31,5,8,20000,4,null)
    ;