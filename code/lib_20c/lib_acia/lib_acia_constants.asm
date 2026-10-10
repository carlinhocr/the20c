
clearRS232Screen:
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e" 


; ---------- Texto foreground ----------
ansi_color_base:  
ansi_black:        
  .byte 27,"[30m",0
ansi_red:   
  .byte 27,"[31m",0
ansi_green:        
  .byte 27,"[32m",0
ansi_yellow:       
  .byte 27,"[33m",0
ansi_blue:         
  .byte 27,"[34m",0
ansi_magenta:      
  .byte 27,"[35m",0
ansi_cyan:         
  .byte 27,"[36m",0
ansi_white:        
  .byte 27,"[37m",0
ansi_fg_default:   
  .byte 27,"[39m",0


; ---------- Texto brillante ----------
ansi_br_black:     
  .byte 27,"[90m",0   ; gris
ansi_br_red:       
  .byte 27,"[91m",0
ansi_br_green:     
  .byte 27,"[92m",0
ansi_br_yellow:    
  .byte 27,"[93m",0
ansi_br_blue:      
  .byte 27,"[94m",0
ansi_br_magenta:   
  .byte 27,"[95m",0
ansi_br_cyan:      
  .byte 27,"[96m",0
ansi_br_white:     
  .byte 27,"[97m",0

; ---------- Fondo (background) ----------
ansi_bg_black:     
  .byte 27,"[40m",0
ansi_bg_red:       
  .byte 27,"[41m",0
ansi_bg_green:     
  .byte 27,"[42m",0
ansi_bg_yellow:    
  .byte 27,"[43m",0
ansi_bg_blue:      
  .byte 27,"[44m",0
ansi_bg_magenta:   
  .byte 27,"[45m",0
ansi_bg_cyan:      
  .byte 27,"[46m",0
ansi_bg_white:     
  .byte 27,"[47m",0
ansi_bg_default:   
  .byte 27,"[49m",0

; ---------- Fondo brillante ----------
ansi_bg_br_black:  
  .byte 27,"[100m",0
ansi_bg_br_red:    
  .byte 27,"[101m",0
ansi_bg_br_green:  
  .byte 27,"[102m",0
ansi_bg_br_yellow: 
  .byte 27,"[103m",0
ansi_bg_br_blue:   
  .byte 27,"[104m",0
ansi_bg_br_magenta:
  .byte 27,"[105m",0
ansi_bg_br_cyan:   
  .byte 27,"[106m",0
ansi_bg_br_white:  
  .byte 27,"[107m",0

ansi_reset: 
  .byte 27,"[0m",0  


