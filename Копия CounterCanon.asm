;*******************************************************************************
;*******************************************************************************
;**                                                                           **
;**             Программа для счетчика копий для копира Canon NP.             **
;**                                                                           **
;**               тип МК ATmega8 Тактовая частота 4.00 МГ                     **
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
 Где знгачение=0 ставим галочку, где значение=1 оставляем пусто.
*/

.include "m8def.inc"
 
    
	; определяем переменные

.def	mulL=r0
.def	mulH=r1
.def	adwL=r2
.def	adwH=r3
.def	count=r4							; Счетчик количества копий
.def	cenaL=r5							; Цена (младший разряд)
.def	cenaH=r6							; Цена (старший разряд)
.def	cena_copii=r7						; Цена одной копии

.def	temp0=r16
.def	temp=r17
.def	temp1=r18
.def	temp2=r19
.def	d=r20
.def	DigPoz=r21

	; это сегмент данных. В нем выделяется оперативная память

.dseg

Digit:		.byte 6
BCD:		.byte 5





.cseg

; ***** INTERRUPT VECTORS ************************************************
.org	$000
		rjmp RESET                             ; Обработка сброса
.org	$0001
		rjmp aINT0                              ; 0x0001 - Внешнее прерывание 0
.org	$0002
		rjmp aINT1                              ; 0x0002 - Внешнее прерывание 1
.org	$0003
		rjmp aOC2                               ; 0x0003 - Совпадение таймера/счетчика Т2
.org	$0004
		rjmp aOVF2                              ; 0x0004 - Переполнение таймера/счетчика Т2
.org	$0005
		rjmp aICP1                              ; 0x0005 - Захват таймера/счетчика Т1
.org	$0006
		rjmp aOC1A                              ; 0x0006 - Совпадение А таймера/счетчика Т1
.org	$0007
		rjmp aOC1B                              ; 0x0007 - Совпадение В таймера/счетчика Т1
.org	$0008
		rjmp aOVF1                              ; 0x0008 - Переполнение таймера/счетчика Т1
.org	$0009
		rjmp aOVF0                              ; 0x0009 - Переполнение таймера/счетчика Т0
.org	$000a
		rjmp aSPI                               ; 0x000a - Передача по SPI завершена
.org	$000b
		rjmp aURXC                              ; 0x000b - USART, Прием завершен
.org	$000c
		rjmp aUDRE                              ; 0x000c - Регистр данных USART пуст
.org	$000d
		rjmp aUTXC                              ; 0x000d - USART, Передача завершена
.org	$000e
		rjmp aADCC                              ; 0x000e - Преобразование ADC завершено
.org	$000f
		rjmp aERDY                              ; 0x000f - EEPROM готов
.org	$0010
		rjmp aACI                               ; 0x0010 - Analog Comparator
.org	$0011
		rjmp aTWI                               ; 0x0011 - Прерывание от 2-wire Serial Interface
.org	$0012
		rjmp aSPMR                              ; 0x0012 - Готовность SPM





aINT0:                              ; 0x0001 - Внешнее прерывание 0
aINT1:                              ; 0x0002 - Внешнее прерывание 1
aOC2:                               ; 0x0003 - Совпадение таймера/счетчика Т2
aOVF2:                              ; 0x0004 - Переполнение таймера/счетчика Т2
aICP1:                              ; 0x0005 - Захват таймера/счетчика Т1
aOC1A:                              ; 0x0006 - Совпадение А таймера/счетчика Т1
aOC1B:                              ; 0x0007 - Совпадение В таймера/счетчика Т1
aOVF1:                              ; 0x0008 - Переполнение таймера/счетчика Т1
;aOVF0:                              ; 0x0009 - Переполнение таймера/счетчика Т0
aSPI:                               ; 0x000a - Передача по SPI завершена
aURXC:                              ; 0x000b - USART, Прием завершен
aUDRE:                              ; 0x000c - Регистр данных USART пуст
aUTXC:                              ; 0x000d - USART, Передача завершена
aADCC:                              ; 0x000e - Преобразование ADC завершено
aERDY:                              ; 0x000f - EEPROM готов
aACI:                               ; 0x0010 - Analog Comparator
aTWI:                               ; 0x0011 - Прерывание от 2-wire Serial Interface
aSPMR:                              ; 0x0012 - Готовность SPM



