%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T),
    \+ holdsAt(wasTransmitting(Vessel)=true, T).

terminatedAt(gap(Vessel)=true, T) :-
    happensAt(gap_end(Vessel), T),
    holdsAt(wasTransmitting(Vessel)=true, T).

initiatedAt(gap(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T),
    \+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

holdsAt(wasTransmitting(Vessel)=true, T) :-
    happensAt(gap_end(Vessel), T).

holdsAt(wasTransmitting(Vessel)=false, T) :-
    happensAt(gap_start(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T),
    holdsAt(movingSpeed(Vessel)=low, T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T),
    \+ holdsAt(movingSpeed(Vessel)=low, T).

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
    threshold(coastalSpeedLimit, CoastalSpeedLimit),
    Speed > CoastalSpeedLimit.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    threshold(coastalSpeedLimit, CoastalSpeedLimit),
    Speed < CoastalSpeedLimit.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, _), T),
    \+ holdsAt(withinArea(Vessel, nearCoast)=true, T).

%--------------- movingSpeed -----------------%

holdsFor(movingSpeed(Vessel)=below, I) :-
    union_all([I1, I2], I),
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(normalSpeed(Vessel)=true, I2).

holdsFor(movingSpeed(Vessel)=normal, I) :-
    union_all([I1, I2], I),
    holdsFor(normalSpeed(Vessel)=true, I1),
    holdsFor(normalSpeed(Vessel)=true, I2).

holdsFor(movingSpeed(Vessel)=above, I) :-
    union_all([I1, I2], I),
    holdsFor(highSpeed(Vessel)=true, I1),
    holdsFor(highSpeed(Vessel)=true, I2).

%----------------- drifitng ------------------%

holdsFor(drifting(Vessel)=true, I) :-
    happensAt(angleDiff(Vessel, _ , Angle)> driftAngThr, T),
    thresholds(driftAngThr, float(DriftAngThr)),
    \+ holdsAt(angleDiff(Vessel, _ , Angle) < DriftAngThr, T),
    holdsFor(movingSpeed(Vessel, Speed)=true, Is),
    Speed > 0,
    thresholds(driftingTime, DriftingTime),
    intDurGreater(I, DriftingTime, I).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, _, _), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    typeSpeed(tawling, TrawlingMin, TrawlingMax),
    TrawlingMin =< _Speed,
    Speed =< TrawlingMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, _, _), T),
    typeSpeed(tawling, TrawlingMin, TrawlingMax),
    \+ (TrawlingMin =< _Speed, Speed =< TrawlingMax).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, _), T),
    \+ holdsAt(withinArea(Vessel, fishingArea)=true, T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, FishingArea)=true, Ip),
    typeSpeed(trawling, trawlspeedMin, trawlspeedMax, trawlspeedAvg),
    holdsFor(speed(Vessel, Speed)=true, Is),
    Speed >= trawlspeedMin, Speed =< trawlspeedMax,
    holdsFor(typeSpeed(trawling, _, _, trawlspeedAvg)=true, It),
    union_all([Ip, Is, It], Ii),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(Ii, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, If),
    intersects_all([If, holdsAt(withinArea(Vessel, farFromPorts)=true, T)], I1),
    I1 \= [],
    holdsFor(stopped(Vessel)=nearPorts, In),
    intersects_all([In, holdsAt(withinArea(Vessel, nearPorts)=true, T)], I2),
    I2 \= [],
    union_all([I1, I2], I),
    holdsFor(stopped(Vessel)=farFromPorts=I1, If1),
    terminatedAt(stopped(Vessel)=farFromPorts, T1),
    happensAt(stop_end(Vessel), T1),
    holdsFor(stopped(Vessel)=nearPorts=I2, If2),
    terminatedAt(stopped(Vessel)=nearPorts, T2),
    happensAt(stop_end(Vessel), T2).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    typeSpeed(tugging, TuggingMin, TuggingMax),
    TuggingMin =< Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    typeSpeed(tugging, TuggingMin, TuggingMax),
    \+ (TuggingMin =< Speed =< TuggingMax).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel)=true, I) :-
    happensAt(change_in_speed_start(Vessel), T),
    happensAt(change_in_speed_end(Vessel), T2),
    interval(I, T, T2),
    proximity(Vessel, Tugboat)=true,
    typeSpeed(tugging, tuggingMin, tuggingMax, _),
    holdsFor(speed(Vessel, Speed)=true, Is),
    Speed >= tuggingMin, Speed =< tuggingMax,
    union_all([Is], Ii),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(Ii, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel)=true, I) :-
    happensAt(assignment(Vessel, PilotVessel), T),
    proximity(Vessel, PilotVessel)=true,
    lowSpeed(Vessel)=true, stopped(Vessel)=farFromPorts,
    \+ holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(pilotOpsTime, PilotOpsTime),
    intDurGreater(I, PilotOpsTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    threshold(sarMinSpeed, SarMinSpeed),
    Speed > SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    threshold(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(sarMovement(Vessel)=true, I) :-
    happensAt(change_in_speed_start(Vessel), T),
    typeSpeed(sarMovement, sarMinSpeed, sarMaxSpeed, sarAvgSpeed),
    holdsFor(speed(Vessel, Speed)=true, Is),
    Speed >= sarMinSpeed, Speed =< sarMaxSpeed,
    holdsFor(typeSpeed(sarMovement, _ , _, sarAvgSpeed)=true, It),
    union_all([Is, It], Ii),
    \+ happensAt(gap_start(Vessel), T),
    thresholds(sarMovementTime, SarMovementTime),
    intDurGreater(Ii, SarMovementTime, I).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(typeSpeed(sar, SarMinSpeed, SarMaxSpeed, _), I),
    holdsFor(movingSpeed(Vessel)=SarMinSpeed, I),
    holdsFor(movingDirection(Vessel)=SarDirection, I),
    threshold(sarMinSpeed, SarMinSpeed, I),
    threshold(sarDirThr, SarDirThr, I),
    intersect_all([I1, I2, I3], I),
    thresholds(sarSpeedMin, SarSpeedMin),
    intDurGreater(I, SarSpeedMin, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(movingSpeed(Vessel)=low, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    \+ holdsAt(withinArea(Vessel, nearCoast)=true, T),
    \+ holdsAt(anchored(Vessel)=true, T),
    \+ holdsAt(moored(Vessel)=true, T),
    threshold(loiteringTime, LoiteringTime),
    intDurGreater(I, LoiteringTime, Ia),
    holdsFor(proximity(Vessel, _) = true, Ii),
    relative_complement_all([Ii], [Ia], I),
    intersects_all([I1, I2], I3),
    union_all([I3, Ia], I).
