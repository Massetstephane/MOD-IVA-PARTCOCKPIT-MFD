// ------------------------------------------------------------------
// ----              Function For FLASHING TEXT                  ----
// ------------------------------------------------------------------
// Copyright © 2021 Masset Stephane 
// Lic. MIT

@lazyGlobal off.

// ---- My user functions in library folder ----
runPath ("0:/library/lib_KpmAddons.ks").			// testing new library (label flag and button function)

// Main parameters
global show is true.
global hide is false.

// Main Function Constructor Object String & Label & Flag with flash function
function Flashthing                                 // Make object flash
{
    parameter strg is " ",                          // the string to show
              hidestr is " ",                       // the string to hide
              tempo is 1,                           // the time flashing    
              objectLF is setKPMapi("L"),           // object label but flag work too
              labID is 0.                           // ID label

    // ====== STRING section =====
    // ---- loop flash ----
    function FlashSTR
    {    
        parameter x,
                  y.
        // the show hide timming
        if show 
            {
                PrintATTestshow(x, y).
                set show to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater then
                {
                    set hide to true.
                    wait 0.001.
                }
            }
        if hide
            {
                PrintATTesthide(x, y).
                set hide to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater THEN 
                {			
                    set show to true.
                    wait 0.001.
                }
            }	
    }
    // ---- one time flash ----
    function FlashSTROne
    {
        parameter x is -1,
                  y is 0.  
        local timer is time:seconds + tempo.
        PrintATTestshow(x, y).
        when time:seconds > timer then PrintATTesthide(x, y).
    }

    // ===== LABEL & FLAG section  TXT =====
    // ---- Loop flash ----
    function FlashLabel
    {
        // the show hide timming
        if show 
            {
                objectLF["setTXT"](labID, strg).
                set show to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater then
                {
                    set hide to true.
                    wait 0.001.
                }
            }
        if hide
            {
                objectLF["setTXT"](labID, hidestr).
                set hide to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater THEN 
                {			
                    set show to true.
                    wait 0.001.
                }
            }
    }
    // ---- one time flash ----
    function FlashLabOne
    {
        local timer is time:seconds + tempo.
        objectLF["setTXT"](labID, strg).
        when time:seconds > timer then objectLF["setTXT"](labID, hidestr).
    }

    // ===== LABEL & FLAG section  STATE =====
    // ---- loop state ----
    function FlashSt
    {
        // the show hide timming
        if show
            {
                objectLF["setSTA"](labID, true).
                set show to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater then
                {
                    set hide to true.
                    wait 0.001.
                }       
            }
        if hide
            {
                objectLF["setSTA"](labID, false).
                set hide to false.
                local SecondsLater is TIME:SECONDS + tempo.
                when TIME:SECONDS > SecondsLater then
                {
                    set show to true.
                    wait 0.001.
                }
            }
    }

    // ---- one time flash ----
    function FlashSTonce
    {
        local timer is time:seconds + tempo.
        objectLF["setSTA"](labID, true).
        when time:seconds > timer then objectLF["setSTA"](labID, false).
    }
    // ===== internal functions =====
    // ---- show txt ----
    function PrintATTestshow
    {
        parameter xp,
                  yp.      
        if xp = -1 print strg. else print strg at(xp, yp).
    }
    // ---- hide text or alternate txt
    function PrintATTesthide
    {
        parameter xp,
                  yp.  
        if xp = -1 print hidestr. else print hidestr at(xp, yp).
    }    

    // lexicon for Function option
    return lexicon(
        "FlashSTR",     FlashSTR@,
        "FlashSTROne",  FlashSTROne@,
        "FlashLF",      FlashLabel@,
        "FlashLFOne",   FlashLabOne@,
        "FlashSTA",     FlashSt@,
        "FlashSTAone",  FlashSTonce@
    ).    
}
// END FILE