RESET:

	; Инициализация стека 
 ldi 	temp, LOW(RAMEND)
 out	spl, Temp
 ldi 	temp, HIGH(RAMEND)
 out	sph, Temp



	; Инициализация портов
		
 ldi	temp,0b00111111                       ; инициализация порта B
 out	DDRB,temp

 ldi	temp,0b00000000                       ; инициализация порта C
 out	DDRC,temp

 ldi	temp,0b11000000                       ; инициализация порта D
 out	DDRD,temp
 
 ldi	temp,0b00000000                       ; запись сигналов на вывод порта B
 out	PORTB,temp      
        
 ldi	temp,0b00000000                       ; запись сигналов на вывод порта C
 out	PORTC,temp      

 ldi	temp,0b00000000                       ; запись сигналов на вывод порта D
 out	PORTD,temp      



;------------------------------------------------------------------------------
     ; Настройка таймера/счетчика T0 в режиме переполнения
 ldi Temp,0b00000010
    ; 7 - 
    ; 6 - 
    ; 5 - 
    ; 4 - 
    ; 3 - 
    ; 2 - CS02 - 1 \
    ; 1 - CS01 - 0  _ управление тактовым сигналом (clk/256)
    ; 0 - CS00 - 0 /
 out TCCR0,Temp

 ldi Temp,0b00000001                        ; разрешить прерывание по "Захват"
    ; 7 - OCIE2 флаг по разрешению прерывания по "совпадению"
    ; 6 - TOIE2 флаг по разрешению прерывания по реоеполнению таймера/счетчика Т1
    ; +5 - TICIE1 флаг по разрешению прерывания по "Захват" таймера счетчика Т1
    ; 4 - OCIE1A флаг по разрешению прерывания по "совпадению А"
    ; 3 - OCIE1B флаг по разрешению прерывания по "совпадению В"
    ; 2 - TOIE1 флаг по разрешению прерывания по переполнению таймера/счетчика Т1
    ; 1 - 
    ; +0 - TOIE0 флаг по разрешению прерывания по переполнению таймера/счетчика Т0
 out TIMSK,Temp



;******************************************************************************
;*                                                                            *
;*                                                                            *
;*         Подготовка периферии и инициализация переменных программы          *
;*                                                                            *
;*                                                                            *
;******************************************************************************

    ; Инициализация и очистка индикатора
                                            ;  Digit +1 +2 +3 +4 +5
                                            ;      8__8__8__8__8__8 

 ldi	temp,20								; Загрузка символа - " "
 sts	Digit  ,Temp						; Запись в 1 разряд индикатора
 ldi	temp,20
 sts	Digit+1,Temp						; Запись в 2 разряд индикатора
 ldi	temp,20
 sts	Digit+2,Temp						; Запись в 3 разряд индикатора
 ldi	temp,20
 sts	Digit+3,Temp						; Запись в 4 разряд индикатора
 ldi	temp,20
 sts	Digit+4,Temp						; Запись в 5 разряд индикатора
 ldi	temp,20
 sts	Digit+5,Temp						; Запись в 6 разряд индикатора

	; Сброс переменных

 clr	DigPoz
 clr	count
 
 clr	cenaL
 clr	cenaH

