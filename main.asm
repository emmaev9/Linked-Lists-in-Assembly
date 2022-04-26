.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern scanf: proc
extern calloc: proc
extern free: proc
;extern fopen: proc
extern fclose: proc
extern fsacnf: proc
extern fprintf: proc

public start

.data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;---FORMATURILE NECESARE---

   	 format0 DB "Alege optiunea: ",13,10,13,10, 0
	 format1 DB "TASTA 1: Insereaza un element in lista", 13,10, 0
	 format2 DB "TASTA 2: Afiseaza lista",13,10, 0
	 format3 DB "TASTA 3: Sterge lista", 13,10, 0
     format4 DB "TASTA 4: Sterge un nod",13,10, 0
     format5 DB "TASTA 5: Salveaza lista intr-un fisier",13,10, 0
     format6 DB "TASTA 6: Incarca valorile din fisier intr-o lista.",13,10,0
     format7 DB "TASTA 7: Copiaza valorile din lista intr-un sir de intregi",13,10,0
     format8 DB "TASTA 8: EXIT", 13,10,0
     format_comanda DB "TASTA: ", 0
	 format_inserare DB "Insert:", 0
     format_citire DB "%d",0
	 format_afisare_lista DB "Lista: ",0
	 format_stergere_lista DB "Lista a fost stearsa", 13, 10, 0
	 format_scriere DB "%d ", 0
	 format_greseala DB "Tasta incorecta. Mai incearca. :)", 13,10,0
	 format_lungime DB  "Lista contine %d noduri", 13, 10, 0
	 copiere_efectuata DB "Lista a fost copiata in sirul de intregi", 13, 10, 0
	 noduri_0 DB "Nu sunt noduri in lista", 13, 10, 0
	 format_index_element_de_sters DB "Index: ", 0
	 index_incorect DB "Indexul e mai mare decat numarul de noduri", 13,10, 0
	 lista_goala DB "Lista e goala", 13, 10, 0
	 index0 DB "Indexul e 0", 13,10, 0
	 sirul DB "Sirul de intregi: ",13,10,0
	 stergere_efectuata DB "Stergerea a fost efectuata cu succes", 13, 10, 0
	 format_spatiu DB " ", 13,10, 0
     ;nume_fisier DB "fisier_in.txt", 0
	 ;mod_citire DB "r", 0
	; mod_scriere DB "w", 0
	 
     TASTA DD 0 
	 element DD 0
	 first DD 0
	 index DD 0
	 sir DD 5 dup(0)
	; FILE DD 0

NODE struct
     key DB 0
	 next DB 0
NODE ends

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	 
.code
                        ; ----MACRO-URI----
						
comanda1 macro instructiune, arg1
     push arg1
	 call instructiune
	 add ESP, 4
endm

comanda2 macro instructiune, arg2, arg1
     push arg1
	 push arg2
	 push instructiune
	 add ESP, 8
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                        ;----PROCEDURI----
                       					   
Inserare_nod proc ;parametrii: key, first
     push EBP
     mov EBP, ESP
	
	 sub ESP, 8
	 mov [EBP-4], EBX ; salvam valoarea veche a lui ebx
	
     push type NODE ; alocam memorie pentru un nod
	 push 1
	 call calloc
	 add ESP, 8
	
	 mov EBX,[EBP+12]              ; citim cheia transmisa ca si parametru pe stiva
	 mov [EAX], EBX	                ; salvam cheia in node.key
	 mov dword ptr [EAX+4], 0	; in node.next se pune NULL pentru ca e ultimul nod din lista
	
	 mov EBX, [EBP+8]               ;pun in ebx adresa lui first
	 cmp EBX, 0                         ;verific daca lista e goala
	 je lista_initial_goala
	
	 elementul_urmator:
	     cmp dword ptr[EBX+4], 0
		 je ultimul_element
		
		 mov EBX, [EBX+4]               ;mergem la urmatorul nod
		 jmp elementul_urmator
	 ultimul_element:
	     mov dword ptr[EBX+4], EAX ;facem legatura intre ultimul si penultimul nod
	 iesire:
	     mov EBX, [EBP-4]                 ; refacem valoarea veche a lui ebx
	    
		 mov ESP, EBP
		 pop EBP
		 ret 4
	 lista_initial_goala:
		 mov first, EAX                      ; first = nodul creeat
		 jmp iesire
Inserare_nod endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Afisare_lista proc  ;parametru: first
    push EBP
    mov EBP, ESP

    sub ESP, 4
	mov [EBP-4], EBX
    mov EBX, [EBP + 8]                ; Adresa primului element
    cmp EBX, 0
    je lista_e_goala
    comanda1 printf, offset format_afisare_lista
