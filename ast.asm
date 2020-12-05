
section .data
    delim db " ", 0

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern calloc
extern strlen

global create_tree
global iocla_atoi

iocla_atoi: 		
    enter 0, 0

    mov esi, dword [esp + 8] 		; stringul de convertit

    push esi
    call strlen 					; apelare strlen

    pop esi							; refacere stiva

 	mov	ecx, eax					; in ecx se gaseste acum lungimea sirului
 	mov eax, 1 						; in eax se vor forma multiplii de 10
 	xor edx, edx 					; in edx se va forma numarul intreg

    positive: 						
    	push eax 			; back up multiplu de 10 (va fi inmultit cu cifra)
    	push edx			; back up nr intreg (se va modifica la inmultire)
		
		xor ebx, ebx
		mov bl, byte [esi + ecx * 1 - 1]	; se extrage o cifra in cod ascii

    	sub ebx, 48 			; cifra se converteste la valoarea ei normala
    	mul ebx 				; se inmulteste cifra cu multiplul de 10


    	pop edx 				; se readuce numarul pentru a aduna noua val
    	add edx, eax 			; se aduna noua valoare

    	pop eax 				; se readuce multiplul de 10 curent

    	push edx
    	mov edi, 10 
    	mul edi    				; se trece la multiplul urmator, inmultindu-se
    	pop edx 				; cu 10, avand grija sa nu se strice edx

    	dec ecx 				; se trece la urmatorul byte din string

    	cmp ecx, 1 				; se cicleaza pana la indexul 1
    	jg positive

    	cmp ecx, 1 				; cand indexul din string e 1, se verifica daca
    	je verify_if_negative 	; numarul de convertit e pozitiv sau negativ

    	jmp done


    	verify_if_negative:
    		cmp byte [esi], '-' 	; se face verificare prin compararea
    		je negative 			; byte-ului cu '-'
    		jmp positive 			; daca e pozitiv, mai exista o cifra in 
    								; string si se face inca o iteratie



    negative:
    	mov ebx, edx 			; daca e negativ, inseamna ca numarul a fost
    	mov edx, 0 				; format integral in modul, si se face trecerea
    	sub edx, ebx 			; la forma sa negativa


    done:
    	mov eax, edx 			; la sfarsit numarul format se pune in eax
    							; pentru a fi parsat de functie
    leave
    ret

my_create_node:
    enter 0, 0
    xor eax, eax
    xor edx, edx

    mov ecx, dword [ebp + 12]	; in ecx se pastreaza stringul curent
    mov ebx, dword [ebp + 8]   	; in ebx se pastreaza adresa nodului curent

    mov dl, byte [ecx]  	; adresa de inceput a operandului sau numarului

    verify_end_of_str: 		; se verifica daca s-a ajuns la finalul stringului
        cmp dl, 0
        je end_of_str

    verify_delim: 					; se verifica daca byte-ul e ' '
    	cmp dl, byte [delim]
    	jne nothing_to_do

    	inc ecx						; daca primul byte din str e ' ', se 	
    	mov dl, byte [ecx]			; incrementeaza sirul


    nothing_to_do:

    push ebx  					; back up context de registrii
    push edx
    push ecx

    push 4      
    push 3						; apelare calloc(3, 4) -> alocare 3 pointeri
    call calloc     			; pentru structura nodului
    add esp, 8      			; refacere stiva

    pop ecx 					; refacere context de registrii
    pop edx
    pop ebx

   	; in eax se gaseste adresa de la memoria alocata pentru nod

    mov [ebx], eax 				; se adauga in root adresa alocata
    mov edi, eax

    push ebx
    push edx					; back up context de registrii pt alt calloc
    push ecx

    push 1         
    push 12 					; apelare calloc(12, 1) -> alocare 12 bytes
    call calloc     			; pentru char* data din nodul curent
    add esp, 8      			; refacere stiva

    pop ecx
    pop edx						; refacere context registrii
    pop ebx

    mov dword [edi], eax 	

    xchg eax, edi 			; in edi se gaseste char *data din struct node
    						; in eax se gaseste nodul curent

    verify_operand: 		; se verifica daca elementul de adaugat in nodul
        cmp dl, '/' 		; curent (char *data) este un operand sau un numar
        je operand
        cmp dl, '*'
        je operand
        cmp dl, '+'
        je operand
        cmp dl, '-'
        je minus_case

        jmp number

    minus_case: 					; minusul este un caz special in care se
    	mov dh, byte [ecx + 1] 		; verifica daca este un operand sau un
    	cmp dh, byte [delim] 		; numar negativ
    	je operand

    	jmp number



    operand:
    	mov byte [edi], dl			; in cazul in care e operand acesta se
    	inc ecx		  				; pune in char *data

    	push ecx 					; se da stringul ca parametru
    	add eax, 4
    	push eax 					; se da node->left parametru

    	call my_create_node 		; apel recursiv


    	pop eax
    	add esp, 4					 ; refacere stiva

    	; in ecx o sa am dupa primul apel recursiv valoarea incrementata
    	; a stringului, intrucat este posibil sa se mai fi creat noduri cu date
    	; din string


    	push ecx 						; se da stringul ca parametru
    	add eax, 4
    	push eax 						; se da node->right parametru

    	call my_create_node 			; apel recursiv

    	pop eax
    	add esp, 4 						; refacere stiva

  		jmp end_of_str

    number: 							; daca e numar, se va face deep copy
    	mov esi, 0 						; din string in char* data

    	copy_data:
    		cmp dl, 0
    		je end_of_str						; se copiaza byte cu byte	
    		cmp dl, byte [delim] 				; din string in node->data
    		jne add_chipher						; pana cand se gaseste delim
    		jmp data_copied						; sau terminator de sir

    	add_chipher:
    		mov byte [edi + esi * 1], dl 	; pune byte-ul extras in data[esi]
    		inc ecx 						; incrementeaza stringul si	
    		mov dl, byte [ecx] 				; extrage o noua cifra din el
    		inc esi               			; ce va fi verificata              
    		jmp copy_data					; la urmatoare iteratie


    data_copied: 				; dupa copierea numarului se incrementeaza
    	inc ecx 				; stringul pentru a face skip la delimitator

    end_of_str:
        leave
        ret


create_tree:
    enter 0, 0
    xor eax, eax

    pushad 				; back up toti registrii

    mov ebx, dword [ebp + 8]

    push ebx      				; my_create_node(node **root, char* str)
    push root 					; apelarea functiei cu transmitere parametrii
    call my_create_node

    add esp, 8     				; recrearea stivei

    popad 						; refacere context pentru main

    mov eax, dword [root] 		; parsarea root ului prin eax

    leave
    ret