EEPROM_read:
 sbic	EECR,EEWE							; Ждать завершения предыдущей записи, если была
 rjmp	EEPROM_read
 clr	temp
 out	EEARH,temp
 ldi	temp,0x05
 out	EEARL,temp							; Заносим адрес в регистр адреса
 sbi	EECR,EERE							; Начать чтение
 in		cena_copii,EEDR						; Сохраняем стоимость одной копии из EEPROM

 sei                                        ; разрешаем прерывание

 rcall	d500ms
 rcall	d500ms

	; Выводим бегущую строку "LESHIC"
 ldi	temp,20								; Загрузка символа - " "
 sts	Digit  ,Temp						; Запись в 1 разряд индикатора
 ldi	temp,20
 sts	Digit+1,Temp						; Запись в 2 разряд индикатора
 ldi	temp,20
 sts	Digit+2,Temp						; Запись в 3 разряд индикатора
 ldi	temp,20
 sts	Digit+3,Temp						; Запись в 4 разряд индикатора
 ldi	temp,20
 sts	Digit+4,Temp						; Запись в 5 разряд индикатора
 ldi	temp,24
 sts	Digit+5,Temp						; Запись в 6 разряд индикатора

 rcall	d300ms

 ldi	temp,20								; Загрузка символа - " "
 sts	Digit  ,Temp						; Запись в 1 разряд индикатора
 ldi	temp,20
 sts	Digit+1,Temp						; Запись в 2 разряд индикатора
 ldi	temp,20
 sts	Digit+2,Temp						; Запись в 3 разряд индикатора
 ldi	temp,20
 sts	Digit+3,Temp						; Запись в 4 разряд индикатора
 ldi	temp,24
 sts	Digit+4,Temp						; Запись в 5 разряд индикатора
 ldi	temp,25
 sts	Digit+5,Temp						; Запись в 6 разряд индикатора

 rcall	d300ms

 ldi	temp,20								; Загрузка символа - " "
 sts	Digit  ,Temp						; Запись в 1 разряд индикатора
 ldi	temp,20
 sts	Digit+1,Temp						; Запись в 2 разряд индикатора
 ldi	temp,20
 sts	Digit+2,Temp						; Запись в 3 разряд индикатора
 ldi	temp,24
 sts	Digit+3,Temp						; Запись в 4 разряд индикатора
 ldi	temp,25
 sts	Digit+4,Temp						; Запись в 5 разряд индикатора
 ldi	temp,26
 sts	Digit+5,Temp						; Запись в 6 разряд индикатора

 rcall	d300ms

 ldi	temp,20								; Загрузка символа - " "
 sts	Digit  ,Temp						; Запись в 1 разряд индикатора
 ldi	temp,20
 sts	Digit+1,Temp						; Запись в 2 разряд индикатора
 ldi	temp,24
 sts	Digit+2,Temp						; Запись в 3 разряд индикатора
 ldi	temp,25
 sts	Digit+3,Temp						; Запись в 4 разряд индикатора
 ldi	temp,26
 sts	Digit+4,Temp						; Запись в 5 разряд индикатора
 ldi	temp,27
 sts	Digit+5,Temp						; Запись в 6 разряд индикатора

 rcall	d300ms

 ldi	temp,20								; Загрузка символа - " "
 sts	Digit  ,Temp						; Запись в 1 разряд индикатора
 ldi	temp,24
 sts	Digit+1,Temp						; Запись в 2 разряд индикатора
 ldi	temp,25
 sts	Digit+2,Temp						; Запись в 3 разряд индикатора
 ldi	temp,26
 sts	Digit+3,Temp						; Запись в 4 разряд индикатора
 ldi	temp,27
 sts	Digit+4,Temp						; Запись в 5 разряд индикатора
 ldi	temp,28
 sts	Digit+5,Temp						; Запись в 6 разряд индикатора

 rcall	d300ms

 ldi	temp,24								; Загрузка символа - " "
 sts	Digit  ,Temp						; Запись в 1 разряд индикатора
 ldi	temp,25
 sts	Digit+1,Temp						; Запись в 2 разряд индикатора
 ldi	temp,26
 sts	Digit+2,Temp						; Запись в 3 разряд индикатора
 ldi	temp,27
 sts	Digit+3,Temp						; Запись в 4 разряд индикатора
 ldi	temp,28
 sts	Digit+4,Temp						; Запись в 5 разряд индикатора
 ldi	temp,29
 sts	Digit+5,Temp						; Запись в 6 разряд индикатора

 rcall	d500ms								; Задржка на 3 секунды
 rcall	d500ms
 rcall	d500ms
 rcall	d500ms
 rcall	d500ms
 rcall	d500ms


