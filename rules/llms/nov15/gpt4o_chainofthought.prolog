%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T),
    (holdsAt(withinArea(Vessel, nearPorts)=true, T);
     holdsAt(withinArea(Vessel, farFromPorts)=true, T)).

terminatedAt(communicationGap(Vessel)=true, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowspeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowspeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowspeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%-------------- changingSpeed ----------------%

initiatedAt(changingspeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingspeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingspeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed >= HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed < HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    not holdsAt(withinArea(Vessel, nearCoast)=true, T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed >= MovingMin.

terminatedAt(movingSpeed(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, Course, _), T),
    thresholds(adriftAngThr, AdriftAngThr),
    Course > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, Course, _), T),
    thresholds(adriftAngThr, AdriftAngThr),
    Course =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(underWay(Vessel)=true, T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax,
    holdsAt(withinArea(Vessel, Area)=true, T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    (Speed < TrawlspeedMin; Speed > TrawlspeedMax).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    not holdsAt(withinArea(Vessel, Area)=true, T).

%--------------- trawling --------------------%

initiatedAt(trawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, Area)=true, T),
    holdsAt(trawlSpeed(Vessel)=true, T),
    holdsAt(trawlingMovement(Vessel)=true, T).

terminatedAt(trawling(Vessel)=true, T) :-
    not holdsAt(withinArea(Vessel, Area)=true, T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlSpeed(Vessel)=true, Is),
    holdsFor(withinArea(Vessel, trawlingArea)=true, Ia),
    intersect_all([Is, Ia], I).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    (holdsAt(stopped(Vessel)=farFromPorts, T);
     holdsAt(withinArea(Vessel, anchorage)=true, T);
     holdsAt(stopped(Vessel)=nearPorts, T)).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, I1),
    holdsFor(withinArea(Vessel, anchorage)=true, I2),
    holdsFor(stopped(Vessel)=nearPorts, I3),
    union_all([I1, I2, I3], I).

%---------------- tugging (B) ----------------%

initiatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(velocity(Vessel1, Speed1, _, _), T),
    happensAt(velocity(Vessel2, Speed2, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed1 >= TuggingMin,
    Speed1 =< TuggingMax,
    Speed2 >= TuggingMin,
    Speed2 =< TuggingMax,
    holdsAt(proximity(Vessel1, Vessel2)=true, T). 

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    holdsAt(velocity(Vessel1, Speed1, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    (Speed1 < TuggingMin; Speed1 > TuggingMax).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    holdsAt(velocity(Vessel2, Speed2, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    (Speed2 < TuggingMin; Speed2 > TuggingMax).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(gap_start(Vessel1), T).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(gap_start(Vessel2), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(trawlSpeed(Vessel1)=true, It1),
    holdsFor(trawlSpeed(Vessel2)=true, It2),
    intersect_all([Ip, It1, It2], I).

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    (isPilot(Vessel1); isPilot(Vessel2)),
    holdsAt(lowSpeed(Vessel1)=true, T),
    holdsAt(lowSpeed(Vessel2)=true, T),
    (holdsAt(stopped(Vessel1)=farFromPorts, T); holdsAt(withinArea(Vessel1, nearCoast)=true, T)),
    (holdsAt(stopped(Vessel2)=farFromPorts, T); holdsAt(withinArea(Vessel2, nearCoast)=true, T)).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not holdsAt(proximity(Vessel1, Vessel2)=true, T).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not holdsAt(lowSpeed(Vessel1)=true, T).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not holdsAt(lowSpeed(Vessel2)=true, T).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not (holdsAt(stopped(Vessel1)=farFromPorts, T); holdsAt(withinArea(Vessel1, nearCoast)=true, T)).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not (holdsAt(stopped(Vessel2)=farFromPorts, T); holdsAt(withinArea(Vessel2, nearCoast)=true, T)).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(isPilot(Vessel1), Ip1),
    holdsFor(isPilot(Vessel2), Ip2),
    union_all([Ip1, Ip2], PilotInterval),
    intersect_all([Ip, Il1, Il2, PilotInterval], I).

%-------------------------- SAR --------------%

initiatedAt(sarOperation(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarOperation(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarOperation(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(sarOperation(Vessel)=true, I) :-
    holdsFor(velocity(Vessel, Speed)=belowSarThreshold, I1),
    union_all([I1], I).

holdsFor(sarMovement(Vessel)=true, I) :-
    holdsFor(change_in_speed_start(Vessel), I2),
    holdsFor(change_in_heading(Vessel), I3),
    union_all([I2, I3], I).

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel)=true, T) :-
    (holdsAt(lowSpeed(Vessel)=true, T);
     holdsAt(stopped(Vessel)=farFromPorts, T);
     holdsAt(withinArea(Vessel, nearCoast)=true, T);
     holdsAt(anchoredOrMoored(Vessel)=true, T)).

terminatedAt(loitering(Vessel)=true, T) :-
    not holdsAt(lowSpeed(Vessel)=true, T),
    not holdsAt(stopped(Vessel)=farFromPorts, T),
    not holdsAt(withinArea(Vessel, nearCoast)=true, T),
    not holdsAt(anchoredOrMoored(Vessel)=true, T).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    holdsFor(withinArea(Vessel, nearCoast)=true, I3),
    holdsFor(anchoredOrMoored(Vessel)=true, I4),
    union_all([I1, I2, I3, I4], I).