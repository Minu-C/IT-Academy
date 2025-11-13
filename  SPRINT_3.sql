
-- Ejercicio 1
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(255) PRIMARY KEY,
	iban VARCHAR(50),
	pin TINYINT(4),
	cvv TINYINT(3),
	expiring_date DATE
);
SHOW COLUMNS FROM credit_card;

 # errores de type data al intentar subir los datos. Así que hago esas correcciones

ALTER TABLE credit_card MODIFY COLUMN iban VARCHAR(255) NULL;
ALTER TABLE credit_card ADD pan VARCHAR(255) NULL;
ALTER TABLE credit_card MODIFY COLUMN pin INT(20) NULL;
ALTER TABLE credit_card MODIFY COLUMN cvv INT(10) NULL;
ALTER TABLE credit_card MODIFY COLUMN expiring_date VARCHAR(255) NULL;

	#verifico que la data se haya subido
SELECT * FROM credit_card;
	
    #agregar relación con la tabla transactions
ALTER TABLE transaction ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id) ;




-- Ejercicio 2 _ Busco el ID CcU-2938 

SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

	#Modifico los datos del iban por el correcto: _ TR323456312213576817699999
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

	#verificio si ha sido modificado 
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';



-- Ejercicio 3 - ingresa una nueva transacción en la tabla transacciones
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, '-117.999',  111.11, 0);

-- ERROR 1452. no puedo insertar la data, porque el id_company ni credit_card_id existen
	# por la restricciones tienen que exisitir
    
	# inserto el company_id a la tabla company
INSERT INTO company (id)
VALUES ('b-9999');

	#verifico
SELECT * 
FROM company
WHERE id = 'b-9999';

	#segunda restricción en credit card. Agrego los datos a la tabla de credit_card
INSERT INTO credit_card(id)
VALUES ('CcU-9999');

	#verifico
SELECT * 
FROM credit_card
WHERE id = 'CcU-9999';   
 
	#ahora si,insertar los datos en transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, '-117.999',  111.11, 0);

	#verifico
SELECT * 
FROM transaction
WHERE id='108B1D1D-5B23-A76C-55EF-C568E49A99DD';



-- Ejercicio 4 _ eliminar la columna "pan" de la tabla credit_card

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT * FROM credit_card;



-- NIVEL 2 
-- Ejercicio 1 -- Elimina de la tabla transacción ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD
 #verifico
SELECT * 
FROM transaction
WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

 #elimino
DELETE FROM transaction WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

 #verifico
SELECT * 
FROM transaction
WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';


-- NIVEL 2   
-- Ejercicio 2 -- crear una VistaMarketing: Nombre de la compañía. Teléfono de contacto. País. Media de compra. 
					-- ordenando los datos de mayor a menor promedio de compra.
# company_name, phone, country (from company)
# AVG amount from transaction DESC (from transaction)

DROP VIEW VistaMarketing;

CREATE VIEW VistaMarketing AS
SELECT 
	c.company_name, 
	c.phone, 
	c.country, 
   	AVG(amount) AS promedio
FROM company c  
JOIN transaction t ON t.company_id = c.id
GROUP BY c.id, c.company_name
ORDER BY promedio DESC;

SELECT * FROM VistaMarketing;


-- NIVEL 2 
-- Ejercicio 3 -- Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT * FROM VistaMarketing
WHERE country='Germany';



-- NIVEL 3 
-- Ejercicio 1 - 
	# Primero creo la tabla datos_user
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);
	#verifico la tabla 
SHOW COLUMNS FROM user;

	#Segundo subo los datos "datos introducir sprint3 user.sql"
	#verifico que se ha subido todo
SELECT * FROM user;

   #agregar relación con la tabla transactions
ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES user(id);
SHOW COLUMNS FROM transaction;

 #Error Code: 1215. Cannot add foreign key constraint
 #Investigando una causa de error he encontrado que NO coinciden el data type de user_id en transaction con id en la tabla user. 
 #Modifico data type de la columna user_id en transaction
 
 ALTER TABLE transaction MODIFY COLUMN user_id CHAR(10);

	#verificio que ha sido modificado y vuelvo a intentar
ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES user(id);

#de nuevo ERROR 
#Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`transactions`.`#sql-a3_c`, CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`))
SELECT * FROM transaction
WHERE user_id = 'NULL';

SELECT DISTINCT user_id
FROM transaction
WHERE user_id IS NOT NULL
  AND user_id NOT IN (SELECT id FROM user);

SELECT * FROM user
WHERE id = '9999';

# Ha descubierto que ese único valor de user_id, es el que no existe en la tabla user.
# Por eso no me deja crear la foreign key.
# Todos los valores actuales en la columna transaction.user_id tienen que tener su “pareja” en user.id.
# Añado el registro en la tabla user, para que coincida

INSERT INTO user(id)
VALUES ('9999');

	#Verifico que se ha creado
SELECT * FROM user
WHERE id = '9999';

	#Vuevlo a intentar crear la FK
ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES user(id);

	#Verifico
SHOW COLUMNS FROM transaction;

	# cambio nombre de tabla para que haga match con la imagen del diagrama la tarea
ALTER TABLE user RENAME data_user;


-- NIVEL 3 
-- Ejercicio 2 -- Crear una vista llamada "InformeTecnico"- LÓGICA: 
	# transaction.id, company.name = tienen que tener el mismo company id 
    # user.name, user.surname, credit_card.iban = tienen que tener el mismo user id. 
    # transaction y user = mismo user id.
    # transaction y credit card = mismo credit card id

DROP VIEW InformeTecnico; 

CREATE VIEW InformeTecnico AS
SELECT 
    t.id AS transaction_id,
    c.company_name,
    d.name,
    d.surname,
    cc.iban 
FROM transaction t
INNER JOIN company c ON t.company_id = c.id
INNER JOIN data_user d ON t.user_id = d.id
INNER JOIN credit_card cc ON t.credit_card_id = cc.id
ORDER BY t.id DESC;

SELECT * FROM InformeTecnico;