;******************************************************************************
;******************************************************************************
;**                                                                          **
;**                                                                          **
;**                     Основной цикл работы программы                       **
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

 sbis	PINC,3								; проверяем нажатия кнопки "-1" 
 rcall	COUNT_MINUS							; если нажата, то переходим к программе COUNT_M1

 sbis	PINC,4								; проверяем нажатия кнопки "OK" 
 rjmp	LOOP_CENA_OK						; если нажата, то отображаем цену на дисплее

 sbis	PINC,5								; проверяем нажатия кнопки "+1" 
 rcall	COUNT_PLUS							; если нажата, то переходим к программе COUNT_P1

 sbis	PIND,1								; Вход от 1-го датчика
 rcall	COUNT_INC							; если сработал, то переходим к программе COUNT_INC

 rcall	DISPLAY_COL							; Отображаем количество копий на дисплее

 rjmp	MAIN_LOOP_COL						; повтор основного цикла



LOOP_CENA_OK:
 rcall	d13ms
 sbis	PINC,4
 rjmp	LOOP_CENA_OK
 rcall	d500ms

MAIN_LOOP_CENA:
 rcall d100ms

 sbis	PINC,3								; проверяем нажатия кнопки "-1" 
 rcall	COUNT_MINUS							; если нажата, то переходим к программе COUNT_M1

 sbis	PINC,4								; проверяем нажатия кнопки "OK" 
 rjmp	LOOP_COL_OK							; если нажата, то переходим к программе CENA_COL

 sbis	PINC,5								; проверяем нажатия кнопки "+1" 
 rcall	COUNT_PLUS							; если нажата, то переходим к программе COUNT_P1

 sbis	PIND,1								; Вход от 1-го датчика
 rcall	COUNT_INC							; если сработал, то переходим к программе COUNT_INC

 rcall	DISPLAY_CENA						; Отображаем количество копий на дисплее

 rjmp	MAIN_LOOP_CENA						; повтор основного цикла








;******************************************************************************
;******************************************************************************
;**                                                                          **
;**                                                                          **
;**                                 Процедуры                                **
;**                                                                          **
;**                                                                          **
;******************************************************************************
;******************************************************************************


;********************************************************************************
;*																				*
;*              Считаем количество и стоимость сделанных копий					*
;*																				*
;********************************************************************************

COUNT_INC:
 rcall	d13ms								; Устраняем ложное срабатывание
 sbic	PIND,1
ret											; Если срабатывание ложное, то просто выходим

COUNT_INC_ON:
 rcall	d20ms
 sbis	PIND,1								; Ждем снятия сигнала со входа
 rjmp	COUNT_INC_ON
 inc	count								; Увеличиваем значение счетчика копий

 clr	temp								; Увеличиваем общую стоимость копий
 add	cenaL,cena_copii
 adc	cenaH,temp

ret





;********************************************************************************
;*																				*
;*						Уменьшаем количество сделанных копий					*
;*																				*
;********************************************************************************

COUNT_MINUS:
 rcall	d13ms								; Устраняем ложное срабатывание
 sbic	PINC,3
ret											; Если срабатывание ложное, то просто выходим

 rcall	d50ms								; Устраняем ложное срабатывание
 ldi	temp,5
 sbis	PINC,5								; Проверяем нажатие двух кнопок одновременно
 rjmp	CENA_COPII_PROG
  
 dec	count								; Увеличиваем значение счетчика копий
 rcall	DISPLAY_COL							; Отображаем количество копий на дисплее

 clr	temp								; Уменьшаем общую стоимость копий
 sub	cenaL,cena_copii
 sbc	cenaH,temp

