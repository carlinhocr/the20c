
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


; ---------- Estilos ----------
ansi_bold:         
  .byte 27,"[1m",0
ansi_dim:          
  .byte 27,"[2m",0
ansi_italic:       
  .byte 27,"[3m",0
ansi_underline:    
  .byte 27,"[4m",0
ansi_blink:        
  .byte 27,"[5m",0
ansi_reverse:      
  .byte 27,"[7m",0
ansi_hidden:       
  .byte 27,"[8m",0
ansi_strike:       
  .byte 27,"[9m",0

; ---------- Apagar estilos individuales ----------
ansi_bold_off:     
  .byte 27,"[22m",0   ; apaga bold y dim
ansi_italic_off:   
  .byte 27,"[23m",0
ansi_underline_off:
  .byte 27,"[24m",0
ansi_blink_off:    
  .byte 27,"[25m",0
ansi_reverse_off:  
  .byte 27,"[27m",0
ansi_hidden_off:   
  .byte 27,"[28m",0
ansi_strike_off:   
  .byte 27,"[29m",0

ansi_reset: 
  .byte 27,"[0m",0  

screen_blue: 
  .byte 27,"[44m",27,"[2J",27,"[H",0  

; ---------- Mover el cursor ----------
cur_up:
  .byte 27,"[A",0      ; arriba 1   (ESC[nA = arriba n)
cur_down:
  .byte 27,"[B",0      ; abajo 1    (ESC[nB)
cur_right:
  .byte 27,"[C",0      ; derecha 1  (ESC[nC)
cur_left:
  .byte 27,"[D",0      ; izquierda 1 (ESC[nD)
cur_up5:
  .byte 27,"[5A",0     ; ejemplo: arriba 5

cur_next_line:
  .byte 27,"[E",0      ; abajo 1 y a columna 1 (ESC[nE)
cur_prev_line:
  .byte 27,"[F",0      ; arriba 1 y a columna 1 (ESC[nF)

; ---------- Posición absoluta ----------
cur_home:
  .byte 27,"[H",0      ; fila 1, columna 1
cur_10_20:
  .byte 27,"[10;20H",0 ; fila 10, columna 20 (ESC[fila;colH)

; ---------- Guardar / restaurar ----------
cur_save:
  .byte 27,"7",0
cur_restore:
  .byte 27,"8",0

; ---------- Mostrar / ocultar ----------
cur_hide:
  .byte 27,"[?25l",0
cur_show:
  .byte 27,"[?25h",0

; ---------- Borrar ----------
cls:
  .byte 27,"[2J",27,"[H",0  ; borra pantalla y va al inicio
clr_eol:
  .byte 27,"[K",0      ; borra desde el cursor al final de la línea
clr_line:
  .byte 27,"[2K",0     ; borra la línea entera