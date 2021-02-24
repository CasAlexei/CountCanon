;*******************************************************************************
;*******************************************************************************
;**                                                                           **
;**             ��������� ��� �������� ����� ��� ������ Canon NP.             **
;**                                                                           **
;**               ��� �� ATmega8 �������� ������� 4.00 ��                     **
;**                                                                           **
;*******************************************************************************
;*******************************************************************************
/*  Fuse Bits:
 CKSEL0=1
 CKSEL1=1
 CKSEL2=1
 CKSEL3=1
 SUT0=1
 SUT1=1
 BODEN=1
 BODLEVEL=1
 BOOTRST=1
 BOOTSZ0=0
 BOOTSZ1=0
 EESAVE=1
 CKOPT=0
 JTAGEN=1
 OCDEN=1
 ��� ���������=0 ������ �������, ��� ��������=1 ��������� �����.
*/

.include "m8def.inc"
 
    
	; ���������� ����������

.def	mulL=r0
.def	mulH=r1
.def	adwL=r2
.def	adwH=r3
.def	count=r4							; ������� ���������� �����
.def	cenaL=r5							; ���� (������� ������)
.def	cenaH=r6							; ���� (������� ������)
.def	cena_copii=r7						; ���� ����� �����

.def	temp0=r16
.def	temp=r17
.def	temp1=r18
.def	temp2=r19
.def	d=r20
.def	DigPoz=r21

	; ��� ������� ������. � ��� ���������� ����������� ������

.dseg

Digit:		.byte 6
BCD:		.byte 5





.cseg

; ***** INTERRUPT VECTORS ************************************************
.org	$000
		rjmp RESET                             ; ��������� ������
.org	$0001
		rjmp aINT0                              ; 0x0001 - ������� ���������� 0
.org	$0002
		rjmp aINT1                              ; 0x0002 - ������� ���������� 1
.org	$0003
		rjmp aOC2                               ; 0x0003 - ���������� �������/�������� �2
.org	$0004
		rjmp aOVF2                              ; 0x0004 - ������������ �������/�������� �2
.org	$0005
		rjmp aICP1                              ; 0x0005 - ������ �������/�������� �1
.org	$0006
		rjmp aOC1A                              ; 0x0006 - ���������� � �������/�������� �1
.org	$0007
		rjmp aOC1B                              ; 0x0007 - ���������� � �������/�������� �1
.org	$0008
		rjmp aOVF1                              ; 0x0008 - ������������ �������/�������� �1
.org	$0009
		rjmp aOVF0                              ; 0x0009 - ������������ �������/�������� �0
.org	$000a
		rjmp aSPI                               ; 0x000a - �������� �� SPI ���������
.org	$000b
		rjmp aURXC                              ; 0x000b - USART, ����� ��������
.org	$000c
		rjmp aUDRE                              ; 0x000c - ������� ������ USART ����
.org	$000d
		rjmp aUTXC                              ; 0x000d - USART, �������� ���������
.org	$000e
		rjmp aADCC                              ; 0x000e - �������������� ADC ���������
.org	$000f
		rjmp aERDY                              ; 0x000f - EEPROM �����
.org	$0010
		rjmp aACI                               ; 0x0010 - Analog Comparator
.org	$0011
		rjmp aTWI                               ; 0x0011 - ���������� �� 2-wire Serial Interface
.org	$0012
		rjmp aSPMR                              ; 0x0012 - ���������� SPM





aINT0:                              ; 0x0001 - ������� ���������� 0
aINT1:                              ; 0x0002 - ������� ���������� 1
aOC2:                               ; 0x0003 - ���������� �������/�������� �2
aOVF2:                              ; 0x0004 - ������������ �������/�������� �2
aICP1:                              ; 0x0005 - ������ �������/�������� �1
aOC1A:                              ; 0x0006 - ���������� � �������/�������� �1
aOC1B:                              ; 0x0007 - ���������� � �������/�������� �1
aOVF1:                              ; 0x0008 - ������������ �������/�������� �1
;aOVF0:                              ; 0x0009 - ������������ �������/�������� �0
aSPI:                               ; 0x000a - �������� �� SPI ���������
aURXC:                              ; 0x000b - USART, ����� ��������
aUDRE:                              ; 0x000c - ������� ������ USART ����
aUTXC:                              ; 0x000d - USART, �������� ���������
aADCC:                              ; 0x000e - �������������� ADC ���������
aERDY:                              ; 0x000f - EEPROM �����
aACI:                               ; 0x0010 - Analog Comparator
aTWI:                               ; 0x0011 - ���������� �� 2-wire Serial Interface
aSPMR:                              ; 0x0012 - ���������� SPM



