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
CREATE OR REPLACE VIEW kursyAll AS
SELECT 
    r.nazwa AS nazwa_kursu, 
    w.imie || ' ' || w.nazwisko AS wykladowca,
    (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id) AS liczba_uczestnikow
FROM kursySiedziba k
JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
UNION ALL
SELECT 
    rf.nazwa, 
    wf.imie || ' ' || wf.nazwisko,
    (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = kf.kurs_id)
FROM kursyFilia kf
JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id;

#zad8
SELECT SUM(przychod) AS przychod_laczny FROM (
    SELECT r.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id) AS przychod
    FROM kursySiedziba k JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    UNION ALL
    SELECT rf.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = kf.kurs_id)
    FROM kursyFilia kf JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
);

#zad9
SELECT SUM(koszt) AS koszty_laczne FROM (
    SELECT w.stawka * r.godz AS koszt
    FROM kursySiedziba k 
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
    UNION ALL
    SELECT wf.stawka * rf.godz
    FROM kursyFilia kf 
    JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
    JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id
);

#zad10
SELECT nazwa_kursu, (przychod - koszt) AS wynik_finansowy FROM (
    SELECT r.nazwa AS nazwa_kursu, 
           (r.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id)) AS przychod,
           (w.stawka * r.godz) AS koszt
    FROM kursySiedziba k 
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
    UNION ALL
    SELECT rf.nazwa, 
           (rf.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = kf.kurs_id)),
           (wf.stawka * rf.godz)
    FROM kursyFilia kf 
    JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
    JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id
);

#zad11
SELECT SUM(wynik_kursu) AS zysk_calkowity_firmy FROM (
    SELECT (r.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id)) - (w.stawka * r.godz) AS wynik_kursu
    FROM kursySiedziba k JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
    UNION ALL
    SELECT (rf.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = kf.kurs_id)) - (wf.stawka * rf.godz)
    FROM kursyFilia kf JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id
);
