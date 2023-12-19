/*
UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Joël Moffatt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
//-----------------------------------------------------------
//   UTComp Version Src by Aaron 'Lotus' Everitt
//
//   Main Mutator class
//   Last Edited(or, rather, last edited and i bothered to update this)
//    - Mar 15, 2005
//-----------------------------------------------------------

class TAM_Mutator extends DMMutator
    HideDropDown
    CacheExempt;

#exec OBJ LOAD FILE=Textures\3SPNTex.utx PACKAGE=3SPNvSoL

/* weapons */
struct WeaponData
{
    var string WeaponName;
    var int Ammo[2];                        // 0 = primary ammo, 1 = alt ammo
    var float MaxAmmo[2];                   // 1 is only used for WeaponDefaults
};
var WeaponData  WeaponInfo[10];
var WeaponData  WeaponDefaults[10];
/* weapons */
	
/* newnet */
var bool EnableNewNet;
var NewNet_PawnCollisionCopy PCC;
var NewNet_TimeStamp StampInfo;
var float AverDT;
var float ClientTimeStamp;
var array<float> DeltaHistory;
var NewNet_FakeProjectileManager FPM;
const AVERDT_SEND_PERIOD = 4.00;
var float LastReplicatedAverDT;
var class<Weapon> WeaponClasses[10];
var class<weapon> NewNetWeaponClasses[10];
var string NewNetWeaponNames[10];
/* newnet */

replication
{
	reliable if(bNetInitial && Role == ROLE_Authority)
		EnableNewNet;
}
	
/*function PreBeginPlay()
{		
    StaticSaveConfig();
    super.PreBeginPlay();
}*/

/*function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(EnableNewNet)
	{
		for(M=Level.Game.BaseMutator; M!=None; M=M.NextMutator)
		{
			if(string(M.Class)~="SpawnGrenades.MutSN")
				return;
		}
		class'GrenadeAmmo'.default.InitialAmount = NumGrenadesOnSpawn;
	}
}*/

static function bool IsPredicted(actor A)
{
   if(A == none || A.IsA('xPawn'))
       return true;
   //Fix up vehicle a bit, we still wanna predict if its in the list w/o a driver
   if((A.IsA('Vehicle') && Vehicle(A).Driver!=None))
       return true;
   return false;
}

function ModifyPlayer(Pawn Other)
{
	if(EnableNewNet)
	{
		SpawnCollisionCopy(Other);
		RemoveOldPawns();
	}
	
    Super.ModifyPlayer(Other);
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
	if(EnableNewNet)
		SpawnCollisionCopy(V);

    if( NextMutator != none )
		NextMutator.DriverEnteredVehicle(V, P);
}

function SpawnCollisionCopy(Pawn Other)
{
    if(PCC==None)
    {
        PCC = Spawn(Class'NewNet_PawnCollisionCopy');
        PCC.SetPawn(Other);
    }
    else
	{
        PCC.AddPawnToList(Other);
	}
}

function RemoveOldPawns()
{
    PCC = PCC.RemoveOldPawns();
}
	
simulated function Tick(float DeltaTime)
{
	if(Level.Pauser!=None)
	{	
		if(Level.NetMode==NM_DedicatedServer)
			Team_GameBase(Level.Game).UpdateTimeOut(DeltaTime);
		return;
	}

	if(!EnableNewNet)
		return;
		
    if(Level.NetMode==NM_DedicatedServer)
    {
		if(StampInfo == none)
		   StampInfo = Spawn(Class'NewNet_TimeStamp');
	
		ClientTimeStamp+=DeltaTime;
		AverDT = (9.0*AverDT + DeltaTime) / 10.0;
		StampInfo.ReplicatetimeStamp(ClientTimeStamp);
		if(ClientTimeStamp > LastReplicatedAverDT + AVERDT_SEND_PERIOD)
		{
			StampInfo.ReplicatedAverDT(AverDT);
			LastReplicatedAverDT = ClientTimeStamp;
		}
        return;
    }
	
	if(Level.NetMode==NM_Client)
	{
		if(FPM==None)
			FPM = Spawn(Class'NewNet_FakeProjectileManager');
	}
}

