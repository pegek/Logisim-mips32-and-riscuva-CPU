# RISCuva1 — wersja minimalna

Prosty, w pełni działający procesor 8-bitowy zgodny z ISA **RISCuva1** (paper: S. de
Pablo i in., *"A very simple 8-bit RISC processor for FPGA"*, FPGAworld 2006), bez
instrukcji `call`, `ret`, `reti`, `di`, `ei`. Zbudowany w Logisim 2.7.x (klasyczny, **nie**
Evolution).

To była pierwsza, sprawdzona wersja procesora — dowód, że architektura RISCuva1 działa
end-to-end (sortuje bąbelkowo 4 liczby). Rozbudowana wersja z 16 rejestrami, pełnym
ALU (12 operacji), flagami Z+C, 4 skokami warunkowymi, adresami 10-bit i prawdziwym RAM
znajduje się w [`../riscuva1_full/`](../riscuva1_full/).

---

## Co jest w tym folderze

| Plik | Opis |
|---|---|
| `procesor_riscuva1.circ` | Działający procesor — otwórz w Logisim 2.7.x |
| `INSTRUKCJA_RISCuva1.md` | Ściąga: architektura, format instrukcji, lista rozkazów |
| `JAK_DZIALA_procesor.md` | Wyjaśnienie "łopatologiczne" — jak procesor wykonuje program krok po kroku |
| `diagram_blokowy.svg` | Prosty diagram blokowy architektury |

Specyfikacja ISA jest wspólna dla obu wersji RISCuva1 (paper: S. de Pablo i in., *"A very
simple 8-bit RISC processor for FPGA"*, FPGAworld 2006). Zdjęcie treści zadania:
[`../riscuva1_full/image0.jpg`](../riscuva1_full/image0.jpg).

---

## Skrót specyfikacji

- **Architektura Harvard** — osobna pamięć programu (ROM) i danych.
- **Pojedynczy cykl** — jedna instrukcja = jeden takt zegara.
- **Słowo instrukcji: 14-bitowe.** Dane i rejestry: 8-bitowe.
- **8 rejestrów** ogólnego przeznaczenia (r0–r7).
- Format: `[13:12]=opA [11:10]=opB [9:8]=opC [7:4]=rM [3:0]=rN`.
- Demonstracja: sortowanie bąbelkowe 4 liczb (program zaszyty w ROM).

Szczegóły w [`INSTRUKCJA_RISCuva1.md`](INSTRUKCJA_RISCuva1.md).

---

## Jak uruchomić

1. Otwórz `procesor_riscuva1.circ` w Logisim 2.7.x.
2. **Ctrl+R** (Reset Simulation).
3. **Ctrl+K** (włącz zegar) lub Ctrl+T wielokrotnie — program się wykonuje.
4. Obserwuj piny wyjściowe — po dojściu do halt komórki pamięci danych powinny
   pokazywać liczby posortowane rosnąco.
5. Zero czerwonych/niebieskich drutów = obwód działa poprawnie.