RESET:

	; ������������� ����� 
 ldi 	temp, LOW(RAMEND)
 out	spl, Temp
 ldi 	temp, HIGH(RAMEND)
 out	sph, Temp



	; ������������� ������
		
 ldi	temp,0b00111111                       ; ������������� ����� B
 out	DDRB,temp

 ldi	temp,0b00000000                       ; ������������� ����� C
 out	DDRC,temp

 ldi	temp,0b11000000                       ; ������������� ����� D
 out	DDRD,temp
 
 ldi	temp,0b00000000                       ; ������ �������� �� ����� ����� B
 out	PORTB,temp      
        
 ldi	temp,0b00000000                       ; ������ �������� �� ����� ����� C
 out	PORTC,temp      

 ldi	temp,0b00000000                       ; ������ �������� �� ����� ����� D
 out	PORTD,temp      



;------------------------------------------------------------------------------
     ; ��������� �������/�������� T0 � ������ ������������
 ldi Temp,0b00000010
    ; 7 - 
    ; 6 - 
    ; 5 - 
    ; 4 - 
    ; 3 - 
    ; 2 - CS02 - 1 \
    ; 1 - CS01 - 0  _ ���������� �������� �������� (clk/256)
    ; 0 - CS00 - 0 /
 out TCCR0,Temp

 ldi Temp,0b00000001                        ; ��������� ���������� �� "������"
    ; 7 - OCIE2 ���� �� ���������� ���������� �� "����������"
    ; 6 - TOIE2 ���� �� ���������� ���������� �� ������������ �������/�������� �1
    ; +5 - TICIE1 ���� �� ���������� ���������� �� "������" ������� �������� �1
    ; 4 - OCIE1A ���� �� ���������� ���������� �� "���������� �"
    ; 3 - OCIE1B ���� �� ���������� ���������� �� "���������� �"
    ; 2 - TOIE1 ���� �� ���������� ���������� �� ������������ �������/�������� �1
    ; 1 - 
    ; +0 - TOIE0 ���� �� ���������� ���������� �� ������������ �������/�������� �0
 out TIMSK,Temp



;******************************************************************************
;*                                                                            *
;*                                                                            *
;*         ���������� ��������� � ������������� ���������� ���������          *
;*                                                                            *
;*                                                                            *
;******************************************************************************

    ; ������������� � ������� ����������
                                            ;  Digit +1 +2 +3 +4 +5
                                            ;      8__8__8__8__8__8 

 ldi	temp,20								; �������� ������� - " "
 sts	Digit  ,Temp						; ������ � 1 ������ ����������
 ldi	temp,20
 sts	Digit+1,Temp						; ������ � 2 ������ ����������
 ldi	temp,20
 sts	Digit+2,Temp						; ������ � 3 ������ ����������
 ldi	temp,20
 sts	Digit+3,Temp						; ������ � 4 ������ ����������
 ldi	temp,20
 sts	Digit+4,Temp						; ������ � 5 ������ ����������
 ldi	temp,20
 sts	Digit+5,Temp						; ������ � 6 ������ ����������

	; ����� ����������

 clr	DigPoz
 clr	count
 
 clr	cenaL
 clr	cenaH

