//:Show info on TWR G acceleration motor etc.
// ------------------------------------------------------------------
// ----         Program To learn Mass and TWR calcul             ----
// ------------------------------------------------------------------
// Copyright © 2021 Masset Stephane 
// Lic. MIT
clearScreen.
// set body
set Planet to body("Kerbin").
Print "planet is : " + Planet.
wait 3.
Print Planet + " Gravitationnel Parameter : " + Planet:mu.
wait 3.
// acceleration
SET g TO Planet:mu / Planet:RADIUS^2.
Print "Gravitationnel Accéleration :" + g.
wait 4.
// list of engine
clearScreen.
print "list of engine in ship".
print getEngines().
wait 4.
// showing maxthrust off engine in ship
clearScreen.
print "engine Maxthrust per engine".
set listengine to getEngines().
for eng in listengine
{
    print eng + " Maxthrust is : " + eng:maxthrust.
} 
wait 7.
clearScreen.
// trying to show specific maxthrust engine
clearScreen.
print "engine Maxthrust per engine tagged VTOL".
set listengine to getEngines().
set totalThrust to 0.
for eng in listengine
{
    if eng:tag = "VTOL"
    {
        print eng + " Maxthrust is : " + eng:maxthrust.
        set totalThrust to totalThrust + eng:maxthrust.
    }
}
print "Max thrust for VTOL engine is : " + totalThrust.
print "".
// calcul thrust weight ration TWR
print "TWR for vtol engine is :" + totalThrust / (ship:mass * g).
wait 100.
clearScreen.
core:activate.


// function get the all engine in ship
function getEngines
{
    list engines in leng.
    return leng.
}
