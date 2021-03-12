//:Hover & Landing Program V4 (test library movepart)
// Vers 5.0 fonctionnel using the PIDLoop integrated in kos
// buttons work now, added input altitude & landing Mode & new library
// Action and event in selected part module by kos tag ok
// Main pidloop Parameter are saved in corresponding aircraft file.txt in a special data folder
// Copyright © 2021 Masset Stephane 
// Lic. Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)

parameter inpalt is 0,  		                       								// base height if nothing enter
		  vTn 	 is "VTOL".															// Default name tag for motor (search)
// ---- My user functions in library folder ----
runPath ("0:/library/lib_KpmAddons.ks").											// testing new library (label flag and button function)
runPath ("0:/library/lib_FlashString.ks").											// library function for string & label effects
runPath ("0:/library/lib_MovePart.ks").	    										// library perform action & event
// ---- user function kos library ----
runPath ("0:/library/lib_input_terminal").			  								// for input altitude
runpath ("0:/library/lib_navball").					  								// library function for fly data

// ===================== setting variables ======================
local NaAircraf is ship:shipName.												// name of vessel
set FullNameAircraft to NaAircraf + ".txt".									// Full name of saved file
set VTOLname to vTn.																// set vtol engine name
set hoVers to "V5.0".																// version tag
set bound_Box to ship:bounds.                         								// ship volume
lock AltiRad to bound_Box:bottomaltradar.											// Current Altitude radar under ship
lock Altisea to bound_Box:bottomalt.												// Current Altitude Sealevel under ship
lock curent_Alt to AltiRad.															// Set to radar by default
set CurentThrottle to ship:control:pilotmainthrottle. 								// keep actual throttle
set DeltaMaxMin to -0.1.							  								// to increase or decrease defaut -0.1
set running to false.								  								// Main hover boucle is on
set timerTime to 0.3.								  								// delta time for flashing label text one time
set onepass to true.								  								// SAS switch
set M to 0.																			// Amplitude Ratio -> searching to find the value
set TU to 1.																		// Mesured period (second i presume) -> same
set TUcheck to true.																// First TU calcul on start true
lock Ku to 1 / M.																	// Optimal Gain
lock KP to 0.2 * Ku.																// Ziegler-Nichols method no overshoot setup
lock KI to (2 * KP)/ TU.															// same
lock KD to (KP * TU) / 3.															// same
set MINthr to 0.									  								// throttle PID MINOUTPUT
set MAXthr to 0.95.									  								// throttle PID MAXOUTPUT
set MINVspeed to -5.																// Verticale speed PID MINOUTPUT (default start)
set MAXVspeed to 5.																	// Verticale speed PID MAXOUTPUT								
set TargetVertSpeed to 0.															// set target speed to 0 (stationary)
set FactorVspeedLand to -10.														// control the descent speed (depending reaction time motor)

// ---- Checking if parameter saved file exist if not create it ----
// ----      And create a LEXICON of data for save or read      ----
// ----          Or update LEXICON from existing file			----
set FileDatas to lexicon(
		"MINthr", 			MINthr,
		"MAXthr", 			MAXthr,
		"FactorVspeedLand", FactorVspeedLand,
		"AmplitudeRatio", 	M,
		"MesuredPeriod", 	TU).
switch to 0.														// NOT in boot directory and local ship store
LoadStoreDat(FullNameAircraft, FileDatas).							// Update or save Datas

// ----          sounds             ----
set Sound1 to getVoice(0).											// button sound
definesound(Sound1,"SQUARE", 0, 0.01, 0.5, 0.1, 0.3).				// sound definition
set sound2 to getVoice(1).											// end hover music
definesound(sound2,"TRIANGLE", 0.0333, 0.02, 0.80, 0.05, 0.3).		// sound definition
set sound2:tempo to 2.

// ---- setting moving Part objects ----
set cherryLight to MovPartOBJ("HoverLight", "ModuleLight", "activer l'éclairage").
set aeroBreak to MovPartOBJ("KosAerofrein","ModuleAeroSurface", "activer").
set LandL to MovPartOBJ("LandL", "ModuleLight", "activer l'éclairage").
set CtrlLight to MovPartOBJ("CtrlLandL", "ModuleRoboticController", "Activer la lecture").

