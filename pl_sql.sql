#Zadanie1
SET SERVEROUTPUT ON;
  
DECLARE
  kci_liczba NUMBER;
  ksy_liczba NUMBER;
  w_liczba NUMBER;
BEGIN
  SELECT COUNT(*) INTO kci_liczba FROM kursanci;
  SELECT COUNT(*) INTO ksy_liczba FROM kursy;
  SELECT COUNT(*) INTO w_liczba FROM wykladowcy;

  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || kci_liczba);
  DBMS_OUTPUT.PUT_LINE('Liczba kursów: ' || ksy_liczba);
  DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: ' || w_liczba);
END;
/

#Zadanie2
DECLARE
  v_laczna_wartosc NUMBER;
BEGIN
  SELECT SUM(r.cena)
  INTO v_laczna_wartosc
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || v_laczna_wartosc || ' zł');
END;
/

#Zadanie3
DECLARE
  v_miasto VARCHAR2(30) := 'BYDGOSZCZ';
  v_liczba_umow NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_liczba_umow
  FROM umowy
  WHERE miasto = v_miasto;

  IF v_liczba_umow = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta');
  ELSIF v_liczba_umow < 50 THEN
    DBMS_OUTPUT.PUT_LINE('Mała liczba umów');
  ELSIF v_liczba_umow <= 100 THEN
    DBMS_OUTPUT.PUT_LINE('Średnia liczba umów');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Duża liczba umów');
  END IF;
END;
/

#Zadanie4
BEGIN
  FOR r IN (
    SELECT k.kurs_id, r.nazwa, r.godz, r.cena, w.imie, w.nazwisko
    FROM kursy k
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
    ORDER BY k.kurs_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' || r.godz || 'h, ' || r.cena || ' zł, prowadzący: ' || r.imie || ' ' || r.nazwisko);
  END LOOP;
END;
/

#Zadanie5
CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2)
AS
  v_liczba_umow NUMBER;
  v_laczna_wartosc NUMBER;
  v_srednia_wartosc NUMBER;
BEGIN
  SELECT COUNT(*), NVL(SUM(r.cena), 0), NVL(AVG(r.cena), 0)
  INTO v_liczba_umow, v_laczna_wartosc, v_srednia_wartosc
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = UPPER(p_miasto);

  DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || UPPER(p_miasto));
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba_umow);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_laczna_wartosc || ' zł');
  DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: ' || ROUND(v_srednia_wartosc, 2) || ' zł');
END;
/

#Zadanie6
CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER)
RETURN NUMBER
AS
  v_cena NUMBER;
BEGIN
  SELECT r.cena
  INTO v_cena
  FROM kursy k
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE k.kurs_id = p_kurs_id;

  RETURN v_cena;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Kurs o ID ' || p_kurs_id || ' nie istnieje.');
END;
/

