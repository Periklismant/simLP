%--------------- communication gap -----------%

initiatedAt(gap(Vessel, nearPorts)=true, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel, nearPorts)=true, T) :-
    happensAt(gap_end(Vessel), T).

initiatedAt(gap(Vessel, farFromPorts)=true, T) :-
    happensAt(gap_start(Vessel), T),
    \+(holdsAt(withinArea(Vessel, nearPorts)=true, T)).

terminatedAt(gap(Vessel, farFromPorts)=true, T) :-
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

% broke disjunction here.
terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed < HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, nearCoast), T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _),
    Speed < Min.

initiatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _),
    Speed >= Min,
    Speed =< Max.

initiatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _),
    Speed > Max.

terminatedAt(movingSpeed(Vessel)=_Status, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=_Status, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) <= AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

% broke disjunction here.
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
    happensAt(leavesArea(Vessel, fishingArea), T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, fishingArea), T).

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

% broke disjunction here.
terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed < TrawlspeedMin.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMax.

initiatedAt(trawling(Vessel)=true, T) :-
    holdsAt(trawlingSpeed(Vessel)=true, T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

% broke ;
terminatedAt(trawling(Vessel)=true, T) :-
    \+(holdsAt(trawlingSpeed(Vessel)=true, T)).
terminatedAt(trawling(Vessel)=true, T) :-
    \+(holdsAt(withinArea(Vessel, fishingArea)=true, T)).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlingSpeed(Vessel)=true, Is),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(Is, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, anchorageAreaFarFromPorts)=true, T).

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
    Speed >= TuggingMin,
    Speed =< TuggingMax.

% broke disjunction here.
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

% Define the tuggingSpeed fluent for speed within tugging bounds
initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

% broke disjunction here
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

% broke ;
initiatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    vesselType(Vessel1, tugboat),
    holdsAt(proximity(Vessel1, Vessel2) = true),
    holdsAt(tuggingSpeed(Vessel1)=true, T),
    holdsAt(tuggingSpeed(Vessel2)=true, T).
initiatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    vesselType(Vessel2, tugboat),
    holdsAt(proximity(Vessel1, Vessel2) = true),
    holdsAt(tuggingSpeed(Vessel1)=true, T),
    holdsAt(tuggingSpeed(Vessel2)=true, T).

% broke ;
terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    \+(holdsAt(proximity(Vessel1, Vessel2) = true, T)).
terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    \+(holdsAt(tuggingSpeed(Vessel1)=true, T)).
terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    \+(holdsAt(tuggingSpeed(Vessel2)=true, T)).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(tuggingSpeed(Vessel1)=true, Is1),
    holdsFor(tuggingSpeed(Vessel2)=true, Is2),
    thresholds(tuggingTime, TuggingTime),
    intersect_all([Is1, Is2], Iintersect),
    intDurGreater(Iintersect, TuggingTime, I).

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    holdsAt(proximity(Vessel1, Vessel2) = true, T),
    (vesselType(Vessel1, pilotVessel); vesselType(Vessel2, pilotVessel)),
    (holdsAt(lowSpeed(Vessel1)=true, T); holdsAt(stopped(Vessel1)=farFromPorts, T)),
    (holdsAt(lowSpeed(Vessel2)=true, T); holdsAt(stopped(Vessel2)=farFromPorts, T)),
    \+(holdsAt(withinArea(Vessel1, nearCoast)=true, T)),
    \+(holdsAt(withinArea(Vessel2, nearCoast)=true, T)).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    \+(holdsAt(proximity(Vessel1, Vessel2) = true, T));
    \+((holdsAt(lowSpeed(Vessel1)=true, T); holdsAt(stopped(Vessel1)=farFromPorts, T)));
    \+((holdsAt(lowSpeed(Vessel2)=true, T); holdsAt(stopped(Vessel2)=farFromPorts, T)));
    (holdsAt(withinArea(Vessel1, nearCoast)=true, T);
     holdsAt(withinArea(Vessel2, nearCoast)=true, T)).

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
initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

% broke disjunction here.
initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(inSAR(Vessel)=true, T) :-
    holdsAt(sarSpeed(Vessel)=true, T),
    holdsAt(sarMovement(Vessel)=true, T).

terminatedAt(inSAR(Vessel)=true, T) :-
    \+(holdsAt(sarSpeed(Vessel)=true, T)).
terminatedAt(inSAR(Vessel)=true, T) :-
    \+(holdsAt(sarMovement(Vessel)=true, T)).

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel)=true, T) :-
    holdsAt(lowSpeed(Vessel)=true, T),
    \+(holdsAt(withinArea(Vessel, nearCoast)=true, T)),
    \+(holdsAt(anchoredOrMoored(Vessel)=true, T)).
initiatedAt(loitering(Vessel)=true, T) :-
    holdsAt(stopped(Vessel)=farFromPorts, T),
    \+(holdsAt(withinArea(Vessel, nearCoast)=true, T)),
    \+(holdsAt(anchoredOrMoored(Vessel)=true, T)).

terminatedAt(loitering(Vessel)=true, T) :-
    \+((holdsAt(lowSpeed(Vessel)=true, T); holdsAt(stopped(Vessel)=farFromPorts, T)));
    holdsAt(withinArea(Vessel, nearCoast)=true, T);
    holdsAt(anchoredOrMoored(Vessel)=true, T).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor((lowSpeed(Vessel)=true; stopped(Vessel)=farFromPorts), I1),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I1, LoiteringTime, I).
