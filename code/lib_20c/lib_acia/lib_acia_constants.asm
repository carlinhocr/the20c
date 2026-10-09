
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

ansi_reset: 
  .byte 27,"[0m",0  


