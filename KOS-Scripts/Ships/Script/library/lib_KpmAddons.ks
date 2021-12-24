// ----------------------------------------------------------------------
// ----   Library addons:kpm  user Function for LABEL BUTON & FLAG   ----
// ----------------------------------------------------------------------
// Copyright © 2021 Masset Stephane 
// Lic. Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
// setting objects to acces buttons and buttonlabel
// ---- list MFD buttons index ----
//  (-1) -> enterButton         : addons:kpm:labels:getstate(-1) get state of button.
//  (-2) -> cancelButton        : addons:kpm:labels:setstate(-2) set state of button
//  (-3) -> upButton
//  (-4) -> downButton
//  (-5) -> leftButton
//  (-6) -> rightButton
//  (0 - 13) other buttons
//
@lazyGlobal off.

// Main function Constructor Object KPM (button, label or flag)
function setKPMapi
{
    parameter choice is "B",
              objecttoclear is makeObj().
    local object is makeObj().    // object definition

    // =================   LABEL & FLAG   ==================
    // ---- set text & state for LABEL or FLAGS ----
    function setTXTFull 
    {
        parameter Text is "-----",
                  state is false.
        if choice <> "B" and (choice = "L" or "F")
        {
            from {local xx is 13.} until xx<0 step { set xx to xx-1.} do 
            {
                setl(xx, Text).
                setS(xx, state).
            } 
        } else throwException("BAD object KPM:ADDONS->", "kpm:labels or kpm:flags").
    }
    // ---- set LABEL or FLAG text ----
    function setTxT
    {
        parameter ID,
                  Text is "".
        if choice <> "B" and (choice = "L" or "F")
        {
            if Text = "" set Text to getL(ID).	
            setL(ID, Text).
        } else throwException("BAD object KPM:ADDONS->", "kpm:labels or kpm:flags").
    }
    // ---- get LABEL or FLAG txt ----
    function getTxT
    {
        parameter ID.
        if choice <> "B" and (choice = "L" or "F")
        {
            return getL(ID).
        } else throwException("BAD object KPM:ADDONS->", "kpm:labels or kpm:flags").
    } 
    // ---- set LABEL or FLAG state ----
    function setSta
    {
        parameter ID is 0,
                  state is false.
        if choice <> "B" and (choice = "L" or "F")
        {
            setS(ID, state).
        } else throwException("BAD object KPM:ADDONS->", "kpm:labels or kpm:flags").
    }
    // ---- get LABEL or FLAG state ----
    function getSta
    {
        parameter ID.
        if choice <> "B" and (choice = "L" or "F")
        {
            return getS(ID).
        } else throwException("BAD object KPM:ADDONS->", "kpm:labels or kpm:flags").
    }
    // ---- starting sequence test cosmetique LABEL & FLAG (flag not tested) ----
    function initLab
    {
        if choice <> "B" and (choice = "L" or "F")
        {
            parameter tempos is 0.5.
            local test1 is "_____".
            local test2 is "[font(4)]"+char(175)+char(175)+char(175)+char(175)+char(175)+"[font(0)]".
            from {local xx is 13.} until xx<0 step { set xx to xx-1.} do
            {
                setTxT(xx, test1).
                wait tempos.
                setTxT(xx, test2).
                wait tempos.
                setSta(xx, true).
                wait tempos.
                setTxT(xx, "-----").
                setSta(xx, false).
            }
        } else throwException("BAD object KPM:ADDONS->", "kpm:labels or kpm:flags").
    }
    
    // =================   BUTTONS    ==================
    // ---- button delegate affect function to button ----
    function dele
    {
        parameter ID,
                  funct.
        if choice = "B" { object:setdelegate(ID, funct).} else throwException("BAD object KPM:ADDONS->", "kpm:buttons ").
    }
    // ----    Button delegate clear assignation      ----
    function clear
    {
        local butid is list(-1, -2, -3, -4, -5, -6, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13).
        for i in butid {objecttoclear:setdelegate(i, empty@).}
    }
    // ===========  global current monitor  ============
    function CurentMoni
    {
        return object:CURRENTMONITOR().
    }
    
    // ======= internal function ======
    // ---- make object set by choice ----
    function makeObj
    {
        if choice = "B" {return addons:kpm:buttons.}	// setting labels object
	    if choice = "L" {return addons:kpm:labels.}	    // setting labes object
	    if choice = "F" {return addons:kpm:flags.}	    // setting flags object
        throwException("Bad choice. Option are :", " B (buttons) L (labels) F (flags)").
    }
    // ---- set label ----
    function setL
    {
        parameter a,
                  b.
        return object:setlabel(a, b).
    }
    // ---- get label ----
    function getL
    {
        parameter a.
        return object:getlabel(a).
    }
    // ---- set state ----
    function setS
    {
        parameter a,
                  b.
        return object:setstate(a, b).
    }
    // ---- get state ----
    function getS
    {
        parameter a.
        return object:getstate(a).
    }
    // ---- Empty Function ----
    function empty {}
    // ---- object error Exception ----
    function throwException {
        parameter info, 
                  type.
        clearScreen.
        print info + type + " Needed !".
        print "CTRL+C Abort programme".
        wait 1000.
    }    
    //
    // ---- set & get & function delegate ----
    return lexicon(
        "Reset",      setTXTFull@,
        "setTXT",     setTxT@,
        "getTXT",     getTxT@,
        "setSTA",     setSta@,
        "getSTA",     getSta@,
        "initLF",     initLab@,
        "dele",       dele@,
        "clear_dele", clear@,
        "Monitor",    CurentMoni@        
    ).
}
// END FILE