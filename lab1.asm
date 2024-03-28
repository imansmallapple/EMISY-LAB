lab1.asm
LED_Y equ P1.4//User LED

//When BUTTON0 
BUTTON0 equ P0.2
SW1 equ P1.2//Keyboard button in the LCD board
SW2 equ P0.5
SW3 equ P1.6
SW4 equ P1.1
RTC_INT equ P1.3//This pin is typically found on a Real Time Clock (RTC) module, not the LCD. It is used to trigger an interrupt signal from the RTC module
RS equ P0.6//This pin is used to switch between command mode (RS=0) and data mode (RS=1). In command mode, we send commands such as clear display, cursor position, etc. In data mode, we send data which is to be displayed on the LCD
EN equ P1.5//This pin is used to enable the LCD module. When data is ready to be read or written, this pin is set high

//Task 1
// turn on the EFM8BB1LCK LED only when selected combination of LCD board buttons is pressed
//Student should be able to answer questions about the keyboard configuration, LED configuration and LCD display
//Keyboard configuration:
//The keyboard on the LCD board is configured through the GPIO (General Purpose Input/Output) pins on the microcontroller. 
//Each button is connected to a specific pin, and when a button is pressed, it changes the state of that pin.

//LED configuration:
//The user LED on the EFM8BB1LCK is also connected to a GPIO pin on the microcontroller. 
//We use BUTTON0 to turn on the LED light

//LCD connection:
//The LCD display is connected to the microcontroller through several pins. These include the RS (Register Select) pin, which switches between command and data modes, and the EN (Enable) pin, which enables the LCD module. The LCD also includes a shift register for controlling the display. 

//setb LED_Y is turn off LED and clr LED_Y is turn on LED
/*
//turn off the LED
       setb LED_Y
START:
       // Check the state of SW1 and SW2
       jnb SW1, NEXT  // Jump if SW1 is high (not pressed)
       jnb SW2, NEXT  // Jump if SW2 is high (not pressed)

// If both SW1 and SW2 are low (pressed), turn on the LED
       clr LED_Y



       mov r1, #0xff
L1:    mov r0, #0xff
L2:    djnz r0, L2
       djnz r1, L1
       sjmp START
*/

//TASK 2
//designed time delay subroutine to generate approx. 5 to 10 ms delay, I assume 6 ms here = 6000 us = 6000 periods
//这里我选用三重循环延时程序, 自己做的不是GPT生成的嗷
//delay calculation: {[(2*14+1+2)*14+1+2]*14+1+2}*(1/12)*12 = 6121 us = 6.121 ms
delay_ms:
 del4：     mov R2, #14D   //1T
 del3:      mov R1, #14D   //1T
 del2:      mov R0, #14D   //1T
 del1:      djnz R0, del1  //2T
            djnz R1, del2  //2T 
            djnz R2, del3  //2T
ret //2T


//RS=0 command mode, RS=1 data mode
//EN=1 LCD ready to be read or write
send_command:
//define subroutine here
mov DPTR, #11010000B  //send to CPLD, D7 to D0(Define the place where to send)
mov @DPTR, A//send command stored in accomulator
mov DPTR, #11100000B //movx A, @DPTR //sent to CPLD CS3MODE register RS and E pins

mov A, #00010000B //Set RS 0 and E 1, here we enter command mode and enables read or write data
movx @DPTR, A //send command stored in accomulator
mov A, #00000000B //Set RS 0 and E 0, just shut down everything
movX @DPTR, A //send command stored in accomulator
ret

send_data:
//define subroutine here
mov DPTR, #11010000B  //send to CPLD, D7 to D0(Define the place where to send)
movx @DPTR, A
mov DPTR, #11100000B
movx @DPTR, A

mov A, #00110000B //Set RS 1 and E 1, here we enter data mode and enables LCD read or write data
movx @DPTR, A
mov A, #00100000B //Set RS 1 and E 0, same data mode but disable the rw function
movx @DPTR, A
ret

LCD_DISPLAY:
    org 8000H
//这里交替查表找指令， lcall 发送指令和 lcall delay就完事了    

ret


MAIN:
  //org 8000H
//A watchdog is a mechanism that periodically tests whether a process or thread is running properly. If it’s not, it either restarts it or notifies an administrator, depending on the needs of the application
//disable watch dog
  mov WDTCN, #0DEH
  mov WDTCN, #0ADH

//单片机晶振频率为12MHz， 则机器周期为1us. 1/12 Mhz * 12 = 1 us
//system clock configuration - 24.5 MHz divided by 2, to get roughly 12 MHz
// The CLKSEL register is typically used to select the clock source and/or divide the clock frequency
//00010000b是一个二进制数字，b后缀表示这个数是二进制，转换为十进制就是16
  mov CLKSEL, #00010000b

//internal crossbar configuration
  mov XBR0, #0H ;no for Pe mov XBR2, #;disable weak pullups, enable crossbar
  mov XBR2, #011000000b
  mov PRTDRV, #00000111b ; all I/O pins in full power mode

  mov P1MDIN, #0FFH   //move 255 inside
  mov P0MDIN, #0FFH
  mov P0MDOUT, #0FFH
  mov P1MDOUT, #0FFH
  mov P0SKIp, #0FFH
  mov P1SKIP, #0FFH

//TASK 1 PART CODE
//优化后的代码
//setb LED_Y is turn off LED and clr LED_Y is turn on LED
//turn off the LED
       setb LED_Y//this should locate in initialization code part
LED_TURN_ON_LOOP:
      //Load 255 inside A register
      mov A, #0FFH   //put 255 inside
      mov A, BUTTON0 //Load LED button pin into A register
      jb SW1, BUTTON1_NOT_PRESSED
      //if press then we check button 2
      jb SW2, BUTTON2_NOT_PRESSED
      //if pressed then we turn on the LED
      clr LED_Y
      jmp LED_TURN_ON_LOOP //keep iterating the loop and make the light always working
BUTTON1_NOT_PRESSED:
      jmp LED_TURN_ON_LOOP
BUTTON2_NOT_PRESSED:
      jmp LED_TURN_ON_LOOP

  //clr RS
  //clr RTC_INT
  //clr LED_Y //turn on LED

  //Upper letter from A-Z
  TAB1: DB 41H, 42H, 43H, 44H, 45H, 46H, 47H, 48H, 49H, 4AH, 4BH, 4CH, 4DH, 4EH, 4FH, 50H, 51H, 52H, 53H, 54H, 55H, 56H, 57H, 58H, 59H, 5AH
  //Lower letter from a-z
  TAB2: DB 61H, 62H, 63H, 64H, 65H, 66H, 67H, 68H, 69H, 6AH, 6BH, 6CH, 6DH, 6EH, 6FH, 70H, 71H, 72H, 73H, 74H, 75H, 76H, 77H, 78H, 79H, 7AH
  //Chen Song
  TAB3: DB 43H, 68H, 65H, 6EH, 20H, 53H, 6FH, 6EH, 67H
END

