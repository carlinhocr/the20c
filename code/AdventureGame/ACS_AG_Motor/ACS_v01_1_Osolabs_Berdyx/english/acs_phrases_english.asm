;=============================================================
;Phrases
;=============================================================
actions_header:
  .ascii ""
  .ascii "You can perform the following actions:"
  .ascii "e"  

letterActions:
  .ascii "ABCDE"  

pasamos:
  .ascii "We passed through here"
  .ascii "e"

msj_heartOn:
  .ascii "Your heart races and you can't think"
  .ascii "e"    

msj_heartOff:
  .ascii "Your heart is calm"
  .ascii "e"

msj_waterOn:
  .ascii "The Water Rises"
  .ascii "e"    

msj_secondElapsed:
  .ascii "Time has passed"
  .ascii "e"    

msj_timerAllGame:
  .ascii "The Adventure begins you have 10 minutes"
  .ascii "e"    

msj_timerExpired:
  .ascii "Time is passing..."
  .ascii "e"    

msj_iddleTimer1:
  .ascii "The constant dripping was hypnotic. Drip, pause, drip. "
  .ascii "The water began to numb your extremities until you stopped feeling them. "
  .ascii "An eternal sleep welcomed you. "    
  .ascii "e"     

option_unknown:
  .ascii "Mmmm that option is not valid"
  .ascii "e"    
  
msj_progressScreen1:
  .ascii "Your progress in the game "
  .ascii "e"     

msj_progressScreen2:  
  .ascii "Seconds Elapsed: "
  .ascii "e" 

msj_progressScreen3:
  .ascii "You died because.... "
  .ascii "e" 

msj_progressScreen4:
  .ascii "Your action had a chance of failing and it failed"
  .ascii "e"   

msj_progressScreen4_printer:
  .ascii "Your action had a chance"
  .ascii "of failing and it failed"
  .ascii "e"

msj_progressScreen5:
  .ascii "You ran out of time"
  .ascii "e"     

msj_progressScreen6:
  .ascii "The enemy caught you"
  .ascii "e"   

msj_progressScreen7:
  .ascii "Your action was extremely reckless and was never going to work"
  .ascii "e"    

msj_progressScreen7_printer:
  .ascii "Your action was reckless"
  .ascii "it was never going to work"  
  .ascii "e" 

msj_flashlightOff:
  .ascii "Your flashlight has no more battery"
  .ascii "e"    

msj_flashlighBateria:
  .ascii "Battery:       "

msj_enemyCaught:  
  .ascii "Caught"
  .ascii "e"    

msj_enemyEscape:  
  .ascii "You escaped"
  .ascii "e"     

msj_actionFailed:  
  .ascii "The action Failed"
  .ascii "e"    

msj_actionSuceeded:  
  .ascii "The action was successful"
  .ascii "e"      

msj_waterTimer:  
  .ascii "Water Level: "
  .ascii "e"

msj_bienvenida:
  .ascii "You Entered The Cavern"
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii ""
  .ascii "e"

msj_secretsFound:
  .ascii "Number of Secrets found"
  .ascii "e"

msj_end_printer:
  .ascii "  _________  "
  .ascii " ########### "
  .ascii "#############"
  .ascii "###  ###  ###"
  .ascii "#############"
  .ascii " ##### ##### "
  .ascii "  #########  "
  .ascii "   # # # #   "
  .ascii "   #######   "
  .ascii "    -----    "
  .ascii "             "
  .ascii " THE CAVERN  "
  .ascii "             "
  .ascii "   DECIDED   "
  .ascii "             "
  .ascii " YOUR FATE   "
  .ascii " "
  .ascii "e"

msj_end_water:                  
  .ascii "  #############"   
  .ascii "  #############"   
  .ascii "   #         # "   
  .ascii "    #       #  "   
  .ascii "      #   #    "   
  .ascii "       # #     "   
  .ascii "      # . #    "   
  .ascii "    # ..... #  "   
  .ascii "   # ....... # "   
  .ascii "  #############"   
  .ascii "  #############"   
  .ascii " "                 
  .ascii "  THE WATER FLOODED"  
  .ascii " "                 
  .ascii "   THE CAVERN" 
  .ascii " "
  .ascii "e"

msj_end_enemy:
  .ascii "    ######"        
  .ascii "   #      # "     
  .ascii "  #        # "     
  .ascii " #   .  .   # "    
  .ascii " #          #  "   
  .ascii "#            # "   
  .ascii "#            #  "  
  .ascii " "                 
  .ascii " "                 
  .ascii " "                 
  .ascii " "                 
  .ascii " "                 
  .ascii " "                 
  .ascii "SOMETHING IS"   
  .ascii " "                
  .ascii "IN THE CAVERN"  
  .ascii " "
  .ascii "e"

msj_win_cavern:
  .ascii "  .     .     .   "
  .ascii ">    .  "          
  .ascii "   .     .  .  . " 
  .ascii ".     . "          
  .ascii "  .       .  . "   
  .ascii "    #### "         
  .ascii " ######### "       
  .ascii "############  "     
  .ascii "####### ..##### "    
  .ascii "#######   ######___ "
  .ascii "    Y  ----       * "
  .ascii " *      ----   Y   " 
  .ascii "    *    ----    *  "
  .ascii "  "                  
  .ascii " YOU ESCAPED "      
  .ascii " THE CAVERN  "       
  .ascii "  "                  
  .ascii " YOUR HUMANITY WAS "
  .ascii " BURIED THERE "
  .ascii " "
  .ascii "e"