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
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, AreaID), T),
    areaType(AreaID, nearCoast),
    holdsAt(speed_over_ground(Vessel)=Speed, T),
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

initiatedAt(movingSpeed(Vessel)=below, T) :-
    holdsAt(speed_over_ground(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, Min, _, _),
    Speed >= MovingMin,
    Speed < Min.

initiatedAt(movingSpeed(Vessel)=normal, T) :-
    holdsAt(speed_over_ground(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _),
    Speed >= Min,
    Speed =< Max.

initiatedAt(movingSpeed(Vessel)=above, T) :-
    holdsAt(speed_over_ground(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _, Max, _),
    Speed > Max.

terminatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, Min, _, _),
    Speed >= Min.     % Speed no longer less than Min
terminatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, Min, _, _),
    Speed < MovingMin.  % Speed falls below MovingMin

terminatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, Min, Max, _),
    Speed < Min.
terminatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, Min, Max, _),
    Speed > Max.
terminatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, Min, Max, _),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, _, Max, _),
    Speed =< Max.
terminatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    thresholds(movingMin, MovingMin),
    typeSpeed(Type, _, Max, _),
    Speed < MovingMin.
    
terminatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    holdsAt(angle_difference(Vessel)=AngleDiff, T),
    thresholds(angleThreshold, AngleThreshold),
    AngleDiff > AngleThreshold,
    holdsAt(stopped(Vessel)=false, T).

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(angle_difference(Vessel)=AngleDiff, T),
    thresholds(angleThreshold, AngleThreshold),
    AngleDiff =< AngleThreshold.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(stopped(Vessel)=true, T).

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, AreaID), T),
    areaType(AreaID, fishingArea),
    holdsAt(speed_over_ground(Vessel)=Speed, T),
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
    intersect_all([I1, I2], I_temp),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(I_temp, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, IsFarFromPorts),
    holdsFor(withinArea(Vessel, anchorageArea)=true, Ia),
    intersect_all([IsFarFromPorts, Ia], I1),
    holdsFor(stopped(Vessel)=nearPorts, I2),
    union_all([I1, I2], I_temp),
    holdsFor(gap(Vessel)=true, Ig),
    relative_complement_all(I_temp, [Ig], I).

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

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(tuggingSpeed(Vessel1)=true, Is1),
    holdsFor(tuggingSpeed(Vessel2)=true, Is2),
    ( vesselType(Vessel1, tugboat) ; vesselType(Vessel2, tugboat) ),
    intersect_all([Ip, Is1, Is2], I_temp),
    holdsFor(gap(Vessel1)=true, Ig1),
    holdsFor(gap(Vessel2)=true, Ig2),
    union_all([Ig1, Ig2], Ig),
    relative_complement_all(I_temp, [Ig], I_no_gap),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(I_no_gap, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    ( vesselType(Vessel1, pilotVessel) ; vesselType(Vessel2, pilotVessel) ),
    holdsFor(lowSpeedOrIdleFarFromPorts(Vessel1)=true, I1),
    holdsFor(lowSpeedOrIdleFarFromPorts(Vessel2)=true, I2),
    holdsFor(notWithinArea(Vessel1, coastalArea)=true, In1),
    holdsFor(notWithinArea(Vessel2, coastalArea)=true, In2),
    intersect_all([Ip, I1, I2, In1, In2], I_temp),
    holdsFor(gap(Vessel1)=true, Ig1),
    holdsFor(gap(Vessel2)=true, Ig2),
    union_all([Ig1, Ig2], Ig),
    relative_complement_all(I_temp, [Ig], I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed > SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed =< SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(sarMovement(Vessel)=true, I) :-
    holdsFor(changingSpeed(Vessel)=true, Is),
    holdsFor(changingHeading(Vessel)=true, Ih),
    union_all([Is, Ih], I_temp),
    holdsFor(gap(Vessel)=true, Ig),
    relative_complement_all(I_temp, [Ig], I).

holdsFor(inSAR(Vessel)=true, I) :-
    vesselType(Vessel, pilotVessel),
    holdsFor(pilotSarSpeed(Vessel)=true, Is),
    holdsFor(sarMovement(Vessel)=true, Im),
    intersect_all([Is, Im], I_temp),
    holdsFor(gap(Vessel)=true, Ig),
    relative_complement_all(I_temp, [Ig], I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeedOrIdleFarFromPorts(Vessel)=true, I1),
    holdsFor(notNearCoast(Vessel)=true, I2),
    holdsFor(notAnchoredOrMoored(Vessel)=true, I3),
    intersect_all([I1, I2, I3], I_temp),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_temp, LoiteringTime, I).
