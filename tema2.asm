%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
    use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0
    hintWord db "revient", 0
    message db "C'est un proverbe francais.", 0
    hintLength dd 7
    A db ".-", 0
    B db "-...", 0
    C db "-.-.", 0
    D db "-..", 0
    E db ".", 0
    F db "..-.", 0
    G db "--.", 0
    H db "....", 0
    I db "..", 0
    J db ".---", 0
    K db "-.-", 0
    L db ".-..", 0
    M db "--", 0
    N db "-.", 0
    O db "---", 0
    P db ".--.", 0
    Q db "--.-", 0
    R db ".-.", 0
    S db "...", 0
    T db "-", 0
    U db "..-", 0
    V db "...-", 0
    W db ".--", 0
    X db "-..-", 0
    Y db "-.--", 0
    Z db "--..", 0
    num_1 db ".----", 0
    num_2 db "..---", 0
    num_3 db "...--", 0
    num_4 db "....-", 0
    num_5 db "....", 0
    num_6 db "-....", 0
    num_7 db "--...", 0
    num_8 db "---..", 0
    num_9 db "----.", 0
    num_0 db "-----", 0
    comma db "--..--", 0


    

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main
main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, 2
    mov ebx, 3
   
    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    
    mov esi, [img]
    push esi
    call bruteforce_singlebyte_xor
    pop esi

    ; afisare mesaj separat pentru a putea refolosi functia la task-ul 2
    push ebx
    push edi
    call writeMessage
    pop edi
    pop ebx
    NEWLINE 

    jmp done
solve_task2:
    
    mov esi, [img]
    push esi
    call task2Method
    pop esi

    jmp done
solve_task3:
    ; TODO Task3

    mov esi, [img]
    mov eax, [ebp + 12]
    push DWORD[eax + 16]
    call atoi
    add esp, 4
    mov ebx, eax ; ebx = index
    xor edx, edx
    mov edx, [ebp + 12]
    mov edx, [edx + 12] ; edx = mesajul
    

    push ebx
    push edx
    push esi
    call morse_encrypt
    add esp, 12

    push dword[img_height]
    push dword[img_width]
    push esi
    call print_image
    sub esp, 12
    
    jmp done
solve_task4:

    jmp done
solve_task5:

    mov esi, [img]
    mov eax, [ebp + 12]
    push DWORD[eax + 12]
    call atoi
    add esp, 4
    mov ebx, eax ; ebx = index
    dec ebx
    
    push ebx
    push esi
    call lsb_decode
    add esp, 8


    jmp done
solve_task6: 
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret

; FUNCTII TASK1
; xorLine(int* matrix, int line, int cheie)
; face xor intre fiecare element de pe linia cu cheia primita ca parametru
xorLine:
    push ebp
    mov ebp, esp
    push ecx
    push ebx
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    
    mov edi, [ebp + 8] ; matricea de pixeli
    mov ebx, [ebp + 16] ; cheia
    
    mov edx, [img_width]
    imul edx, [ebp + 12] ; latime * linie

iterateLine:
    xor eax, eax
    mov eax, edx    ; latime * i + j ; j coloana
    imul eax, 4     ; (latime * i + j) * 4

    xor dword[edi + eax], ebx ; xor intre cheie si elementul din matrice

    add edx, 1      ; creste indicele de pe coloana
    inc ecx  
    cmp ecx, [img_width]
    jb iterateLine
    
    pop ebx
    pop ecx
    leave
    ret

bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    xor ecx, ecx
tryKeys:
    xor ebx, ebx
    xor edx, edx

iterateMatrix:
    mov edi, [ebp + 8] ;matricea

    push ecx ; cheie
    push ebx ; linia
    push edi ; matricea de pixeli
    ; xor pe linia data ca parametru
    call xorLine

    ; se cauta cuvantul pe linia modificata
    ; daca functia intoarce 1, mesajul a fost gasit
    call findSubstring
    cmp edx , 1
    je endBruteForce
    
    ;daca nu se gaseste cuvantul pe linie, se reface matricea
    call xorLine 
    pop edi
    pop ebx
    pop ecx

    inc ebx
    cmp ebx, [img_height]
    jb iterateMatrix
    
    inc ecx
    cmp ecx, 256 ; limita superioare a numerelor reprezentate pe un byte
    jb tryKeys

endBruteForce:
    pop edi
    pop ebx
    pop ecx

    leave
    ret
; findSubstring(int* matrix, int line)
; cauta mesajul stocat in .data pe linia data ca parametru
findSubstring:
    push ebp
    mov ebp, esp

    xor esi, esi
    xor edi, edi
    xor ebx, ebx
    xor ecx, ecx
    xor ebx, ebx
    
    mov edi, [ebp + 8]
    mov edx, [img_width]
    imul edx, [ebp + 12] ; latime * linie ; 