COUNT_MINUS_ON:
 rcall	d20ms
 sbis	PINC,3								; Ждем снятия сигнала со входа
 rjmp	COUNT_MINUS_ON
 rcall	d13ms
ret





;********************************************************************************
;*																				*
;*						Увеличиваем количество сделанных копий					*
;*																				*
;********************************************************************************

COUNT_PLUS:
 rcall	d13ms								; Устраняем ложное срабатывание
 sbic	PINC,5
ret											; Если срабатывание ложное, то просто выходим

 rcall	d50ms								; Устраняем ложное срабатывание
 ldi	temp,5
 sbis	PINC,3								; Проверяем нажатие двух кнопок одновременно
 rjmp	CENA_COPII_PROG

 inc	count								; Увеличиваем значение счетчика копий
 rcall	DISPLAY_COL							; Отображаем количество копий на дисплее

 clr	temp								; Увеличиваем общую стоимость копий
 add	cenaL,cena_copii
 adc	cenaH,temp

COUNT_PLUS_ON:
 rcall	d20ms
 sbis	PINC,5								; Ждем снятия сигнала со входа
 rjmp	COUNT_PLUS_ON
 rcall	d13ms
ret





;********************************************************************************
;*																				*
;*                  Отображает общую стоимость сделанных копий                  *
;*																				*
;********************************************************************************

DISPLAY_CENA:
 mov	adwH,cenaH							; Загружаем число в регистры
 mov	adwL,cenaL							;
 rcall	Bin2ToBCD5							; Перводим в десятичную систему 

 lds	temp,BCD
 cpi	temp,0								; Проверяем первый разряд на ноль
 breq	CENA_COL_1000						;  если равен 0, то гасим разряд 
 
 lds	temp,BCD							; Считываем значение 1 разряда
 sts	Digit,temp

 lds	temp,BCD+1							; Считываем значение 2 разряда
 sts	Digit+1,temp

 lds	temp,BCD+2							; Считываем значение 3 разряда
 ldi	temp1,10
 add	temp,temp1
 sts	Digit+2,temp

 lds	temp,BCD+3							; Считываем значение 4 разряда
 sts	Digit+3,temp

 lds	temp,BCD+4							; Считываем значение 5 разряда
 sts	Digit+4,temp

 ldi	temp,24
 sts	Digit+5,temp

ret

CENA_COL_1000:
 ldi	temp,20
 sts	Digit,temp
 sts	Digit+1,temp

 lds	temp,BCD+1
 cpi	temp,0								; Проверяем первый разряд на ноль
 breq	CENA_COL_100						;  если равен 0, то гасим разряд 
 lds	temp,BCD+1							; Считываем значение 2 разряда
 sts	Digit+1,temp

CENA_COL_100:
 lds	temp,BCD+2							; Считываем значение 3 разряда
 ldi	temp1,10
 add	temp,temp1
 sts	Digit+2,temp

 lds	temp,BCD+3							; Считываем значение 4 разряда
 sts	Digit+3,temp

 lds	temp,BCD+4							; Считываем значение 5 разряда
 sts	Digit+4,temp

 ldi	temp,24
 sts	Digit+5,temp

ret





;********************************************************************************
;*																				*
;*						Отображает количество сделанных копий					*
;*																				*
;********************************************************************************

DISPLAY_COL:
 clr	adwH
 mov	adwL,count							; Выводим на дисплей количество сделанных копий
 rcall	Bin2ToBCD3							; Перводим в десятичную систему 

 ldi	temp,20								; Загружаем пустой символ в переменную
 clr	temp0								; Сбрасываем значение регистра
 lds	temp1,BCD+2							; Проверяем с 0 
 cpse	temp1,temp0							;  если разряд=0, то гасим не значущий ноль
 lds	temp,BCD+2
 sts	Digit,temp

 mov	temp,count
 cpi	temp,10								; Если число больше 10, тогда отображаем текущий разряд
 brsh	MOOR100
 ldi	temp,20								; Загружаем пустой символ в переменную
 clr	temp0								; Сбрасываем значение регистра
 lds	temp1,BCD+3							; Проверяем с 0 
 cpse	temp1,temp0							;  если разряд=0, то гасим не значущий ноль
