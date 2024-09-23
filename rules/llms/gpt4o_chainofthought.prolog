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
    holdsAt(coord(Vessel, X, Y), T),  
    nearCoast(X, Y),  
    holdsAt(velocity(Vessel, Speed, _, _), T),  
    Speed > 5. 

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),  
    Speed =< 5.  

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(gap_start(Vessel), T). 

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :-
    happensAt(velocity(Vessel, _Speed, CoG, TrueHeading), T),
    threshold(cog_threshold, Threshold),  
    abs(CoG - TrueHeading) > Threshold.   

terminatedAt(drifting(Vessel) = true, T) :-
    happensAt(velocity(Vessel, _Speed, CoG, TrueHeading), T),
    threshold(cog_threshold, Threshold),  
    abs(CoG - TrueHeading) =< Threshold.  

terminatedAt(drifting(Vessel) = true, T) :-
    happensAt(gap_start(Vessel), T).  

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel) = true, T) :-
    holdsAt(trawlingSpeed(Vessel) = true, T),  
    wideHeadingDistribution(Vessel, T).  

terminatedAt(trawlingMovement(Vessel) = true, T) :-
    not holdsAt(trawlingSpeed(Vessel) = true, T).  

terminatedAt(trawlingMovement(Vessel) = true, T) :-
    not wideHeadingDistribution(Vessel, T).  

holdsFor(trawlingMovement(Vessel) = true, I) :-
    holdsFor(withinArea(Vessel, fishing) = true, I1),  
    eventsToIntervals(change_in_heading(Vessel), I2),  
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
    holdsFor(lowSpeed(Vessel1) = true, Ils1),  
    holdsFor(lowSpeed(Vessel2) = true, Ils2),  
    holdsFor(tuggingSpeed(Vessel1) = true, Its1),  
    holdsFor(tuggingSpeed(Vessel2) = true, Its2), 
    union_all([Ils1, Its1], I1),  
    union_all([Ils2, Its2], I2),  
    intersect_all([Ip, I1, I2], Ii), 
    threshold(vtug, Vtug),  
    intDurGreater(Ii, Vtug, I).  

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2) = true, I) :-
    holdsFor(proximity(Vessel1, Vessel2) = true, Ip),  
    holdsFor(lowSpeed(Vessel1) = true, Ils1),  
    holdsFor(lowSpeed(Vessel2) = true, Ils2), 
    holdsFor(movingSpeed(Vessel1) = below, Im1),  
    holdsFor(movingSpeed(Vessel2) = below, Im2),  
    holdsFor(underWay(Vessel1) = true, Iuw1),  
    holdsFor(underWay(Vessel2) = true, Iuw2),  
    union_all([Ils1, Im1], I1), 
    union_all([Ils2, Im2], I2),  
    intersect_all([Ip, I1, I2, Iuw1, Iuw2], Ii),  
    threshold(vpilot, Vpilot),  
    intDurGreater(Ii, Vpilot, I).  

%---------------- rendezVous -----------------%

holdsFor(rendezVous(Vessel1, Vessel2) = true, I) :-
    holdsFor(proximity(Vessel1, Vessel2) = true, Ip),  
    holdsFor(stopped(Vessel1) = farFromPorts, Isf1),  
    holdsFor(stopped(Vessel2) = farFromPorts, Isf2),  
    holdsFor(lowSpeed(Vessel1) = true, Ils1),  
    holdsFor(lowSpeed(Vessel2) = true, Ils2),  
    union_all([Isf1, Ils1], I1),  
    union_all([Isf2, Ils2], I2), 
    intersect_all([Ip, I1, I2], Ii),  
    threshold(vrdv, Vrdv),  
    intDurGreater(Ii, Vrdv, I).  

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
    holdsFor(stopped(Vessel) = true, Is),  
    holdsFor(lowSpeed(Vessel) = true, Ils), 
    holdsFor(withinArea(Vessel, Area) = true, Iwa),  
    union_all([Is, Ils], Isls),  
    intersect_all([Isls, Iwa], Ii),  
    threshold(vloiter, Vloiter),  
    intDurGreater(Ii, Vloiter, I).  