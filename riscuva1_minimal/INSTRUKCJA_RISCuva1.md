# Procesor RISCuva1 — instrukcja obsługi + ściąga

Plik procesora: `procesor_riscuva1.circ` (klasyczny Logisim 2.7.x — **nie** Evolution).

---

## 1. Co to jest

**8-bitowy procesor RISC** zgodny z ISA **RISCuva1** (paper: S. de Pablo i in.,
*„A very simple 8-bit RISC processor for FPGA"*, FPGAworld 2006), **bez instrukcji
`call`, `ret`, `reti`, `di`, `ei`** (zgodnie z treścią zadania).

- **Architektura: Harvard** — osobna pamięć programu (ROM) i pamięć danych.
- **Pojedynczy cykl** — każda instrukcja wykonuje się w jednym takcie zegara.
- **Słowo instrukcji: 14-bitowe.** Dane i rejestry: 8-bitowe.
- **Demonstracja:** sortowanie bąbelkowe 4 liczb.

---

## 2. Z czego się składa (bloki)

| Blok | Rola |
|---|---|
| **ROM** | Pamięć programu — 14-bitowe instrukcje. PC ją adresuje. |
| **Dekoder** | Rozkodowuje 14-bitową instrukcję na pola (opcode, rejestry, wartość) i sygnały sterujące. |
| **Plik rejestrów** | 8 rejestrów 8-bitowych (odczyt dwóch, zapis jednego). |
| **ALU** | Odejmowanie (do porównań) + przepisywanie (mov). Ustawia flagę **Carry** (C=1 gdy a<b). |
| **Pamięć danych** | Adresowana pamięć na sortowane liczby (odczyt/zapis). |
| **PC + skoki** | Licznik rozkazów: inkrement, `goto` (skok bezwarunkowy), `jpC` (skok gdy Carry). |

Przepływ (pojedynczy cykl): `PC → ROM → dekoder → rejestry → ALU → zapis wyniku`,
a na zboczu zegara `PC → PC+1` lub skok.

---

## 3. Jak uruchomić

1. Otwórz `procesor_riscuva1.circ` w Logisimie (klasyczny 2.7.x).
2. **Reset:** menu `Simulate → Reset Simulation` (**Ctrl+R**) — PC wraca do 0.
3. **Uruchom:** `Simulate → Ticks Enabled` (**Ctrl+K**) — procesor sam się taktuje.
   (Albo krokuj po jednym takcie: **Ctrl+T**.)
4. Poczekaj, aż **PC zatrzyma się na `78`** (to instrukcja `halt` = goto-do-siebie; program się skończył).
5. **Odczytaj wynik:** piny **`WYNIK0`–`WYNIK3`** (prawy-górny róg) = posortowane liczby
   (komórki pamięci danych 0–3, rosnąco).

> Uwaga: po dojściu do `halt` piny `busN`/`dataBus` mogą pokazać „overflow" — to
> nieszkodliwy artefakt instrukcji halt (odwołuje się do nieistniejącego rejestru).
> Wynik na `WYNIK0–3` jest poprawny.

---

## 4. ŚCIĄGA: jak zmienić sortowane liczby

Liczby są wpisywane przez program (init) i siedzą w **4 słowach ROM-u**.

1. **Podwójny klik na ROM** → otwiera się edytor zawartości (hex).
2. Zmień 4 słowa pod adresami **0, 3, 6, 9**:

| Adres w ROM | Komórka | Słowo (przykład dla `7,3,9,1`) |
|---|---|---|
| `0` | 0 | `2074` (=7) |
| `3` | 1 | `2034` (=3) |
| `6` | 2 | `2094` (=9) |
| `9` | 3 | `2014` (=1) |

### Wzór słowa: **`2` + [liczba w hex, 2 cyfry] + `4`**

| Liczba | Hex | Słowo |
|---|---|---|
| 1 | 01 | `2014` |
| 5 | 05 | `2054` |
| 9 | 09 | `2094` |
| 15 | 0f | `20f4` |
| 30 | 1e | `21e4` |
| 42 | 2a | `22a4` |
| 99 | 63 | `2634` |
| 200 | c8 | `2c84` |
| 255 (max) | ff | `2ff4` |

**Zakres: 0–255** (8-bit). Reszta programu (logika sortowania) zostaje bez zmian.

Po zmianie: **Ctrl+R** (reset) → **Ctrl+K** (uruchom) → odczytaj `WYNIK0–3`.

> Przykład: żeby posortować **99, 15, 30, 7** → wpisz w adresy `0,3,6,9`:
> `2634, 20f4, 21e4, 2074`. Wynik: `7, 15, 30, 99`.

---

## 5. ŚCIĄGA: kodowanie instrukcji (14-bit)

Format: `[13:12]=opA  [11:10]=opB  [9:8]=opC  [7:4]=rM  [3:0]=rN`

| Instrukcja | Znaczenie | Kod (hex, wzór) |
|---|---|---|
| `mov rN,#k` | rN = liczba k | `2` k(2hex) `n` |
| `mov rN,rM` | rN = rM | `30` m n |
| `sub rN,rM` | rN = rN − rM, ustaw Carry | `36` m n |
| `mov rN,(rM)` | rN = pamięć[rM] (odczyt) | `3c` m n |
| `mov (rM),rN` | pamięć[rM] = rN (zapis) | `0c` m n |
| `goto adr` | skok bezwarunkowy | `04` adr(2hex) |
| `jpC adr` | skok gdy Carry=1 | `18` adr(2hex) |

**Konwencja rejestrów w programie sortowania:**
`r3` = adres komórki, `r4` = pierwsza wartość, `r5` = druga wartość, `r2` = rejestr roboczy (porównanie).

**Idea sortowania:** compare-swap dwóch komórek = wczytaj obie, `sub` (ustawia Carry gdy a<b),
`jpC` pomiń zamianę jeśli już uporządkowane, inaczej zapisz w zamienionej kolejności.
Dla 4 liczb wykonuje się 6 takich compare-swapów (rozwinięty bubble sort).

---

Aby posortować inne liczby, edytuj bezpośrednio ROM w Logisim (podwójny klik na
komponent ROM) wg kodowania instrukcji ze ściągi w sekcji 4, albo zmień wartości
`mov_imm` inicjalizujące pamięć danych na początku programu.
