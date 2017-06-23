#line 1 "C:/Users/alenn/Desktop/Summer Work 2017/FireflyDiagnosticKit/FirePIC_PiTranslator.c"
#line 18 "C:/Users/alenn/Desktop/Summer Work 2017/FireflyDiagnosticKit/FirePIC_PiTranslator.c"
char receivedByte = 0;
char counter = 0;
#line 27 "C:/Users/alenn/Desktop/Summer Work 2017/FireflyDiagnosticKit/FirePIC_PiTranslator.c"
void interrupt(){
 asm{
 ISR:
 MOVLB 0
 BTFSC PIR1, RCIF
 GOTO SEND_DATA
 RETFIE




 RESET_9BIT_COUNTER:
 MOVLB 0
 MOVLW 2
 MOVWF _counter
 RETFIE



 TURN_ON_BIT_9:
 MOVLB 3
 BSF TXSTA, TX9D
 MOVLB 0
 DECF _counter, 1
 RETURN




 SEND_DATA:

 MOVLB 0
 BCF PIR1, RCIF


 MOVLB 3
 MOVF RCREG, 0
 MOVLB 0
 MOVWF _receivedByte


 SUBLW  0xF0; 
 BTFSC STATUS, Z
 GOTO RESET_9BIT_COUNTER


 MOVLB 3
 BCF TXSTA, TX9D
 MOVLB 0
 MOVF _counter,0
 BTFSS STATUS, Z
 CALL TURN_ON_BIT_9


 MOVLB 0
 MOVF _receivedByte, 0
 MOVLB 3
 MOVWF TXREG


 RETFIE
 }
}
#line 98 "C:/Users/alenn/Desktop/Summer Work 2017/FireflyDiagnosticKit/FirePIC_PiTranslator.c"
void main(){
 asm{
 CONFIG_PIC:
 MOVLB 1
 MOVLW 0xFC

 MOVWF TRISA
 MOVLB 0
 CLRF PORTA


 MOVLB 1
 MOVLW 0xF0
 MOVWF OSCCON


 MOVLB 3
 CLRF ANSELA


 MOVLB 2
 MOVLW 0x84
 MOVWF APFCON


 MOVLB 3
 CLRF SPBRGH
 MOVLB 3
 MOVLW 1
 MOVWF SPBRGL

 MOVLB 3
 MOVLW 0x04
 MOVWF BAUDCON


 MOVLB 3
 MOVLW 0x64
 MOVWF TXSTA

 MOVLB 3
 MOVLW 0x90
 MOVWF RCSTA


 MOVLB 0
 CLRF _counter


 MOVLB 1
 BSF PIE1, RCIE
 CLRF INTCON
 BSF INTCON, PEIE
 BSF INTCON, GIE
 }
 while(1){}
}
