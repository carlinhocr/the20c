;zero page

;zero page memory positions for Vectors and Data

delay_COUNT_A = $32        
delay_COUNT_B = $33

;RAM
;bin 2 ascii memory locations
value=                  $0203
value_1=                $0204
mod10=                    $0205
mod10_1=                  $0206
message = $0207 ; the result up to 6 bytes to $020b
;used by message= $0207
;$0208
;$0209
;$020a
;$020b
multiFactor1=                     $020c
multiFactor2=                     $020d
multiResultLow=                   $020e
multiResultHigh=                  $020f