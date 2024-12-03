%--------------- communication gap -----------%
%
% Added all the values
% holdsAt heads -> holdsFor

initiatedAt(gap(Vessel)=true, I) :-
    lastReceivedMessage(Vessel, LastReceivedMessageTime, _),
    timeSince(LastReceivedMessageTime, TimeElapsed, _),
    TimeElapsed > HcNearCoastMax,
    \+ withinArea(Vessel, Port, _).

terminatedAt(gap(Vessel)=true, I) :-
    lastReceivedMessage(Vessel, LastReceivedMessageTime, _),
    timeSince(LastReceivedMessageTime, TimeElapsed, _),
    TimeElapsed > LoiteringTime,
    velocity(Vessel, Speed, _, _),
    Speed >= MovingMin.

initiatedAt(farFromPortsGap(Vessel)=true, I) :-
    lastReceivedMessage(Vessel, LastReceivedMessageTime, _),
    timeSince(LastReceivedMessageTime, TimeElapsed, _),
    TimeElapsed > AdriftAngThr,
    \+ withinArea(Vessel, Port, _).

terminatedAt(farFromPortsGap(Vessel)=true, I) :-
    lastReceivedMessage(Vessel, LastReceivedMessageTime, _),
    timeSince(LastReceivedMessageTime, TimeElapsed, _),
    TimeElapsed > LoiteringTime,
    velocity(Vessel, Speed, _, _),
    Speed >= MovingMin.

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, I) :-
    velocity(Vessel, Speed, _, _),
    Speed =< LowSpeedMax,
    \+ gapStart(Vessel).

terminatedAt(lowSpeed(Vessel)=true, I) :-
    velocity(Vessel, Speed, _, _),
    Speed > LowSpeedMax.

terminatedAt(lowSpeed(Vessel)=true, I) :-
     gapEnd(Vessel).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, I) :-
    velocityChange(Vessel, _),
    \+ gapStart(Vessel).

terminatedAt(changingSpeed(Vessel)=true, I) :-
    velocity(Vessel, Speed1, _, _), 
    velocity(Vessel, Speed2, _, _), 
    Speed1 = Speed2.
terminatedAt(changingSpeed(Vessel)=true, I) :-
     gapEnd(Vessel).


%------------ highSpeedNearCoast -------------%

initiatedAt( highSpeedNearCoast(Vessel)=true, I) :-
    withinArea(Vessel, _, _),
    velocity(Vessel, Speed, _, _),
    Speed > HcNearCoastMax.

terminatedAt( highSpeedNearCoast(Vessel)=true, I) :-
    velocity(Vessel, Speed, _, _), 
    Speed =< HcNearCoastMax.

terminatedAt( highSpeedNearCoast(Vessel)=true, I) :-
    \+ withinArea(Vessel, _, _).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel)=true, I) :-
    type(Vessel, _),
    velocity(Vessel, Speed, _, _),
    Speed < MinSpeed.
initiatedAt(movingSpeed(Vessel)=true, I) :-
    type(Vessel, _),
    velocity(Vessel, Speed, _, _),
    min(MinSpeed, Speed, MaxSpeed) =< Speed, Speed =< max(MaxSpeed) , 
    \+ gapStart(Vessel).


terminatedAt(movingSpeed(Vessel)=true, I) :-
    velocity(Vessel, Speed, _, _), 
    Speed < MinSpeed. 
terminatedAt(movingSpeed(Vessel)=true, I) :-
    gapEnd(Vessel).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, I) :-
    abs(angleDifference(Vessel)) > MaxDriftAngle,
    \+ gapStart(Vessel).
initiatedAt(drifting(Vessel)=true, I) :-
    noMovement(Vessel),
    \+ gapStart(Vessel).


terminatedAt(drifting(Vessel)=true, I) :-
    abs(angleDifference(Vessel)) =< MaxDriftAngle.
terminatedAt(drifting(Vessel)=true, I) :-
    noMovement(Vessel). 