MOOR100:
 lds	temp,BCD+3
 sts	Digit+1,temp

 lds	temp,BCD+4							; Считываем значение третьего разряда
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
;*           Изменение и сохранение в EEPROM стоимости одной копии              *
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
 rcall	d13ms								; Устраняем ложное срабатывание
 sbic	PINC,4								; Проверяем нажатие кнопи OK
 rjmp	PROG_ENTER


CENA_CHANGE_PR:
 rcall	d50ms
 sbis	PINC,4
 rjmp	CENA_CHANGE_PR

CENA_CHANGE:
 rcall	d100ms
 
 clr	adwH								; Загружаем число в регистры
 mov	adwL,cena_copii						;
 rcall	Bin2ToBCD3							; Перводим в десятичную систему 

 ldi	temp,20
 sts	Digit,temp
 sts	Digit+1,temp
 
 lds	temp,BCD+2							; Считываем значение 3 разряда
 ldi	temp1,10
 add	temp,temp1
 sts	Digit+2,temp

 lds	temp,BCD+3							; Считываем значение 4 разряда
 sts	Digit+3,temp

 lds	temp,BCD+4							; Считываем значение 5 разряда
 sts	Digit+4,temp

 ldi	temp,24
 sts	Digit+5,temp

 sbis	PINC,3								; проверяем нажатия кнопки "-1" 
 rcall	CENA_COPII_MINUS					; если нажата, то переходим к программе COUNT_M1

 sbis	PINC,5								; проверяем нажатия кнопки "+1" 
 rcall	CENA_COPII_PLUS						; если нажата, то переходим к программе COUNT_M1

 sbic	PINC,4								; Проверяем нажатие кнопи OK
 rjmp	CENA_CHANGE
CENA_OK:
 rcall	d13ms
 sbis	PINC,4								; Если нажата кнопка OK, тогда сохраняем новое значение цены
 rjmp	CENA_OK
 
 rcall	d100ms
 cli										; Запрещаем прерывание на время записи в память EEPROM
EEPROM_write:
 sbic	EECR,EEWE
 rjmp	EEPROM_write						; Ждем завершения предыдущей записи, если была
 clr	temp
 out	EEARH,temp
 ldi	temp,0x05
 out	EEARL,temp							; Заносим адрес в регистр адреса
 out	EEDR,cena_copii						; Запишем данные в регистр данных
 sbi	EECR,EEMWE							; Установить флаг EEMWE
 sbi	EECR,EEWE							; Начать запись в EEPROM
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

 dec	cena_copii							; Уменьшаем стоимость одной копии на 5 бань
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
 add	cena_copii,temp						; Увеличиваем стоимость одной копии на 5 бань

 rcall	d100ms
ret

;******************************************************************************
;*                                                                            *
;*      преобразование двоичного числа в код 7-сегментного индикатора         *
;*Переменная d содержит переменную для преобразования.Результат помещается в d*
;******************************************************************************
    
	;   Регистры: temp2, d, r0

DECODER:
 ldi	ZL,Low(DigitFont*2)					; инициализация массива
 ldi	ZH,High(DigitFont*2)
 ldi	temp2,0								; прибавление переменной
 add	ZL,d								; к 0-му адресу массива
 adc	ZH,temp2
 lpm										; загрузка значения
 mov	d,r0
ret

;------------------------------------------------------------------------------
;   Таблица знакогенератора
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
	; где символ светится-1, 0-погашен





;******************************************************************************
;*                                                                            *
;*                      Вывод индикации на индикатор                          *
;*                     записываем данные в регистр HC595                      *
;*      переменная d содержит данные для вывода на разряде индикатора         *
;******************************************************************************

    ;   Регистры: temp2, d

