# RISCuva1 — pełny rdzeń obliczeniowy

Rozbudowana wersja procesora RISCuva1. ISA wg: S. de Pablo i in., *"A very simple 8-bit
RISC processor for FPGA"*, FPGAworld Conference, 2006 — patrz też zdjęcie treści zadania
[`image0.jpg`](image0.jpg). Zbudowana na bazie działającej wersji minimalnej
([`../riscuva1_minimal/`](../riscuva1_minimal/)), rozszerzona do pełnoprawnych rozmiarów.

Podstawy architektury (Harvard, jednocyklowość, format instrukcji, ściąga) są
udokumentowane w [`../riscuva1_minimal/INSTRUKCJA_RISCuva1.md`](../riscuva1_minimal/INSTRUKCJA_RISCuva1.md)
— tutaj opisane są tylko różnice i rozszerzenia.

---

## Co zostało rozbudowane względem wersji minimalnej

| Element | Minimalna | Pełna |
|---|---|---|
| Rejestry | 8 | **16** (drzewo 2× blok 8-rejestrowy + MUX wyboru górnym bitem adresu) |
| Operacje ALU | 4 (LOGIC) | **12**: mov/xnor/or/and (LOGIC), add/adc/sub/sbc (ARITH), asr/rrc/ror/rol (SHIFT) |
| Flagi | C | **Z + C** |
| Skoki warunkowe | 1 (JR z flagą C) | **4**: jpZ / jpNZ / jpC / jpNC |
| Adresowanie | 8-bit (256 słów) | **10-bit** (1024 słowa) |
| Pamięć danych | rejestry-jako-RAM | **prawdziwy komponent RAM** (bus=separate, adresowany, z zegarem) |

---

## Co jest w tym folderze

| Plik/folder | Opis |
|---|---|
| `procesor_riscuva1_full.circ` | **Gotowy procesor** — otwórz w Logisim 2.7.x |
| `programs/sortowanie_riscuva1.hex` | Program sortowania w formacie hex (ładowany do ROM) |
| `sortowanie_RISCuva1.asm` | Kod źródłowy z mnemonikami **i komentarzami** |
| `sortowanie_RISCuva1.txt` | Kod źródłowy z mnemonikami **bez komentarzy** (do oddania) |
| `sortowanie_RISCuva1_listing.txt` | Listing `adres \| hex \| mnemonik` |
| `image0.jpg` | Zdjęcie treści zadania |

---

## Jak uruchomić (z ręcznym wpisywaniem liczb)

Program w ROM **nie inicjalizuje** pamięci — liczby do posortowania wpisujesz sam:

1. **Ctrl+R** (Reset Simulation) — zeruje PC **i RAM**.
2. Podwójnie kliknij komponent **RAM** → wpisz 4 liczby do komórek 0–3 (np. `5 2 8 1`).
3. **Ctrl+K** (włącz zegar) lub Ctrl+T wielokrotnie — procesor sortuje.
4. Wynik: komórki RAM 0–3 = liczby posortowane rosnąco. Piny `M_R1..M_R4` (lustro
   rejestrowe) pokazują to samo.
5. Zero czerwonych/niebieskich drutów, zero „Incompatible widths".

**Uwaga kolejności:** reset zeruje RAM, więc wpisuj liczby *po* Ctrl+R, nie przed.
