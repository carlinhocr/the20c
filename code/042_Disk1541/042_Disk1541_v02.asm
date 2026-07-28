;===============================================================================
;
;   IEC SERIAL BUS DRIVER FOR COMMODORE 1541 DISK DRIVE
;   Written for a bare-metal 6502 system (no kernel/OS)
;
;===============================================================================
;
;   HARDWARE SETUP:
;   ---------------
;   CPU:    MOS 6502
;   RAM:    $0000 - $3FFF  (16 KB)
;   ROM:    $8000 - $FFFF  (32 KB, this program lives here)
;   VIA:    6522 VIA at base address $6000
;
;   IEC BUS WIRING (VIA Port B):
;   ---------------
;   The Commodore IEC serial bus uses three signal lines 
;   (active-low, open-collector with external pull-up resistors     ):
;
;       ATN  (Attention)  - directly controls ATN output
;       CLK  (Clock)      - directly controls CLK output
;       DATA (Data)       - directly controls DATA output
;
;   VIA Port B pin assignments:
;       PB0 = DATA OUT   (directly controls DATA output via transistor/buffer) use pullUp to 5v
;       PB1 = CLK  OUT   (directly controls CLK  output via transistor/buffer) use pullUp to 5v 
;       PB2 = ATN  OUT   (directly controls ATN  output via transistor/buffer) use pullUp to 5v 
;       PB3 = DATA IN    (          input,      reads actual bus state     )
;       PB4 = CLK  IN    (          input,      reads actual bus state     )
;
;    IMPORTANT : The IEC bus is active-low with open-collector drivers.
;       - Writing a 1 to an output pin pulls that line LOW  (asserted).
;       - Writing a 0 to an output pin releases the line HIGH (via pull-up).
;       - Reading a 0 on an input pin means the line is HIGH (released).
;       - Reading a 1 on an input pin means the line is LOW  (asserted).
;
;   IEC BUS PROTOCOL OVERVIEW:
;   --------------------------
;   The IEC (IEC-625 / IEEE-488 simplified) serial bus is a      bit-serial     
;   protocol used by Commodore computers to talk to peripherals (drives,
;   printers). Communication follows a talker/listener model:
;
;   1. The computer is always the CONTROLLER. It asserts ATN to send
;      command bytes (device addresses, secondary addresses, etc.).
;   2. Devices become TALKERS or LISTENERS depending on the command.
;   3. Data is transferred one bit at a time, LSB first, using CLK and
;      DATA handshaking.
;   4. The standard device number for the first 1541 drive is #8.
;
;   PROTOCOL PHASES:
;   ----------------
;   OPEN:    Send LISTEN + secondary address (with OPEN flag) + filename
;   WRITE:   Send LISTEN + secondary address, then send data bytes
;   READ:    Send TALK   + secondary address, then receive data bytes
;   CLOSE:   Send LISTEN + secondary address (with CLOSE flag)
;   UNTALK:  Command $5F - tells talker to stop
;   UNLISTEN: Command $3F - tells all listeners to stop
;
;   COMMAND BYTE ENCODING:
;   ----------------------
;   LISTEN  = $20 + device number  (e.g. $28 for device 8)
;   TALK    = $40 + device number  (e.g. $48 for device 8)
;   UNLISTEN= $3F
;   UNTALK  = $5F
;   Secondary address (OPEN)  = $F0 + channel  (e.g. $F0 for channel 0)
;   Secondary address (CLOSE) = $E0 + channel  (e.g. $E0 for channel 0)
;   Secondary address (DATA)  = $60 + channel  (e.g. $60 for channel 0)
;
;===============================================================================


;===============================================================================
; 6522 VIA REGISTER DEFINITIONS
;===============================================================================
; The 6522 Versatile Interface Adapter has 16 registers mapped starting
; at the base address. We only use a subset for IEC communication.

VIA_BASE    = $6000             ; Base address of the 6522 VIA

VIA_PORTB   = VIA_BASE + $00   ; Port B data register (    read/write bus lines    )
VIA_PORTA   = VIA_BASE + $01   ; Port A data register (not used here)
VIA_DDRB    = VIA_BASE + $02   ; Data Direction Register B (1=output, 0=input)
VIA_DDRA    = VIA_BASE + $03   ; Data Direction Register A (not used here)
VIA_T1CL    = VIA_BASE + $04   ; Timer 1 counter low  (for timing delays)
VIA_T1CH    = VIA_BASE + $05   ; Timer 1 counter high (for timing delays)
VIA_T1LL    = VIA_BASE + $06   ; Timer 1 latch low
VIA_T1LH    = VIA_BASE + $07   ; Timer 1 latch high
VIA_ACR     = VIA_BASE + $0B   ; Auxiliary Control Register
VIA_IFR     = VIA_BASE + $0D   ; Interrupt Flag Register
VIA_IER     = VIA_BASE + $0E   ; Interrupt Enable Register


;===============================================================================
; IEC BUS BIT MASKS
;===============================================================================
; These masks correspond to the VIA Port B pin assignments described above.

; --- Output pins (directly control bus lines) ---
DATA_OUT    = %00000001         ; PB0 - DATA output (1 = pull low, 0 = release)
CLK_OUT     = %00000010         ; PB1 - CLK  output (1 = pull low, 0 = release)
ATN_OUT     = %00000100         ; PB2 - ATN  output (1 = pull low, 0 = release)

; --- Input pins (read the actual bus state) ---
DATA_IN     = %00001000         ; PB3 - DATA input (1 = line is low/asserted)
CLK_IN      = %00010000         ; PB4 - CLK  input (1 = line is low/asserted)

; --- Combined masks ---
ALL_OUTPUTS = DATA_OUT + CLK_OUT + ATN_OUT  ; = %00000111
ALL_RELEASE = %00000000         ; All outputs released (lines go high via pull-ups)


;===============================================================================
; IEC DEVICE AND COMMAND CONSTANTS
;===============================================================================
; These are the standard IEC bus command bytes. Device 8 is the default
; for the first Commodore 1541 disk drive.

DEVICE_NUM  = 8                 ; Default 1541 device number
DEV_LISTEN  = $20 + DEVICE_NUM ; $28 - LISTEN command for device 8
DEV_TALK    = $40 + DEVICE_NUM ; $48 - TALK command for device 8
CMD_UNLISTEN= $3F               ; Universal UNLISTEN (all devices stop listening)
CMD_UNTALK  = $5F               ; Universal UNTALK  (talker stops talking)