LED_SEND: 
 ldi	temp2,8								; Передача 8-ми разрядов
 cbi	PORTB,1								; Сбрасываем сигнал Load
 cbi	PORTB,2								; Сбрасываем сигнал CLK 
LED_LOOP1:                                  ;
 cbi	PORTB,2								; Сбрасываем сигнал CLK 
 sbrc	d,7									; Переносим старший бит
 sbi	PORTB,3								;  регистра промежуточного
 sbrs	d,7									;  хранения в линию
 cbi	PORTB,3								;  сигнала Data
 lsl	d									; Сдвиг влево (очередной бит)
 sbi	PORTB,2								; Запись бита по фронту CLK
 dec	temp2								; Итерация внутреннего цикла
 brne	LED_LOOP1
 cbi	PORTB,2
ret




;***********************************************************************************
;*                                                                                 *
;*                                                                                 *
;*            Преобразование двоичного числа в число для индикатора                *
;*                                                                                 *
;*                                                                                 *
;***********************************************************************************

;   Использует переменные: temp, temp1, adwL, adwH, mulL, mulH
                          
; Bin2ToBcd5
; ==========
; converts a 16-bit-binary to a 5-digit-BCD
; In: 16-bit-binary in adwH,adwL
; Out: 5-digit-BCD
; Used registers:temp
; Called subroutines: Bin2ToDigit
;
Bin2ToBCD5:
 ldi	temp,high(10000)						; Вычисляем 10000 разряд
 mov	mulH,temp
 ldi	temp,low(10000)
 mov	mulL,temp
 rcall	Bin2ToDigit							; Вычисляем, результат в переменной temp
 sts	BCD,temp							; Если не ноль, тогда записываем результат
Bin2ToBCD4:
 ldi	temp,high(1000)						; Вычисляем 1000 разряд
 mov	mulH,temp
 ldi	temp,low(1000)
 mov	mulL,temp
 rcall	Bin2ToDigit							; Выяисляем
 sts	BCD+1,temp							; Результат в переменной temp 
Bin2ToBCD3:
 clr	mulH								;  Вычисляем 100 разряд
 ldi	temp,100
 mov	mulL,temp
 rcall	Bin2ToDigit							; Вычисляем
 sts	BCD+2,temp							; Результат в переменной temp
Bin2ToBCD2:
 clr	mulH								; Вычисляем 10 разряд
 ldi	temp,10
 mov	mulL,temp
 rcall	Bin2ToDigit							; Вычисляем
 sts	BCD+4,adwL							; Единицы остаются в adiw0
 sts	BCD+3,temp							; Результат в переменной temp
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
;**      Обработка прерывания - 0x0009 - Переполнение таймера/счетчика Т0      **
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
   
 inc	DigPoz								; Увеличиваем разряд индикации
 cpi	DigPoz,6							; Если отображается 7 разряд, то
 brne	NOT_CLEAR
 clr	DigPoz								;  загружаем начальное состояние (0).
NOT_CLEAR:
 lds	d,Digit+5
 cpi	DigPoz,0
 breq	VIVOD1
                                            ; Загрузка 5 числа для индикатора 
 lds	d,Digit+4
 cpi	DigPoz,1
 breq	VIVOD1
                                            ; Загрузка 4 числа для индикатора 
 lds	d,Digit+3
 cpi	DigPoz,2
 breq	VIVOD1
                                            ; Загрузка 3 числа для индикатора 
 lds	d,Digit+2
 cpi	DigPoz,3
 breq	VIVOD1
                                            ; Загрузка 2 числа для индикатора 
 lds	d,Digit+1
 cpi	DigPoz,4
 breq	VIVOD1
                                            ; Загрузка 1 числа для индикатора 
 lds	d,Digit

