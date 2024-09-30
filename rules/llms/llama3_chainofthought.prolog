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

initiatedAt(stopped(Vessel), I) :-
  happensAt(presentIn(Vessel, Position), It),
  speedOverGround(Vessel, Position) =< thresholdLowSpeed,
  not_holdsFor(speedOverGround(Vessel, Position) > thresholdLowSpeed, It).

terminatedAt(stopped(Vessel), T) :-
  happensAt(not_presentIn(Vessel, Position), Ta),
  speedOverGround(Vessel, Position) > thresholdLowSpeed.

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel), I) :-
  exists(Message, in(recentMessages, Message)),
  speedOverGround(Vessel, Message) =< vmin,
  all(Message, in(recentMessages, Message), speedOverGround(Vessel, Message) =< vmin).

terminatedAt(lowSpeed(Vessel), T) :-
  exists(Message, not_in(recentMessages, Message)),
  speedOverGround(Vessel, Message) > vmin.

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel), I) :-
  happensAt(speedOverGround(Vessel, Position), vnow),
  abs(vnow - vprev) > alpha,
  not_holdsFor(abs(vnow - vprev) =< alpha, previouslyObserved(I - timeStep)).

terminatedAt(changingSpeed(Vessel), T) :-
  happensAt(speedOverGround(Vessel, NewPosition), vnew),
  abs(vnew - vnow) =< alpha.

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeed(Vessel)=true,T) :- 
  happensAt(enterArea(Vessel, nearCoast),T), 
  highSpeed(Vessel)>highSpeedLimit.

terminatedAt(highSpeed(Vessel)=true,T) :- 
  happensAt(exitArea(Vessel, 
  nearCoast),T), 
  highSpeed(Vessel)<lowSpeedLimit.

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel, "below"), I) :-
  speedOverGround(Vessel, Position) =< minServiceSpeed * 0.5,
  not_holdsFor(speedOverGround(Vessel, Position) > minServiceSpeed * 0.5, previouslyObserved(I - timeStep)).

initiatedAt(movingSpeed(Vessel, "normal"), I) :-
  speedOverGround(Vessel, Position) >= minServiceSpeed,
  speedOverGround(Vessel, Position) =< maxServiceSpeed,
  not_holdsFor(speedOverGround(Vessel, Position) < minServiceSpeed, previouslyObserved(I - timeStep)),
  not_holdsFor(speedOverGround(Vessel, Position) > maxServiceSpeed, previouslyObserved(I - timeStep)).

initiatedAt(movingSpeed(Vessel, "above"), I) :-
  speedOverGround(Vessel, Position) >= maxServiceSpeed,
  not_holdsFor(speedOverGround(Vessel, Position) < maxServiceSpeed, previouslyObserved(I - timeStep)).

terminatedAt(movingSpeed(Vessel, "below"), T) :-
  speedOverGround(Vessel, NewPosition) > minServiceSpeed * 0.5.

terminatedAt(movingSpeed(Vessel, "normal"), T) :-
  speedOverGround(Vessel, NewPosition) < minServiceSpeed.

terminatedAt(movingSpeed(Vessel, "normal"), T) :-
  speedOverGround(Vessel, NewPosition) > maxServiceSpeed.

terminatedAt(movingSpeed(Vessel, "above"), T) :-
  speedOverGround(Vessel, NewPosition) < maxServiceSpeed.

%----------------- underWay ------------------% 

holdsFor(underway(Vessel), T) :-
  or(
    speedOverGround(Vessel, Position) =< minServiceSpeed * 0.5,
    (speedOverGround(Vessel, Position) >= minServiceSpeed),
      (speedOverGround(Vessel, Position) =< maxServiceSpeed),
    speedOverGround(Vessel, Position) >= maxServiceSpeed
  ),
  all(
    previouslyObserved(I - timeStep), \+underway(Vessel),
    I = T
  ).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :- 
  happensAt(velocity(Vessel, CoG, _CoG, TrueHeading), T), 
  abs(diff(CoG, TrueHeading)) > driftThreshold.

terminatedAt(drifting(Vessel) = true, T) :- 
   happensAt(velocity(Vessel, CoG, _CoG, TrueHeading), T), 
   abs(diff(CoG, TrueHeading)) =< driftThreshold.

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel), I) :-
  speedOverGround(Vessel, Position) >= minTrawlSpeed,
  speedOverGround(Vessel, Position) =< maxTrawlSpeed,
  not_holdsFor(speedOverGround(Vessel, Position) < minTrawlSpeed, previouslyObserved(I - timeStep)),
  not_holdsFor(speedOverGround(Vessel, Position) > maxTrawlSpeed, previouslyObserved(I - timeStep)).

terminatedAt(trawlSpeed(Vessel), T) :-
  or(
    speedOverGround(Vessel, NewPosition) < minTrawlSpeed,
    speedOverGround(Vessel, NewPosition) > maxTrawlSpeed
  ).

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
holdsFor((vesselType(Vessel, fishing), 
   exists(MaxHeadingAngle, MinHeadingAngle), 
   abs(diff(MaxHeadingAngle, MinHeadingAngle)) > trawlingThresholdHeadingAngle))):- _.

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

%-------------------------- SAR --------------%

initiatedAt(sarResult(Vessel), I) :-
  absHeadingDifference(Vessel, PreviousHeading) >= headingChangeThreshold,
  speedOverGround(Vessel, Position) =< minSARSpeed,
  not_holdsFor(absHeadingDifference(Vessel, NewPreviousHeading) < headingChangeThreshold, previouslyObserved(I - timeStep)),
  not_holdsFor(speedOverGround(Vessel, NewPosition) > minSARSpeed, previouslyObserved(I - timeStep)).

terminatedAt(sarResult(Vessel), T) :-
  and(
    absHeadingDifference(Vessel, PreviousHeading) < headingChangeThreshold,
    speedOverGround(Vessel, NewPosition) > minSARSpeed
  ).

holdsFor(sarResult(Vessel), T) :-
  absHeadingDifference(Vessel, PreviousHeading) >= headingChangeThreshold,
  speedOverGround(Vessel, Position) =< minSARSpeed,
  all(
    previouslyObserved(I - timeStep), \+sarResult(Vessel),
    I = T
  ).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
  holdsFor(presentIn(Vessel, ParticularArea), Isa),
  intDurGreater(Isa, Vlong, I),
  not_holdsFor(evidentPurpose(Vessel), Isa),
  threshold(vloiter, Vloiter), intDurGreater(I, Vloiter,I).