; ===== Sortowanie babelkowe 4 liczb — procesor RISCuva1 =====
; Rejestry: r3=adres komorki, r4/r5=wartosci, r2=scratch (porownanie)

; --- Bez inicjalizacji: liczby wpisz recznie do RAM (komorki 0-3) ---
; --- w symulacji przed uruchomieniem (podwojny klik na RAM) ---

; --- Przebieg 1: compare-swap (0,1), (1,2), (2,3) ---
        mov  r3,#0
        mov  r4,(r3)    ; a = pamiec[0]
        mov  r3,#1
        mov  r5,(r3)    ; b = pamiec[1]
        mov  r2,r4      ; scratch = a
        sub  r2,r5      ; a-b ; Carry=1 gdy a<b
        jpC  noswap0 ; a<b -> juz uporzadkowane, pomin zamiane
        mov  r3,#0
        mov  (r3),r5    ; pamiec[0] = b (mniejsze)
        mov  r3,#1
        mov  (r3),r4    ; pamiec[1] = a (wieksze)
noswap0:
        mov  r3,#1
        mov  r4,(r3)    ; a = pamiec[1]
        mov  r3,#2
        mov  r5,(r3)    ; b = pamiec[2]
        mov  r2,r4      ; scratch = a
        sub  r2,r5      ; a-b ; Carry=1 gdy a<b
        jpC  noswap1 ; a<b -> juz uporzadkowane, pomin zamiane
        mov  r3,#1
        mov  (r3),r5    ; pamiec[1] = b (mniejsze)
        mov  r3,#2
        mov  (r3),r4    ; pamiec[2] = a (wieksze)
noswap1:
        mov  r3,#2
        mov  r4,(r3)    ; a = pamiec[2]
        mov  r3,#3
        mov  r5,(r3)    ; b = pamiec[3]
        mov  r2,r4      ; scratch = a
        sub  r2,r5      ; a-b ; Carry=1 gdy a<b
        jpC  noswap2 ; a<b -> juz uporzadkowane, pomin zamiane
        mov  r3,#2
        mov  (r3),r5    ; pamiec[2] = b (mniejsze)
        mov  r3,#3
        mov  (r3),r4    ; pamiec[3] = a (wieksze)
noswap2:

; --- Przebieg 2: compare-swap (0,1), (1,2) ---
        mov  r3,#0
        mov  r4,(r3)    ; a = pamiec[0]
        mov  r3,#1
        mov  r5,(r3)    ; b = pamiec[1]
        mov  r2,r4      ; scratch = a
        sub  r2,r5      ; a-b ; Carry=1 gdy a<b
        jpC  noswap3 ; a<b -> juz uporzadkowane, pomin zamiane
        mov  r3,#0
        mov  (r3),r5    ; pamiec[0] = b (mniejsze)
        mov  r3,#1
        mov  (r3),r4    ; pamiec[1] = a (wieksze)
noswap3:
        mov  r3,#1
        mov  r4,(r3)    ; a = pamiec[1]
        mov  r3,#2
        mov  r5,(r3)    ; b = pamiec[2]
        mov  r2,r4      ; scratch = a
        sub  r2,r5      ; a-b ; Carry=1 gdy a<b
        jpC  noswap4 ; a<b -> juz uporzadkowane, pomin zamiane
        mov  r3,#1
        mov  (r3),r5    ; pamiec[1] = b (mniejsze)
        mov  r3,#2
        mov  (r3),r4    ; pamiec[2] = a (wieksze)
noswap4:

; --- Przebieg 3: compare-swap (0,1) ---
        mov  r3,#0
        mov  r4,(r3)    ; a = pamiec[0]
        mov  r3,#1
        mov  r5,(r3)    ; b = pamiec[1]
        mov  r2,r4      ; scratch = a
        sub  r2,r5      ; a-b ; Carry=1 gdy a<b
        jpC  noswap5 ; a<b -> juz uporzadkowane, pomin zamiane
        mov  r3,#0
        mov  (r3),r5    ; pamiec[0] = b (mniejsze)
        mov  r3,#1
        mov  (r3),r4    ; pamiec[1] = a (wieksze)
noswap5:

; --- Koniec: zatrzymanie procesora ---
halt:
        goto halt       ; stop (skok do samego siebie)