VIVOD1:
 rcall	DECODER
 rcall	LED_SEND							; Выводим число в регистр сдвига индикатора HC595

	; Выводим в порт число для дешифратора HC138 разряда индикатора
 cbi	PORTD,6								; Устанавливаем порт в 0
 sbrc	DigPoz,0							; Если бит регистра установлен, то
 sbi	PORTD,6								;  устанавливаем бит порта в 1

 cbi	PORTD,7								; Устанавливаем порт в 0
 sbrc	DigPoz,1							; Если бит регистра установлен, то
 sbi	PORTD,7								;  устанавливаем бит порта в 1

 cbi	PORTB,0								; Устанавливаем порт в 0
 sbrc	DigPoz,2							; Если бит регистра установлен, то
 sbi	PORTB,0								;  устанавливаем бит порта в 1

 sbi	PORTB,1								; Строб сигнал Load для вывода значения на выход 
 nop
 cbi	PORTB,1								;  регистра HC595


 pop	temp2								; Восстанавливаем прежние значения переменных
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
;**                 Формирование задержек при частоте кварца 4мГц                  **
;**                                                                                **
;**                                                                                **
;************************************************************************************
;************************************************************************************
;-------------------------------------------------------------------------
;	Задержка на 0,25мс (250мкс)

d025ms:
 ldi YL,low(248)                            ; Загрузка в YH:YL константы 497
 ldi YH,high(248)

d025_1:
 sbiw YL,1                                  ; Вычитание из содержимого YH:YL
                                            ;  единицы
 brne d025_1                                ; Если флаг Z<>0 (результат выполнения
                                            ;  предыдущей команды не равен нулю), то
									        ;  перейти на метку d05_1
ret





;-------------------------------------------------------------------------
;	Задержка на 0,5мс (500мкс)

d05ms:
 ldi	YL,low(497)							; Загрузка в YH:YL константы 497
 ldi	YH,high(497)

d05_1:
 sbiw	YL,1								; Вычитание из содержимого YH:YL единицы
 brne	d05_1								; Если флаг Z<>0 (результат выполнения
											;  предыдущей команды не равен нулю), то
											;  перейти на метку d05_1
ret





;-------------------------------------------------------------------------
;	Задержка 1 ms

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
;	Задержка 2,8 ms

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
;	Задержка 13 ms

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
;	Задержка 20 ms

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
;	Задержка на 50мс

d50ms:
 ldi	temp,100

d50_1:
 rcall	d05ms								; Вызов подпрограммы задержки на 0,5мс
 dec	temp								; Вычитание единицы из temp
 brne	d50_1								; Если результат не равен нулю, перейти на метку d50_1
ret





;-------------------------------------------------------------------------
;	Задержка на 100мс

d100ms:
 ldi	temp,200							; Загрузка в temp константы 200

d100_1:
 rcall	d05ms								; Вызов подпрограммы задержки на 0,5мс
 dec	temp								; Вычитание единицы из temp
 brne	d100_1								; Если результат не равен нулю, перейти на метку d100_1
ret





;-------------------------------------------------------------------------
;	Задержка на 300мс

d300ms:
 ldi	XL,low(700)							; Загрузка в YH:YL константы 700
 ldi	XH,high(700)

d300_1:
 rcall	d05ms								; Вызов подпрограммы задержки на 0,5мс
 sbiw	XL,1								; Вычитание единицы из содержимого XH:XL
 brne	d300_1								; Если результат не равен нулю, перейти на метку d500_1
ret





;-------------------------------------------------------------------------
;	Задержка на 500мс

d500ms:
 ldi	XL,low(1000)						; Загрузка в YH:YL константы 1000
 ldi	XH,high(1000)

d500_1:
 rcall	d05ms								; Вызов подпрограммы задержки на 0,5мс
 sbiw	XL,1								; Вычитание единицы из содержимого XH:XL
 brne	d500_1								; Если результат не равен нулю, перейти на метку d500_1
ret





;******************************************************************************

.exit                                       ; Конец программы
