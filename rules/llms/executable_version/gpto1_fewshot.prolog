
%----------------within area -----------------%

initiatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, AreaType).

terminatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, AreaType).

terminatedAt(withinArea(Vessel, _AreaType)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_Status, T) :-
    happensAt(gap_end(Vessel), T).

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
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, AreaID), T),
    areaType(AreaID, nearCoast),
    happensAt(velocity(Vessel, Speed, _, _), T),
    %holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, nearCoast).

%--------------- movingSpeed -----------------%

% LLM attempted to introduce a real-valued fluent, which we do not allow.

%initiatedAt(currentSpeed(Vessel)=Speed, T) :-
    %happensAt(velocity(Vessel, Speed, _, _), T).

%terminatedAt(currentSpeed(Vessel)=_, T) :-
    %happensAt(velocity(Vessel, _, _, _), T).

initiatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    %holdsAt(currentSpeed(Vessel)=Speed, T),
    thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, _, _),
    Speed >= MovingMin,
    Speed < MinSpeed.

initiatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    %holdsAt(currentSpeed(Vessel)=Speed, T),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, MaxSpeed, _),
    Speed >= MinSpeed,
    Speed =< MaxSpeed.

initiatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _, MaxSpeed, _),
    Speed > MaxSpeed.

terminatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    %vesselType(Vessel, Type),
    %typeSpeed(Type, MinSpeed, _, _),
    Speed < MovingMin.
terminatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    %thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, _, _),
    Speed >= MinSpeed.

terminatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, MinSpeed, _MaxSpeed, _),
    Speed < MinSpeed.
terminatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _MinSpeed, MaxSpeed, _),
    Speed > MaxSpeed.

terminatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    %vesselType(Vessel, Type),
    %typeSpeed(Type, _, MaxSpeed, _),
    Speed < MovingMin.
terminatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    %thresholds(movingMin, MovingMin),
    vesselType(Vessel, Type),
    typeSpeed(Type, _, MaxSpeed, _),
    Speed =< MaxSpeed.

terminatedAt(movingSpeed(Vessel)=_, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(movingSpeed(Vessel)=_, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

%----------------- underWay ------------------% 

holdsFor(underWay(Vessel)=true, I) :-
    holdsFor(movingSpeed(Vessel)=below, I1),
    holdsFor(movingSpeed(Vessel)=normal, I2),
    holdsFor(movingSpeed(Vessel)=above, I3),
    union_all([I1,I2,I3], I).

%----------------- drifitng ------------------%

%initiatedAt(currentAngleDifference(Vessel)=Difference, T) :-
    %happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    %Difference1 is abs(CourseOverGround - TrueHeading),
    %Difference2 is 360 - Difference1,
    %DifferenceAngle is min(Difference1, Difference2),
    %Difference = DifferenceAngle.

%terminatedAt(currentAngleDifference(Vessel)=_, T) :-
    %happensAt(velocity(Vessel, _, _, _), T).

initiatedAt(drifting(Vessel)=true, T) :-
    %holdsAt(currentAngleDifference(Vessel)=Difference, T),
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    Difference1 is abs(CourseOverGround - TrueHeading),
    Difference2 is 360 - Difference1,
    DifferenceAngle is min(Difference1, Difference2),
    Difference = DifferenceAngle,
    thresholds(adriftAngThr, AdriftAngThr),
    Difference > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    Difference1 is abs(CourseOverGround - TrueHeading),
    Difference2 is 360 - Difference1,
    DifferenceAngle is min(Difference1, Difference2),
    Difference = DifferenceAngle,
    thresholds(adriftAngThr, AdriftAngThr),
    Difference =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, AreaID), T),
    %areaType(AreaID, fishingArea),
    areaType(AreaID, fishing),
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    %thresholds(trawlspeedMax, TrawlspeedMax),
    Speed < TrawlspeedMin.
terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    %thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishing).
    %areaType(AreaID, fishingArea).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishing).

fi(trawlingMovement(Vessel)=true, trawlingMovement(Vessel)=false, TrawlingCrs):-
    thresholds(trawlingCrs, TrawlingCrs).
