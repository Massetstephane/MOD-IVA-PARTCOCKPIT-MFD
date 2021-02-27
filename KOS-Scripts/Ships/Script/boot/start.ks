// ------------------------------------------------------------------
// ----                 S T A R T U P file                       ----
// ------------------------------------------------------------------
// Copyright © 2021 Masset Stephane 
// Lic. Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
// setting objects to acces buttons and buttonlabel

wait until ship:unpacked.
wait 1.5.
runPath ("0:/library/lib_KpmAddons.ks").							           // testing new library (label flag and button function)
runPath ("0:/library/lib_FlashString.ks").                                     // library for animated string
local but is setKPMapi("B").     					                           // object Buttons			  
local lab is setKPMapi("L").  						                           // object lab for text and state.
lab["initLF"](0.05).                                                           // set label test cosmetic start
// delegate buttons
but["dele"](7, Bup@).                                                          // Choice Indicator UP
but["dele"](8, Bdown@).                                                        // Choice Indicator DOWN
but["dele"](9, Benter@).                                                       // Validate Choice
but["dele"](10, exitstart@).                                                   // Exit button
// setting labels txt
lab["setTXT"](7, " UP ").
lab["setTXT"](8, " DOWN").
lab["setTXT"](9, " ENTER").
lab["setTXT"](10, " EXIT").
// setting label state
lab["setSTA"](9, false).
set activeFunc to false.
set config:audioerr to true.
clearScreen.
print " [font4]KOS system :[font0] " + core:version.
// create list of Program in a folder and store info & program
cd ("0:/lib_Prog").                                                             // Program Folder
set ListProg to list().                                                 
list files in ListProg.                                                         // Store program to liste
set ProgNumber to ListProg:length().                                            // Number of program
print "[#ffffffff] - " + "[#33FF00FF]" + ProgNumber + "[#ffffffff] - Active Program Stored".
print "-------------------------------------------------".
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
set indicator to Flashthing("O", " ", 0.7).
// Main Program
until lab["getSTA"](9) 
{
    indicator["FlashSTR"](4, current_option+deltaPos).                          // Placing flashing Indicator.
    if activeFunc
    {        
        copyPath(ListProg[current_option], "1:").
        switch to 1.
        clearScreen.
        but["dele"](10, nothing@).                                              // For it"s the only way i find to deactivate button
        runPath (ListProg[current_option]).
        lab["setSTA"](9, true).
    }
    wait 0.001.  
}.
lab["Reset"]().
switch to 0.
clearScreen.
print "-Vers :" + core:version + " -Disk : " + core:volume.
print "-----------------------------------------------------------------------".
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
// ---- Cancel the previous function ----
function nothing                            
{}
// ---- exit ----
function exitstart
{
    clearscreen.
    lab["setSTA"](9, true).
}
// end file
