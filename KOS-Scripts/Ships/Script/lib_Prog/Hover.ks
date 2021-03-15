//:Hover & Landing Program
// Using the PIDLoop integrated in kos
// MFD buttons , added input altitude & landing Mode & new library
// Action and event in selected part module by kos tag
// Main pidloop Parameter are saved in corresponding aircraft file.txt in a special data folder
// Testing PIdloop setting using the Ziegler-Nichols method (wiki kos)
//
// Copyright © 2021 Masset Stephane 
// Lic. Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)

parameter inpalt is 0,  		                       								// base height if nothing enter
		  vTn 	 is "VTOL".															// Default name tag for motor (search)

// ---- My user functions in library folder ----
runPath ("0:/library/lib_KpmAddons.ks").											// library (label flag and button function)
runPath ("0:/library/lib_FlashString.ks").											// library function for string & label effects
runPath ("0:/library/lib_MovePart.ks").	    										// library perform action & event
// ---- user function kos library ----
runPath ("0:/library/lib_input_terminal").			  								// for input altitude
runpath ("0:/library/lib_navball").					  								// library function for fly data

// ===================== setting variables ======================
local NaAc is ship:shipName.														// name of vessel
set FullNameAircraft to NaAc+".txt".												// Full name for saved file
set FoldName to "AircraftParaM".													// Name of stored data folder
switch to 0.																		// NOT in boot directory and local ship store
set vol to core:currentvolume.														// Actual Volume of processor (hardisk)
set VTOLname to vTn.																// set vtol engine name default "VTOL"
set hoVers to "V5.2".																// version tag
set bound_Box to ship:bounds.                         								// ship volume
// Current Altitude radar under ship no negative value
lock AltiRad to choose 0 if bound_Box:bottomaltradar < 0 else bound_Box:bottomaltradar.
// Current Altitude Sealevel under ship	no negative value
lock Altisea to choose 0 if bound_Box:bottomalt < 0 else bound_Box:bottomalt.												
lock curent_Alt to AltiRad.															// Set to radar by default
set CurentThrottle to ship:control:pilotmainthrottle. 								// keep actual throttle
set DeltaMaxMthr to -0.1.							  								// Switch to increase or decrease defaut -0.1
set DeltaseekAlt to 5.																// Negative (Variable) increment for selected altitude
set running to false.								  								// Main hover boucle is on
set timerTime to 0.3.								  								// delta time for flashing label text one time
set onepass to true.								  								// SAS switch
set M to 1.																			// Amplitude Ratio -> searching to find the value
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
lock FileDatas to lexicon(															// Create default data lexicon pointing on variable dynamic
		"MINthr", 			MINthr,
		"MAXthr", 			MAXthr,
		"FactorVspeedLand", FactorVspeedLand,
		"AmplitudeRatio", 	M,
		"MesuredPeriod", 	TU,
		"TUcheck",          TUcheck,
		"KosTagMotor",		VTOLname,
		"Ship Name",		NaAc,
		"Version script",   hoVers).
// [#d8dcd6ff] is "light grey" defaut {COLOR}
// ---- Checking if parameter saved file exist if not create it ----
// ----       Or update DATAS LEXICON from existing file		----
LoadStoreDat(FullNameAircraft, FileDatas).											// Update or save Datas
//
// ----          sounds             ----
set Sound1 to getVoice(0).															// button sound
definesound(Sound1,"SQUARE", 0, 0.01, 0.5, 0.1, 0.3).								// sound definition
set sound2 to getVoice(1).															// end hover music
definesound(sound2,"TRIANGLE", 0.0333, 0.02, 0.80, 0.05, 0.3).						// sound definition
set sound2:tempo to 2.

// ---- setting moving Part objects ----
set cherryLight to MovPartOBJ("HoverLight", "ModuleLight", "activer l'éclairage").
set aeroBreak to MovPartOBJ("KosAerofrein","ModuleAeroSurface", "activer").
set LandL to MovPartOBJ("LandL", "ModuleLight", "activer l'éclairage").
set CtrlLight to MovPartOBJ("CtrlLandL", "ModuleRoboticController", "Activer la lecture").

// ---- pidLoop(KP, KI, KD, MINOUTPUT, MAXOUTPUT) ----
set hoverPID to pidLoop(KP, KI, KD, MINthr, MAXthr).  								// set pidloop for throttle
set VertSpPID to pidLoop(KP, KI, KD, MINVspeed, MAXVspeed).							// set pidloop for target vertical speed default
set hoverPID:setpoint to 0.							  								// set vertical speed setpoint to 0 on start