p(trawlingMovement(_Vessel)=true).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlSpeed(Vessel)=true, I1),
    holdsFor(trawlingMovement(Vessel)=true, I2),
    holdsFor(withinArea(Vessel, fishing)=true, I3),
    intersect_all([I1, I2, I3], I_temp),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(I_temp, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

%holdsFor(stopped(Vessel)=true, I_stop) :-
    %holdsFor(stopped(Vessel), I_stop).

%holdsFor(withinArea(Vessel, anchorageArea)=true, I_anchorage) :-
    %holdsFor(withinArea(Vessel, anchorageArea)=true, I_anchorage).

%holdsFor(withinArea(Vessel, nearPorts)=true, I_nearPorts) :-
    %holdsFor(withinArea(Vessel, nearPorts)=true, I_nearPorts).

%intersect_all([I_stop, I_anchorage], I_stoppedAnchorage).

%relative_complement_all(I_stoppedAnchorage, [I_nearPorts], I_anchoredFarFromPorts).

%intersect_all([I_stop, I_nearPorts], I_mooredNearPorts).

%holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    %union_all([I_anchoredFarFromPorts, I_mooredNearPorts], I).

holdsFor(anchoredOrMoored(Vessel)=true, I):-
    holdsFor(stopped(Vessel)=farFromPorts, I_stop),
    holdsFor(withinArea(Vessel, anchorage)=true, I_anchorage),
    intersect_all([I_stop, I_anchorage], I_stoppedAnchorage),
    holdsFor(withinArea(Vessel, nearPorts)=true, I_nearPorts),
    relative_complement_all(I_stoppedAnchorage, [I_nearPorts], I_anchoredFarFromPorts),
    holdsFor(stopped(Vessel)=nearPorts, I_stop_np),
    intersect_all([I_stop_np, I_nearPorts], I_mooredNearPorts),
    union_all([I_anchoredFarFromPorts, I_mooredNearPorts], I).

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

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    %thresholds(tuggingMax, TuggingMax),
    Speed < TuggingMin.
terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    %thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, I_proximity),
    holdsFor(tuggingSpeed(Vessel1)=true, I_speed1),
    holdsFor(tuggingSpeed(Vessel2)=true, I_speed2),
    intersect_all([I_proximity, I_speed1, I_speed2], I_temp),
    oneIsTug(Vessel1, Vessel2),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(I_temp, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, I_proximity),
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeedOrStoppedFar(Vessel1)=true, I_movement1),
    holdsFor(lowSpeedOrStoppedFar(Vessel2)=true, I_movement2),
    intersect_all([I_proximity, I_movement1, I_movement2], I_temp),
    holdsFor(withinArea(Vessel1, nearCoast)=true, I_nearCoast1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, I_nearCoast2),
    relative_complement_all(I_temp, [I_nearCoast1, I_nearCoast2], I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

fi(sarMovement(Vessel)=true, sarMovement(Vessel)=false, 1800).
p(sarMovement(_Vessel)=true).

holdsFor(inSAR(Vessel)=true, I) :-
    %vesselType(Vessel, pilotVessel),
    holdsFor(sarSpeed(Vessel)=true, I1),
    holdsFor(sarMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I).

%-------- loitering --------------------------%

% wow
% this type of hierarchy is allowed, because the value of the introduced fluent is discrete.
holdsFor(lowSpeedOrStoppedFar(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I_lowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, I_stoppedFar),
    union_all([I_lowSpeed, I_stoppedFar], I).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeedOrStoppedFar(Vessel)=true, I1),
    holdsFor(anchoredOrMoored(Vessel)=true, I_anchorMoored),
    holdsFor(withinArea(Vessel, nearCoast)=true, I_nearCoast),
    relative_complement_all(I1, [I_anchorMoored, I_nearCoast], I_temp),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_temp, LoiteringTime, I).

% proximity is an input statically determined fluent.
% its instances arrive in the form of intervals.
collectIntervals(proximity(_,_)=true).

% The elements of these domains are derived from the ground arguments of input entitites
dynamicDomain(vessel(_Vessel)).
dynamicDomain(vpair(_Vessel1,_Vessel2)).

% Groundings of input entities
grounding(change_in_speed_start(V)):- vessel(V).
grounding(change_in_speed_end(V)):- vessel(V).
grounding(change_in_heading(V)):- vessel(V).
grounding(stop_start(V)):- vessel(V).
grounding(stop_end(V)):- vessel(V).
grounding(slow_motion_start(V)):- vessel(V).
grounding(slow_motion_end(V)):- vessel(V).
grounding(gap_start(V)):- vessel(V).
grounding(gap_end(V)):- vessel(V).
grounding(entersArea(V,Area)):- vessel(V), areaType(Area).
grounding(leavesArea(V,Area)):- vessel(V), areaType(Area).
grounding(coord(V,_,_)):- vessel(V).
grounding(velocity(V,_,_,_)):- vessel(V).
grounding(proximity(Vessel1, Vessel2)=true):- vpair(Vessel1, Vessel2).

% Groundings of output entities
grounding(gap(Vessel)=PortStatus):-
    vessel(Vessel), portStatus(PortStatus).
grounding(stopped(Vessel)=PortStatus):-
    vessel(Vessel), portStatus(PortStatus).
grounding(lowSpeed(Vessel)=true):-
    vessel(Vessel).
grounding(changingSpeed(Vessel)=true):-
    vessel(Vessel).
grounding(withinArea(Vessel, AreaType)=true):-
    vessel(Vessel), areaType(AreaType).
grounding(underWay(Vessel)=true):-
    vessel(Vessel).
grounding(sarSpeed(Vessel)=true):-
    vessel(Vessel), vesselType(Vessel,sar).
grounding(sarMovement(Vessel)=true):-
    vessel(Vessel), vesselType(Vessel,sar).
grounding(sarMovement(Vessel)=false):-
    vessel(Vessel), vesselType(Vessel,sar).
grounding(inSAR(Vessel)=true):-
    vessel(Vessel).
grounding(highSpeedNearCoast(Vessel)=true):-
    vessel(Vessel).
grounding(drifting(Vessel)=true):-
    vessel(Vessel).
grounding(anchoredOrMoored(Vessel)=true):-
    vessel(Vessel).
grounding(trawlSpeed(Vessel)=true):-
    vessel(Vessel), vesselType(Vessel,fishing).
grounding(movingSpeed(Vessel)=Status):-
    vessel(Vessel), movingStatus(Status).
grounding(pilotOps(Vessel1, Vessel2)=true):-
    vpair(Vessel1, Vessel2).
grounding(tuggingSpeed(Vessel)=true):-
    vessel(Vessel).
grounding(tugging(Vessel1, Vessel2)=true):-
    vpair(Vessel1, Vessel2).
grounding(rendezVous(Vessel1, Vessel2)=true):-
    vpair(Vessel1, Vessel2).
grounding(trawlingMovement(Vessel)=true):-
    vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawlingMovement(Vessel)=false):-
    vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawling(Vessel)=true):-
    vessel(Vessel).
grounding(lowSpeedOrStoppedFar(Vessel)=true):-
    vessel(Vessel).
grounding(loitering(Vessel)=true):-
    vessel(Vessel).

needsGrounding(_, _, _) :-
    fail.
buildFromPoints(_) :-
    fail.
