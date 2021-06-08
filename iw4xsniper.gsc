/*
			 _ __ ___ __  ____   _____ 
			| '_ ` _ \\ \/ /\ \ / / _ \
			| | | | | |>  <  \ V /  __/
			|_| |_| |_/_/\_\  \_/ \___|

 _          _  _                   _                 
(_)_      _| || |__  __  ___ _ __ (_)_ __   ___ _ __ 
| \ \ /\ / / || |\ \/ / / __| '_ \| | '_ \ / _ \ '__|
| |\ V  V /|__   _>  <  \__ \ | | | | |_) |  __/ |   
|_| \_/\_/    |_|/_/\_\ |___/_| |_|_| .__/ \___|_|   
                                    |_|              

Based on Sunbae's iw4xSniper
https://github.com/eztso/iw4xSniper
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level thread onPlayerConnect();
	level thread serverHUD();
}

onPlayerConnect()
{
	while (true)
	{
		level waittill("connected", player);		

		if(!isDefined(player.message_shown))
		{
			player.message_shown = 0;
		}

		if(!isDefined(player.cur_bright))
		{
			player.cur_bright = 0;
		}

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	
	while (true)
	{
		self waittill("spawned_player");

		self thread doDvars();
		self thread giveAmmo();
	}
}

doDvars()
{	
	// Disable melee
	setDvar("player_meleeRange", 0); 

	// Replace not allowed weapons etc during class selection grace period, 5*3.5=17.5
	for (count=0;count<15;count++)
	{

		// Remove nades
		self takeWeapon("frag_grenade_mp");
		self takeWeapon("semtex_mp");
		self takeWeapon("specialty_tacticalinsertion");
		self takeWeapon("specialty_blastshield");
		self takeWeapon("claymore_mp");
		self takeWeapon("c4_mp");
		self takeWeapon("flash_grenade_mp");
		self takeWeapon("concussion_grenade_mp");
		self takeWeapon("smoke_grenade_mp");


		weapon = self getCurrentWeapon();

		// Check for weapon attachments and allowed weapons
		if (	
				weapon!= self.secondaryWeapon &&
		   		(
					isSubStr(weapon,"thermal") ||
		   			isSubStr(weapon,"heartbeat") ||
					isSubStr(weapon,"acog") ||
					isSubStr(weapon,"silencer") ||
					isSubStr(weapon,"riotshield") ||
					!(
						isSubStr(weapon,"cheytac") ||
						isSubStr(weapon,"l96a1") ||
						isSubStr(weapon,"dsr") ||
						isSubStr(weapon,"msr") ||
						isSubStr(weapon,"l118a") ||
						isSubStr(weapon,"awp") ||
						isSubStr(weapon,"ballista") ||
						isSubStr(weapon,"m40a3") ||
						isSubStr(weapon,"throwingknife")
					)
				)
			)
		{
			self takeWeapon(weapon);
			self giveWeapon("cheytac_mp");

			wait(.1);
			self switchToWeapon("cheytac_mp");

			self maps\mp\perks\_perks::givePerk("specialty_fastreload");
			self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
		}

		if (isSubstr(self.secondaryWeapon, "akimbo"))
		{
			self setWeaponAmmoClip(self.secondaryWeapon, 0, "left");
			self setWeaponAmmoClip(self.secondaryWeapon, 0, "right");
		} else {
			self setWeaponAmmoClip(self.secondaryWeapon, 0);
		}

		self setWeaponAmmoStock(self.secondaryWeapon, 0);

		wait(3);
	}
}

giveAmmo()
{
	while (true)
	{
		self waittill("weapon_fired");
		ammoWeapon=self getCurrentWeapon();

		if (ammoWeapon != self.secondaryWeapon)
		{
			self giveMaxAmmo(ammoWeapon);
		}
	}
}

serverHUD()
{
	info = level createServerFontString("objective", 0.95);
	info setPoint("CENTER", "BOTTOM", 0, -10);
	info.glowalpha = .6;
	info.glowcolor = ( 0, 1, 0 );
	info setText("mxve");
	info.hideWhenInMenu = true;

	while (true)
	{
		info.glowcolor = ( .7, .3, 1 );
		info setText("mxve's Sniper Rotation");
		wait 20;
		info.glowcolor = ( 0, 1, 0 );
		info setText("iw4x.mxve.de");
		wait 14;
		info.glowcolor = ( 1, 0, 0 );
		info setText("github.com/mxve/iw4x-sniper");
		wait 8;
	}
}