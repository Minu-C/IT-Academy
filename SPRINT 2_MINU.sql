SELECT * FROM company
;
-- Llistat dels països que estan generant vendes.
SELECT company.id, company.country, transaction.amount
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
ORDER BY transaction.amount DESC
;
-- Des de quants països es generen les vendes.
SELECT company.id, company.country, transaction.timestamp
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
ORDER BY transaction.timestamp
;
-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company.id, company.company_name, transaction.amount
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
ORDER BY transaction.amount DESC;

-- He logrado identificar monto de venta más alto. Ahora tengo que lograr la media AVG 
SELECT company.id, company.company_name, AVG(transaction.amount) AS promedio
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
GROUP BY company.id, company.company_name
ORDER BY promedio DESC;

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT company.company_name, company.country
FROM company
WHERE company.country='Germany';

-- aquí logré filtrar compañias por país, ahora tengo que hacerlo en transacciones
SELECT * FROM transaction
WHERE company_id IN (
	SELECT company_id
    FROM company
    WHERE country='Germany');
    
-- lo filtré pero no veo la columna. ahora intentar visualizar la columna country
SELECT transaction.company_id, transaction.timestamp, transaction.amount,
	(SELECT company.country 
    FROM company 
    WHERE company.id=transaction.company_id 
	AND country='Germany') AS country
FROM transaction ;

-- lográ filtrar y ver la columna de país, pero me muestra los de Alemania y los vacíos. 
-- volver a intentar pero que no me muestre los null

SELECT transaction.company_id, transaction.timestamp, transaction.amount,
    (SELECT company.company_name
    FROM company
    WHERE company.id=transaction.company_id) AS company_name,
    (SELECT company.country 
    FROM company 
    WHERE company.id=transaction.company_id) AS country
FROM transaction
WHERE transaction.company_id IN (
	SELECT id 
    FROM company
    WHERE country='Germany');
    
-- empreses que han realitzat transaccions per un amount superior a la mitjana. 
-- agrupar por company id y company_name / calcular el promedio de todas las transacciones (global) 

SELECT company_name,
	(SELECT AVG(amount)
    FROM transaction
    WHERE transaction.company_id=company.id) AS promedio
FROM company
ORDER BY promedio;

-- / filtrar y mostrar las que SUPERAN ese promedio (global)

SELECT company_name,
	(SELECT AVG (amount)
	FROM transaction
	WHERE transaction.company_id=company.id) AS promedio
FROM company
WHERE 
	(SELECT AVG (amount)
	FROM transaction) <
    (SELECT AVG(amount)
    FROM transaction
    WHERE transaction.company_id=company.id)
ORDER BY promedio;

-- Eliminaran del sistema les empreses que no tenen transaccions registrades
-- primero hacer una lista de las empresas sin transacciones
SELECT *
FROM company
WHERE id NOT IN 
	(SELECT company_id
  	  FROM transaction);
      
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos

SELECT
    DATE(timestamp) AS fecha,
    SUM(amount) AS total_ventas
FROM transaction
GROUP BY DATE(timestamp)
ORDER BY total_ventas DESC
LIMIT 5;

-- Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT transaction.id, transaction.company_id, transaction.timestamp, transaction.amount, 
    (SELECT company.company_name 
        FROM company 
        WHERE company.id = transaction.company_id) AS empresa,
    (SELECT company.country 
        FROM company 
        WHERE company.id = transaction.company_id) AS pais,
    (SELECT SUM(t2.amount)
        FROM transaction AS t2
        WHERE DATE(t2.timestamp) = DATE(transaction.timestamp)) AS total_ventas_dia
FROM transaction
WHERE DATE(transaction.timestamp) IN (
    SELECT fecha
    FROM (
        SELECT DATE(timestamp) AS fecha
        FROM transaction
        GROUP BY DATE(timestamp)
        ORDER BY SUM(amount) DESC
        LIMIT 5) AS dias_top
	)
ORDER BY DATE(transaction.timestamp), transaction.amount DESC; 

--  mitjana de vendes per país
SELECT
  company.country,
  AVG(transaction.amount) AS promedio,
  COUNT(*) AS transacciones
FROM company
JOIN transaction ON transaction.company_id = company.id
GROUP BY company.country
ORDER BY transacciones DESC;

