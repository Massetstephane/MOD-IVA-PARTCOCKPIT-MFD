//:Test to trying acess kos module in ship
// Copyright © 2021 Masset Stephane 
// Lic. MIT
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
print "- core:activate -".
core:activate().
wait 5.

