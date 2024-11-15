%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(communicationGap(Vessel)=true, T) :-
    happensAt(gap_end(Vessel), T).

terminatedAt(communicationGap(Vessel)=true, T) :-
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(communicationGap(Vessel)=true, T) :-
    holdsAt(withinArea(Vessel, farFromPorts)=true, T).

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
    happensAt(change_in_speed_start(Vessel), T),
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    not holdsAt(withinArea(Vessel, nearCoast)=true, T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel)=true, T) :-
    holdsAt(movingSpeed(Vessel)=below, T).

initiatedAt(movingSpeed(Vessel)=true, T) :-
    holdsAt(movingSpeed(Vessel)=normal, T).

initiatedAt(movingSpeed(Vessel)=true, T) :-
    holdsAt(movingSpeed(Vessel)=above, T).

terminatedAt(movingSpeed(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(underWay(Vessel)=true, T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax,
    holdsAt(withinArea(Vessel, AreaType)=true, T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    Speed < TrawlspeedMin.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    not holdsAt(withinArea(Vessel, AreaType)=true, T).

%--------------- trawling --------------------%

initiatedAt(trawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    holdsAt(trawlSpeed(Vessel)=true, T),
    holdsAt(trawlingMovement(Vessel)=true, T).

terminatedAt(trawling(Vessel)=true, T) :-
    not holdsAt(withinArea(Vessel, AreaType)=true, T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(change_in_heading(Vessel)=true, Ih),
    holdsFor(withinArea(Vessel, AreaType)=true, Ia),
    holdsFor(trawlSpeed(Vessel)=true, Its),
    holdsFor(trawlingMovement(Vessel)=true, Itm),
    intersect_all([Ih, Ia, Its, Itm], I).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    holdsAt(stopped(Vessel)=true, T),
    (holdsAt(withinArea(Vessel, farFromPorts)=true, T);
     holdsAt(withinArea(Vessel, anchorage)=true, T);
     holdsAt(withinArea(Vessel, nearPorts)=true, T)).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    not holdsAt(stopped(Vessel)=true, T);
    (not holdsAt(withinArea(Vessel, farFromPorts)=true, T),
     not holdsAt(withinArea(Vessel, anchorage)=true, T),
     not holdsAt(withinArea(Vessel, nearPorts)=true, T)).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=true, Is),
    holdsFor(withinArea(Vessel, farFromPorts)=true, Ifp),
    holdsFor(withinArea(Vessel, anchorage)=true, Ia),
    holdsFor(withinArea(Vessel, nearPorts)=true, Inp),
    union_all([Ifp, Ia, Inp], Iaom),
    intersect_all([Is, Iaom], I).

%---------------- tugging (B) ----------------%

initiatedAt(tugging(Tug, Towed)=true, T) :-
    holdsAt(proximity(Tug, Towed)=true, T),
    holdsAt(velocity(Towed, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tugging(Tug, Towed)=true, T) :-
    holdsAt(velocity(Towed, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    (Speed < TuggingMin; Speed > TuggingMax).

terminatedAt(tugging(Tug, Towed)=true, T) :-
    happensAt(gap_start(Tug), T).

terminatedAt(tugging(Tug, Towed)=true, T) :-
    happensAt(gap_start(Towed), T).

holdsFor(tugging(Tug, Towed)=true, I) :-
    holdsFor(proximity(Tug, Towed)=true, Ip),
    holdsFor(velocity(Towed, Speed, _, _), Iv),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    holdsFor(Speed >= TuggingMin, Is1),
    holdsFor(Speed =< TuggingMax, Is2),
    intersect_all([Ip, Is1, Is2], I).

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    (isPilot(Vessel1); isPilot(Vessel2)),
    holdsAt(lowSpeed(Vessel1)=true, T),
    holdsAt(lowSpeed(Vessel2)=true, T),
    (holdsAt(withinArea(Vessel1, farFromPorts)=true, T);
     holdsAt(withinArea(Vessel2, farFromPorts)=true, T);
     holdsAt(withinArea(Vessel1, nearCoast)=true, T);
     holdsAt(withinArea(Vessel2, nearCoast)=true, T)).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not holdsAt(proximity(Vessel1, Vessel2)=true, T).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not holdsAt(lowSpeed(Vessel1)=true, T).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not holdsAt(lowSpeed(Vessel2)=true, T).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    (not holdsAt(withinArea(Vessel1, farFromPorts)=true, T),
     not holdsAt(withinArea(Vessel2, farFromPorts)=true, T),
     not holdsAt(withinArea(Vessel1, nearCoast)=true, T),
     not holdsAt(withinArea(Vessel2, nearCoast)=true, T)).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    (isPilot(Vessel1); isPilot(Vessel2)),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(withinArea(Vessel1, farFromPorts)=true, Ifp1),
    holdsFor(withinArea(Vessel2, farFromPorts)=true, Ifp2),
    holdsFor(withinArea(Vessel1, nearCoast)=true, Inc1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Inc2),
    union_all([Ifp1, Ifp2, Inc1, Inc2], Inear),
    intersect_all([Ip, Il1, Il2, Inear], I).

%-------------------------- SAR --------------%

initiatedAt(SAR(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(SAR(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(SAR(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(SAR(Vessel)=true, I) :-
    holdsFor(velocity(Vessel, Speed, _, _), Iv),
    thresholds(sarMinSpeed, SarMinSpeed),
    holdsFor(Speed < SarMinSpeed, Isar),
    intersect_all([Iv, Isar], I).

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel)=true, T) :-
    (holdsAt(lowSpeed(Vessel)=true, T);
     holdsAt(withinArea(Vessel, farFromPorts)=true, T);
     holdsAt(withinArea(Vessel, nearCoast)=true, T);
     holdsAt(anchoredOrMoored(Vessel)=true, T)).

terminatedAt(loitering(Vessel)=true, T) :-
    not holdsAt(lowSpeed(Vessel)=true, T),
    not holdsAt(withinArea(Vessel, farFromPorts)=true, T),
    not holdsAt(withinArea(Vessel, nearCoast)=true, T),
    not holdsAt(anchoredOrMoored(Vessel)=true, T).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(withinArea(Vessel, farFromPorts)=true, Ifp),
    holdsFor(withinArea(Vessel, nearCoast)=true, Inc),
    holdsFor(anchoredOrMoored(Vessel)=true, Iaom),
    union_all([Il, Ifp, Inc, Iaom], I).