EEPROM_read:
 sbic	EECR,EEWE							; ����� ���������� ���������� ������, ���� ����
 rjmp	EEPROM_read
 clr	temp
 out	EEARH,temp
 ldi	temp,0x05
 out	EEARL,temp							; ������� ����� � ������� ������
 sbi	EECR,EERE							; ������ ������
 in		cena_copii,EEDR						; ��������� ��������� ����� ����� �� EEPROM

 sei                                        ; ��������� ����������

 rcall	d500ms
 rcall	d500ms

	; ������� ������� ������ "LESHIC"
 ldi	temp,20								; �������� ������� - " "
 sts	Digit  ,Temp						; ������ � 1 ������ ����������
 ldi	temp,20
 sts	Digit+1,Temp						; ������ � 2 ������ ����������
 ldi	temp,20
 sts	Digit+2,Temp						; ������ � 3 ������ ����������
 ldi	temp,20
 sts	Digit+3,Temp						; ������ � 4 ������ ����������
 ldi	temp,20
 sts	Digit+4,Temp						; ������ � 5 ������ ����������
 ldi	temp,24
 sts	Digit+5,Temp						; ������ � 6 ������ ����������

 rcall	d300ms

 ldi	temp,20								; �������� ������� - " "
 sts	Digit  ,Temp						; ������ � 1 ������ ����������
 ldi	temp,20
 sts	Digit+1,Temp						; ������ � 2 ������ ����������
 ldi	temp,20
 sts	Digit+2,Temp						; ������ � 3 ������ ����������
 ldi	temp,20
 sts	Digit+3,Temp						; ������ � 4 ������ ����������
 ldi	temp,24
 sts	Digit+4,Temp						; ������ � 5 ������ ����������
 ldi	temp,25
 sts	Digit+5,Temp						; ������ � 6 ������ ����������

 rcall	d300ms

 ldi	temp,20								; �������� ������� - " "
 sts	Digit  ,Temp						; ������ � 1 ������ ����������
 ldi	temp,20
 sts	Digit+1,Temp						; ������ � 2 ������ ����������
 ldi	temp,20
 sts	Digit+2,Temp						; ������ � 3 ������ ����������
 ldi	temp,24
 sts	Digit+3,Temp						; ������ � 4 ������ ����������
 ldi	temp,25
 sts	Digit+4,Temp						; ������ � 5 ������ ����������
 ldi	temp,26
 sts	Digit+5,Temp						; ������ � 6 ������ ����������

 rcall	d300ms

 ldi	temp,20								; �������� ������� - " "
 sts	Digit  ,Temp						; ������ � 1 ������ ����������
 ldi	temp,20
 sts	Digit+1,Temp						; ������ � 2 ������ ����������
 ldi	temp,24
 sts	Digit+2,Temp						; ������ � 3 ������ ����������
 ldi	temp,25
 sts	Digit+3,Temp						; ������ � 4 ������ ����������
 ldi	temp,26
 sts	Digit+4,Temp						; ������ � 5 ������ ����������
 ldi	temp,27
 sts	Digit+5,Temp						; ������ � 6 ������ ����������

 rcall	d300ms

 ldi	temp,20								; �������� ������� - " "
 sts	Digit  ,Temp						; ������ � 1 ������ ����������
 ldi	temp,24
 sts	Digit+1,Temp						; ������ � 2 ������ ����������
 ldi	temp,25
 sts	Digit+2,Temp						; ������ � 3 ������ ����������
 ldi	temp,26
 sts	Digit+3,Temp						; ������ � 4 ������ ����������
 ldi	temp,27
 sts	Digit+4,Temp						; ������ � 5 ������ ����������
 ldi	temp,28
 sts	Digit+5,Temp						; ������ � 6 ������ ����������

 rcall	d300ms

 ldi	temp,24								; �������� ������� - " "
 sts	Digit  ,Temp						; ������ � 1 ������ ����������
 ldi	temp,25
 sts	Digit+1,Temp						; ������ � 2 ������ ����������
 ldi	temp,26
 sts	Digit+2,Temp						; ������ � 3 ������ ����������
 ldi	temp,27
 sts	Digit+3,Temp						; ������ � 4 ������ ����������
 ldi	temp,28
 sts	Digit+4,Temp						; ������ � 5 ������ ����������
 ldi	temp,29
 sts	Digit+5,Temp						; ������ � 6 ������ ����������

 rcall	d500ms								; ������� �� 3 �������
 rcall	d500ms
 rcall	d500ms
 rcall	d500ms
 rcall	d500ms
 rcall	d500ms


;******************************************************************************
;******************************************************************************
;**                                                                          **
;**                                                                          **
;**                     �������� ���� ������ ���������                       **
;**                                                                          **
;**                                                                          **
;******************************************************************************
;******************************************************************************
 rjmp	MAIN_LOOP_COL

LOOP_COL_OK:
 rcall	d13ms
 sbis	PINC,4
 rjmp	LOOP_COL_OK
 rcall	d500ms

MAIN_LOOP_COL:
 rcall d100ms

 sbis	PINC,3								; ��������� ������� ������ "-1" 
 rcall	COUNT_MINUS							; ���� ������, �� ��������� � ��������� COUNT_M1

 sbis	PINC,4								; ��������� ������� ������ "OK" 
 rjmp	LOOP_CENA_OK						; ���� ������, �� ���������� ���� �� �������

 sbis	PINC,5								; ��������� ������� ������ "+1" 
 rcall	COUNT_PLUS							; ���� ������, �� ��������� � ��������� COUNT_P1

 sbis	PIND,1								; ���� �� 1-�� �������
 rcall	COUNT_INC							; ���� ��������, �� ��������� � ��������� COUNT_INC

 rcall	DISPLAY_COL							; ���������� ���������� ����� �� �������

 rjmp	MAIN_LOOP_COL						; ������ ��������� �����



LOOP_CENA_OK:
 rcall	d13ms
 sbis	PINC,4
 rjmp	LOOP_CENA_OK
 rcall	d500ms

