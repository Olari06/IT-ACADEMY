# SPRINT 3 
# NIVELL 1
#EXERCICI 1
# La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls 
# crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera 
# única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
# Després de crear la taula serà necessari que ingressis la informació del document denominat 
# "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

CREATE TABLE credit_card (
	id VARCHAR (50) NOT NULL,
    iban VARCHAR (150),
    pan VARCHAR (100),
    pin VARCHAR (25),
    cvv VARCHAR (25),
    expiring_date VARCHAR (50),
    PRIMARY KEY (id)
);
    
SELECT * FROM transactions.credit_card;
DESCRIBE credit_card;
    
ALTER TABLE transaction
ADD foreign key fk_credit_card(credit_card_id)
references credit_card(id);
    
DESCRIBE transaction;

#EXERCICI 2: 
# El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari
# amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: 
# R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

SELECT * FROM credit_card
WHERE id = "CcU-2938";

UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";

#EXERCICI 3:
# En la taula "transaction" ingressa un nou usuari amb la següent informació:
# Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
# credit_card_id	CcU-9999
# company_id	b-9999
# user_id	9999
# lat	829.999
# longitude	-117.999
# amount	111.11

INSERT INTO transaction
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999",
	"b-9999", "9999", "829.999", "-117.999", NOW(), "111.11", "0");
# Dona un error de restricció de FK, per això introduirè primer les dades
# a les taules de les PK afectades.

INSERT INTO credit_card
VALUES ("CcU-9999", NULL, NULL, NULL, NULL, NULL);

SELECT * FROM credit_card
WHERE id = "CcU-9999";

INSERT INTO company
VALUES ("9999", NULL, NULL, NULL, NULL, NULL);
# dona un error en el camp company_id
DESCRIBE company;
# per sol.lucionar-ho li dono un valor genèric al camp afectat perque no pot ser NULL
INSERT INTO company
VALUES ("9999", "varis", NULL, NULL, NULL, NULL);

SELECT * FROM company
WHERE id = "9999";

#torno a introduir les dades:
INSERT INTO transaction
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999",
	"b-9999", "9999", "829.999", "-117.999", NOW(), "111.11", "0");
# però continua donant un error de restricció de FK

SHOW CREATE TABLE transaction;
# A continuación hacer click derecho sobre CREATE TABLE 'transaction' .... 
# para abrir Open Value in View y ver las FK que hay (nombre y relación)
    
SET FOREIGN_KEY_CHECKS = 0; # dehabilitar les restriccions

INSERT INTO transaction
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999",
	"b-9999", "9999", "829.999", "-117.999", NOW(), "111.11", "0");    
    
SELECT * FROM transaction
WHERE id="108B1D1D-5B23-A76C-55EF-C568E49A99DD";

SET FOREIGN_KEY_CHECKS = 1;  # habilitar les restriccions

# EXERCICI 4
# Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card.
# Recorda mostrar el canvi realitzat.

SELECT * FROM credit_card;

ALTER TABLE credit_card DROP column pan;

-- NIVELL 2

-- EXERCICI 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 
-- de la base de dades.

SELECT * FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- EXERCICI 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi 
-- i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre 
-- les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing 
-- que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència.
-- Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major 
-- a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, AVG(t.amount) AS mitjana_compres
FROM company c
JOIN transaction t
ON c.id = t.company_id 
GROUP BY c.company_name, c.phone, c.country;

SHOW CREATE VIEW VistaMarketing;
SELECT * FROM VistaMarketing;

-- EXERCICI 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència
-- en "Germany"

SELECT * FROM VistaMarketing
WHERE country = "Germany";

-- NIVELL 3
-- EXERCICI 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip
-- va realitzar modificacions en la base de dades, però no recorda com les va realitzar. Et demana 
-- que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: 

-- Després de comparar els diagrames, hem de realitzar les següents modificacions:
-- De la taula company, eliminem el camp website:

ALTER TABLE company
DROP COLUMN website;

SELECT * FROM company;

-- De la taula credit_card hem de realitzar les següents modificacions:

ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(50);

ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);

ALTER TABLE credit_card
MODIFY COLUMN cvv INT;

ALTER TABLE credit_card
MODIFY COLUMN expiring VARCHAR(10);
 
ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20);

-- dona un error de restricció al camp id. 
-- per solucionar-ho podem des-habilitar temporalment les restricions:

SET FOREIGN_KEY_CHECKS = 1; # tornar a habilitar les restriccions

-- afagir un nou camp amb la data actual de cada registre:

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE DEFAULT(current_date);

SELECT * FROM credit_card;
DESCRIBE credit_card;

-- Ara crearem la taula nova:

CREATE TABLE data_user (
id INT PRIMARY KEY,
name VARCHAR(100),
surname VARCHAR(100),
phone VARCHAR(150),
email VARCHAR(150),
birth_date VARCHAR(100),
country VARCHAR(150),
city VARCHAR(150),
postal_code VARCHAR(100),
address VARCHAR(255),
FOREIGN KEY(id) REFERENCES transaction(user_id)
);
 
-- Indexar el camp user_id per poder fer de FK a transaction:

ALTER TABLE transaction
ADD INDEX(user_id);

-- Canviem el nom de la taula per poder introduir les dades:

ALTER TABLE data_user
RENAME TO user;

SELECT * FROM user; # mostrem la taula

-- Un cop introduides les dades des de l'arxiu .sql, tornem a canviar el nom de la taula:

ALTER TABLE user
RENAME TO data_user;

SELECT * FROM data_user; # mostrem la taula

-- Canviem el nom del camp email per personal_email:

ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

-- EXERCICI 2
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- ID de la transacció, Nom de l'usuari/ària, Cognom de l'usuari/ària, IBAN de la targeta de crèdit usada,
-- Nom de la companyia de la transacció realitzada. 
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes 
-- segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de 
-- transaction.

SELECT * FROM data_user;
SELECT * FROM transaction;
SELECT * FROM credit_card;
SELECT * FROM company;
-- Despres de veure les dades, creem la vista:

CREATE VIEW InformeTecnico AS
SELECT t.id AS transaccio, du.name AS nom, dU.surname AS cognom,
	cc.iban AS iban_tarjeta, c.company_name AS companyia
FROM transaction t
JOIN data_user du
ON t.user_id = du.id
JOIN credit_card cc
ON t.credit_card_id = cc.id
JOIN company c
ON t.company_id = c.id
GROUP BY transaccio
ORDER BY transaccio DESC;

SELECT * FROM InformeTecnico;


