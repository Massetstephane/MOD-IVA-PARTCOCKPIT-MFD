# --- KOS Script (WIP) ---
Copyright (C) Masset Stephane 
> script created for use with MFDkos
- I created a function library to interact with the functions of the MFD, Thanks to the KPM mod.
  it is possible to use and program functions with the MFD ASET The new MFDkos is configured to display label
  I have a constructor that allows access to LABEL and FLAG and BUTTON, it is possible to modifi the STATE, the TXT
  These constructors are based on this technique:
  
  ```javascript
  return lexicon(
        "Reset", SetTXTFull@,
        "setTXT", SsetTxT@,
        "getTXT", GetTxT@,
        "setSTA", SetSta@,
        "getSTA", GetSta@,
        "initLF", InitLab@,
        "dele", Dele@,
        "Monitor", CurentMoni@        
    ).
   ```
   works that way : myConstructorObject\["setTXT"](parameter).
   
Completely inspired by [SMOKETEER](https://github.com/smoketeer/fall) , and his FALL script. Thanks to him
_____

### INSTALLS
Copy Folders or scripts in *Ships/Script/* if you want :) , Kos library included 

___

### LICENCE
GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
   
