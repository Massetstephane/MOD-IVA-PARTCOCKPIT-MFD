//:Test to trying acess kos module in ship
// Copyright © 2021 Masset Stephane 
// Lic. Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
clearScreen.
set kospart to core:element.
print "- kos:element -".
print kospart.
print "- core:tag -".
set computername to ""+core:tag.
print computername.
for pkos in ship:partstagged(computername)
{
    set kospar to pkos.    
}
print "- kos module part -".
print kospar.
wait 5.
set modulekos to kospar:GETMODULE("kOSProcessor").
clearscreen.
print "- module actions are -".
print modulekos:allevents.
wait 5.
clearScreen.
print "- test core suffixe -".
print "- test core:mode -".
print "mode :" + core:mode.
wait 5.
core:activate.
// end file

