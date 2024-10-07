
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Random }


insta_respawn_device := class(creative_device):

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    ClassSelectorRespawn : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    ClassSelectorNormal1 : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    ClassSelectorNormal2 : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    ClassSelectorNo : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    TriggerClass1 : trigger_device = trigger_device{}

    @editable
    TriggerClass2 : trigger_device = trigger_device{}

    @editable
    TriggerClassNo : trigger_device = trigger_device{}

    @editable
    SpawnTeleporters : []teleporter_device = array{}

    OnBegin<override>()<suspends>:void=
        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(AgentSpawned)
    
    AgentSpawned(Agent : agent):void=
        spawn{HandleAgentSpawned(Agent)}
    
    HandleAgentSpawned(Agent : agent)<suspends>:void=
        FortChar := AwaitActiveChar(Agent)
        FortChar.EliminatedEvent().Subscribe(FortCharEliminated)

    AwaitActiveChar(Agent : agent)<suspends>:fort_character=
        loop:
            Sleep(0.1)
            if (FortChar := Agent.GetFortCharacter[], FortChar.IsActive[]):
                return FortChar
    
    FortCharEliminated(Result : elimination_result):void=
        spawn{HandleFortCharEliminated(Result)}
    
    HandleFortCharEliminated(Result : elimination_result)<suspends>:void=
        if:
            Agent := Result.EliminatedCharacter.GetAgent[]
            RandomTeleporter := SpawnTeleporters[GetRandomInt(0, SpawnTeleporters.Length-1)]
        then:
            Task := spawn{GetAgentsClassSelector(Agent)}
            spawn{TriggerClassTriggers(Agent)}
            ClassSelector := Task.Await()
            spawn{RespawnAgent(Agent, RandomTeleporter, ClassSelector)}
    
    GetAgentsClassSelector(Agent : agent)<suspends>:class_and_team_selector_device=
        Result := race:
            block:
                TriggerClass1.TriggeredEvent.Await()
                ClassSelectorNormal1
            block:
                TriggerClass2.TriggeredEvent.Await()
                ClassSelectorNormal2
            block:
                TriggerClassNo.TriggeredEvent.Await()
                ClassSelectorNo

    TriggerClassTriggers(Agent  : agent)<suspends>:void=
        Sleep(0.0)
        TriggerClass1.Trigger(Agent)
        TriggerClass2.Trigger(Agent)
        TriggerClassNo.Trigger(Agent)
    
    RespawnAgent(Agent : agent, Teleporter : teleporter_device, NormalClassSelector : class_and_team_selector_device)<suspends>:void=
        if (Player := player[Agent]):
            Transform := Teleporter.GetTransform()
            Player.Respawn(Transform.Translation, Transform.Rotation)
            Sleep(0.2)
            ClassSelectorRespawn.ChangeClass(Agent)
            Sleep(0.2)
            NormalClassSelector.ChangeClass(Agent)
            Player.Respawn(Transform.Translation, Transform.Rotation)
            if (FortChar := Agent.GetFortCharacter[]):
                FortChar.SetHealth(100.0)
                FortChar.SetShield(100.0)