function InitWeapons(int AssaultAmmo,int AssaultGrenades,int BioAmmo,int ShockAmmo,int LinkAmmo,int MiniAmmo,int FlakAmmo,int RocketAmmo,int LightningAmmo, int ClassicSniperAmmo)
{
    local int i;
    local class<Weapon> WeaponClass;

    for(i = 0; i < ArrayCount(WeaponInfo); i++)
    {
        if(WeaponInfo[i].WeaponName ~= "")
            continue;

        if(WeaponInfo[i].WeaponName ~= "xWeapons.AssaultRifle")
        {
            WeaponInfo[i].Ammo[0] = AssaultAmmo;
            WeaponInfo[i].Ammo[1] = AssaultGrenades;
        }
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.BioRifle")
				WeaponInfo[i].Ammo[0] = BioAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.ShockRifle")
            WeaponInfo[i].Ammo[0] = ShockAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.LinkGun")
            WeaponInfo[i].Ammo[0] = LinkAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.MiniGun")
            WeaponInfo[i].Ammo[0] = MiniAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.FlakCannon")
            WeaponInfo[i].Ammo[0] = FlakAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.RocketLauncher")
            WeaponInfo[i].Ammo[0] = RocketAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.SniperRifle")
            WeaponInfo[i].Ammo[0] = LightningAmmo;
       else if(WeaponInfo[i].WeaponName ~= "UTClassic.ClassicSniperRifle")
            WeaponInfo[i].Ammo[0] = ClassicSniperAmmo;			
			
        WeaponClass = class<Weapon>(DynamicLoadObject(WeaponInfo[i].WeaponName, class'Class'));

        if(WeaponClass == None)
        {
            log("Could not find weapon:"@WeaponInfo[i].WeaponName, '3SPN');
            continue;
        }

        // remember defaults
        WeaponDefaults[i].WeaponName = WeaponInfo[i].WeaponName;

        if(class<Translauncher>(WeaponClass) != None && WeaponInfo[i].Ammo[0] > 0)
        {
            WeaponDefaults[i].MaxAmmo[0] = Class'XWeapons.Translauncher'.default.AmmoChargeRate;
            WeaponDefaults[i].MaxAmmo[1] = Class'XWeapons.Translauncher'.default.AmmoChargeF;
            WeaponDefaults[i].Ammo[0] = Class'XWeapons.Translauncher'.default.AmmoChargeMax;
            class'XWeapons.Translauncher'.default.AmmoChargeRate = 0.000000; 
		    class'XWeapons.Translauncher'.default.AmmoChargeMax = WeaponInfo[i].Ammo[0];
		    class'XWeapons.Translauncher'.default.AmmoChargeF = WeaponInfo[i].Ammo[0];
        }
		else if(class<ShieldGun>(WeaponClass) != None)
        {
        }
        else
		{
			if(WeaponClass.default.FireModeClass[0].default.AmmoClass != None)
			{
				WeaponDefaults[i].Ammo[0] = WeaponClass.default.FireModeClass[0].default.AmmoClass.default.InitialAmount;
				WeaponDefaults[i].MaxAmmo[0] = WeaponClass.default.FireModeClass[0].default.AmmoClass.default.MaxAmmo;
				WeaponClass.default.FireModeClass[0].default.AmmoClass.default.InitialAmount = Min(999, WeaponInfo[i].Ammo[0]);
				WeaponClass.default.FireModeClass[0].default.AmmoClass.default.MaxAmmo = Min(999, WeaponInfo[i].Ammo[0] * WeaponInfo[i].MaxAmmo[0]);
			}

			if(WeaponClass.default.FireModeClass[1].default.AmmoClass != None && (WeaponClass.default.FireModeClass[0].default.AmmoClass != WeaponClass.default.FireModeClass[1].default.AmmoClass))
			{
				WeaponDefaults[i].Ammo[1] = WeaponClass.default.FireModeClass[1].default.AmmoClass.default.InitialAmount;
				WeaponDefaults[i].MaxAmmo[1] = WeaponClass.default.FireModeClass[1].default.AmmoClass.default.MaxAmmo;
				WeaponClass.default.FireModeClass[1].default.AmmoClass.default.InitialAmount = Min(999, WeaponInfo[i].Ammo[1]);
				WeaponClass.default.FireModeClass[1].default.AmmoClass.default.MaxAmmo = Min(999, WeaponInfo[i].Ammo[1] * WeaponInfo[i].MaxAmmo[0]);
			}
		}
		
		class'Freon_Pawn'.default.RequiredEquipment[i + 1] = WeaponInfo[i].WeaponName;
		class'Misc_Pawn'.default.RequiredEquipment[i + 1] = WeaponInfo[i].WeaponName;
    }
	
	class'ShieldFire'.Default.DamageType = Class'DamType_ShieldImpact';
    class'WeaponFire_Shield'.Default.DamageType = Class'DamType_ShieldImpact';
	class'AssaultFire'.Default.DamageType = Class'DamType_AssaultBullet';
    class'Grenade'.Default.MyDamageType = class'DamType_AssaultGrenade';
    class'BioGlob'.default.MyDamageType = class'DamType_BioGlob';
	class'LinkFire'.Default.DamageType = Class'DamType_LinkShaft';
    class'LinkProjectile'.Default.MyDamageType = Class'DamType_LinkPlasma';
    class'MinigunFire'.Default.DamageType = Class'DamType_MinigunBullet';
    class'MinigunAltFire'.Default.DamageType = Class'DamType_MinigunAlt';
    class'FlakChunk'.default.MyDamageType = class'DamType_FlakChunk';
    class'FlakShell'.default.MyDamageType = class'DamType_FlakShell';
	class'RocketProj'.default.MyDamageType = class'DamType_Rocket';
	class'SeekingRocketProj'.default.MyDamageType = class'DamType_RocketHoming';
	//class'ShieldGun'.Default.DamageType = Class'DamType_ShieldImpact';

	if(EnableNewNet)
	{
        class'NewNet_AssaultFire'.Default.DamageType = Class'DamType_AssaultBullet';
        class'Grenade'.Default.MyDamageType = class'DamType_AssaultGrenade';
        class'ShieldFire'.Default.DamageType = Class'DamType_ShieldImpact';
        class'WeaponFire_Shield'.Default.DamageType = Class'DamType_ShieldImpact';
		class'NewNet_BioGlob'.default.MyDamageType = class'DamType_BioGlob';
        class'NewNet_ShockBeamFire'.Default.DamageType = class'DamType_ShockBeam';
        class'NewNet_ShockProjectile'.Default.MyDamageType = class'DamType_ShockBall';
        class'NewNet_ShockProjectile'.Default.ComboDamageType = class'DamType_ShockBeam';
		class'NewNet_LinkFire'.Default.DamageType = Class'DamType_LinkShaft';
		class'NewNet_LinkProjectile'.Default.MyDamageType = Class'DamType_LinkPlasma';
		class'NewNet_MiniGunFire'.Default.DamageType = Class'DamType_MinigunBullet';
		class'NewNet_MiniGunAltFire'.Default.DamageType = Class'DamType_MinigunAlt';
		class'NewNet_FlakChunk'.default.MyDamageType = class'DamType_FlakChunk';
		class'NewNet_FlakShell'.default.MyDamageType = class'DamType_FlakShell';
		class'NewNet_RocketProj'.default.MyDamageType = class'DamType_Rocket';
		class'NewNet_SeekingRocketProj'.default.MyDamageType = class'DamType_RocketHoming';
		class'NewNet_SniperFire'.default.DamageType = class'DamType_SniperShot';
		class'NewNet_SniperFire'.default.DamageTypeHeadshot = class'DamType_HeadShot';
		class'NewNet_ClassicSniperFire'.default.DamageType = class'DamType_ClassicSniperShot';
		class'NewNet_ClassicSniperFire'.default.DamageTypeHeadShot = class'DamType_ClassicHeadShot';

		
		
        class'DamType_ShieldImpact'.default.WeaponClass = class'NewNet_ShieldGun';
		class'DamType_AssaultBullet'.default.WeaponClass = class'NewNet_AssaultRifle';
		class'DamType_AssaultGrenade'.default.WeaponClass = class'NewNet_AssaultRifle';
		//class'DamTypeAssaultGrenade'.default.WeaponClass = class'DamType_AssaultGrenade';
		class'DamType_BioGlob'.default.WeaponClass = class'NewNet_BioRifle';
		class'DamType_ShockBall'.default.WeaponClass = class'NewNet_ShockRifle';
		class'DamType_ShockBeam'.default.WeaponClass = class'NewNet_ShockRifle';
		class'DamType_ShockCombo'.default.WeaponClass = class'NewNet_ShockRifle';
		class'DamType_LinkShaft'.default.WeaponClass = class'NewNet_LinkGun';
		class'DamType_LinkPlasma'.default.WeaponClass = class'NewNet_LinkGun';
		class'DamType_MinigunAlt'.default.WeaponClass = class'NewNet_MiniGun';
		class'DamType_MinigunBullet'.default.WeaponClass = class'NewNet_MiniGun';
		class'DamType_FlakChunk'.default.WeaponClass = class'NewNet_FlakCannon';
		class'DamType_FlakShell'.default.WeaponClass = class'NewNet_FlakCannon';
		class'DamType_Rocket'.default.WeaponClass = class'NewNet_RocketLauncher';
		class'DamType_RocketHoming'.default.WeaponClass = class'NewNet_RocketLauncher';
		class'DamType_SniperShot'.default.WeaponClass = class'NewNet_SniperRifle';
		class'DamType_HeadShot'.default.WeaponClass = class'NewNet_SniperRifle';
		class'DamType_ClassicSniperShot'.default.WeaponClass = class'NewNet_ClassicSniperRifle';
		class'DamType_ClassicHeadshot'.default.WeaponClass = class'NewNet_ClassicSniperRifle';
	}

    //snarf setup old weapons, these are used when newnet=false
    class'FlakFire'.default.ProjectileClass = class'TeamColorFlakChunk';
    class'FlakAltFire'.default.ProjectileClass = class'TeamColorFlakShell';
    class'ShockProjFire'.default.ProjectileClass = class'TeamColorShockProjectile';
}
	
