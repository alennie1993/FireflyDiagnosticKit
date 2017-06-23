/********************************************************************************
 *  Firefly, Pi forwarding PIC                                                  *
 *  Creator: Aidan Lennie                                                       *
 *  Team: Joe Finney, Andras Herczeg                                            *
 *  Organisation: Lancaster University                                          *
 *  Liscence: Please see !"£"!$!£"%$"£^£"^%£&^%$£"&                             *
 *  Date of Creation: 22/06/2017                                                *
 *  Version: 0.0.1                                                              *
 *  Description: This program will receive 'manchester encoded', '8-bit bytes   *
 *               from the Pi. The Bytes it receives will be instantly forwarded *
 *               to the Pi for diagnosis and analysis (9-bit).                  *
 *               When the illegal charcter (0xF0), is received, the PIC will    *
 *               then turn the ninth bit on for the next to bytes it receives,  *
 *               ensuring all others are removed.                               *
 ********************************************************************************/

#define NEW_MESSAGE_FLAG 0xF0;
char receivedByte = 0;
char counter = 0;

/*
 *   This interupt reads '8-bit, manchester encoded' messages from the Pi,
 *        forwarding them to Firefly in '9-bit'. It also determines when the
 *        start of a new message is, turning on the 9-bit bit for the first
 *        of the two bytes which follow.
 */
void interrupt(){
  asm{
      ISR:                                                                      /// Interrupt Service Routine.
              MOVLB       0
              BTFSC       PIR1, RCIF                                            // Ignore interrupt unless it was Rx.
              GOTO        SEND_DATA
              RETFIE                                                            // Return from interrupt.


      // This set of instructions resets the counter for setting the 9th bit
      //      on the first two bytes of a message.
      RESET_9BIT_COUNTER:
              MOVLB      0
              MOVLW      2
              MOVWF      _counter                                               // Set Counter to 2.
              RETFIE                                                            // Leave interrupt here, only called on start message indicator so don't send.


      // This set of instructions Turns on the 9th bit on decrements the counter.
      TURN_ON_BIT_9:
              MOVLB     3
              BSF       TXSTA, TX9D                                             // Turn the 9th bit ON.
              MOVLB     0
              DECF      _counter, 1                                             // Decrement the counter.
              RETURN                                                            // Return to send byte.


      // This set of instructions reads the byte, turning on the 9th bit if it's
      //      one of the two first bytes, before sending.
      SEND_DATA:
           // RESET INTERRUPT FLAG
           MOVLB       0
           BCF         PIR1, RCIF

           // READ BYTE RECEIVED
           MOVLB      3
           MOVF       RCREG, 0
           MOVLB      0
           MOVWF      _receivedByte                                             // Store into receivedByte for testing agains 0xF0 in W.

           // CHECK IF BYTE IS START INDICATOR (0xFF, an illegal byte in manchester encoding)
           SUBLW      NEW_MESSAGE_FLAG                                          // Subtract from 0xFF
           BTFSC      STATUS, Z                                                 // If the result of that was not 0 (ie. it was the start indicator)...
           GOTO       RESET_9BIT_COUNTER                                        //        Set the counter to 2 for 9th bit setting, then exit ISR.

           // Otherwise: SET OR CLEAR NINTH BIT BEFORE SENDING.
           MOVLB       3
           BCF         TXSTA, TX9D                                              // Always clear by default.
           MOVLB       0
           MOVF       _counter,0                                                // Load the counter to check if it was empty (inside STATUS.Z)
           BTFSS      STATUS, Z                                                 // If the counter == 0:
           CALL       TURN_ON_BIT_9                                                 // Turn on the 9th bit and return back.

           //SEND THE BYTE
           MOVLB       0
           MOVF        _receivedByte, 0                                         // Load back the untouched _receivedByte.
           MOVLB       3
           MOVWF       TXREG                                                    // Send received data.

           // RETURN FROM THE INTERRUPT
           RETFIE
    }
}

/*
 *   The only two functions of this function are to:
 *      A) Configure the PIC for USART communication from PIC to the Pi, adding
 *         the 9th bit onto the messages it forwards.
 *         See CONFIG_PIC for specifics.
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
            MOVLW        0x64                                                   // With 9 bit mode by Default...
            MOVWF        TXSTA                                                  // SYNC = 0 & BRGH = 1

            MOVLB        3                                                      // Enable Asynschronous USART Rx
            MOVLW        0x90                                                   // With 8 bit mode, (RX9 = 0)
            MOVWF        RCSTA

            // CLEAR THE COUNTER FOR TOGGLING THE 9TH BIT STATE.
            MOVLB      0
            CLRF       _counter

            // CONFIGURE INTERRUPTS
            MOVLB        1
            BSF          PIE1, RCIE                                             // USART Receive Interrupt Enable bit.
            CLRF         INTCON                                                 // Reset any previous settings.
            BSF          INTCON, PEIE                                           // Enable Periphieral Interrupts (For Rx Interrupts).
            BSF          INTCON, GIE                                            // Enable Global Interrupts (For Rx Interrupts).
  }
  while(1){}
}