%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel, Location)=true, T) :-
    happensAt(gap_start(Vessel), T),
    (   holdsAt(nearPorts(Vessel)=true, T)
    ->  Location = nearPorts
    ;   Location = farFromPorts
    ).

terminatedAt(communicationGap(Vessel, _Location)=true, T) :-
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
    holdsAt(proximity(Vessel, coast)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed <= HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, coast), T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel, SpeedStatus)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    thresholds(movingMax, MovingMax),
    (   Speed < MovingMin -> SpeedStatus = below
    ;   Speed >= MovingMin, Speed <= MovingMax -> SpeedStatus = normal
    ;   Speed > MovingMax -> SpeedStatus = above
    ).

terminatedAt(movingSpeed(Vessel, _)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel, _)=true, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) <= AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(underWay(Vessel)=true, T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(inArea(Vessel)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed <= TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    (   thresholds(trawlspeedMin, TrawlspeedMin),
        Speed < TrawlspeedMin
    ;   thresholds(trawlspeedMax, TrawlspeedMax),
        Speed > TrawlspeedMax
    ).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    holdsAt(inArea(Vessel)=false, T).

%--------------- trawling --------------------%

initiatedAt(trawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(inArea(Vessel, trawlingArea)=true, T),
    holdsAt(trawlSpeed(Vessel)=true, T),
    holdsAt(trawlingMovement(Vessel)=true, T).

terminatedAt(trawling(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, trawlingArea), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlSpeed(Vessel)=true, I1),
    holdsFor(inArea(Vessel, trawlingArea)=true, I2),
    intersect_all([I1, I2], I).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel, Location)=true, T) :-
    happensAt(stop_start(Vessel), T),
    (   holdsAt(inArea(Vessel, anchorage)=true, T)
    ->  Location = anchorage
    ;   holdsAt(nearPorts(Vessel)=true, T)
    ->  Location = nearPorts
    ;   Location = farFromPorts
    ).

initiatedAt(anchoredOrMoored(Vessel, Location)=true, T) :-
    holdsAt(anchoredOrMoored(Vessel, Location)=true, Tprev),
    T > Tprev,
    not happensAt(stop_end(Vessel), T),
    not happensAt(start(moving(Vessel)), T).

terminatedAt(anchoredOrMoored(Vessel, _)=true, T) :-
    happensAt(stop_end(Vessel), T).

terminatedAt(anchoredOrMoored(Vessel, Location)=true, T) :-
    happensAt(leavesArea(Vessel, Location), T).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, I1),
    holdsFor(inArea(Vessel, anchorage)=true, I2),
    holdsFor(inArea(Vessel, nearCoast)=true, I3),
    union_all([I1, I2, I3], I).

%---------------- tugging (B) ----------------%

