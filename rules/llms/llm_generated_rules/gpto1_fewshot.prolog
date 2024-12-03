%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_Status, T) :-
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
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, AreaID), T),
    areaType(AreaID, nearCoast),
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, nearCoast).

%--------------- movingSpeed -----------------%

initiatedAt(currentSpeed(Vessel)=Speed, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T).

terminatedAt(currentSpeed(Vessel)=_, T) :-
    happensAt(velocity(Vessel, _, _, _), T).

initiatedAt(movingSpeed(Vessel)=below, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, _, _),
    Speed >= MovingMin,
    Speed < MinSpeed.

initiatedAt(movingSpeed(Vessel)=normal, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, MaxSpeed, _),
    Speed >= MinSpeed,
    Speed =< MaxSpeed.

initiatedAt(movingSpeed(Vessel)=above, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _, MaxSpeed, _),
    Speed > MaxSpeed.

terminatedAt(movingSpeed(Vessel)=below, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, _, _),
    Speed < MovingMin.
terminatedAt(movingSpeed(Vessel)=below, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, _, _),
    Speed >= MinSpeed.

terminatedAt(movingSpeed(Vessel)=normal, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, MaxSpeed, _),
    Speed < MinSpeed.
terminatedAt(movingSpeed(Vessel)=normal, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, MaxSpeed, _),
    Speed > MaxSpeed.

terminatedAt(movingSpeed(Vessel)=above, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, _, MaxSpeed, _),
    Speed < MovingMin.
terminatedAt(movingSpeed(Vessel)=above, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, _, MaxSpeed, _),
    Speed =< MaxSpeed.

terminatedAt(movingSpeed(Vessel)=_, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(movingSpeed(Vessel)=_, T) :-
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

%----------------- drifitng ------------------%

initiatedAt(currentAngleDifference(Vessel)=Difference, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    Difference1 is abs(CourseOverGround - TrueHeading),
    Difference2 is 360 - Difference1,
    DifferenceAngle is min(Difference1, Difference2),
    Difference = DifferenceAngle.

terminatedAt(currentAngleDifference(Vessel)=_, T) :-
    happensAt(velocity(Vessel, _, _, _), T).

initiatedAt(drifting(Vessel)=true, T) :-
    holdsAt(currentAngleDifference(Vessel)=Difference, T),
    thresholds(adriftAngThr, AdriftAngThr),
    Difference > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(currentAngleDifference(Vessel)=Difference, T),
    thresholds(adriftAngThr, AdriftAngThr),
    Difference =< AdriftAngThr.

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

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, AreaID), T),
    areaType(AreaID, fishingArea),
    holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed < TrawlspeedMin.
terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishingArea).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishingArea).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlSpeed(Vessel)=true, I1),
    holdsFor(trawlingMovement(Vessel)=true, I2),
    holdsFor(withinArea(Vessel, fishingArea)=true, I3),
    intersect_all([I1, I2, I3], I_temp),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(I_temp, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

holdsFor(stopped(Vessel)=true, I_stop) :-
    holdsFor(stopped(Vessel), I_stop).

holdsFor(withinArea(Vessel, anchorageArea)=true, I_anchorage) :-
    holdsFor(withinArea(Vessel, anchorageArea)=true, I_anchorage).

holdsFor(withinArea(Vessel, nearPorts)=true, I_nearPorts) :-
    holdsFor(withinArea(Vessel, nearPorts)=true, I_nearPorts).

intersect_all([I_stop, I_anchorage], I_stoppedAnchorage).

relative_complement_all(I_stoppedAnchorage, [I_nearPorts], I_anchoredFarFromPorts).

intersect_all([I_stop, I_nearPorts], I_mooredNearPorts).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    union_all([I_anchoredFarFromPorts, I_mooredNearPorts], I).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed < TuggingMin.
terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, I_proximity),
    holdsFor(tuggingSpeed(Vessel1)=true, I_speed1),
    holdsFor(tuggingSpeed(Vessel2)=true, I_speed2),
    intersect_all([I_proximity, I_speed1, I_speed2], I_temp),
    oneIsTug(Vessel1, Vessel2),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(I_temp, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, I_proximity),
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeedOrStoppedFar(Vessel1)=true, I_movement1),
    holdsFor(lowSpeedOrStoppedFar(Vessel2)=true, I_movement2),
    intersect_all([I_proximity, I_movement1, I_movement2], I_temp),
    holdsFor(withinArea(Vessel1, nearCoast)=true, I_nearCoast1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, I_nearCoast2),
    relative_complement_all(I_temp, [I_nearCoast1, I_nearCoast2], I).

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

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    vesselType(Vessel, pilotVessel),
    holdsFor(sarSpeed(Vessel)=true, I1),
    holdsFor(sarMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I).

%-------- loitering --------------------------%

holdsFor(lowSpeedOrStoppedFar(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I_lowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, I_stoppedFar),
    union_all([I_lowSpeed, I_stoppedFar], I).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeedOrStoppedFar(Vessel)=true, I1),
    holdsFor(anchoredOrMoored(Vessel)=true, I_anchorMoored),
    holdsFor(withinArea(Vessel, nearCoast)=true, I_nearCoast),
    relative_complement_all(I1, [I_anchorMoored, I_nearCoast], I_temp),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_temp, LoiteringTime, I).
