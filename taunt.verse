
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }


custom_prop_taunt_device := class(creative_device):

    @editable
    SoundEffects : []creative_prop_asset = array{}

    @editable
    InputTrigger : input_trigger_device = input_trigger_device{}

    (Prop : creative_prop_asset).PlayCue(Location : vector3, Time : float)<suspends>:void=
        SpawnedProp := SpawnProp(Prop, Location, rotation{})
        if (PossibleProp := SpawnedProp(0)?):
            Sleep(Time)
            PossibleProp.Dispose()

    OnBegin<override>()<suspends>:void=
        InputTrigger.PressedEvent.Subscribe(InputPressed)
    
    InputPressed(Agent : agent):void=
        spawn{HandleInputPressed(Agent)}
    
    HandleInputPressed(Agent : agent)<suspends>:void=
        if (FortChar := Agent.GetFortCharacter[]):
            RanNum := GetRandomInt(0, SoundEffects.Length-1)
            if (SoundEffect := SoundEffects[RanNum]):
                InputTrigger.Unregister(Agent)
                SoundEffect.PlayCue(FortChar.GetTransform().Translation, 4.0)
                InputTrigger.Register(Agent)
                
