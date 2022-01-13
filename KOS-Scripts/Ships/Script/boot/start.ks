// ------------------------------------------------------------------
// ----                 S T A R T U P file                       ----
// ------------------------------------------------------------------
// Copyright © 2022 Masset Stephane 
// GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
// V 1.0 (now using PRIMARY MFD buttons for actions)
//
set config:ipu to 500.
wait until ship:unpacked.
wait 6.
runoncePath ("0:/library/lib_KpmAddons.ks").							       // testing new library (label flag and button function)
runoncePath ("0:/library/lib_FlashString.ks").                                 // library for animated string
local but to setKPMapi("B").     		    			                       // object Buttons			  
local lab to setKPMapi("L").  						                           // object lab for text and state.
lab["initLF"](0.06).                                                           // set label test cosmetic start
// delegate buttons
but["dele"](-3, Bup@).                                                         // Choice Indicator UP
but["dele"](-4, Bdown@).                                                       // Choice Indicator DOWN
but["dele"](-1, Benter@).                                                      // Validate Choice
but["dele"](-2, exitstart@).                                                   // Exit button
// setting label state
lab["setSTA"](-2, false).
set activeFunc to false.
set config:audioerr to true.
clearScreen.
print " [font4]KOS system :[font0] " + core:version.
// create list of Program in a folder and store info & program
cd ("0:/lib_Prog").                                                             // Program Folder
set ListProg to list().                                                 
list files in ListProg.                                                         // Store program to liste
set ProgNumber to ListProg:length().                                            // Number of program
print "[#ffffffff] - " + "[#33FF00FF]" + ProgNumber + "[#ffffffff] - Active Program Stored (/SCRIPT/lib_Prog)".
print "-----------------------------------------------------------------------".
// packing first info line of program
set contentProgString to list().
set firsline to "".                                                             // For convert data file to string
FROM {local x is 0.} UNTIL x = ProgNumber STEP {set x to x+1.} DO 
{
    set file to ListProg[x].                                                    // Take File at position in list program (x)
    contentProgString:add(OPEN(file):READALL:ITERATOR).                         // Create list by Add data file make read by line (iterator)
    contentProgString[x]:next.                                                  // pointing first line 0 for data program in list at position x
    set firstline to firsline+contentProgString[x]:value.                       // Convert first line to string for program at position x in list
    local len is firstline:length.
    set contentProgString[x] to firstline:substring(3, len-3).                  // Change Data File to First troncated program line
}.
set current_option to 0.                                                        // Variable for user choice & indicator position
set deltaPos to 4.
local i is 0.
// show item in list program
until i=ProgNumber
{
	print " [ ] " + contentProgString[i] at(2,i+deltaPos).
	set i to i+1.
}.
// flashing cursor object
set indicator to Flashthing("O", " ", 0.5).
//
// ---- Main Loop Boot Program start ----
//
until lab["getSTA"](-2) 
{
    indicator["FlashSTR"](4, current_option+deltaPos).                          // Placing flashing Indicator.
    if activeFunc
    {        
        copyPath(ListProg[current_option], "1:").
        switch to 1.
        clearScreen.
        runPath (ListProg[current_option]).
        break. // continue to Exit 
    }
    wait 0.001.  
}.
// Exit (end boot program if it's not restarted)
// cleaning labels and buttons
lab["Reset"]().
but["clear_dele"]().
// set the exit screen
clearScreen.
print "-Vers :" + core:version + " -Disk : " + core:volume.
print "-----------------------------------------------------------------------".
print "".
//
// ==== END SCRIPT ====
// ====  function  ====
// ---- choice up ----
function Bup                                                            
{
    set current_option to current_option-1.
    if current_option < 0 
    {
        print " " at(4, current_option+deltaPos+1).
        set current_option to ProgNumber-1.        
    }
    print " " at(4, current_option+deltaPos+1).
    wait 0.1.
}
// ---- choice down ----
function Bdown
{
    set current_option to current_option+1.
    if current_option >= ProgNumber 
    {
        print " " at(4, current_option+deltaPos-1).
        set current_option to 0.
    }
    print " " at(4,current_option+deltaPos-1).
    wait 0.1.
}
// ---- enter choice ----
function Benter
{
    set activeFunc to true.
}
// ---- exit ----
function exitstart
{
    clearscreen.
    lab["setSTA"](-2, true).
}
// end file