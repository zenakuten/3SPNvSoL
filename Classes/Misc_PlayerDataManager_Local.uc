/*******************************************************************************
 * Misc_PlayerDataManager_Local generated by Eliot.UELib using UE Explorer.
 * Eliot.UELib © 2009-2015 Eliot van Uytfanghe. All rights reserved.
 * http://eliotvu.com
 *
 * All rights belong to their respective owners.
 *******************************************************************************/
class Misc_PlayerDataManager_Local extends Misc_PlayerDataManager_ServerLink
    config(statstext)
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const MAXRECORDS = 10000;

struct TList
{
    var string ListName;
    var name StatType;
    var name Aggregate;
    var int listsize;
    var int TimeRange;
};

var config array<TList> Lists;
var int CurrentList;
var private array<string> SLNames;
var private array<float> SLValues;
var private array<string> SLStats;
var private int SLAwaiting;
var private int SLRow;
var string TopName;
var int TopScore;
//var config int Moneyreal;
var Team_GameBase BaseGame;

function Misc_ServerLink GetServerLink()
{
    return none;
    //return;    
}

function PostBeginPlay()
{
    super.PostBeginPlay();

    if(BaseGame==None)
        foreach DynamicActors(class'Team_GameBase', BaseGame)
            break;

    PurgeAndUpdateTopScore();
    SLAwaiting = 0;
    //return;    
}

function string GetPlayerID(Misc_Player P)
{
    return P.GetPlayerIDHash();
    //return;    
}

function Misc_LocalStatsDB GetDB(string PlayerID)
{
    // End:0x35
    if(Level.Game.IsA('Freon'))
    {
        return class'Misc_LocalStatsDB_Freon'.static.GetFor(PlayerID);
    }
    // End:0x4A
    else
    {
        return class'Misc_LocalStatsDB'.static.GetFor(PlayerID);
    }
    //return;    
}

function class<Misc_LocalStatsDB> GetGameConfigClass()
{
    // End:0x26
    if(Level.Game.IsA('Freon'))
    {
        return class'Misc_LocalStatsDB_Freon';
    }
    // End:0x2C
    else
    {
        return class'Misc_LocalStatsDB';
    }
    //return;    
}

function ServerRequestStats(int PlayerIndex, string PlayerHash)
{
    local float Rank, PointsToRankUp, AvgPPR;
    local array<float> PPRList;

    GetDB(PlayerHash).ReadStats(Rank, PointsToRankUp, AvgPPR, PPRList);
	
	
    ReceiveStats(PlayerIndex, Rank, PointsToRankUp, AvgPPR, PPRList);
    //return;    
}

function ServerRequestStatsList()
{
    ++ SLAwaiting;
    GotoState('SendStatsLists');
    //return;    
}

function ServerRegisterGame(string GameTime, string MapName, string TeamScores)
{
    //return;    
}

function ServerRegisterStats(string GameTime, string PlayerName, string PlayerHash, int TeamIdx, int Rounds, float Score, int Kills, int Deaths, int thaws, int git)
{
    local Misc_LocalStatsDB DB;

    DB = GetDB(PlayerHash);
    DB.WriteStats(DB.GetCurrentTime(Level), PlayerName, Rounds, Score, Kills, Deaths );
    //return;    
}







function PurgeAndUpdateTopScore()
{
    local array<string> Names;
    local int i;
    local Misc_LocalStatsDB StatsDB;
    local string Time;
    local int Score;
    local bool ClearOldStats;

    Time = class'Misc_LocalStatsDB'.static.GetCurrentTime(Level);
    Names = GetPerObjectNames(GetGameConfigClass().default.ConfigName, string(GetGameConfigClass().default.Class.Name), 10000);
    default.TopName = "";
    default.TopScore = 0;
    i = 0;
    ClearOldStats=false;
    if(BaseGame != None)
        ClearOldStats=BaseGame.ClearOldStats;

    J0x6A:
    // End:0x105 [Loop If]
    if(i < Names.Length)
    {
        StatsDB = new (none, Names[i]) GetGameConfigClass();
        // End:0xB7
        if(StatsDB.IsOutDated(Time) && ClearOldStats)
        {
            StatsDB.ClearConfig();
        }
        Score = StatsDB.GetTopScore();
        // End:0xFB
        if(Score > default.TopScore)
        {
            default.TopName = StatsDB.GetPlayerName();
            default.TopScore = Score;
        }
        ++ i;
        // [Loop Continue]
        goto J0x6A;
    }
    //return;    
}