#Zadanie7
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER)
AS
  v_imie kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
  SELECT imie, nazwisko
  INTO v_imie, v_nazwisko
  FROM kursanci
  WHERE kursant_id = p_kursant_id;

  DBMS_OUTPUT.PUT_LINE('Kursant: ' || v_imie || ' ' || v_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/

CREATE OR REPLACE PROCEDURE pokaz_kursanta_po_nazwisku(p_nazwisko IN VARCHAR2)
AS
  v_imie kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
  SELECT imie, nazwisko
  INTO v_imie, v_nazwisko
  FROM kursanci
  WHERE UPPER(nazwisko) = UPPER(p_nazwisko);

  DBMS_OUTPUT.PUT_LINE('Znaleziono kursanta: ' || v_imie || ' ' || v_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o nazwisku: ' || p_nazwisko);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: Zapytanie zwróciło więcej niż jeden wiersz (wielu kursantów o tym nazwisku).');
END;
/

Zadanie8
DECLARE
  CURSOR c_umowy IS
    SELECT u.umowa_id, kr.imie, kr.nazwisko, r.nazwa AS nazwa_kursu, r.cena
    FROM umowy u
    JOIN kursanci kr ON u.kursant_id = kr.kursant_id
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';

  v_rekord c_umowy%ROWTYPE;
BEGIN
  OPEN c_umowy;

  LOOP
    FETCH c_umowy INTO v_rekord;
    EXIT WHEN c_umowy%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('Umowa ' || v_rekord.umowa_id || ' | ' || 
                         v_rekord.imie || ' ' || v_rekord.nazwisko || ' | ' || 
                         v_rekord.nazwa_kursu || ' | ' || v_rekord.cena || ' zł');
  END LOOP;
  
  CLOSE c_umowy;
END;
/

#Zadanie9
CREATE OR REPLACE PROCEDURE raport_umow_szczecin
AS
BEGIN
  FOR r IN (
    SELECT u.umowa_id, kf.imie, kf.nazwisko, rf.nazwa AS nazwa_kursu, rf.cena, u.miasto
    FROM umowy u
    JOIN mv_kursanci_filia kf ON u.kursant_id = kf.kursant_id
    JOIN mv_kursy_filia k ON u.kurs_id = k.kurs_id
    JOIN mv_rodzaje_filia rf ON k.rodzaj_id = rf.rodzaj_id
    WHERE u.miasto = 'SZCZECIN'
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Umowa ' || r.umowa_id || ' | ' || 
                         r.imie || ' ' || r.nazwisko || ' | ' || 
                         r.nazwa_kursu || ' | ' || r.cena || ' zł | ' || r.miasto);
  END LOOP;
END;
/

#Zadanie10
CREATE OR REPLACE PROCEDURE raport_uczelni
AS
  v_byd_liczba_umow NUMBER;
  v_byd_laczna_wartosc NUMBER;
  v_byd_najdrozszy VARCHAR2(100);
  v_byd_najpopularniejszy VARCHAR2(100);

  v_szc_liczba_umow NUMBER;
  v_szc_laczna_wartosc NUMBER;
  v_szc_najdrozszy VARCHAR2(100);
  v_szc_najpopularniejszy VARCHAR2(100);
BEGIN
  SELECT COUNT(*), NVL(SUM(r.cena), 0)
  INTO v_byd_liczba_umow, v_byd_laczna_wartosc
  FROM umowy u JOIN kursy k ON u.kurs_id = k.kurs_id JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  SELECT r.nazwa INTO v_byd_najdrozszy FROM kursy k JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE r.cena = (SELECT MAX(cena) FROM rodzajeSiedziba);

  SELECT r.nazwa INTO v_byd_najpopularniejszy FROM umowy u JOIN kursy k ON u.kurs_id = k.kurs_id JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ' GROUP BY r.nazwa
  HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM umowy WHERE miasto = 'BYDGOSZCZ' GROUP BY kurs_id);

  SELECT COUNT(*), NVL(SUM(rf.cena), 0)
  INTO v_szc_liczba_umow, v_szc_laczna_wartosc
  FROM umowy u JOIN mv_kursy_filia kf ON u.kurs_id = kf.kurs_id JOIN mv_rodzaje_filia rf ON kf.rodzaj_id = rf.rodzaj_id
  WHERE u.miasto = 'SZCZECIN';

  SELECT rf.nazwa INTO v_szc_najdrozszy FROM mv_kursy_filia kf JOIN mv_rodzaje_filia rf ON kf.rodzaj_id = rf.rodzaj_id
  WHERE rf.cena = (SELECT MAX(cena) FROM mv_rodzaje_filia);

  SELECT rf.nazwa INTO v_szc_najpopularniejszy FROM umowy u JOIN mv_kursy_filia kf ON u.kurs_id = kf.kurs_id JOIN mv_rodzaje_filia rf ON kf.rodzaj_id = rf.rodzaj_id
  WHERE u.miasto = 'SZCZECIN' GROUP BY rf.nazwa
  HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM umowy WHERE miasto = 'SZCZECIN' GROUP BY kurs_id);

  DBMS_OUTPUT.PUT_LINE('RAPORT UCZELNI');
  DBMS_OUTPUT.PUT_LINE('===========================================');
  DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_byd_liczba_umow);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_byd_laczna_wartosc || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_byd_najdrozszy);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_byd_najpopularniejszy);
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_szc_liczba_umow);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_szc_laczna_wartosc || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_szc_najdrozszy);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_szc_najpopularniejszy);
  DBMS_OUTPUT.PUT_LINE('===========================================');
  DBMS_OUTPUT.PUT_LINE('PODSUMOWANIE');
  DBMS_OUTPUT.PUT_LINE('Liczba wszystkich umów: ' || (v_byd_liczba_umow + v_szc_liczba_umow));
  DBMS_OUTPUT.PUT_LINE('Łączna wartość wszystkich umów: ' || (v_byd_laczna_wartosc + v_szc_laczna_wartosc) || ' zł');
END;
/
