
-- Nivel 1
CREATE DATABASE sprint_4;

-- Crear tablas + upload data:

-- TRANSACTION / id; card_id; business_id; timestamp; amount; declined; product_ids; user_id; lat; longitude
	CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        card_id VARCHAR(15) REFERENCES credit_card(id),
        business_id VARCHAR(20), 
		timestamp TIMESTAMP,
		amount DECIMAL(10, 2),
        declined BOOLEAN,
        product_id VARCHAR(15) REFERENCES products,
		user_id INT REFERENCES user(id),
		lat FLOAT,
        longitude FLOAT
	);
    
-- COMPANY: company_id,company_name,phone,email,country,website
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
	
    SHOW COLUMNS FROM company;
    SELECT * FROM company;
    
   
-- PRODUCTS: id, product_name,price,colour,weight,warehouse_id
	CREATE TABLE IF NOT EXISTS products (
        id VARCHAR(15) PRIMARY KEY,
        product_name VARCHAR(255),
        price VARCHAR(1000),
        color VARCHAR(15),
        weight DECIMAL(10, 2),
        warehouse_id VARCHAR(15)
    );

	SHOW COLUMNS FROM products;
    SELECT * FROM products;
    
		#modifico data type
			ALTER TABLE products MODIFY COLUMN id VARCHAR(255);
			
		#limpio los registros NULL
			ALTER TABLE products DROP PRIMARY KEY;
			DELETE FROM products WHERE id IS NULL;
			SELECT * FROM products WHERE id IS NULL;
			
			SELECT COUNT(*) FROM products
			WHERE id IS NULL;
			
		#Agrego la primary key nuevamente
			ALTER TABLE products ADD PRIMARY KEY (id);
    

-- CREDIT_CARD: id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date
	CREATE TABLE IF NOT EXISTS credit_card (
		id VARCHAR(255) PRIMARY KEY NOT NULL,
		user_id CHAR(10),
		iban VARCHAR(50),
		pan VARCHAR(255),
		pin INT(10),
		cvv INT(10),
		track1 VARCHAR (255),
		track2 VARCHAR (255),
		expiring_date VARCHAR(255)		
);

		#FK
			ALTER TABLE credit_card ADD FOREIGN KEY (user_id) REFERENCES user(id);
		
		#verifico columnas y tabla
			SHOW COLUMNS FROM credit_card;
			SELECT * FROM credit_card;
	
    
-- USER: id,name,surname,phone,email,birth_date,country,city,postal_code,address
# lógica: uniré la lista de usuarios (american / EU), añadiré una columna REGION, e insertaré esos datos
		DROP TABLE user;
		
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
			address VARCHAR(255),
			region VARCHAR(255)
	);
		
        #FK
			ALTER TABLE user DROP PRIMARY KEY ;
			ALTER TABLE user MODIFY COLUMN id VARCHAR(255) NOT NULL;
			ALTER TABLE user ADD PRIMARY KEY (id);
		
		#verifico la tabla 
			SHOW COLUMNS FROM user;
    
		-- -- -- -- -- -- -- --
		-- LOAD DATA INFILE --> no funcionó  por limitaciones de iOS (he seguido el tutorial, tampoco funcionó)
	
						-- 	LOAD DATA LOCAL INFILE '/Users/minu/[PROJECT]/_ 2025/ 05_ Data Analysis/_ SPRINT 4/transactions.csv'
						-- 	INTO TABLE transaction;
							#Error Code: 1148. The used command is not allowed with this MySQL version

						-- 	SHOW VARIABLES LIKE 'local_infile';
							# output: local_infile, OFF
							
						-- 	SET GLOBAL local_infile = 1;
						-- 	SHOW VARIABLES LIKE 'local_infile';
							#output: local_infile, ON
							
						-- 	LOAD DATA LOCAL INFILE '~/dumps/transactions.csv'
						-- 	INTO TABLE transaction;
							#Error Code: 2068. LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.
							
						-- 	SHOW VARIABLES LIKE 'secure_file_priv';
							#output: secure_file_priv, NULL
							
						-- 	SET GLOBAL secure_file_priv= 'users/minu/dumps/';
							
						-- 	LOAD DATA INFILE 'users/minu/dumps/transactions.csv' 
						-- 	INTO TABLE transaction
						-- 	FIELDS TERMINATED BY ',' 
						-- 	IGNORE 1 LINES;
							#Error Code: 2068. LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.
							#Error Code: 1290. The MySQL server is running with the --secure-file-priv option so it cannot execute this statement

		-- #no he logrado subir el archivo con comandos. Haré modificaciones en el cvs manualmente para transformarlo en sql.
		-- -- -- -- -- -- --    

