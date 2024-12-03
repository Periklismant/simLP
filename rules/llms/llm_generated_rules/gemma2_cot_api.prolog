%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=true, T) :-
  happensAt(gap_start(Vessel), T),
  holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=true, T) :-
  happensAt(gap_start(Vessel), T),
  \+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=true, T) :-
  happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
happensAt(change_in_speed_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
 happensAt(change_in_speed_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=True, T) :-
 happensAt(gap_start(Vessel), T).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
   happensAt(gap_start(Vessel).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happenAt(entersArea(Vessel, AreaID), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HCMax),
    Speed > HCMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed =< HCMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T).

%--------------- movingSpeed -----------------%

holdsFor(velocity(Vessel,Speed,_,_), Ip):-
   holdsFor(thresholds(movingMin, MinSpeed), Th),
   Speed < MinSpeed, 
   union_all(Ip, I).

holdsFor(velocity(Vessel,Speed,_,_), Ip):-
   holdsFor(thresholds(movingMin, MinSpeed), Th1),
   holdsFor(thresholds(movingMax, MaxSpeed), Th2),
   MinSpeed =< Speed, 
   Speed =< MaxSpeed,
   union_all(Ip, I).

holdsFor(velocity(Vessel,Speed,_,_), Ip):-
   holdsFor(thresholds(movingMin, MinSpeed), Th1),
   holdsFor(thresholds(movingMax, MaxSpeed), Th2),
   Speed > MaxSpeed, 
   union_all(Ip, I).

terminatedAt(movingSpeed(Vessel)=_Speed, T):-
   gap_start(Vessel, T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    thresholds(adriftAngThr, AdriftAngThr),
    velocity(Vessel,Speed,CourseOverGround,TrueHeading),
    abs(TrueHeading - CourseOverGround) > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    thresholds(adriftAngThr, AdriftAngThr),
    velocity(Vessel,Speed,CourseOverGround,TrueHeading),
    abs(TrueHeading - CourseOverGround) =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T). 

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happenAt(entersArea(Vessel, FishingArea), T),
    holdsAt(areaType(FishingArea, FishingAreaType), T),
    happensAt(typeSpeed(FishingAreaType, trawlspeedMin, trawlspeedMax, _), T),
    happensAt(velocity(Vessel, Speed, _, _), T),
    trawlspeedMin =< Speed,
    Speed =< trawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed < trawlspeedMin.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed > trawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T.

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T):- 
    happensAt(changeInHeading(Vessel), T),
    holdsAt(withinArea(Vessel, FishingArea), T).

terminatedAt(trawlingMovement(Vessel)=true, T):-
    happensAt(leavesArea(Vessel, FishingArea), T).

initiatedAt(trawling(Vessel) = true, T) :-
    happensAt(entersArea(Vessel,FishingArea), T),       
    happensAt(change_in_speed_start(Vessel), T),   
    \+ oneIsTug(Vessel, _),                       
    typeSpeed(trawling, trawlspeedMin, trawlspeedMax, _),
    holdsAt(velocity(Vessel, Speed, _, _, _), T),   
    holdsAt([(velocity(Vessel, Speed, _, _, _)) ], T), 
    thresholds(trawlingTime, TrawlingDuration),
    intDurGreater(TrawlingDuration, TrawlingTime, _),  
    duration(T, T1, durationLess(TrawlingDuration, T1)).     

terminatedAt(trawling(Vessel) = true, T) :-
    happensAt(leavesArea(Vessel, FishingArea), T),  
    happensAt(trawling(Vessel) = true, T1),     
    duration(T1, T2, durationGreater(T2, T)).   

terminatedAt(trawling(Vessel) = true, T) :-
    happensAt(change_in_speed_end(Vessel), T),     
    happensAt(trawling(Vessel) = true, T1),      
    tDuration(T1, T2, durationLess(T2, T)).    

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) :-
    holdsFor(stopped(Vessel) = farFromPorts, I1),
    holdsFor(withinArea(Vessel, anchorageArea), I2),
    intersect_all([I1, I2], I).

holdsFor(anchoredOrMoored(Vessel) = true, I) :-
    holdsFor(stopped(Vessel) = nearPorts, I1),
    holdsFor(withinArea(Vessel, portArea), I2),
    intersect_all([I1, I2], I).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    typeSpeed(tugging, TuggingMin, TuggingMax, _), 
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    velocity(Vessel, Speed, _, _), 
    Speed >= TuggingMin,
    Speed =< TuggingMax. 

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    typeSpeed(tugging, TuggingMin, TuggingMax, _), 
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    velocity(Vessel, Speed, _, _), 
    \+ (Speed >= TuggingMin), 
    \+ (Speed =< TuggingMax).

holdsFor(tugging(TugBoat, TowedBoat)=true, I) :-
    holdsFor(proximity(TugBoat, TowedBoat)=true, Ip),
        holdsFor(vesselType(TugBoat,tugboat)=true, It1),
        holdsFor(vesselType(TowedBoat,_)=true, It2),
    holdsFor(movingSpeed(TugBoat)=below(TuggingTrawlspeedLow), Il1),
    holdsFor(movingSpeed(TowedBoat)=below(TuggingTrawlspeedLow), Il2),
    intersect_all([Ip,  If, Il1, Il2], It),
    thresholds(tuggingMin,TuggingMin),
    intDurGreater(It,TuggingMin, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    vesselType(Vessel1, pilot), 
    vesselType(Vessel2, not_pilot), 
    (holdsFor(lowSpeed(Vessel1)=true, Il1),
      holdsFor(lowSpeed(Vessel2)=true, Il2);
    (holdsFor(stopped(Vessel1)=farFromPorts, Is1),
      holdsFor(stopped(Vessel2)=farFromPorts, Is2))),
    intersect_all([Il1, Is1, Il2, Is2, Ip], If), If \=[],
    holdsFor(withinArea(Vessel1, nearCoast)=false, Ic1), 
    holdsFor(withinArea(Vessel2, nearCoast)=false, Ic2),
    relative_complement_all(If, [Ic1, Ic2], I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    velocities(Vessel, Speed, _, _),
    Speed > SarMinSpeed. 

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    thresholds(sarMinSpeed, SarMinSpeed), 
    velocities(Vessel, Speed, _, _),
    Speed =< SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T):-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    holdsFor(sarMovement(Vessel)=true, I).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    typeSpeed(sar, SarMinSpeed, SarMaxSpeed, _),
    holdsFor(velocity(Vessel, V, _, _)=true, VspeedI),
    VspeedI >= SarMinSpeed,
    holdsFor(typicalSARMovement(Vessel)=true, MvtI),
    intersect_all([VspeedI, MvtI], I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(union_all([lowSpeed(Vessel)=true,stopped(Vessel)=farFromPorts], L), Ip),
    \+ holdsFor(withinArea(Vessel, nearBeaches)=true, Ib1),
    \+ holdsFor(anchored(Vessel)=true, Ib2),
    \+ holdsFor(moored(Vessel)=true, Ib3),
    relative_complement_all([Ip], [Ib1, Ib2, Ib3], If), 
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(If, LoiteringTime, I).
