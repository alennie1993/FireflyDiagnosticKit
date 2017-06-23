
_interrupt:

;FirePIC_PiTranslator.c,27 :: 		void interrupt(){
;FirePIC_PiTranslator.c,30 :: 		MOVLB       0
	MOVLB      0
;FirePIC_PiTranslator.c,31 :: 		BTFSC       PIR1, RCIF                                            // Ignore interrupt unless it was Rx.
	BTFSC      PIR1+0, 5
;FirePIC_PiTranslator.c,32 :: 		GOTO        SEND_DATA
	GOTO       SEND_DATA
;FirePIC_PiTranslator.c,33 :: 		RETFIE                                                            // Return from interrupt.
	RETFIE     0
;FirePIC_PiTranslator.c,38 :: 		RESET_9BIT_COUNTER:
RESET_9BIT_COUNTER:
;FirePIC_PiTranslator.c,39 :: 		MOVLB      0
	MOVLB      0
;FirePIC_PiTranslator.c,40 :: 		MOVLW      2
	MOVLW      2
;FirePIC_PiTranslator.c,41 :: 		MOVWF      _counter                                               // Set Counter to 2.
	MOVWF      _counter+0
;FirePIC_PiTranslator.c,42 :: 		RETFIE                                                            // Leave interrupt here, only called on start message indicator so don't send.
	RETFIE     0
;FirePIC_PiTranslator.c,46 :: 		TURN_ON_BIT_9:
TURN_ON_BIT_9:
;FirePIC_PiTranslator.c,47 :: 		MOVLB     3
	MOVLB      3
;FirePIC_PiTranslator.c,48 :: 		BSF       TXSTA, TX9D                                             // Turn the 9th bit ON.
	BSF        TXSTA+0, 0
;FirePIC_PiTranslator.c,49 :: 		MOVLB     0
	MOVLB      0
;FirePIC_PiTranslator.c,50 :: 		DECF      _counter, 1                                             // Decrement the counter.
	DECF       _counter+0, 1
;FirePIC_PiTranslator.c,51 :: 		RETURN                                                            // Return to send byte.
	RETURN
;FirePIC_PiTranslator.c,56 :: 		SEND_DATA:
SEND_DATA:
;FirePIC_PiTranslator.c,58 :: 		MOVLB       0
	MOVLB      0
;FirePIC_PiTranslator.c,59 :: 		BCF         PIR1, RCIF
	BCF        PIR1+0, 5
;FirePIC_PiTranslator.c,62 :: 		MOVLB      3
	MOVLB      3
;FirePIC_PiTranslator.c,63 :: 		MOVF       RCREG, 0
	MOVF       RCREG+0, 0
;FirePIC_PiTranslator.c,64 :: 		MOVLB      0
	MOVLB      0
;FirePIC_PiTranslator.c,65 :: 		MOVWF      _receivedByte                                             // Store into receivedByte for testing agains 0xF0 in W.
	MOVWF      _receivedByte+0
;FirePIC_PiTranslator.c,68 :: 		SUBLW      NEW_MESSAGE_FLAG                                          // Subtract from 0xFF
	SUBLW      240
;FirePIC_PiTranslator.c,69 :: 		BTFSC      STATUS, Z                                                 // If the result of that was not 0 (ie. it was the start indicator)...
	BTFSC      STATUS+0, 2
;FirePIC_PiTranslator.c,70 :: 		GOTO       RESET_9BIT_COUNTER                                        //        Set the counter to 2 for 9th bit setting, then exit ISR.
	GOTO       RESET_9BIT_COUNTER
;FirePIC_PiTranslator.c,73 :: 		MOVLB       3
	MOVLB      3
;FirePIC_PiTranslator.c,74 :: 		BCF         TXSTA, TX9D                                              // Always clear by default.
	BCF        TXSTA+0, 0
;FirePIC_PiTranslator.c,75 :: 		MOVLB       0
	MOVLB      0
;FirePIC_PiTranslator.c,76 :: 		MOVF       _counter,0                                                // Load the counter to check if it was empty (inside STATUS.Z)
	MOVF       _counter+0, 0
;FirePIC_PiTranslator.c,77 :: 		BTFSS      STATUS, Z                                                 // If the counter == 0:
	BTFSS      STATUS+0, 2
;FirePIC_PiTranslator.c,78 :: 		CALL       TURN_ON_BIT_9                                                 // Turn on the 9th bit and return back.
	CALL       TURN_ON_BIT_9
;FirePIC_PiTranslator.c,81 :: 		MOVLB       0
	MOVLB      0
;FirePIC_PiTranslator.c,82 :: 		MOVF        _receivedByte, 0                                         // Load back the untouched _receivedByte.
	MOVF       _receivedByte+0, 0
;FirePIC_PiTranslator.c,83 :: 		MOVLB       3
	MOVLB      3
;FirePIC_PiTranslator.c,84 :: 		MOVWF       TXREG                                                    // Send received data.
	MOVWF      TXREG+0
;FirePIC_PiTranslator.c,87 :: 		RETFIE
	RETFIE     0
;FirePIC_PiTranslator.c,89 :: 		}
L_end_interrupt:
L__interrupt7:
	RETFIE     %s
