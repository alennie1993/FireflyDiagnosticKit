/********************************************************************************
 *  Firefly Diagnosis PIC                                                       *
 *  Creator: Aidan Lennie                                                       *
 *  Team: Joe Finney, Andras Herczeg                                            *
 *  Organisation: Lancaster University                                          *
 *  Liscence: Please see !"£"!$!£"%$"£^£"^%£&^%$£"&                             *
 *  Date of Creation: 22/06/2017                                                *
 *  Version: 0.0.1                                                              *
 *  Description: This program will receive 'manchester decoded', '9-bit' bytes  *
 *               from the PIC inside the wire leading to the Firefly itself.    *
 *               The Bytes it receives will be instantly forwarded (8-bit) to   *
 *               the Pi for diagnosis and analysis.                             *
 ********************************************************************************/

/*
 *   This interupt simply reads Rx Transmition from the Firefly, then forwards
 *      it to the Pi, converting from 9-bit to 8-bit transmission.
 */
void interrupt(){
  asm{
      ISR:                                                                      // Interrupt Service Routine.
           MOVLB       0
           BTFSC       PIR1, RCIF                                               // Ignore interrupt unless it was Rx.
           GOTO        SEND_DATA
           RETFIE                                                               // Return from interrupt.


      SEND_DATA:
           MOVLB       0
           BCF         PIR1, RCIF                                               // First clear the interrupt flag.
           MOVLB       3
           MOVF        RCREG, 0                                                 // Retrieve byte from Rx.
           MOVWF       TXREG                                                    // Send the byte to the Pi.
           RETFIE                                                               // Return from interrupt.
    }
}

/*
 *   The only two functions of this function are to:
 *      A) Configure the PIC for USART communication from Firefly to the Pi for
 *         diagnosis. see CONFIG_PIC for specifics.
 *      B) Continuesly loop in "while(1){}" to keep the PIC alive and running.
 */
void main(){
  asm{
    CONFIG_PIC:
            MOVLB      1
            MOVLW      0xFC                                                     // (0xFC = 1111 1100)
            // WARNING! RA3 is always input only! (page 102 on datasheet).
            MOVWF      TRISA                                                    // Set input{RA5, RA4, RA3}, output{RA0, RA1} (Tx pin needs to be set as input).
            MOVLB      0
            CLRF       PORTA                                                    // Clear the port.

            // SETUP OSCILATOR
            MOVLB        1
            MOVLW        0xF0                                                   // Configure for 32MHz operation (0x7A for 16MHz)
            MOVWF        OSCCON

            // DISABLE ALL ANOLOGUE TO DIGITAL
            MOVLB        3                                                      // Disable AtoD functionality on all pins.
            CLRF         ANSELA

            // SETUP USART (RX = RA5; TX = RA4)
            MOVLB        2                                                      // Configure USART pinout
            MOVLW        0x84                                                   // RX = RA5
            MOVWF        APFCON                                                 // TX = RA4

            // Configure Serial BAUD rate for high speed.                       // SYNC = 0; BRG16 = 0; BRGH = 1;
            MOVLB        3                                                      // 1Mbps: SPBRGH = 0  @ 16MHz, SPBRGL = 1  @ 16MHz
            CLRF         SPBRGH                                                 // 2Mbps: SPBRGH = 0 @ 16MHz,  SPBRGL = 0  @ 16MHz
            MOVLB        3
            MOVLW        1
            MOVWF        SPBRGL

            MOVLB        3                                                      // BRG16
            MOVLW        0x04                                                   // bit 3 = 1. (BRG16)
            MOVWF        BAUDCON

            // CONFIGURE USART.
            MOVLB        3                                                      // Enable Asynschronous USART Tx
            MOVLW        0x24                                                   // With 8 bit mode by Default...
            MOVWF        TXSTA                                                  // SYNC = 0 & BRGH = 1

            MOVLB        3                                                      // Enable Asynschronous USART Rx
            MOVLW        0xD0                                                   // With 9 bit mode, (RX9 = 0)
            MOVWF        RCSTA

            // CONFIGURE INTERRUPTS
            MOVLB        1
            BSF          PIE1, RCIE                                             // USART Receive Interrupt Enable bit.
            CLRF         INTCON                                                 // Reset any previous settings.
            BSF          INTCON, PEIE                                           // Enable Periphieral Interrupts (For Rx Interrupts).
            BSF          INTCON, GIE                                            // Enable Global Interrupts (For Rx Interrupts).
  }
  while(1){}
}