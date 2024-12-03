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
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

%--------------- movingSpeed -----------------%

holdsFor(movingSpeed(Vessel)=below, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, _Max, _Avg),
    Speed < Min,
    \+ happensAt(gap_start(Vessel), T),
    holdsFor(movingSpeed(Vessel)=below, I).

holdsFor(movingSpeed(Vessel)=normal, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _Avg),
    Speed >= Min,
    Speed =< Max,
    \+ happensAt(gap_start(Vessel), T),
    holdsFor(movingSpeed(Vessel)=normal, I).

holdsFor(movingSpeed(Vessel)=above, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _Min, Max, _Avg),
    Speed > Max,
    \+ happensAt(gap_start(Vessel), T),
    holdsFor(movingSpeed(Vessel)=above, I).

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
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed < TrawlspeedMin.
terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, fishingArea)=true, I1),
    holdsFor(trawlSpeed(Vessel)=true, I2),
    holdsFor(trawlingMovement(Vessel)=true, I3),
    intersect_all([I1, I2, I3], Ii),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(Ii, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=true, Is),
    (
        (
            holdsFor(withinArea(Vessel, anchorageArea)=true, Ia1),
            \+ holdsFor(withinArea(Vessel, nearPorts)=true, Ia2),
            relative_complement_all(Is, [Ia2], Iaf),
            intersect_all([Ia1, Iaf], Ianchored)
        );
        (
            holdsFor(withinArea(Vessel, nearPorts)=true, Imoored),
            intersect_all([Is, Imoored], Imoored)
        )
    ),
    union_all([Ianchored, Imoored], I).

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

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    vesselType(Vessel1, tugboat),
    holdsFor(tuggingSpeed(Vessel1)=true, Is1),
    holdsFor(tuggingSpeed(Vessel2)=true, Is2),
    intersect_all([Ip, Is1, Is2], IcloseSpeed),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(IcloseSpeed, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    vesselType(Vessel1, pilotVessel),
    (
        holdsFor(lowSpeed(Vessel1)=true, Il1);
        holdsFor(stopped(Vessel1)=farFromPorts, Is1)
    ),
    (
        holdsFor(lowSpeed(Vessel2)=true, Il2);
        holdsFor(stopped(Vessel2)=farFromPorts, Is2)
    ),
    intersect_all([Ip, Il1, Il2], IcloseSpeed),
    holdsFor(withinArea(Vessel1, nearCoast)=false, In1),
    holdsFor(withinArea(Vessel2, nearCoast)=false, In2),
    intersect_all([IcloseSpeed, In1, In2], Ifinal),
    Ifinal \= [],
    I = Ifinal.

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed > SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed =< SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    vesselType(Vessel, pilotVessel),
    holdsFor(sarSpeed(Vessel)=true, Ispeed),
    holdsFor(sarMovement(Vessel)=true, Imovement),
    intersect_all([Ispeed, Imovement], I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    (
        holdsFor(lowSpeed(Vessel)=true, IlowSpeed);
        holdsFor(stopped(Vessel)=farFromPorts, Iidle)
    ),
    \+ holdsFor(anchoredOrMoored(Vessel)=true, Ianm),
    holdsFor(withinArea(Vessel, nearCoast)=false, InotCoast),
    intersect_all([IlowSpeed, Iidle, InotCoast], Iloafing),
    relative_complement_all(Iloafing, [Ianm], Ifiltered),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(Ifiltered, LoiteringTime, I).
