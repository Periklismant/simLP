# Nov 15

## o1 setup2

- fluent predicate renaming
    - communicationGap -> gap
    - moving -> movingSpeed
    - tugSpeed -> tuggingSpeed
- use of start/end auxiliary events for "semantically equavalent" expressions
    - gap_start -> start(gap) 
    - leavesArea, areaType(nearCoast) -> end(withinArea(Vessel, nearCoast)=true)
    - change_in_speed_start -> start(changingSpeed) 
- comparison predicate renaming
    - greater_than/less_than -> inRange/standard comparison predicates (e.g., =<)
- auxiliary predicate renaming
    - angle_difference -> absoluteAngleDiff
- renaming constants that do not exist:
    - trawlingArea -> fishing

### Comments:
    - Some definitions are generated multiple times (the definition for trawlSpeed appears twice, while anchoredOrMoored is defined 3 times: once as a simple fluent and twice as a statically determined one). I cheated and kept the most accurate definitions.
    - trawling and tugging are defined as simple FVP by the LLM, but are defined as statically determined fluents in the ground rules. Do we instruct the LLM regarding the type of fluent that should be used for each activity?
    - trawlingMovement is not defined.
    - The LLM defines the fluent "sar" with a set of rules that resemble the ground rules for sarSpeed. Looking at the description for sar in the google docs file, I think that I see the reason for this. We are first providing a definition of sar, which mainly includes speed thresholds (and perhaps was intended for sarSpeed), and then we supply a definition for sarMovement. This approach, however, does not capture the fact that sarMovement is intended as a building block for sar. In order for the LLM to use the building block fluents of sar correctly, i.e., sarSpeed and sarMovement, I think that we should first start by describing the definitions of sarSpeed and sarMovement, and then provide the definition for sar.
    - The generated rules include a definition for moving(Vessel)=true. This is intended as a definition for movingSpeed. However, "true" is not a possible value of the movingSpeed fluent. None of its values, i.e., below, normal and above, is defined in the generated rules. I think that we should define each type of speed in a separate prompt. For instance, we could use the prompt: "We say that the moving speed of a vessel of a certain type is above the anticipated speed when it exceeds the maximum speed threshold for vessels of this type".

