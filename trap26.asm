; Supports interrupt-driven keyboard input.
; CSC 225, Assignment 5

            .ORIG x1000

; Reads one character, executing a second program while waiting for input:
;  1. Saves the keyboard entry from the IVT.
;  2. Sets the keyboard entry in the IVT to ISR180.
;  3. Enables keyboard interrupts.
;  4. Returns to the second program.
; NOTE: The first program's state must be swapped with the second's.
TRAP26      ST R1, P1R1  
		    ST R2, P1R2 
		    ST R3, P1R3
		    ST R4, P1R4  
		    ST R5, P1R5  
		    ST R7, P1R7

            AND R2, R2, #0 
            LDR R2, R6, #0 
            ST R2, P1PC     
		    
		    ADD R6, R6, #1 
		    AND R2, R2, #0
		    LDR R2, R6, #0
		    ST R2, P1PSR 
	
		    ; 1. Saves the keyboard entry from the IVT 
		    AND R2, R2, #0 
		    AND R3, R3, #0 
		    LD R2, KBIV
		    LDR R3, R2, #0         ; I think he said this needs and LDR instead... but
		    ST R3, SAVEIV
	
		    ; 2. Set the keyboard entry in the IVT to ISR180
		    AND R2, R2, #0 
		    AND R3, R3, #0
		    LEA R2, ISR180
		    LD R3, KBIV
		    STR R2, R3, #0 ; store R2 at the value of KBIV which is x0180 
	
		    ; 3. Enables keyboard interrupts 
		    AND R2, R2, #0 
		    AND R3, R3, #0
		    LD R2, KBSR 
		    LD R3, KBIMASK
		    STR R3, R2, #0
		    
		    AND R2, R2, #0 
		    AND R3, R3, #0
		    
		    ; the first programs state must be swapped with the second's 
	        AND R2, R2, #0 
	        LD R2, P2PSR
		    STR R2, R6, #0 
		
		    ADD R6, R6, #-1 
		    AND R2, R2, #0 
	        LD R2, P2PC
		    STR R2, R6, #0 
		    
		    LD R0, P2R0
		    LD R1, P2R1
		    LD R2, P2R2 
		    LD R3, P2R3
		    LD R4, P2R4 
		    LD R5, P2R5
		    LD R7, P2R7 
		
		    ; 4. Returns to the second program 
		    RTI 
	


; Responds to a keyboard interrupt:
;  1. Disables keyboard interrupts.
;  2. Restores the original keyboard entry in the IVT.
;  3. Reads the typed character into R0.
;  4. Returns to the caller of TRAP26.
; NOTE: The second program's state must be swapped with the first's.

; We are getting to ISR180 :) Now we just have to make sure it works as expected
ISR180      ST R0, P2R0
		    ST R1, P2R1  
		    ST R2, P2R2 
		    ST R3, P2R3
		    ST R4, P2R4  
		    ST R5, P2R5  
		    ST R7, P2R7

            AND R2, R2, #0 
            LDR R2, R6, #0 
            ST R2, P2PC     
		    
		    ADD R6, R6, #1 
		    AND R2, R2, #0
		    LDR R2, R6, #0
		    ST R2, P2PSR 
		
		; 1. Disables keyboard interrupts 
		    AND R2, R2, #0 
		    AND R3, R3, #0
		    LD R2, KBSR 
		    STR R3, R2, #0 
	
		; 2. Restores the original keyboard entry in the IVT 
		; i'm not actually putting it into the IVT 
		; get the value at SAVIV, save that value at the value of KBIV???? 
		; it is still putting just the address of SAVEIV at 0x0180
		    AND R2, R2, #0 
		    AND R3, R3, #0 
		    LD R2, SAVEIV
		    LD R3, KBIV
		    STR R2, R3, #0 
		    
		    AND R2, R2, #0 
		    AND R3, R3, #0
		    
		    ; the second program's state must be swapped with the first's 
	        LD R2, P1PSR
		    STR R2, R6, #0 
		
		    ADD R6, R6, #-1 
		    AND R2, R2, #0 
	        LD R2, P1PC
		    STR R2, R6, #0 
		    
		    LD R1, P1R1
		    LD R2, P1R2 
		    LD R3, P1R3
		    LD R4, P1R4 
		    LD R5, P1R5
		    LD R7, P1R7 
		    
		; 3. Reads the typed character into R0 
		    LDI R0, KBDR 
		
		    ; 4. Returns to the caller of TRAP26 
		    RTI
		
		

; Program 1's data:
P1R1        .FILL x0000     ; TODO: Use these memory locations to save and
P1R2        .FILL x0000     ;       restore the first program's state.
P1R3        .FILL x0000
P1R4        .FILL x0000
P1R5        .FILL x0000
P1R7        .FILL x0000
P1PC        .FILL x0000
P1PSR       .FILL x0000

; Program 2's data:
P2R0        .FILL x0000     ; TODO: Use these memory locations to save and
P2R1        .FILL x0000     ;       restore the second program's state.
P2R2        .FILL x0000
P2R3        .FILL x0000
P2R4        .FILL x0000
P2R5        .FILL x0000
P2R7        .FILL x0000
P2PC        .FILL x4000     ; Initially, Program 2's PC is 0x4000.
P2PSR       .FILL x8002     ; Initially, Program 2 is unprivileged.  

; Shared data:
SAVEIV      .FILL x0000     ; TODO: Use this memory location to save and
                            ;       restore the keyboard's IVT entry.

; Shared constants:
KBIV        .FILL x0180     ; The keyboard's interrupt vector
KBSR        .FILL xFE00     ; The Keyboard Status Register
KBDR        .FILL xFE02     ; The Keyboard Data Register
KBIMASK     .FILL x4000     ; The keyboard interrupt bit's mask


            .END