-- LOAD DATA archivos cvs editados y transformados en sql. 
    
    #USER
	SELECT * FROM user;
    
		#soluciones conflictos al subir datos european_users en user
			SELECT * FROM user
			WHERE id IS NULL;
			
			DELETE FROM user 
			WHERE id IS NULL;

		#agrego dato 'eu' en la columna region:
			UPDATE user SET region='eu' WHERE region IS NULL;
		
		#Load american_users y dato "usa" en columna region:
			UPDATE user SET region='usa' WHERE region IS NULL;

		#verifico los datos
			SELECT * FROM user
			ORDER BY region DESC;
    
    #verifico todas las tablas
		SELECT * FROM credit_card;
		SELECT * FROM company;
		SELECT * FROM products;

-- Configuración FK y data type:
		#check formatos:
			 SHOW COLUMNS FROM transaction;
			 SHOW COLUMNS FROM user;
			 SHOW COLUMNS FROM products;

	#FK transaction + credit_card / transaction + company: 
			ALTER TABLE transaction MODIFY COLUMN card_id VARCHAR(255);
			ALTER TABLE transaction ADD FOREIGN KEY (card_id) REFERENCES credit_card(id);  
			ALTER TABLE transaction ADD FOREIGN KEY (business_id) REFERENCES company(id);
			
	#FK transaction + user:    
			ALTER TABLE transaction MODIFY COLUMN user_id VARCHAR(255);
			ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES user(id);  
	
				#Soluciono conflicto: ERROR al crear la FK. Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails
										
						#busco si hay un registro en transaction que NO exista en la tabla user:
						SELECT DISTINCT user_id
						FROM transaction
						WHERE user_id NOT IN (SELECT id FROM user);
				
						#resultado, el user id=1 NO coincide, verifico en la tabla user:
						SELECT * FROM user
						WHERE id=1;
						
						#Agrego el user id 1
						INSERT INTO user(id) VALUES (1); 
						
						#vuelvo a chequear
						SELECT DISTINCT user_id
						FROM transaction
						WHERE user_id NOT IN (SELECT id FROM user);
						
						SELECT *
						FROM user 
						WHERE id=1;
    
		#ahora si agrego FK
			ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES user(id);  
			
		#verifico
			SHOW COLUMNS FROM transaction;


	#FK transaction + products:
		ALTER TABLE transaction MODIFY COLUMN product_id VARCHAR(255);
		ALTER TABLE transaction ADD FOREIGN KEY (product_id) REFERENCES products(id);
		#Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`sprint_4`.`#sql-a3_d`, CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`))

		SELECT product_id
		FROM transaction
		WHERE product_id NOT IN (SELECT id FROM products);
	   #ahora entiendo que el problema es hay múltiples registros en la columna product_id.


	-- Normalización tabla transaction columna products_id. Crear una nueva tabla de relación/union
					#backup
					CREATE TABLE backup_transaction AS SELECT * FROM transaction;
			
			-- crear nueva tabla separando los productos en cada celda. #JSON
					CREATE TABLE transaction_products AS
					SELECT 
						transaction.id AS transaction_id,
						jt.product AS product_id
					FROM transaction
						JOIN JSON_TABLE(
						CONCAT('[', transaction.product_id, ']'),
						'$[*]' COLUMNS (product VARCHAR(10) PATH '$')
					) AS jt;
					
					SELECT * FROM transaction_products; 
					
			#FK transaction + transaction_products:
					ALTER TABLE transaction_products ADD FOREIGN KEY(transaction_id) REFERENCES transaction(id); 
					ALTER TABLE transaction_products ADD FOREIGN KEY (product_id) REFERENCES products(id);
					
					SHOW COLUMNS FROM transaction_products;

    
