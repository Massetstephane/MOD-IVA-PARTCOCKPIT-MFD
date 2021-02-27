## How to USE

- **boot folder**
  - Contains **start.ks** script
  
    He manages the main page of the MFDkos    
    To access scripts or set up the ship of your choice

- **lib_Prog folder**
  - You place your script in this folder and the start script in the boot folder will read the script information
    and display on the page the script info page with the possibility of launching it
    
    - The first ligne in the script is used to show information
    - 
      EX : //: My program do that
      
      Will show a list with this info : My program do that
    
- **library** (This folder is created by using this [library](https://github.com/KSP-KOS/KSLib))
  - **lib_FlashString.ks**  -> Constructor to animate STRING LABEL and FLAG (text and state)
                                
                               Produces these functions:
                               
                               "FlashSTR", "FlashSTROne", FlashLF", "FlashLFOne", "FlashSTA", "FlashSTAone"
                               
  - **lib_KpmAddons.ks**    -> Constructor to manage the creation of LABEL and FLAG as well as assigning a function to the buttons of the MFD
 
                               Produces these functions:
  
                               "Reset", "setTXT", "getTXT", "setSTA", "getSTA", "initLF", "dele", "Monitor"
                               
  - **lib_MovePart.ks**     -> Consttructor that created an object containing one or more Parts in the ship, configured by indicating the KOSTAG, module, and action or event
  
                               Produces two functions: 
                               
                               "Move", "Stop"
                               
  #### *Non-definitive scripts that can be modified, optimized.*
  