// ----    setting the altitude on start depend choice off user    ----
// ---- prevent falling ship if script started with ship is flying ----
set seekAlt to choose AltiRad if inpalt = 0 else inpalt.
if seekAlt > 1000 {set seekAlt to 1000.}
set VertSpPID:setpoint to seekAlt.					  								// the choosed altitude setpoint at start
set checkseekALT to seekAlt.														// store first value before is change later (user input new altitude)

// ---- setting objects to acces buttons and button label ----
set button to setKPMapi("B").							  							// object Buttons			  
set label to setKPMapi("L").							  							// object label for text and state
button["clear_dele"]().																// Reset buttons delegate from previous script
label["Reset"]("").																	// Reset all label from previous script

// ---- setting Planet ----
set actualPlanet to FindPlanet().													// setting body to calcul TWR max

// ---- setting Labels ----
label["setTXT"](0, "[hw][#00ff00ff] radAlt ").		      							// show actual radar mode
label["setTXT"](1, "    LANDING").													// Mode landing label
label["setTXT"](3, "            INPUT").											// Input altitude
label["setTXT"](4, "     [#ff0000ff]StabOFF").										// Mode stab
label["setTXT"](7, " [hw]Minthr").													// Min output pidloop throttle
label["setTXT"](8, "     Maxthr").													// Max output pidloop throttle
label["setTXT"](9, "     [#00ff00ff]-[#FFFFFFFF]0.01").								// start sign for Max and Min
label["setTXT"](10, "      Alt+10").												// altitude +10
label["setTXT"](11, ("      Alt-" + DeltaseekAlt)).						// altitude -5 default start

// ---- Main function program STATE ----
label["setSTA"](0, true).							  								// Radar mode default radar altitude.
label["setSTA"](9, true).                              								// delta state -0.1 default is true switch

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
button["dele"](11, SeekAlBut11@).									// - Button
button["dele"](-6, DeltaseekAlup@).									// DeltaseekAlt + Button
button["dele"](-5, DeltaseekAldw@).									// DeltaseekAlt - Button
button["dele"](-3, FactorVspUP@).									// Up button to increase landing vertical speed factor
button["dele"](-4, FactorVspDO@).									// Down button to decrease landing verticla speed factor

// ---- setting Flashing Objects ----
// RADAR string flash (string)
set AlRadIndic to Flashthing("[font4] RADAR [font0]", "[font4]       [font0]", 0.8).
// SEA LEVEL flash (string)
set AlSeaIndic to Flashthing("[font4] SEA L [font0]  ", "[font4]       [font0]  ", 0.8).
// Minthr flash (label 7)
set MinthFlash to Flashthing(" [#ff0000ff][hw]Minthr", " [hw]Minthr", timerTime, label, 7).
// MAXthr flash (label 8)
set MaxthFlash to Flashthing("     [#ff0000ff][hw]MAXthr", "     [hw]MAXthr", timerTime, label, 8).
// StabON mode flash (label 4)
set StabON to Flashthing("     [#33FF00ff]StabON", "     [#33FF00ff]      ", 0.8, label, 4).
// Alt+10 flash (label 10)
set SeekAl10Fl to Flashthing("[#ff0000ff]      [hw]Alt+10", "      [hw]Alt+10", timerTime, label, 10).
// Alt-[variable] flash (label 11)
lock SeekAl11Fl to Flashthing(("[#ff0000ff]      [hw]Alt-" + DeltaseekAlt), ("      [hw]Alt-" + DeltaseekAlt), timerTime, label, 11).

// ---- take control on throttle & sas ----
lock throttle to CurentThrottle.
sas on.