-- NIVEL 1 | Ejercicio 1 -- usuarios con más de 80 transacciones.
	
	-- comando con SUBCONSULTA
	SELECT t.*
    FROM (
		SELECT user.id,
        COUNT(transaction.id) AS total_transactions
        FROM user
        JOIN transaction
			ON transaction.user_id=user.id
		GROUP BY user.id
    ) AS t
    WHERE t.total_transactions > 80
    ORDER BY total_transactions;
	   
       
			-- comando con JOIN
				SELECT 
					user.id, 
					COUNT(transaction.id) AS total_transaction
				FROM user
				JOIN transaction 
					ON transaction.user_id=user.id
				GROUP BY user.id
				HAVING COUNT(transaction.id) > 80
				ORDER BY total_transaction;
				
    
-- NIVEL 1 | Ejercicio 2 -- media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd.
	#lógica: averiguar promedio por iban (user) de compras hechas a Donec Ltd.

		SELECT 
			cc.iban,
			AVG(t.amount) AS promedio
		FROM credit_card cc
		JOIN transaction t
			ON t.card_id=cc.id
		WHERE t.business_id = (
			SELECT id
			FROM company
			WHERE company_name = 'Donec Ltd'
			)
		GROUP BY cc.iban
		ORDER BY promedio DESC;

-- NIVEL 2:
-- tabla que refleje el estado de las tarjetas de crédito: 
-- si las tres últimas transacciones han sido declinadas entonces es inactivo
-- si al menos una no es rechazada entonces es activo

				#proceso: primero hago una consulta general para comprender la lógica y filtros
					SELECT 
						card_id,
						CASE
							WHEN SUM(declined) > 3 THEN 'inactive'
							ELSE 'active'
						END AS status
					FROM transaction
					GROUP BY card_id
					ORDER BY card_id;
					   
				-- > falta filtrar por fecha
						SELECT 
							card_id,
							CASE 
								WHEN SUM(declined) > 3 THEN 'inactive'
								ELSE 'active'
							END AS status
						FROM (
							SELECT
								card_id,
								declined
							FROM transaction
							ORDER BY timestamp DESC
							) AS t
						GROUP BY t.card_id;
				-- > Esto aún no funciona porque no filtra por las últimas 3
                    #tengo que agregar una cláusala WITH para crear una tabla temporal, 
                    # y que ordene por timestamp, así poder detectar "las últimas 3"
                    # creo la tabla
                    
          CREATE TABLE card_status AS          
			WITH last_3 AS (
					SELECT 
						card_id, declined,
						ROW_NUMBER () OVER ( 
							PARTITION BY card_id
							ORDER BY timestamp DESC
							) AS rn
					FROM transaction 
					)
			SELECT
				card_id,
				CASE 
					WHEN SUM(declined) = 3 THEN 'inactive'
					ELSE 'active'
				END AS status
			FROM last_3
			WHERE rn <= 3
			GROUP BY card_id;
                    
		#verifico
        SELECT * FROM card_status;

 
 -- NIVEL 2: Ejercicio 1
	SELECT COUNT(status)
    FROM card_status
	WHERE status = 'active';
    
  
-- NIVEL 3 | Ejercicio 1 | número de veces que se ha vendido cada producto.
    
    SELECT
		p.id AS product_id,
        p.product_name,
        COUNT(t.product_id) AS total_sold
	FROM products p
    JOIN transaction_products t ON p.id=t.product_id
    GROUP BY
		p.id,
        p.product_name
	ORDER BY product_id;
    
  