urmatorul_nod:
   
    push dword ptr[EBX]
	push offset format_scriere
    call printf
	add ESP, 8
	
    mov EBX, [EBX+4]                  ;trecem la urmatorul element
    cmp EBX, 0                             ;verific daca am ajuns la finalul listei
    jne urmatorul_nod
	
final:
    push offset format_spatiu
	call printf
	add ESP, 4
	
    mov EBX, [EBP-4]                   ;refacem valoarea lui EBX

    mov ESP, EBP
    pop EBP
    ret 4

lista_e_goala:
     push offset lista_goala
	 call printf
	 add ESP, 4
     jmp final

Afisare_lista endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

Stergere_lista proc ;parametru: first
     push EBP
	 mov EBP, ESP
	 sub ESP, 4
	 mov [EBP-4], EAX                        ;retin valoarea lui eax
	 
	 mov EAX, [EBP+8]                      ; pun in eax adresa lui first
	 cmp EAX, 0                               ; cat timp nu am ajuns la finalul listei, eliberez memooria
	 je final
	 
	 push dword ptr[EAX+4]            ; merg la urmatorul nod
	 call Stergere_lista 
	 add ESP, 4
	 
	 push EAX
	 call free
	 add ESP, 4
	 
	 final:
	 mov first, 0                               ; adresa lui first devine 0
	 mov EAX, [EBP-4]                     ;refac valoarea lui eax
	 mov ESP, EBP
	 pop EBP
	 ret 4
	 
Stergere_lista endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Stergere_nod proc ;parametrii: indexul nodului, first
     
	 push EBP
	 mov EBP, ESP
	 sub ESP, 4
	 mov [EBP-4], EAX                         ;retin valoarea lui eax
	 
	 mov EAX, [EBP+8]                       ;temp=first
	 cmp EAX, 0                                  ;verific daca lista e goala
	 je lista_e_goala
	
	 mov EDX, [EBP+12]                    ;pun in ebx indexul
	 cmp EDX, 0                                 ;verific daca indexul=0 => trebuie modificat first 
	jne caut_nodul
     modific_first:
	         mov ECX, EAX
	         mov EAX, [EAX+4]
			 mov first, EAX
			 
			 comanda2 printf, offset format_scriere,ECX
			 push ECX
             call free                                ;eliberez memoria
             add ESP, 4	
             
			 cmp first, 0                           ;verific daca lista avea un singur nod
			 je lista_stearsa		    		 
			 
	         jmp efectuat
	
	 caut_nodul:
	     mov EDX, [EBP+12]                  ; pun in edx indexul
		 xor ECX, ECX                            ; ecx-contor
		 
		 sub EDX, 1                               ;index=index-1  
		 mov ECX, EDX
		
		 bucla: 
		     ;for (int i=0;  i<index-1;  i++) {  temp= temp->next; }
		      mov EAX, [EAX+4]              ;temp=temp->next
		 loop bucla
	
		 ;if(temp == NULL) return; --daca pozitia e mai mare decat nr de noduri
		 cmp EAX, 0
		 je index_prea_mare
		 mov EDX, [EAX+4]
		 cmp EDX, 0
		 je index_prea_mare
		 
         altfel:
	         ;Node* next = prev->next->next
			 ;free(prev->next)
			 ;prev->next = next
			 ;EAX reprezinta previous
			 mov ECX, [EAX+4]                       ;ECX = prev->next           ECX reprezinta nodul care trebuie sters
			 mov EDX, [ECX+4]                       ;EDX = prev->next->next              EDX reprezinta next
			 
			 mov dword ptr[EAX+4], EDX
	         push ECX      
	         call free                                     ;eliberez memoria
	         add ESP,4
			 
			 jmp efectuat
	 
     final:
	 mov EAX, [EBP-4]                        ;refac valoarea lui eax
	 mov ESP, EBP
	 pop EBP
	 ret 4
	 
	 efectuat:
	         comanda1 printf, offset stergere_efectuata
	 jmp final
	 lista_e_goala:
	       comanda1 printf, offset lista_goala
	 jmp final
	 
	 index_prea_mare:
	        comanda1 printf, offset index_incorect
	 jmp final
	 
	 lista_stearsa:
	     comanda1 printf, offset format_stergere_lista
	     mov first, 0
	 jmp final
	 