MAIN_LOOP_CENA:
 rcall d100ms

 sbis	PINC,3								; ��������� ������� ������ "-1" 
 rcall	COUNT_MINUS							; ���� ������, �� ��������� � ��������� COUNT_M1

 sbis	PINC,4								; ��������� ������� ������ "OK" 
 rjmp	LOOP_COL_OK							; ���� ������, �� ��������� � ��������� CENA_COL

 sbis	PINC,5								; ��������� ������� ������ "+1" 
 rcall	COUNT_PLUS							; ���� ������, �� ��������� � ��������� COUNT_P1

 sbis	PIND,1								; ���� �� 1-�� �������
 rcall	COUNT_INC							; ���� ��������, �� ��������� � ��������� COUNT_INC

 rcall	DISPLAY_CENA						; ���������� ���������� ����� �� �������

 rjmp	MAIN_LOOP_CENA						; ������ ��������� �����








;******************************************************************************
;******************************************************************************
;**                                                                          **
;**                                                                          **
;**                                 ���������                                **
;**                                                                          **
;**                                                                          **
;******************************************************************************
;******************************************************************************


;********************************************************************************
;*																				*
;*              ������� ���������� � ��������� ��������� �����					*
;*																				*
;********************************************************************************

COUNT_INC:
 rcall	d13ms								; ��������� ������ ������������
 sbic	PIND,1
ret											; ���� ������������ ������, �� ������ �������

COUNT_INC_ON:
 rcall	d20ms
 sbis	PIND,1								; ���� ������ ������� �� �����
 rjmp	COUNT_INC_ON
 inc	count								; ����������� �������� �������� �����

 clr	temp								; ����������� ����� ��������� �����
 add	cenaL,cena_copii
 adc	cenaH,temp

ret





;********************************************************************************
;*																				*
;*						��������� ���������� ��������� �����					*
;*																				*
;********************************************************************************

COUNT_MINUS:
 rcall	d13ms								; ��������� ������ ������������
 sbic	PINC,3
ret											; ���� ������������ ������, �� ������ �������

 rcall	d50ms								; ��������� ������ ������������
 ldi	temp,5
 sbis	PINC,5								; ��������� ������� ���� ������ ������������
 rjmp	CENA_COPII_PROG
  
 dec	count								; ����������� �������� �������� �����
 rcall	DISPLAY_COL							; ���������� ���������� ����� �� �������

 clr	temp								; ��������� ����� ��������� �����
 sub	cenaL,cena_copii
 sbc	cenaH,temp

COUNT_MINUS_ON:
 rcall	d20ms
 sbis	PINC,3								; ���� ������ ������� �� �����
 rjmp	COUNT_MINUS_ON
 rcall	d13ms
ret





;********************************************************************************
;*																				*
;*						����������� ���������� ��������� �����					*
;*																				*
;********************************************************************************

COUNT_PLUS:
 rcall	d13ms								; ��������� ������ ������������
 sbic	PINC,5
ret											; ���� ������������ ������, �� ������ �������

 rcall	d50ms								; ��������� ������ ������������
 ldi	temp,5
 sbis	PINC,3								; ��������� ������� ���� ������ ������������
 rjmp	CENA_COPII_PROG

 inc	count								; ����������� �������� �������� �����
 rcall	DISPLAY_COL							; ���������� ���������� ����� �� �������

 clr	temp								; ����������� ����� ��������� �����
 add	cenaL,cena_copii
 adc	cenaH,temp

COUNT_PLUS_ON:
 rcall	d20ms
 sbis	PINC,5								; ���� ������ ������� �� �����
 rjmp	COUNT_PLUS_ON
 rcall	d13ms
ret





;********************************************************************************
;*																				*
;*                  ���������� ����� ��������� ��������� �����                  *
;*																				*
;********************************************************************************

DISPLAY_CENA:
 mov	adwH,cenaH							; ��������� ����� � ��������
 mov	adwL,cenaL							;
 rcall	Bin2ToBCD5							; �������� � ���������� ������� 

 lds	temp,BCD
 cpi	temp,0								; ��������� ������ ������ �� ����
 breq	CENA_COL_1000						;  ���� ����� 0, �� ����� ������ 
 
 lds	temp,BCD							; ��������� �������� 1 �������
 sts	Digit,temp

 lds	temp,BCD+1							; ��������� �������� 2 �������
 sts	Digit+1,temp

 lds	temp,BCD+2							; ��������� �������� 3 �������
 ldi	temp1,10
 add	temp,temp1
 sts	Digit+2,temp

 lds	temp,BCD+3							; ��������� �������� 4 �������
 sts	Digit+3,temp

 lds	temp,BCD+4							; ��������� �������� 5 �������
 sts	Digit+4,temp

 ldi	temp,24
 sts	Digit+5,temp

ret

