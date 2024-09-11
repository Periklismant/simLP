%----------------within area -----------------%

initiatedAt(withinArea(Vessel, Area, AreaType) = true, T) :-
    happensAt(enterArea(Vessel, Area, AreaType), T).

terminatedAt(withinArea(Vessel, Area, AreaType) = true, T) :-
    happensAt(leaveArea(Vessel, Area, AreaType), T).


%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel) = true, T) :-
    lastMessage(Vessel, LastMsgTime),
    T is LastMsgTime + 30,  % Time is in minutes
    not(happensAt(receiveMessage(Vessel), Time), LastMsgTime < Time, Time =< T).

terminatedAt(communicationGap(Vessel) = true, T) :-
    happensAt(receiveMessage(Vessel), T).


%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    holdsAt(nearCoast(Vessel) = true, T),
    Speed > 5.

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    Speed =< 5.

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    not holdsAt(nearCoast(Vessel) = true, T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, CoG, TrueHeading), T),
    holdsAt(operationalStatus(Vessel) = normal, T),
    abs(TrueHeading - CoG) > DriftThreshold.

terminatedAt(drifting(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, CoG, TrueHeading), T),
    abs(TrueHeading - CoG) =< DriftThreshold.


%--------------- trawling --------------------%

initiatedAt(trawling(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, CoG, TrueHeading), T),
    holdsAt(operationalStatus(Vessel) = fishing, T),
    trawlingSpeedRange(Speed),
    highHeadingVariability(Vessel, TrueHeading, T).

terminatedAt(trawling(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    not trawlingSpeedRange(Speed).

terminatedAt(trawling(Vessel) = true, T) :-
    happensAt(operationChange(Vessel, Operation), T),
    Operation \= fishing.

holdsFor(trawling(Vessel) = true, Intervals) :-
    holdsFor(trawlingSpeed(Vessel) = true, SpeedIntervals),
    holdsFor(wideHeadingVariability(Vessel) = true, HeadingIntervals),
    intersect_all([SpeedIntervals, HeadingIntervals], Intervals).

holdsFor(trawlingSpeed(Vessel) = true, SpeedIntervals) :-
    velocitySamples(Vessel, SpeedSamples),
    findall((Tstart, Tend), (member((Speed, Tstart, Tend), SpeedSamples), Speed >= MinTrawlingSpeed, Speed =< MaxTrawlingSpeed), SpeedIntervals).

holdsFor(wideHeadingVariability(Vessel) = true, HeadingIntervals) :-
    headingSamples(Vessel, HeadingSamples),
    findall((Tstart, Tend), (member((Heading, Tstart, Tend), HeadingSamples), isWideVariability(Heading)), HeadingIntervals).


%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, Intervals) :-
    holdsFor(nearFixedPoint(Vessel) = true, FixedIntervals),
    holdsFor(lowSpeed(Vessel) = true, SpeedIntervals),
    intersect_all([FixedIntervals, SpeedIntervals], Intervals).

holdsFor(lowSpeed(Vessel) = true, SpeedIntervals) :-
    velocitySamples(Vessel, SpeedSamples),
    findall((Tstart, Tend), (member((Speed, Tstart, Tend), SpeedSamples), Speed =< AnchoringSpeedThreshold), SpeedIntervals).


%---------------- tugging (B) ----------------%

holdsFor(tugging(Tug, Vessel) = true, Intervals) :-
    holdsFor(closeProximity(Tug, Vessel) = true, CloseIntervals),
    holdsFor(lowSpeed(Tug) = true, TugSpeedIntervals),
    holdsFor(lowSpeed(Vessel) = true, VesselSpeedIntervals),
    intersect_all([CloseIntervals, TugSpeedIntervals, VesselSpeedIntervals], Intervals).

holdsFor(closeProximity(Tug, Vessel) = true, CloseIntervals) :-
    proximitySamples(Tug, Vessel, ProximitySamples),
    findall((Tstart, Tend), (member((Distance, Tstart, Tend), ProximitySamples), Distance =< SafetyDistanceThreshold), CloseIntervals).

holdsFor(lowSpeed(Tug) = true, TugSpeedIntervals) :-
          velocitySamples(Tug, TugSpeedSamples),
          findall((Tstart, Tend), (member((Speed, Tstart, Tend), TugSpeedSamples), Speed =< TuggingSpeedThreshold), TugSpeedIntervals).

holdsFor(lowSpeed(Vessel) = true, VesselSpeedIntervals) :-
    velocitySamples(Vessel, VesselSpeedSamples),
    findall((Tstart, Tend), (member((Speed, Tstart, Tend), VesselSpeedSamples), Speed =< TuggingSpeedThreshold), VesselSpeedIntervals).



%-------- pilotOps ---------------------------%

holdsFor(piloting(PilotBoat, Vessel) = true, Intervals) :-
    holdsFor(closeProximity(PilotBoat, Vessel) = true, ProximityIntervals),
    holdsFor(transferOfPilot(PilotBoat, Vessel) = true, TransferIntervals),
    intersect_all([ProximityIntervals, TransferIntervals], Intervals).

holdsFor(closeProximity(PilotBoat, Vessel) = true, CloseIntervals) :-
    proximitySamples(PilotBoat, Vessel, ProximitySamples),
    findall((Tstart, Tend), (member((Distance, Tstart, Tend), ProximitySamples), Distance =< PilotTransferDistanceThreshold), CloseIntervals).

holdsFor(transferOfPilot(PilotBoat, Vessel) = true, TransferIntervals) :-
    operationalEvents(PilotBoat, Vessel, EventSamples),
    findall((Tstart, Tend), (member((Event, Tstart, Tend), EventSamples), Event == 'pilotTransfer'), TransferIntervals).

%---------------- rendezVous -----------------%

holdsFor(rendezVous(Vessel1, Vessel2) = true, Intervals) :-
    holdsFor(closeProximity(Vessel1, Vessel2) = true, ProximityIntervals),
    holdsFor(lowSpeedOrStopped(Vessel1) = true, SpeedIntervals1),
    holdsFor(lowSpeedOrStopped(Vessel2) = true, SpeedIntervals2),
    intersect_all([ProximityIntervals, SpeedIntervals1, SpeedIntervals2], Intervals).

holdsFor(closeProximity(Vessel1, Vessel2) = true, CloseIntervals) :-
    proximitySamples(Vessel1, Vessel2, ProximitySamples),
    findall((Tstart, Tend), (member((Distance, Tstart, Tend), ProximitySamples), Distance =< RendezVousDistanceThreshold), CloseIntervals).

holdsFor(lowSpeedOrStopped(Vessel) = true, SpeedIntervals) :-
    velocitySamples(Vessel, SpeedSamples),
    findall((Tstart, Tend), (member((Speed, Tstart, Tend), SpeedSamples), Speed =< LowSpeedThreshold), SpeedIntervals).


%-------- loitering --------------------------%


holdsFor(loitering(Vessel) = true, Intervals) :-
    holdsFor(inArea(Vessel, Area) = true, AreaIntervals),
    duration(AreaIntervals, Duration),
    Duration > LoiteringThreshold.

holdsFor(inArea(Vessel, Area) = true, AreaIntervals) :-
    positionSamples(Vessel, PositionSamples),
    findall((Tstart, Tend), (member((Position, Tstart, Tend), PositionSamples), withinArea(Position, Area)), AreaIntervals).
