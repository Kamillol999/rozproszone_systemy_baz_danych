#Zadanie1
DECLARE
  kci_liczba NUMBER;
  ksy_liczba NUMBER;
  w_liczba NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO kci_liczba
  FROM kursanci;
  SELECT COUNT(*)
  INTO ksy_liczba
  FROM kursy;
  SELECT COUNT(*)
  INTO w_liczba
  FROM wykladowcy;

  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || kci_liczba, 'Liczba kursów: ' || ksy_liczba, 'Liczba wykładowców: ' || w_liczba);
END;
/

#Zadanie2
SELECT 

#Zadanie3
DECLARE
  v_liczba_umow NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_liczba_umow
  FROM umowy;

  DECLARE
  v_liczba NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_liczba
  FROM kursanci;

  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || v_liczba);
END;
/

#Zadanie4
