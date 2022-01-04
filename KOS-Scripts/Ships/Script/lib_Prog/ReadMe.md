**Hover.ks** (*V5.0*)

 *Need standard library* **KSLib** *To function properly*
 *Need* **lib_KpmAddons.ks**, **lib_FlashString.ks**, **lib_MovePart.ks** *scripts.*
 
- **lib_MovePart.ks** script *in Hover.ks code for KSP french patch*

```Python
set CherryLight to MovPartOBJ("HoverLight", "ModuleLight", "activer l'éclairage").
set AeroBreak to MovPartOBJ("KosAerofrein","ModuleAeroSurface", "activer").
set LandL to MovPartOBJ("LandL", "ModuleLight", "activer l'éclairage").
set CtrlLight to MovPartOBJ("CtrlLandL", "ModuleRoboticController", "Activer la lecture").
```
- MovPartOBJ("*is KOSTAG*", "*is Part Module*", "*is Event or Action name*"

  - **CherryLIght** *object Control KOSCherryLight kos part* 

  - **AeroBreak** *object Control KSP Airbrake part*

  - **LandL** *object Control KSP light for landing purpose*

  - **CtrlLight** *object Control KSP KAL1000 part controller anim*

> The Constructor **MovPartOBJ()** thus controls all shares using the specified KOSTAG for an object

> EX : aeroBreak["move"]\().  -> activate all part with "KosAerofrrein" name.

**this script is a Beta version** 

_____
> To Do list
- ☑️ Control Altitude level
- ☑️ Landing Mod
- ☑️ using MFD buttons and labels
- ⬛ learning about Serialization to update my saving variable
- ⬛ Try to use the Ziegler-Nichols method (wiki) to apply methode no overshot WIP bugged 
- ⬛ Stopped and stabilized the aircraft in flight and maintain a position (Currently only the attitude of the ship is controlled)
- ☑️ Save variables in a file for a type of aircraft (Remember parameters for this type of aircraft)
