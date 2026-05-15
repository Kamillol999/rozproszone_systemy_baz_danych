##Zadania

#Zadanie 1
CREATE MATERIALIZED VIEW LOG ON kursanci WITH PRIMARY KEY;

CREATE MATERIALIZED VIEW m_kursanci_fast
REFRESH FAST ON DEMAND
AS SELECT * FROM kursanciSiedziba;

#Zadanie2
CREATE MATERIALIZED VIEW m_kursanci_local_commit
REFRESH FAST ON COMMIT
AS SELECT * FROM kursanci;

#Zadanie3
CREATE MATERIALIZED VIEW m_calkowity_przychod
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS 
SELECT 
    SUM(r.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id)) AS laczny_przychod,
    SUM(r.cena * (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id)) * 0.19 AS podatek_19
FROM kursySiedziba k 
JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id;

#Zadanie4
SELECT capability_name, possible, msgtxt 
FROM MV_CAPABILITIES_TABLE 
WHERE mvname = 'M_CALKOWITY_PRZYCHOD' AND capability_name LIKE 'REFRESH_FAST%';

##Zadania Migawki Complete
#Zadanie1
CREATE MATERIALIZED VIEW REP_wykladowcy
REFRESH COMPLETE ON DEMAND
AS SELECT * FROM wykladowcyFilia;

#Zadanie2
INSERT INTO wykladowcy (wykladowca_id, imie, nazwisko, stawka) 
VALUES (999, 'TESTOWY', 'WYKLADOWCA', 150);
COMMIT;

#Zadanie3
SELECT * FROM REP_wykladowcy;

#Zadanie4
BEGIN
   DBMS_MVIEW.REFRESH('REP_wykladowcy', 'C');
END;
/

#Zadanie5
SELECT * FROM REP_wykladowcy;

#Zadanie6
CREATE MATERIALIZED VIEW REP_godz_wykladowcy_godziny
REFRESH COMPLETE
START WITH LAST_DAY(SYSDATE)
NEXT SYSDATE + 1/24
AS 
SELECT wf.imie, wf.nazwisko, SUM(rf.godz) as suma_godzin
FROM wykladowcyFilia wf
JOIN kursyFilia kf ON wf.wykladowca_id = kf.wykladowca_id
JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
GROUP BY wf.imie, wf.nazwisko;

#Zadanie7
CREATE MATERIALIZED VIEW REP_kursy
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH SYSDATE
NEXT SYSDATE + 7
AS 
SELECT rf.nazwa, wf.imie, wf.nazwisko, rf.godz, rf.cena
FROM kursyFilia kf
JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id;

#Zadanie8
CREATE OR REPLACE VIEW kursy_wszystkie_widok AS
SELECT nazwa, imie, nazwisko, godz, cena FROM REP_kursy
UNION ALL
SELECT r.nazwa, w.imie, w.nazwisko, r.godz, r.cena
FROM kursy k
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id;

#Zadanie9
SELECT mview_name, last_refresh_date, refresh_method, refresh_mode 
FROM USER_MVIEWS;

##Zadania Migawki Fast
#Zadanie1
CREATE MATERIALIZED VIEW LOG ON kursanci WITH PRIMARY KEY;

CREATE MATERIALIZED VIEW LOG ON wykladowcy WITH PRIMARY KEY;

#Zadanie2
CREATE MATERIALIZED VIEW m_kursanci_fast
REFRESH FAST ON DEMAND
AS SELECT * FROM kursanciSiedziba;

CREATE MATERIALIZED VIEW m_kursanci_commit
REFRESH FAST ON COMMIT
AS SELECT * FROM kursanci;

#Zadanie3
SELECT capability_name, possible, msgtxt 
FROM MV_CAPABILITIES_TABLE 
WHERE capability_name LIKE 'REFRESH_FAST%';

#Zadanie4
SELECT capability_name, possible, msgtxt 
FROM MV_CAPABILITIES_TABLE 
WHERE mvname = 'M_CALKOWITY_PRZYCHOD' 
AND capability_name IN ('REFRESH_FAST', 'REFRESH_FAST_AFTER_INSERT', 'REFRESH_FAST_AFTER_ANY_DML', 'ON_COMMIT');
