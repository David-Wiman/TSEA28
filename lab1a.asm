;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Mall för lab1 i TSEA28 Datorteknik Y
;;
;; 210105 KPa: Modified for distance version
;;

	;; Ange att koden är för thumb mode
	.thumb
	.text
	.align 2

	;; Ange att labbkoden startar här efter initiering
	.global	main
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Ange vem som skrivit koden
;;               student LiU-ID: davwi279
;; + ev samarbetspartner LiU-ID: samer177
;;
;; Placera programmet här

wrongcode .string "Felaktig kod!",10,13				; spara felmeddelandet i programminnet
	 .align 2

main:				; Start av programmet
	
	bl inituart			; initiera allt och sätt lösenordet
	bl initGPIOE
	bl initGPIOF
	bl setpassword

start:				; början på den aktiva koden
	bl activatealarm
	bl clearinput
	bl releasedkey
afterevaluate:
	bl getkey
	bl updatekey
	b evaluatekey

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setpassword:
;	spara den giltiga koden i minnet

	mov r0,#0x1
	mov r1,#(0x20001013 & 0xffff)
	movt r1,#(0x20001013 >> 16)
	strb r0,[r1]

	mov r0,#0x3
	mov r1,#(0x20001012 & 0xffff)
	movt r1,#(0x20001012 >> 16)
	strb r0,[r1]

	mov r0,#0x3
	mov r1,#(0x20001011 & 0xffff)
	movt r1,#(0x20001011 >> 16)
	strb r0,[r1]

	mov r0,#0x7
	mov r1,#(0x20001010 & 0xffff)
	movt r1,#(0x20001010 >> 16)
	strb r0,[r1]

	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updatekey:
	mov r5,#(GPIOE_GPIODATA & 0xffff)	; spara tangenttryck i r4
	movt r5,#(GPIOE_GPIODATA >> 16)
	ldr r4,[r5]
	ands r4,#0xF
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
releasedkey:						; vänta på att ingen tangent är nedtryckt
	mov r8,#(GPIOE_GPIODATA & 0xffff)
	movt r8,#(GPIOE_GPIODATA >> 16)
	ldr r7,[r8]
	ands r7,#0x10
	bne releasedkey
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; activatealarm
; Inargument: Inga
; Utargument: Inga
;
; Funktion: Täander röd lysdiod (bit 3 = 0, bit 2 = 0, bit 1 = 1)
activatealarm:
; Förberedelseuppgift: Skriv denna subrutin!
	mov r1,#(GPIOF_GPIODATA & 0xffff)
	movt r1,#(GPIOF_GPIODATA >> 16)
	mov r0,#0x00000002
	str r0,[r1]
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: Täander grön lysdiod (bit 3 = 1, bit 2 = 0, bit 1 = 0)
deactivatealarm:
; Förberedelseuppgift: Skriv denna subrutin!
	mov r1,#(GPIOF_GPIODATA & 0xffff)
	movt r1,#(GPIOF_GPIODATA >> 16)
	mov r0,#0x00000008
	str r0,[r1]
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: Sätter innehållet på 0x20001000-0x20001003 till 0xFF
clearinput:
; Förberedelseuppgift: Skriv denna subrutin!
	mov r1,#(0x20001000 & 0xffff)
	movt r1,#(0x20001000 >> 16)
	mov r0,#0xFF
	str r0,[r1]

	mov r1,#(0x20001001 & 0xffff)
	movt r1,#(0x20001001 >> 16)
	mov r0,#0xFF
	str r0,[r1]

	mov r1,#(0x20001002 & 0xffff)
	movt r1,#(0x20001002 >> 16)
	mov r0,#0xFF
	str r0,[r1]

	mov r1,#(0x20001003 & 0xffff)
	movt r1,#(0x20001003 >> 16)
	mov r0,#0xFF
	str r0,[r1]
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;checkcode
; Inargument: Inga
; Utargument: Returnerar 1 i r4 om koden var korrekt, annars 0 i r4
checkcode:
; Förberedelseuppgift: Skriv denna subrutin!
	mov r1,#(0x20001010 & 0xffff)		; läs in rätt kod
	movt r1,#(0x20001010 >> 16)
	ldr r0,[r1]

	mov r1,#(0x20001000 & 0xffff)		; läs in inskriven kod
	movt r1,#(0x20001000 >> 16)
	ldr r2,[r1]

	cmp r0,r2
	beq rightcode
	mov r3,#0x0
	bx lr

rightcode:
	mov r3,#0x1
	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ifzero:			; om fel kod skrivits in
	mov r5,#0xf			; sätt längden på strängen
	adr r4,wrongcode		; hitta strängen i minnet
	adr r7,wrongcode
	bl printstring
	mov r4,#0x0
	b start

ifone:
	mov r4,#0x1		; om rätt kod skrivits in
	bl deactivatealarm
	b getkeywhileopen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Tryckt knappt returneras i r4