// ---- pidLoop(KP, KI, KD, MINOUTPUT, MAXOUTPUT) ----
set hoverPID to pidLoop(KP, KI, KD, MINthr, MAXthr).  				// set pidloop for throttle
set VertSpPID to pidLoop(KP, KI, KD, MINVspeed, MAXVspeed).			// set pidloop for target vertical speed default
set hoverPID:setpoint to 0.							  				// set vertical speed setpoint to 0 on start

// ----    setting the altitude on start depend choice off user    ----
// ---- prevent falling ship if script started with ship is flying ----
set seekAlt to choose AltiRad if inpalt = 0 else inpalt.
if seekAlt > 1000 {set seekAlt to 1000.}
set VertSpPID:setpoint to seekAlt.					  				// the choosed altitude setpoint at start
set checkseekALT to seekAlt.										// store first value before is change later (user input new altitude)

// ---- setting objects to acces buttons and buttonlabel ----
set button to setKPMapi("B").							  			// object Buttons			  
set label to setKPMapi("L").							  			// object label for text and state
label["Reset"]().													// clean label

// ---- setting Planet ----
set actualPlanet to FindPlanet().									// setting body to calcul TWR max

// ---- setting button & state ----
label["setTXT"](0, " [hw][#00ff00ff]radAlt[#CEE3F6FF][/hw] ").      // show actual radar mode
label["setTXT"](1, "[hw] LANDING[/hw] ").							// Mode landing label
label["setTXT"](3, " [hw]Input[/hw]  ").							// Input altitude
label["setTXT"](4, "[hw][#ff0000ff]StabOFF  ").						// Mode stab
label["setTXT"](7, " [hw]Minthr").									// Min output pidloop throttle
label["setTXT"](8, "     Maxthr").									// Max output pidloop throttle
label["setTXT"](9, "     [#00ff00ff]-[#CEE3F6FF]0.1").				// start sign for Max and Min
label["setTXT"](10, "      Alt+10").								// altitude +10
label["setTXT"](11, "      Alt-5").									// altitude -5
label["setTXT"](12, "      Alt+1").									// altitude +1 (fine adjustement)
label["setTXT"](13, "      Alt-1").									// altitude -1 (fine adjustement)

// ---- Main function program STATE ----
label["setSTA"](0, true).							  				// Radar mode default radar altitude.
label["setSTA"](9, true).                              				// delta state -0.1 default is true switch

// ---- bind function parameter passing value in delegate function ----
set RadarModeB to RadarMode@. 
set DeltaMaxMinOutputB to DeltaMaxMinOutput@.

// ---- affect buttons to functions ----
button["dele"](0, RadarModeB:bind(label["getSTA"](0))).				// function radar mode Button
button["dele"](1, landingButton@).									// Landing Button
button["dele"](3, InputAltKeyB@).									// Input altitude Button
button["dele"](-2, stop@).											// Exit Button
button["dele"](7, FuncMINthr@).										// Minthr Button
button["dele"](8, FuncMAXthr@).										// Maxthr Button
button["dele"](9, DeltaMaxMinOutputB:bind(label["getSTA"](9))).		// Switch sign Button
button["dele"](10, SeekAlBut10@).									// +10 Button
button["dele"](11, SeekAlBut11@).									// -5 Button
button["dele"](12, SeekAlBut12@).									// +1 Button
button["dele"](13, SeekAlBut13@).									// -1 Button
button["dele"](-3, FactorVspUP@).									// Up button to increase landing vertical speed factor
button["dele"](-4, FactorVspDO@).									// Down button to decrease landing verticla speed factor

// ---- setting Flashing Objects ----
set AlRadIndic to Flashthing("[font4]altRadar[font0]", "[font4]        [font0]", 0.8).
set AlSeaIndic to Flashthing("[font4]altsea[font0]  ", "[font4]      [font0]  ", 0.8).
set MinthFlash to Flashthing(" [hw][#ff0000ff]Minthr", " [hw][#CEE3F6FF]Minthr", timerTime, label, 7).
set MaxthFlash to Flashthing("     [hw][#ff0000ff]MAXthr", "     [hw][#CEE3F6FF]MAXthr", timerTime, label, 8).
set SeekAl10Fl to Flashthing("[#ff0000ff]      Alt+10", "[#CEE3F6FF]      Alt+10", timerTime, label, 10).
set SeekAl11Fl to Flashthing("[#ff0000ff]      Alt-5", "[#CEE3F6FF]      Alt-5", timerTime, label, 11).
set SeekAl12Fl to Flashthing("[#ff0000ff]      Alt+1 ", "[#CEE3F6FF]      Alt+1 ", timerTime, label, 12).
set SeekAl13Fl to Flashthing("[#ff0000ff]      Alt-1", "[#CEE3F6FF]      Alt-1 ", timerTime, label, 13).

