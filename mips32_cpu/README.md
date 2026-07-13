# Procesor 32-bitowy w Logisimie

Projekt procesora 32-bitowego w stylu MIPS, zrealizowany w programie Logisim 2.7.1.

---

## Architektura procesora

### Ogolna budowa

Procesor jest klasyczna **jednoscyklowa** maszyna 32-bitowa - kazda instrukcja wykonuje sie w jednym cyklu zegara. Sklada sie z pieciu glownych blokow:

```
[ROM instrukcji] -> [Jednostka sterujaca] -> [Rejestry] -> [ALU] -> [RAM danych]
                           |                                           |
                       [PC + logika skokow] <------------------------/
```

### Bloki funkcjonalne

**Licznik rozkazow (PC)**
- 32-bitowy rejestr adresu instrukcji
- Normalnie PC <- PC + 1 (procesor jest **word-addressed**: kazda instrukcja to jedno slowo 32-bitowe)
- Przy skoku bezwarunkowym (J): PC <- JUMP_TGT = {6'b000000, INSTR[25:0]}
- Przy skoku warunkowym (branch): PC <- PC + 1 + offset (signed)
- Przy JR: PC <- wartosc rejestru RS

**ROM instrukcji**
- Przechowuje program jako slowa 32-bitowe (format .hex)
- Adresowany przez PC

**Jednostka sterujaca (CU)**
- Dekoduje pole Opcode (bity [31:26]) i Funct (bity [5:0]) instrukcji
- Generuje 10-bitowe slowo sterujace: `RegDst | ALUSrc | MemtoReg | RegWrite | MemRead | MemWrite | Branch | Jump | ALUClass1 | ALUClass0`
- Generuje kod operacji dla ALU (ALUOp, 4-bity)
- Wewnetrznie uzywa ROM-ow i MUX-ow do dekodowania

**Plik rejestrow**
- Przechowuje wartosci rejestrow ogolnego przeznaczenia R0-R31
- Dwa porty odczytu (RS, RT) i jeden port zapisu (RD)
- R0 = zawsze 0 (hardcoded)
- Zapis synchroniczny (na zbocze zegara), odczyt kombinacyjny

**ALU (jednostka arytmetyczno-logiczna)**
- Wykonuje 11 operacji (kod 0-10):

| ALUOp | Operacja | Opis |
|-------|----------|------|
| 0     | ADD      | Dodawanie |
| 1     | SUB      | Odejmowanie |
| 2     | MUL      | Mnozenie (dolne 32 bity) |
| 3     | DIV      | Dzielenie (iloraz) |
| 4     | AND      | Koniunkcja bitowa |
| 5     | OR       | Alternatywa bitowa |
| 6     | XOR      | Alternatywa wykluczajaca |
| 7     | SLT      | Set Less Than (1 jesli A < B) |
| 8     | SLL      | Przesuniecie logiczne w lewo |
| 9     | SRL      | Przesuniecie logiczne w prawo |
| 10    | SRA      | Przesuniecie arytmetyczne w prawo |

- Dwa wejscia 32-bitowe (A = RS, B = RT lub immediate)
- Wejscie shamt 5-bitowe (dla przestawien)
- Flaga Zero (1 gdy wynik = 0)

**RAM danych**
- Przechowuje dane programu (tablice, zmienne)
- Dostep przez instrukcje LW (load) i SW (store)
- Adresowanie bajtowe

**Logika skokow warunkowych**
- Sygnal BRANCH z CU + flagi ALU -> PC_SEL1
- BEQ/BNE: uzywaja flagi Zero (wynik SUB = 0)
- BLT/BGT: uzywaja flagi Negative (wynik SUB < 0)
- Bit BRANCHINV odwraca warunek (BNE odwraca BEQ, BGT odwraca BLT)

---

## Format instrukcji

### Typ R (operacje na rejestrach)
```
[31:26] Opcode=000000 | [25:21] RS | [20:16] RT | [15:11] RD | [10:6] shamt | [5:0] Funct
```

### Typ I (z wartoscia natychmiastowa)
```
[31:26] Opcode | [25:21] RS | [20:16] RT | [15:0] Immediate (signed)
```

### Typ J (skok)
```
[31:26] Opcode | [25:0] Adres docelowy
```

---

## Lista instrukcji ISA

| Instrukcja     | Format | Opcode/Funct | Dzialanie |
|----------------|--------|--------------|-----------|
| ADD rd,rs,rt   | R | funct=0x20 | rd = rs + rt |
| SUB rd,rs,rt   | R | funct=0x22 | rd = rs - rt |
| MUL rd,rs,rt   | R | funct=0x18 | rd = rs * rt |
| DIV rd,rs,rt   | R | funct=0x1A | rd = rs / rt |
| AND rd,rs,rt   | R | funct=0x24 | rd = rs AND rt |
| OR  rd,rs,rt   | R | funct=0x25 | rd = rs OR rt |
| XOR rd,rs,rt   | R | funct=0x26 | rd = rs XOR rt |
| SLT rd,rs,rt   | R | funct=0x2A | rd = (rs < rt) ? 1 : 0 |
| SLL rd,rt,s    | R | funct=0x00 | rd = rt << s |
| SRL rd,rt,s    | R | funct=0x02 | rd = rt >> s (logiczny) |
| SRA rd,rt,s    | R | funct=0x03 | rd = rt >> s (arytmetyczny) |
| ADDI rt,rs,imm | I | opcode=0x08 | rt = rs + imm |
| ANDI rt,rs,imm | I | opcode=0x0C | rt = rs AND imm |
| ORI  rt,rs,imm | I | opcode=0x0D | rt = rs OR imm |
| XORI rt,rs,imm | I | opcode=0x0E | rt = rs XOR imm |
| SLTI rt,rs,imm | I | opcode=0x0A | rt = (rs < imm) ? 1 : 0 |
| LW rt,imm(rs)  | I | opcode=0x23 | rt = MEM[rs + imm] |
| SW rt,imm(rs)  | I | opcode=0x2B | MEM[rs + imm] = rt |
| BEQ rs,rt,off  | I | opcode=0x04 | jesli rs==rt: PC += off |
| BNE rs,rt,off  | I | opcode=0x05 | jesli rs!=rt: PC += off |
| BLT rs,rt,off  | I | opcode=0x06 | jesli rs<rt:  PC += off |
| BGT rs,rt,off  | I | opcode=0x07 | jesli rs>rt:  PC += off |
| J target       | J | opcode=0x02 | PC = target |
| JR rs          | R | funct=0x08 | PC = rs |

> **Uwaga:** offset w branch-ach jest **word-count** (nie bajtowy jak w klasycznym MIPS).
> Offset=+2 oznacza przeskok o 2 instrukcje do przodu.

---

## Programy testowe

Wszystkie pliki hex znajduja sie w `programs/`.

---

### `test_rtype.hex` - Test operacji R-type

**Co robi:** Testuje podstawowe operacje arytmetyczne i logiczne na rejestrach.

```
R8  = 10
R9  = 3
R10 = R8 - R9    -> R10 = 7   (SUB)
R11 = R8 AND R9  -> R11 = 2   (AND: 1010 AND 0011 = 0010)
R12 = R8 OR  R9  -> R12 = 11  (OR:  1010 OR  0011 = 1011)
R13 = R8 XOR R9  -> R13 = 9   (XOR: 1010 XOR 0011 = 1001)
R14 = SLT(R8,R9) -> R14 = 0   (10 > 3, wiec wynik = 0)
```

**Oczekiwane rejestry:** R8=10, R9=3, R10=7, R11=2, R12=11, R13=9, R14=0

---

### `test_muldiv.hex` - Test mnozenia i dzielenia

**Co robi:** Testuje instrukcje MUL i DIV.

```
R8  = 7
R9  = 6
R10 = R8 * R9  -> R10 = 42  (MUL)
R11 = R8 / R9  -> R11 = 1   (DIV, iloraz calkowity)
```

**Oczekiwane rejestry:** R10=42, R11=1

---

### `test_shift.hex` - Test przesuniecia bitowego

**Co robi:** Testuje SLL, SRL i SRA z roznym shamt.

```
R8  = 8         (= 0b00001000)
R9  = R8 SLL 1  -> R9  = 16   (= 0b00010000)
R10 = R8 SRL 1  -> R10 = 4    (= 0b00000100)
R11 = R8 SRA 1  -> R11 = 4    (liczba dodatnia, j.w.)
R12 = -8        (= 0xFFFFFFF8)
R13 = R12 SRA 1 -> R13 = -4   (zachowanie znaku)
```

**Oczekiwane rejestry:** R9=16, R10=4, R11=4, R13=-4

---

### `test_lwsw.hex` - Test ladowania i zapisu do RAM

**Co robi:** Zapisuje wartosc do pamieci i odczytuje ja z powrotem.

```
R8 = 0           (adres bazowy)
R9 = 42          (wartosc do zapisania)
SW R9, 0(R8)  -> MEM[0] = 42
LW R10, 0(R8) -> R10 = MEM[0] = 42
```

**Oczekiwane:** R10=42, RAM[adres 0]=42

---

### `test_beq.hex` - Test skoku warunkowego BEQ

**Co robi:** Sprawdza czy BEQ (Branch if Equal) dziala poprawnie.

```
R8 = 5, R9 = 5
BEQ R8, R9, +2   -> galaz wzieta (R8 == R9)
[pominiete] R10 = 99
[pominiete] R11 = 88
R12 = 7           <- wykonane po skoku
```

**Oczekiwane:** R12=7, R10=0, R11=0

---

### `test_bne.hex` - Test skoku warunkowego BNE

**Co robi:** Sprawdza czy BNE (Branch if Not Equal) dziala poprawnie.

```
R8 = 5, R9 = 7
BNE R8, R9, +2   -> galaz wzieta (R8 != R9)
[pominiete] R10 = 99
[pominiete] R11 = 88
R12 = 1           <- wykonane po skoku
```

**Oczekiwane:** R12=1, R10=0, R11=0

---

### `test_blt.hex` - Test skoku warunkowego BLT

**Co robi:** Sprawdza czy BLT (Branch if Less Than) dziala poprawnie.

```
R8 = 3, R9 = 5
BLT R8, R9, +2   -> galaz wzieta (3 < 5)
[pominiete] R10 = 99
[pominiete] R11 = 88
R12 = 7           <- wykonane po skoku
```

**Oczekiwane:** R12=7, R10=0, R11=0

---

### `test_j.hex` - Test skoku bezwarunkowego J

**Co robi:** Sprawdza czy J (Jump) przeskakuje do wlasciwego adresu.

```
R8 = 1
J 4              -> PC = 4
[pominiete] R9 = 88   (adres 2)
[pominiete] R10 = 77  (adres 3)
R11 = 5          <- adres 4, wykonane
```

**Oczekiwane:** R8=1, R9=0, R10=0, R11=5

---

### `test_jr.hex` - Test skoku przez rejestr JR

**Co robi:** Sprawdza czy JR (Jump Register) skacze pod adres z rejestru.

```
R8 = 3           (adres docelowy)
JR R8            -> PC = 3
[pominiete] R9 = 99  (adres 2)
R10 = 5          <- adres 3, wykonane
```

**Oczekiwane:** R8=3, R9=0, R10=5

---

### `bubble_sort.hex` - Bubble Sort (wersja z SLT+BEQ/BNE)

**Co robi:** Sortuje tablice 5 elementow 32-bitowych w RAM rosnaco algorytmem bubble sort.

Uzywa instrukcji SLT i BEQ/BNE do porownania elementow. Wymaga dzialajacego BNE.

**Rejestry:**
- R8  = wskaznik bajtowy do biezacego elementu (0, 4, 8, ...)
- R9  = liczba pozostalych przebiegow zewnetrznej petli (start: 4)
- R10 = licznik wewnetrzny
- R11, R12 = para sasiadujacych elementow do porownania

**Dane wejsciowe:** zaladuj `ram_data.hex` do RAM przed uruchomieniem.
**Koniec:** PC zatrzymuje sie na ostatniej instrukcji (J do siebie).

---

### `bubble_sort_blt_bgt.hex` - Bubble Sort (wersja z BLT)

**Co robi:** Identyczny algorytm bubble sort, ale uzywa BLT zamiast SLT+BEQ/BNE.
Prostsza i bardziej czytelna wersja.

```
Petla zewnetrzna (R9 = liczba przebiegow, start 4):
  Petla wewnetrzna (R10 = licznik, R8 = wskaznik bajtowy):
    LW R11 = A[j]
    LW R12 = A[j+1]
    BLT R11, R12, +2  -> jesli A[j] < A[j+1]: pomin zamiane
    SW: zamien A[j] i A[j+1]
    R8 += 4, R10 += 1
    BLT R10, R9, -8   -> wróc do poczatku petli wewnetrznej
  Reset wskaznika, R9 -= 1, reset licznika
  BLT R0, R9, -12    -> wróc do petli zewnetrznej jesli R9 > 0
J 15  -> koniec (samopetle)
```

**Oczekiwany wynik:** RAM posortowany rosnaco, PC=15 po zakonczeniu.

---

## Pliki projektu

```
mips32_cpu/
├── procesor.circ                              <- glowny plik integracyjny
├── alu_stage17_builtin_mux_core6_zero.circ   <- ALU (11 operacji)
├── jednostka_sterujaca.circ                  <- jednostka sterujaca (CU)
├── rejestry.circ                             <- plik rejestrow
├── zadanie.txt                                <- tresc zadania (wymagania)
└── programs/                                  <- programy testowe (.hex), opisane wyzej
```