getkey:
; Förberedelseuppgift: Skriv denna subrutin!

	mov r8,#(GPIOE_GPIODATA & 0xffff)	; vänta på tangenttryck
	movt r8,#(GPIOE_GPIODATA >> 16)

loop:
	ldr r7,[r8]
	ands r7,#0x10
	bne releasekey
	b loop

releasekey:								; vänta på att tangenten släpps upp
	mov r8,#(GPIOE_GPIODATA & 0xffff)
	movt r8,#(GPIOE_GPIODATA >> 16)
	ldr r7,[r8]
	ands r7,#0x10
	bne releasekey

	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
evaluatekey:

	cmp r4,#0xF		; kontrollera om F trycktes in
	beq pressedf

	cmp r4,#0xA 	; kontrollerar att ingen annan bokstav tryckts ner
	bpl start
	bl addkey

	b afterevaluate

pressedf:
	bl checkcode
	cmp r3,#0x1
	beq ifone
	b ifzero


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
getkeywhileopen:						; samma som getkey fast bara i det öppna läget

	mov r8,#(GPIOE_GPIODATA & 0xffff)		; väntar på tangenttryck
	movt r8,#(GPIOE_GPIODATA >> 16)
	ldr r7,[r8]
	ands r7,#0x10
	bne updatekeywhileopen
	b getkeywhileopen

updatekeywhileopen:							; spara tangenttryck i r4
	mov r5,#(GPIOE_GPIODATA & 0xffff)
	movt r5,#(GPIOE_GPIODATA >> 16)
	ldr r4,[r5]
	ands r4,#0xF

	cmp r4,#0xA			; om A trycktes in, lås och börja om
	beq start

	b getkeywhileopen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Vald tangent i r4
; Utargument: Inga
;
; Funktion: Flyttar innehållet på 0x20001000-0x20001002 framåt en byte
; till 0x20001001-0x20001003. Lagrar sedan innehållet i r4 på
; adress 0x20001000.
addkey:
; Förberedelseuppgift: Skriv denna subrutin!

	mov r1,#(0x20001000 & 0xffff)
	movt r1,#(0x20001000 >> 16)
	ldr r2,[r1]
	lsl r2,r2,#0x8
	str r2,[r1]

	strb r4,[r1]

	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Pekare till strängen i r4
; Längd på strängen i r5
; Utargument: Inga
;
; Funktion: Skriver ut strängen mha subrutinen printchar
printstring:
; Förberedelseuppgift: Skriv denna subrutin!
; skriv ut meddelandet som r4 pekar på
	ldrb r0, [r4]
	push {lr}
	bl printchar
	pop {lr}
	add r4,r4,#0x1
	sub r8,r4,r5
	cmp r7,r8
	bne printstring
	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;;
;;; Allt här efter ska inte ändras
;;;
;;; Rutiner för initiering
;;; Se labmanual för vilka namn som ska användas
;;;
	
	.align 4

;; 	Initiering av seriekommunikation
;;	Förstör r0, r1 
	
inituart:
	mov r1,#(RCGCUART & 0xffff)		; Koppla in serieport
	movt r1,#(RCGCUART >> 16)
	mov r0,#0x01
	str r0,[r1]

	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x01
	str r0,[r1]		; Koppla in GPIO port A

	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOA_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOA_GPIOAFSEL >> 16)
	mov r0,#0x03
	str r0,[r1]		; pinnar PA0 och PA1 som serieport

	mov r1,#(GPIOA_GPIODEN & 0xffff)
	movt r1,#(GPIOA_GPIODEN >> 16)
	mov r0,#0x03
	str r0,[r1]		; Digital I/O på PA0 och PA1

	mov r1,#(UART0_UARTIBRD & 0xffff)
	movt r1,#(UART0_UARTIBRD >> 16)
	mov r0,#0x08
	str r0,[r1]		; Sätt hastighet till 115200 baud
	mov r1,#(UART0_UARTFBRD & 0xffff)
	movt r1,#(UART0_UARTFBRD >> 16)
	mov r0,#44
	str r0,[r1]		; Andra värdet för att få 115200 baud

	mov r1,#(UART0_UARTLCRH & 0xffff)
	movt r1,#(UART0_UARTLCRH >> 16)
	mov r0,#0x60
	str r0,[r1]		; 8 bit, 1 stop bit, ingen paritet, ingen FIFO
	
	mov r1,#(UART0_UARTCTL & 0xffff)
	movt r1,#(UART0_UARTCTL >> 16)
	mov r0,#0x0301
	str r0,[r1]		; Börja använda serieport

	bx  lr