; Secondary address flags (OR'd with channel number 0-15):
SA_OPEN     = $F0               ; Secondary address for OPEN  (+ channel)
SA_CLOSE    = $E0               ; Secondary address for CLOSE (+ channel)
SA_DATA     = $60               ; Secondary address for DATA  (+ channel)

; Channel numbers:
CHAN_LOAD    = 0                 ; Channel 0 = LOAD (read file)
CHAN_SAVE    = 1                 ; Channel 1 = SAVE (write file)
CHAN_CMD     = 15                ; Channel 15 = command/status channel


;===============================================================================
; ZERO PAGE VARIABLES
;===============================================================================
; Zero page ($00-$FF) is precious on 6502 - it allows faster addressing
; modes (zero-page addressing is 1 byte shorter and 1 cycle faster than
; absolute addressing). We use it for frequently-accessed variables.

            .org $0000

; --- Pointer for indirect addressing (used to access RAM buffers) ---
ZP_PTR_LO   .byte $00          ; Low byte of 16-bit pointer
ZP_PTR_HI   .byte $00          ; High byte of 16-bit pointer

; --- IEC bus state variables ---
IEC_STATUS   .byte $00          ; Status byte (0=OK, bit 1=timeout, bit 6=EOI)
IEC_EOI_FLAG .byte $00          ; End-Or-Identify flag (nonzero = last byte)

; --- File operation variables ---
FILE_SIZE_LO .byte $00          ; Low byte of bytes transferred
FILE_SIZE_HI .byte $00          ; High byte of bytes transferred

; --- Temporary storage ---
ZP_TEMP      .byte $00          ; General-purpose temporary byte
ZP_BYTE      .byte $00          ; Byte being sent or received
ZP_COUNT     .byte $00          ; Bit counter for serial transfer


;===============================================================================
; RAM BUFFER AREA
;===============================================================================
; We designate a general-purpose buffer in RAM for file data.
; This sits above the zero page and stack ($0100-$01FF).

BUFFER_START = $0200            ; Start of file data buffer
BUFFER_END   = $3FFF            ; End of available RAM
BUFFER_SIZE  = BUFFER_END - BUFFER_START + 1  ; = 15,872 bytes max


;===============================================================================
; ROM CODE STARTS HERE
;===============================================================================
; The program resides in ROM at $8000-$FFFF. The 6502 reads its reset
; vector from $FFFC-$FFFD, which points to our RESET entry point.

            .org $8000


;===============================================================================
;===============================================================================
;
;   SECTION 1: INITIALIZATION
;
;   This section sets up the hardware after power-on or reset.
;   It configures the 6522 VIA port directions, releases all IEC bus
;   lines, and clears our status variables.
;
;===============================================================================
;===============================================================================

RESET:
;-----------------------------------------------------------------------
; RESET - Entry point after power-on (jumped to via reset vector at $FFFC)
;
; We must:
;   1. Initialize the 6502 CPU state
;   2. Configure the VIA for IEC communication
;   3. Release all IEC bus lines
;   4. Clear status variables
;-----------------------------------------------------------------------

            SEI                 ; Disable interrupts - we do everything in polling
            CLD                 ; Clear decimal mode (safety: ensure binary arithmetic)
            LDX #$FF
            TXS                 ; Initialize stack pointer to $01FF

            ; --- Configure VIA Port B data direction ---
            ; PB0-PB2 are outputs (DATA_OUT, CLK_OUT, ATN_OUT)
            ; PB3-PB7 are inputs  (DATA_IN, CLK_IN, and unused)
            LDA #ALL_OUTPUTS    ; = %00000111
            STA VIA_DDRB        ; Set direction: bits 0-2 output, bits 3-7 input

            ; --- Configure VIA Timer 1 for one-shot mode ---
            ; We use Timer 1 for microsecond-level timing delays.
            ; ACR bit 6 = 0 means one-shot mode for Timer 1.
            LDA VIA_ACR
            AND #%00111111      ; Clear bits 7-6 (Timer 1 one-shot, no PB7 output)
            STA VIA_ACR

            ; --- Release all IEC bus lines ---
            ; Writing 0 to all output bits releases DATA, CLK, and ATN.
            ; The external pull-up resistors will bring them HIGH.
            LDA #ALL_RELEASE
            STA VIA_PORTB

            ; --- Clear status variables ---
            LDA #$00
            STA IEC_STATUS      ; No errors
            STA IEC_EOI_FLAG    ; No EOI pending
            STA FILE_SIZE_LO    ; Zero bytes transferred
            STA FILE_SIZE_HI

            ; --- Small delay to let bus settle after power-on ---
            JSR DELAY_1MS
            JSR DELAY_1MS

            ; Initialization complete. Fall through or jump to main program.
            JMP MAIN


;===============================================================================
;===============================================================================
;
;   SECTION 2: LOW-LEVEL IEC BUS LINE CONTROL
;
;   These routines directly manipulate the three IEC bus lines (ATN,
;   CLK, DATA) through the VIA Port B register. They use read-modify-
;   write to change only the desired bit without affecting others.
;
;    BUS   POLARITY   REMINDER:
;   Setting an output bit to 1 = pulls line LOW (asserted)
;   Setting an output bit to 0 = releases line HIGH (pull-up)
;   Reading an input bit of 1 = line is LOW (other device asserts)
;   Reading an input bit of 0 = line is HIGH (released)
;
;===============================================================================
;===============================================================================

;-----------------------------------------------------------------------
; ATN_ASSERT - Pull the ATN line LOW (active)
;
; ATN (Attention) is asserted by the controller to signal that the
; following bytes on the bus are COMMAND bytes (addresses), not data.
; All devices on the bus must listen when ATN is asserted.
;-----------------------------------------------------------------------
ATN_ASSERT:
            LDA VIA_PORTB       ; Read current port state
            ORA #ATN_OUT        ; Set bit 2 = 1 (pull ATN low)
            STA VIA_PORTB       ; Write back
            RTS

;-----------------------------------------------------------------------
; ATN_RELEASE - Release the ATN line (goes HIGH via pull-up)
;
; After sending command bytes, we release ATN to signal that
; subsequent bytes are DATA, not commands.
;-----------------------------------------------------------------------
ATN_RELEASE:
            LDA VIA_PORTB
            AND #$FF-ATN_OUT    ; Clear bit 2 = 0 (release ATN)
            STA VIA_PORTB
            RTS

;-----------------------------------------------------------------------
; CLK_ASSERT - Pull the CLK line LOW
;
; The clock line is used for handshaking during byte transfer.
; The talker controls CLK to frame each bit.
;-----------------------------------------------------------------------
CLK_ASSERT:
            LDA VIA_PORTB
            ORA #CLK_OUT        ; Set bit 1 = 1 (pull CLK low)
            STA VIA_PORTB
            RTS

;-----------------------------------------------------------------------
; CLK_RELEASE - Release the CLK line (goes HIGH via pull-up)
;-----------------------------------------------------------------------
CLK_RELEASE:
            LDA VIA_PORTB
            AND #$FF-CLK_OUT    ; Clear bit 1 = 0 (release CLK)
            STA VIA_PORTB
            RTS

;-----------------------------------------------------------------------
; DATA_ASSERT - Pull the DATA line LOW
;
; The data line carries the actual bits during transfer. Both the
; talker and listener use DATA for handshaking as well.
;-----------------------------------------------------------------------
DATA_ASSERT:
            LDA VIA_PORTB
            ORA #DATA_OUT       ; Set bit 0 = 1 (pull DATA low)
            STA VIA_PORTB
            RTS

;-----------------------------------------------------------------------
; DATA_RELEASE - Release the DATA line (goes HIGH via pull-up)
;-----------------------------------------------------------------------
DATA_RELEASE:
            LDA VIA_PORTB
            AND #$FF-DATA_OUT   ; Clear bit 0 = 0 (release DATA)
            STA VIA_PORTB
            RTS

;-----------------------------------------------------------------------
; READ_DATA - Read the current state of the DATA line
;
; Returns: Carry flag = 1 if DATA is LOW (asserted by a device)
;          Carry flag = 0 if DATA is HIGH (released)
;-----------------------------------------------------------------------
READ_DATA:
            LDA VIA_PORTB       ; Read port
            AND #DATA_IN        ; Isolate bit 3 (DATA input)
            BEQ .data_high      ; If bit is 0, line is HIGH (released)
            SEC                 ; Bit is 1, line is LOW (asserted) -> set carry
            RTS
.data_high:
            CLC                 ; Line is HIGH (released) -> clear carry
            RTS

;-----------------------------------------------------------------------
; READ_CLK - Read the current state of the CLK line
;
; Returns: Carry flag = 1 if CLK is LOW (asserted)
;          Carry flag = 0 if CLK is HIGH (released)
;-----------------------------------------------------------------------
READ_CLK:
            LDA VIA_PORTB       ; Read port
            AND #CLK_IN         ; Isolate bit 4 (CLK input)
            BEQ .clk_high       ; If bit is 0, line is HIGH (released)
            SEC                 ; Line is LOW -> carry set
            RTS
.clk_high:
            CLC                 ; Line is HIGH -> carry clear
            RTS


;===============================================================================
;===============================================================================
;
;   SECTION 3: TIMING DELAY ROUTINES
;
;   The IEC protocol requires specific timing for bit framing and
;   handshaking. We use the VIA Timer 1 in one-shot mode for accurate
;   microsecond delays, and a software loop for millisecond delays.
;
;   At 1 MHz CPU clock, the VIA timer decrements once per microsecond.
;
;===============================================================================
;===============================================================================

;-----------------------------------------------------------------------
; DELAY_US - Delay for a specified number of microseconds
;
; Input:  A = number of microseconds to delay (1-255)
;
; Uses VIA Timer 1 in one-shot mode. Writing to T1CH starts the
; countdown. When the counter reaches zero, bit 6 of the IFR
; (Interrupt Flag Register) is set.
;
; Note: There is some overhead (~5-10 cycles) for the JSR, register
; setup, and polling, so very short delays (< 10 us) will be slightly
; longer than requested. This is acceptable for IEC timing.
;-----------------------------------------------------------------------
DELAY_US:
            STA VIA_T1CL        ; Load low byte of delay count
            LDA #$00
            STA VIA_T1CH        ; Load high byte (0) and START the timer

.wait_timer:
            LDA VIA_IFR         ; Read interrupt flags
            AND #%01000000      ; Check bit 6 (Timer 1 flag)
            BEQ .wait_timer     ; Loop until timer fires
            RTS                 ; Timer expired, return

;-----------------------------------------------------------------------
; DELAY_1MS - Delay approximately 1 millisecond
;
; At 1 MHz, 1 ms = 1000 cycles. We use a nested loop.
; Inner loop: 5 cycles x 200 iterations = 1000 cycles approximately.
;-----------------------------------------------------------------------
DELAY_1MS:
            TXA                 ; Save X register
            PHA                 ; Push A (which holds X) onto stack
            LDX #200            ; Loop counter
.loop_1ms:
            NOP                 ; 2 cycles \
            NOP                 ; 2 cycles  } = 5 cycles per iteration
            DEX                 ; 2 cycles /   (approximate)
            BNE .loop_1ms       ; 3/2 cycles
            PLA                 ; Pull saved X value
            TAX                 ; Restore X register
            RTS

