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

%-------------- stopped-----------------------%

initiatedAt(stopped(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed =< LowThreshold.

terminatedAt(stopped(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > LowThreshold.

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel) = true, T) :-
  countRecentMessagesUnderThreshold(Vessel, Tmin, NumMessages, Vmin),
  NumMessages >= m.

terminatedAt(lowSpeed(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > Vmin.

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel) = true, T) :-
  happensAt(velocity(Vessel, CurrentSpeed, _, _), T),
  holdsAt(velocity(Vessel, PreviousSpeed, _, _) = previous(T), Tprev),  % assuming 'previous' captures the last known speed
  abs(CurrentSpeed - PreviousSpeed) / PreviousSpeed > a / 100.

terminatedAt(changingSpeed(Vessel) = true, T) :-
  happensAt(velocity(Vessel, CurrentSpeed, _, _), T),
  holdsAt(velocity(Vessel, PreviousSpeed, _, _) = previous(T), Tprev),
  abs(CurrentSpeed - PreviousSpeed) / PreviousSpeed =< a / 100.

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

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel) = below, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > 0.5,
  Speed =< MinServiceSpeed.

initiatedAt(movingSpeed(Vessel) = normal, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > MinServiceSpeed,
  Speed =< MaxServiceSpeed.

initiatedAt(movingSpeed(Vessel) = above, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > MaxServiceSpeed.

terminatedAt(movingSpeed(Vessel) = below, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > MinServiceSpeed.

terminatedAt(movingSpeed(Vessel) = normal, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed =< MinServiceSpeed.

terminatedAt(movingSpeed(Vessel) = normal, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > MaxServiceSpeed.

terminatedAt(movingSpeed(Vessel) = above, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed =< MaxServiceSpeed.

%----------------- underWay ------------------% 

holdsFor(underWay(Vessel) = true, I) :-
  holdsFor(movingSpeed(Vessel) = below, Ib),
  holdsFor(movingSpeed(Vessel) = normal, In),
  holdsFor(movingSpeed(Vessel) = above, Ia),
  union_all([Ib, In, Ia], I).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, CoG, _TrueHeading), T),
  holdsAt(driftingConditions(CoG, Speed) = true, T).

terminatedAt(drifting(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, CoG, _TrueHeading), T),
  not holdsAt(driftingConditions(CoG, Speed) = true, T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed >= 1.0,
  Speed =< 9.0.

terminatedAt(trawlingSpeed(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed < 1.0.

terminatedAt(trawlingSpeed(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > 9.0.

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

%-------------------------- SAR --------------%

initiatedAt(sarOperation(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  happensAt(change_in_heading(Vessel), T),
  Speed =< SARMinSpeed,  
  holdsAt(onSARduty(Vessel) = true, T).  

terminatedAt(sarOperation(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  Speed > SARMinSpeed.

terminatedAt(sarOperation(Vessel) = true, T) :-
  happensAt(velocity(Vessel, Speed, _, _), T),
  not happensAt(change_in_heading(Vessel), T).

holdsFor(sarOperation(Vessel) = true, I) :-
  holdsFor(velocity(Vessel, Speed) = sarSpeed, Iv),
  holdsFor(change_in_heading(Vessel) = true, Ih),
  intersect_all([Iv, Ih], I),
  threshold(minSarDuration, MinDuration),
  intDurGreater(I, MinDuration, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
  holdsFor(withinArea(Vessel, Area) = true, Ia),
  holdsFor(velocity(Vessel, Speed, _, _) = stopped, Iv),
  intersect_all([Ia, Iv], I),
  threshold(vloiter, Vloiter),
  intDurGreater(I, Vloiter, I).
