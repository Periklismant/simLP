%----------------within area -----------------%

initiatedAt(withinArea(Vessel,AreaType)=true,T) :-
 happensAt(entersArea(Vessel,AreaID),T),
 areaType(AreaID,AreaType).

terminatedAt(withinArea(Vessel,AreaType)=true,T) :-
 happensAt(leavesArea(Vessel,AreaID),T),
 areaType(AreaID,AreaType).

 terminatedAt(withinArea(Vessel,AreaType)=true,T) :-
 happensAt(gap_start(Vessel),T).


%--------------- communication gap -----------%

initiatedAt(gap(Vessel) = nearPorts, T)  :-
 happensAt(gap_start(Vessel), T),
 holdsAt(withinArea(Vessel,nearPorts)=true, T).

 initiatedAt(gap(Vessel) = farFromPorts, T)  :-
 happensAt(gap_start(Vessel), T),
 not holdsAt(withinArea(Vessel,nearPorts)=true, T).

 terminatedAt(gap(Vessel) =_Value, T)  :-
 happensAt(gap_end(Vessel), T).


%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel) = true, T) :-
  holdsAt(withinArea(Vessel, nearCoast) = true, T),
  velocity(Vessel, Speed, _, T),
  Speed > 5.

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
  happensAt(leavesArea(Vessel, nearCoast), T).

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
  velocity(Vessel, Speed, _, T),
  Speed =< 5.

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, CoG, _TrueHeading), T),
  holdsAt(driftingConditions(CoG, Speed) = true, T).

terminatedAt(drifting(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, CoG, _TrueHeading), T),
  not holdsAt(driftingConditions(CoG, Speed) = true, T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),
  holdsAt(trawlingSpeed(Vessel) = true, T),
  checkHeadingVariability(Vessel, T).

terminatedAt(trawlingMovement(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),
  not holdsAt(trawlingSpeed(Vessel) = true, T).

terminatedAt(trawlingMovement(Vessel) = true, T) :-
  not checkHeadingVariability(Vessel, T).

holdsFor(trawling(Vessel) = true, I) :-
  holdsFor(velocity(Vessel, Speed) = trawlingSpeed, I1),
  holdsFor(withinArea(Vessel, fishingArea) = true, I2),
  intersect_all([I1, I2], I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) :-
holdsFor(stopped(Vessel) = farFromPorts, Isffp),
holdsFor(withinArea(Vessel, anchorage) = true, Iwa),
intersect_all([Isffp,Iwa],Isa),
holdsFor(stopped(Vessel) = nearPorts, Isn),
union_all([Isa,Isn],Ii),
threshold(vaorm, Vaorm), intDurGreater(Ii, Vaorm,I).

%---------------- tugging (B) ----------------%

holdsFor(tugging(Vessel1, Vessel2) = true, I) :-
  holdsFor(proximity(Vessel1, Vessel2) = true, Ip),
  holdsFor(lowSpeed(Vessel1) = true, Is1),
  holdsFor(lowSpeed(Vessel2) = true, Is2),
  intersect_all([Ip, Is1, Is2], I).

%-------- pilotOps ---------------------------%

holdsFor(piloting(PilotBoat, NavigatedVessel) = true, I) :-
  holdsFor(proximity(PilotBoat, NavigatedVessel) = true, Ip),
  holdsFor(pilotOps(PilotBoat, NavigatedVessel) = true, Io),
  intersect_all([Ip, Io], I).

%---------------- rendezVous -----------------%

holdsFor(rendezVous(Vessel1, Vessel2) = true, I) :-
  holdsFor(proximity(Vessel1, Vessel2) = true, Ip),
  holdsFor(stopped(Vessel1) = true, Is1),
  holdsFor(stopped(Vessel2) = true, Is2),
  union_all([Is1, Is2], Is),
  intersect_all([Ip, Is], I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
  holdsFor(withinArea(Vessel, Area) = true, Ia),
  holdsFor(velocity(Vessel, Speed, _, _) = stopped, Iv),
  intersect_all([Ia, Iv], I),
  threshold(vloiter, Vloiter),
  intDurGreater(I, Vloiter, I).