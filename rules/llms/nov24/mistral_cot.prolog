%--------------- communication gap -----------%

initiatedAt(gap_start_nearPort(Vessel)=true, I1) :-
    holdsFor(stopped(Vessel), I2),
    holdsFor(nearPort(Vessel), I3),
    \+ holdsFor(gap_start_farFromAllPorts(Vessel), I4),
    I2 < I1,
    I3 =< I1.

initiatedAt(gap_start_farFromAllPorts(Vessel)=true, I1) :-
    holdsFor(stopped(Vessel), I2),
    \+ holdsFor(nearPort(_), I3),
    \+ holdsFor(gap_start_nearPort(Vessel), I4),
    I2 < I1.

initiatedAt(gap_end(Vessel)=true, I1) :-
    holdsFor(proximity(_, Vessel), I2),
    \+ holdsFor(stopped(Vessel), I3),
    I < I2.

%-------------- lowspeed----------------------%

holdsFor(lowSpeedLimit=true, I) :-
    LowSpeedLimit = LowSpeedThreshold.

holdsFor(highSpeedLimit=true, I) :-
    HighSpeedLimit = HighSpeedThreshold.

initiatedAt(lowSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_Vessel < LowSpeedLimit.

initiatedAt(normalSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    LowSpeedLimit =< Speed_Vessel, Speed_Vessel < HighSpeedLimit.

initiatedAt(highSpeed(Vessel)=true , I1):-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_Vessel >= HighSpeedLimit.

initiatedAt(noLowSpeed(Vessel)=true, I1) :-
    ( \+ initiatedAt(lowSpeed(Vessel), _) ; \+ initiatedAt(stopped(Vessel), _) ).

%-------------- changingSpeed ----------------%

holdsFor(changingSpeedThreshold=true, I) :-
    MaximumChangeRate =< Speed_Change_Rate.

initiatedAt(changingSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel1, _), I3),
    holdsFor(velocity(_, _, Speed_Vessel2, I4), I4 > I3),
    DeltaT = (I4 - I3) / 60,
    Speed_Change_Rate > DeltaT.

initiatedAt(noChangingSpeed(Vessel)=true, I1) :-
    (holdsFor(moving(Vessel), _), holdsFor(velocity(_, _, Speed_Vessel1, _), I2), holdsFor(velocity(_, _,
Speed_Vessel2, I3), I3 > I2), DeltaT = (I3 - I2) / 60, Speed_Change_Rate =< DeltaT).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, I1) :-
    holdsFor(withinCoastalArea(Vessel, Region), I2),
    holdsFor(speedLimit(Speed), I3),
    holdsFor(velocity(_, _, Speed_Vessel, _), I4),
    Speed_Vessel > Speed.

initiatedAt(exitedCoastalArea(Region)=true, I1) :-
    holdsFor(withinCoastalArea(Vessel, Region), I2),
    \+ holdsFor(Position(_, X_Vessel, Y_Vessel), I3),
    I2 < I1.

initiatedAt(lowSpeedNearCoast(Vessel)=true, I1) :-
    ( holdsFor(speedLimit(Speed), I2), holdsFor(velocity(_, _, Speed_Vessel, _), I3), Speed_Vessel < Speed ;
      holdsFor(exitedCoastalArea(Region), I4) ).

%--------------- movingSpeed -----------------%

holdsFor(minSpeedExpectedForType=true, I) :-
    MinimumSpeedExpectedForType =< Speed_Min.

holdsFor(maxSpeedExpectedForType=true, I) :-
    MaximumSpeedExpectedForType >= Speed_Max.