checkLine:
    xor eax, eax
    mov eax, edx    ; latime * i + j ; j coloana
    imul eax, 4     ; (latime * i + j) * 4

    push edx
    xor edx, edx
    mov dl, [hintWord + ebx]
    cmp edx, [edi + eax]
    je existsMatch
    jmp resetCounter

existsMatch:
    inc ebx
    jmp continueSearch

resetCounter:
    cmp ebx, [hintLength]
    je substringFound
    xor ebx, ebx

continueSearch:
    pop edx
    add edx, 1 
    inc ecx  
    cmp ecx, [img_width]
    jb checkLine
    jmp endFindSubstring

substringFound:
    xor edx, edx
    mov edx, 1

endFindSubstring:
    leave
    ret

; writeMessage(matrix, line)
; scrise mesajul de pe linia data ca parametru pana la terminator
writeMessage:
    push ebp
    mov ebp, esp
    mov edi, [ebp + 8]
    mov edx, [img_width]
    imul edx, [ebp + 12] 

printLine:
    xor eax, eax
    mov eax, edx
    imul eax, 4
    cmp dword[edi + eax], 0
    je endWriteMessage
    PRINT_CHAR [edi + eax]
    add edx, 1 
    cmp dword[edi + eax], 0
    jne printLine 
endWriteMessage:
    NEWLINE
    PRINT_DEC 4, ecx ;afiseaza cheia cu care s-a facut decriptarea
    NEWLINE
    PRINT_DEC 4, ebx ;afiseaza linia la care s-a gasit mesajul


    leave
    ret

; FUNCTII TASK2

; applyKeyOnMatrix(matrix, key)
; face intre cheia data ca parametru si fiecare element din matrice
applyKeyOnMatrix:
    push ebp
    mov ebp, esp
    xor ecx, ecx ; linia 
    xor edx, edx
    xor edi, edi
    mov edi, [ebp + 8]
    mov edx, [ebp + 12] ; cheia

; parcurgere matrice linie cu linie
traverseMatrix:    
    push edx
    push ecx
    push edi
    call xorLine
    pop edi
    pop ecx
    pop edx 
    
    inc ecx
    cmp ecx, [img_height]
    jb traverseMatrix

    leave
    ret
;introduceMessage(matrix, line)
;introduce mesajul salvata in .data pe linia primita ca parametru
introduceMessage:
    push ebp
    mov ebp, esp
    pusha
    xor ebx, ebx
    xor ecx, ecx
    xor ebx, ebx
    xor edi, edi
    
    mov ebx, [ebp + 12]
    inc ebx
    
    mov edi, [ebp + 8]
    mov edx, [img_width]
    imul edx, ebx ; latime * linie ; 

modifyLine:
    xor eax, eax
    mov eax, edx    ; latime * i + j ; j coloana
    imul eax, 4     ; (latime * i + j) * 4

    cmp byte[message + ecx], 0
    jne writeChar
    jmp endIntroduceMessage

writeChar:
    push edx
    xor edx, edx
    mov dl, [message + ecx]
    mov [edi + eax], edx
        
    pop edx
    add edx, 1
    inc ecx  
    cmp ecx, [img_width]
    jb modifyLine
endIntroduceMessage:
    mov dword[edi + eax], 0
    popa
    leave
    ret
; createNewKey(old_key)
; primeste cheia veche si o creeaza pe cea noua dupa formula ceruta
createNewKey:
    push ebp
    mov ebp, esp
    push ebx
    xor ebx, ebx
    xor eax, eax
    mov eax, [ebp + 8]
    imul eax, 2
    add eax, 3
    mov ebx, 5
    xor edx, edx
    idiv ebx
    sub eax, 4
    

    pop ebx
    leave
    ret

task2Method:
    push ebp
    mov ebp, esp

    xor esi, esi
    mov esi, [esp + 8]
    ; gaseste cheia si linia
    push esi
    call bruteforce_singlebyte_xor
    pop esi
    ; revenire la matricea originala
    push ecx
    push esi
    call applyKeyOnMatrix 
    pop esi
    pop ecx
    ; refacere linia cu mesajul
    push ecx
    push ebx
    push esi
    call xorLine 
    pop esi
    pop ebx
    pop ecx
    
    ; introduce mesajul in imaginea
    push ebx
    push esi
    call introduceMessage
    pop esi
    pop ebx
    ; creeaza noua cheie
    push ecx
    call createNewKey
    pop ecx
    ; aplica noua cheie pe matrice
    push eax
    push esi
    call applyKeyOnMatrix 
    pop esi
    pop eax
    ; afiseaza imaginea
    push dword[img_height]
    push dword[img_width]
    push esi
    call print_image
    sub esp, 12

    leave
    ret