; end of _interrupt

_main:

;FirePIC_PiTranslator.c,98 :: 		void main(){
;FirePIC_PiTranslator.c,101 :: 		MOVLB      1
	MOVLB      1
;FirePIC_PiTranslator.c,102 :: 		MOVLW      0xFC                                                     // (0xFC = 1111 1100)
	MOVLW      252
;FirePIC_PiTranslator.c,104 :: 		MOVWF      TRISA                                                    // Set input{RA5, RA4, RA3}, output{RA0, RA1} (Tx pin needs to be set as input).
	MOVWF      TRISA+0
;FirePIC_PiTranslator.c,105 :: 		MOVLB      0
	MOVLB      0
;FirePIC_PiTranslator.c,106 :: 		CLRF       PORTA                                                    // Clear the port.
	CLRF       PORTA+0
;FirePIC_PiTranslator.c,109 :: 		MOVLB        1
	MOVLB      1
;FirePIC_PiTranslator.c,110 :: 		MOVLW        0xF0                                                   // Configure for 32MHz operation (0x7A for 16MHz)
	MOVLW      240
;FirePIC_PiTranslator.c,111 :: 		MOVWF        OSCCON
	MOVWF      OSCCON+0
;FirePIC_PiTranslator.c,114 :: 		MOVLB        3                                                      // Disable AtoD functionality on all pins.
	MOVLB      3
;FirePIC_PiTranslator.c,115 :: 		CLRF         ANSELA
	CLRF       ANSELA+0
;FirePIC_PiTranslator.c,118 :: 		MOVLB        2                                                      // Configure USART pinout
	MOVLB      2
;FirePIC_PiTranslator.c,119 :: 		MOVLW        0x84                                                   // RX = RA5
	MOVLW      132
;FirePIC_PiTranslator.c,120 :: 		MOVWF        APFCON                                                 // TX = RA4
	MOVWF      APFCON+0
;FirePIC_PiTranslator.c,123 :: 		MOVLB        3                                                      // 1Mbps: SPBRGH = 0  @ 16MHz, SPBRGL = 1  @ 16MHz
	MOVLB      3
;FirePIC_PiTranslator.c,124 :: 		CLRF         SPBRGH                                                 // 2Mbps: SPBRGH = 0 @ 16MHz,  SPBRGL = 0  @ 16MHz
	CLRF       SPBRGH+0
;FirePIC_PiTranslator.c,125 :: 		MOVLB        3
	MOVLB      3
;FirePIC_PiTranslator.c,126 :: 		MOVLW        1
	MOVLW      1
;FirePIC_PiTranslator.c,127 :: 		MOVWF        SPBRGL
	MOVWF      SPBRGL+0
;FirePIC_PiTranslator.c,129 :: 		MOVLB        3                                                      // BRG16
	MOVLB      3
;FirePIC_PiTranslator.c,130 :: 		MOVLW        0x04                                                   // bit 3 = 1. (BRG16)
	MOVLW      4
;FirePIC_PiTranslator.c,131 :: 		MOVWF        BAUDCON
	MOVWF      BAUDCON+0
;FirePIC_PiTranslator.c,134 :: 		MOVLB        3                                                      // Enable Asynschronous USART Tx
	MOVLB      3
;FirePIC_PiTranslator.c,135 :: 		MOVLW        0x64                                                   // With 9 bit mode by Default...
	MOVLW      100
;FirePIC_PiTranslator.c,136 :: 		MOVWF        TXSTA                                                  // SYNC = 0 & BRGH = 1
	MOVWF      TXSTA+0
;FirePIC_PiTranslator.c,138 :: 		MOVLB        3                                                      // Enable Asynschronous USART Rx
	MOVLB      3
;FirePIC_PiTranslator.c,139 :: 		MOVLW        0x90                                                   // With 8 bit mode, (RX9 = 0)
	MOVLW      144
;FirePIC_PiTranslator.c,140 :: 		MOVWF        RCSTA
	MOVWF      RCSTA+0
;FirePIC_PiTranslator.c,143 :: 		MOVLB      0
	MOVLB      0
;FirePIC_PiTranslator.c,144 :: 		CLRF       _counter
	CLRF       _counter+0
;FirePIC_PiTranslator.c,147 :: 		MOVLB        1
	MOVLB      1
;FirePIC_PiTranslator.c,148 :: 		BSF          PIE1, RCIE                                             // USART Receive Interrupt Enable bit.
	BSF        PIE1+0, 5
;FirePIC_PiTranslator.c,149 :: 		CLRF         INTCON                                                 // Reset any previous settings.
	CLRF       INTCON+0
;FirePIC_PiTranslator.c,150 :: 		BSF          INTCON, PEIE                                           // Enable Periphieral Interrupts (For Rx Interrupts).
	BSF        INTCON+0, 6
;FirePIC_PiTranslator.c,151 :: 		BSF          INTCON, GIE                                            // Enable Global Interrupts (For Rx Interrupts).
	BSF        INTCON+0, 7
;FirePIC_PiTranslator.c,153 :: 		while(1){}
L_main4:
	GOTO       L_main4
;FirePIC_PiTranslator.c,154 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