initiatedAt(belowMinSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_Vessel < Speed_Min.

initiatedAt(normalSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_Min =< Speed_Vessel,
    Speed_Vessel < Speed_Max.

initiatedAt(aboveMaxSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_Vessel > Speed_Max.

initiatedAt(noMovement=true, I1) :-
    holdsFor(velocity(_, _, Speed_Vessel, _), I2),
    Speed_Vessel < MinimumSpeedExpectedForType.

%----------------- drifitng ------------------%

holdsFor(drifting(Vessel)=true, I) :-
    angleDiff(_, AngleDiff, Vessel, _), AngleDiff > MaxDriftAngle.

holdsFor(notStopped(Vessel)=true, I) :-
    \+holdsFor(stopped(Vessel), I).

holdsFor(stopped(Vessel)=true, I) :-
    \+ holdsFor(velocity(_, _, _, _), I).

initiatedAt(driftingStarted=true, I1) :-
    (holdsFor(drifting(Vessel), _); holdsFor(notStopped(Vessel), _)).

initiatedAt(driftingEnded=true, I1) :-
    (holdsFor(\+ drifting(Vessel), I2); holdsFor(stopped(Vessel), I2)),
    I1 >= I2.

%---------------- trawlSpeed -----------------%

holdsFor(trawlSpeedLowerLimit=true, I) :-
    TrawlLowerLimit = LowerTrawlSpeed.

holdsFor(trawlSpeedUpperLimit=true , I) :-
    TrawlUpperLimit = UpperTrawlSpeed.

initiatedAt(trawling(Vessel)=true, I1) :-
    holdsFor(withinFishingArea(Vessel, Region), I2),
    holdsFor(speedLimit(TrawlSpeed), I3),
    holdsFor(velocity(_, _, Speed_Vessel, _), I4),
    TrawlLowerLimit =< Speed_Vessel,
    Speed_Vessel =< TrawlUpperLimit.

initiatedAt(noTrawling(Vessel)=true, I1) :-
    ( ( \+ holdsFor(trawlSpeedLowerLimit, I2) ; \+ holdsFor(velocity(_, _, Speed_Vessel, _), I3) ;
Speed_Vessel < TrawlLowerLimit ; Speed_Vessel > TrawlUpperLimit ) ; gapInTransmission ).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, I1) :-
    holdsFor(withinFishingArea(Vessel, Region), I2),
    initiatedAt(changingHeading, I3),
    I3 < I1.

initiatedAt(leavingFishingArea(Vessel)=true, I1) :-
    \+ holdsFor(withinFishingArea(Vessel, Region), I2).

initiatedAt(noTrawlingMovement(Vessel)=true, I1) :-
    ( \+ initiatedAt(trawlingMovement(Vessel), _) ; \+ holdsFor(withinFishingArea(Vessel, Region), _) ).

initiatedAt(trawlingActivity=true, I1) :-
    holdsFor(sailingInFishingArea(Vessel), I2),
    holdsFor(speedWithinBounds(Vessel, MinTrawlSpeed, MaxTrawlSpeed), I3),
    holdsFor(sailingTypicallyForTrawling(Vessel), I4),
    I1 > I2,
    I1 > I3,
    I1 > I4.

initiatedAt(\+ trawlingActivity=true, I1) :-
    (holdsFor(\+ sailingInFishingArea(Vessel), I2); holdsFor(speedOutsideBounds(Vessel, MinTrawlSpeed,
MaxTrawlSpeed), I3); holdsFor(\+ sailingTypicallyForTrawling(Vessel), I4)),
    I1 < I2,
    I1 < I3,
    I1 < I4.

initiatedAt(temporalThresholdExceeded=true, I1) :-
    holdsFor(trawlingActivity, I2),
    I1 - I2 > MinTrawlDuration.

%-------------- anchoredOrMoored ---------------%

holdsFor(anchorageArea(Location)=true, I) :-
    withinAnchorage(_, Location, I).

holdsFor(mooringArea(Location)=true, I) :-
    withinMooring(_, Location, I).

holdsFor(idle(Vessel)=true , I):-
    holdsFor(\+ moving(Vessel), I).

holdsFor(farFromPort(Location, DistanceFromPort)=true, I) :-
    DistanceFromPort >= MinDistanceToPort,
    \+ (withinPort(_, _, _), I).

holdsFor(nearPort(Location, Port)=true, I) :-
    DistanceToPort =< MaxDistanceToPort,
    withinPort(Port, _, _).

initiatedAt(anchoredOrMoored=true, I1) :-
    (holdsFor(idle(Vessel), I2); holdsFor(\+ idle(Vessel), I2)),
    (holdsFor(farFromPort(_, Distance), I3), holdsFor(anchoredOrMoored, I1));
    (holdsFor(nearPort(_, Port), I4), holdsFor(anchoredOrMoored, I1)).

%---------------- tugging (B) ----------------%

holdsFor(tuggingSpeedLimit=true, I) :-
    LowerBound =< Speed_TuggingThreshold1,
    UpperBound >= Speed_TuggingThreshold2.

initiatedAt(withinTuggingSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_TuggingThreshold1 =< Speed_Vessel, Speed_Vessel < Speed_TuggingThreshold2.

initiatedAt(noWithinTuggingSpeed(Vessel)=true, I1) :-
    ( \+ initiatedAt(withinTuggingSpeed(Vessel), _) ; \+ initiatedAt(stopped(Vessel), _) ).

holdsFor(tugboat(Vessel)=true, I) :-
    (isTugboat(_, _, Vessel, _)).


holdsFor(otherVessel(Vessel)=true, I) :-
    \+tugboat(Vessel).

holdsFor(closeToEachOther(Vessel1, Vessel2)=true, I) :-
    distanceBetween(_, Distance, Vessel1, Vessel2, _, _) -> (Distance <= MaxDistanceTug).

holdsFor(speedWithinBounds(Vessel, MinSpeedTug, MaxSpeedTug)=true, I) :-
    holdsFor(velocity(_, _, Speed, _), I),
    (MinSpeedTug =< Speed; Speed =< MaxSpeedTug).

initiatedAt(tugging=true, I1) :-
    (holdsFor(tugboat(Vessel1), _); holdsFor(otherVessel(Vessel2), _)),
    (holdsFor(closeToEachOther(Vessel1, Vessel2), _); holdsFor(speedWithinBounds(Vessel1, MinSpeedTug, MaxSpeedTug), _)).

initiatedAt(tuggingDurationExceeded=true, I1) :-
    holdsFor(tugging, I2),
    I1 - I2 > MinTugDuration.

%-------- pilotOps ---------------------------%

holdsFor(maritimePilot(Vessel)=true, I) :-
    (isPilotBoat(_, _, Vessel, _)).

holdsFor(closeToEachOther(Vessel1, Vessel2)=true, I) :-
    distanceBetween(_, Distance, Vessel1, Vessel2, _, _) -> (Distance <= MaxDistancePilot).

holdsFor(lowSpeedOrIdle(Vessel)=true, I) :-
    (holdsFor(velocity(_, _, Speed, _), I); holdsFor(idle(Vessel), I)); Speed <= MinSpeedPilot.

holdsFor(notWithinCoastalArea(Vessel)=true, I) :-
    \+withinCoastalArea(_, _, Vessel).

initiatedAt(pilotOps=true, I1) :-
    (holdsFor(maritimePilot(Vessel1), _); holdsFor(otherVessel(Vessel2), _)),
    (holdsFor(closeToEachOther(Vessel1, Vessel2), _); holdsFor(lowSpeedOrIdle(Vessel1), _);
holdsFor(lowSpeedOrIdle(Vessel2), _); holdsFor(notWithinCoastalArea(Vessel1), _)).

%-------------------------- SAR --------------%

holdsFor(SARSpeedThreshold=true, I) :-
    MinimumSARSpeed =< Speed_SAR_Threshold.

initiatedAt(withinSARSpeed(Vessel)=true, I1) :-
    holdsFor(moving(Vessel), I2),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_Vessel >= Speed_SAR_Threshold.

initiatedAt(noWithinSARSpeed(Vessel)=true, I1) :-
    ( \+ initiatedAt(moving(Vessel), _) ; (holdsFor(moving(Vessel), _), holdsFor(velocity(_, _, Speed_Vessel,
_), I3), Speed_Vessel < Speed_SAR_Threshold) ).

initiatedAt(sarActivity=true, I1) :-
    (holdsFor(changeSpeed(Vessel), I2); holdsFor(changeHeading(Vessel), I2)).

initiatedAt(sarInactive=true, I1) :-
    (holdsFor(\+ changeSpeed(Vessel), I2); holdsFor(\+ changeHeading(Vessel), I2)),
    holdsFor(velocity(_, _, Speed_Vessel, _), I3),
    Speed_Vessel < MinimumSpeedExpectedForType.

holdsFor(SARVessel(Vessel)=true, I) :-
    (isPilotVessel(_, _, Vessel, _)).

holdsFor(typicalSARSpeed(Vessel, Speed)=true, I) :-
    (holdsFor(velocity(_, _, Speed, _), I); Speed >= MinSpeedSAR; Speed =< MaxSpeedSAR).

holdsFor(typicalSARManner(Vessel)=true, I) :-
    (maneuvering(_, _, Vessel, _)).

initiatedAt(inSAR=true, I1) :-
    (holdsFor(SARVessel(Vessel), _); holdsFor(typicalSARSpeed(Vessel, Speed), _);
holdsFor(typicalSARManner(Vessel), _)),
    I1 = initial_time.

initiatedAt(inSARContinues=true, I1) :-
    (holdsFor(SARVessel(Vessel), _); holdsFor(typicalSARSpeed(Vessel, Speed), _);
holdsFor(typicalSARManner(Vessel), _)),
    \+ends_at(inSARContinues, I2).

initiatedAt(inSAREnded=true, I1) :-
    (\+holdsFor(typicalSARSpeed(_, Speed), _); \+holdsFor(typicalSARManner(Vessel), _)),
    I1 = final_time.

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    \+isAnchored(Vessel, _); \+isMoorred(Vessel, _).

holdsFor(lowSpeed(Vessel, Speed)=true, I) :-
    (Speed =< MinSpeedLoitering; Speed = 0).

holdsFor(farFromPorts(Vessel)=true, I) :-
    \+nearAnyPort(Vessel, _).

holdsFor(notNearCoast(Vessel)=true, I) :-
    \+nearCoast(Vessel, _).

holdsFor(loiteringTimeThreshold(I1, I2)=true, I) :-
    (I2 - I1) >= MinLoiteringTime.

initiatedAt(loitering=true, I1) :-
    (holdsFor(lowSpeed(_, Speed), _); holdsFor(farFromPorts(Vessel), _); 

holdsFor(notNearCoast(Vessel), _)),
    \+isAnchored(_, _); \+isMoorred(_, _),
    loiteringTimeThreshold(Istart, I1).

initiatedAt(loiteringContinues=true , I1):-
    (holdsFor(lowSpeed(_, Speed), _); holdsFor(farFromPorts(Vessel), _); holdsFor(notNearCoast(Vessel), _)),
    \+isAnchored(_, _); \+isMoorred(_, _),
    loiteringTimeThreshold(Istart, I1),
    \+ends_at(loiteringContinues, I2).

initiatedAt(loiteringEnded=true, I1) :-
    \+holdsFor(lowSpeed(_, Speed), _); \+holdsFor(farFromPorts(Vessel), _); \+holdsFor(notNearCoast(Vessel), _),
    \+isAnchored(_, _); \+isMoorred(_, _),
    I1 = final_time.