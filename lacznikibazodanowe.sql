#zad3
CREATE DATABASE LINK dblinkfilia
CONNECT TO RBDN2_ST11
IDENTIFIED BY start123
using 'baza11b'

#zad4
SELECT * FROM kursanci@dblinkfilia

#zad5
CREATE SYNONYM kursySiedziba
FOR kursy

CREATE SYNONYM kursyFilia
FOR kursy@dblinkfilia

CREATE SYNONYM kursanciSiedziba
FOR kursanci

CREATE SYNONYM kursanciFilia
FOR kursanci@dblinkfilia

CREATE SYNONYM rodzajeSiedziba
FOR rodzaje

CREATE SYNONYM rodzajeFilia
FOR rodzaje@dblinkfilia

CREATE SYNONYM wykladowcySiedziba
FOR wykladowcy

CREATE SYNONYM wykladowcyFilia
FOR wykladowcy@dblinkfilia

#zad6
CREATE VIEW kursanciAll AS
SELECT imie,nazwisko FROM kursanciSiedziba 
UNION 
SELECT imie,nazwisko FROM kursanciFilia

CREATE VIEW wykladowcyAll AS
SELECT imie,nazwisko FROM wykladowcySiedziba 
UNION 
SELECT imie,nazwisko FROM wykladowcyFilia

#zad7(do dokończenia)
CREATE VIEW kursyAll AS
SELECT wykladowca_id, FROM kursanciSiedziba 
UNION 
SELECT imie,nazwisko FROM kursanciFilia