function ResetWeaponsToDefaults(bool bModifyShieldGun,float ShieldGunSelfForceScale,float ShieldGunSelfDamageScale,int ShieldGunMinSelfDamage)
{
    local int i;
    local class<Weapon> WeaponClass;

    for(i = 0; i < ArrayCount(WeaponDefaults); i++)
    {
        if(WeaponDefaults[i].WeaponName ~= "")
            continue;

        WeaponClass = class<Weapon>(DynamicLoadObject(WeaponDefaults[i].WeaponName, class'Class'));

        if(WeaponClass == None)
            continue;

        // reset defaults
        if(class<Translauncher>(WeaponClass) != None && WeaponDefaults[i].Ammo[0] > 0)
        {
            Class'XWeapons.Translauncher'.default.AmmoChargeRate = WeaponDefaults[i].MaxAmmo[0]; 
		    Class'XWeapons.Translauncher'.default.AmmoChargeMax = WeaponDefaults[i].Ammo[0];
		    Class'XWeapons.Translauncher'.default.AmmoChargeF = WeaponDefaults[i].MaxAmmo[1];
            continue;
        }

		if(class<ShieldGun>(WeaponClass) != None)
            continue;
        
        if(WeaponClass.default.FireModeClass[0].default.AmmoClass != None)
        {
            WeaponClass.default.FireModeClass[0].default.AmmoClass.default.InitialAmount = WeaponDefaults[i].Ammo[0];
            WeaponClass.default.FireModeClass[0].default.AmmoClass.default.MaxAmmo = WeaponDefaults[i].MaxAmmo[0];
        }

        if(WeaponClass.default.FireModeClass[1].default.AmmoClass != None && (WeaponClass.default.FireModeClass[0].default.AmmoClass != WeaponClass.default.FireModeClass[1].default.AmmoClass))
        {
            WeaponClass.default.FireModeClass[1].default.AmmoClass.default.InitialAmount = WeaponDefaults[i].Ammo[1];
            WeaponClass.default.FireModeClass[1].default.AmmoClass.default.MaxAmmo = WeaponDefaults[i].MaxAmmo[1];
        }
    }

    if(bModifyShieldGun)
	{
		Class'XWeapons.ShieldFire'.default.SelfForceScale = ShieldGunSelfForceScale;
		Class'XWeapons.ShieldFire'.default.SelfDamageScale = ShieldGunSelfDamageScale;
		Class'XWeapons.ShieldFire'.default.MinSelfDamage = ShieldGunMinSelfDamage;
        
        class'WeaponFire_Shield'.default.SelfForceScale = ShieldGunSelfForceScale;
        class'WeaponFire_Shield'.default.SelfDamageScale = ShieldGunSelfDamageScale;
        class'WeaponFire_Shield'.default.MinSelfDamage = ShieldGunMinSelfDamage;
	}

    class'FlakChunk'.default.MyDamageType = class'DamTypeFlakChunk';
    class'FlakShell'.default.MyDamageType = class'DamTypeFlakShell';
    class'BioGlob'.default.MyDamageType = class'DamTypeBioGlob';
	class'RocketProj'.default.MyDamageType = class'DamTypeRocket';
	class'SeekingRocketProj'.default.MyDamageType = class'DamTypeRocketHoming';

	// newnet
	if(EnableNewNet)
	{
		class'GrenadeAmmo'.default.InitialAmount = 4;
        class'xWeapons.ShieldGun'.default.FireModeClass[0] = class'xWeapons.ShieldFire';
        class'xWeapons.ShieldGun'.default.FireModeClass[1] = class'xWeapons.ShieldAltFire';
		class'xWeapons.AssaultRifle'.default.FireModeClass[0] = Class'xWeapons.AssaultFire';
		class'xWeapons.AssaultRifle'.default.FireModeClass[1] = Class'xWeapons.AssaultGrenade';
		class'xWeapons.BioRifle'.default.FireModeClass[0] = Class'xWeapons.BioFire';
		class'xWeapons.BioRifle'.default.FireModeClass[1] = Class'xWeapons.BioChargedFire';
		class'xWeapons.ShockRifle'.default.FireModeClass[0] = Class'xWeapons.ShockBeamFire';
		class'xWeapons.ShockRifle'.default.FireModeClass[1] = Class'xWeapons.ShockProjFire';
		class'xWeapons.LinkGun'.default.FireModeClass[0] = Class'xWeapons.LinkAltFire';
		class'xWeapons.LinkGun'.default.FireModeClass[1] = Class'xWeapons.LinkFire';
		class'xWeapons.MiniGun'.default.FireModeClass[0] = Class'xWeapons.MinigunFire';
		class'xWeapons.MiniGun'.default.FireModeClass[1] = Class'xWeapons.MinigunAltFire';
		class'xWeapons.FlakCannon'.default.FireModeClass[0] = Class'xWeapons.FlakFire';
		class'xWeapons.FlakCannon'.default.FireModeClass[1] = Class'xWeapons.FlakAltFire';
		class'xWeapons.RocketLauncher'.default.FireModeClass[0] = Class'xWeapons.RocketFire';
		class'xWeapons.RocketLauncher'.default.FireModeClass[1] = Class'xWeapons.RocketMultiFire';
		class'xWeapons.SniperRifle'.default.FireModeClass[0]= Class'xWeapons.SniperFire';
		class'UTClassic.ClassicSniperRifle'.default.FireModeClass[0]= Class'Weaponfire_ClassicSniper';
		class'xWeapons.SuperShockRifle'.default.FireModeClass[0]=class'xWeapons.SuperShockBeamFire';
		class'xWeapons.SuperShockRifle'.default.FireModeClass[1]=class'xWeapons.SuperShockBeamFire';
		
        class'DamTypeShieldImpact'.default.WeaponClass = class'xWeapons.ShieldGun';
		class'DamTypeAssaultBullet'.default.WeaponClass = class'xWeapons.AssaultRifle';
		class'DamTypeAssaultGrenade'.default.WeaponClass = class'xWeapons.AssaultRifle';
		class'DamType_BioGlob'.default.WeaponClass = class'xWeapons.BioRifle';
		class'DamType_FlakChunk'.default.WeaponClass = class'xWeapons.FlakCannon';
		class'DamType_FlakShell'.default.WeaponClass = class'xWeapons.FlakCannon';
		class'DamType_LinkPlasma'.default.WeaponClass = class'xWeapons.LinkGun';
		class'DamType_LinkShaft'.default.WeaponClass = class'xWeapons.LinkGun';
		class'DamTypeMinigunAlt'.default.WeaponClass = class'xWeapons.MiniGun';
		class'DamTypeMinigunBullet'.default.WeaponClass = class'xWeapons.MiniGun';
		class'DamType_Rocket'.default.WeaponClass = class'xWeapons.RocketLauncher';
		class'DamType_RocketHoming'.default.WeaponClass = class'xWeapons.RocketLauncher';
		class'DamTypeShockBall'.default.WeaponClass = class'xWeapons.ShockRifle';
		class'DamTypeShockBeam'.default.WeaponClass = class'xWeapons.ShockRifle';
		class'DamType_ShockCombo'.default.WeaponClass = class'xWeapons.ShockRifle';
		class'DamTypeSniperHeadShot'.default.WeaponClass = class'xWeapons.SniperRifle';
		class'DamTypeSniperShot'.default.WeaponClass = class'xWeapons.SniperRifle';
		class'DamType_ClassicSniperShot'.default.WeaponClass = class'NewNet_ClassicSniperRifle';	
		class'DamType_ClassicHeadshot'.default.WeaponClass = class'NewNet_ClassicSniperRifle';	
    }

    //snarf restore old weapons
    class'FlakFire'.default.ProjectileClass = class'XWeapons.FlakChunk';
    class'FlakAltFire'.default.ProjectileClass = class'XWeapons.FlakShell';
    class'ShockProjFire'.default.ProjectileClass = class'XWeapons.ShockProjectile';

}
	
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local LinkedReplicationInfo lPRI;
    local int x, i;
	local WeaponLocker L;

    bSuperRelevant = 0;

	if(EnableNewNet)
	{
		if (xWeaponBase(Other) != None)
		{
			for (x = 0; x < ArrayCount(WeaponClasses); x++)
				if (xWeaponBase(Other).WeaponType == WeaponClasses[x])
					xWeaponBase(Other).WeaponType = NewNetWeaponClasses[x];
			return true;
		}
		else if (WeaponLocker(Other) != None)
		{
			L = WeaponLocker(Other);
			for (x = 0; x < ArrayCount(WeaponClasses); x++)
				for (i = 0; i < L.Weapons.Length; i++)
					if (L.Weapons[i].WeaponClass == WeaponClasses[x])
						L.Weapons[i].WeaponClass = NewNetWeaponClasses[x];
			return true;
		}
		
		if (PlayerReplicationInfo(Other)!=None)
		{
			if(PlayerReplicationInfo(Other).CustomReplicationInfo!=None)
			{
				lPRI=PlayerReplicationInfo(Other).CustomReplicationInfo;
				while(lPRI.NextReplicationInfo!=None)
				{
					 lPRI=lPRI.NextReplicationInfo;
				}
				lPRI.NextReplicationInfo = Spawn(Class'NewNet_PRI', Other.Owner);
			}
			else
			{
				PlayerReplicationInfo(Other).CustomReplicationInfo = Spawn(Class'NewNet_PRI', Other.Owner);
			}
			return true;
		}
	}
	else
	{
		if(Other.IsA('Weapon'))
		{
            if(Other.IsA('ShieldGun'))
            {
                ShieldGun(Other).FireModeClass[0] = class'WeaponFire_Shield';
            }
			else if(Other.IsA('AssaultRifle'))
			{
				AssaultRifle(Other).FireModeClass[0] = class'WeaponFire_Assault';
				AssaultRifle(Other).FireModeClass[1] = class'WeaponFire_AssaultAlt';
			}
			else if(Other.IsA('BioRifle'))
			{
				BioRifle(Other).FireModeClass[0] = class'WeaponFire_Bio';
				BioRifle(Other).FireModeClass[1] = class'WeaponFire_BioAlt';
			}
			else if(Other.IsA('ShockRifle') && !Other.IsA('SuperShockRifle'))
			{
				ShockRifle(Other).FireModeClass[0] = class'WeaponFire_Shock';
				ShockRifle(Other).FireModeClass[1] = class'WeaponFire_ShockAlt';
			}
			else if(Other.IsA('LinkGun'))
			{
				LinkGun(Other).FireModeClass[0] = class'WeaponFire_LinkAlt';
				LinkGun(Other).FireModeClass[1] = class'WeaponFire_Link';
			}
			else if(Other.IsA('Minigun'))
			{
				MiniGun(Other).FireModeClass[0] = class'WeaponFire_Mini';
				MiniGun(Other).FireModeClass[1] = class'WeaponFire_MiniAlt';
			}
			else if(Other.IsA('FlakCannon'))
			{
				FlakCannon(Other).FireModeClass[0] = class'WeaponFire_Flak';
				FlakCannon(Other).FireModeClass[1] = class'WeaponFire_FlakAlt';
			}
			else if(Other.IsA('RocketLauncher'))
			{
				RocketLauncher(Other).FireModeClass[0] = class'WeaponFire_Rocket';
				RocketLauncher(Other).FireModeClass[1] = class'WeaponFire_RocketAlt';
			}
			else if(Other.IsA('ClassicSniperRifle'))
			{
				ClassicSniperRifle(Other).FireModeClass[0] = class'WeaponFire_ClassicSniper';
			}			
			else if(Other.IsA('SniperRifle'))
			{
				SniperRifle(Other).FireModeClass[0] = class'WeaponFire_Lightning';
			}
		}
	}
	
    if(Other.IsA('Pickup') && !Other.IsA('Misc_PickupHealth') && !Other.IsA('Misc_PickupShield') && !(Other.IsA('Misc_PickupAdren')))
        return false;
		
    if(Other.IsA('xPickupBase') && !Other.IsA('Misc_PickupBase'))
        Other.bHidden = true;
		
    return true;
}

