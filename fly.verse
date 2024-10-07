
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }


flying := class(creative_device):

    @editable
    Chair : chair_device = chair_device{}

    @editable
    Camera : gameplay_camera_orbit_device = gameplay_camera_orbit_device{}

    @editable
    Inputs : input_trigger_device = input_trigger_device{}

    @editable
    BuyTrigger : trigger_device = trigger_device{}

    @editable
    ResetTrigger : trigger_device = trigger_device{}

    var IsForward : logic = false
    var OriginalLocation : vector3 = vector3{}

    OnBegin<override>()<suspends>:void=
        BuyTrigger.TriggeredEvent.Subscribe(BuyFly)
        Chair.SeatedEvent.Subscribe(BeginFly)
        Inputs.PressedEvent.Subscribe(Forward)
        Inputs.ReleasedEvent.Subscribe(Stop)

        set OriginalLocation = Chair.GetTransform().Translation
    
    BuyFly(MAgent : ?agent):void=
        if (Agent := MAgent?):
            spawn{SeatAgent(Agent)}
    
    SeatAgent(Agent : agent)<suspends>:void=
        if (FortChar := Agent.GetFortCharacter[]):
            Transform := FortChar.GetTransform()
            if. Chair.TeleportTo[Transform.Translation, Transform.Rotation]
            Sleep(0.2)
            Chair.Seat(Agent)
    
    Forward(Agent : agent):void=
        set IsForward = true
    
    Stop(Agent : agent, t : float):void=
        set IsForward = false

    BeginFly(Agent : agent):void=
        if:
            FortChar := Agent.GetFortCharacter[]
        then:
            Camera.AddTo(Agent)
            Inputs.Register(Agent)
            spawn{Fly(FortChar)}

    Fly(FortChar : fort_character)<suspends>:void=
        race:
            block:
                Chair.ExitedEvent.Await()
                if (Agent := FortChar.GetAgent[]):
                    Camera.RemoveFrom(Agent)
                    ResetFly(Agent)
            loop:
                if (IsForward?):
                    ViewRotation := FortChar.GetViewRotation()
                    NewLocation := FortChar.GetTransform().Translation + ViewRotation.GetLocalForward() * 300.0
                    Chair.MoveTo(NewLocation, ViewRotation, 0.2)
                Sleep(0.0)
            block:
                FortChar.EliminatedEvent().Await()
                if (Agent := FortChar.GetAgent[]):
                    spawn{DelayedCameraRemove(Agent)}
                    ResetFly(Agent)

    
    ResetFly(Agent : agent)<suspends>:void=
        Inputs.Unregister(Agent)
        Sleep(0.2)
        if. Chair.TeleportTo[OriginalLocation, rotation{}]
        set IsForward = false
        ResetTrigger.Trigger(Agent)

    DelayedCameraRemove(Agent : agent)<suspends>:void=
        Sleep(7.0)
        Camera.RemoveFrom(Agent)

