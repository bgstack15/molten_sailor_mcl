Molten Sailor for Mineclonia
========================
Boat for sailing on lava, and armor for diving in lava.

Adaptations of Minetest Game mod Boats, and Spacesuit mod by Thomas Rudin / Buckaroo Banzay
Adapted to Mineclonia by bgstack15.

See license.txt for license information.



Boat Controls
--------
Right mouse button = Enter or exit boat when pointing at boat.
Forward            = Speed up.
                     Slow down when moving backwards.
Forward + backward = Enable cruise mode: Boat will accelerate to maximum forward
                     speed and remain at that speed without needing to hold the
                     forward key.
Backward           = Slow down.
                     Speed up when moving backwards.
                     Disable cruise mode.
Left               = Turn to the left.
                     Turn to the right when moving backwards.
Right              = Turn to the right.
                     Turn to the left when moving backwards.

Changes required for Mineclonia 0.112.2
---------------------------------------
In order for this mod to work correctly, some changes need to be made in Mineclonia. As of version 0.112.2, these files need to be updated. See included file [include/mineclonia-0.112.2.patch](include/mineclonia-0.112.2.patch)

* mineclonia/mods/ENTITIES/mcl_burning/api.lua
* mineclonia/mods/CORE/mcl_damage/init.lua
