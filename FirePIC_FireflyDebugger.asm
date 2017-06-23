
_interrupt:

;FirePIC_FireflyDebugger.c,19 :: 		void interrupt(){
;FirePIC_FireflyDebugger.c,22 :: 		MOVLB       0
	MOVLB      0
;FirePIC_FireflyDebugger.c,23 :: 		BTFSC       PIR1, RCIF                                               // Ignore interrupt unless it was Rx.
	BTFSC      PIR1+0, 5
;FirePIC_FireflyDebugger.c,24 :: 		GOTO        SEND_DATA
	GOTO       SEND_DATA
;FirePIC_FireflyDebugger.c,25 :: 		RETFIE                                                               // Return from interrupt.
	RETFIE     0
;FirePIC_FireflyDebugger.c,28 :: 		SEND_DATA:
SEND_DATA:
;FirePIC_FireflyDebugger.c,29 :: 		MOVLB       0
	MOVLB      0
;FirePIC_FireflyDebugger.c,30 :: 		BCF         PIR1, RCIF                                               // First clear the interrupt flag.
	BCF        PIR1+0, 5
;FirePIC_FireflyDebugger.c,31 :: 		MOVLB       3
	MOVLB      3
;FirePIC_FireflyDebugger.c,32 :: 		MOVF        RCREG, 0                                                 // Retrieve byte from Rx.
	MOVF       RCREG+0, 0
;FirePIC_FireflyDebugger.c,33 :: 		MOVWF       TXREG                                                    // Send the byte to the Pi.
	MOVWF      TXREG+0
;FirePIC_FireflyDebugger.c,34 :: 		RETFIE                                                               // Return from interrupt.
	RETFIE     0
;FirePIC_FireflyDebugger.c,36 :: 		}
L_end_interrupt:
L__interrupt5:
	RETFIE     %s
; end of _interrupt

_main:

;FirePIC_FireflyDebugger.c,44 :: 		void main(){
;FirePIC_FireflyDebugger.c,47 :: 		MOVLB      1
	MOVLB      1
;FirePIC_FireflyDebugger.c,48 :: 		MOVLW      0xFC                                                     // (0xFC = 1111 1100)
	MOVLW      252
;FirePIC_FireflyDebugger.c,50 :: 		MOVWF      TRISA                                                    // Set input{RA5, RA4, RA3}, output{RA0, RA1} (Tx pin needs to be set as input).
	MOVWF      TRISA+0
;FirePIC_FireflyDebugger.c,51 :: 		MOVLB      0
	MOVLB      0
;FirePIC_FireflyDebugger.c,52 :: 		CLRF       PORTA                                                    // Clear the port.
	CLRF       PORTA+0
;FirePIC_FireflyDebugger.c,55 :: 		MOVLB        1
	MOVLB      1
;FirePIC_FireflyDebugger.c,56 :: 		MOVLW        0xF0                                                   // Configure for 32MHz operation (0x7A for 16MHz)
	MOVLW      240
;FirePIC_FireflyDebugger.c,57 :: 		MOVWF        OSCCON
	MOVWF      OSCCON+0
;FirePIC_FireflyDebugger.c,60 :: 		MOVLB        3                                                      // Disable AtoD functionality on all pins.
	MOVLB      3
;FirePIC_FireflyDebugger.c,61 :: 		CLRF         ANSELA
	CLRF       ANSELA+0
;FirePIC_FireflyDebugger.c,64 :: 		MOVLB        2                                                      // Configure USART pinout
	MOVLB      2
;FirePIC_FireflyDebugger.c,65 :: 		MOVLW        0x84                                                   // RX = RA5
	MOVLW      132
;FirePIC_FireflyDebugger.c,66 :: 		MOVWF        APFCON                                                 // TX = RA4
	MOVWF      APFCON+0
;FirePIC_FireflyDebugger.c,69 :: 		MOVLB        3                                                      // 1Mbps: SPBRGH = 0  @ 16MHz, SPBRGL = 1  @ 16MHz
	MOVLB      3
;FirePIC_FireflyDebugger.c,70 :: 		CLRF         SPBRGH                                                 // 2Mbps: SPBRGH = 0 @ 16MHz,  SPBRGL = 0  @ 16MHz
	CLRF       SPBRGH+0
;FirePIC_FireflyDebugger.c,71 :: 		MOVLB        3
	MOVLB      3
;FirePIC_FireflyDebugger.c,72 :: 		MOVLW        1
	MOVLW      1
;FirePIC_FireflyDebugger.c,73 :: 		MOVWF        SPBRGL
	MOVWF      SPBRGL+0
;FirePIC_FireflyDebugger.c,75 :: 		MOVLB        3                                                      // BRG16
	MOVLB      3
;FirePIC_FireflyDebugger.c,76 :: 		MOVLW        0x04                                                   // bit 3 = 1. (BRG16)
	MOVLW      4
;FirePIC_FireflyDebugger.c,77 :: 		MOVWF        BAUDCON
	MOVWF      BAUDCON+0
;FirePIC_FireflyDebugger.c,80 :: 		MOVLB        3                                                      // Enable Asynschronous USART Tx
	MOVLB      3
;FirePIC_FireflyDebugger.c,81 :: 		MOVLW        0x24                                                   // With 8 bit mode by Default...
	MOVLW      36
;FirePIC_FireflyDebugger.c,82 :: 		MOVWF        TXSTA                                                  // SYNC = 0 & BRGH = 1
	MOVWF      TXSTA+0
;FirePIC_FireflyDebugger.c,84 :: 		MOVLB        3                                                      // Enable Asynschronous USART Rx
	MOVLB      3
;FirePIC_FireflyDebugger.c,85 :: 		MOVLW        0xD0                                                   // With 9 bit mode, (RX9 = 0)
	MOVLW      208
;FirePIC_FireflyDebugger.c,86 :: 		MOVWF        RCSTA
	MOVWF      RCSTA+0
;FirePIC_FireflyDebugger.c,89 :: 		MOVLB        1
	MOVLB      1
;FirePIC_FireflyDebugger.c,90 :: 		BSF          PIE1, RCIE                                             // USART Receive Interrupt Enable bit.
	BSF        PIE1+0, 5
;FirePIC_FireflyDebugger.c,91 :: 		CLRF         INTCON                                                 // Reset any previous settings.
	CLRF       INTCON+0
;FirePIC_FireflyDebugger.c,92 :: 		BSF          INTCON, PEIE                                           // Enable Periphieral Interrupts (For Rx Interrupts).
	BSF        INTCON+0, 6
;FirePIC_FireflyDebugger.c,93 :: 		BSF          INTCON, GIE                                            // Enable Global Interrupts (For Rx Interrupts).
	BSF        INTCON+0, 7
;FirePIC_FireflyDebugger.c,95 :: 		while(1){}
L_main2:
	GOTO       L_main2
;FirePIC_FireflyDebugger.c,96 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
