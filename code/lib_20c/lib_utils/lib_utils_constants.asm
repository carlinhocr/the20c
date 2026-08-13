
;Timer Constants
; ── Timer load values for 1 MHz clock ────────────────────
;
;  Timer counts DOWN from the loaded value to 0, then sets
;  IFR bit 6.  At 1 MHz each tick = 1 µs.
;
;  Maximum single load = 65535 µs ≈ 65.535 ms
;  So to reach 1 second we need ~15.259 overflows of 65535,
;  but it's cleaner to use exactly 50 000 µs (50 ms) and
;  count 20 overflows  →  20 × 50 000 µs = 1 000 000 µs = 1 s
;
;  TICKS_50MS = 50 000 - 2 = 49 998
;    (subtract 2 because the VIA takes 2 extra cycles to
;     reload and set the flag — datasheet §4.2.1)
;  49 998 = $C34E
;  Low  byte: $4E
;  High byte: $C3

TIMER_TICKS_LO  = $4E               ; low  byte of 49 998
TIMER_TICKS_HI  = $C3               ; high byte of 49 998

TIMER_LOOPS_1S  = 20                ; 20 × 50 ms = 1 second
TIMER_LOOPS_5S  = 100               ;5 seconds
TIMER_LOOPS_10S  = 200               ;10 seconds

TIMER_LOOPS_1M  = 6                ; 6 × 10 seconds = 1 minute
TIMER_LOOPS_10M  = 60                ; 60 × 10 seconds = 10 minute

;TIMER_ZP_SEC    = $42               ; loop counter for WAIT_ONE_SECOND  (1 byte)
TIMER_ZP_MIN    = $43               ; seconds counter for WAIT_ONE_MINUTE (1 byte)