;TASK3 METHODS
morse_encrypt:
    push ebp
    mov ebp, esp
    xor esi, esi
    xor edx, edx
    xor ecx, ecx
    xor eax, eax

    mov esi, [ebp + 8] ;imaginea
    mov edx, [ebp + 12] ;mesajul
    mov ebx, [ebp + 16] ;indice


; parcuge mesajul primit ca parametru
iterateMessage:
    push edx
    push ecx
    cmp byte[edx + ecx], 'A'
    je convertA
    cmp byte[edx + ecx], 'B'
    je convertB
    cmp byte[edx + ecx], 'C'
    je convertC
    cmp byte[edx + ecx], 'D'
    je convertD
    cmp byte[edx + ecx], 'E'
    je convertE
    cmp byte[edx + ecx], 'F'
    je convertF
    cmp byte[edx + ecx], 'G'
    je convertG
    cmp byte[edx + ecx], 'H'
    je convertH
    cmp byte[edx + ecx], 'I'
    je convertI
    cmp byte[edx + ecx], 'J'
    je convertJ
    cmp byte[edx + ecx], 'K'
    je convertK
    cmp byte[edx + ecx], 'L'
    je convertL
    cmp byte[edx + ecx], 'M'
    je convertM
    cmp byte[edx + ecx], 'N'
    je convertN
    cmp byte[edx + ecx], 'N'
    je convertN
    cmp byte[edx + ecx], 'O'
    je convertO
    cmp byte[edx + ecx], 'P'
    je convertP
    cmp byte[edx + ecx], 'Q'
    je convertQ
    cmp byte[edx + ecx], 'R'
    je convertR
    cmp byte[edx + ecx], 'S'
    je convertS
    cmp byte[edx + ecx], 'T'
    je convertT
    cmp byte[edx + ecx], 'U'
    je convertU
    cmp byte[edx + ecx], 'V'
    je convertV
    cmp byte[edx + ecx], 'W'
    je convertW
    cmp byte[edx + ecx], 'X'
    je convertX
    cmp byte[edx + ecx], 'Y'
    je convertY
    cmp byte[edx + ecx], 'Z'
    je convertZ
    cmp byte[edx + ecx], '0'
    je convertNum_0
    cmp byte[edx + ecx], '1'
    je convertNum_1
    cmp byte[edx + ecx], '2'
    je convertNum_2
    cmp byte[edx + ecx], '3'
    je convertNum_3
    cmp byte[edx + ecx], '4'
    je convertNum_4
    cmp byte[edx + ecx], '5'
    je convertNum_5
    cmp byte[edx + ecx], '6'
    je convertNum_6
    cmp byte[edx + ecx], '7'
    je convertNum_7
    cmp byte[edx + ecx], '8'
    je convertNum_8
    cmp byte[edx + ecx], '9'
    je convertNum_9
    cmp byte[edx + ecx], ','
    je convertComma

afterConvert:
    pop ecx
    pop edx
    inc ecx
    cmp byte[edx + ecx], 0
    jne iterateMessage
    jmp endMorseCode

convertA:
    push esi
    push A
    call convert
    add esp, 8
    jmp afterConvert
convertB:
    push esi
    push B
    call convert
    add esp, 8
    jmp afterConvert
convertC:
    push esi
    push C
    call convert
    add esp, 8
    jmp afterConvert
convertD:
    push esi
    push D
    call convert
    add esp, 8
    jmp afterConvert
convertE:
    push esi
    push E
    call convert
    add esp, 8
    jmp afterConvert    
convertF:
    push esi
    push F
    call convert
    add esp, 8
    jmp afterConvert
convertG:
    push esi
    push G
    call convert
    add esp, 8
    jmp afterConvert
convertH:
    push esi
    push H
    call convert
    add esp, 8
    jmp afterConvert
convertI:
    push esi
    push I
    call convert
    add esp, 8
    jmp afterConvert
convertJ:
    push esi
    push J
    call convert
    add esp, 8
    jmp afterConvert
convertK:
    push esi
    push K
    call convert
    add esp, 8
    jmp afterConvert
convertL:
    push esi
    push L
    call convert
    add esp, 8
    jmp afterConvert
convertM:
    push esi
    push M
    call convert
    add esp, 8
    jmp afterConvert
convertN:
    push esi
    push N
    call convert
    add esp, 8
    jmp afterConvert
convertO:
    push esi
    push O
    call convert
    add esp, 8
    jmp afterConvert
convertP:
    push esi
    push P
    call convert
    add esp, 8
    jmp afterConvert
convertQ:
    push esi
    push Q
    call convert
    add esp, 8
    jmp afterConvert
convertR:
    push esi
    push R
    call convert
    add esp, 8
    jmp afterConvert
