%----------------within area -----------------%

initiatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, AreaType).

terminatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, AreaType).

terminatedAt(withinArea(Vessel, _AreaType)=true, T) :-
    happensAt(gap_start(Vessel), T).

%-------------- stopped-----------------------%

initiatedAt(stopped(Vessel)=nearPorts, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(stopped(Vessel)=farFromPorts, T) :-
    happensAt(stop_start(Vessel), T),
    \+holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(stopped(Vessel)=_Status, T) :-
    happensAt(stop_end(Vessel), T).

terminatedAt(stopped(Vessel)=_Status, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

%---------------- rendezVous -----------------%

holdsFor(rendezVous(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    \+oneIsTug(Vessel1, Vessel2),
    \+oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il1, Is1], I1b),
    union_all([Il2, Is2], I2b),
    intersect_all([I1b, I2b, Ip], If), If\=[],
    holdsFor(withinArea(Vessel1, nearPorts)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearPorts)=true, Iw2),
    holdsFor(withinArea(Vessel1, nearCoast)=true, Iw3),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Iw4),
    relative_complement_all(If,[Iw1, Iw2, Iw3, Iw4], Ii),
    thresholds(rendezvousTime, RendezvousTime),
    intDurGreater(Ii, RendezvousTime, I).

%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_PortStatus, T) :-
    happensAt(gap_end(Vessel), T).


%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    %happensAt(start(gap(Vessel)=_Status), T).
    happensAt(gap_start(Vessel), T).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    %happensAt(start(gap(Vessel)=_Status), T).
    happensAt(gap_start(Vessel), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    %\+ inRange(Speed, 0, HcNearCoastMax),
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    %inRange(Speed, 0, HcNearCoastMax),
    Speed < HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T):-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, Istfp),
    holdsFor(withinArea(Vessel, anchorage)=true, Ia),
    intersect_all([Istfp, Ia], Ista),
    holdsFor(stopped(Vessel)=nearPorts, Istnp),
    union_all([Ista, Istnp], Ii),
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(Ii, AOrMTime, I).


%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true , T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMin,
    Speed < TuggingMax.
    %inRange(Speed, TuggingMin, TuggingMax).

terminatedAt(tuggingSpeed(Vessel)=true , T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed < TuggingMin.
terminatedAt(tuggingSpeed(Vessel)=true , T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.
    %\+inRange(Speed, TuggingMin, TuggingMax).

terminatedAt(tuggingSpeed(Vessel)=true , T) :-
    happensAt(gap_start(Vessel), T).
    %happensAt(start(gap(Vessel)=_Status), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    oneIsTug(Vessel1, Vessel2),
    \+oneIsPilot(Vessel1, Vessel2),
    \+twoAreTugs(Vessel1, Vessel2),
    holdsFor(tuggingSpeed(Vessel1)=true, Its1),
    holdsFor(tuggingSpeed(Vessel2)=true, Its2),
    intersect_all([Ip, Its1, Its2], Ii),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(Ii, TuggingTime, I).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _Heading,_), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMin,
    Speed < TrawlspeedMax,
    %inRange(Speed, TrawlspeedMin, TrawlspeedMax),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlSpeed(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _Heading,_), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed < TrawlspeedMin.

terminatedAt(trawlSpeed(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _Heading,_), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMax.

    %\+inRange(Speed, TrawlspeedMin, TrawlspeedMax).

terminatedAt(trawlSpeed(Vessel)=true, T):-
    happensAt(gap_start(Vessel), T).
    %happensAt(start(gap(Vessel)=_Status), T).

terminatedAt(trawlSpeed(Vessel)=true, T):-
    happensAt(end(withinArea(Vessel, fishing)=true), T).


%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true , T):-
    %vesselType(Vessel, fishing),
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T):-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

%fi(trawlingMovement(Vessel)=true, trawlingMovement(Vessel)=false, TrawlingCrs):-
	%thresholds(trawlingCrs, TrawlingCrs).
%p(trawlingMovement(_Vessel)=true).

holdsFor(trawling(Vessel)=true, I):-
    holdsFor(trawlSpeed(Vessel)=true, It),
    holdsFor(trawlingMovement(Vessel)=true, Itc),
    intersect_all([It, Itc], Ii),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(Ii, TrawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true , T):-
    %vesselType(Vessel, sar),
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed > SarMinSpeed.
    %inRange(Speed,SarMinSpeed,inf).

terminatedAt(sarSpeed(Vessel)=true, T):-
    %vesselType(Vessel, sar),
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.
    %inRange(Speed,0,SarMinSpeed).

terminatedAt(sarSpeed(Vessel)=true, T):-
    happensAt(gap_start(Vessel), T).
    %happensAt(start(gap(Vessel)=_Status), T).

initiatedAt(sarMovement(Vessel)=true, T):-
    %vesselType(Vessel, sar),
    happensAt(change_in_heading(Vessel), T).

initiatedAt(sarMovement(Vessel)=true , T):-
    %vesselType(Vessel, sar),
    happensAt(change_in_speed_start(Vessel), T).
    %happensAt(start(changingSpeed(Vessel)=true), T).

terminatedAt(sarMovement(Vessel)=true, T):-
    %vesselType(Vessel, sar),
    happensAt(gap_start(Vessel), T).
    %happensAt(start(gap(Vessel)=_Status), T).

%fi(sarMovement(Vessel)=true, sarMovement(Vessel)=false, 1800).
%p(sarMovement(_Vessel)=true).

holdsFor(inSAR(Vessel)=true, I):-
    holdsFor(sarSpeed(Vessel)=true, Iss),
    holdsFor(sarMovement(Vessel)=true, Isc),
    intersect_all([Iss, Isc], Ii),
    intDurGreater(Ii, 3600, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], Ils),
    holdsFor(withinArea(Vessel, nearCoast)=true, Inc),
    holdsFor(anchoredOrMoored(Vessel)=true, Iam),
    relative_complement_all(Ils, [Inc,Iam], Ii),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(Ii, LoiteringTime, I).


%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il1, Is1], I1b),
    union_all([Il2, Is2], I2b),
    intersect_all([I1b, I2b, Ip], Ii), Ii\=[],
    holdsFor(withinArea(Vessel1, nearCoast)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Iw2),
    relative_complement_all(Ii,[Iw1, Iw2], I).