;-----------------------------------------------------------------------
; DELAY_LONG - Delay approximately A x 1ms
;
; Input:  A = number of milliseconds to delay
; Used for protocol timeouts and settling times.
;-----------------------------------------------------------------------
DELAY_LONG:
            PHA                 ; Save count
.loop_long:
            JSR DELAY_1MS       ; Delay 1 ms
            SEC
            PLA                 ; Get count
            SBC #$01            ; Decrement
            PHA                 ; Save it back
            BNE .loop_long      ; Loop if not zero
            PLA                 ; Clean stack
            RTS


;===============================================================================
;===============================================================================
;
;   SECTION 4: IEC BUS BYTE TRANSFER (LOW LEVEL)
;
;   These are the core routines that send and receive individual bytes
;   on the IEC bus. They implement the bit-level serial protocol:
;
;   SENDING A BYTE (as talker):
;   ---------------------------
;   1. We hold CLK LOW to indicate "I am ready to send" (talker ready)
;   2. Wait for listener to release DATA (listener is ready)
;   3. For each of 8 bits (LSB first):
;      a. Release CLK (CLK goes HIGH)
;      b. Put the data bit on the DATA line
;      c. After ~60us, pull CLK LOW (clock the bit in)
;      d. Release DATA
;   4. After all 8 bits, wait for listener to acknowledge by pulling
;      DATA LOW.
;
;   RECEIVING A BYTE (as listener):
;   -------------------------------
;   1. Release DATA to signal "I am ready to receive"
;   2. Wait for talker to release CLK (CLK goes HIGH = "bit ready")
;   3. For each of 8 bits (LSB first):
;      a. Wait for CLK to go HIGH (bit is now on DATA line)
;      b. Read the DATA line and shift into our byte
;      c. Wait for CLK to go LOW (end of bit)
;   4. After all 8 bits, pull DATA LOW to acknowledge
;
;   EOI (End Or Identify):
;   ----------------------
;   EOI signals that the current byte is the LAST byte of the
;   transmission. The talker signals EOI by holding CLK LOW for
;   longer than 200us before the first bit. The listener detects
;   this timeout and acknowledges EOI by briefly pulling DATA LOW
;   then releasing it.
;
;===============================================================================
;===============================================================================

;-----------------------------------------------------------------------
; IEC_SEND_BYTE_ATN - Send a byte under ATN (command byte)
;
; Input:  A = byte to send
;
; When ATN is asserted, all devices on the bus listen. This is used
; to send LISTEN, TALK, UNLISTEN, UNTALK, and secondary address bytes.
;
; The protocol is the same as normal byte send, except ATN is held
; low throughout the entire transfer.
;-----------------------------------------------------------------------
IEC_SEND_BYTE_ATN:
            STA ZP_BYTE         ; Save the byte to send

            ; --- Assert ATN and CLK, release DATA ---
            ; ATN tells all devices: "this is a command byte"
            ; CLK LOW tells devices: "talker is holding the bus"
            JSR ATN_ASSERT
            JSR CLK_ASSERT
            JSR DATA_RELEASE

            ; --- Wait for at least one device to respond ---
            ; Devices respond by pulling DATA LOW within 1ms.
            ; If no device responds, we have a "device not present" error.
            LDA #250            ; Timeout: 250 ms max
            STA ZP_TEMP
.wait_device:
            JSR READ_DATA       ; Check DATA line
            BCS .device_found   ; DATA is LOW -> a device responded!
            JSR DELAY_1MS       ; Wait 1 ms
            DEC ZP_TEMP         ; Decrement timeout counter
            BNE .wait_device    ; Keep waiting...

            ; --- Timeout! No device responded ---
            LDA #$80            ; Set bit 7 = "device not present" in status
            ORA IEC_STATUS
            STA IEC_STATUS
            JSR ATN_RELEASE     ; Clean up: release ATN
            JSR CLK_RELEASE     ; Release CLK
            RTS                 ; Return with error

.device_found:
            ; --- Device is present, now send the 8 bits ---
            ; The byte in ZP_BYTE is sent LSB first.
            LDA #$08
            STA ZP_COUNT        ; 8 bits to send

.atn_send_loop:
            ; --- Release CLK briefly to signal "here comes a bit" ---
            JSR CLK_RELEASE     ; CLK goes HIGH

            ; --- Put the next data bit on the DATA line ---
            ; Shift the LSB out of ZP_BYTE into carry
            LSR ZP_BYTE         ; Bit 0 -> Carry, shift right
            BCS .atn_bit_is_1   ; If carry=1, the bit is 1 (DATA should be HIGH)

            ; Bit is 0: Assert DATA (pull LOW = logic 0 on IEC bus)
            JSR DATA_ASSERT
            JMP .atn_bit_placed

.atn_bit_is_1:
            ; Bit is 1: Release DATA (goes HIGH = logic 1 on IEC bus)
            JSR DATA_RELEASE

