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

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    \+ holdsAt(withinArea(Vessel, nearCoast)=true, T).

%--------------- movingSpeed -----------------%

holdsFor(movingSpeed(Vessel)=below, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), _T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, _Max, _Avg),
    thresholds(movingMin, MovingMin),
    Speed < Min,
    Speed >= MovingMin,
    holdsFor(velocity(Vessel, Speed, _), I).

holdsFor(movingSpeed(Vessel)=normal, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), _T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _Avg),
    Speed >= Min,
    Speed =< Max,
    holdsFor(velocity(Vessel, Speed, _), I).

holdsFor(movingSpeed(Vessel)=above, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), _T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _Min, Max, _Avg),
    Speed > Max,
    holdsFor(velocity(Vessel, Speed, _), I).

terminatedAt(movingSpeed(Vessel)=_, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=_, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _Speed, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    AngleDifference is abs(CourseOverGround - TrueHeading),
    AngleDifference > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _Speed, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    AngleDifference is abs(CourseOverGround - TrueHeading),
    AngleDifference =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    Speed < TrawlspeedMin.
terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    Speed > TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    \+ holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    \+ holdsAt(withinArea(Vessel, fishingArea)=true, T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, fishingArea)=true, I1),
    holdsFor(trawlSpeed(Vessel)=true, I2),
    holdsFor(trawlingMovement(Vessel)=true, I3),
    intersect_all([I1, I2, I3], IIntersect),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(IIntersect, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=true, I1),
    (
        holdsFor(withinArea(Vessel, anchorageArea)=true, I2),
        \+ holdsFor(withinArea(Vessel, nearPorts)=true, I3)
    ;
        holdsFor(withinArea(Vessel, nearPorts)=true, I4)
    ),
    union_all([I2, I4], IAnchoredOrMooredArea),
    intersect_all([I1, IAnchoredOrMooredArea], I).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed < TuggingMin.
terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel, Tugboat)=true, I) :-
    vesselType(Tugboat, tug),
    holdsFor(proximity(Vessel, Tugboat)=true, I1),
    holdsFor(tuggingSpeed(Vessel)=true, I2),
    holdsFor(tuggingSpeed(Tugboat)=true, I3),
    intersect_all([I1, I2, I3], IIntersect),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(IIntersect, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(PilotVessel, Vessel)=true, I) :-
    vesselType(PilotVessel, pilot),
    holdsFor(proximity(PilotVessel, Vessel)=true, I1),
    holdsFor(lowSpeed(PilotVessel)=true, I2),
    holdsFor(lowSpeed(Vessel)=true, I3),
    holdsFor(stopped(PilotVessel)=farFromPorts, I4),
    holdsFor(stopped(Vessel)=farFromPorts, I5),
    \+ holdsFor(withinArea(PilotVessel, nearCoast)=true, I6),
    \+ holdsFor(withinArea(Vessel, nearCoast)=true, I7),
    intersect_all([I1, I2, I3, I4, I5], IIntersect),
    relative_complement_all(IIntersect, [I6, I7], I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, I1),
    holdsFor(sarMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I).

%-------- loitering --------------------------%
%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    \+ holdsFor(withinArea(Vessel, nearCoast)=true, I3),
    \+ holdsFor(anchoredOrMoored(Vessel)=true, I4),
    intersect_all([I1, I2], IIntersect),
    relative_complement_all(IIntersect, [I3, I4], IFiltered),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(IFiltered, LoiteringTime, I).
