### --- Start.ks ---
> Need my library script

*starting script, running when plane is loaded on scene*
*take a look [here](http://ksp-kos.github.io/KOS_DOC/general/boot.html)*

 _____
 
 ### --- Issues ---
 
 When the ship and loaded, I use this :
 ```javascript
 wait until ship:unpacked.
 ```
 *But sometimes the objects created by KPM:ADDONS are not initialized at the start, I do not know why, to correct the problem I raise the start script with the button of the mfd.
 I'm not sure that **ship:unpacked** works or so it's another problem !
 I added a delay after this line*
```javascript
wait 1.5.
```
*I test right now maybe when increasing this delay the problem be solved*