function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( aClassName == "" )
		return true;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if ( A.IsA('Pickup') && !A.IsA('WeaponPickup') )
			Pickup(A).Respawntime = 0.0;
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return true;
	}
	return false;
}

function string GetInventoryClassOverride(string InventoryClassName)
{
    local int x;
	
	if(EnableNewNet)
	{
		for(x=0; x<ArrayCount(WeaponInfo); x++)
		{
			if(InventoryClassName ~= WeaponInfo[x].WeaponName)
				return NewNetWeaponNames[x];
		}
	}
	
    if ( NextMutator != None )
		return NextMutator.GetInventoryClassOverride(InventoryClassName);
	return InventoryClassName;
}

function GiveWeapons(Pawn P)
{
    local int i;
	local Misc_Pawn xP;

	xP = Misc_Pawn(P);
	if(xP==None)
		return;
		
    for(i = 0; i < ArrayCount(WeaponInfo); i++)
    {
        if(WeaponClasses[i]==None || (WeaponInfo[i].Ammo[0]<=0 && WeaponInfo[i].Ammo[1]<=0))
            continue;
			
		xP.GiveWeaponClass(WeaponClasses[i]);
    }
}

function GiveAmmo(Pawn P)
{
    local Weapon W;
    local int i;

	for(i = 0; i < ArrayCount(WeaponInfo); i++)
	{
		if(WeaponInfo[i].WeaponName == "" || (WeaponInfo[i].Ammo[0] <= 0 && WeaponInfo[i].Ammo[1] <= 0))
			continue;
			
		W = Weapon(P.FindInventoryType(WeaponClasses[i]));
		if(W == None)
			continue;

		if(WeaponInfo[i].Ammo[0] > 0)
			W.AmmoCharge[0] = WeaponInfo[i].Ammo[0];

		if(WeaponInfo[i].Ammo[1] > 0)
			W.AmmoCharge[1] = WeaponInfo[i].Ammo[1];

        //fix shield bug
        if(ShieldGun(W) != None)
        {
            W.FillToInitialAmmo();
        }
	}
}

