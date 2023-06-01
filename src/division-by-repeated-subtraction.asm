; *** FILE DATA ***
;   Filename: division-by-repeated-subtraction.asm
;   Date: June 1, 2023
;   Version: 1.0
;
;   Author: Gianni Labella
;
;   Notes: Implementation of division by repeated subtraction


; *** Processor Config ***
	list		p=16f877a       ; list directive to define processor
	#include	<p16f877a.inc>  ; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
w_temp      EQU	0x7D    ; variable used for context saving
status_temp	EQU	0x7E    ; variable used for context saving
pclath_temp	EQU	0x7F    ; variable used for context saving

; Division algorithm variables
dividend    EQU 0x20
divisor     EQU 0x21
quotient    EQU 0x22
remainder   EQU 0x23


; *** Reset Config ***
	ORG     0x000   ; processor reset vector

	nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
	ORG     0x004       ; interrupt vector location

	movwf   w_temp      ; save off current W register contents
	movf	STATUS, W   ; move status register into W register
	movwf	status_temp ; save off contents of STATUS register
	movf	PCLATH, W	; move pclath register into w register
	movwf	pclath_temp ; save off contents of PCLATH register

    ; isr code can go here or be located as a call subroutine elsewhere

	movf	pclath_temp, W  ; retrieve copy of PCLATH register
	movwf	PCLATH		    ; restore pre-isr PCLATH register contents
	movf    status_temp, W  ; retrieve copy of STATUS register
	movwf	STATUS          ; restore pre-isr STATUS register contents
	swapf   w_temp, F
	swapf   w_temp, W       ; restore pre-isr W register contents
	retfie                  ; return from interrupt


; *** Main Routine ***
main
    ; Set dividend
    movlw   d'127'
    movwf   dividend

    ; Set divisor
    movlw   d'20'
    movwf   divisor

    call    division

loop
    goto    loop


; *** Division subroutine ***
division
    ; Set remainder to dividend
    movf    dividend, W
    movwf   remainder

    ; Set quotient to zero
    movlw   0x0
    movwf   quotient

    ; Check if divisor is zero
    incf    divisor, F      ; increment and decrement divisor to check if it is zero
    decfsz  divisor, F
    call    division_loop   ; enter division if divisor is not 0

    return

division_loop
    ; Check if remainder bigger or equal to divisor
    movf    divisor, W      ; W = divisor
    subwf   remainder, W    ; W = remainder - W = remainder - divisor
    btfss   STATUS, C       ; check if result is positive, skip if it is
    return                  ; exit loop when result is negative (remainder < divisor)

    ; Decrement remainder by divisor
    movf    divisor, W      ; W = divisor
    subwf   remainder, F    ; remainder = remainder - W = remainder - divisor

    ; Increment quotient
    incf    quotient, F

    goto    division_loop


	END ; directive 'end of program'