// ---- take control on throttle & sas ----
lock throttle to CurentThrottle.
sas on.

// ---- Display main screen Structure First Pass ----
Main_Screen().
InfoHud("* hover Controle on *", red).
//
//                             ------------ Main hover Boucle -------------
// 
set Total_TWR_Vtolengs to CalcTWRMax("POSSIBLETHRUST", VTOLname).						// Max TWR at full condition show value in mfd
if M = 0 set M to Total_TWR_Vtolengs.													// setting the amplitude Ratio if not defined(0)
until running                              			  									// Start on
 {
	set TargetVertSpeed to VertSpPID:update(time:seconds, curent_Alt).					// actualise vertical speed vs altitude
	set hoverPID:setpoint to TargetVertSpeed.											// set setpoint of throttle pidloop
	set CurentThrottle to hoverPID:update(time:seconds, ship:verticalspeed).			// update throttle pidloop
	AjustVertSpeedMin().																// Contrôle Minoutput for VertSpPID
	if TUcheck and (checkseekALT <> seekAlt) CalTu(time:seconds).							// start the calcul for TU parameter if condition true	
	//---- show selection radar or sea level control altitude to desired altitude ----
	if label["getSTA"](0)																// mode radar
		{
			AlRadIndic["FlashSTR"](22, 11).												// object flashing string for Rad alitude
			print round(Altisea, 1) at (27,12).  										// no active altitude
		} else																			// mode alt
			{
				AlSeaIndic["FlashSTR"](22, 11).											// object flashing string for sea alitude 
				print round(AltiRad, 1) at(27,12).										// passive
			}.	
	
	// ---- stability Assit depend sas on or off ----
	if not sas and onepass							  									// work one time until action on sas
    {
		// ---- retrieve pitch and roll and yaw(heading) ----
		set showhead to compass_for().
		lock steering to heading(showhead,0).

		// ---- vector learning things ----
		set V1 to vecDraw(v(0,0,0), ship:facing:forevector, blue, "forevector Z", 6, true, 0.1, true, true). 	// Z
		set V2 to vecDraw(v(0,0,0), ship:facing:topvector, red, "topvector Y", 6, true, 0.1, true, true). 		// Y
		set V3 to vecDraw(v(0,0,0), ship:facing:starvector, green, "starvector X", 6, true, 0.1, true, true). 	// X
		set onepass to false.
		InfoHud("* stab on *", blue).
		label["setTXT"](4, "[hw][#33FF00ff]StabON   ").
		MovePart("Move").																// part moving on
    }.
    if sas and not onepass  
    {
        unlock steering.
        set onepass to true.
		InfoHud("* Stability Mode OFF SAS on *", blue).
		label["setTXT"](4, "[hw][#ff0000ff]StabOFF  ").
		CLEARVECDRAWS().
		MovePart("Stop").																// part moving off
    }.
	Aff_Values(2). 									  									// show info values and hover state
  	wait 0.001.
}.

//                             ------------ END hover Boucle -------------

// ---- exit setup parameter of ship ----
InfoHud("* hover Controle off *", blue).
MovePart("Stop").
MoveLandingLight("Stop").
sas off.
unlock steering.
set ship:control:pilotmainthrottle to throttle.
CLEARVECDRAWS().																		// cleaning all vectors in game

// ---- reset label ----
label["Reset"]().

// ---- reboot to start program (return to main menue) ----
core:activate.
// ==== end script ====

// ======================== Main functions ==========================
// ---- Function Save or Read Parameter
function LoadStoreDat
{
	parameter name is "Empty_File",
			  dat  is lexicon().
			  
	set vol to core:currentvolume.
	if not vol:EXISTS("AircraftParM")												// check if folder exist or creat it
	{
		vol:createdir("AircraftParM").
		CD("0:/AircraftParM").
	} else CD("0:/AircraftParM").
	// ---- Create File if not exist or read value from file ----
	if not vol:exists(name)
	{	
		WRITEJSON(dat, name).														// Save lexicon Data
	} else {
				local FDs is READJSON(name).										// store lexicon Data from file
				// update data
				set MINthr to FDs:MINthr.
				set MAXthr to FDs:MAXthr.
				set FactorVspeedLand to FDs:FactorVspeedLan.
				set M to FDs:AmplitudeRatio.
				set TU to FDs:MesuredPeriod.			
			}
}

