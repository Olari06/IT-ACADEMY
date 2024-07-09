CREATE DATABASE sprint4; # creació de la base de dades (schema)
DROP DATABASE sprint4;

USE sprint4; # treballarem sobre aquesta base de dades

CREATE TABLE companies (
company_id varchar(20),
company_name varchar(100),
phone varchar(20),
email VARCHAR(100),
country varchar(30),
website VARCHAR(100)
); # creació taula companies

select * FROM companies; # visualització de la taula

load data 
infile "C:/arxius CSV/companies.csv"
into table companies
fields terminated by ','
lines terminated by "\n"
ignore 1 rows; # carrega de dades des de un arxiu

CREATE TABLE products (
id INT,
product_name varchar(100),
price VARCHAR(30),
colour VARCHAR(10),
weight float,
warehouse_id VARCHAR(10)
); # creació taula products

select * FROM products; # visualització de la taula
DROP TABLE products; # eliminació de la taula

load data 
infile "C:/arxius CSV/products.csv"
into table products
fields terminated by ','
lines terminated by "\n"
ignore 1 rows; # carrega de dades des de un arxiu

CREATE TABLE credit_cards (
id varchar(20),
user_id int,
iban varchar(100),
pan VARCHAR(50),
pin varchar(10),
cvv varchar(10),
track1 varchar(150),
track2 VARCHAR(150),
expiring_date varchar(15)
); # creació taula credit_card

select * FROM credit_cards; # visualització de la taula

load data 
infile "C:/arxius CSV/credit_cards.csv"
into table credit_cards
fields terminated by ','
lines terminated by "\n"
ignore 1 rows; # carrega de dades des de un arxiu

CREATE TABLE transactions (
id varchar(200),
card_id varchar(20),
business_id VARCHAR(20),
timestamp VARCHAR(50),
amount VARCHAR(50),
declined VARCHAR(10),
product_ids VARCHAR(50),
user_id VARCHAR(30),
lat VARCHAR(250),
longitude VARCHAR(250)
); # creació taula transactions

SELECT * FROM transactions; # visualització de la taula

load data 
infile "C:/arxius CSV/transactions.csv"
into table transactions
fields terminated by ';'
lines terminated by '\n'
ignore 1 rows; # carrega de dades des de un arxiu

CREATE TABLE users (
id VARCHAR(255),
name varchar(255),
surname VARCHAR(255),
phone VARCHAR(255),
email VARCHAR(255),
birth_date VARCHAR(255),
country VARCHAR(255),
city VARCHAR(255),
postal_code VARCHAR(255),
address VARCHAR(255)
);

SELECT * FROM users; # visualització de la taula
DROP TABLE users; # eliminació de la taula

SET GLOBAL local_infile = "ON"; # per a donar els permisos per carregar els arxius 

load data 
infile "C:/arxius CSV/users_usa.csv"
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows; # carrega de dades des de un arxiu

load data 
infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows; # carrega de dades des de un arxiu

load data 
infile "C:/arxius CSV/users_ca.csv"
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows; # carrega de dades des de un arxiu

# Modificació de les carateristiques del camps i assignació de FK:

ALTER TABLE users MODIFY id int AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE products ADD PRIMARY KEY (id);
ALTER TABLE companies ADD PRIMARY KEY (company_id);
ALTER TABLE credit_cards ADD PRIMARY KEY (id);
ALTER TABLE transactions ADD PRIMARY KEY (id);
ALTER TABLE transactions modify timestamp timestamp;
ALTER TABLE transactions modify amount float;
ALTER TABLE transactions modify declined tinyint(1);
ALTER TABLE transactions modify user_id int;
ALTER TABLE transactions modify lat float;
ALTER TABLE transactions modify longitude float;

DESCRIBE transactions; # per veure els canvis 

ALTER TABLE transactions 
ADD foreign key (card_id)
REFERENCES credit_cards(id); # assignació de FK

ALTER TABLE transactions 
ADD foreign key (business_id)
REFERENCES companies(company_id); # assignació de FK

ALTER TABLE transactions 
ADD foreign key (user_id)
REFERENCES users(id); # assignació de FK

# Exercici 1: Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions
# utilitzant almenys 2 taules.

SELECT users.id, users.name, users.surname
FROM users
WHERE users.id IN (
	SELECT user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(id)>30
    );
    
#Tambien se puede hacer con una join:
SELECT t.user_id, u.name, u.surname, COUNT(t.id) AS num_trans
FROM users u
JOIN transactions t
ON u.id = t.user_id
GROUP BY t.user_id
order by count(t.id) desc
limit 4;
  
    
# Exercici 2: Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, 
# utilitza almenys 2 taules.
SELECT company_name, credit_cards.iban, ROUND(avg(transactions.amount),2) AS Mitjana
FROM transactions
JOIN credit_cards
ON transactions.card_id = credit_cards.id
JOIN companies
ON transactions.business_id = companies.company_id
WHERE company_name = "Donec Ltd"
GROUP BY credit_cards.iban;

# NIVELL 2: Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en 
# si les últimes tres transaccions van ser declinades i genera la següent consulta:
# EXERCICI 1: Quantes targetes estan actives?