CENA_COL_1000:
 ldi	temp,20
 sts	Digit,temp
 sts	Digit+1,temp

 lds	temp,BCD+1
 cpi	temp,0								; ��������� ������ ������ �� ����
 breq	CENA_COL_100						;  ���� ����� 0, �� ����� ������ 
 lds	temp,BCD+1							; ��������� �������� 2 �������
 sts	Digit+1,temp

CENA_COL_100:
 lds	temp,BCD+2							; ��������� �������� 3 �������
 ldi	temp1,10
 add	temp,temp1
 sts	Digit+2,temp

 lds	temp,BCD+3							; ��������� �������� 4 �������
 sts	Digit+3,temp

 lds	temp,BCD+4							; ��������� �������� 5 �������
 sts	Digit+4,temp

 ldi	temp,24
 sts	Digit+5,temp

ret





;********************************************************************************
;*																				*
;*						���������� ���������� ��������� �����					*
;*																				*
;********************************************************************************

DISPLAY_COL:
 clr	adwH
 mov	adwL,count							; ������� �� ������� ���������� ��������� �����
 rcall	Bin2ToBCD3							; �������� � ���������� ������� 

 ldi	temp,20								; ��������� ������ ������ � ����������
 clr	temp0								; ���������� �������� ��������
 lds	temp1,BCD+2							; ��������� � 0 
 cpse	temp1,temp0							;  ���� ������=0, �� ����� �� �������� ����
 lds	temp,BCD+2
 sts	Digit,temp

 mov	temp,count
 cpi	temp,10								; ���� ����� ������ 10, ����� ���������� ������� ������
 brsh	MOOR100
 ldi	temp,20								; ��������� ������ ������ � ����������
 clr	temp0								; ���������� �������� ��������
 lds	temp1,BCD+3							; ��������� � 0 
 cpse	temp1,temp0							;  ���� ������=0, �� ����� �� �������� ����
MOOR100:
 lds	temp,BCD+3
 sts	Digit+1,temp

 lds	temp,BCD+4							; ��������� �������� �������� �������
 sts	Digit+2,temp
 ldi	temp,34
 sts	Digit+3,temp
 ldi	temp,32
 sts	Digit+4,temp
 ldi	temp,35
 sts	Digit+5,temp

ret





;********************************************************************************
;*																				*
;*           ��������� � ���������� � EEPROM ��������� ����� �����              *
;*																				*
;********************************************************************************

CENA_COPII_PROG:
 rcall	d500ms
 sbic	PINC,3
 ret
 sbic	PINC,5
 ret
 dec	temp
 brne	CENA_COPII_PROG

 ldi	temp,20
 sts	Digit,temp
 ldi	temp,30
 sts	Digit+1,temp
 ldi	temp,31
 sts	Digit+2,temp
 ldi	temp,32
 sts	Digit+3,temp
 ldi	temp,33
 sts	Digit+4,temp
 ldi	temp,20
 sts	Digit+5,temp

PROG_ENTER:
 rcall	d13ms								; ��������� ������ ������������
 sbic	PINC,4								; ��������� ������� ����� OK
 rjmp	PROG_ENTER


CENA_CHANGE_PR:
 rcall	d50ms
 sbis	PINC,4
 rjmp	CENA_CHANGE_PR

CENA_CHANGE:
 rcall	d100ms
 
 clr	adwH								; ��������� ����� � ��������
 mov	adwL,cena_copii						;
 rcall	Bin2ToBCD3							; �������� � ���������� ������� 

 ldi	temp,20
 sts	Digit,temp
 sts	Digit+1,temp
 
 lds	temp,BCD+2							; ��������� �������� 3 �������
 ldi	temp1,10
 add	temp,temp1
 sts	Digit+2,temp

 lds	temp,BCD+3							; ��������� �������� 4 �������
 sts	Digit+3,temp

 lds	temp,BCD+4							; ��������� �������� 5 �������
 sts	Digit+4,temp

 ldi	temp,24
 sts	Digit+5,temp

 sbis	PINC,3								; ��������� ������� ������ "-1" 
 rcall	CENA_COPII_MINUS					; ���� ������, �� ��������� � ��������� COUNT_M1

 sbis	PINC,5								; ��������� ������� ������ "+1" 
 rcall	CENA_COPII_PLUS						; ���� ������, �� ��������� � ��������� COUNT_M1

 sbic	PINC,4								; ��������� ������� ����� OK
 rjmp	CENA_CHANGE
CENA_OK:
 rcall	d13ms
 sbis	PINC,4								; ���� ������ ������ OK, ����� ��������� ����� �������� ����
 rjmp	CENA_OK
 
 rcall	d100ms
 cli										; ��������� ���������� �� ����� ������ � ������ EEPROM