// ---- Display main screen Structure First Pass ----
set StarRowDynamicValues to 2.														// starting row dynamic screen
Main_Screen().																		// Static screen
Aff_Values(StarRowDynamicValues).													// Dynamic screen	
InfoHud("* hover Controle on *", red).
//
//                             ------------ Main hover Boucle -------------
// setting
set Total_TWR_Vtolengs to CalcTWRMax("POSSIBLETHRUST", VTOLname).					// Max TWR at full condition show value in mfd
if M = 0 set M to Total_TWR_Vtolengs.												// setting the amplitude Ratio if not defined(0)
// loop
until running                              			  								// Start on
 {
	// PIDLOOP section (setup & actualisation)
	set TargetVertSpeed to VertSpPID:update(time:seconds, curent_Alt).				// actualise vertical speed vs altitude
	set hoverPID:setpoint to TargetVertSpeed.										// set setpoint of throttle pidloop
	set CurentThrottle to hoverPID:update(time:seconds, ship:verticalspeed).		// update throttle pidloop
	if TUcheck and (checkseekALT <> seekAlt) CalTu(time:seconds).					// start the calcul for TU parameter if condition true (altitude change)
	AjustVertSpeedMin().															// Contrôle Minoutput for VertSpPID
	// Display (Dynamic) Hover script Mod data
	if label["getSTA"](0) AlRadIndic["FlashSTR"](25, StarRowDynamicValues + 1).		// Flash Mod RADAR 
		else AlSeaIndic["FlashSTR"](25, StarRowDynamicValues + 1).					// Flash Mod SEA LEVEL
	if not sas StabON["FlashLF"]().													// stability assit flash on (sas off)	
	Aff_Values(StarRowDynamicValues). 									  			// show values of hover script
  	// Timming (see kos wiki, in the CPU hardware description page)
	wait 0.001.
}.
//
//                             ------------ END hover Boucle -------------
//
// ---- exit setup parameter of ship ----
InfoHud("* hover Controle off *", blue).
MovePart("Stop").																	// Stop animated parts 
MoveLandingLight("Stop").															// stop animated lights 
// Give control to player landed or not landed
if ship:status = "FLYING" sas on. else sas off.										// set SAS depend flight status
unlock steering.
set ship:control:pilotmainthrottle to throttle.										// Return control to player flying or not flying
CLEARVECDRAWS().																	// cleaning all vectors in game if present
// ---- reset ADDONS:KPM ----
button["clear_dele"]().
label["Reset"]("     ").															// No string in Labels
// ---- reboot to boot start program (return to main menu) ----
core:activate.
// 									==========================
// 									==== end HOVER script ====
//
// ================ HOVER FUNCTIONS FOR vessel =================
// ==========  Function SAS state	===========
function ChekSasState
{
	// ---- stability Assit depend sas on or off ----
	if not sas and onepass							  								// set one time until action on sas change (off)
    {
		// ---- retrieve pitch and roll and yaw(heading) ----
		set showhead to compass_for().
		lock steering to heading(showhead,0).
		InfoHud("* stab on *", blue).
		MovePart("Move").															// part moving on
		// ---- vector learning things debug ----
		set V1 to vecDraw(v(0,0,0), ship:facing:forevector, blue, "forevector Z", 6, true, 0.1, true, true). 	// Z
		set V2 to vecDraw(v(0,0,0), ship:facing:topvector, red, "topvector Y", 6, true, 0.1, true, true). 		// Y
		set V3 to vecDraw(v(0,0,0), ship:facing:starvector, green, "starvector X", 6, true, 0.1, true, true). 	// X    
	}.
    if sas and not onepass															// set one time until action on sas change  (on)  
    {
        unlock steering.															// Important no lock with SAS on
        set onepass to true.														// Inverse SAS SWITCH action
		InfoHud("* Stability Mode OFF SAS on *", blue).
		label["setTXT"](4, "     [#ff0000ff]StabOFF").								// Restore original display 
		CLEARVECDRAWS().															// Clear vecDraw things
		MovePart("Stop").															// part moving off
    }.
}
//
// ========== Function landing Mode ===========
function landingButton
{ 
	if AltiRad > 180 or AltiRad < 40												// check for valid altitude
	{
		if altiRad > 180 InfoHud("* too much Altitude Recommanded 180 meter *", blue).
		if AltiRad < 40 InfoHud("* too low Altitutde Recommanded 40 meter *", blue).
		return.
	}
	// ---- Prepare ship status for landing & sound ----
	CLEARVECDRAWS().																// if present clear
	MovePart("Stop").																// stop moving part if exist		
	MoveLandingLight("Move")().														// Move or activate light
	set sound1:tempo to 1.5.														// Update voice 0 tempo (using button sound now)
	set sound1:loop to true.														// Voice 0 is looping now
	playNoteF("FA", "SOL", 1).														// PLay sound
	// ---- retrieve pitch and roll and yaw(heading) ----
	sas off.																		// SAS script take control steering
	set showhead to compass_for().													// Take the current direction degress
	lock steering to heading(showhead,0).											// set direction and pitch
	//
	// ----                Main descent LOOP               ----
	// setting
	// Change label 1 text to dynamic display set current altitude to radar mode
	local Landflash to Flashthing("[#e50000ff][hw] LANDING[/hw][#CEE3F6FF] ", "[hw]        [/hw] ", 0.8, label, 1).
	set altitudestart to AltiRad.													// Starting altitude to ground
	// loop
	until ship:status = "LANDED" or ship:status = "SPLASHED"						// Test if ship landing ended
	{
		// Actualise setpoint of throttle Pidloop with progressive verticalspeed (decrease value)
		set hoverPID:setpoint to (FactorVspeedLand * (AltiRad/altitudestart))-1.	// calcul with factor	
		set CurentThrottle to hoverPID:update(time:seconds, ship:verticalspeed).
		if AltiRad < 40 and not gear {gear on.}										// Gear On if not
		Landflash["FlashLF"]().														// Label flash land mod active
		AlRadIndic["FlashSTR"](25, StarRowDynamicValues + 1).						// Rad alitude flashing stat for landing
		Aff_Values(StarRowDynamicValues). 									  		// Actualise display value during landing
		wait 0.001.																	// Timming	
	}
	// ----                 EXIT LOOP                      ----
	// ----                SHIP LANDED					   ----
	// Set SHIP state
	set sound1:loop to false.														// stop sound
	lock throttle to 0.																// Set Throttle to 0.
	MoveLandingLight("Stop")().														// Stop animated Lights
	InfoHud("-- SHIP ON THE GROUND --"+"-"+ship:status+"-", green).					// Display SHIP state landed
	stop().																			// Call the exit function
}.
// ================= MAIN FUNCTIONS script ==================
// - DATA settings
// ---- Function Save or Read Parameter ----
function LoadStoreDat
{
	parameter name is path,															// Path or string (name of ship)
			  dat  is lexicon().													// The lexicon data saved by scrip
	if not vol:EXISTS(FoldName)														// check if folder exist or creat it
	{
		vol:createdir(FoldName).													// Create folder with 'FoldName' variable name (0:/)
		CD(FoldName).																// Change directory to Parameter save folder
	} else CD(FoldName).															// same (folder exist)
	// ---- Create File if not exist or read value from file ----
	if not vol:exists(FoldName + "/" + name)										// Check if file present
	{	
		WRITEJSON(dat, name).														// Save New lexicon Data file (no file present)
	} else {
				local FDs is READJSON(name).										// store lexicon Data from file (file is present)
				// update data (keys match the creation lexicon of course)
				set MINthr to FDs:MINthr.
				set MAXthr to FDs:MAXthr.
				set FactorVspeedLand to FDs:FactorVspeedLand.
				set M to FDs:AmplitudeRatio.
				set TU to FDs:MesuredPeriod.
				set TUcheck to FDs:Tucheck.
				set VTOLname to FDs:KosTagMotor.			
			}
}
//
// ---- function to choose the planet ----
function FindPlanet
{
	// ===================== setting variables ======================
	set current_option to 1.                                                        // Index for user choice (set to kerbin default)
	local current_option_up to current_option - 1.									// Index - 1 precedent planet
	local current_option_dw to current_option + 1.									// Index + 1 next planet
	list bodies in PlanetLst.														// Planets list
	local nbrPla is PlanetLst:length().												// Total Planet in list (list-1)
	local row to 3.																	// row placement for screen info
	local col to 12.																// column placement for screen info
	label["setSTA"](-1, false).														// setting state of ENTER
	//
	// delegate buttons use same as global scrip
	button["dele"](-3, Bup@).                                                       // Choice Indicator UP
	button["dele"](-4, Bdown@).                                                     // Choice Indicator DOWN
	button["dele"](-1, Benter@).                                                    // Validate Choice
	//
	// Main Screen setting screen info planet display
	print "---- [#ffff14ff]CHOICE PLANETE{COLOR} ----" at(col + 9, row).
	print "------------------------" at(col + 9, row + 1).
	print "Nombre de Planetes Trouvees : " + (nbrPla-1) at(col + 5, row + 4).
	//
	// ----                Main loop choice Display                    ----
	//
	until label["getSTA"](-1)														// Wait for enter button 
	{	
		print "--------------------------------" at (col + 5, row +5).
		print "                  " + "[#92959150]-" + PlanetLst[current_option_up]:name + "-          " at(col + 5,row + 6).
		print "Current option :  " + "[#02ab2eFF]-[font4] " + PlanetLst[current_option]:name + " [font0]-          " at(col + 5, row + 7).
		print "                  " + "[#92959150]-" + PlanetLst[current_option_dw]:name + "-          "  at(col + 5, row + 8).
		print "--------------------------------" at(col + 5, row + 9).
		wait 0.1.  
	}
	// ----                       END loop                             ----
	// ===== internal functions =====
	local function Bup 																// move up indicator                                                          
	{
		set current_option to current_option - 1.									// Active choice operation
		if current_option = - 1 													// Top index return to end index
		{
			set current_option to (nbrPla - 1).										// set to end index (current)
			set current_option_up to (nbrPla - 2).									// set to end index -1 (Precedent)
			set current_option_dw to 0.												// set to top index (Next)      
		} else
			{
				// Cosmetic info (precedent) prevent -1 value for index
				set current_option_up to choose (nbrPla - 1) if current_option = 0 else current_option_up - 1.						
				set current_option_dw to current_option + 1.						// (next)
			}
	}
	local function Bdown 															// move down indicator
	{
		set current_option to current_option + 1.									// Active choice operation
		if current_option = nbrPla													// End Index return to top
		{
			set current_option to 0.												// set to top index (Current)
			set current_option_up to (nbrPla - 1).									// (precedent)
			set current_option_dw to current_option + 1.							// (next)
		} else
			{
				set current_option_up to current_option - 1.						// (precedent)
				// (next) prevent exceeding index+1
				set current_option_dw to choose 0 if current_option = (nbrPla - 1) else current_option + 1.						
			}
	}
	local function Benter 															// validate choice
	{
		label["setSTA"](-1, true).
	}
	// END FUNCTION
	clearScreen.
	label["Reset"]("     ").														// Reset labels
	button["clear_dele"]().															// Reset buttons delegate
	return PlanetLst[current_option].												// return Planet from curent index
}
// - ENGINE FUNCTIONS
// ---- function to calculate TWR only for selected VTOL engines two option ----
// Option 1 : eng:POSSIBLETHRUST : http://ksp-kos.github.io/KOS_DOC/structures/vessels/engine.html#attribute:ENGINE:POSSIBLETHRUST
// Option 2 : eng:THRUST : http://ksp-kos.github.io/KOS_DOC/structures/vessels/engine.html#attribute:ENGINE:THRUST 
function CalcTWRMax
{
	local parameter Thrusttype,														// choosing option	
					name.

	list engines in listengine.														// Retrieve all engine in ship
	// testing if Motor with KosTag 'name' present and calcul if true
	if listengine:find(name) <> -1													// Search if at last one Tag motor 'name' present
	{
		local g is actualPlanet:mu / actualPlanet:RADIUS^2.							// acceleration
		local totalThrust is 0.														// Local Thrust parameter SUM total
		for eng in listengine														// retieving engine in ship with TAG: 'name'
		{
			if eng:tag = name and Thrusttype = "POSSIBLETHRUST"						// selected engine and first option
			{ set totalThrust to totalThrust + eng:POSSIBLETHRUST. } else			// SUM of engine
				{ set totalThrust to totalThrust + eng:THRUST. }					// SUM of engine second option
		}
		return totalThrust / (ship:mass * g).										// return update total SUM calcul on Formula is Maxthrust/(mass *g)
	} else																			// No engine
		{
			clearscreen.
			hudtext("-No Motors with tag VTOL detected-", 5, 4, 30, red, false).
			hudtext("    -Program ENDING-", 6, 4, 30, green, false).
			wait 5.
			core:activate.															// Reboot to boot file
		}
}
// ---- function to determine the Mesured Period TU based on time reached to full TWR
// In test wip
function CalTu
{
	lock actualtwr to CalcTWRMax("THRUST", VTOLname).								// take the actual thrust
	local startime is time:seconds.													// Starting count delay		
	WHEN actualtwr >= Total_TWR_Vtolengs THEN										// End if Full thrust										// Moment when actual thrust reach total thrust 
	{
		if actualtwr >= Total_TWR_Vtolengs											// At the moment Full Thrust 
		{
			set TU to (time:seconds - starTime).									// Active time - starting time (Should be positive)	
			// Update PIDLOOPs because parameter are constantly updated by TU
			actualVertSpPID(MINVspeed).
			actualHoverPid().
			set TUcheck to false.													// One Pass lift off moment
		}
		wait 0.001.
	}
}
//
// - PidLoop Functions adjustement
// ---- set SETPOINT for the two main pidloop ----
function actualSetpoint
{ 
	set hoverPID:setpoint to TargetVertSpeed.										// Throttle PID
	set VertSpPID:setpoint to seekAlt.												// Vertical speed PID
}.
//
// ---- Actualise hoverPIDloop throttle control ----
function actualHoverPid
{ set hoverPID to pidLoop(KP, KI, KD, MINthr, MAXthr). }							// ALL values
//
// ---- Actualise VertSpPIDloop vertical speed control ----
function actualVertSpPID
{ 
	parameter min is -1.															// Security value (-1) if no entry 
	set VertSpPID to pidLoop(KP , KI, KD, min, MAXVspeed).							// ALL values possibility to change MinOUTPUT value
}
//
// ---- adjustement for VertSpPIDloop Min output ----
// ADDED because hight negative verticalspeed dangerous with low
// delay time response motor thrust 
function AjustVertSpeedMin
{
	set setpointcheck to false.														// First Pass
	if curent_Alt > 300 and MINVspeed <> -5											// check altitude > 300 & MINVspeed changed or not changed
	{ settrue(-5).} else															// Update PIDloop and store actual MINVspeed
	if curent_Alt > 200 and MINVspeed <> -4											// check for > 200
	{ settrue(-4).} else															// update
	if curent_Alt > 100 and MINVspeed <> -2.5										// check for > 100
	{ settrue(-2.5).} else															// update
	if curent_Alt <= 50 and MINVspeed <> -1											// check for <= 50
	{ settrue(-1).}																	// update
	if setpointcheck actualSetpoint().												// if MINVspeed setting has changed update PIDloop
	//
		local function settrue														// store MINVspeed and activate Update
		{ 
			parameter check.
			actualVertSpPID(check).													// Update set point
			set MINVspeed to check.													// Set the MINoutput value
			set setpointcheck to true.												// Update true
		}
}
//
//               ===== input altitude keyboard =====
function InputAltKeyB
{
	// Mess with txt superposition if color TAG or other clear line
	print "                                                                                          "  at(0, StarRowDynamicValues + 4).
	// re-define the line
	print "    |  Alt Entry :                                  |" at(0, StarRowDynamicValues + 4).
	set inalt to terminal_input_number(18, 5, StarRowDynamicValues + 4).		  	// library function input number
	set inalt to inalt:tonumber().					 								// convert to number
	if inalt < 0 set inalt to 0.													// No negative altitude
	if inalt > 1000 set inalt to 1000.												// Max altitude
	set seekAlt to inalt.															// Update Selected altitude
	actualSetpoint().																// Update Pid loop
	// Same as starting line need to be cleaned
	print "                                                                                          "  at(0, StarRowDynamicValues + 4).
	print "    |  Alt Entry : [font4][#9ffeb050]" + "       {COLOR}[font0]" + "                          |" at(0, StarRowDynamicValues + 4).
}
//
// ===== Function for moving selected part in ship =====
// ---- Grouped parts Vtol mod STAB ON or OFF ----
function MovePart
{
	parameter state.																// Action or Event state 'Stop' or 'Move'
	// List of objects
	cherryLight[state]().
	aeroBreak[state]().
}
//
// ---- Grouped parts Landing Mod ----
function MoveLandingLight
{
	parameter state.																// Action or Event state 'Stop' or 'Move'
	// List of objects
	LandL[state]().
	CtrlLight[state]().
}
//
// ===================== D E L E G A T E Functions =================
// ---- function altitude mode rad or sealevel button 0 ----
function RadarMode																	// BUTTON 0
{
	parameter bool.																	// SWITCH
	
	if bool																			// Condition TRUE
	{
		label["setTXT"](0, "[hw][#00ff00ff] seaAlt ").								// Set label
		label["setSTA"](0, false).													// Set switch false
		button["dele"](0, RadarModeB:bind(label["getSTA"](0))).						// Actualise button delegate with switch state
		set seekAlt to Altisea.						  								// to keep altitude level
		lock curent_Alt to Altisea.					  								// curent altitude set to sea level
		actualSetpoint().															// Update PIDLOOPs
	} else																			// Condition FALSE
	{
		label["setTXT"](0, "[hw][#00ff00ff] radAlt ").								// Set label
		label["setSTA"](0, true).													// Set switch true
		button["dele"](0, RadarModeB:bind(label["getSTA"](0))).						// Actualise button delegate with switch state
		set seekAlt to AltiRad.						  								// to keep altitude level
		lock curent_Alt to AltiRad.					  								// curent altitude set to radar level
		actualSetpoint().															// Update PIDLOOPs
	}.
	playNoteF("d4", "r4").															// Action sound
}.
//
// ---- function exit & save parameter ----
function stop																		// BUTTON -2
{ 
	if vol:exists(FoldName + "/" + FullNameAircraft)								// If data file present update file
	{
		set TUcheck to false.
		writeJson(FileDatas, FullNameAircraft).										// Save file
	}
	sound2:play(musique()).							  								// for fun :) (testing)
	wait until not sound2:isplaying.
	set running to true.							  								// End Main hover boucle
}.
// ---- function MINthr increment ----
function FuncMINthr																	// BUTTON 7
{
	set MINthr to MINthr + DeltaMaxMthr.											// + or - increment (DeltaMaxMthr)
	if Minthr < 0 set MINthr to 0.                    								// not negative value.
	if MINthr > 1 set MINthr to 1.                	  								// max value 1 
	actualHoverPid().																// Update PIDLOOPS
	MinthFlash["FlashLFOne"]().														// Cosmetic
}.
//
// ---- function MAXthr increment ----
function FuncMAXthr																	// BUTTON 8
{
	set MAXthr to MAXthr + DeltaMaxMthr.											// + or - increment (DeltaMaxMthr)
	if MAXthr < 0 set MAXthr to 0.                	  								// not negative value
	if MAXthr > 1 set MAXthr to 1.					  								// max value 1
	actualHoverPid().																// Update PIDLOOPS
	MaxthFlash["FlashLFOne"]().														// Cosmetic
}.
//
// ---- function changing signe for deltamaxmin ----
function DeltaMaxMinOutput															// BUTTON 9
{
	parameter bool.																	// SWITCH
	
	if bool																			// Condition True
	{
		label["setSTA"](9, false).													// Set switch False
		set DeltaMaxMthr to 0.01.													// Increment positif
		label["setTXT"](9, "     [hw][#00ff00ff]+[#ffffffff]0.01").					// Update Label txt +
		button["dele"](9, DeltaMaxMinOutputB:bind(label["getSTA"](9))).				// Actualise button delegate with switch state
	} else																			// Condition False
	{
		label["setSTA"](9, true).													// Set switch True
		set DeltaMaxMthr to -0.01.													// Increment Negatif
		label["setTXT"](9, "     [hw][#00ff00ff]-[#ffffffff]0.01").					// Update Label txt -
		button["dele"](9, DeltaMaxMinOutputB:bind(label["getSTA"](9))).				// Actualise button delegate with switch state 
	}.
}.
//
// ---- Function control Vertical speed factor value in landing mode ----
function FactorVspUP																// BUTTON -3 (upButton)
{
	set FactorVspeedLand to FactorVspeedLand - 1.									// Decrease Factor (negative range)
	if FactorVspeedLand = -11 set FactorVspeedLand to -10.							// Minimun -10
}
function FactorVspDO																// BUTTON -4 (downButton)
{
	set FactorVspeedLand to FactorVspeedLand + 1.									// Increase Factor (negative range)
	if FactorVspeedLand = 0 set FactorVspeedLand to -1.								// Minimun -1
}
//
// ---- Function altitude management ----
function SeekAlBut10																// button 10
{
	set seekAlt to seekAlt + 10.													// update +10 for selected altitude
	if seekAlt > 1000 set seekAlt to 1000.											// Max altitude
	actualSetpoint().																// Update PIDLOOPS setpoint
	playNote("C3").																	// For fun
	SeekAl10Fl["FlashLFOne"]().														// Cosmetic display
}.
function SeekAlBut11																// button 11
{
	set seekAlt to seekAlt - DeltaseekAlt.											// Decrease (variable) for selected altitude
	if seekAlt < 0 set seekAlt to 0.												// No negative value for selected altitude
	actualSetpoint().																// Update PIDLOOPS setpoint
	playNote("E3").																	// For fun
	SeekAl11Fl["FlashLFOne"]().														// Cosmetic display
}.
function DeltaseekAlup																// button -6 (left)
{
	set DeltaseekAlt to DeltaseekAlt + 1.											// Increase 
	if DeltaseekAlt = 11 set DeltaseekAlt to 10.									// Max delta
	label["setTXT"](11, ("      [hw]Alt-" + DeltaseekAlt)).							// update Label
}.
function DeltaseekAldw																// button -5 (right)
{
	set DeltaseekAlt to DeltaseekAlt - 1.											// Decrease
	if DeltaseekAlt = 0 set DeltaseekAlt to 1.										// Min delta
	label["setTXT"](11, ("      [hw]Alt-" + DeltaseekAlt)).							// update label
}.
//
// =====================   Display Functions   ====================
// ---- main screen display static ----
function Main_Screen																// STATIC
{
	clearScreen. // delete the last setup screen
	print "   _________________________________________________" at(0,00).
	print "    |[#2110E7FF]                -- [font4]V T O L[font0] --{COLOR}                  |" at(0,01).
	print "    |  Set hover at :                                                        {COLOR}|" at(0,02).				// section altitude (starting Row)
	print "    |     ACTIVE radar :                                          |" at(0,03).								// Mode Radar Flash (Row +1)
	print "    |                                                        {COLOR}|" at(0,04).								// Passive Radar	(Row +2)
	print "    |  Vsp :                                                               		{COLOR}|" at(0,05).			// Verticale speed section (Row +3)	
	print "    |  Alt Entry : [font4][#9ffeb050]" + "       {COLOR}[font0]" + "                          |" at(0,06).	// Input location (Row +4)
	print "    |  Steering is free for now (next update)       |" at(0,07).
	print "    |                 [#E7D410FF]_________{COLOR}                     |" at(0,08).
	print "    |    -- PID setting for throttle control --     |" at(0,9).												// PidLoop section (Throttle)
	print "    |[#E7D410FF]  MINOUTPUT :                                             {COLOR}|" at(0,10).				// Min output (Row +8)
	print "    |[#E7D410FF]  MAXOUTPUT :                                             {COLOR}|" at(0,11).				// Max output (Row +9)
	print "    |                                               |" at(0,12).												// (Row +10)
	print "    |                                               |" at(0,13).												// (Row +11)	
	print "    |[#E7D410FF]                 _________{COLOR}                     |" at(0,14).
	print "    |  Throttle=                                                         	    {COLOR}|" at(0,15).			// show actual throttle value (Row +13)
	print "    |  VertSp Fac Lnd Mod :                         |" at(0,16).												// Show the factor (Row +14) 
	print "    |_______________________________________________|" at(0,17).												//for verticalspeed landing mod
	print "- [hw][font1][#06c2ac]" + NaAc + "[font0]{COLOR}" at(5,18). print "[#fac205]" + hoVers + "{COLOR} -" at (67,18). // cosmetic info
	//print "[hw][font1]VSpFacL Up +1" at(57,06).
	//print "[hw][font1]VSpFacL Do -1" at(57,07).	
}
//
// ---- Call to update the display of values Try to use in every Mod ----
function Aff_Values																	// DYNAMIC
{
	parameter startRow.																// Set initial row 															// define where the block of text should be positioned
	// Section altitude & current altitude (top)
	print "[#c1f80a]" + round(seekAlt, 1) + "m    " at (22, startRow).
	if (curent_Alt > (seekAlt - 5)) and (curent_Alt < (seekAlt + 5))				// Check if curent altitude is in range
	{																				// of desired altitude (show in green if true)
		print "{COLOR}Cur ALT =[#c1f80a] " + round(curent_Alt, 1) + "m   " at (40, startRow).	 
	} else print "{COLOR}Cur ALT =[#E50E53] " + round(curent_Alt, 1) + "m   " at (40, startRow).
	//---- show passive radar or sea level ----
	if label["getSTA"](0)															// mode radar
	{
		print "Sea Level : [#cdfd02]" + round(Altisea, 1) + "m   " at (13, startRow + 2).  		// no active altitude live update
	} else																			// mode alt
		{
			print "    Radar : [#cdfd02]" + round(AltiRad, 1) + "m   " at(13, startRow + 2).	// no active altitude LIve update
		}.
	// section Targetverticalspeed & current verticalSpeed
	print "TargSp:[#c1f80a] " + round(TargetVertSpeed, 2) + "    " at(13, startRow + 3).
	if (ship:verticalspeed > (TargetVertSpeed - 2)) and (ship:verticalspeed < (TargetVertSpeed + 2)) // Check if TargetSpeed is in range
	{																								 // of desired vertical speed (show in green if true)
		print "{COLOR}Vs:[#c1f80a] " + round(TargetVertSpeed, 2) + "    " at(35, startRow + 3).
	} else print "{COLOR}Vs:[#E50E53] " + round(TargetVertSpeed, 2) + "    " at(35, startRow + 3).
	// section Pidloop for MINoutput & MAXoutput Pid
    print "[#E50E53FF]" + round(MINthr, 2) + "   " at(28, startRow + 8).
    print "[#E50E53FF]" + round(MAXthr, 2) + "   " at(28, startRow + 9).
	// Throttle management & Show the TWR for engine used for script hover
	print "[#E50E53]" + round(CurentThrottle, 2) + "    " at (17 ,startRow + 13).
	print "{COLOR}TWR Vtol: [#33FF00]" + round(Total_TWR_Vtolengs,2) at(38, startRow + 13).	
	// Landing Factor Vertical speed
	print FactorVspeedLand + "   " at (28, startRow + 14).
}.
//
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
//
// =====================   SOUNDS MANAGEMENT   ====================
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
//
// ----            Buttons sounds			 ----
function playNote									  // short sound
{
	parameter a,									  // input letter note no frequency
			  dur is 0.05,
			  keyd is 0.2.
	// note(Frequency, Endfrequency or note, duration, keyDownlenght, volume)
	Sound1:play( note(a, dur, keyd)).
}
//
// ----           Fonctions sounds			 ----
function playNoteF									  // slide sound
{
	parameter a,									  // input start letter note no frequency
			  b,	
			  dur is 0.05,
			  keyd is 0.2.
	// note(Frequency, Endfrequency or note, duration, keyDownlenght, volume)
	Sound1:play( slideNote(a, b, dur, keyd)).
}
//
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
// =====================
// end SCRIPT file HOVER
// =====================