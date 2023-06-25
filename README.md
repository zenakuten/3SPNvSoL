# 3SPNvSoL
3SPN/TAM mutator customized for SoL, originally based on 3SPNv42102

v2.0
- stats update

v1.9
- disable landing sound if bPlayOwnFootsteps is false
- add server settings FootstepVolume and FootstepRadius for footstep sound
- remove unneccessary logging
- Add UTComp style movement updates
- Add ally/enemy logic for weapon colors, remove 'use brightskins' for weapon colors

v1.8
- increase config/webadmin setting for maxnetspeed.  It could be changed in the ini but using webadmin 
would force it to be within 9636-25000 range.  New range is 9636-100000

v1.7
- increase auto net speed max settings in gui
- add the rest of Fox WS Fix (thanks ds8k :) )
- add custom team colors for weapons
- add config option for abort necro sound

v1.6
- new config option "Auto Set Netspeed", set netspeed at match start
- new server options MinNetSpeed, MaxNetSpeed.  Admin can restrict netspeeds to a range.  
- new config option "Enable Widescreen Fix".  Add some widescreen fixes from Fox WS Fix.  Currently fixes crosshairs.  More to come.  (thanks ds8k!)
- new config options to enable team colors for rockets, bio, flak, and shock rifle.  

v1.5
- fix issue with booster sometimes not working
- new config option 'MinPlayersForStatsRecording', minimum players needed before recording stats, default is 2 (was hardcoded at 6)

V1.4
- fix 'teams' command

v1.3
- fix config option 'ReceiveAwards' not applying, was only doing 'player' awards previously
- change shield gun award to use haha sound

v1.2
- fix 1 kill combo whore bug (oops)
- change default receive award type to all

v1.1
- Add config option for SuddenDeathSound, SuddenDeath text, MatchPointSound, and MatchPoint text

[3SPNvSoL.Message_WinningRound]
SuddenDeathSound=Sound'SoL_Zoundz_1601.dod'
SuddenDeath=DO OR DIE!!!
;MatchPointSound=...
;MatchPoint=This is MATCH POINT!!!

- Add Map prefix to fix issue with MapList.  Freon maps must start with 'FR-'
- Update help text for play own footsteps checkbox "(weapon bob must be OFF!!!)"
- rename 'Damage' submenu to 'extra'
- Add 'ReceiveAward' configuration to 'extra' sub menu.  Default is 'Player'
- Add 'Use classic 3SPN death messages' to colored names sub menu. Default is false.


v1.0 initial release, based off 3SPNv42102

new in vSoL
- Add options for FastWeaponSwitch, boost dodge
- Add Eye height fix
- remove sniper type stuff
