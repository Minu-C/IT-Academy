SELECT COUNT(*) FROM transaction
;

--  N1 / Ejercicio 2 / Listado de los países que están generando ventas.
SELECT company.id, company.country, transaction.amount
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
ORDER BY transaction.amount DESC
;
 -- Luego de la P2P, me he dado cuenta que id y ammount no es necesario. ADEMÁS tengo países repetidos. 
 #Es más sencillo de lo que planteaba
 
 SELECT DISTINCT company.country
 FROM company;


-- N1 / Ejercicio 2 / Des de quants països es generen les vendes.
SELECT company.id, company.country, transaction.timestamp
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
ORDER BY transaction.timestamp
;
 -- Luego de la P2P, me he dado cuenta estaba buscando "desde cuando". 
 #Es más sencillo de lo que planteaba: cuántas empresas generan ventas
 #Lógica: 1- agrupar las empresas iguales. 2-Contar el total

SELECT DISTINCT transaction.company_id
FROM transaction;
 
-- agregamos el COUNT para que nos arroje un número concreto
SELECT COUNT(DISTINCT transaction.company_id)
FROM transaction;
 
 
-- N1 / Ejercicio 2 / Identifica la companyia amb la mitjana més gran de vendes.
SELECT company.id, company.company_name, transaction.amount
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
ORDER BY transaction.amount DESC;

-- He logrado identificar monto de venta más alto. Ahora tengo que lograr la media AVG 
SELECT company.id, company.company_name, AVG(transaction.amount) AS promedio
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
GROUP BY company.id, company.company_name
ORDER BY promedio DESC
LIMIT 1;

-- N1 / Ejercicio 3 / Muestra todas las transacciones realizadas por empresas de Alemania
SELECT * FROM transaction
WHERE transaction.company_id IN (
	SELECT company.id
    FROM company
    WHERE company.country='Germany')
;

	# cuántas transacciones se generaron por compañías de Alemania.

		SELECT COUNT(*) FROM transaction
		WHERE transaction.company_id IN (
			SELECT company.id
			FROM company
			WHERE company.country='Germany')
		;

    
-- N1 / Ejercicio 3 / empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
-- 1 calcular promedio total, 2 empresas que superan el promedio 

SELECT company_name,
	(SELECT AVG(amount)
    FROM transaction
    WHERE transaction.company_id=company.id) AS promedio
FROM company
ORDER BY promedio DESC;

-- He podido calcular el promedio, ahora queda mostrar las que SUPERAN ese promedio (global)
SELECT company_name
FROM company
WHERE id IN (
	SELECT company_id
    FROM transaction
    WHERE amount > (SELECT AVG(amount) FROM transaction)
);


-- N1 / Ejercicio 3 / Eliminarán del sistema las empresas que carecen de transacciones registradas

SELECT *
FROM company
WHERE id NOT IN 
	(SELECT company_id
	FROM transaction);
    
    
--  N2 / Ejercicio 1 / Identifica los cinco días que se generó la mayor cantidad de ingresos

SELECT
    DATE(timestamp) AS fecha,
    SUM(amount) AS total_ventas
FROM transaction
GROUP BY DATE(timestamp)
ORDER BY total_ventas DESC
LIMIT 5;

--  N2/ Ejercicio 2 / media de ventas por país
SELECT
  company.country,
  AVG(transaction.amount) AS promedio
FROM company
JOIN transaction ON transaction.company_id = company.id
GROUP BY company.country
ORDER BY promedio DESC;

--  N2 / Ejercicio 3 /  
-- lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que Non Institute
 #identificar país Non Institute
SELECT company_name, company.country
FROM company
WHERE company_name = 'Non Institute'
;

 #Filtrar transacciones hechas por empresas en UK
SELECT * FROM transaction
WHERE company_id IN (
	SELECT id
    FROM company
    WHERE company.country='United Kingdom')
;

	#junto ambas consultas
SELECT * FROM transaction
WHERE company_id IN (
	SELECT id
    FROM company
    WHERE company.country=(
		SELECT company.country
		FROM company
		WHERE company_name = 'Non Institute')
		)
;

	#contar cuántas empresas son
SELECT COUNT(company_id)
FROM transaction
WHERE company_id IN (
	SELECT id
    FROM company
    WHERE company.country='United Kingdom')
;

#consulta con JOIN
SELECT *
FROM transaction
INNER JOIN company ON transaction.company_id = company.id
WHERE company.country = (
    SELECT country
    FROM company
    WHERE company_name = 'Non Institute'
);





--  N3 / Ejercicio 1 /  Nombre, teléfono, país, fecha y amount, de empresas con transacciones con un valor entre 350 y 400 euros.
-- en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
-- Ordena los resultados de mayor a menor cantidad.
	# Lógica:  Ver tabla company. 
	# Filtrar por fechas. 
	# Sumar columnas fecha y amount de transacciones.
	# Filtrar transacciones de un monto entre 350-400. 
	# Ordenar por amount. 
    
SELECT company.company_name, company.country, company.phone, transaction.timestamp, transaction.amount
FROM company
INNER JOIN transaction ON transaction.company_id=company.id
ORDER BY amount
;

# hemos logrado mostrar las columnas que necesitamos. 
# ahora buscaremos filtrar por las fechas y montos específicos

SELECT company.company_name, 
		company.country, 
        company.phone, 
        transaction.timestamp, 
        transaction.amount
FROM company
INNER JOIN transaction 
	ON transaction.company_id=company.id
	WHERE transaction.amount BETWEEN 350 AND 400
    AND DATE(transaction.timestamp) IN (
      '2015-04-29', 
      '2018-07-20', 
      '2024-03-13'
	)
ORDER BY amount DESC
; 

--  N3 / Ejercicio 2 / cantidad de transacciones que realizan las empresas /
-- especifiques si tienen más de 400 transacciones o menos.
		#Lógica: agrupar company_id 
		# COUNT transaction_id
		# COUNT is equal, more o less than 400

SELECT 
	company.id,
    company.company_name,
    COUNT(transaction.id) AS total,
	CASE
		WHEN COUNT(transaction.id)> 400 THEN 'más 400'
		ELSE 'menos 400'
	END AS transacciones
FROM transaction
INNER JOIN company
	ON company.id = transaction.company_id
GROUP BY company.id
ORDER BY total
;