Stergere_nod endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
Lungime_lista proc                     ;parametru: first
     push EBP
	 mov EBP, ESP
	 sub ESP, 4
	 mov [EBP-4], EAX
	 mov EAX, [EBP+8]               ;pun in eax first
	 xor ECX, ECX
	 
	 cmp EAX, 0
	 je nu_sunt_noduri_in_lista
	 afla_lungimea:
	 
	    add ECX, 1
	    mov EAX, [EAX+4]
		cmp EAX, 0                     ;verific daca am ajuns la finanul listei
	    jne afla_lungimea
	 
	 push ECX
	 push offset format_lungime
	 call printf
	 add ESP, 8
	 
	 iesire:
	   mov EAX, [EBP-4]
	   mov ESP, EBP
	   pop EBP
	   ret 4
	 
	 nu_sunt_noduri_in_lista:
	   push offset noduri_0
	   call printf
	   add ESP,4
	   jmp iesire

Lungime_lista endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sir_intregi proc                      ;parametru: first
     push EBP
     mov EBP, ESP
     sub ESP, 4
 	 mov [EBP-4], EBX
     mov EBX, [EBP + 8]                ; Adresa primului element
    
	 cmp EBX, 0
     je lista_e_goala
     mov ESI, offset sir
	 
inserare:
	 mov EDX, dword ptr[EBX]
	 mov [ESI], EDX
	
     ;push [ESI]
	 ;push offset format_scriere    ;afisarea sirului
     ;call printf
	 ;add ESP, 8
	
	 inc ESI
     mov EBX, [EBX+4]                  ;trecem la urmatorul element 
     cmp EBX, 0                 	;verific daca am ajuns la finalul listei
 jne inserare
     push offset copiere_efectuata
     call printf
	 add ESP, 4	
final:
    mov EBX, [EBP-4]                   ;refacem valoarea lui EBX
    mov ESP, EBP
    pop EBP
    ret 4

lista_e_goala:
     push offset lista_goala
	 call printf
	 add ESP, 4
     jmp final
Sir_intregi endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                                                  ;MAIN
start:
  
          comanda1 printf, offset format0
	      comanda1 printf, offset format1    
	      comanda1 printf, offset format2
	      comanda1 printf, offset format3
	      comanda1 printf, offset format4                    ;afisare meniu
	      comanda1 printf, offset format5
	      comanda1 printf, offset format6
	      comanda1 printf, offset format7
		  comanda1 printf, offset format8
	  
     alege_tasta:	
          comanda1 printf, offset format_spatiu	 
	      comanda1 printf, offset format_comanda
	     
		  push offset TASTA
	      push offset format_citire
	      call scanf
	      add ESP,8
		  
		  mov EDX, TASTA
		  cmp EDX, 8
		  jg tasta_gresita
		  cmp EDX, 1
		  je insereaza_nod
		  cmp EDX, 2
		  je afisarea_listei
		  cmp EDX, 3
		  je stergerea_listei
		  cmp EDX, 4
		  je sterge_nod
		  cmp EDX, 5
		  je sir_de_intregi
		  cmp EDX, 6
		  je incarcare_in_fisier
		  cmp EDX, 7
		  je descarcare_din_fisier
		  cmp EDX, 8
		  je final
		 ; cmp EDX, 10
		 ; je lungime
		  sterge_nod:
		         comanda1 printf, offset format_index_element_de_sters
				 
				 push offset index
                 push offset format_citire
                 call scanf
                 add ESP, 8
 				 
				 push index                            ;indexul nodului care urmeaza sa fie sters
				 push dword ptr[first]
				 call Stergere_nod
				 
				 jmp alege_tasta
				 
		  stergerea_listei:
		         comanda1 printf, offset format_stergere_lista
                 push dword ptr [first] 
			     call Stergere_lista
			 
			     jmp alege_tasta
		  
		  afisarea_listei:
		    	 push dword ptr [first] 
			     call Afisare_lista
			 
			     jmp alege_tasta
			 
		  insereaza_nod: 
                 comanda1 printf, offset format_inserare		  
		    
			     push offset element
	     	     push offset format_citire
			     call scanf
			     add ESP, 8
			 
			     push element
			     push dword ptr[first]
			     call Inserare_nod
			 
			     jmp alege_tasta
			
		  lungime:
		         push dword ptr[first]
				 call Lungime_lista
				 
				 jmp alege_tasta
				 
		  sir_de_intregi:
				 push dword ptr[first]
				 call Sir_intregi
				 
				 jmp alege_tasta
		  tasta_gresita:
		        push offset format_greseala
				call printf
				add ESP, 4
				
				jmp alege_tasta
				
		   incarcare_in_fisier:
;	             push dword ptr[first]
;				 call Incarcare_fisier
				 
				 jmp stergerea_listei
				 
	       descarcare_din_fisier:
	             
				 jmp alege_tasta
	 
	 final:
	 push 0
	 call exit
end start