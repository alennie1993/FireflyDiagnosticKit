#line 1 "C:/Users/alenn/Desktop/Summer Work 2017/FireflyDiagnosticKit/FirePIC_FireflyDebugger.c"
#line 19 "C:/Users/alenn/Desktop/Summer Work 2017/FireflyDiagnosticKit/FirePIC_FireflyDebugger.c"
void interrupt(){
 asm{
 ISR:
 MOVLB 0
 BTFSC PIR1, RCIF
 GOTO SEND_DATA
 RETFIE


 SEND_DATA:
 MOVLB 0
 BCF PIR1, RCIF
 MOVLB 3
 MOVF RCREG, 0
 MOVWF TXREG
 RETFIE
 }
}
#line 44 "C:/Users/alenn/Desktop/Summer Work 2017/FireflyDiagnosticKit/FirePIC_FireflyDebugger.c"
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
 MOVLW 0x24
 MOVWF TXSTA

 MOVLB 3
 MOVLW 0xD0
 MOVWF RCSTA


 MOVLB 1
 BSF PIE1, RCIE
 CLRF INTCON
 BSF INTCON, PEIE
 BSF INTCON, GIE
 }
 while(1){}
}