.atn_bit_placed:
            ; --- Hold the data stable for ~60 microseconds ---
            LDA #60
            JSR DELAY_US

            ; --- Pull CLK LOW to "clock in" the bit ---
            ; The listener reads DATA on this falling edge of CLK.
            JSR CLK_ASSERT

            ; --- Release DATA line (prepare for next bit or handshake) ---
            JSR DATA_RELEASE

            ; --- Brief pause between bits ---
            LDA #60
            JSR DELAY_US

            ; --- Loop for all 8 bits ---
            DEC ZP_COUNT
            BNE .atn_send_loop

            ; --- All 8 bits sent. Wait for listener acknowledgment ---
            ; The listener(s) pull DATA LOW within 1ms to say "I got it."
            LDA #250            ; Timeout counter
            STA ZP_TEMP
.atn_wait_ack:
            JSR READ_DATA
            BCS .atn_ack_ok     ; DATA is LOW = acknowledged
            JSR DELAY_1MS
            DEC ZP_TEMP
            BNE .atn_wait_ack

            ; Timeout waiting for ACK
            LDA #$03            ; Set error bits in status
            ORA IEC_STATUS
            STA IEC_STATUS

.atn_ack_ok:
            ; The byte was sent successfully under ATN.
            ; NOTE: We do NOT release ATN here - the caller decides when
            ; to release ATN (it may want to send more command bytes).
            RTS


;-----------------------------------------------------------------------
; IEC_SEND_BYTE - Send a data byte (ATN is NOT asserted)
;
; Input:  A = byte to send
;         IEC_EOI_FLAG = nonzero if this is the last byte (signal EOI)
;
; This is used after the command phase to send actual file data to
; a listening device. The protocol is similar to ATN sending but:
;   - ATN is not asserted
;   - EOI signaling is used for the last byte
;-----------------------------------------------------------------------
IEC_SEND_BYTE:
            STA ZP_BYTE         ; Save byte to send

            ; --- Pull CLK LOW (talker holds the bus) ---
            JSR CLK_ASSERT
            JSR DATA_RELEASE    ; Make sure we're not holding DATA

            ; --- Wait for listener to release DATA ---
            ; Listener releases DATA to say "I'm ready for the next byte"
            LDA #250
            STA ZP_TEMP
.send_wait_ready:
            JSR READ_DATA
            BCC .listener_ready ; DATA is HIGH (released) = listener ready
            JSR DELAY_1MS
            DEC ZP_TEMP
            BNE .send_wait_ready

            ; Timeout - listener not ready
            LDA #$03
            ORA IEC_STATUS
            STA IEC_STATUS
            RTS

.listener_ready:
            ; --- Check if we need to signal EOI (last byte) ---
            LDA IEC_EOI_FLAG
            BEQ .no_eoi_send    ; Zero = not last byte, skip EOI

            ; --- EOI SIGNALING ---
            ; To signal EOI, the talker keeps CLK LOW for > 200us
            ; without releasing it. The listener will timeout waiting
            ; for CLK to go HIGH, and interpret this as "EOI coming."
            ;
            ; The listener acknowledges EOI by briefly pulsing DATA LOW
            ; and then releasing it. We wait for that pulse.
            LDA #250            ; Wait ~250us (exceeds 200us EOI threshold)
            JSR DELAY_US

            ; Wait for listener's EOI acknowledgment (DATA goes LOW then HIGH)
            LDA #100
            STA ZP_TEMP
.wait_eoi_ack:
            JSR READ_DATA
            BCS .eoi_ack_seen   ; DATA went LOW = listener ack'd EOI
            DEC ZP_TEMP
            BNE .wait_eoi_ack

.eoi_ack_seen:
            ; Wait for listener to release DATA again
            LDA #100
            STA ZP_TEMP
.wait_eoi_done:
            JSR READ_DATA
            BCC .eoi_handshake_done ; DATA is HIGH again = ready
            DEC ZP_TEMP
            BNE .wait_eoi_done

.eoi_handshake_done:
.no_eoi_send:
            ; --- Now send the 8 data bits, LSB first ---
            LDA #$08
            STA ZP_COUNT

.send_bit_loop:
            ; Release CLK (goes HIGH) to signal "bit is coming"
            JSR CLK_RELEASE

            ; Place the data bit on the DATA line
            LSR ZP_BYTE         ; Shift LSB into carry
            BCS .send_bit_1

            JSR DATA_ASSERT     ; Bit is 0: pull DATA LOW
            JMP .send_bit_placed

.send_bit_1:
            JSR DATA_RELEASE    ; Bit is 1: release DATA (HIGH)

.send_bit_placed:
            ; Hold for ~60us so listener can read it
            LDA #60
            JSR DELAY_US

            ; Pull CLK LOW to clock the bit in
            JSR CLK_ASSERT

            ; Release DATA
            JSR DATA_RELEASE

            ; Inter-bit delay
            LDA #60
            JSR DELAY_US

            DEC ZP_COUNT
            BNE .send_bit_loop

            ; --- Wait for listener acknowledgment (DATA goes LOW) ---
            LDA #250
            STA ZP_TEMP
.send_wait_ack:
            JSR READ_DATA
            BCS .send_ack_ok    ; DATA LOW = acknowledged
            JSR DELAY_1MS
            DEC ZP_TEMP
            BNE .send_wait_ack

            ; Timeout
            LDA #$03
            ORA IEC_STATUS
            STA IEC_STATUS

.send_ack_ok:
            RTS


;-----------------------------------------------------------------------
; IEC_RECEIVE_BYTE - Receive a byte from the talker (we are listener)
;
; Output: A = received byte
;         IEC_EOI_FLAG = nonzero if this was the last byte (EOI)
;
; Protocol:
;   1. Release DATA to signal "listener ready"
;   2. Wait for talker to release CLK (CLK goes HIGH)
;      - If CLK stays LOW for > 200us, it's an EOI signal
;   3. Read 8 bits from DATA, clocked by CLK transitions
;   4. Pull DATA LOW to acknowledge receipt
;-----------------------------------------------------------------------
IEC_RECEIVE_BYTE:
            LDA #$00
            STA IEC_EOI_FLAG    ; Clear EOI flag
            STA ZP_BYTE         ; Clear receive buffer

            ; --- Release DATA to signal "listener ready" ---
            JSR DATA_RELEASE

            ; --- Wait for talker to release CLK (CLK goes HIGH) ---
            ; If CLK stays LOW for > 200us, the talker is signaling EOI.
            ; We use a timeout counter to detect this.
            LDA #200            ; ~200us timeout for EOI detection
            STA ZP_TEMP

.recv_wait_clk:
            JSR READ_CLK
            BCC .clk_went_high  ; CLK is HIGH = talker released it, bit coming

            ; CLK is still LOW - decrement timeout
            ; (Each loop iteration takes ~10-15 cycles = ~10-15us at 1MHz)
            DEC ZP_TEMP
            BNE .recv_wait_clk

            ; --- CLK stayed LOW too long: this is an EOI signal ---
            ; The talker is telling us "this is the last byte."
            ; We must acknowledge by pulsing DATA LOW briefly.
            LDA #$FF
            STA IEC_EOI_FLAG    ; Set EOI flag

            ; Acknowledge EOI: pull DATA LOW for ~60us, then release
            JSR DATA_ASSERT
            LDA #60
            JSR DELAY_US
            JSR DATA_RELEASE

            ; Now wait for CLK to actually go HIGH (talker releases CLK
            ; after seeing our EOI acknowledgment)
            LDA #250
            STA ZP_TEMP