function BuildList(int ListIndex, out array<string> Players, out array<float> PlayerStats)
{
    local array<string> Names;
    local int i, li;
    local Misc_LocalStatsDB StatsDB;
    local string Time;
    local float StatData;

    Time = class'Misc_LocalStatsDB'.static.GetCurrentTime(Level);
    Names = GetPerObjectNames(GetGameConfigClass().default.ConfigName, string(GetGameConfigClass().default.Class.Name), 10000);
    Players.Length = 0;
    PlayerStats.Length = 0;
    i = 0;
    J0x6B:
    // End:0x1C4 [Loop If]
    if(i < Names.Length)
    {
        StatsDB = new (none, Names[i]) GetGameConfigClass();
        StatData = StatsDB.CalculateStatData(Time, Lists[ListIndex].TimeRange, Lists[ListIndex].StatType, Lists[ListIndex].Aggregate);
        // End:0xEF
        if(StatData == float(0))
        {
            
            goto J0x1BA;
        }
        li = 0;
        J0xF6:
        
        if(li < PlayerStats.Length)
        {
            // End:0x11E
            if(PlayerStats[li] < StatData)
            {
              
               goto J0x128;
            }
			
             li++;
			
            
            goto J0xF6;
        }
       J0x128:
        if(li < PlayerStats.Length)
        {
            Players.Insert(li, 1);
            PlayerStats.Insert(li, 1);
        }
        Players[li] = StatsDB.GetPlayerName();
        PlayerStats[li] = StatData;
		
        li = Lists[ListIndex].listsize;
       
        if(PlayerStats.Length > li)
        {
            Players.Length = li;
            PlayerStats.Length = li;
        }
        J0x1BA:
        i++;
        
        goto J0x6B;
    }
    //return;    
}

state SendStatsLists
{
  function ServerRequestStatsList ()
  {
    SLAwaiting++;
  }
  
  function PrepareList ()
  {
    local int i;
  
    SLStats.Length = 0;
    BuildList(CurrentList,SLNames,SLValues);
    if ( Lists[CurrentList].StatType == 'PPR' )
    {
	i = 0;
  JL003E:
      
      if ( i < SLValues.Length )
      {
        SLStats[i] = Class'Misc_PRI'.static.GetFormattedPPR(SLValues[i]);
        i++;
        goto JL003E;
      }
    } else {
      i = 0;
	  JL0088:
      if ( i < SLValues.Length )
      {
        SLStats[i] = string(int(SLValues[i]));
        i++;
        goto JL0088;
      }
    }
  }
Begin:
    PrepareList();
    ReceiveListName(Lists[CurrentList].ListName);
    Sleep(0.50);
    SLRow = 0;
    J0x2B:
    // End:0x6E [Loop If]
    if(SLRow < SLStats.Length)
    {
        ReceiveListIdx(SLRow, SLNames[SLRow], SLStats[SLRow]);
        Sleep(0.10);
        ++ SLRow;
        // [Loop Continue]
        goto 'J0x2B';
    }
    Sleep(0.40);
    // End:0x8F
    if(++ CurrentList >= Lists.Length)
    {
        CurrentList = 0;
    }
    // End:0xA5
    if(-- SLAwaiting > 0)
    {
        goto 'Begin';
    }
    // End:0xAC
    else
    {
        GotoState('None');
    }
    stop;                
}

defaultproperties
{
     Lists(0)=(ListName="Top10 Score 7 Day*",StatType="Score",Aggregate="sum",listsize=10,TimeRange=10080)
     Lists(1)=(ListName="Top10 PPR 7 Day",StatType="PPR",Aggregate="Max",listsize=10,TimeRange=10080)
     Lists(2)=(ListName="Top10 Kills 7 Day*",StatType="Kills",Aggregate="sum",listsize=10,TimeRange=10080)
     Lists(3)=(ListName="Top10 Map Score 7 Day",StatType="Score",Aggregate="Max",listsize=10,TimeRange=10080)
     Lists(4)=(ListName="Top10 Score 30 Day",StatType="Score",Aggregate="sum",listsize=10,TimeRange=43200)
     Lists(5)=(ListName="Top10 PPR 30 Day",StatType="PPR",Aggregate="Max",listsize=10,TimeRange=43200)
     Lists(6)=(ListName="Top10 Kills 30 Day",StatType="Kills",Aggregate="sum",listsize=10,TimeRange=43200)
     Lists(7)=(ListName="Top10 Map Score 30 Day",StatType="Score",Aggregate="Max",listsize=10,TimeRange=43200)
     Lists(8)=(ListName="Top10 Kills 24h",StatType="Kills",Aggregate="sum",listsize=10,TimeRange=1440)
     bUseOwnPlayerID=True
}