initiatedAt(tugging(Tug, Tow)=true, T) :-
    happensAt(velocity(Tug, SpeedTug, _, _), T),
    happensAt(velocity(Tow, SpeedTow, _, _), T),
    holdsAt(proximity(Tug, Tow)=true, T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    SpeedTug >= TuggingMin, SpeedTug <= TuggingMax,
    SpeedTow >= TuggingMin, SpeedTow <= TuggingMax.

terminatedAt(tugging(Tug, Tow)=true, T) :-
    (   happensAt(velocity(Tug, SpeedTug, _, _), T),
        thresholds(tuggingMin, TuggingMin),
        thresholds(tuggingMax, TuggingMax),
        (   SpeedTug < TuggingMin
        ;   SpeedTug > TuggingMax
        )
    ;   happensAt(velocity(Tow, SpeedTow, _, _), T),
        (   SpeedTow < TuggingMin
        ;   SpeedTow > TuggingMax
        )
    ).

terminatedAt(tugging(Tug, Tow)=true, T) :-
    happensAt(gap_start(Tug), T);
    happensAt(gap_start(Tow), T).

holdsFor(tugging(Tug, Tow)=true, I) :-
    holdsFor(proximity(Tug, Tow)=true, Ip),
    holdsFor(velocity(Tug, SpeedTug)=tuggingSpeed, I1),
    holdsFor(velocity(Tow, SpeedTow)=tuggingSpeed, I2),
    intersect_all([Ip, I1, I2], I).

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    happensAt(proximity(Vessel1, Vessel2)=true, T),
    (   holdsAt(isPilot(Vessel1)=true, T)
    ;   holdsAt(isPilot(Vessel2)=true, T)
    ),
    holdsAt(lowSpeed(Vessel1)=true, T),
    holdsAt(lowSpeed(Vessel2)=true, T),
    (   holdsAt(stopped(Vessel1)=farFromPorts, T)
    ;   holdsAt(inArea(Vessel1, nearCoast)=true, T)
    ),
    (   holdsAt(stopped(Vessel2)=farFromPorts, T)
    ;   holdsAt(inArea(Vessel2, nearCoast)=true, T)
    ).


initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    holdsAt(pilotOps(Vessel1, Vessel2)=true, Tprev),
    T > Tprev,
    not happensAt(gap_start(Vessel1), T),
    not happensAt(gap_start(Vessel2), T).
terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    happensAt(velocity(Vessel1, Speed1, _, _), T),
    happensAt(velocity(Vessel2, Speed2, _, _), T),
    thresholds(movingMax, MovingMax),
    (   Speed1 > MovingMax
    ;   Speed2 > MovingMax
    ).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    happensAt(gap_start(Vessel1), T);
    happensAt(gap_start(Vessel2), T).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    happensAt(leavesArea(Vessel1, nearCoast), T);
    happensAt(leavesArea(Vessel2, nearCoast), T).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    (   holdsFor(isPilot(Vessel1)=true, Ip)
    ;   holdsFor(isPilot(Vessel2)=true, Ip)
    ),
    holdsFor(lowSpeed(Vessel1)=true, I1),
    holdsFor(lowSpeed(Vessel2)=true, I2),
    holdsFor(stopped(Vessel1)=farFromPorts, I3),
    holdsFor(inArea(Vessel1, nearCoast)=true, I4),
    holdsFor(stopped(Vessel2)=farFromPorts, I5),
    holdsFor(inArea(Vessel2, nearCoast)=true, I6),
    union_all([I3, I4, I5, I6], Iarea),
    intersect_all([Ip, I1, I2, Iarea], I).

%-------------------------- SAR --------------%

initiatedAt(SAR(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(SAR(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(SAR(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(SARMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(SARMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(SARMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(SAR(Vessel)=true, I) :-
    holdsFor(velocity(Vessel, Speed)=sarSpeed, I1),
    holdsFor(SARMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I).

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel)=true, T) :-
    (   holdsAt(lowSpeed(Vessel)=true, T)
    ;   holdsAt(stopped(Vessel)=farFromPorts, T)
    ;   holdsAt(inArea(Vessel, nearCoast)=true, T)
    ;   holdsAt(anchoredOrMoored(Vessel)=true, T)
    ).

initiatedAt(loitering(Vessel)=true, T) :-
    holdsAt(loitering(Vessel)=true, Tprev),
    T > Tprev,
    (   holdsAt(lowSpeed(Vessel)=true, T)
    ;   holdsAt(stopped(Vessel)=farFromPorts, T)
    ;   holdsAt(inArea(Vessel, nearCoast)=true, T)
    ;   holdsAt(anchoredOrMoored(Vessel)=true, T)
    ).

terminatedAt(loitering(Vessel)=true, T) :-
    not holdsAt(lowSpeed(Vessel)=true, T),
    not holdsAt(stopped(Vessel)=farFromPorts, T),
    not holdsAt(inArea(Vessel, nearCoast)=true, T),
    not holdsAt(anchoredOrMoored(Vessel)=true, T).

holdsFor(loitering(Vessel)=true, I) :-
    initiatedAt(loitering(Vessel)=true, Tstart),
    terminatedAt(loitering(Vessel)=true, Tend),
    thresholds(loiteringTime, LoiteringTime),
    Tend - Tstart > LoiteringTime,
    I = [Tstart, Tend].

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    holdsFor(inArea(Vessel, nearCoast)=true, I3),
    holdsFor(anchoredOrMoored(Vessel)=true, I4),
    union_all([I1, I2, I3, I4], I).