terminatedAt(drifting(Vessel)=true, I) :-
    gapEnd(Vessel).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, I) :-
    withinArea(Vessel, _, _),
    velocity(Vessel, Speed, _, _),
    minTrawlSpeed =< Speed, 
    Speed =< maxTrawlSpeed,
    \+ gapStart(Vessel).

terminatedAt(trawlSpeed(Vessel)=true, I) :-
    velocity(Vessel, Speed, _, _), 
     \+(minTrawlSpeed =< Speed , Speed =< maxTrawlSpeed).
terminatedAt(trawlSpeed(Vessel)=true, I) :-
     gapEnd(Vessel).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, I) :-
    withinArea(Vessel, _, _),
    absoluteHeadingChange(Vessel, _),
    \+ gapStart(Vessel).

terminatedAt(trawlingMovement(Vessel)=true, I) :-
    withinArea(Vessel, _, _) , 
    \+(velocity(Vessel, _, _, _)).
terminatedAt(trawlingMovement(Vessel)=true, I) :-
     gapEnd(Vessel).


holdsFor(trawling(Vessel)=true, I) :-
    fishingArea(Vessel, _),
    (velocity(Vessel, Speed, _, _) , 
     minTrawlingSpeed =< Speed, 
     Speed =< maxTrawlingSpeed),
    trawlingManner(Vessel, _),
    duration(I) > MinTrawlingDuration.

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    (anchorageArea(Vessel, _) , 
     farFromPorts(Vessel)); 
    portNearby(Vessel, _).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, I) :-
    velocity(Vessel, Speed, _, _),
    minTugSpeed =< Speed, 
    Speed =< maxTugSpeed,
    \+ gapStart(Vessel).

terminatedAt(tuggingSpeed(Vessel)=true, I) :-
    (velocity(Vessel, Speed, _, _) , 
     \+(minTugSpeed =< Speed , Speed =< maxTugSpeed); 
     gapEnd(Vessel)).

holdsFor(tugging(Vessel)=true, I) :-
    tugboat(Tugboat),
    closeToEachOther(Vessel, Tugboat, _),
    (velocity(Vessel, Speed1, _, _) , 
     velocity(Tugboat, Speed2, _, _) , 
     minTuggingSpeed =< Speed1, Speed1 =< maxTuggingSpeed, 
     Speed2 =< maxTuggingSpeed),
    duration(I) > MinTuggingDuration.

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel)=true, I) :-
    pilotVessel(PilotVessel),
    closeToEachOther(Vessel, PilotVessel, _),
    ((velocity(Vessel, Speed1, _, _) , 
       velocity(PilotVessel, Speed2, _, _) , 
       (Speed1 =< maxLowSpeed ; idle(Vessel)) , 
       (Speed2 =< maxLowSpeed ; idle(PilotVessel)));
     farFromPorts(Vessel); 
     farFromPorts(PilotVessel)),
    \+ coastalArea(Vessel).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, I) :-
    velocity(Vessel, Speed, _, _),
    Speed > MinSARSpeed,
    \+ gapStart(Vessel).

terminatedAt(sarSpeed(Vessel)=true, I) :-
    (velocity(Vessel, Speed, _, _) , 
     Speed =< MinSARSpeed; 
     gapEnd(Vessel)).

initiatedAt(sarMovement(Vessel)=true, I) :-
    (absoluteHeadingChange(Vessel, _) ; 
     velocityChange(Vessel, _)),
    \+ gapStart(Vessel).

terminatedAt(sarMovement(Vessel)=true, I) :-
    (gapEnd(Vessel)).

holdsFor(inSAR(Vessel)=true, I) :-
    (velocity(Vessel, Speed, _, _) , 
     typicalSARSpeed =< Speed, 
     Speed =< maxSARSpeed),
    sarManner(Vessel, _).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    ((velocity(Vessel, Speed, _, _) , 
       (Speed =< maxLowSpeed ; idle(Vessel))); 
     farFromPorts(Vessel)),
    \+ coastalArea(Vessel),
    \+ anchored(Vessel),
    \+ moored(Vessel),
    duration(I) > MinLoiteringDuration.
