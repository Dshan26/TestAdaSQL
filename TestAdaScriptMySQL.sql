-- Firt Test 

-- Tabla Company
-- No olvidar crear el schema o base de datos ejemplo: CREATE SCHEMA `prueba` ;
CREATE TABLE company (
    id_company INT AUTO_INCREMENT PRIMARY KEY,
    codigo_company VARCHAR(255) UNIQUE NOT NULL,
    name_company VARCHAR(255) NOT NULL,
    description_company TEXT
);

-- Tabla Application
CREATE SCHEMA `application` ;
CREATE TABLE application (
    app_id INT AUTO_INCREMENT PRIMARY KEY,
    app_code VARCHAR(255) UNIQUE NOT NULL,
    app_name VARCHAR(255) NOT NULL,
    app_description TEXT
);

-- Tabla Version
CREATE TABLE version (
    version_id INT AUTO_INCREMENT PRIMARY KEY,
    app_id INT UNIQUE NOT NULL,
    version VARCHAR(255) NOT NULL,
    version_description TEXT,
    FOREIGN KEY (app_id) REFERENCES application(app_id)
);

-- Tabla Version_Company
CREATE TABLE version_company (
    version_company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    version_id INT NOT NULL,
    version_company_description TEXT,
    FOREIGN KEY (company_id) REFERENCES company(id_company),
    FOREIGN KEY (version_id) REFERENCES version(version_id)
);

-- Tabla TMP_LLENAR_CAMPOS
CREATE TABLE TMP_LLENAR_CAMPOS (
    id_company INT,
    codigo_company VARCHAR(255),
    name_company VARCHAR(255),
    description_company TEXT,
    version_id INT,
    app_id INT,
    version VARCHAR(255),
    version_description TEXT,
    version_company_id INT,
    version_company_description TEXT,
    app_code VARCHAR(255),
    app_name VARCHAR(255),
    app_description TEXT
);

-- Tabla Company
INSERT INTO company (codigo_company, name_company, description_company)
VALUES 
('COMP001', 'COMPANY ADA', 'Description of COMPANY ADA'),
('COMP002', 'COMPANY BETA', 'Description of COMPANY BETA');

-- Tabla Application
INSERT INTO application (app_code, app_name, app_description)
VALUES 
('APP001', 'Application Alpha', 'Description of Application Alpha'),
('APP002', 'Application Beta', 'Description of Application Beta');

-- Tabla Version
INSERT INTO version (app_id, version, version_description)
VALUES 
(1, '1.0', 'Initial version of Application Alpha'),
(2, '1.1', 'Initial version of Application Beta');

-- Tabla Version_Company
INSERT INTO version_company (company_id, version_id, version_company_description)
VALUES 
(1, 1, 'Version 1.0 for COMPANY ADA'),
(2, 2, 'Version 1.1 for COMPANY BETA');

-- Poblar TMP_LLENAR_CAMPOS
INSERT INTO TMP_LLENAR_CAMPOS (
    id_company, codigo_company, name_company, description_company,
    version_id, app_id, version, version_description,
    version_company_id, version_company_description,
    app_code, app_name, app_description
)
SELECT 
    c.id_company, c.codigo_company, c.name_company, c.description_company,
    v.version_id, a.app_id, v.version, v.version_description,
    vc.version_company_id, vc.version_company_description,
    a.app_code, a.app_name, a.app_description
FROM company c
JOIN version_company vc ON c.id_company = vc.company_id
JOIN version v ON vc.version_id = v.version_id
JOIN application a ON v.app_id = a.app_id;

SELECT * FROM TMP_LLENAR_CAMPOS;



--  -------------------Second Test Junior-----------------------------------

-- 1 image add en png  MVC


-- 2 create data in  version company
 CREATE TABLE version_company (
    version_company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    version_id INT NOT NULL,
    version_company_description TEXT,
    UNIQUE (company_id, version_id),
    FOREIGN KEY (company_id) REFERENCES company(id_company),
    FOREIGN KEY (version_id) REFERENCES version(version_id)
);


-- Add data in TMP_LLENAR_CAMPOS

DELIMITER //

CREATE PROCEDURE InsertDataFromTemp()
BEGIN
    -- Definir variables locales para almacenar cada fila del cursor
    DECLARE temp_id_company INT;
    DECLARE temp_codigo_company VARCHAR(255);
    DECLARE temp_name_company VARCHAR(255);
    DECLARE temp_description_company TEXT;
    DECLARE temp_app_id INT;
    DECLARE temp_app_code VARCHAR(255);
    DECLARE temp_app_name VARCHAR(255);
    DECLARE temp_app_description TEXT;
    DECLARE temp_version_id INT;
    DECLARE temp_version VARCHAR(255);
    DECLARE temp_version_description TEXT;
    DECLARE temp_version_company_id INT;
    DECLARE temp_version_company_description TEXT;

    DECLARE done INT DEFAULT 0; -- Variable para el control del cursor

    -- Cursor CTemporal para leer TMP_LLENAR_CAMPOS
    DECLARE CTemporal CURSOR FOR
    SELECT id_company, codigo_company, name_company, description_company,
           app_id, app_code, app_name, app_description,
           version_id, version, version_description,
           version_company_id, version_company_description
    FROM TMP_LLENAR_CAMPOS;

    -- Handler para detectar el final del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir el cursor
    OPEN CTemporal;

    -- Bucle para procesar cada fila del cursor
    read_loop: LOOP
        FETCH CTemporal INTO temp_id_company, temp_codigo_company, temp_name_company, temp_description_company,
                          temp_app_id, temp_app_code, temp_app_name, temp_app_description,
                          temp_version_id, temp_version, temp_version_description,
                          temp_version_company_id, temp_version_company_description;

        -- Verificar si se terminó de leer el cursor
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insertar datos en la tabla company
        INSERT INTO company (id_company, codigo_company, name_company, description_company)
        VALUES (temp_id_company, temp_codigo_company, temp_name_company, temp_description_company)
        ON DUPLICATE KEY UPDATE 
            name_company = VALUES(name_company), 
            description_company = VALUES(description_company);

        -- Insertar datos en la tabla application
        INSERT INTO application (app_id, app_code, app_name, app_description)
        VALUES (temp_app_id, temp_app_code, temp_app_name, temp_app_description)
        ON DUPLICATE KEY UPDATE 
            app_name = VALUES(app_name), 
            app_description = VALUES(app_description);

        -- Insertar datos en la tabla version
        INSERT INTO version (version_id, app_id, version, version_description)
        VALUES (temp_version_id, temp_app_id, temp_version, temp_version_description)
        ON DUPLICATE KEY UPDATE 
            version = VALUES(version), 
            version_description = VALUES(version_description);

        -- Insertar datos en la tabla version_company
        INSERT INTO version_company (version_company_id, company_id, version_id, version_company_description)
        VALUES (temp_version_company_id, temp_id_company, temp_version_id, temp_version_company_description)
        ON DUPLICATE KEY UPDATE 
            version_company_description = VALUES(version_company_description);
    END LOOP;

    -- Cerrar el cursor
    CLOSE CTemporal;
END;
//

DELIMITER ;



