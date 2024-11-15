%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel, AreaType)=true, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, AreaType)=true, T).

terminatedAt(communicationGap(Vessel, _)=true, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowspeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(lowspeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed >= MovingMin.

terminatedAt(lowspeed(Vessel)=true, T) :-
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

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed <= HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    holdsAt(areaType(Area, nearCoast), T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    thresholds(movingMax, MovingMax),
    (Speed >= MovingMin; Speed <= MovingMax).

terminatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=true, T) :-
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
    holdsAt(underWay(Vessel)=true, T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMin,
    Speed < TrawlspeedMax,
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    ( thresholds(trawlspeedMin, TrawlspeedMin), Speed < TrawlspeedMin;
      thresholds(trawlspeedMax, TrawlspeedMax), Speed > TrawlspeedMax ).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    holdsAt(areaType(Area, fishingArea), T).

%--------------- trawling --------------------%

initiatedAt(trawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, trawlingArea)=true, T).

terminatedAt(trawling(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    holdsAt(areaType(Area, trawlingArea), T).

holdsFor(trawling(Vessel)=true, I) :-
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    holdsFor(velocity(Vessel) in_range [TrawlspeedMin, TrawlspeedMax]=true, Iv),
    holdsFor(withinArea(Vessel, trawlingArea)=true, Ia),
    intersect_all([Iv, Ia], I).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    (holdsAt(withinArea(Vessel, farFromPorts)=true, T) ;
     holdsAt(withinArea(Vessel, anchorage)=true, T) ;
     holdsAt(withinArea(Vessel, nearPorts)=true, T)).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    ( holdsAt(areaType(Area, farFromPorts), T) ;
      holdsAt(areaType(Area, anchorage), T) ;
      holdsAt(areaType(Area, nearPorts), T) ).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    not(holdsAt(anchoredOrMoored(Vessel)=true, T)).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=true, I),
    ( holdsFor(withinArea(Vessel, farFromPorts)=true, I) ;
      holdsFor(withinArea(Vessel, anchorage)=true, I) ;
      holdsFor(withinArea(Vessel, nearPorts)=true, I) ).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=true, Is),
    union_all([
        holdsFor(withinArea(Vessel, farFromPorts)=true, If),
        holdsFor(withinArea(Vessel, anchorage)=true, Ia),
        holdsFor(withinArea(Vessel, nearPorts)=true, In)
    ], Iw),
    intersect_all([Is, Iw], I).

%---------------- tugging (B) ----------------%

initiatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(velocity(Vessel1, Speed1, _, _), T),
    happensAt(velocity(Vessel2, Speed2, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed1 >= TuggingMin, Speed1 <= TuggingMax,
    Speed2 >= TuggingMin, Speed2 <= TuggingMax,
    holdsAt(proximity(Vessel1, Vessel2)=true, T).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    ( happensAt(velocity(Vessel1, Speed1, _, _), T),
      ( thresholds(tuggingMin, TuggingMin), Speed1 < TuggingMin ;
        thresholds(tuggingMax, TuggingMax), Speed1 > TuggingMax ) ;
      happensAt(velocity(Vessel2, Speed2, _, _), T),
      ( thresholds(tuggingMin, TuggingMin), Speed2 < TuggingMin ;
        thresholds(tuggingMax, TuggingMax), Speed2 > TuggingMax ) ).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(gap_start(Vessel1), T);
    happensAt(gap_start(Vessel2), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    holdsFor(velocity(Vessel1) in_range [TuggingMin, TuggingMax]=true, Iv1),
    holdsFor(velocity(Vessel2) in_range [TuggingMin, TuggingMax]=true, Iv2),
    intersect_all([Ip, Iv1, Iv2], I).

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    (oneIsPilot(Vessel1, Vessel2); oneIsPilot(Vessel2, Vessel1)),
    holdsAt(lowSpeed(Vessel1)=true, T),
    holdsAt(lowSpeed(Vessel2)=true, T),
    (holdsAt(stopped(Vessel1)=farFromPorts, T) ;
     holdsAt(withinArea(Vessel1, nearCoast)=true, T)),
    (holdsAt(stopped(Vessel2)=farFromPorts, T) ;
     holdsAt(withinArea(Vessel2, nearCoast)=true, T)).

terminatedAt(pilotOps(Vessel1, Vessel2)=true, T) :-
    not(holdsAt(proximity(Vessel1, Vessel2)=true, T)) ;
    not(holdsAt(lowSpeed(Vessel1)=true, T)) ;
    not(holdsAt(lowSpeed(Vessel2)=true, T)) ;
    (not(holdsAt(stopped(Vessel1)=farFromPorts, T)) ;
     not(holdsAt(withinArea(Vessel1, nearCoast)=true, T))) ;
    (not(holdsAt(stopped(Vessel2)=farFromPorts, T)) ;
     not(holdsAt(withinArea(Vessel2, nearCoast)=true, T))).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    union_all([
        holdsFor(lowSpeed(Vessel1)=true, Il1),
        holdsFor(lowSpeed(Vessel2)=true, Il2),
        holdsFor(stopped(Vessel1)=farFromPorts, Is1),
        holdsFor(stopped(Vessel2)=farFromPorts, Is2),
        holdsFor(withinArea(Vessel1, nearCoast)=true, Iw1),
        holdsFor(withinArea(Vessel2, nearCoast)=true, Iw2)
    ], Iu),
    intersect_all([Ip, Iu], I).

%-------------------------- SAR --------------%

initiatedAt(sarOps(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarOps(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed > SarMinSpeed.

terminatedAt(sarOps(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T);
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(sarOps(Vessel)=true, I) :-
    thresholds(sarMinSpeed, SarMinSpeed),
    holdsFor(velocity(Vessel) < SarMinSpeed=true, Iv),
    union_all([
        Iv
    ], I).

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin;
    holdsAt(stopped(Vessel)=farFromPorts, T);
    holdsAt(withinArea(Vessel, nearCoast)=true, T);
    holdsAt(anchoredOrMoored(Vessel)=true, T).

terminatedAt(loitering(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed >= MovingMin.

terminatedAt(loitering(Vessel)=true, T) :-
    happensAt(start(Vessel), T),
    not holdsAt(stopped(Vessel)=farFromPorts, T).

terminatedAt(loitering(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    holdsAt(areaType(Area, nearCoast), T).

terminatedAt(loitering(Vessel)=true, T) :-
    terminatedAt(anchoredOrMoored(Vessel)=true, T).

holdsFor(loitering(Vessel)=true, I) :-
    ( holdsFor(lowSpeed(Vessel)=true, I);
      holdsFor(stopped(Vessel)=farFromPorts, I);
      holdsFor(withinArea(Vessel, nearCoast)=true, I);
      holdsFor(anchoredOrMoored(Vessel)=true, I) ),
    thresholds(loiteringTime, LoiteringTime),
    intDur(I, Duration),
    Duration >= LoiteringTime.

holdsFor(loitering(Vessel)=true, I) :-
    thresholds(loiteringTime, LoiteringTime),
    union_all([
        holdsFor(lowSpeed(Vessel)=true, Il),
        holdsFor(stopped(Vessel)=farFromPorts, If),
        holdsFor(withinArea(Vessel, nearCoast)=true, In),
        holdsFor(anchoredOrMoored(Vessel)=true, Ia)
    ], Iu),
    intDurGreater(Iu, LoiteringTime, I).