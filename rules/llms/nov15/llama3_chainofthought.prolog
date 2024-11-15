%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel)=true, T) :-
    not happensAt(receivesMessage(Vessel), T).

terminatedAt(communicationGap(Vessel)=true, T) :-
    happensAt(startsSendingMessages(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(Lowspeed(Vessel)=true, T) :-
    happensAt(startsMovingLowSpeed(Vessel), T).

terminatedAt(Lowspeed(Vessel)_Status, T) :-
    happensAt(stopsMovingLowSpeed(Vessel), T) |
happensAt(start(gap(Vessel)), T).

%-------------- changingSpeed ----------------%

initiatedAt(Changingspeed(Vessel)=true, T) :-
    happensAt(startsChangingSpeed(Vessel), T).

terminatedAt(Changingspeed(Vessel)_Status, T) :-
    happensAt(stopsChangingSpeed(Vessel), T) |
happensAt(start(gap(Vessel)), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(HighSpeedNearCoast(Vessel)=true, T) :-
    happensAt(increasesVelocity(Vessel), T),
    not holdsAt(speedThreshold(_Threshold) < _Threshold, T),
    holdsAt(withinArea(Vessel, nearCoast), T).

terminatedAt(HighSpeedNearCoast(Vessel)=_Status, T) :-
    happensAt(decreasesVelocity(Vessel), T) |
happensAt(start(gap(Vessel)), T).

%--------------- movingSpeed -----------------%

initiatedAt(MovingSpeed(Vessel)=true, T) :-
    (holdsAt(speed(Vessel) < lowThreshold, T) ; holdsAt(speed(Vessel)
= normalThreshold, T) ; holdsAt(speed(Vessel) > highThreshold, T)).

terminatedAt(MovingSpeed(Vessel)_Status, T) :-
    (holdsAt(speed(Vessel) < lowThreshold, T) ;
happensAt(start(gap(Vessel)), T)).

%----------------- drifitng ------------------%

initiatedAt(Drifting(Vessel)=true, T) :-
    holdsAt(course(Vessel) > driftThreshold, T),
    velocityGreaterThanZero(Vessel, T).

terminatedAt(Drifting(Vessel)=false, T) :-
    (holdsAt(course(Vessel) <= driftThreshold, T) ;
happensAt(underway(Vessel), T)).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(increasesVelocity(Vessel), T),
    not holdsAt(speed(Vessel) < speedMinThreshold, T),
    not holdsAt(speed(Vessel) > speedMaxThreshold, T),
    holdsAt(withinArea(Vessel), T).

terminatedAt(trawlSpeed(Vessel)=_Status, T) :-
    happensAt(decreasesVelocity(Vessel), T) | (speed(Vessel) <
speedMinThreshold; speed(Vessel) > speedMaxThreshold) |
    happensAt(start(gap(Vessel)), T) | not holdsAt(withinArea(Vessel),
T).

%--------------- trawling --------------------%

initiatedAt(Trawling(Vessel)=true, T) :-
    happensAt(changesHeading(Vessel), T),
    holdsAt(withinArea(Vessel), T).

terminatedAt(Trawling(Vessel)_Status, T) :-
    not holdsAt(withinArea(Vessel), T).

holdsFor(trawling(Vessel)=true, T) :-
    holdsAt(velocityGreaterThanZero(Vessel), T),
    holdsAt(course(Vessel) > trawlingThreshold, T).

%-------------- anchoredOrMoored ---------------%

initiatedAt(AnchoredOrMoored(Vessel)=true, T) :-
    (holdsAt(isIdleFarFromPorts(Vessel), T) ;
holdsAt(withinArea(Vessel), T) ; holdsAt(nearPorts(Vessel), T)).

terminatedAt(AnchoredOrMoored(Vessel)_Status, T) :-
    not (holdsAt(isIdleFarFromPorts(Vessel), T) ;
holdsAt(withinArea(Vessel), T) ; holdsAt(nearPorts(Vessel), T)).

holdsFor(anchoredOrMoored(Vessel)=true, T) :-
    (holdsAt(anchored(Vessel), T) ; holdsAt(moored(Vessel), T)).

%---------------- tugging (B) ----------------%

initiatedAt(Tugging(Vessel)=true, T) :-
    holdsAt(speed(Vessel) >= minTuggingSpeed, T),
    holdsAt(speed(Vessel) <= maxTuggingSpeed, T).

terminatedAt(Tugging(Vessel)_Status, T) :-
    (not (holdsAt(speed(Vessel) >= minTuggingSpeed, T),
holdsAt(speed(Vessel) <= maxTuggingSpeed, T)) ;
happensAt(start(gap(Vessel)), T)).

initiatedAt(CloseToEachOther(Vessel1, Vessel2)=true, T) :-
    initiatedAt(Tugging(Vessel1)=true, T),
    initiatedAt(Tugging(Vessel2)=true, T).

initiatedAt(TuggingSpeed(Vessel)=true, T) :-
    initiatedAt(Tugging(Vessel)=true, T).

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    happensAt(approachesPilotBoat(Vessel1), T),
    boardsWithPilotBoat(Vessel1, Vessel2, T),
    manoeuvresVessel(Vessel2, T).

initiatedAt(CloseToEachOther(Vessel1, Vessel2)=true, T) :-
    initiatedAt(pilotOps(Vessel1, Vessel2)=true, T).

initiatedAt(IsPilot(Vessel1)=true, T) :-
    initiatedAt(pilotOps(Vessel1, Vessel2)=true, T),
    Vessel1 = Vessel2.

initiatedAt(LowSpeed(Vessel1, Vessel2)=true, T) :-
    initiatedAt(pilotOps(Vessel1, Vessel2)=true, T).

initiatedAt(IdelFarFromPorts(Vessel1, Vessel2)=true, T) :-
    initiatedAt(pilotOps(Vessel1, Vessel2)=true, T),
    (holdsAt(farFromPorts(Vessel1), T) ;
holdsAt(farFromPorts(Vessel2), T)).

initiatedAt(WithinAreaNearCoast(Vessel1, Vessel2)=true, T) :-
    initiatedAt(pilotOps(Vessel1, Vessel2)=true, T),
    (holdsAt(withinAreaNearCoast(Vessel1), T) ;
holdsAt(withinAreaNearCoast(Vessel2), T)).

holdsFor(pilotOps(Vessel)=true, T) :-
    holdsAt(courseDiff(Vessel,PilotVessel) < pilotOpsThreshold, T),
    velocityGreaterThanZero(Vessel, T).

%-------------------------- SAR --------------%

initiatedAt(SAR(Vessel)=true, T) :-
    holdsAt(speed(Vessel) < sarSpeedThreshold, T).

terminatedAt(SAR(Vessel)_Status, T) :-
    (holdsAt(speed(Vessel) >= sarSpeedThreshold, T) ;
happensAt(startsCommunicationGap, T)).

initiatedAt(sarMovement(Vessel)=true, T) :-
    (happensAt(changesSpeed(Vessel), T) ; happensAt(
changesHeading(Vessel), T)).

terminatedAt(sarMovement(Vessel)_Status, T) :-
    happensAt(startsCommunicationGap, T).

holdsFor(SAR(Vessel)=true, T) :-
    holdsAt(speed(Vessel) < sarSpeedThreshold, T).

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel)=true, T) :-
    (holdsAt(speed(Vessel) < lowSpeedThreshold, T) ;
holdsAt(isIdleFarFromPorts(Vessel), T) ;
     holdsAt(nearCoast(Vessel), T) ; holdsAt(anchoredOrMoored(Vessel),
T)).

terminatedAt(loitering(Vessel)_Status, T) :-
    not (holdsAt(speed(Vessel) < lowSpeedThreshold, T) ;
holdsAt(isIdleFarFromPorts(Vessel), T) ;
     holdsAt(nearCoast(Vessel), T) ; holdsAt(anchoredOrMoored(Vessel),
T)).

holdsFor(loitering(Vessel)=true, T) :-
    (holdsAt(speed(Vessel) < lowSpeedThreshold, T) ;
     holdsAt(isIdleFarFromPorts(Vessel), T) ;
     holdsAt(nearCoast(Vessel), T)).