.wait_clk_after_eoi:
            JSR READ_CLK
            BCC .clk_went_high
            DEC ZP_TEMP
            BNE .wait_clk_after_eoi

            ; Timeout - serious error
            LDA #$02
            ORA IEC_STATUS
            STA IEC_STATUS
            LDA #$00
            RTS                 ; Return 0 with error status

.clk_went_high:
            ; --- CLK is HIGH: the talker has a bit ready ---
            ; Now receive 8 bits, LSB first.
            LDA #$08
            STA ZP_COUNT

.recv_bit_loop:
            ; --- Wait for CLK to go LOW (talker clocks the bit in) ---
            ; Data is valid while CLK is HIGH, and CLK going LOW marks
            ; the end of this bit period.

            ; First, wait for CLK HIGH (bit presentation)
            ; (It should already be HIGH from the previous handshake,
            ;  but we re-check for each subsequent bit.)
.wait_clk_high:
            JSR READ_CLK
            BCC .clk_is_high    ; CLK HIGH = data is on the bus
            JMP .wait_clk_high  ; Keep waiting

.clk_is_high:
            ; --- Read the DATA line ---
            ; If DATA is LOW  (asserted), the bit is 0.
            ; If DATA is HIGH (released), the bit is 1.
            JSR READ_DATA
            BCS .recv_got_zero  ; DATA LOW = bit is 0

            ; DATA is HIGH = bit is 1
            ; Shift a 1 into the MSB of ZP_BYTE and rotate right
            ; (We're receiving LSB first, so we shift right and put
            ;  new bits into bit 7, then after 8 shifts, it's correct)
            SEC                 ; Set carry (bit = 1)
            JMP .recv_shift

.recv_got_zero:
            CLC                 ; Clear carry (bit = 0)

.recv_shift:
            ROR ZP_BYTE         ; Rotate carry into bit 7, shift right

            ; --- Wait for CLK to go LOW (end of this bit) ---
.wait_clk_low:
            JSR READ_CLK
            BCS .clk_is_low     ; CLK LOW = bit period ended
            JMP .wait_clk_low

.clk_is_low:
            ; --- Next bit ---
            DEC ZP_COUNT
            BNE .recv_bit_loop

            ; --- All 8 bits received. Acknowledge by pulling DATA LOW ---
            JSR DATA_ASSERT

            ; Return the received byte in A
            LDA ZP_BYTE
            RTS


;===============================================================================
;===============================================================================
;
;   SECTION 5: IEC BUS TRANSACTION COMMANDS
;
;   These routines handle the higher-level bus commands: LISTEN, TALK,
;   UNLISTEN, UNTALK, and secondary addresses. They compose the
;   command phase of IEC communication.
;
;===============================================================================
;===============================================================================

;-----------------------------------------------------------------------
; IEC_LISTEN - Command device to become a LISTENER
;
; Sends the LISTEN command ($20 + device#) under ATN.
; After this, the device will accept data bytes we send.
;-----------------------------------------------------------------------
IEC_LISTEN:
            LDA #DEV_LISTEN     ; $28 for device 8
            JSR IEC_SEND_BYTE_ATN
            RTS

;-----------------------------------------------------------------------
; IEC_TALK - Command device to become a TALKER
;
; Sends the TALK command ($40 + device#) under ATN.
; After this, the device will send data bytes to us.
;-----------------------------------------------------------------------
IEC_TALK:
            LDA #DEV_TALK       ; $48 for device 8
            JSR IEC_SEND_BYTE_ATN
            RTS

;-----------------------------------------------------------------------
; IEC_SEND_SECONDARY - Send a secondary address byte under ATN
;
; Input:  A = secondary address byte (e.g. $F0 for OPEN channel 0)
;
; Secondary addresses tell the device which channel/operation to use.
;-----------------------------------------------------------------------
IEC_SEND_SECONDARY:
            JSR IEC_SEND_BYTE_ATN
            RTS

;-----------------------------------------------------------------------
; IEC_UNLISTEN - Send the universal UNLISTEN command
;
; Tells all listening devices to stop listening.
; Releases ATN after sending.
;-----------------------------------------------------------------------
IEC_UNLISTEN:
            LDA #CMD_UNLISTEN   ; $3F
            JSR IEC_SEND_BYTE_ATN
            JSR ATN_RELEASE     ; Release ATN - command phase done
            JSR CLK_RELEASE     ; Release CLK
            RTS

;-----------------------------------------------------------------------
; IEC_UNTALK - Send the universal UNTALK command
;
; Tells the current talker to stop talking.
; Releases ATN after sending.
;-----------------------------------------------------------------------
IEC_UNTALK:
            LDA #CMD_UNTALK     ; $5F
            JSR IEC_SEND_BYTE_ATN
            JSR ATN_RELEASE     ; Release ATN
            JSR CLK_RELEASE     ; Release CLK
            RTS

;-----------------------------------------------------------------------
; IEC_TURNAROUND - "Turn the bus around" after TALK command
;
; After we send a TALK command + secondary address under ATN, we need
; to switch roles: we were the talker (sending commands), now the
; device becomes the talker and we become the listener.
;
; Protocol:
;   1. Release ATN (end of command phase)
;   2. Release CLK (we're no longer the talker)
;   3. Assert DATA (signal "listener not ready yet")
;   4. Wait for device to assert CLK (device is now talker)
;-----------------------------------------------------------------------
IEC_TURNAROUND:
            JSR ATN_RELEASE     ; End command phase
            JSR CLK_RELEASE     ; We stop driving CLK (device takes over)
            JSR DATA_ASSERT     ; We hold DATA LOW ("not ready yet")

            ; Wait for device to pull CLK LOW (it's now the talker)
            LDA #250
            STA ZP_TEMP
.turn_wait:
            JSR READ_CLK
            BCS .turn_done      ; CLK is LOW = device has taken over
            JSR DELAY_1MS
            DEC ZP_TEMP
            BNE .turn_wait

            ; Timeout
            LDA #$02
            ORA IEC_STATUS
            STA IEC_STATUS

.turn_done:
            RTS


;===============================================================================
;===============================================================================
;
;   SECTION 6: FILE OPERATIONS - OPEN, CLOSE, READ, WRITE
;
;   These are the high-level routines that implement complete file
;   operations by sequencing the appropriate IEC commands.
;
;===============================================================================
;===============================================================================

;-----------------------------------------------------------------------
; IEC_OPEN_FILE - Open a file on the disk drive
;
; Input:  ZP_PTR_LO/HI = pointer to null-terminated filename string
;         X = channel number (0=load, 1=save, 15=command)
;
; Protocol sequence:
;   1. LISTEN device
;   2. Send secondary address with OPEN flag ($F0 + channel)
;   3. Send filename bytes (each byte under ATN released)
;   4. UNLISTEN
;
; The filename string can include drive number and file type, e.g.:
;   "0:MYFILE,P,R"  - open PRG file for reading on drive 0
;   "0:MYFILE,P,W"  - open PRG file for writing on drive 0
;   "MYFILE"         - simple filename (defaults vary)
;-----------------------------------------------------------------------
IEC_OPEN_FILE:
            STX ZP_TEMP         ; Save channel number

            ; Clear status
            LDA #$00
            STA IEC_STATUS

            ; --- Step 1: LISTEN ---
            JSR IEC_LISTEN
            LDA IEC_STATUS
            BNE .open_err       ; Error? (device not present)

            ; --- Step 2: Send OPEN secondary address ---
            LDA #SA_OPEN        ; $F0
            ORA ZP_TEMP         ; Add channel number
            JSR IEC_SEND_SECONDARY

            ; --- Step 3: Release ATN and send the filename as data ---
            ; After the secondary address, we release ATN so the filename
            ; bytes are treated as data (not commands) by the device.
            JSR ATN_RELEASE
            JSR CLK_ASSERT      ; We remain the talker

            ; Send each character of the filename
            LDY #$00            ; Index into filename string
.open_name_loop:
            LDA (ZP_PTR_LO),Y  ; Load next character using indirect indexed
            BEQ .open_name_done ; Null terminator? We're done.

            ; Check if next char is the last (for EOI signaling)
            INY
            PHA                 ; Save current char
            LDA (ZP_PTR_LO),Y  ; Peek at next char
            BNE .not_last_char  ; Not null? Not the last char.

            ; This IS the last character - set EOI flag
            LDA #$FF
            STA IEC_EOI_FLAG
            JMP .send_name_char

.not_last_char:
            LDA #$00
            STA IEC_EOI_FLAG    ; Not the last character

.send_name_char:
            PLA                 ; Restore current char
            JSR IEC_SEND_BYTE   ; Send it
            LDA IEC_STATUS
            BNE .open_err       ; Check for errors
            JMP .open_name_loop

.open_name_done:
            ; --- Step 4: UNLISTEN to complete the OPEN ---
            JSR IEC_UNLISTEN

.open_err:
            RTS


;-----------------------------------------------------------------------
; IEC_CLOSE_FILE - Close a previously opened file
;
; Input:  X = channel number to close
;
; Protocol:
;   1. LISTEN device
;   2. Send secondary address with CLOSE flag ($E0 + channel)
;   3. UNLISTEN
;-----------------------------------------------------------------------
IEC_CLOSE_FILE:
            STX ZP_TEMP         ; Save channel number

            LDA #$00
            STA IEC_STATUS

            ; LISTEN
            JSR IEC_LISTEN

            ; Send CLOSE secondary address
            LDA #SA_CLOSE       ; $E0
            ORA ZP_TEMP         ; Add channel number
            JSR IEC_SEND_SECONDARY

            ; UNLISTEN
            JSR IEC_UNLISTEN
            RTS


;===============================================================================
;===============================================================================
;
;   SECTION 7: READ FILE FROM DISK TO RAM
;
;   IEC_READ_FILE - Complete routine to read a file from the 1541
;   disk drive into RAM memory.
;
;   Input:
;     ZP_PTR_LO/HI = pointer to null-terminated filename string
;     The data will be stored starting at BUFFER_START ($0200)
;
;   Output:
;     FILE_SIZE_LO/HI = number of bytes read
;     IEC_STATUS = error status (0 = success)
;     Data stored at BUFFER_START through BUFFER_START + FILE_SIZE - 1
;
;   Complete protocol sequence:
;     1. OPEN the file for reading (LISTEN + OPEN + filename + UNLISTEN)
;     2. TALK  the device on the data channel
;     3. Turn the bus around (device becomes talker)
;     4. Receive bytes in a loop until EOI is signaled
;     5. UNTALK the device
;     6. CLOSE the file
;
;===============================================================================
;===============================================================================

IEC_READ_FILE:
            ; --- Clear counters ---
            LDA #$00
            STA FILE_SIZE_LO
            STA FILE_SIZE_HI
            STA IEC_STATUS

            ; --- Step 1: OPEN the file for reading ---
            ; Channel 0 is traditionally used for LOADing (reading).
            ; The filename should include ",P,R" or ",S,R" for read mode
            ; if needed, e.g. "0:MYFILE,P,R"
            LDX #CHAN_LOAD      ; Channel 0
            JSR IEC_OPEN_FILE

            ; Check for errors from OPEN
            LDA IEC_STATUS
            BEQ .read_opened_ok
            JMP .read_error     ; OPEN failed

.read_opened_ok:
            ; --- Step 2: TALK the device on the data channel ---
            ; We tell the device: "Talk to me on channel 0"
            JSR IEC_TALK        ; Send TALK command

            ; Send the data-transfer secondary address for channel 0
            LDA #SA_DATA        ; $60
            ORA #CHAN_LOAD      ; + channel 0 = $60
            JSR IEC_SEND_SECONDARY

            ; --- Step 3: Turn the bus around ---
            ; The device is now the talker, we are the listener.
            JSR IEC_TURNAROUND

            ; --- Step 4: Set up RAM destination pointer ---
            ; We'll store received bytes starting at BUFFER_START
            LDA #<BUFFER_START  ; Low byte of buffer address
            STA ZP_PTR_LO
            LDA #>BUFFER_START  ; High byte of buffer address
            STA ZP_PTR_HI

            ; --- Step 5: Receive data loop ---
            ; Keep receiving bytes until the talker signals EOI (last byte)
            ; or until we run out of buffer space.

.read_loop:
            ; Check if we've filled the buffer
            LDA ZP_PTR_HI
            CMP #>BUFFER_END    ; Are we past the end of RAM?
            BCS .read_overflow  ; Yes - buffer overflow!

            ; Receive one byte from the talker
            JSR IEC_RECEIVE_BYTE

            ; Check for errors
            PHA                 ; Save received byte
            LDA IEC_STATUS
            AND #$02            ; Check for timeout error
            BNE .read_rx_error

            ; --- Store the byte in RAM ---
            PLA                 ; Restore received byte
            LDY #$00
            STA (ZP_PTR_LO),Y  ; Store at address pointed to by ZP_PTR

            ; --- Increment the destination pointer ---
            INC ZP_PTR_LO      ; Increment low byte
            BNE .no_ptr_inc     ; No overflow? Skip high byte
            INC ZP_PTR_HI      ; Overflow: increment high byte
.no_ptr_inc:

            ; --- Increment the byte count ---
            INC FILE_SIZE_LO
            BNE .no_size_inc
            INC FILE_SIZE_HI
.no_size_inc:

            ; --- Check for EOI (last byte) ---
            LDA IEC_EOI_FLAG
            BNE .read_eoi       ; EOI was signaled -> this was the last byte

            ; Not done yet - receive the next byte
            JMP .read_loop

.read_eoi:
            ; --- End of file reached (EOI received) ---
            ; Fall through to cleanup

.read_done:
            ; --- Step 6: UNTALK the device ---
            ; Tell the device to stop talking. We must re-assert ATN and
            ; take control of CLK again.
            JSR DATA_ASSERT     ; Hold DATA low
            JSR ATN_ASSERT      ; Assert ATN
            JSR CLK_ASSERT      ; Take CLK
            JSR IEC_UNTALK      ; Send UNTALK command

            ; --- Step 7: CLOSE the file ---
            LDX #CHAN_LOAD
            JSR IEC_CLOSE_FILE

            ; Return with status in IEC_STATUS and byte count in FILE_SIZE
            RTS

.read_overflow:
            ; Buffer is full - stop reading
            LDA #$04            ; Custom error: buffer overflow
            ORA IEC_STATUS
            STA IEC_STATUS
            JMP .read_done

.read_rx_error:
            PLA                 ; Clean stack (discard byte)
            JMP .read_done

.read_error:
            RTS                 ; Return with error status already set


;===============================================================================
;===============================================================================
;
;   SECTION 8: WRITE RAM TO DISK FILE
;
;   IEC_WRITE_FILE - Complete routine to write data from RAM to a
;   file on the 1541 disk drive.
;
;   Input:
;     ZP_PTR_LO/HI = pointer to null-terminated filename string
;     BUFFER_START  = start of data in RAM
;     FILE_SIZE_LO/HI = number of bytes to write (must be set by caller!)
;
;   Output:
;     IEC_STATUS = error status (0 = success)
;
;   Complete protocol sequence:
;     1. OPEN the file for writing (LISTEN + OPEN + filename + UNLISTEN)
;     2. LISTEN the device on the data channel
;     3. Send all data bytes (signal EOI on the last one)
;     4. UNLISTEN
;     5. CLOSE the file
;
;   NOTE: The filename should include the write flag, e.g.:
;         "0:MYFILE,P,W" to write a PRG file
;         "@0:MYFILE,P,W" to overwrite an existing file (save-with-replace)
;
;===============================================================================
;===============================================================================

IEC_WRITE_FILE:
            ; --- Clear status ---
            LDA #$00
            STA IEC_STATUS

            ; --- Step 1: OPEN the file for writing ---
            ; Channel 1 is traditionally used for SAVEing (writing).
            LDX #CHAN_SAVE      ; Channel 1
            JSR IEC_OPEN_FILE

            ; Check for errors
            LDA IEC_STATUS
            BEQ .write_opened_ok
            RTS                 ; OPEN failed, return with error

.write_opened_ok:
            ; --- Step 2: LISTEN on the data channel ---
            ; Tell the device: "Listen to me on channel 1 for data"
            JSR IEC_LISTEN      ; LISTEN device

            ; Send the data-transfer secondary address for channel 1
            LDA #SA_DATA        ; $60
            ORA #CHAN_SAVE      ; + channel 1 = $61
            JSR IEC_SEND_SECONDARY

            ; Release ATN (switch from command phase to data phase)
            JSR ATN_RELEASE

            ; --- Step 3: Set up source pointer ---
            ; We're copying from our temporary storage. Save the filename
            ; pointer and set up for the data buffer.
            ; (The caller already set FILE_SIZE_LO/HI to the byte count)

            ; Set source pointer to BUFFER_START
            LDA #<BUFFER_START
            STA ZP_PTR_LO
            LDA #>BUFFER_START
            STA ZP_PTR_HI

            ; --- Step 4: Send data loop ---
            ; We send bytes one at a time, setting EOI on the last byte.

.write_loop:
            ; --- Check if this is the last byte ---
            ; Compare remaining count. If FILE_SIZE = 1, this is the last.
            LDA FILE_SIZE_LO
            CMP #$01
            BNE .not_last_write_byte
            LDA FILE_SIZE_HI
            CMP #$00
            BNE .not_last_write_byte

            ; This IS the last byte - set EOI flag
            LDA #$FF
            STA IEC_EOI_FLAG
            JMP .send_write_byte

.not_last_write_byte:
            ; Check if we have zero bytes left
            LDA FILE_SIZE_LO
            ORA FILE_SIZE_HI
            BEQ .write_done     ; No more bytes to send

            LDA #$00
            STA IEC_EOI_FLAG    ; Not the last byte

.send_write_byte:
            ; --- Read byte from RAM and send it ---
            LDY #$00
            LDA (ZP_PTR_LO),Y  ; Load byte from source buffer
            JSR IEC_SEND_BYTE   ; Send it over IEC bus

            ; Check for errors
            LDA IEC_STATUS
            AND #$03            ; Check for timeout/error bits
            BNE .write_error_cleanup

            ; --- Increment source pointer ---
            INC ZP_PTR_LO
            BNE .no_wptr_inc
            INC ZP_PTR_HI
.no_wptr_inc:

            ; --- Decrement remaining byte count ---
            ; 16-bit decrement of FILE_SIZE
            LDA FILE_SIZE_LO
            SEC
            SBC #$01
            STA FILE_SIZE_LO
            LDA FILE_SIZE_HI
            SBC #$00
            STA FILE_SIZE_HI

            ; Check if we just sent the last byte (with EOI)
            LDA IEC_EOI_FLAG
            BNE .write_done     ; EOI was set -> we're done

            JMP .write_loop

.write_done:
            ; --- Step 5: UNLISTEN ---
            JSR IEC_UNLISTEN

            ; --- Step 6: CLOSE the file ---
            LDX #CHAN_SAVE
            JSR IEC_CLOSE_FILE

            RTS

.write_error_cleanup:
            JSR IEC_UNLISTEN
            LDX #CHAN_SAVE
            JSR IEC_CLOSE_FILE
            RTS


;===============================================================================
;===============================================================================
;
;   SECTION 9: UTILITY - READ DISK STATUS / ERROR CHANNEL
;
;   The 1541 has a status/error channel (channel 15) that reports
;   the result of the last operation. Reading it returns a string
;   like "00, OK,00,00" or "62, FILE NOT FOUND,00,00".
;
;   This routine reads the status string into BUFFER_START so the
;   main program can check for errors after disk operations.
;
;===============================================================================
;===============================================================================

;-----------------------------------------------------------------------
; IEC_READ_STATUS - Read the drive's error/status channel
;
; Output:
;   Status string stored at BUFFER_START (null-terminated)
;   FILE_SIZE_LO/HI = length of status string
;   IEC_STATUS = bus error status
;
; The status channel (15) doesn't need to be OPENed - it's always
; available. We just TALK it directly.
;-----------------------------------------------------------------------
IEC_READ_STATUS:
            LDA #$00
            STA IEC_STATUS
            STA FILE_SIZE_LO
            STA FILE_SIZE_HI

            ; --- TALK on channel 15 ---
            JSR IEC_TALK

            LDA #SA_DATA        ; $60
            ORA #CHAN_CMD       ; + channel 15 = $6F
            JSR IEC_SEND_SECONDARY

            ; Turn bus around (device becomes talker)
            JSR IEC_TURNAROUND

            ; Set up destination
            LDA #<BUFFER_START
            STA ZP_PTR_LO
            LDA #>BUFFER_START
            STA ZP_PTR_HI

            ; Receive bytes until EOI
.status_loop:
            JSR IEC_RECEIVE_BYTE

            ; Store byte
            LDY #$00
            STA (ZP_PTR_LO),Y

            ; Increment pointer
            INC ZP_PTR_LO
            BNE .no_sptr_inc
            INC ZP_PTR_HI
.no_sptr_inc:

            ; Increment count
            INC FILE_SIZE_LO
            BNE .no_ssize_inc
            INC FILE_SIZE_HI
.no_ssize_inc:

            ; Check for EOI
            LDA IEC_EOI_FLAG
            BNE .status_done

            ; Check for errors
            LDA IEC_STATUS
            AND #$02
            BNE .status_done

            JMP .status_loop

.status_done:
            ; Null-terminate the string
            LDA #$00
            LDY #$00
            STA (ZP_PTR_LO),Y

            ; UNTALK
            JSR DATA_ASSERT
            JSR ATN_ASSERT
            JSR CLK_ASSERT
            JSR IEC_UNTALK

            RTS


;===============================================================================
;===============================================================================
;
;   SECTION 10: MAIN PROGRAM / DEMO
;
;   This demonstrates how to use the above routines. It shows two
;   complete operations:
;
;   DEMO 1: Read a file called "TESTFILE" from disk into RAM
;   DEMO 2: Write 256 bytes from RAM to a file called "OUTFILE"
;
;   You can replace these with your own application logic.
;
;===============================================================================
;===============================================================================

MAIN:
            ;===================================================================
            ; DEMO 1: READ A FILE FROM DISK INTO RAM
            ;===================================================================
            ;
            ; To read a file, we:
            ;   1. Point ZP_PTR to the filename string
            ;   2. Call IEC_READ_FILE
            ;   3. Check IEC_STATUS for errors
            ;   4. The data is now at BUFFER_START, size in FILE_SIZE
            ;

            ; Set up filename pointer
            LDA #<FNAME_READ    ; Low byte of filename string address
            STA ZP_PTR_LO
            LDA #>FNAME_READ    ; High byte of filename string address
            STA ZP_PTR_HI

            ; Read the file!
            JSR IEC_READ_FILE

            ; Check result
            LDA IEC_STATUS
            BNE .read_failed    ; Nonzero = error occurred

            ; Success! Data is now in RAM at BUFFER_START.
            ; FILE_SIZE_LO/HI contains the number of bytes read.
            ; Your application can now process the data.
            JMP .demo_write     ; Continue to demo 2

.read_failed:
            ; Handle error - read the drive status to find out what happened
            JSR IEC_READ_STATUS
            ; The error string is now at BUFFER_START
            ; In a real system, you'd display this to the user.
            JMP .halt           ; Stop on error

            ;===================================================================
            ; DEMO 2: WRITE DATA FROM RAM TO A DISK FILE
            ;===================================================================
            ;
            ; To write a file, we:
            ;   1. Place the data to write at BUFFER_START
            ;   2. Set FILE_SIZE_LO/HI to the number of bytes
            ;   3. Point ZP_PTR to the filename string
            ;   4. Call IEC_WRITE_FILE
            ;   5. Check IEC_STATUS for errors
            ;

.demo_write:
            ; --- First, fill the buffer with some test data ---
            ; We'll write 256 bytes (values $00 through $FF)
            LDX #$00
.fill_loop:
            TXA                 ; A = X (0-255)
            STA BUFFER_START,X  ; Store at BUFFER_START + X
            INX
            BNE .fill_loop      ; Loop 256 times (X wraps to 0)

            ; Set the file size to 256 bytes
            LDA #$00            ; Low byte (256 = $0100)
            STA FILE_SIZE_LO
            LDA #$01            ; High byte
            STA FILE_SIZE_HI

            ; Point to the output filename
            LDA #<FNAME_WRITE
            STA ZP_PTR_LO
            LDA #>FNAME_WRITE
            STA ZP_PTR_HI

            ; Write the file!
            JSR IEC_WRITE_FILE

            ; Check result
            LDA IEC_STATUS
            BNE .write_failed

            ; Success! File written to disk.
            JMP .halt           ; Done with demo

.write_failed:
            JSR IEC_READ_STATUS
            ; Error string at BUFFER_START
            ; Fall through to halt

.halt:
            ; --- System halt ---
            ; In a real system, you'd return to a command prompt or
            ; monitor. Here we just loop forever.
            JMP .halt


;===============================================================================
; FILENAME STRINGS
;===============================================================================
; These are null-terminated filename strings used by the demo.
;
; Format: "drivenumber:filename,type,mode"
;   Drive number: 0 (only option on single-drive 1541)
;   Type: P = Program (PRG), S = Sequential (SEQ), U = User (USR)
;   Mode: R = Read, W = Write
;
; The "@" prefix means "save with replace" (overwrite existing file).

FNAME_READ:
            .byte "0:TESTFILE,P,R", $00  ; Open TESTFILE as PRG for reading

FNAME_WRITE:
            .byte "@0:OUTFILE,P,W", $00  ; Write OUTFILE as PRG (overwrite if exists)


;===============================================================================
;===============================================================================
;
;   SECTION 11: 6502 INTERRUPT AND RESET VECTORS
;
;   The 6502 reads three 16-bit vectors from the top of the address
;   space upon specific events:
;
;   $FFFA-$FFFB = NMI vector   (Non-Maskable Interrupt)
;   $FFFC-$FFFD = RESET vector (Power-on / Reset button)
;   $FFFE-$FFFF = IRQ vector   (Maskable Interrupt / BRK instruction)
;
;   Since we don't use interrupts, NMI and IRQ just return immediately
;   with RTI (Return from Interrupt). The RESET vector points to our
;   RESET initialization code.
;
;===============================================================================
;===============================================================================

;-----------------------------------------------------------------------
; NMI_HANDLER - Non-Maskable Interrupt handler
;
; NMI is edge-triggered and cannot be disabled. In our system we don't
; use it, so we just return immediately. In a real system, this could
; be used for a RESTORE key or critical hardware event.
;-----------------------------------------------------------------------
NMI_HANDLER:
            RTI                 ; Return from interrupt (do nothing)

;-----------------------------------------------------------------------
; IRQ_HANDLER - Maskable Interrupt / BRK handler
;
; IRQ is level-triggered and can be disabled with SEI. Since we called
; SEI at startup, this should never fire. But just in case:
;-----------------------------------------------------------------------
IRQ_HANDLER:
            RTI                 ; Return from interrupt (do nothing)


;===============================================================================
; VECTOR TABLE - Must be at $FFFA-$FFFF
;===============================================================================
; The 6502 CPU hardware reads these addresses automatically.
; We use .org to force placement at the correct location.

            .org $FFFA

            .word NMI_HANDLER   ; $FFFA-$FFFB: NMI vector
            .word RESET         ; $FFFC-$FFFD: RESET vector -> our init code
            .word IRQ_HANDLER   ; $FFFE-$FFFF: IRQ/BRK vector


;===============================================================================
; END OF PROGRAM
;===============================================================================
;
; SUMMARY OF PUBLIC API:
; ----------------------
;
; IEC_READ_FILE:
;   Input:  ZP_PTR_LO/HI -> null-terminated filename string
;   Output: Data at BUFFER_START, size in FILE_SIZE_LO/HI
;           IEC_STATUS = 0 on success
;
; IEC_WRITE_FILE:
;   Input:  ZP_PTR_LO/HI -> null-terminated filename string
;           Data at BUFFER_START, size in FILE_SIZE_LO/HI
;   Output: IEC_STATUS = 0 on success
;
; IEC_READ_STATUS:
;   Output: Drive status string at BUFFER_START (null-terminated)
;
; MEMORY MAP:
; -----------
;   $0000-$000F  Zero page variables (pointers, flags, counters)
;   $0100-$01FF  6502 hardware stack
;   $0200-$3FFF  File data buffer (~15 KB)
;   $6000-$600F  6522 VIA registers
;   $8000-$FFFF  This program (ROM)
;
;===============================================================================
;Hardware layer (Sections 1–3): 
;VIA initialization, individual line control routines (ATN/CLK/DATA assert/release/read), 
;and timing delays using VIA Timer 1.
;Bit-level protocol (Section 4): 
;The core IEC_SEND_BYTE, IEC_SEND_BYTE_ATN, and IEC_RECEIVE_BYTE routines 
;;that transfer bytes LSB-first with full CLK/DATA handshaking and EOI detection.
;Bus commands (Section 5): LISTEN, TALK, UNLISTEN, UNTALK, secondary address sending,
; and the bus turnaround sequence for switching talker/listener roles.
;File operations (Sections 6–8): 
;The two main routines you asked for — IEC_READ_FILE reads a file from disk into RAM at $0200, 
;and IEC_WRITE_FILE writes data from that buffer to a disk file. 
;Both handle OPEN, data transfer with EOI on the last byte, and CLOSE.
;Utilities & demo (Sections 9–11): Drive error channel reader, a demo main program showing both read and write operations, and the 6502 vector table at $FFFA.
;A few things to keep in mind for your hardware build: the VIA PB0-PB2 outputs need open-collector drivers (transistors or buffers with external pull-up resistors to +5V, typically 1k) since the IEC bus is active-low. The input pins PB3-PB4 should read the actual bus state after the pull-ups. This file uses vasm oldstyle syntax with -dotdir (.byte, .word, .org). Assemble with: vasm6502_oldstyle -Fbin -dotdir -o disk1541.bin 042_Disk1541_vasm.asm