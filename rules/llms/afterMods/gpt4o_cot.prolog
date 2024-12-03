
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
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, _AreaID), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

%--------------- movingSpeed -----------------%

holdsFor(movingSpeed(Vessel)=below, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, _Max, _Avg),
    Speed < Min,
    \+ happensAt(gap_start(Vessel), T),
    holdsFor(movingSpeed(Vessel)=below, I).

holdsFor(movingSpeed(Vessel)=normal, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _Avg),
    Speed >= Min,
    Speed =< Max,
    \+ happensAt(gap_start(Vessel), T),
    holdsFor(movingSpeed(Vessel)=normal, I).

holdsFor(movingSpeed(Vessel)=above, I) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _Min, Max, _Avg),
    Speed > Max,
    \+ happensAt(gap_start(Vessel), T),
    holdsFor(movingSpeed(Vessel)=above, I).

terminatedAt(movingSpeed(Vessel)=_, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=_, T) :-
    happensAt(gap_start(Vessel), T).

%----------------- underWay ------------------% 

holdsFor(underWay(Vessel)=true, I) :-
	holdsFor(movingSpeed(Vessel)=below, I1),
	holdsFor(movingSpeed(Vessel)=normal, I2),
	holdsFor(movingSpeed(Vessel)=above, I3),
	union_all([I1,I2,I3], I).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _Speed, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    AngleDifference is abs(CourseOverGround - TrueHeading),
    AngleDifference > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _Speed, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    AngleDifference is abs(CourseOverGround - TrueHeading),
    AngleDifference =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    %holdsAt(withinArea(Vessel, fishingArea)=true, T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, _TrawlspeedMax),
    Speed < TrawlspeedMin.
terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(trawlspeedMin, _TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed > TrawlspeedMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    %holdsAt(withinArea(Vessel, fishingArea)=true, T).
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, _AreaID), T),
    %holdsAt(withinArea(Vessel, fishingArea)=true, T).
    holdsAt(withinArea(Vessel, fishing)=true, T).

fi(trawlingMovement(Vessel)=true, trawlingMovement(Vessel)=false, TrawlingCrs):-
    thresholds(trawlingCrs, TrawlingCrs).
p(trawlingMovement(_Vessel)=true).

holdsFor(trawling(Vessel)=true, I) :-
    %holdsFor(withinArea(Vessel, fishingArea)=true, I1),
    holdsFor(withinArea(Vessel, fishing)=true, I1),
    holdsFor(trawlSpeed(Vessel)=true, I2),
    holdsFor(trawlingMovement(Vessel)=true, I3),
    intersect_all([I1, I2, I3], Ii),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(Ii, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

% CHANGE: I removed all disjunctions from statically determined fluent definitions.
%         The intention was to put a comma there, and use the corresponding FVP in a union operator.

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    %holdsFor(stopped(Vessel)=true, Is),
    holdsFor(stopped(Vessel)=farFromPorts, Is1),
    holdsFor(stopped(Vessel)=nearPorts, Is2),
            %holdsFor(withinArea(Vessel, anchorageArea)=true, Ia1),
            holdsFor(withinArea(Vessel, anchorage)=true, Ia1),
            holdsFor(withinArea(Vessel, nearPorts)=true, Ia2),
            relative_complement_all(Is1, [Ia2], Iaf),
            intersect_all([Ia1, Iaf], Ianchored),
            holdsFor(withinArea(Vessel, nearPorts)=true, InP),
            intersect_all([Is2, InP], Imoored),
    union_all([Ianchored, Imoored], I).

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
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, _TuggingMax),
    Speed < TuggingMin.
terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(tuggingMin, _TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    %vesselType(Vessel1, tugboat),
    oneIsTug(Vessel1, Vessel2),
    holdsFor(tuggingSpeed(Vessel1)=true, Is1),
    holdsFor(tuggingSpeed(Vessel2)=true, Is2),
    intersect_all([Ip, Is1, Is2], IcloseSpeed),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(IcloseSpeed, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    %vesselType(Vessel1, pilotVessel),
    oneIsPilot(Vessel1, Vessel2),
        holdsFor(lowSpeed(Vessel1)=true, Il1),
        %holdsFor(stopped(Vessel1)=farFromPorts, Is1),
        holdsFor(lowSpeed(Vessel2)=true, Il2),
        %holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    intersect_all([Ip, Il1, Il2], IcloseSpeed),
    %holdsFor(withinArea(Vessel1, nearCoast)=false, In1),
    %holdsFor(withinArea(Vessel2, nearCoast)=false, In2),
    %intersect_all([IcloseSpeed, In1, In2], Ifinal),
    holdsFor(withinArea(Vessel1, nearCoast)=true, In1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, In2),
    relative_complement_all(IcloseSpeed, [In1, In2], Ifinal),
    Ifinal \= [],
    I = Ifinal.

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed > SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _CourseOverGround, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed =< SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

fi(sarMovement(Vessel)=true, sarMovement(Vessel)=false, 1800).
p(sarMovement(_Vessel)=true).

holdsFor(inSAR(Vessel)=true, I) :-
    %vesselType(Vessel, pilotVessel),
    holdsFor(sarSpeed(Vessel)=true, Ispeed),
    holdsFor(sarMovement(Vessel)=true, Imovement),
    intersect_all([Ispeed, Imovement], I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, IlowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, Iidle),
    holdsFor(anchoredOrMoored(Vessel)=true, Ianm),
    %holdsFor(withinArea(Vessel, nearCoast)=false, InotCoast),
    holdsFor(withinArea(Vessel, nearCoast)=true, ICoast),
    %intersect_all([IlowSpeed, Iidle, InotCoast], Iloafing),
    %relative_complement_all(Iloafing, [Ianm], Ifiltered),
    intersect_all([IlowSpeed, Iidle], Iloafing),
    relative_complement_all(Iloafing, [Ianm, ICoast], Ifiltered),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(Ifiltered, LoiteringTime, I).

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
grounding(loitering(Vessel)=true):-
    vessel(Vessel).

needsGrounding(_, _, _) :-
    fail.
buildFromPoints(_) :-
    fail.