function ServerTraveling(string URL, bool bItems)
{
	if(Team_GameBase(Level.Game) != None)
        Team_GameBase(Level.Game).ResetDefaults();
    else if(ArenaMaster(Level.Game) != None)
        ArenaMaster(Level.Game).ResetDefaults();
		
    Super.ServerTraveling(URL, bItems);
}

defaultproperties
{
     WeaponInfo(0)=(WeaponName="xWeapons.ShockRifle",Ammo[0]=20,MaxAmmo[0]=1.500000)
     WeaponInfo(1)=(WeaponName="xWeapons.LinkGun",Ammo[0]=100,MaxAmmo[0]=1.500000)
     WeaponInfo(2)=(WeaponName="xWeapons.MiniGun",Ammo[0]=75,MaxAmmo[0]=1.500000)
     WeaponInfo(3)=(WeaponName="xWeapons.FlakCannon",Ammo[0]=12,MaxAmmo[0]=1.500000)
     WeaponInfo(4)=(WeaponName="xWeapons.RocketLauncher",Ammo[0]=12,MaxAmmo[0]=1.500000)
     WeaponInfo(5)=(WeaponName="xWeapons.SniperRifle",Ammo[0]=10,MaxAmmo[0]=1.500000)
     WeaponInfo(6)=(WeaponName="xWeapons.BioRifle",Ammo[0]=20,MaxAmmo[0]=1.500000)
     WeaponInfo(7)=(WeaponName="xWeapons.AssaultRifle",Ammo[0]=999,Ammo[1]=5,MaxAmmo[0]=1.500000)
     WeaponInfo(8)=(WeaponName="xWeapons.ShieldGun",Ammo[1]=100,MaxAmmo[0]=1.000000,MaxAmmo[1]=1.000000)
     WeaponInfo(9)=(WeaponName="UTClassic.ClassicSniperRifle",Ammo[0]=10,MaxAmmo[0]=1.500000)
     EnableNewNet=True
     WeaponClasses(0)=Class'XWeapons.ShockRifle'
     WeaponClasses(1)=Class'XWeapons.LinkGun'
     WeaponClasses(2)=Class'XWeapons.Minigun'
     WeaponClasses(3)=Class'XWeapons.FlakCannon'
     WeaponClasses(4)=Class'XWeapons.RocketLauncher'
     WeaponClasses(5)=Class'XWeapons.SniperRifle'
     WeaponClasses(6)=Class'XWeapons.BioRifle'
     WeaponClasses(7)=Class'XWeapons.AssaultRifle'
     WeaponClasses(8)=Class'XWeapons.ShieldGun'
     WeaponClasses(9)=Class'UTClassic.ClassicSniperRifle'
     NewNetWeaponClasses(0)=Class'3SPNvSoL.NewNet_ShockRifle'
     NewNetWeaponClasses(1)=Class'3SPNvSoL.NewNet_LinkGun'
     NewNetWeaponClasses(2)=Class'3SPNvSoL.NewNet_MiniGun'
     NewNetWeaponClasses(3)=Class'3SPNvSoL.NewNet_FlakCannon'
     NewNetWeaponClasses(4)=Class'3SPNvSoL.NewNet_RocketLauncher'
     NewNetWeaponClasses(5)=Class'3SPNvSoL.NewNet_SniperRifle'
     NewNetWeaponClasses(6)=Class'3SPNvSoL.NewNet_BioRifle'
     NewNetWeaponClasses(7)=Class'3SPNvSoL.NewNet_AssaultRifle'
     NewNetWeaponClasses(8)=Class'3SPNvSoL.NewNet_ShieldGun'
     NewNetWeaponClasses(9)=Class'3SPNvSoL.NewNet_ClassicSniperRifle'
     NewNetWeaponNames(0)="3SPNvSoL.NewNet_ShockRifle"
     NewNetWeaponNames(1)="3SPNvSoL.NewNet_LinkGun"
     NewNetWeaponNames(2)="3SPNvSoL.NewNet_MiniGun"
     NewNetWeaponNames(3)="3SPNvSoL.NewNet_FlakCannon"
     NewNetWeaponNames(4)="3SPNvSoL.NewNet_RocketLauncher"
     NewNetWeaponNames(5)="3SPNvSoL.NewNet_SniperRifle"
     NewNetWeaponNames(6)="3SPNvSoL.NewNet_BioRifle"
     NewNetWeaponNames(7)="3SPNvSoL.NewNet_AssaultRifle"
     NewNetWeaponNames(8)="3SPNvSoL.NewNet_ShieldGun"
     NewNetWeaponNames(9)="3SPNvSoL.NewNet_ClassicSniperRifle"
     bAddToServerPackages=True
     FriendlyName="3SPN"
     Description="3SPN"
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysTick=True
}