EEPROM_write:
 sbic	EECR,EEWE
 rjmp	EEPROM_write						; ���� ���������� ���������� ������, ���� ����
 clr	temp
 out	EEARH,temp
 ldi	temp,0x05
 out	EEARL,temp							; ������� ����� � ������� ������
 out	EEDR,cena_copii						; ������� ������ � ������� ������
 sbi	EECR,EEMWE							; ���������� ���� EEMWE
 sbi	EECR,EEWE							; ������ ������ � EEPROM
 rcall	d100ms
 sei 

 ldi	temp,20
 sts	Digit,temp
 ldi	temp,26
 sts	Digit+1,temp
 ldi	temp,36
 sts	Digit+2,temp
 ldi	temp,37
 sts	Digit+3,temp
 ldi	temp,25
 sts	Digit+4,temp
 ldi	temp,20
 sts	Digit+5,temp

CENA_COPII_SAVE:
 rcall	d100ms
 sbic	PINC,4
 rjmp	CENA_COPII_SAVE

 clr	count
 clr	cenaL
 clr	cenaH

 rjmp	MAIN_LOOP_COL


CENA_COPII_MINUS:
 rcall	d13ms
 sbis	PINC,4
 rjmp	CENA_COPII_MINUS	

 dec	cena_copii							; ��������� ��������� ����� ����� �� 5 ����
 dec	cena_copii
 dec	cena_copii
 dec	cena_copii
 dec	cena_copii 
 
 rcall	d100ms
ret



CENA_COPII_PLUS:
 rcall	d13ms
 sbis	PINC,5
 rjmp	CENA_COPII_PLUS	

 ldi	temp,5
 add	cena_copii,temp						; ����������� ��������� ����� ����� �� 5 ����

 rcall	d100ms
ret

;******************************************************************************
;*                                                                            *
;*      �������������� ��������� ����� � ��� 7-����������� ����������         *
;*���������� d �������� ���������� ��� ��������������.��������� ���������� � d*
;******************************************************************************
    
	;   ��������: temp2, d, r0

DECODER:
 ldi	ZL,Low(DigitFont*2)					; ������������� �������
 ldi	ZH,High(DigitFont*2)
 ldi	temp2,0								; ����������� ����������
 add	ZL,d								; � 0-�� ������ �������
 adc	ZH,temp2
 lpm										; �������� ��������
 mov	d,r0
ret

;------------------------------------------------------------------------------
;   ������� ���������������
DigitFont:
;     gchdefab   gchdefab                                            a
.db 0b01011111,0b01000001                   ; 0, 1                 f   b
.db 0b10011011,0b11010011                   ; 2, 3                   g
.db 0b11000101,0b11010110                   ; 4, 5                 e   c
.db 0b11011110,0b01000011                   ; 6, 7                   d   .h
.db 0b11011111,0b11010111                   ; 8, 9
.db 0b01111111,0b01100001                   ; 0., 1.
.db 0b10111011,0b11110011                   ; 2., 3.
.db 0b11100101,0b11110110                   ; 4., 5.
.db 0b11111110,0b01100011                   ; 6., 7.
.db 0b11111111,0b11110111                   ; 8., 9.

.db 0b00000000,0b10000000                   ; " ", -
.db 0b00010000,0b00000010                   ; "_", -
.db 0b00011100,0b10011110                   ; L, E
.db 0b11010110,0b11001101					; S, H 
.db 0b01000001,0b00011110					; I, C
.db 0b10001111,0b10001000					; P, r
.db 0b11011000,0b11010111					; o, g
.db 0b10011000,0b00001100					; c, l
.db 0b11001111,0b01011101					; A, V
	; ��� ������ ��������-1, 0-�������





;******************************************************************************
;*                                                                            *
;*                      ����� ��������� �� ���������                          *
;*                     ���������� ������ � ������� HC595                      *
;*      ���������� d �������� ������ ��� ������ �� ������� ����������         *
;******************************************************************************

    ;   ��������: temp2, d

LED_SEND: 
 ldi	temp2,8								; �������� 8-�� ��������
 cbi	PORTB,1								; ���������� ������ Load
 cbi	PORTB,2								; ���������� ������ CLK 
LED_LOOP1:                                  ;
 cbi	PORTB,2								; ���������� ������ CLK 
 sbrc	d,7									; ��������� ������� ���
 sbi	PORTB,3								;  �������� ��������������
 sbrs	d,7									;  �������� � �����
 cbi	PORTB,3								;  ������� Data
 lsl	d									; ����� ����� (��������� ���)
 sbi	PORTB,2								; ������ ���� �� ������ CLK
 dec	temp2								; �������� ����������� �����
 brne	LED_LOOP1
 cbi	PORTB,2
ret




