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

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    \+ happensAt(gap_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    \+ happensAt(gap_start(Vessel), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    Speed > hcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),
    Speed =< hcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    holdsAt(withinArea(Vessel, nearCoast)=false, T).  

%--------------- movingSpeed -----------------%

holdsFor(movingSpeed(Vessel) = below, I) :-
    holdsFor(velocity(Vessel, Speed, _, _), Ip),
    Speed < thresholds(movingMin, MovingMin),  
    union_all([Ip], I).

holdsFor(movingSpeed(Vessel) = normal, I) :- 
    holdsFor(velocity(Vessel, Speed, _, _), Ip),
    Speed >= thresholds(movingMin, MovingMin),
    Speed =< thresholds(movingMax, MovingMax),
    union_all([Ip], I).

holdsFor(movingSpeed(Vessel) = above, I) :-
    holdsFor(velocity(Vessel, Speed, _, _), Ip),
    Speed > thresholds(movingMax, MovingMax), 
    union_all([Ip], I).

terminatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed < thresholds(movingMin, MovingMin),
    \+ happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
    abs(CourseOverGround - TrueHeading) > AdriftAngThr. 

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
    abs(CourseOverGround - TrueHeading) =< AdriftAngThr. 

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T). 

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, fishingArea), T), 
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
    happensAt(gap_start(Vessel), T).     

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(withinArea(Vessel, fishingArea)=true, T),  
    happensAt(change_in_heading(Vessel), T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    \+ holdsAt(withinArea(Vessel, fishingArea), T).

holdsFor(trawling(Vessel) = true, I) :-
    holdsFor(withinArea(Vessel, fishingArea) = true, I1), 
    holdsFor(typeSpeed(trawler, trawlspeedMin, trawlspeedMax, _), _),
    holdsFor(velocity(Vessel, Speed, _, _), Il),
    holdsFor(intRange(Speed, trawlspeedMin, trawlspeedMax), I2),
    holdsFor(typical_trawling_behavior(Vessel, I3), _),  
    union_all([I1, I2, I3], I),
    intDurGreater(I, trawlingTime, I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) :- 
    holdsFor(stopped(Vessel) = farFromPorts, I1),
    holdsFor(withinArea(Vessel, anchorageArea) = true, I2),  
    union_all([I1, I2], I). 

holdsFor(anchoredOrMoored(Vessel) = true, I) :- 
    holdsFor(stopped(Vessel) = nearPorts, I1),
    holdsFor(withinArea(Vessel, anchorageArea) = true, I2),
    union_all([I1, I2], I). 

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > tuggingMin,
  Speed < tuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T), 
  Speed < tuggingMin,
  Speed > tuggingMax.

holdsFor(tugging(TugBoat, TowedVessel)=true, I) :- 
    holdsFor(proximity(TugBoat, TowedVessel)=true, Ip),
    holdsFor(vesselType(TugBoat, tugboat), _),
    holdsFor(typeSpeed(tugbot, tuggingMin, tuggingMax, _), _), 
    holdsFor(velocity(TugBoat, Speed, _, _) , Itg),
    holdsFor(velocity(TowedVessel, Speed, _, _) , Itw),
    holdsFor(intRange(Speed, tuggingMin, tuggingMax), It), 
    union_all([Ip, Itg, Itw, It], I),
    intDurGreater(I, tuggingTime, I). 

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(PilotVessel, Vessel)=true, I) :-
    holdsFor(proximity(PilotVessel, Vessel)=true, Ip),
    holdsFor(lowSpeed(PilotVessel)=true, I1), 
    holdsFor(lowSpeed(Vessel)=true, I2),
    holdsFor(stopped(PilotVessel) = farFromPorts, I3),
    holdsFor(stopped(Vessel) = farFromPorts, I4),
    holdsFor(withinArea(PilotVessel, not nearCoast) = true, I5), % Pilot vessel not near coast
    holdsFor(withinArea(Vessel, not nearCoast) = true, I6), % Vessel not near coast
    union_all([I1, I2, I3, I4, Ip, I5, I6], I_),
    %Additional constraints as needed, like duration 
    \+ intersect_all([I_ , I6],[nearPorts]).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(good_speed_calibration(Vessel), T),  
    Speed >= thresholds(sarMinSpeed, SarMinSpeed). 

terminatedAt(sarSpeed(Vessel)=true, T) :- 
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(good_speed_calibration(Vessel), T),
    Speed < thresholds(sarMinSpeed, SarMinSpeed),
    \+ happensAt(gap_start(Vessel), T). 

initiatedAt(sarMovement(Vessel)=true, T) :-
  happensAt(change_in_speed_start(Vessel), T),
  \+ holdsAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
  happensAt(change_in_heading(Vessel), T),
  \+ holdsAt(gap_start(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
  happensAt(gap_start(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
  happensAt(stop_start(Vessel), T).

initiatedAt(inSAR(Vessel)=true, T) :- 
    happensAt(typeSpeed(sar, SarMinSpeed, SarMaxSpeed, _), _),
    holdsAt(velocity(Vessel,Speed,_,_), T),
    Speed >= SarMinSpeed,
    holdsAt(change_in_heading(Vessel)=true, T), 
    holdsAt(typeSpeed(pilot, _ ,_, _),  _ ,).

terminatedAt(inSAR(Vessel)=true, T) :- 
    happensAt(stop_end(Vessel), T),
     holdsAt(velocity(Vessel,Speed,_,_), T),
    Speed < SarMinSpeed. 

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(slowMotion(Vessel)=true, Il1),
    holdsFor(stopped(Vessel)=farFromPorts, Il2),
    holdsFor(stopped_nearObjects(Vessel)=false, Il3),
    holdsFor(stopped_anchored(Vessel)=false, Il4), 
    union_all([Il1, Il2, Il3, Il4], I1),
    thresholds(loiteringTime, LoiteringTimeThreshold), 
    intDurGreater(I1, LoiteringTimeThreshold, I). 
