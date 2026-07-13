# Jak działa procesor RISCuva1 — proste wyjaśnienie

## W jednym zdaniu
To mały komputer, który **wykonuje program krok po kroku**: czyta instrukcje z pamięci,
robi to co każą (przepisz liczbę, odejmij, zapisz, skocz) i tak w kółko, aż dojdzie do końca.

## Analogia (najprościej)
Wyobraź sobie **robota, który czyta przepis linijka po linijce** i wykonuje polecenia. Ma:
- **kartkę z przepisem** = pamięć programu (ROM),
- **palec pokazujący którą linijkę teraz czyta** = licznik rozkazów (PC),
- **kilka szufladek na liczby** = rejestry,
- **kalkulator** = ALU,
- **notes na wyniki** = pamięć danych.

Robot: patrzy palcem na linijkę → czyta polecenie → wykonuje → przesuwa palec dalej. I znowu.

## Diagram blokowy

```
       +------------------ PC przesuwa sie dalej <-------------------+
       |                                                            |
       v                                                            |
  +---------+  adres  +-----------+ instrukcja +-------------+       |
  |   PC    |-------->|    ROM    |----------->|   DEKODER   |       |
  | licznik |         |  pamiec   | (14 bitow) |  tlumaczy   |       |
  | rozkazow|         |  programu |            |  instrukcje |       |
  +---------+         +-----------+            +------+------+       |
                                                      | mowi co robic|
                                          +-----------+-----------+  |
                                          v                       v  |
                                   +-------------+         +-----------+
                                   |  REJESTRY   |<- dane ->|    ALU    |
                                   | 8 szufladek |         | kalkulator |
                                   | na liczby   |         | (odejmij,  |
                                   +------+------+         |  przepisz) |
                                          |                +-----------+
                                   zapis/ | odczyt
                                          v
                                  +----------------------------+
                                  |       PAMIEC DANYCH        |
                                  | tu leza i sortuja sie      |
                                  | liczby (komorki 0,1,2,3)   |
                                  +----------------------------+
```

(Ładniejsza wersja: `diagram_blokowy.svg`)

## Co robi każdy klocek (łopatologicznie)

1. **PC — licznik rozkazów.** To „palec", który pokazuje którą instrukcję teraz wykonujemy.
   Po każdej instrukcji przesuwa się na następną. Gdy jest skok — przeskakuje gdzie indziej.

2. **ROM — pamięć programu.** Kartka z całym programem. PC mówi „daj instrukcję numer N",
   a ROM ją podaje. Instrukcja to 14 zer i jedynek.

3. **DEKODER — tłumacz.** Bierze te 14 bitów i mówi reszcie co robić:
   „to jest odejmowanie", „użyj rejestru 2 i 5", „to jest skok" itd.

4. **REJESTRY — 8 szufladek na liczby** (każda mieści liczbę 0–255).
   Procesor czyta z nich dwie liczby naraz i może zapisać wynik do jednej.

5. **ALU — kalkulator.** Tu dzieje się liczenie: **odejmowanie** (do porównywania liczb)
   i **przepisywanie** (kopiowanie liczby). Gdy pierwsza liczba jest mniejsza od drugiej,
   ALU podnosi **flagę Carry** — to sygnał „mniejsza!", którego używa sortowanie.

6. **PAMIĘĆ DANYCH — notes na sortowane liczby.** Adresowana: komórka 0, 1, 2, 3...
   Program zapisuje tu liczby i je odczytuje w trakcie sortowania.

## Jak wykonuje JEDNĄ instrukcję (przykład: `sub r2,r5`)

1. **PC** pokazuje adres → **ROM** podaje instrukcję (14 bitów).
2. **DEKODER** czyta ją: „to odejmowanie, rejestry 2 i 5".
3. **REJESTRY** podają wartości z szufladek 2 i 5.
4. **ALU** odejmuje (r2 − r5), podnosi flagę Carry jeśli r2 < r5, a wynik wraca do szufladki 2.
5. **Zegar tyka** → **PC** przesuwa się na następną instrukcję.

Wszystko dzieje się w **jednym takcie zegara** (to znaczy „pojedynczy cykl").

## Jak sortuje (bąbelkowo)

Sortowanie to porównywanie **par sąsiednich liczb** i zamiana miejscami, gdy są w złej kolejności:

1. Wczytaj dwie sąsiednie liczby z pamięci (`a` i `b`).
2. `sub` — odejmij. Flaga Carry mówi, czy `a < b`.
3. `jpC` — jeśli `a < b` (już dobrze), **pomiń zamianę**. Inaczej zapisz je w zamienionej kolejności.
4. Powtórz dla kolejnych par.

Po kilku takich przejściach największe liczby „przebąblowują" na koniec — i tablica jest posortowana.
Dla 4 liczb wystarcza 6 takich porównań-zamian.

## Najważniejsze cechy (gdyby ktoś pytał)

- **Architektura Harvard** — osobna pamięć programu (ROM) i danych. Nie mieszają się.
- **RISC** — mało, prostych instrukcji (przepisz, odejmij, skok, zapis/odczyt pamięci).
- **8-bitowy** — liczby i rejestry mają po 8 bitów (zakres 0–255).
- **Pojedynczy cykl** — każda instrukcja = jeden takt zegara.
- **ISA RISCuva1** — zgodny z paperem (de Pablo i in., 2006), bez instrukcji
  `call`, `ret`, `reti`, `di`, `ei` (tak jak wymagało zadanie).