;***********************************************************************************
;*                                                                                 *
;*                                                                                 *
;*            �������������� ��������� ����� � ����� ��� ����������                *
;*                                                                                 *
;*                                                                                 *
;***********************************************************************************

;   ���������� ����������: temp, temp1, adwL, adwH, mulL, mulH
                          
; Bin2ToBcd5
; ==========
; converts a 16-bit-binary to a 5-digit-BCD
; In: 16-bit-binary in adwH,adwL
; Out: 5-digit-BCD
; Used registers:temp
; Called subroutines: Bin2ToDigit
;
Bin2ToBCD5:
 ldi	temp,high(10000)						; ��������� 10000 ������
 mov	mulH,temp
 ldi	temp,low(10000)
 mov	mulL,temp
 rcall	Bin2ToDigit							; ���������, ��������� � ���������� temp
 sts	BCD,temp							; ���� �� ����, ����� ���������� ���������
Bin2ToBCD4:
 ldi	temp,high(1000)						; ��������� 1000 ������
 mov	mulH,temp
 ldi	temp,low(1000)
 mov	mulL,temp
 rcall	Bin2ToDigit							; ���������
 sts	BCD+1,temp							; ��������� � ���������� temp 
Bin2ToBCD3:
 clr	mulH								;  ��������� 100 ������
 ldi	temp,100
 mov	mulL,temp
 rcall	Bin2ToDigit							; ���������
 sts	BCD+2,temp							; ��������� � ���������� temp
Bin2ToBCD2:
 clr	mulH								; ��������� 10 ������
 ldi	temp,10
 mov	mulL,temp
 rcall	Bin2ToDigit							; ���������
 sts	BCD+4,adwL							; ������� �������� � adiw0
 sts	BCD+3,temp							; ��������� � ���������� temp
ret

; Bin2ToDigit
; ===========
; converts one decimal digit by continued subraction of a binary coded decimal
; Used by: Bin2ToBcd5
; In: 16-bit-binary in adw1,adw0, binary coded decimal in mul0,mul1
; Out: Result in temp
; Used registers: adiw0,adiw1, mul0,mul1, temp
; Called subroutines: -

Bin2ToDigit:
 clr	temp								; digit count is zero
Bin2ToDigita:
 cp		adwH,mulH							; Number bigger than decimal?
 brcs	Bin2ToDigitc						; MSB smaller than decimal
 brne	Bin2ToDigitb						; MSB bigger than decimal
 cp		adwL,mulL							; LSB bigger or equal decimal
 brcs	Bin2ToDigitc						; LSB smaller than decimal
Bin2ToDigitb:
 sub	adwL,mulL							; Subtract LSB decimal
 sbc	adwH,mulH							; Subtract MSB decimal
 inc	temp								; Increment digit count
 rjmp	Bin2ToDigita						; Next loop
Bin2ToDigitc:
ret											; done













;********************************************************************************
;**                                                                            **
;**                                                                            **
;**      ��������� ���������� - 0x0009 - ������������ �������/�������� �0      **
;**                                                                            **
;**                                                                            **
;**                                                                            **
;********************************************************************************

aOVF0:

 push	temp2
 push	r0
 push	ZL
 push	ZH
 in		temp2,SREG
 push	temp2
   
 inc	DigPoz								; ����������� ������ ���������
 cpi	DigPoz,6							; ���� ������������ 7 ������, ��
 brne	NOT_CLEAR
 clr	DigPoz								;  ��������� ��������� ��������� (0).
NOT_CLEAR:
 lds	d,Digit+5
 cpi	DigPoz,0
 breq	VIVOD1
                                            ; �������� 5 ����� ��� ���������� 
 lds	d,Digit+4
 cpi	DigPoz,1
 breq	VIVOD1
                                            ; �������� 4 ����� ��� ���������� 
 lds	d,Digit+3
 cpi	DigPoz,2
 breq	VIVOD1
                                            ; �������� 3 ����� ��� ���������� 
 lds	d,Digit+2
 cpi	DigPoz,3
 breq	VIVOD1
                                            ; �������� 2 ����� ��� ���������� 
 lds	d,Digit+1
 cpi	DigPoz,4
 breq	VIVOD1
                                            ; �������� 1 ����� ��� ���������� 
 lds	d,Digit