; Definitioner för registeradresser (32-bitars konstanter) 
GPIOHBCTL	.equ	0x400FE06C
RCGCUART	.equ	0x400FE618
RCGCGPIO	.equ	0x400fe608
UART0_UARTIBRD	.equ	0x4000c024
UART0_UARTFBRD	.equ	0x4000c028
UART0_UARTLCRH	.equ	0x4000c02c
UART0_UARTCTL	.equ	0x4000c030
UART0_UARTFR	.equ	0x4000c018
UART0_UARTDR	.equ	0x4000c000
GPIOA_GPIOAFSEL	.equ	0x40004420
GPIOA_GPIODEN	.equ	0x4000451c
GPIOE_GPIODATA	.equ	0x400240fc
GPIOE_GPIODIR	.equ	0x40024400
GPIOE_GPIOAFSEL	.equ	0x40024420
GPIOE_GPIOPUR	.equ	0x40024510
GPIOE_GPIODEN	.equ	0x4002451c
GPIOE_GPIOAMSEL	.equ	0x40024528
GPIOE_GPIOPCTL	.equ	0x4002452c
GPIOF_GPIODATA	.equ	0x4002507c
GPIOF_GPIODIR	.equ	0x40025400
GPIOF_GPIOAFSEL	.equ	0x40025420
GPIOF_GPIODEN	.equ	0x4002551c
GPIOF_GPIOLOCK	.equ	0x40025520
GPIOKEY		.equ	0x4c4f434b
GPIOF_GPIOPUR	.equ	0x40025510
GPIOF_GPIOCR	.equ	0x40025524
GPIOF_GPIOAMSEL	.equ	0x40025528
GPIOF_GPIOPCTL	.equ	0x4002552c

;; Initiering av port F
;; Förstör r0, r1, r2
initGPIOF:
	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x20		; Koppla in GPIO port F
	str r0,[r1]
	nop 			; Vänta lite
	nop
	nop

	mov r1,#(GPIOHBCTL & 0xffff)	; Använd apb för GPIO
	movt r1,#(GPIOHBCTL >> 16)
	ldr r0,[r1]
	mvn r2,#0x2f		; bit 5-0 = 0, övriga = 1
	and r0,r0,r2
	str r0,[r1]

	mov r1,#(GPIOF_GPIOLOCK & 0xffff)
	movt r1,#(GPIOF_GPIOLOCK >> 16)
	mov r0,#(GPIOKEY & 0xffff)
	movt r0,#(GPIOKEY >> 16)
	str r0,[r1]		; Lås upp port F konfigurationsregister

	mov r1,#(GPIOF_GPIOCR & 0xffff)
	movt r1,#(GPIOF_GPIOCR >> 16)
	mov r0,#0x1f		; tillåt konfigurering av alla bitar i porten
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAMSEL >> 16)
	mov r0,#0x00		; Koppla bort analog funktion
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPCTL & 0xffff)
	movt r1,#(GPIOF_GPIOPCTL >> 16)
	mov r0,#0x00		; använd port F som GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIODIR & 0xffff)
	movt r1,#(GPIOF_GPIODIR >> 16)
	mov r0,#0x0e		; styr LED (3 bits), andra bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPUR & 0xffff)
	movt r1,#(GPIOF_GPIOPUR >> 16)
	mov r0,#0x11		; svag pull-up för tryckknapparna
	str r0,[r1]

	mov r1,#(GPIOF_GPIODEN & 0xffff)
	movt r1,#(GPIOF_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar som digital I/O
	str r0,[r1]

	bx lr


;; Initiering av port E
;; Förstör r0, r1
initGPIOE:
	mov r1,#(RCGCGPIO & 0xffff)    ; Clock gating port (slå på I/O-enheter)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x10		; koppla in GPIO port B
	str r0,[r1]
	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOE_GPIODIR & 0xffff)
	movt r1,#(GPIOE_GPIODIR >> 16)
	mov r0,#0x0		; alla bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAMSEL >> 16)
	mov r0,#0x00		; använd inte analoga funktioner
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPCTL & 0xffff)
	movt r1,#(GPIOE_GPIOPCTL >> 16)
	mov r0,#0x00		; använd inga specialfunktioner på port B	
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPUR & 0xffff)
	movt r1,#(GPIOE_GPIOPUR >> 16)
	mov r0,#0x00		; ingen pullup på port B
	str r0,[r1]

	mov r1,#(GPIOE_GPIODEN & 0xffff)
	movt r1,#(GPIOE_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar är digital I/O
	str r0,[r1]

	bx lr


;; Utskrift av ett tecken på serieport
;; r0 innehåller tecken att skriva ut (1 byte)
;; returnerar först när tecken skickats
;; förstör r0, r1 och r2 
printchar:
	mov r1,#(UART0_UARTFR & 0xffff)	; peka på serieportens statusregister
	movt r1,#(UART0_UARTFR >> 16)
loop1:
	ldr r2,[r1]			; hämta statusflaggor
	ands r2,r2,#0x20		; kan ytterligare tecken skickas?
	bne loop1			; nej, försök igen
	mov r1,#(UART0_UARTDR & 0xffff)	; ja, peka på serieportens dataregister
	movt r1,#(UART0_UARTDR >> 16)
	str r0,[r1]			; skicka tecken
	bx lr