// ---- Function landing Mode ----
function landingButton
{ 
	if AltiRad > 180 or AltiRad < 40													// check for valid altitude
	{
		if altiRad > 200 InfoHud("* too much Altitude Recommanded 170 meter *", blue).
		if AltiRad < 60 InfoHud("* too low Altitutde Recommanded 60 meter *", blue).
		return.
	}
	// ---- retrieve pitch and roll and yaw(heading) ----
	sas off.
	CLEARVECDRAWS().
	set showhead to compass_for().
	lock steering to heading(showhead,0).
	local Landflash to Flashthing("[#e50000ff][hw] LANDING[/hw][#CEE3F6FF] ", "[hw]        [/hw] ", 0.8, label, 1).
	set altitudestart to AltiRad.
	MovePart("Stop").
	MoveLandingLight("Move")().
	set sound1:tempo to 1.5.
	set sound1:loop to true.
	playNoteF("FA", "SOL", 1).
	until ship:status = "LANDED" or ship:status = "SPLASHED"
	{
		set hoverPID:setpoint to (FactorVspeedLand * (AltiRad/altitudestart))-1.
		set CurentThrottle to hoverPID:update(time:seconds, ship:verticalspeed).
		if AltiRad < 40 and not gear {gear on.}
		Landflash["FlashLF"]().
		Aff_Values(2). 									  								// show info values and hover state
		wait 0.001.	
	}
	lock throttle to 0.
	set sound1:loop to false.
	MoveLandingLight("Stop")().
	InfoHud("-- SHIP ON THE GROUND --"+"-"+ship:status+"-", green).
	stop().
}.

// ---- function to choose the planet ----
function FindPlanet
{
	// ===================== setting variables ======================
	local bu is setKPMapi("B").
	local lb is setKPMapi("L").
	local current_option to 1.                                                      // Variable for user choice & indicator position set to kerbin default
	local calTWR is false.
	list bodies in PlanetLst.
	local index is PlanetLst:length().
	local curentBod is PlanetLst:iterator.
	local indicator is Flashthing("P", " ", 0.8).
	local decal is 2.

	// setting labels txt
	lb["setTXT"](7, " UP ").
	lb["setTXT"](8, " DOWN").
	lb["setTXT"](9, " ENTER").

	// setting state of ENTER
	lb["setSTA"](9, false).

	// delegate buttons
	bu["dele"](7, Bup@).                                                           	// Choice Indicator UP
	bu["dele"](8, Bdown@).                                                        	// Choice Indicator DOWN
	bu["dele"](9, Benter@).                                                        	// Validate Choice
	
	// Main Screen setting screen info planet display
	Print "---- CHOICE PLANETE ----" at(5, 0).
	print "------------------------" at(5, 1).
	UNTIL NOT curentBod:NEXT
	{
    	PRINT " [ ]-> " + curentBod:VALUE at(6, decal + curentBod:index).
	}
	indicator["FlashSTR"](8, current_option + decal).								// Place indicator before loop start

	// ---- Main loop choice ----
	print "index : " + index at(30,4).
	until lb["getSTA"](9) 
	{
		indicator["FlashSTR"](8, current_option + decal).                          	// Moving flashing Indicator.
		print "current option : " + PlanetLst[current_option] + "  " at(30,5).
		if calTWR
		{        
			// active planet
			clearScreen.
			lb["Reset"]().															// clean labels
			return PlanetLst[current_option].
		}
		wait 0.001.  
	}.
	
	// ===== internal functions =====
	local function Bup // move up indicator                                                          
	{
		set current_option to current_option - 1.
		if current_option < 0 
		{
			print " " at(8, current_option + decal + 1).
			set current_option to index-1.        
		}
		print " " at(8, current_option + decal + 1).
		wait 0.1.
	}
	local function Bdown // move down indicator
	{
		set current_option to current_option + 1.
		if current_option >= index 
		{
			print " " at(8, current_option + decal - 1).
			set current_option to 0.
		}
		print " " at(8, current_option + decal - 1).
		wait 0.1.
	}
	local function Benter // validate choice
	{
		set calTWR to true.
		lb["setSTA"](9, true).
	}
}