VIVOD1:
 rcall	DECODER
 rcall	LED_SEND							; ������� ����� � ������� ������ ���������� HC595

	; ������� � ���� ����� ��� ����������� HC138 ������� ����������
 cbi	PORTD,6								; ������������� ���� � 0
 sbrc	DigPoz,0							; ���� ��� �������� ����������, ��
 sbi	PORTD,6								;  ������������� ��� ����� � 1

 cbi	PORTD,7								; ������������� ���� � 0
 sbrc	DigPoz,1							; ���� ��� �������� ����������, ��
 sbi	PORTD,7								;  ������������� ��� ����� � 1

 cbi	PORTB,0								; ������������� ���� � 0
 sbrc	DigPoz,2							; ���� ��� �������� ����������, ��
 sbi	PORTB,0								;  ������������� ��� ����� � 1

 sbi	PORTB,1								; ����� ������ Load ��� ������ �������� �� ����� 
 nop
 cbi	PORTB,1								;  �������� HC595


 pop	temp2								; ��������������� ������� �������� ����������
 out	SREG,temp2
 pop	ZH
 pop	ZL
 pop	r0
 pop	temp2


reti












;************************************************************************************
;************************************************************************************
;**                                                                                **
;**                                                                                **
;**                 ������������ �������� ��� ������� ������ 4���                  **
;**                                                                                **
;**                                                                                **
;************************************************************************************
;************************************************************************************
;-------------------------------------------------------------------------
;	�������� �� 0,25�� (250���)

d025ms:
 ldi YL,low(248)                            ; �������� � YH:YL ��������� 497
 ldi YH,high(248)

d025_1:
 sbiw YL,1                                  ; ��������� �� ����������� YH:YL
                                            ;  �������
 brne d025_1                                ; ���� ���� Z<>0 (��������� ����������
                                            ;  ���������� ������� �� ����� ����), ��
									        ;  ������� �� ����� d05_1
ret





;-------------------------------------------------------------------------
;	�������� �� 0,5�� (500���)

d05ms:
 ldi	YL,low(497)							; �������� � YH:YL ��������� 497
 ldi	YH,high(497)

d05_1:
 sbiw	YL,1								; ��������� �� ����������� YH:YL �������
 brne	d05_1								; ���� ���� Z<>0 (��������� ����������
											;  ���������� ������� �� ����� ����), ��
											;  ������� �� ����� d05_1
ret





;-------------------------------------------------------------------------
;	�������� 1 ms

d1ms:  
 ldi	temp,5
m2:
 ldi	temp1,255
m3:
 dec	temp1
 brne	m3
 dec	temp
 brne	m2
ret





;-------------------------------------------------------------------------
;	�������� 2,8 ms

d2_8ms:  
 ldi	temp,15
m:
 ldi	temp1,255
m1:
 dec	temp1
 brne	m1
 dec	temp
 brne	m
ret





;-------------------------------------------------------------------------
;	�������� 13 ms

d13ms:  
 ldi	temp,70								; 100-19ms, 70-13ms
ms:
 ldi	temp1,255
ms1:
 dec	temp1
 brne	ms1
 dec	temp
 brne	ms
ret





;-------------------------------------------------------------------------
;	�������� 20 ms

d20ms:  
 ldi	temp,100
m20s:
 ldi	temp1,255
m20s1:
 dec	temp1
 brne	m20s1
 dec	temp
 brne	m20s
ret





;-------------------------------------------------------------------------
;	�������� �� 50��

d50ms:
 ldi	temp,100

d50_1:
 rcall	d05ms								; ����� ������������ �������� �� 0,5��
 dec	temp								; ��������� ������� �� temp
 brne	d50_1								; ���� ��������� �� ����� ����, ������� �� ����� d50_1
ret





;-------------------------------------------------------------------------
;	�������� �� 100��

d100ms:
 ldi	temp,200							; �������� � temp ��������� 200

d100_1:
 rcall	d05ms								; ����� ������������ �������� �� 0,5��
 dec	temp								; ��������� ������� �� temp
 brne	d100_1								; ���� ��������� �� ����� ����, ������� �� ����� d100_1
ret





;-------------------------------------------------------------------------
;	�������� �� 300��

d300ms:
 ldi	XL,low(700)							; �������� � YH:YL ��������� 700
 ldi	XH,high(700)

d300_1:
 rcall	d05ms								; ����� ������������ �������� �� 0,5��
 sbiw	XL,1								; ��������� ������� �� ����������� XH:XL
 brne	d300_1								; ���� ��������� �� ����� ����, ������� �� ����� d500_1
ret





;-------------------------------------------------------------------------
;	�������� �� 500��

d500ms:
 ldi	XL,low(1000)						; �������� � YH:YL ��������� 1000
 ldi	XH,high(1000)

d500_1:
 rcall	d05ms								; ����� ������������ �������� �� 0,5��
 sbiw	XL,1								; ��������� ������� �� ����������� XH:XL
 brne	d500_1								; ���� ��������� �� ����� ����, ������� �� ����� d500_1
ret





;******************************************************************************

.exit                                       ; ����� ���������
