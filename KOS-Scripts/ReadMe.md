# --- KOS Script ---
> script created for use with MFDkos
- I created a function library to interact with the functions of the MFD, Thanks to the KPM mod.
  it is possible to use and program functions with the MFD ASET The new MFDkos is configured to display label
  I have a constructor that allows access to LABEL and FLAG and BUTTON, it is possible to modifi the STATE, the TXT
  These constructors are based on this technique:
  
  ```javascript
  return lexicon(
        "Reset", setTXTFull@,
        "setTXT", setTxT@,
        "getTXT", getTxT@,
        "setSTA", setSta@,
        "getSTA", getSta@,
        "initLF", initLab@,
        "dele", dele@,
        "Monitor", CurentMoni@        
    ).
   ```
   Completely inspired by ![SMOKETEER](https://github.com/smoketeer/fall) , and his FALL script.
   
   _
## LICENCE
 Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
   
