%----------------within area -----------------%

withinAreaOfInteres(Vessel, AreaType, AreaID) :-
    entersArea(Vessel, AreaID), areaType(AreaID, AreaType), not leavesArea(Vessel, AreaID).

withinAreaOfInterest(Vessel, AreaType, AreaID) :-
    leavesArea(Vessel, AreaID), areaType(AreaID, AreaType), not entersArea(Vessel, AreaID).


%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel), T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(communicationGap(Vessel), T) :-
    happensAt(gap_end(Vessel), T).


%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel), T) :-
    happensAt(speed(Vessel, Speed), T),
    holdsAt(withinArea(Vessel, nearCoast), T),
    Speed > 5.

terminatedAt(highSpeedNearCoast(Vessel), T) :-
    happensAt(speed(Vessel, Speed), T),
    not holdsAt(withinArea(Vessel, nearCoast), T),
    Speed > 5.


%----------------- drifitng ------------------%

initiatedAt(driftingVessel(Vessel), T) :-
    happensAt(courseOverGround(Vessel, COG), T),
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),
    Speed > 0,
    threshold(cogThreshold, COGThreshold),
    abs(COG - COGThreshold) > driftThreshold.

terminatedAt(driftingVessel(Vessel), T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),
    Speed = 0.


%--------------- trawling --------------------%

initiatedAt(trawling(Vessel), T) :-
    happensAt(speed(Vessel, Speed), T),
    happensAt(headingAngle(Vessel, Angle), T),
    Speed >= minTrawlingSpeed,
    angleDistribution(Angle).

terminatedAt(trawling(Vessel), T) :-
    happensAt(stopTrawling(Vessel), T).

holdsFor(trawling(Vessel) = true, I) :-
    holdsFor(trawlerSpeed(Vessel) = true, I1),
    holdsFor(wideHeadingAngle(Vessel) = true, I2),
    intersect_all([I1, I2], I).


%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) :-
    holdsFor(anchorLowered(Vessel) = true, I1),
    holdsFor(vesselMoored(Vessel) = true, I2),
    union_all([I1, I2], I).

holdsFor(anchoredOrMoored(Vessel) = false, I) :-
    holdsFor(anchorRaised(Vessel) = true, I1),
    holdsFor(vesselUnmoored(Vessel) = true, I2),
    union_all([I1, I2], I).


%---------------- tugging (B) ----------------%

holdsFor(tugging(Vessel) = true, I) :-
    holdsFor(closeToTugBoat(Vessel) = true, I1),
    holdsFor(lowSpeed(Vessel) = true, I2),
    intersect_all([I1, I2], I).


%-------- pilotOps ---------------------------%

holdsFor(piloting(Vessel) = true, I) :-
    holdsFor(closeToPilotBoat(Vessel) = true, I1),
    holdsFor(experiencedSailorOnBoard(Vessel) = true, I2),
    intersect_all([I1, I2], I).


%---------------- rendezVous -----------------%

holdsFor(vesselRendezVous(Vessel1, Vessel2) = true, I) :-
    holdsFor(nearby(Vessel1, Vessel2) = true, I1),
    holdsFor(stoppedOrLowSpeed(Vessel1) = true, I2),
    holdsFor(stoppedOrLowSpeed(Vessel2) = true, I3),
    intersect_all([I1, I2, I3], I).


%-------- loitering --------------------------%


holdsFor(loitering(Vessel) = true, I) :-
    holdsFor(inAreaForLongPeriod(Vessel) = true, I1),
    holdsFor(noEvidentPurpose(Vessel) = true, I2),
    intersect_all([I1, I2], I).
