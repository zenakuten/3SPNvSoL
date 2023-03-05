# 3SPNvSoL
3SPN/TAM mutator customized for SoL, originally based on 3SPNv42102

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