// ---- function to calculate TWR only for selected VTOL engines ----
function CalcTWRMax
{
	local parameter type,
					name.

	list engines in listengine.														// Retrieve all engine in ship
	// testing if Motor with KosTag "VTOL" present
	for eng in listengine
	{
		if eng:tag = name {
			break.
		} else
		{
			hudtext("-No Motors with tag VTOL detected-", 5, 4, 50, red, false).
			hudtext("       -Program ENDING-", 5, 4, 50, green, false).
			wait 4.
			core:activate.															// Reboot to boot file
		}
	}
	// acceleration
	local g is actualPlanet:mu / actualPlanet:RADIUS^2.
	// retieve engine in ship TAG: VTOL
	
	local totalThrust is 0.
	for eng in listengine
	{
		
		if eng:tag = name and type = "POSSIBLETHRUST"
		{ set totalThrust to totalThrust + eng:POSSIBLETHRUST. } else
			{ set totalThrust to totalThrust + eng:THRUST. }
	}
	return totalThrust / (ship:mass * g).											// Formule is Maxthrust/(mass *g)
}

// ---- function to determine the Mesured Period TU based on time reached to full TWR
function CalTu
{
	parameter stTime.
	lock actualtwr to CalcTWRMax().
	wait until actualtwr >= Total_TWR_Vtolengs.
	set TU to (time:seconds - stTime).
	actualVertSpPID().
	actualHoverPid().
	set TUcheck to false.
}

// ======     PidLoop       Functions adjustement     =====
// ---- set SETPOINT for the two pidloop ----
function actualSetpoint
{ 
	set hoverPID:setpoint to TargetVertSpeed.
	set VertSpPID:setpoint to seekAlt.
}.

// ---- Actualise hoverPIDloop throttle control ----
function actualHoverPid
{ set hoverPID to pidLoop(KP, KI, KD, MINthr, MAXthr). }

// ---- Actualise VertSpPIDloop vertical speed control ----
function actualVertSpPID
{ 
	parameter min.
	set VertSpPID to pidLoop(KP , KI, KD, min, MAXVspeed).
}
// ---- adjustement for VertSpPIDloop Min output ----
function AjustVertSpeedMin
{
	set setpointcheck to false.														// First Pass
	if curent_Alt > 300 and MINVspeed <> -5											// check altitude > 300 & MINVspeed changed or not changed
	{ actualVertSpPID(-5). settrue(-5).} else											// Update PIDloop and store actual MINVspeed
	if curent_Alt > 200 and MINVspeed <> -4											// check for > 200
	{ actualVertSpPID(-4). settrue(-4).} else											// update
	if curent_Alt > 100 and MINVspeed <> -2.5										// check for > 100
	{ actualVertSpPID(-2.5). settrue(-2.5).} else										// update
	if curent_Alt <= 50 and MINVspeed <> -1											// check for <= 50
	{ actualVertSpPID(-1). settrue(-1).}												// update
	if setpointcheck actualSetpoint().												// if MINVspeed has changed update PIDloop
	wait 0.001.
	//
	local function settrue															// store MINVspeed and activate Update
	{ 
		parameter check.
		set MINVspeed to check.
		set setpointcheck to true.
	}
}

// ---- input altitude keyboard ----
function InputAltKeyB
{
	set inalt to terminal_input_number(19,5,5).		  // library function
	set inalt to inalt:tonumber().					  // convert to number
	if inalt < 0 set inalt to 0.
	if inalt > 1000 set inalt to 1000.
	set seekAlt to inalt.
	actualSetpoint().
	print "     " at(19,5).
}

// ===== Function for moving selected part in ship =====
// ---- Grouped parts Vtol mod STAB ON or OFF ----
function MovePart
{
	parameter name.
	cherryLight[name]().
	aeroBreak[name]().
}

// ---- Grouped parts Landing Mod ----
function MoveLandingLight
{
	parameter name.
	LandL[name]().
	CtrlLight[name]().
}

