// ------------------------------------------------------------------
// ----           Function set Object Moving PARTS               ----
// ------------------------------------------------------------------
// Copyright © 2022 Masset Stephane 
// GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
//
@lazyGlobal off.
//
// Main Function Constructor Object PART with info for Part name(kostag), module name, action or event name
function MovPartOBJ                                                                                         // make object
{
    parameter pttag is "",																		            // Kos tag for part in ship
			  modu is "",																		            // module to find
			  actionEvent is "".																            // the actionEvent name or event name
    // ===== Main function for Object =====
    // ---- move part in ship ----
    function mvPart
    {
        setModulACtion(true).
    }
    // ---- stop part in ship ----
    function stpPart
    {
        setModulACtion(false).
    }
    // ===== Internal Function =====    
    // ---- get actionEvent list by module in list module ----
    function setModulACtion
    {
        parameter bool.
        local module is GetPmodul().																        // Make a list of module containing actions		  
        if not module:empty																		            // module empty no actionEvent
        {
            from {local i is 0.} until i = (module:length()) step{ set i to i + 1.} do			            // main iterator module list
            {
                from {local j is 0.} until j = (module[i]:length()) step{ set j to j+1.} do		            // second iterator actionEvent list in module
                {
                    if module[i][j]:HASACTION(actionEvent)                                                  // perform actionEvent
                    {
                        module[i][j]:DOACTION(actionEvent, bool).
                    } else if module[i][j]:HASEVENT(actionEvent)
                    {
                        module[i][j]:DOEVENT(actionEvent).
                    }
                }
            }
	    }
    }
    // ---- get module in ship ----
	function GetPmodul
	{
		local Moduf is list().																	            // the main list module number
		local it is 0.																			            // actionEvent iterator
		FOR P IN SHIP:PARTSTAGGED(pttag)														            // search for tagged part
		{
			if P:HASMODULE(modu)																            // contain module
			{
				Moduf:add(list()).																            // sub list created for actionname
				Moduf[it]:add(P:GETMODULE(modu)).												            // list module with list actionEvent
				set it to it+1.
			}       
		}
		return Moduf.           
	}
    //
    // delegate function lexicon
    return lexicon(
        "Move", mvPart@,
        "Stop", stpPart@
    ).
}
// END FILE