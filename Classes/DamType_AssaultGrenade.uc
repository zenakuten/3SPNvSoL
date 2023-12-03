//================================================================================
// DamType_AssaultGrenade.
//================================================================================

class DamType_AssaultGrenade extends DamTypeAssaultGrenade;

var int AwardLevel;
static function IncrementKills(Controller Killer)
{
	local Misc_PRI xPRI;


	xPRI = Misc_PRI(Killer.PlayerReplicationInfo);
	if(xPRI != None)
	{
		++xPRI.GrenCount;

		if((xPRI.GrenCount >= Default.AwardLevel) && (Misc_Player(Killer) != None))
			Misc_Player(Killer).BroadcastAward(class'Message_RocketMan');

		if((xPRI.GrenCount >= Default.AwardLevel) && (Misc_Bot(Killer) != None))
			Misc_Bot(Killer).BroadcastAward(class'Message_RocketMan');
	} 	
	
}

defaultproperties
{
     AwardLevel=1
}
