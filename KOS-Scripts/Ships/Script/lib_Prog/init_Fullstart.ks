//:Full start SAS & Engine & Break ON (0:)
// Copyright © 2021 Masset Stephane 
// Lic. Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
parameter x is 25, y is 5.
clearscreen.
switch to 0.
sas on.
print "[#2311EFff]--------------------------------" at(x,y).
print "[#D61432ff]          [font4]S T A R T U P[font0]" at(x,y+2).
print "[#2311EFff]--------------------------------" at(x,y+4).
print "switch to 0" at(x,y+6).
print "SAS on" at(x,y+7).
print "__________________________________________________________________________________________".
wait 2.
print "                                              " at(x,y).
print "                                                " at(x,y+2).
print "                                              " at(x,y+4).
print "              " at(x,y+6).
print "              " at(x,y+7).
print " ".
wait 5.
// (return to boot program and exit) 
// end file  