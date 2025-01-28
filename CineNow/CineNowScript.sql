--------------------------------------------------------------------------------
-- 1) Creazione DATABASE e USE
--------------------------------------------------------------------------------
DROP DATABASE IF EXISTS CineNow;
CREATE DATABASE CineNow;
USE CineNow;

--------------------------------------------------------------------------------
-- 2) Creazione TABELLE
--------------------------------------------------------------------------------

CREATE TABLE utente (
    email VARCHAR(255) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    ruolo VARCHAR(50) NOT NULL
);

CREATE TABLE cliente (
    email VARCHAR(255),
    nome VARCHAR(255) NOT NULL,
    cognome VARCHAR(255) NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES utente(email) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE sede (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    via VARCHAR(255) NOT NULL,
    città VARCHAR(255) NOT NULL,
    cap CHAR(5) NOT NULL
);

CREATE TABLE gest_sede (
    email VARCHAR(255),
    id_sede INT,
    PRIMARY KEY (email, id_sede),
    FOREIGN KEY (email) REFERENCES utente(email) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_sede) REFERENCES sede(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE sala (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_sede INT,
    numero INT NOT NULL,
    capienza INT NOT NULL,
    FOREIGN KEY (id_sede) REFERENCES sede(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE posto (
    id_sala INT,
    fila CHAR(1),
    numero INT,
    PRIMARY KEY (id_sala, fila, numero),
    FOREIGN KEY (id_sala) REFERENCES sala(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE film (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titolo VARCHAR(255) NOT NULL,
    genere VARCHAR(255) NOT NULL,
    classificazione VARCHAR(50) NOT NULL,
    durata INT NOT NULL,
    locandina MEDIUMBLOB,
    descrizione TEXT NOT NULL,
    regista VARCHAR(255) NOT NULL,
    cast VARCHAR(255) NOT NULL,
    is_proiettato BOOLEAN DEFAULT FALSE
);

CREATE TABLE slot (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ora_inizio TIME NOT NULL
);

CREATE TABLE proiezione (
    id INT PRIMARY KEY AUTO_INCREMENT,
    data DATE NOT NULL,
    id_film INT,
    id_sala INT,
    id_orario INT,
    FOREIGN KEY (id_film) REFERENCES film(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_sala) REFERENCES sala(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_orario) REFERENCES slot(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE posto_proiezione (
    id_sala INT,
    fila CHAR(1),
    numero INT,
    id_proiezione INT,
    stato BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_sala, fila, numero, id_proiezione),
    FOREIGN KEY (id_sala, fila, numero) REFERENCES posto(id_sala, fila, numero) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_proiezione) REFERENCES proiezione(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE prenotazione (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email_cliente VARCHAR(255),
    id_proiezione INT,
    FOREIGN KEY (email_cliente) REFERENCES cliente(email) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_proiezione) REFERENCES proiezione(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE occupa (
    id_sala INT,
    fila CHAR(1),
    numero INT,
    id_proiezione INT,
    id_prenotazione INT,
    PRIMARY KEY (id_sala, fila, numero, id_proiezione, id_prenotazione),
    FOREIGN KEY (id_sala, fila, numero) REFERENCES posto(id_sala, fila, numero) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_proiezione) REFERENCES proiezione(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_prenotazione) REFERENCES prenotazione(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);


--------------------------------------------------------------------------------
-- 3) Popolamento tabelle UTENTE, CLIENTE, ecc.
--------------------------------------------------------------------------------

-- 3.1 Utenti
INSERT INTO utente (email, password, ruolo)
VALUES
  ('cliente1@email.com', SHA2('password1', 512), 'cliente'),
  ('cliente2@email.com', SHA2('password2', 512), 'cliente'),
  ('cliente3@email.com', SHA2('password3', 512), 'cliente'),
  ('gestoresede@example.com', SHA2('passwordgestore', 512), 'gestore_sede'),
  ('gestoresede1@example.com', SHA2('passwordgestore1', 512), 'gestore_sede'),
  ('gestorecatena@example.com', SHA2('passwordcatena', 512), 'gestore_catena'),
  ('staff@example.com', SHA2('passwordstaff', 512), 'staff');

-- 3.2 Clienti
INSERT INTO cliente (email, nome, cognome)
VALUES
  ('cliente1@email.com', 'Mario', 'Rossi'),
  ('cliente2@email.com', 'Giulia', 'Bianchi'),
  ('cliente3@email.com', 'Carlo', 'Neri');

-- 3.3 Sede
INSERT INTO sede (nome, via, città, cap)
VALUES
  ('Movieplex Mercogliano', 'Via Centrale, 10', 'Mercogliano', '12345'),
  ("Movieplex L'Aquila", 'Via Roma, 10', "L'Aquila", '67891');

-- 3.4 Gestore Sede -> associato a id_sede=1
INSERT INTO gest_sede (email, id_sede)
VALUES
  ('gestoresede@example.com', 1),
  ('gestoresede1@example.com', 2);

--------------------------------------------------------------------------------
-- 4) Creiamo 5 sale (id=1..5) 
--------------------------------------------------------------------------------
-- inizialmente capienza=0, poi aggiorneremo
INSERT INTO sala (id_sede, numero, capienza)
VALUES 
  (1, 1, 0),  -- sala 1
  (1, 2, 0),  -- sala 2
  (1, 3, 0),  -- sala 3
  (1, 4, 0),  -- sala 4
  (1, 5, 0);  -- sala 5
  
INSERT INTO sala (id_sede, numero, capienza)
VALUES 
  (2, 1, 0),  -- sala 1
  (2, 2, 0),  -- sala 2
  (2, 3, 0),  -- sala 3
  (2, 4, 0),  -- sala 4
  (2, 5, 0);
--------------------------------------------------------------------------------
-- 5) Creazione POSTI (20 file = A..T):
--    prime 4 file = 18 posti
--    restanti 16 file = 20 posti
--    => 392 posti per sala
--    Ripetiamo la logica per tutte le sale
--------------------------------------------------------------------------------

-- Creiamo una tabella temporanea con 20 righe (A..T)
DROP TEMPORARY TABLE IF EXISTS tmp_fila;

CREATE TEMPORARY TABLE tmp_fila (
  fila CHAR(1) NOT NULL,
  fila_numero INT NOT NULL
);

SET @filaLetters = 'ABCDEFGHIJKLMNOPQRST'; 

INSERT INTO tmp_fila (fila, fila_numero)
SELECT SUBSTRING(@filaLetters, n, 1) AS lettera, n AS progressivo
FROM (
    SELECT 1 AS n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
    UNION SELECT 6
    UNION SELECT 7
    UNION SELECT 8
    UNION SELECT 9
    UNION SELECT 10
    UNION SELECT 11
    UNION SELECT 12
    UNION SELECT 13
    UNION SELECT 14
    UNION SELECT 15
    UNION SELECT 16
    UNION SELECT 17
    UNION SELECT 18
    UNION SELECT 19
    UNION SELECT 20
) AS numbers;

-- Creiamo 392 posti per ognuna delle 5 sale
-- (stesso schema di join per sala 1..5)

-- Sala 1
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  1 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 2
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  2 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 3
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  3 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 4
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  4 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 5
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  5 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Aggiorniamo la capienza a 392 (prime 4 file * 18 + 16 file * 20)
UPDATE sala
SET capienza = 392
WHERE id BETWEEN 1 AND 5;
-- Creiamo 392 posti per ognuna delle 5 sale della seconda sede
-- (stesso schema di join per sala 6..10)

-- Sala 6
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  6 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 7
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  7 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 8
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  8 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 9
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  9 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Sala 10
INSERT INTO posto (id_sala, fila, numero)
SELECT 
  10 AS id_sala, 
  f.fila AS fila,
  p.n AS numero
FROM tmp_fila f
JOIN (
  SELECT 1 AS n 
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
) p
ON (
    (f.fila_numero <= 4 AND p.n <= 18)
    OR (f.fila_numero > 4 AND p.n <= 20)
)
ORDER BY f.fila_numero, p.n;

-- Aggiorniamo la capienza a 392 (prime 4 file * 18 + 16 file * 20) per la seconda sede
UPDATE sala
SET capienza = 392
WHERE id BETWEEN 6 AND 10;

--------------------------------------------------------------------------------
-- 6) Film
--------------------------------------------------------------------------------
INSERT INTO film (id, titolo, genere, classificazione, durata, locandina, descrizione, regista, cast, is_proiettato)
VALUES
  (1, 'Conclave', 'Thriller', '14+', 120, LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/conclave.jpg'), "Un thriller ambientato nel mondo della Chiesa e ispirato all'omonimo romanzo di Robert Harris.",'Edward Berger',"Ralph Fiennes,Stanley Tucci,John Lithgow,Sergio Castellitto,Isabella Rossellini",true),
  (2, 'Nosferatu', 'Horror', '16+', 135, LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/nosferatulocandina.jpg'), "L'ultimo horror, dal regista di Nosferatu.",'Robert Eggers',"Nicholas Hoult,Lily-Rose Depp,Aaron Taylor-Johnson,Willem Dafoe,Bill Skarsgård",true),
  (3, 'Sonic 3', 'Avventura', 'T', 90, LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sonic.jpg'), 'Il sequel di Sonic 2.', 'Jeff Fowler',"Jim Carrey,Keanu Reeves",true),
  (4, 'Dove osano le cicogne', 'Commedia', 'T', 95, LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/doveosanolecicogne.jpg'), 'Commedia di Andrea Pintus.', 'Fausto Brizzi',"Angelo Pintus,Gianluca Belardi,Herbert Simone Paragnani",true),
  (5, 'Mufasa', 'Animazione', 'T', 120, LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/mufasalocandina.jpg'), 'La pellicola contemporaneamente prequel e sequel de Il re leone.','Barry Jenkins',"Aaron Pierre,Seth Rogen, Mads Mikkelsen,Beyoncé",true),
  (6, 'The substance', 'Horror', '14+', 120, LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/thesubstance.jpg'), "Un film potente e audace che affronta l'ossessione per la bellezza.",'Coralie Farget',"Demi Moore,Margaret Qually, Hugo Diego Garcia",true),
  (7, 'Wolfman', 'Horror', '14+', 104, LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/wolfman.jpg'), "Dopo il suo ritorno nelle sue terre ancestrali, un'uomo americano viene morso e poi maledetto da un licantropo.",'Leigh Whannell',"Christopher Abbott,Julia Garner",true);
	
--------------------------------------------------------------------------------
-- 7) Slot (ogni 30 min dalle 18:00 alle 22:00)
--------------------------------------------------------------------------------
INSERT INTO slot (ora_inizio)
VALUES
  ('18:00:00'),
  ('18:30:00'),
  ('19:00:00'),
  ('19:30:00'),
  ('20:00:00'),
  ('20:30:00'),
  ('21:00:00'),
  ('21:30:00'),
  ('22:00:00');

--------------------------------------------------------------------------------
-- 8) Proiezioni
--    Assegniamo:
--    - Film 1 -> Sala 1
--    - Film 2 -> Sala 2
--    - Film 3 -> Sala 3
--    - Film 4 -> Sala 4
--    - Film 5 -> Sala 5
--------------------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE InsertProiezioni()
BEGIN
    /* Dichiarazione delle variabili */
    DECLARE slot_durata INT;
    DECLARE remaining_time INT;
    DECLARE v_current_time TIME;
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;

    /* Imposta le date di inizio e fine */
    SET v_start_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY);
    SET v_end_date   = '2025-02-25';

    /* Ciclo per ogni giorno tra v_start_date e v_end_date */
    WHILE v_start_date <= v_end_date DO

        /* ===========================
           Film 1 nelle Sale 1 e 6
           =========================== */
        SET v_current_time = '18:00:00';
        SELECT durata INTO slot_durata FROM film WHERE id = 1;
        SET slot_durata = CEIL(slot_durata / 30); /* Converti la durata in blocchi da 30 min */

        WHILE v_current_time <= '22:00:00' DO
            SET remaining_time = slot_durata * 30;
            WHILE remaining_time > 0 DO
                /* Inserimento per Sala 1 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 1, 1, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                /* Inserimento per Sala 6 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 1, 6, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                SET v_current_time = ADDTIME(v_current_time, '00:30:00');
                SET remaining_time = remaining_time - 30;
            END WHILE;
            SET v_current_time = ADDTIME(v_current_time, '02:00:00');
        END WHILE;

        /* ===========================
           Film 2 nelle Sale 2 e 7
           =========================== */
        SET v_current_time = '18:00:00';
        SELECT durata INTO slot_durata FROM film WHERE id = 2;
        SET slot_durata = CEIL(slot_durata / 30);

        WHILE v_current_time <= '22:00:00' DO
            SET remaining_time = slot_durata * 30;
            WHILE remaining_time > 0 DO
                /* Inserimento per Sala 2 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 2, 2, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                /* Inserimento per Sala 7 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 2, 7, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                SET v_current_time = ADDTIME(v_current_time, '00:30:00');
                SET remaining_time = remaining_time - 30;
            END WHILE;
            SET v_current_time = ADDTIME(v_current_time, '02:15:00');
        END WHILE;

        /* ===========================
           Film 3 nelle Sale 3 e 8
           =========================== */
        SET v_current_time = '18:00:00';
        SELECT durata INTO slot_durata FROM film WHERE id = 3;
        SET slot_durata = CEIL(slot_durata / 30);

        WHILE v_current_time <= '22:00:00' DO
            SET remaining_time = slot_durata * 30;
            WHILE remaining_time > 0 DO
                /* Inserimento per Sala 3 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 3, 3, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                /* Inserimento per Sala 8 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 3, 8, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                SET v_current_time = ADDTIME(v_current_time, '00:30:00');
                SET remaining_time = remaining_time - 30;
            END WHILE;
            SET v_current_time = ADDTIME(v_current_time, '01:30:00');
        END WHILE;

        /* ===========================
           Film 4 nelle Sale 4 e 9
           =========================== */
        SET v_current_time = '18:00:00';
        SELECT durata INTO slot_durata FROM film WHERE id = 4;
        SET slot_durata = CEIL(slot_durata / 30);

        WHILE v_current_time <= '22:00:00' DO
            SET remaining_time = slot_durata * 30;
            WHILE remaining_time > 0 DO
                /* Inserimento per Sala 4 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 4, 4, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                /* Inserimento per Sala 9 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 4, 9, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                SET v_current_time = ADDTIME(v_current_time, '00:30:00');
                SET remaining_time = remaining_time - 30;
            END WHILE;
            SET v_current_time = ADDTIME(v_current_time, '01:35:00');
        END WHILE;

        /* ===========================
           Film 5 nelle Sale 5 e 10
           =========================== */
        SET v_current_time = '18:00:00';
        SELECT durata INTO slot_durata FROM film WHERE id = 5;
        SET slot_durata = CEIL(slot_durata / 30);

        WHILE v_current_time <= '22:00:00' DO
            SET remaining_time = slot_durata * 30;
            WHILE remaining_time > 0 DO
                /* Inserimento per Sala 5 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 5, 5, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                /* Inserimento per Sala 10 */
                INSERT INTO proiezione (data, id_film, id_sala, id_orario)
                    SELECT v_start_date, 5, 10, id
                    FROM slot
                    WHERE ora_inizio = v_current_time;

                SET v_current_time = ADDTIME(v_current_time, '00:30:00');
                SET remaining_time = remaining_time - 30;
            END WHILE;
            SET v_current_time = ADDTIME(v_current_time, '02:00:00');
        END WHILE;

        /* Incrementa la data di 1 giorno */
        SET v_start_date = DATE_ADD(v_start_date, INTERVAL 1 DAY);
    END WHILE;
END $$

DELIMITER ;

/* Esecuzione della procedura */
CALL InsertProiezioni();

--------------------------------------------------------------------------------
-- 9) Popolare la tabella posto_proiezione (REPLICA dei posti per le proiezioni)
--------------------------------------------------------------------------------
INSERT INTO posto_proiezione (id_sala, fila, numero, id_proiezione, stato)
SELECT 
    p.id_sala,
    p.fila,
    p.numero,
    pr.id AS id_proiezione,
    TRUE AS stato
FROM proiezione pr
JOIN posto p ON p.id_sala = pr.id_sala
ORDER BY p.id_sala, p.fila, p.numero, pr.id;
