%--------------- communication gap -----------%

initiatedAt(communicationGapNearPort(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(communicationGapNearPort(Vessel)=true, T) :-
    happensAt(gap_end(Vessel), T).

initiatedAt(communicationGapFarFromPorts(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T),
    \+(holdsAt(withinArea(Vessel, nearPorts)=true, T)).

terminatedAt(communicationGapFarFromPorts(Vessel)=true, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, coastalArea)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, coastalArea), T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel, below)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, _, _),
    Speed < Min.

initiatedAt(movingSpeed(Vessel, normal)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _),
    Speed >= Min,
    Speed =< Max.

initiatedAt(movingSpeed(Vessel, above)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _, Max, _),
    Speed > Max.

terminatedAt(movingSpeed(Vessel, _SpeedStatus)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel, _SpeedStatus)=true, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed < TrawlspeedMin.
terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed > TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, fishingArea), T).

initiatedAt(trawling(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

holdsFor(trawling(Vessel)=true, I) :-
    initiatedAt(trawling(Vessel)=true, T),
    holdsFor(withinArea(Vessel, fishingArea)=true, I),
    holdsFor(velocity(Vessel, Speed, _, _)=between, I),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax,
    thresholds(trawlingTime, TrawlingTime),
    duration(I, Duration),
    Duration >= TrawlingTime.

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).
initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, anchorageArea)=true, T).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stop_start(Vessel)=true, I),
    union_all([
        holdsFor(withinArea(Vessel, nearPorts)=true, I),
        holdsFor(withinArea(Vessel, anchorageArea)=true, I)
    ], I).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed < TuggingMin.
terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(proximity(Vessel1, Vessel2)=true, T),
    vesselType(Vessel1, tugboat),
    happensAt(velocity(Vessel1, Speed1, _, _), T),
    happensAt(velocity(Vessel2, Speed2, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed1 >= TuggingMin, Speed1 =< TuggingMax,
    Speed2 >= TuggingMin, Speed2 =< TuggingMax.

initiatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(proximity(Vessel1, Vessel2)=true, T),
    vesselType(Vessel2, tugboat),
    happensAt(velocity(Vessel1, Speed1, _, _), T),
    happensAt(velocity(Vessel2, Speed2, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed1 >= TuggingMin, Speed1 =< TuggingMax,
    Speed2 >= TuggingMin, Speed2 =< TuggingMax.


holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    initiatedAt(tugging(Vessel1, Vessel2)=true, T),
    holdsFor(proximity(Vessel1, Vessel2)=true, I),
    holdsFor(velocity(Vessel1, Speed1, _, _)=between, I),
    holdsFor(velocity(Vessel2, Speed2, _, _)=between, I),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed1 >= TuggingMin, Speed1 =< TuggingMax,
    Speed2 >= TuggingMin, Speed2 =< TuggingMax,
    thresholds(tuggingTime, TuggingTime),
    duration(I, Duration),
    Duration >= TuggingTime.

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    happensAt(proximity(Vessel1, Vessel2)=true, T),
    (vesselType(Vessel1, pilotVessel); vesselType(Vessel2, pilotVessel)),
    (holdsAt(slow_motion_start(Vessel1)=true, T); holdsAt(stop_start(Vessel1)=true, T)),
    (holdsAt(slow_motion_start(Vessel2)=true, T); holdsAt(stop_start(Vessel2)=true, T)),
    \+(holdsAt(withinArea(Vessel1, coastalArea)=true, T)),
    \+(holdsAt(withinArea(Vessel2, coastalArea)=true, T)).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    initiatedAt(pilotOps(Vessel1, Vessel2)=true, T),
    holdsFor(proximity(Vessel1, Vessel2)=true, I),
    (holdsFor(slow_motion_start(Vessel1)=true, I); holdsFor(stop_start(Vessel1)=true, I)),
    (holdsFor(slow_motion_start(Vessel2)=true, I); holdsFor(stop_start(Vessel2)=true, I)),
    \+(holdsFor(withinArea(Vessel1, coastalArea)=true, I)),
    \+(holdsFor(withinArea(Vessel2, coastalArea)=true, I)).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

% broke ;
initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).
initiatedAt(sarMovement(Vessel)=true, T) :-
     happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(inSAR(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    thresholds(sarMaxSpeed, SarMaxSpeed),
    Speed >= SarMinSpeed,
    Speed =< SarMaxSpeed,
    happensAt(change_in_heading(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    initiatedAt(inSAR(Vessel)=true, T),
    holdsFor(velocity(Vessel, Speed, _, _)=between, I),
    thresholds(sarMinSpeed, SarMinSpeed),
    thresholds(sarMaxSpeed, SarMaxSpeed),
    Speed >= SarMinSpeed,
    Speed =< SarMaxSpeed,
    holdsFor(change_in_heading(Vessel)=true, I).

% broke ;
terminatedAt(inSAR(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed < SarMinSpeed.
terminatedAt(inSAR(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed > SarMaxSpeed.

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    (holdsFor(slow_motion_start(Vessel)=true, I1); holdsFor(stop_start(Vessel)=true, I1)),
    \+(holdsFor(withinArea(Vessel, nearPorts)=true, I1)),
    \+(holdsFor(withinArea(Vessel, coastalArea)=true, I1)),
    thresholds(loiteringTime, LoiteringTime),
    duration(I1, Duration),
    Duration >= LoiteringTime,
    union_all([I1], I).