# Opción 1: no hay transacciones que se repitan más de 3 veces.
SELECT card_id, declined, count(id)
FROM transactions
where declined = 1
GROUP BY card_id, declined
having COUNT(id) > 3;

# otra opción:
select card_id, 
row_number() over (partition by card_id order by timestamp) as repeticions
from transactions
WHERE declined = 1; # todas las tarjetas se han rechazado solo una vez

# determinar el numero de transaccions per tarjeta
SELECT card_id, COUNT(t.id) AS Num_transaccions, sum(declined) AS Rebutjades
FROM transactions t
GROUP BY card_id, declined;

# INSERTAR 3 REGISTROS CONSECUTIVOS QUE ESTÉN DECLINADOS

INSERT INTO transactions 
VALUES ("008B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-2938",
	"b-2362", "2023-01-01 21:21:21", "89.99", "1", "31", "92", 
    "-117.999", "12.1111"),
    ("009B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-2938",
	"b-2362", "2023-01-01 22:21:21", "89.99", "1", "31", "92", 
    "-117.999", "12.1111"),
    ("010B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-2938",
	"b-2362", "2023-01-01 23:21:21", "89.99", "1", "31", "92", 
    "-117.999", "12.1111");

SELECT * FROM transactions;

# CREAMOS LA CONSULTA QUE HA DE DAR LOS DATOS DE LA NUEVA TABLA
SELECT card_id, # los campos que buscamos son la id de la tarjeta y el status activo o inactivo
  CASE # la determinacion de activa o inactiva la hacemos con un case
    WHEN declined_consecutive >= 3 THEN 'Inactiva' # decline_consecutive es el nombre de la consulta posterior
    ELSE 'Activa'
  END AS Status 
FROM ( # esta es la consulta de donde va a buscar el status activo o inactivo 
  SELECT card_id, declined, timestamp, # con estos campos y un sumatorio de los declined vamos a hacer una partición
         SUM(declined) OVER (PARTITION BY card_id ORDER BY timestamp DESC 
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS declined_consecutive
         # la partición nos cuenta el último declined y los 2 precedentes tambien declined para considerala inactiva
  FROM transactions
  ORDER BY card_id DESC, timestamp DESC # ordenada por la id de la tarjeta y la fecha descendente para obtener 
  # las 3 últimas tarjetas rechazadas
) AS last3
GROUP BY card_id, Status
ORDER BY Status DESC; # ordeno por status descendente para ver el único caso inactivo que hemos creado
# al introducir los nuevos datos de transacciones

# CREAMOS LA NUEVA TABLA DESDE LA CONSULTA ANTERIOR:
CREATE TABLE status_credit_card as
SELECT card_id,
  CASE
    WHEN declined_consecutive >= 3 THEN 'Inactiva'
    ELSE 'Activa'
  END AS Status
FROM (
  SELECT card_id, declined, timestamp,
         SUM(declined) OVER (PARTITION BY card_id ORDER BY timestamp DESC 
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS declined_consecutive
  FROM transactions
  ORDER BY card_id DESC, timestamp DESC
) AS last3
GROUP BY card_id, Status;

SELECT * FROM status_credit_card; # MOSTRAMOS LA TABLA CREADA

# BORRAR DATOS INTRODUCIDOS
DELETE FROM transactions
WHERE id = "008B1D1D-5B23-A76C-55EF-C568E49A99DD";

DELETE FROM transactions
WHERE id = "009B1D1D-5B23-A76C-55EF-C568E49A99DD";

DELETE FROM transactions
WHERE id = "010B1D1D-5B23-A76C-55EF-C568E49A99DD";

# CAMBIAR STATUS TARJETA CcU-2938 A ACTIVA 

DELETE FROM status_credit_card
where card_id="CcU-2938";

INSERT INTO status_credit_card 
VALUES ("CcU-2938", "Activa");

SELECT * 
FROM status_credit_card
WHERE status = "inactiva";

# MODIFICO LA TABLA PARA ASIGNAR PK I FK

ALTER TABLE status_credit_card
ADD PRIMARY KEY(card_id);

ALTER TABLE status_credit_card
ADD FOREIGN KEY fk_status(card_id)
REFERENCES credit_cardS(id);

DESCRIBE status_credit_card;

# Nivell 3: Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
# tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

# creamos la tabla desde una consulta que nos ha de insertar los valores de los campos product_id y transactions_id
CREATE TABLE order_products AS 
SELECT p.id AS product_id, t.id AS transactions_id
FROM products p
LEFT join transactions t
ON FIND_IN_SET(p.id, t.product_ids) > 0;
# uso una left join de productos para obtener todas las transacciones de los productos
# incluso las repetidas y las que no tienen transacción y sale el valor nulo, y 
# la función FIND-IN-SET para que detecte todos los product_ids que hay en cada transacción
# y los inserte individualmente en la nueva tabla

SELECT * FROM order_products;

# EXERCICI 1
# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT product_id, count(transactions_id) AS vegades_producte_venut
FROM order_products
GROUP BY product_id;







