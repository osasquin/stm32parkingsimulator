	EXPORT	__main
;cfg rcc
rcc_base	EQU 	0x40021000
rcc_apb2enr	EQU 	0x18
;portB
gpiob_base	EQU     0x40010c00
gpiob_crh	EQU     0x04
gpiob_idr	EQU     0x08
;portC
gpioc_base	EQU     0x40011000
gpioc_crh	EQU     0x04
gpioc_odr	EQU     0x0c
;portA
gpioa_base 	EQU 	0x40010800
gpioa_crl	EQU 	0x00
gpioa_crh	EQU 	0x04
gpioa_odr	EQU 	0x0c
gpioa_brr	EQU 	0x14
;AFIO
afio_base	equ	0x40010000
afio_mapr	equ	0x04

;codigo
	AREA	m_prg, code, readonly
__main
;iniciando valores para teste
	MOV	R11, #4		;N° de vagas disponíveis em A
	MOV	R12, #6		;N° de vagas disponíveis em B
	MOV	R9, #0		;R9 controla a preferência de bloco, A = 0 e B = 1

;inicializando clock para as portas
	LDR	R0,=rcc_base 
	LDR	R1,[R0,#rcc_apb2enr] 
	ORR	R1,R1,#0xFD
	STR	R1,[R0,#rcc_apb2enr] 

	LDR	R0,=afio_base
	LDR	R1,[R0,#afio_mapr] 
	ORR	R1,R1,#0x2000000
	STR	R1,[R0,#afio_mapr] 

;garantindo que gpioa_odr está zerado 
	LDR	R0, =gpioa_base;
	MOV	R1, #0xFFFF
	STRH	R1, [R0,#gpioa_brr]

;configurando PA5 e PA6
	LDR	R1, [R0,#gpioa_crl] 
	MOVT	R1, #0x0330
	STR	R1, [R0,#gpioa_crl]

;configurando PA8, PA11, PA12 e PA15
	LDR	R1, [R0,#gpioa_crh]
	MOV	R1, #0x3003
	MOVT	R1, #0x3003
	STR	R1, [R0,#gpioa_crh]
	
;Configurando o LCD
	BL	lcd_config

    ;---cfg portb PB12 input
	LDR	R0, =gpiob_base
	LDR     R1, [R0,#gpiob_crh]
	ORR	R1, #0x40000              ; PB12 input floating 
	STR	R1, [R0,#gpiob_crh]


    ;---ci PC13 (Hi-z)
	LDR	R2, =gpioc_base
	LDR	R1, [R2,#gpioc_odr]
	ORR	R1,R1,#0x2000
	STR	R1,[R2,#gpioc_odr]

    ;---cfg PC13 output
	LDR	R2,=gpioc_base
	LDR	R3,[R2,#gpioc_crh]
	ORR	R3,#0x200000             ; PC13 output op-dr 
	STR	R3,[R2,#gpioc_crh]			

;Mostrando no LCD o estado atual do sistema
	BL	print_data

pkb
	LDR	R1,[R0,#gpiob_idr]      ; ler PB12
	ANDS	R1,R1,#0x1000           ; pres. PB12
	BEQ	pkb                     ; wait until button is pressed

    ;---debounce delay
	MOV	R5, #10000
debounce
	subs	R5, R5, #1
	BNE	debounce
	
	bl	toggle_led              

    ;---wait for button release
	bl	wait_for_release

	b	pkb

toggle_led
	cmp	R9, #0                  ; check if LED is off
	BEQ	turn_on_led             ; if off, turn on

turn_off_led
	LDR	R1,[R2,#gpioc_odr]
	ORR	R1,R1,#0x2000            
	STR	R1,[R2,#gpioc_odr]
	MOV	R9, #0                  
	bx	lr

turn_on_led
	LDR	R1,[R2,#gpioc_odr]
	MOV	R3,#0xdfff
	AND	R1,R1,R3
	STR	R1,[R2,#gpioc_odr]
	MOV	R9, #1                  
	bx	lr

wait_for_release
	LDR	R1,[R0,#gpiob_idr]      
	ANDS	R1,R1,#0x1000            
	BNE	wait_for_release        
	
	BL	print_data

loop	NOP
	B	loop


;Subrotina para configurar o LCD -----------------
lcd_config	
	PUSH	{R0-R12}
	PUSH	{R14}

	MOV	R10, #0x28	;0010 1000
	BL	lcd_commAND
	MOV	R10, #0x0F	;1111
	BL	lcd_commAND
	MOV	R10, #0x01	;0001
	BL	lcd_commAND
	MOV	R10, #0x06	;0110
	BL	lcd_commAND

	POP 	{R14}
	POP	{R0-R12}
	BX	R14
;--------------------------------------------------

;Subrotina para enviar um comANDo ao LCD ----------
lcd_commAND	
	PUSH	{R0-R12}
	PUSH	{R14}

	LDR	R0, =gpioa_base
	LDRH	R1, [R0, #gpioa_odr]
	MOV	R2, #0x7FFF
	AND	R1, R2
	STRH	R1, [R0, #gpioa_odr]
	BL	delay
	BL	lcd_load

	POP 	{R14}
	POP	{R0-R12}
	BX	R14
;--------------------------------------------------

;Subrotina para escrever algo no LCD --------------
lcd_show	
	PUSH	{R0-R12}
	PUSH	{R14}
		
	LDR	R0, =gpioa_base
	LDRH	R1, [R0, #gpioa_odr]
	ORR	R1, #0x8000
	STRH	R1, [R0, #gpioa_odr]
	BL	lcd_load

	POP 	{R14}
	POP	{R0-R12}
	BX	R14
;--------------------------------------------------

;Subrotina para carregar um valor no LCD ----------
lcd_load
	PUSH	{R0-R12}
	PUSH	{R14}

	MOV	R1, #2
	LDR	R2, =gpioa_base
	LSR	R3, R10, #4
salva_bits
	;DesativANDo o Enable
	LDRH	R4, [R2, #gpioa_odr]
	BIC	R4, #0x1960
	AND	R3, #0xF
	STRH	R4, [R2, #gpioa_odr]
	BL	delay

	;ColocANDo o primeiro bit na posição 0x100
	AND	R5, R3, #0x1	
	LSL	R5, #9-1
	ORR	R4, R5

	;ColocANDo o segundo bit na posição 0x40
	AND	R5, R3, #0x2
	LSL	R5, #7-2
	ORR	R4, R5
	
	;ColocANDo o terceiro bit na posição 0x20
	AND	R5, R3, #0x4	
	LSL	R5, #6-3
	ORR	R4, R5
	
	;ColocANDo o quarto bit na posição 0x800
	AND	R5, R3, #0x8	
	LSL	R5, #12-4
	ORR	R4, R5
	
	MOV	R3, R10	;Para salvar os bits menos significavos
	
	;DANDo Enable
	LDRH	R7, [R2, #gpioa_odr]
	ORR	R7, #0x1000
	STRH	R7, [R2, #gpioa_odr]

	STRH	R4, [R2, #gpioa_odr]
	BL	delay

	SUBS	R1, #1
	BNE	salva_bits

	POP 	{R14}
	POP	{R0-R12}
	BX	R14
;--------------------------------------------------

;Subrotina de delay -------------------------------
delay 	
	PUSH	{R0-R12}
	PUSH	{R14}

	MOV     R0, #7500
pk2     SUBS    R0, #1             
        BNE     pk2 

	POP 	{R14}
	POP	{R0-R12}
	BX	R14
;--------------------------------------------------

;Subrotina para escrever os dados no display LCD --
print_data
	PUSH	{R0-R12}
	PUSH	{R14}
	
	MOV	R10, #0x01
	BL	lcd_commAND

	CMP	R11, #0
	BNE	ha_vagas
	CMP	R12, #0
	BNE	ha_vagas
	MOV	R10, #'S'
	BL	lcd_show
	MOV	R10, #'E'
	BL	lcd_show
	MOV	R10, #'M'
	BL	lcd_show
	MOV	R10, #' '
	BL	lcd_show
	MOV	R10, #'V'
	BL	lcd_show
	MOV	R10, #'A'
	BL	lcd_show
	MOV	R10, #'G'
	BL	lcd_show
	MOV	R10, #'A'
	BL	lcd_show
	MOV	R10, #'S'
	BL	lcd_show
	B	sair

ha_vagas
	MOV	R10, #0x01
	BL	lcd_commAND
	MOV	R10, #'P'
	BL	lcd_show
	MOV	R10, #':'
	BL	lcd_show
	ADD	R0, R9, #0x41
	MOV	R10, R0
	BL	lcd_show
	MOV	R10, #' '
	BL	lcd_show
	MOV	R10, #'A'
	BL	lcd_show
	MOV	R10, #':'
	BL	lcd_show
	ADD	R0, R11, #0x30
	MOV	R10, R0
	BL	lcd_show
	MOV	R10, #' '
	BL	lcd_show
	MOV	R10, #'B'
	BL	lcd_show
	MOV	R10, #':'
	BL	lcd_show
	ADD	R0, R12, #0x30
	MOV	R10, R0
	BL	lcd_show
	MOV	R10, #' '
	BL	lcd_show
	MOV	R10, #'E'
	BL	lcd_show
	MOV	R10, #':'
	BL	lcd_show
	
	;lógica para definir qual bloco será escolhido
	CMP	R11, #0
	BEQ	blocoA_ocupado
	CMP	R9, #0
	BEQ	E_blocoA
	B	teste_blocoB
	
blocoA_ocupado
	MOV	R10, #'B'
	BL	lcd_show
	B 	sair

E_blocoA
	MOV	R10, #'A'
	BL	lcd_show
	B 	sair

teste_blocoB
	CMP	R12, #0
	BEQ	E_blocoA
	MOV	R10, #'B'
	BL	lcd_show
sair
	POP 	{R14}
	POP	{R0-R12}
	B	pkb
;--------------------------------------------------

	END