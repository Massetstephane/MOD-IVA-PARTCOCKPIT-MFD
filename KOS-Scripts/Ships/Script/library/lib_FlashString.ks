// ------------------------------------------------------------------
// ----              Function For FLASHING TEXT                  ----
// ------------------------------------------------------------------
// Copyright © 2021 Masset Stephane 
// Lic. Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)

@lazyGlobal off.

// ---- My user functions in library folder ----
runPath ("0:/library/lib_KpmAddons.ks").			                                // library (label flag and button function)

// Main parameters
global showS is true.                                                               // The first pass show (string)
global hideS is false.                                                              // Hide is off (string)
global showSLF is true.                                                             // The first pass show (Flag & label)
global hideLF is false.                                                             // Hide is off (Flag & Label)
global showst is true.                                                              // The first pass state
global hidest is false.                                                             // Hide is off (state)

// Main Function Constructor Object String & Label & Flag with flash function
function Flashthing                                                                 // Make object global
{
    parameter strg is    " ",                                                       // the string to show global parameter work for string label flag
              hidestr is " ",                                                       // the string to hide "
              tempo is     1,                                                       // the time flashing    
              objectLF is setKPMapi("L"),                                           // object label but flag work too
              labID is     0.                                                       // ID label

    // ====== STRING section =====
    // ---- loop flash ----
    function FlashSTR                                                               // Work with loop script
    {    
        parameter x,
                  y.
        // the show hide timming with switch show & hide
        if showS                                                                    // show string section 
            {
                PrintATTestshow(x, y).                                              // Place string at location
                set showS to false.                                                 // This disable ShowS (one pass)
                local SecondsLater is TIME:SECONDS + tempo.                         // set End timepoint at this moment
                WHEN TIME:SECONDS > SecondsLater then                               // set the delay time                             
                {
                    set hideS to true.                                              // this enable HideS after delay
                }
            }
        if hideS                                                                    // hide string section
            {
                PrintATTesthide(x, y).                                              // Clear string at location
                set hideS to false.                                                 // This disable hideS (one pass)
                local SecondsLater is TIME:SECONDS + tempo.                         // set End timepoint at this moment
                WHEN TIME:SECONDS > SecondsLater THEN                               // set the delay time 
                {			
                    set showS to true.                                              // this enable showS after delay
                }
            }
        wait 0.001.	
    }
    //
    // ---- one time flash ----
    function FlashSTROne                                                            // Not for loop function
    {
        parameter x is -1,
                  y is 0.  
        local timer is time:seconds + tempo.                                        // set End timepoint at this moment
        PrintATTestshow(x, y).                                                      // print string at location
        when time:seconds > timer then PrintATTesthide(x, y).                       // clear string after delay
    }
    //
    // ===== LABEL & FLAG section  TXT =====
    // ---- Loop flash ----
    function FlashLabel                                                             // Flag work too (same as string script loop)
    {
        // the show hide timming
        if showSLF 
            {
                objectLF["setTXT"](labID, strg).
                set showSLF to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater then
                {
                    set hideLF to true.
                }
            }
        if hideLF
            {
                objectLF["setTXT"](labID, hidestr).
                set hideLF to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater THEN 
                {			
                    set showSLF to true.
                }
            }
        wait 0.001.
    }
    //
    // ---- one time flash ----
    function FlashLabOne                                                            // Not for script loop (same as string)
    {
        local timer is time:seconds + tempo.
        objectLF["setTXT"](labID, strg).
        when time:seconds > timer then objectLF["setTXT"](labID, hidestr).
    }
    //
    // ===== LABEL & FLAG section  STATE =====
    // ---- loop state ----
    function FlashSt                                                                // For script loop (same as string but for state)
    {
        // the show hide timming
        if showst
            {
                objectLF["setSTA"](labID, true).                                    // state is true
                set showst to false.
                local SecondsLater is TIME:SECONDS + tempo.
                WHEN TIME:SECONDS > SecondsLater then
                {
                    set hidest to true.
                }       
            }
        if hidest
            {
                objectLF["setSTA"](labID, false).                                   // state if false
                set hidest to false.
                local SecondsLater is TIME:SECONDS + tempo.
                when TIME:SECONDS > SecondsLater then
                {
                    set showst to true.
                }
            }
        wait 0.001.
    }
    //
    // ---- one time flash ----
    function FlashSTonce                                                            // Not for script loop (same as string)
    {
        local timer is time:seconds + tempo.
        objectLF["setSTA"](labID, true).
        when time:seconds > timer then objectLF["setSTA"](labID, false).
    }
    // ===== internal functions =====
    // ---- show txt ----
    function PrintATTestshow                                                        // print the visible string
    {
        parameter xp,
                  yp.      
        if xp = -1 print strg. else print strg at(xp, yp).                          // if location specified print at 
    }
    // ---- hide text or alternate txt
    function PrintATTesthide                                                        // print the erase string
    {
        parameter xp,
                  yp.  
        if xp = -1 print hidestr. else print hidestr at(xp, yp).                    // same as show
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