
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }


flashbang_device := class(creative_device):

    @editable
    UIManager : ui_manager_device = ui_manager_device{}

    @editable
    FlashInputTrigger : input_trigger_device = input_trigger_device{}

    @editable
    FlashbangCinematic : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    FlashbangAudioEnemy : audio_player_device = audio_player_device{}

    @editable
    FlashbangAudioLocal : audio_player_device = audio_player_device{}

    @editable
    FlashbangVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    MaxFlashbangs : int = 2

    var FlashbangLimitMap : [fort_character]int = map{}

    OnBegin<override>()<suspends>:void=
        FlashInputTrigger.PressedEvent.Subscribe(FlashbangPressed)
    
    FlashbangPressed(Agent : agent):void=
        spawn{HandleFlashbangPressed(Agent)}
    
    HandleFlashbangPressed(Agent : agent)<suspends>:void=
        if (ActivatingFortChar := Agent.GetFortCharacter[]):
            ClosestChar := FindClosestFortChar(GetPlayspace().GetPlayers(), ActivatingFortChar)
            
            if (ClosestAgent := ClosestChar.GetAgent[]):
                FlashbangCinematic.Play(ClosestAgent)
                FlashbangAudioEnemy.Play(ClosestAgent)
                FlashbangVFX.Pickup(ClosestAgent)
                if (FlashbangLimitMap[ActivatingFortChar] > 0):
                    if:
                        set FlashbangLimitMap[ActivatingFortChar] += 1
                else:
                    if:
                        set FlashbangLimitMap[ActivatingFortChar] = 1
                FlashbangAudioLocal.Play(Agent)

            if (NumFlashbangs := FlashbangLimitMap[ActivatingFortChar], Player := player[Agent]):
                UIManager.UpdateFlashbangs(Player, NumFlashbangs)

            if (FlashbangLimitMap[ActivatingFortChar] = MaxFlashbangs):
                FlashInputTrigger.Unregister(Agent)
    
    FindClosestFortChar(Players : []player, InFortChar : fort_character):fort_character=
        var ClosestFortChar : fort_character = InFortChar
        var ClosestDistance : float = 1000000000.0
        CameraLocation := InFortChar.GetViewLocation()
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (SeekersTeam := TeamCollection.GetTeams()[0]): #TEAM1
            for (Player : Players, FortChar := Player.GetFortCharacter[], FortChar <> InFortChar, TeamCollection.IsOnTeam[Player, SeekersTeam]):
                L_Distance := Distance(CameraLocation, FortChar.GetTransform().Translation)
                if (L_Distance < ClosestDistance):
                    set ClosestFortChar = FortChar
                    set ClosestDistance = L_Distance
        return ClosestFortChar