// =============== D E L E G A T E Functions =================
// ---- function altitude mode rad or sealevel button 0 ----
function RadarMode
{
	parameter bool.
	if bool
	{
		label["setTXT"](0, " [hw][#00ff00ff]seaAlt[#CEE3F6FF][/hw] ").
		label["setSTA"](0, false).
		button["dele"](0, RadarModeB:bind(label["getSTA"](0))).
		set seekAlt to Altisea.						  								// to keep altitude level
		lock curent_Alt to Altisea.					  								// curent altitude set to sea level
		actualSetpoint().
	} else
	{
		label["setTXT"](0, " [hw][#00ff00ff]radAlt[#CEE3F6FF][/hw] ").
		label["setSTA"](0, true).
		button["dele"](0, RadarModeB:bind(label["getSTA"](0))).
		set seekAlt to AltiRad.						  								// to keep altitude level
		lock curent_Alt to AltiRad.					  								// curent altitude set to radar level
		actualSetpoint().
	}.
	playNoteF("d4", "r4").
}.

// ---- function exit button 5 & save parameter ----
function stop
{ 
	LIST FILES in curentsavedfile.
	for n in curentsavedfile
	{
		if n = FullNameAircraft
		{
			writeJson(FullNameAircraft, "0:/AIRCRAFT/").
			break.
		}
	}
	sound2:play(musique()).							  // for fun :) (testing)
	wait until not sound2:isplaying.
	set running to true.							  // End Main hover boucle
}.
// ---- function MINthr output increment with deltamaxmin value depend signe button 7 ----
function FuncMINthr
{
	set MINthr to MINthr + DeltaMaxMin.
	if Minthr < 0 set MINthr to 0.                    // not negative value.
	if MINthr > 1 set MINthr to 1.                	  // max value 1 
	actualHoverPid().
	MinthFlash["FlashLFOne"]().
}.

// ---- function MAXthr OUtput increment with deltamaxmin value depend signe button 8 ----
function FuncMAXthr
{
	set MAXthr to MAXthr + DeltaMaxMin.
	if MAXthr < 0 set MAXthr to 0.                	  // not negative value
	if MAXthr > 1 set MAXthr to 1.					  // max value 1
	actualHoverPid().
	MaxthFlash["FlashLFOne"]().
}.

// ---- function changing signe for deltamaxmin button 9 ----
function DeltaMaxMinOutput
{
	parameter bool.
	if bool
	{
		label["setSTA"](9, false).
		set DeltaMaxMin to 0.01.
		label["setTXT"](9, "     [#00ff00ff]+[#ffffffff]0.1").
		button["dele"](9, DeltaMaxMinOutputB:bind(label["getSTA"](9))).
	} else
	{
		label["setSTA"](9, true).
		set DeltaMaxMin to -0.01.
		label["setTXT"](9, "     [#00ff00ff]-[#ffffffff]0.1").
		button["dele"](9, DeltaMaxMinOutputB:bind(label["getSTA"](9))).
	}.
}.

// ---- Function control Vertical speed factor value in landing mode ----
function FactorVspUP	// increase
{
	set FactorVspeedLand to FactorVspeedLand - 1.
}
function FactorVspDO	// decrease
{
	set FactorVspeedLand to FactorVspeedLand + 1.
}

// ---- Function altitude management button 10 11 12 13 ----
function SeekAlBut10	// button 10
{
	set seekAlt to seekAlt + 10.
	actualSetpoint().
	playNote("C3").
	SeekAl10Fl["FlashLFOne"]().
}.
function SeekAlBut11	// button 11
{
	set seekAlt to seekAlt - 5.
	if seekAlt < 0 set seekAlt to 0.
	actualSetpoint().
	playNote("E3").
	SeekAl11Fl["FlashLFOne"]().
}.
function SeekAlBut12	// button 12
{
	set seekAlt to seekAlt + 1.
	actualSetpoint().
	playNote("C3").
	SeekAl12Fl["FlashLFOne"]().
}.
function SeekAlBut13	// button 13
{
	set seekAlt to seekAlt - 1.
	if seekAlt < 0 set seekAlt to 0.
	actualSetpoint().
	playNote("E3").
	SeekAl13Fl["FlashLFOne"]().
}.

