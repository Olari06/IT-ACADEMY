# EXERCICIS SPRINT 2
# NIVELL 1
# EXERCICI 2: utilitzant JOIN realitzaràs les següents consultes:

# Llistat dels països que estan fent compres
SELECT DISTINCT country 
FROM company c
JOIN transaction t
ON c.id = t.company_id;

# Des de quants països es realitzen les compres 
SELECT count(DISTINCT country) AS nombre_paisos_compres
FROM company c
JOIN transaction t
ON c.id = t.company_id;

# Es pot fer sense join, perquè, per la relació de les taules 1 a N, cada transacció
# ha de tenir assignada una companyia d'un pais, i per tant es pot fer la consulta 
# a la taula Company sense relacionar-la amb la taula de Transaccions:
SELECT count(DISTINCT country) AS nombre_paisos_compres
FROM company;

# Identifica la companyia amb la mitjana més gran de vendes
SELECT company_name, avg(amount)
FROM company
JOIN transaction 
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY AVG(amount) DESC
LIMIT 1;
# He considerat que la columna decline quan té valor 1 és una transacció rebutjada,
# i no compte a efectes de "amount" per a calcular valors com AVG.


# EXERCICI 3: utilitzant nomes subconsultes (sense utilitzar JOIN):

# Mostre totes les transaccions realitzades per empreses d'Alemanya
SELECT *
FROM transaction
WHERE company_id IN 
	(SELECT id
	FROM company
	WHERE country = "Germany");
    
# Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions
SELECT company_name
FROM company
WHERE id IN ( 
		SELECT company_id
        FROM transaction
        WHERE amount > (
			SELECT AVG(amount)
			FROM transaction
            WHERE declined = 0)
		)
ORDER BY company_name DESC;

# Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT COUNT(company_name) AS Empreses_sense_transaccions
FROM company 
WHERE id NOT IN
		( SELECT company_id
        FROM transaction );
# El resultat és 0, ja que a no hi ha cap empresa de la taula Company que no tingui com a mínim una transacció
# feta a la taula Transaction, i per tant no hi ha llistat d'empreses per eliminar


# EXERCICIS SPRINT 2 
# NIVELL 2

# EXERCICI 1
# Identifica els cinc dies que es van generar la quantitat més gran d'ingressos a l'empresa
# per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT timestamp, SUM(amount) AS Total
FROM transaction 
WHERE declined = 0
GROUP BY timestamp
ORDER BY Total DESC
LIMIT 5;

# Exercici 2: Quina és la mitjana de Vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT country, ROUND(AVG(amount),2) AS mitjana
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE declined = 0
GROUP BY country
ORDER BY mitjana DESC;

# Exercici 3: En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
# per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes 
# les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
# Mostra el llistat aplicant JOIN i subconsultes.
# Mostra el llistat aplicant solament subconsultes. 

#JOIN I SUBQUERY
SELECT t.id, company_name, country, user_id, timestamp, amount
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE country = (
	SELECT country
	FROM company
	WHERE company_name like "Non Institute"
);

#SUBQUERY
SELECT *
FROM transaction
WHERE company_id IN (
			SELECT id
            FROM company
            WHERE country = (
					SELECT country
					FROM company
					WHERE company_name like "Non Institute")
);


#EXERCICIS SPRINT 2 
#NIVELL 3

#EXERCICI 1
# Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor 
# comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 
# 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

SELECT company_name, phone, country, timestamp, amount
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE (DATE(timestamp) = "2021-04-29"
OR DATE(timestamp) = "2021-07-20"
OR DATE(Timestamp) = "2022-03-13")
AND (amount BETWEEN 100 AND 200)
AND declined = 0
ORDER BY amount DESC;

#EXERCICI 2
#Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
#per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
#però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen 
#més de 4 transaccions o menys.

SELECT company_name, COUNT(t.id) AS num_trans,
CASE
	WHEN COUNT(t.id) > 4 THEN "Si"
    WHEN COUNT(t.id) < 4 THEN "No"
END AS mas_4_trans
FROM transaction t
JOIN company c
ON t.company_id = c.id
GROUP BY company_id
ORDER BY num_trans DESC;
