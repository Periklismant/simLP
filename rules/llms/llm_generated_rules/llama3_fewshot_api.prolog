%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

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

initiatedAt(HighSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, _, _), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, MaxCoastSpeed),
    FSpeed is _, % assuming FSpeed is a fluent for the vessel's speed
    FSpeed > MaxCoastSpeed.

terminatedAt(HighSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, _, _), T),
    not (holdsAt(withinArea(Vessel, nearCoast)=true, T), thresholds(hcNearCoastMax, MaxCoastSpeed), FSpeed is _, FSpeed > MaxCoastSpeed) :-
    holdsAt(withinArea(Vessel, nearCoast)=true, T), % or
    holdsAt(withinArea(Vessel, farFromCoast)=true, T). % or
    thresholds(hcNearCoastMax, MaxCoastSpeed), FSpeed is _, FSpeed =< MaxCoastSpeed.

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel, Status)=true, T) :-
    thresholds(movingMin, MovingMin),
    thresholds(movingMax, MovingMax),
    holdsAt(movingSpeed(Vessel, Status)=true, T0),
    Status = one_of([below, normal, above]),
    holdsAt(speed(Vessel, Speed), T0),
    case Status
      when below :-
        MovingMin =< Speed
      when normal :-
        MovingMin =< Speed, Speed =< MovingMax
      when above :-
        Speed =< MovingMax
    end.

terminatedAt(movingSpeed(Vessel, Status)=true, T) :-
    thresholds(movingMin, MovingMin),
    not (holdsAt(movingSpeed(Vessel, Status)=true, T)),
    holdsAt(speed(Vessel, Speed), T),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel, Status)=true, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    absCourseDifference(Vessel, Angle,
        thresholds(adriftAngThr, AdriftAngThr)),
    Angle > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    absCourseDifference(Vessel, Angle,
        thresholds(adriftAngThr, AdriftAngThr)),
    Angle <= AdriftAngThr;
    happensAt(stop_start(Vessel), T).

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    MinBound is TrawlspeedMin, MaxBound is TrawlspeedMax,
    MinBound =< Speed =< MaxBound.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    not (MinBound =< Speed =< MaxBound).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, _), T).

initiatedAt(trawling(Vessel)=true, T) :-
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    holdsAt(moving_in_manner TypicalTrawlingManner, T),
    intDurGreater(T, thresholds(trawlingTime, TrawlingTime)).

terminatedAt(trawling(Vessel)=true, T) :-
    not (holdsAt(withinArea(Vessel, fishingArea)=true, T),
         thresholds(trawlspeedMin, TrawlspeedMin),
         thresholds(trawlspeedMax, TrawlspeedMax),
         holdsAt(moving_in_manner TypicalTrawlingManner, T)).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, anchorageArea)=true, T),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    MinBound is TuggingMin, MaxBound is TuggingMax,
    MinBound =< Speed =< MaxBound.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    not (MinBound =< Speed =< MaxBound).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(tugging(Vessel)=true, T) :-
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    typeVessel(Vessel1, tugboat),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    holdsAt(speed(Vessel1, Speed1)=true, T),
    holdsAt(speed(Vessel2, Speed2)=true, T),
    and(F1, F2, F3),
    F1 = Speed1 >= TuggingMin,
    F2 = Speed1 =< TuggingMax,
    F3 = Speed2 >= TuggingMin,
    F3 = Speed2 =< TuggingMax.

terminatedAt(tugging(Vessel)=true, T) :-
    not (holdsAt(proximity(Vessel1, Vessel2)=true, T),
         typeVessel(Vessel1, tugboat),
         thresholds(tuggingMin, TuggingMin),
         thresholds(tuggingMax, TuggingMax)).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il1, Is1], I1b),
    union_all([Il2, Is2], I2b),
    intersect_all([I1b, I2b, Ip], If),
    not holdsFor(withinArea(Vessel1, nearCoast)=true, Iw1),
    not holdsFor(withinArea(Vessel2, nearCoast)=true, Iw2),
    intersects_all([If, Iw1, Iw2], I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed > SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    not (Speed > SarMinSpeed).

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T);
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarMovement(Vessel)=true, I);
    holdsFor(movingSpeed(Vessel)=distance, I),
    movingSpeed(Vessel) >= thresholds(sarMinSpeed, SarMinSpeed),
    sarMovement(Vessel) = true.

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il) |
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    not holdsFor(withinArea(Vessel, nearCoast)=true, Iw),
    not holdsFor(anchored(Vessel)=true, Ia),
    not holdsFor(moored(Vessel)=true, Im),
    thresholds(loiteringTime, LoiteringTime) < intDur(I).