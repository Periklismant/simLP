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

initiatedAt(highSpeed(Vessel)=true,T) :- 
  happensAt(enterArea(Vessel, nearCoast),T), 
  highSpeed(Vessel)>highSpeedLimit.

terminatedAt(highSpeed(Vessel)=true,T) :- 
  happensAt(exitArea(Vessel, 
  nearCoast),T), 
  highSpeed(Vessel)<lowSpeedLimit.

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :- 
  happensAt(velocity(Vessel, CoG, _CoG, TrueHeading), T), 
  abs(diff(CoG, TrueHeading)) > driftThreshold.

terminatedAt(drifting(Vessel) = true, T) :- 
   happensAt(velocity(Vessel, CoG, _CoG, TrueHeading), T), 
   abs(diff(CoG, TrueHeading)) =< driftThreshold.

%--------------- trawling --------------------%

initiatedAt(trawling(Vessel) = true, T) :- 
  happensAt(velocity(Vessel, Speed, CoG, TrueHeading), T), 
  Speed > trawlingThresholdSpeed, 
  abs(diff(MaxHeadingAngle, MinHeadingAngle)) > trawlingThresholdHeadingAngle.

terminatedAt(trawling(Vessel) = true, T) :- 
  happensAt(velocity(Vessel, Speed, CoG, TrueHeading), T), 
  Speed =< trawlingThresholdSpeed, 
  abs(diff(MaxHeadingAngle, MinHeadingAngle)) =< trawlingThresholdHeadingAngle.

staticallyDetermined(trawling(Vessel) = 
holdsFor(vesselType(Vessel, fishing), 
   exists(MaxHeadingAngle, MinHeadingAngle), 
   abs(diff(MaxHeadingAngle, MinHeadingAngle)) > trawlingThresholdHeadingAngle)):- _.

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) :-
holdsFor(stopped(Vessel) = farFromPorts, Isffp),
holdsFor(withinArea(Vessel, anchorage) = true, Iwa),
intersect_all([Isffp,Iwa],Isa),
holdsFor(stopped(Vessel) = nearPorts, Isn),
union_all([Isa,Isn],Ii),
threshold(vaorm, Vaorm), intDurGreater(Ii, Vaorm,I).

%---------------- tugging (B) ----------------%

holdsFor(tugging(Vessel) = true, I) :-
  holdsFor(notMovingByItself(Vessel), It),
  happensAt(association(Vessel, Tugboat), Itc),
  intersect_all([It, Itc], Isa),
  holdsFor(closeToEachOther(Vessel, Tugboat) = true, Isa),
  holdsFor(lowerThanNormalSpeed(Vessel) = true, Isa),
  threshold(vtug, Vtug), intDurGreater(Isa, Vtug,I).

%-------- pilotOps ---------------------------%

holdsFor(piloting(Vessel) = true, I) :-
  holdsFor(highlyExperiencedSailor(MaritimePilot), It),
  happensAt(approaches(PilotBoat, Vessel), Itc),
  happensAt(boards(MaritimePilot, Vessel), Ib),
  holdsFor(manoeuvres(Vessel, MaritimePilot) = true, Ia),
  intersect_all([It, Itc], Isa),
  intersect_all([It, Ib], Isb),
  union_all([Isa, Isb], I),
  threshold(vpil, Vpil), intDurGreater(I, Vpil,I).

%---------------- rendezVous -----------------%

holdsFor(rendezVous(Vessel1, Vessel2) = true, I) :-
  holdsFor(nearbyInOpenSea(Vessel1, Vessel2), Isa),
  holdsFor(stoppedOrLowSpeed(Vessel1) = true, Isf),
  holdsFor(stoppedOrLowSpeed(Vessel2) = true, Isb),
  intersect_all([Isa, Isf], Isa),
  intersect_all([Isa, Isb], Isb),
  union_all([Isa, Isf, Isb], I),
  threshold(vrendez, Vrendez), intDurGreater(I, Vrendez, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
  holdsFor(presentIn(Vessel, ParticularArea), Isa),
  intDurGreater(Isa, Vlong, I),
  not holdsFor(evidentPurpose(Vessel), Isa),
  threshold(vloiter, Vloiter), intDurGreater(I, Vloiter,I).