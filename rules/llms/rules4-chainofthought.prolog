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
holdsAt(movingSpeed(Vessel) = above, T),
holdsAt(nearCoast(Vessel) = true, T),
movingSpeed(Vessel) > 5. 

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
holdsAt(movingSpeed(Vessel) = normal, T),
not holdsAt(nearCoast(Vessel) = true, T).

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
holdsAt(movingSpeed(Vessel) = below, T),
holdsAt(nearCoast(Vessel) = true, T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :-
happensAt(courseOverGround(Vessel, CoG), T),
threshold(deviation, MaxDeviation),
deviation(CoG, _TrueHeading, Deviation),
Deviation > MaxDeviation.

terminatedAt(drifting(Vessel) = true, T) :-
happensAt(courseOverGround(Vessel, CoG), T),
threshold(deviation, MaxDeviation),
deviation(CoG, _TrueHeading, Deviation),
Deviation ≤ MaxDeviation.

%--------------- trawling --------------------%

initiatedAt(trawling(Vessel) = true, T) :-
happensAt(velocity(Vessel, Speed, CoG, TrueHeading), T),
trawlingSpeed(Vessel, MinSpeed, MaxSpeed),
Speed >= MinSpeed,
Speed <= MaxSpeed,
headingDistribution(Vessel, HeadingDist),
HeadingDist >= trawlingAngle(Vessel).

terminatedAt(trawling(Vessel) = true, T) :-
happensAt(velocity(Vessel, Speed, CoG, TrueHeading), T),
trawlingSpeed(Vessel, MinSpeed, MaxSpeed),
(Speed < MinSpeed;
 Speed > MaxSpeed),
headingDistribution(Vessel, HeadingDist),
HeadingDist < trawlingAngle(Vessel).

holdsFor(trawlingMovement(Vessel) = true, I) :-
holdsFor(change_in_heading(Vessel) = true, I1),
holdsFor(withinArea(Vessel, fishing) = true, I2),
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
    holdsFor(close(Vessel1, Vessel2) = true, Ic),
    holdsFor(movingSpeed(Vessel1) = below, Is1),
    holdsFor(movingSpeed(Vessel2) = below, Is2),
    intersect_all([Ic, Is1, Is2], I).

%-------- pilotOps ---------------------------%

holdsFor(piloting(Vessel, PilotBoat) = true, I) :-
    holdsFor(close(PilotBoat, Vessel) = true, Ic),
    holdsFor(approaching(PilotBoat, Vessel) = true, Ia),
    holdsFor(boarding(PilotBoat, Vessel) = true, Ib),
    holdsFor(navigationalExpert(PilotBoat) = true, In),
    intersect_all([Ic, Ia, Ib, In], I).

%---------------- rendezVous -----------------%

holdsFor(rendezVous(Vessel1, Vessel2) = true, I) :-
    holdsFor(close(Vessel1, Vessel2) = true, Ic),
    holdsFor(stopped(Vessel1) = true, Is1),
    holdsFor(lowSpeed(Vessel1) = true, Ils1),
    holdsFor(stopped(Vessel2) = true, Is2),
    holdsFor(lowSpeed(Vessel2) = true, Ils2),
    
    union_all([Is1, Ils1], I1),
    union_all([Is2, Ils2], I2),
    
    intersect_all([I1, I2], Ii),
    intersect_all([Ic, Ii], I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
    holdsFor(withinArea(Vessel, Area) = true, Iwa),
    threshold(vloiter, Vloiter),
    intDurGreater(Iwa, Vloiter, I).