//:Test to trying acess kos module in ship
// Copyright © 2022 Masset Stephane 
// GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
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
// restart boot program selected
core:activate.
// end file