// ================ Display Functions ================
// ---- main screen display ----
function Main_Screen
{
	clearScreen. // delete the last setup screen
	print "   _________________________________________________" at(0,00).
	print "    |[#2110E7]                -- [font4]V T O L[font0] --{COLOR}                  |" at(0,01).
	print "    |  set  hover at :                              {COLOR}         |" at(0,02).
	print "    |  Infos :                                      |" at(0,03).
	print "    |  Steering is free for now (next update)       |" at(0,04).
	print "    |  Alt Entry :                                  |" at(0,05).
	print "    |  TWR for Vtol ENG :                                    {COLOR}|" at(0,08).
	print "    |[#E7D410]                 _________{COLOR}                     |" at(0,06).
	print "    |    -- PID setting for throttle control --     |" at(0,07).
	print "    |[#E7D410]  MINOUTPUT :                                           {COLOR}|" at(0,09).
	print "    |[#E7D410]  MAXOUTPUT :                                           {COLOR}|" at(0,10).
	print "    |  active radar :                                             |" at(0,11).
	print "    |  passive radar alt :                          |" at(0,12).
	print "    |[#E7D410]                 _________{COLOR}                     |" at(0,13).
	print "    |[#3D44B7]       Seek ALT =                          {COLOR}             |" at(0,14).
	print "    |[#3D44B7]        Cur ALT =                          {COLOR}             |" at(0,15).
	print "    |[#3D44B7]       Throttle =                          {COLOR}             |" at(0,16).
	print "    | VertSp Fac Lnd Mod :                          |" at(0,17).
	print "    |____________________________________" + hoVers + "_______|" at(0,18).
	print "Ldg Vert Spd Up+1->" at(64,00).
	print "Ldg Vert Spd Do-1->" at(64,04).
}.

// ---- hud text ----
function InfoHud
{
	parameter texte ,
			  colr,
			  loc is 4.
	// stingMessage,delayseconde,style,size,color,booleanecho
	// style: 1upperlefet,2uppercenter,3upperright,4lowcenter,
	hudtext(texte, 3, loc, 30, colr, false).
}

// ---- Call to update the display of values ----
function Aff_Values
{
	parameter startRow. // define where the block of text should be positioned
	// target altitude (top)
	print "[#E50E53]" + round(seekAlt, 1) + " m   " at (23, startRow).
	// Value for MINoutput & MAXoutput Pid
    print "[#E50E53]" + round(MINthr, 2) + "   " at(28, startRow+7).
    print "[#E50E53]" + round(MAXthr, 2) + "   " at(28, startRow+8).
	// Show Target Altitude VS Curent altitude
	print "[#E50E53]" + round(seekAlt, 1) + " m   " at (32, startRow+12).
	print "[#E50E53]" + round(curent_Alt, 1) + " m   " at (32 ,startRow+13).
	// Throttle management
	print "[#E50E53]" + round(CurentThrottle, 2) + "     " at (32 ,startRow+14).
	// section info value
	print "Vs: " + round(ship:verticalspeed, 3) at(15, startRow + 1).
	print " TargSp: " + round(TargetVertSpeed, 2) at(24, startRow + 1).
	// Landing Factor Vertical speed
	print FactorVspeedLand + "  " at (27, startRow + 15).
	// Show the TWR for engine used for scrip hover
	print "[#33FF00]" + round(Total_TWR_Vtolengs,2) at(26, 8).
}.

// ----          SOUNDS MANAGEMENT			 ----
function definesound
{
	parameter sound,
			  wave,
			  attack,
			  decay,
			  sustain,
			  release,
			  volume.
	set sound:wave to wave.
	set sound:attack to attack.
	set sound:decay to decay.
	set sound:sustain to sustain.
	set sound:release to release.
	set sound:volume to volume.	
}
// ----            Buttons sounds			 ----
function playNote									  // short sound
{
	parameter a,									  // input letter note no frequency
			  dur is 0.05,
			  keyd is 0.2.
	// note(Frequency, Endfrequency or note, duration, keyDownlenght, volume)
	Sound1:play( note(a, dur, keyd)).
}.
// ----           Fonctions sounds			 ----
function playNoteF									  // slide sound
{
	parameter a,									  // input start letter note no frequency
			  b,	
			  dur is 0.05,
			  keyd is 0.2.
	// note(Frequency, Endfrequency or note, duration, keyDownlenght, volume)
	Sound1:play( slideNote(a, b, dur, keyd)).
}.
// ----           Music exit hover           ----
function musique
{
	set Partition to list().
	partition:add(note("g4", 0.1, 0.20)).
	Partition:add(note("g4", 0.1, 0.20)). 
	Partition:add(note("f4", 0.1, 0.20)). 
	Partition:add(note("e4", 0.1, 0.20)). 
	Partition:add(note("d4", 0.1, 0.20)). 
	Partition:add(note("c3", 0.1, 0.20)).

	return Partition.
} 
// end file