convertS:
    push esi
    push S
    call convert
    add esp, 8
    jmp afterConvert
convertT:
    push esi
    push T
    call convert
    add esp, 8
    jmp afterConvert
convertU:
    push esi
    push U
    call convert
    add esp, 8
    jmp afterConvert
convertV:
    push esi
    push V
    call convert
    add esp, 8
    jmp afterConvert
convertW:
    push esi
    push W
    call convert
    add esp, 8
    jmp afterConvert
convertX:
    push esi
    push X
    call convert
    add esp, 8
    jmp afterConvert
convertY:
    push esi
    push Y
    call convert
    add esp, 8
    jmp afterConvert
convertZ:
    push esi
    push Z
    call convert
    add esp, 8
    jmp afterConvert
convertComma:
    push esi
    push comma
    call convert
    add esp, 8
    jmp afterConvert
; nefolosite in teste
convertNum_0:
    push esi
    push num_0
    call convert
    add esp, 8
    jmp afterConvert
convertNum_1:
    push esi
    push num_1
    call convert
    add esp, 8
    jmp afterConvert
convertNum_2:
    push esi
    push num_2
    call convert
    add esp, 8
    jmp afterConvert
convertNum_3:
    push esi
    push num_3
    call convert
    add esp, 8
    jmp afterConvert
convertNum_4:
    push esi
    push num_4
    call convert
    add esp, 8
    jmp afterConvert
convertNum_5:
    push esi
    push num_5
    call convert
    add esp, 8
    jmp afterConvert
convertNum_6:
    push esi
    push num_6
    call convert
    add esp, 8
    jmp afterConvert
convertNum_7:
    push esi
    push num_7
    call convert
    add esp, 8
    jmp afterConvert
convertNum_8:
    push esi
    push num_8
    call convert
    add esp, 8
    jmp afterConvert
convertNum_9:
    push esi
    push num_0
    call convert
    add esp, 9
    jmp afterConvert



endMorseCode:
    push ebx
    add ebx, eax
    imul ebx, 4
    mov byte[esi + ebx - 4], 0 ; terminator dupa mesaj
    pop ebx
    inc eax
    
    leave
    ret
; convert(matrix, caracter)
; introduce in matrice caracterele ascii corespunzatoare 
; codului morse al caracterului
convert:
    push ebp
    xor edi, edi
    mov ebp, esp
    xor ecx, ecx
    xor esi, esi
    xor edx, edx
    mov edx, [ebp + 8] ;  caracter
    mov esi, [ebp + 12] ; matrice

convertLoop:
    push ebx
    push eax
    add ebx, eax
    imul ebx, 4
    pop eax
    inc eax
    push eax
    xor eax, eax
    mov al, [edx + ecx]
    mov [esi + ebx], eax
    pop eax
    inc ecx
    cmp byte[edx + ecx], 0
    pop ebx
    jne convertLoop
    push ebx
    add ebx, eax
    imul ebx, 4
    mov byte[esi + ebx], 32 ; spatiu dupa caracter
    pop ebx
    inc eax
    
    leave
    ret


; checkBit(int number, int k)
; intoarce 0 daca al k-lea bit este 0
; diferit de 0 daca este setat
checkBit:
    push ebp 
    mov ebp, esp
    
    push ecx
    push edx

    xor eax, eax
    xor ecx, ecx

    mov eax, [ebp + 8] ;litera
    mov ecx, [ebp + 12] ;k-bit
    ; formula: n & (1 << k)
    xor edx, edx
    mov edx, 1
    shl edx , cl
    and eax, edx
    pop edx
    pop ecx
    
    leave
    ret

lsb_decode:
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8] ;imaginea
    mov ebx, [ebp + 12] ;indice 
    xor edi, edi
    xor ecx, ecx
    xor edx, edx
    mov ecx , 7 ; indexul celui mai semnificativ bit 
loop:
    ; calculeaza indexul pixelului
    push ebx
    add ebx, edi
    imul ebx, 4
    xor eax, eax
    ; verifica cel mai nesimnificativ bit din pixel
    push 0
    push dword[esi + ebx]
    call checkBit 
    add esp, 8
    cmp ecx, 0
    je sum          ; ex: 101 - > 201 -> 801 -> suma = numarul = 9
    imul eax, 2
    push ecx
    dec ecx
    shl eax, cl ; transforma numarul in 2 ^ indexul bitului
    pop ecx
sum:
    add edx, eax
    dec ecx
    cmp ecx, -1
    je anotherPixel
    jmp continueIteration
anotherPixel:
    cmp edx, 0
    je endLsbDecode
    PRINT_CHAR edx
    xor edx, edx
    mov ecx, 7

continueIteration:
    inc edi
    pop ebx
    jmp loop

endLsbDecode:
    leave
    ret