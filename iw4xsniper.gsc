/*
 *		 _ __ ___ __  ____   _____ 
 *		| '_ ` _ \\ \/ /\ \ / / _ \
 *		| | | | | |>  <  \ V /  __/
 *		|_| |_| |_/_/\_\  \_/ \___|
 *	
 *	 _          _  _                   _                 
 *	(_)_      _| || |__  __  ___ _ __ (_)_ __   ___ _ __ 
 *	| \ \ /\ / / || |\ \/ / / __| '_ \| | '_ \ / _ \ '__|
 *	| |\ V  V /|__   _>  <  \__ \ | | | | |_) |  __/ |   
 *	|_| \_/\_/    |_|/_/\_\ |___/_| |_|_| .__/ \___|_|   
 *	                                    |_|              
 *
 *	Based on Sunbae's iw4xSniper
 *	https://github.com/eztso/iw4xSniper
 *
 */

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
 *	init()
 *		Script entry point
 */
init()
{
	level thread onPlayerConnect();
	level thread hudLoop();
}

/*
 *	onPlayerConnect()
 *
 *		Main Thread that starts a thread for each player once they are connected
 */
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

/*
 *	onPlayerSpawned()
 *
 *		Player thread started by onPlayerConnect
 *		Alive until player disconnects
 */
onPlayerSpawned()
{
	self endon("disconnect");
	
	while (true)
	{
		self waittill("spawned_player");

		self thread applyGameMode();
		self thread ammoLoop();
	}
}

/*
 *	restrictWeapons()
 *
 *		Restrict weapons and offhand, replace if disallowed encountered
 */
restrictWeapons()
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
			weapon != self.secondaryWeapon &&
		   	(
				isSubStr(weapon, "thermal") ||
		   		isSubStr(weapon, "heartbeat") ||
				isSubStr(weapon, "acog") ||
				isSubStr(weapon, "silencer") ||
				isSubStr(weapon, "riotshield") ||
				!(
					isSubStr(weapon, "cheytac") ||
					isSubStr(weapon, "m40a3") ||
					isSubStr(weapon, "throwingknife")
				)
			)
		)
	{
		self takeWeapon(weapon);
		self giveWeapon("cheytac_mp");

		// wait .1 second as switchToWeapon doesn't seem to work when called directly after giveWeapon
		wait(.1);
		self switchToWeapon("cheytac_mp");

		// Give Sleight of Hand Pro
		self maps\mp\perks\_perks::givePerk("specialty_fastreload");
		self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
	}
}

/*
 *	takeAmmo(slot)
 *		slot (string):
 *			primary
 *			secondary
 */
takeAmmo(slot)
{
	if (slot == "primary")
	{
		self setWeaponAmmoClip(self.primaryWeapon, 0);
		self setWeaponAmmoStock(self.primaryWeapon, 0);
	}
	else if (slot == "secondary")
	{
		// Check for akimbo and take ammo of both akimbo weapons if encountered
		if (isSubstr(self.secondaryWeapon, "akimbo"))
		{
			self setWeaponAmmoClip(self.secondaryWeapon, 0, "left");
			self setWeaponAmmoClip(self.secondaryWeapon, 0, "right");
		} else {
			self setWeaponAmmoClip(self.secondaryWeapon, 0);
		}

		self setWeaponAmmoStock(self.secondaryWeapon, 0);
	}

}

/*
 *	dvars()
 *
 *		Set required dvars
 */
dvars()
{
	/*
	 *	Disable melee
	 *		WONTFIX:
	 *			Can't break windows with knife
	 *				Fixing this would require hooking into the damage function and
	 *				settings damage on player hit to 0 for the knife
	 */
	setDvar("player_meleeRange", 0);

	/*
	 *	/weather clear
	 *	r_fog
	 *		removes main dust on rust
	 *	fx_enable
	 *		removes particles etc
	 *		also fixed black boxes with fullbright on mp_nuked
	 *		additonally this seems to change the kill points color to gray?
	 */ 
	self setClientDvar("r_fog", 0);
	self setClientDvar("fx_enable", 0);
}

/*
 *	applyGameMode()
 *
 *		Apply game mode on player spawn
 *		Restrict weapons during class selection grace period
 */
applyGameMode()
{	
	self dvars();

	for (count=0;count<15;count++)
	{
		self restrictWeapons();
		self takeAmmo("secondary");

		wait(3);
	}
}

/*
 *	ammoLoop()
 *
 *		Restock ammo on shot fired
 *			Excluding secondary weapon
 */
ammoLoop()
{
	while (true)
	{
		self waittill("weapon_fired");
		ammoWeapon = self getCurrentWeapon();

		if (ammoWeapon != self.secondaryWeapon)
		{
			self giveMaxAmmo(ammoWeapon);
		}
	}
}

/*
 *	hudLoop()
 *
 *		Draw watermark and cycle text
 */
hudLoop()
{
	info = level createServerFontString("objective", 0.95);
	info setPoint("CENTER", "BOTTOM", 0, -10);
	info.glowalpha = .6;
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