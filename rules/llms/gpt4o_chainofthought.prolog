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
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    thresholds(vstop, Vstop),
    Speed =< Vstop. 

terminatedAt(stopped(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    thresholds(vstop, Vstop),  
    Speed > Vstop.  

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel) = true, T) :-
    thresholds(vmin, Vmin),  
    m_most_recent_messages(Vessel, M), 
    allSpeedsBelowThreshold(M, Vmin).  

terminatedAt(lowSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    thresholds(vmin, Vmin),  
    Speed > Vmin.  

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Vnow, _CoG, _TrueHeading), T),  
    prevSpeed(Vessel, Vprev),  
    thresholds(alpha, Alpha), 
    abs(Vnow - Vprev) > (Alpha / 100) * Vprev.  

terminatedAt(changingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Vnow, _CoG, _TrueHeading), T),  
    prevSpeed(Vessel, Vprev),  
    thresholds(alpha, Alpha),  
    abs(Vnow - Vprev) =< (Alpha / 100) * Vprev.  

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    holdsAt(coord(Vessel, X, Y), T),  
    nearCoast(X, Y),  
    holdsAt(velocity(Vessel, Speed, _, _), T),
    \+ inRange(Speed, 0, 5).
    %Speed > 5. 

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _), T),  
    inRange(Speed, 0, 5).
    %Speed =< 5.  

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(gap_start(Vessel), T). 

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel) = below, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    vesselType(Vessel, Type), 
    typeSpeed(Type, MinSpeed, _, _),
    inRange(Speed, 0.5, MinSpeed).
    %minServiceSpeed(Type, MinSpeed),
    %Speed >= 0.5,  
    %Speed < MinSpeed.  

initiatedAt(movingSpeed(Vessel) = normal, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    vesselType(Vessel, Type), 
    typeSpeed(Type, MinSpeed, MaxSpeed, _),
    %minServiceSpeed(Type, MinSpeed),  
    %maxServiceSpeed(Type, MaxSpeed),  
    inRange(Speed, MinSpeed, MaxSpeed).
    %Speed >= MinSpeed,  
    %Speed < MaxSpeed.  
    
initiatedAt(movingSpeed(Vessel) = above, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    vesselType(Vessel, Type),  
    typeSpeed(Type, _, MaxSpeed, _),
    %maxServiceSpeed(Type, MaxSpeed),  
    inRange(Speed, MaxSpeed, inf).
    %Speed >= MaxSpeed.  

terminatedAt(movingSpeed(Vessel) = below, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    vesselType(Vessel, Type),  
    typeSpeed(Type, MinSpeed, _, _),
    inRange(Speed, 0, 0.5).
    %minServiceSpeed(Type, MinSpeed),  
    %Speed < 0.5.

terminatedAt(movingSpeed(Vessel) = below, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    vesselType(Vessel, Type),  
    typeSpeed(Type, MinSpeed, _, _),
    inRange(Speed, MinSpeed, inf).
    %minServiceSpeed(Type, MinSpeed),  
    %Speed >= MinSpeed.  

terminatedAt(movingSpeed(Vessel) = normal, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T), 
    vesselType(Vessel, Type),  
    typeSpeed(Type, MinSpeed, MaxSpeed, _),
    %minServiceSpeed(Type, MinSpeed), 
    %maxServiceSpeed(Type, MaxSpeed),  
    inRange(Speed, 0, MinSpeed).
    %Speed < MinSpeed. 

terminatedAt(movingSpeed(Vessel) = normal, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T), 
    vesselType(Vessel, Type),  
    typeSpeed(Type, MinSpeed, MaxSpeed, _),
    %minServiceSpeed(Type, MinSpeed), 
    %maxServiceSpeed(Type, MaxSpeed),  
    inRange(Speed, MaxSpeed, inf).
    %Speed >= MaxSpeed. 

terminatedAt(movingSpeed(Vessel) = above, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    vesselType(Vessel, Type),  
    typeSpeed(Type, _, MaxSpeed, _),
    inRange(Speed, 0, MaxSpeed).
    %maxServiceSpeed(Type, MaxSpeed),  
    %Speed < MaxSpeed.  

%----------------- underWay ------------------% 

holdsFor(underWay(Vessel) = true, I) :-
    holdsFor(movingSpeed(Vessel) = below, Ib),  
    holdsFor(movingSpeed(Vessel) = normal, In),  
    holdsFor(movingSpeed(Vessel) = above, Ia),  
    union_all([Ib, In, Ia], I).  

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :-
    happensAt(velocity(Vessel, _Speed, CoG, TrueHeading), T),
    absoluteAngleDiff(CourseOverGround, TrueHeading, AngleDiff),
    thresholds(cog_threshold, Threshold),  
    AngleDiff > Threshold.   

terminatedAt(drifting(Vessel) = true, T) :-
    happensAt(velocity(Vessel, _Speed, CoG, TrueHeading), T),
    absoluteAngleDiff(CourseOverGround, TrueHeading, AngleDiff),
    thresholds(cog_threshold, Threshold),  
    AngleDiff =< Threshold.  

terminatedAt(drifting(Vessel) = true, T) :-
    happensAt(gap_start(Vessel), T).  

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) :-
    holdsFor(stopped(Vessel) = farFromPorts, Isffp),
    holdsFor(withinArea(Vessel, anchorage) = true, Iwa),
    intersect_all([Isffp,Iwa],Isa),
    holdsFor(stopped(Vessel) = nearPorts, Isn),
    union_all([Isa,Isn],Ii),
    thresholds(vaorm, Vaorm), intDurGreater(Ii, Vaorm,I).

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
    thresholds(vtug, Vtug),  
    intDurGreater(Ii, Vtug, I).  

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
    thresholds(vrdv, Vrdv),  
    intDurGreater(Ii, Vrdv, I).  

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    inRange(Speed, TrawlspeedMin, TrawlspeedMax).
    %minTrawlSpeed(MinSpeed),  
    %maxTrawlSpeed(MaxSpeed),  
    %Speed >= MinSpeed,  
    %Speed =< MaxSpeed. 

terminatedAt(trawlSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    inRange(Speed, 0, TrawlspeedMin).
    %minTrawlSpeed(MinSpeed),  
    %maxTrawlSpeed(MaxSpeed),  
    %Speed < MinSpeed.  

terminatedAt(trawlSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    inRange(Speed, TrawlspeedMax, inf).
    %minTrawlSpeed(MinSpeed),  
    %maxTrawlSpeed(MaxSpeed),  
    %Speed > MaxSpeed. 

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel) = true, T) :-
    holdsAt(trawlSpeed(Vessel) = true, T),  
    wideHeadingDistribution(Vessel, T).  

terminatedAt(trawlingMovement(Vessel) = true, T) :-
    not holdsAt(trawlSpeed(Vessel) = true, T).  

terminatedAt(trawlingMovement(Vessel) = true, T) :-
    not wideHeadingDistribution(Vessel, T).  

holdsFor(trawling(Vessel) = true, I) :- % changes from trawlingMovement to trawling
    holdsFor(withinArea(Vessel, fishing) = true, I1),  
    eventsToIntervals(change_in_heading(Vessel), I2),  
    intersect_all([I1, I2], I).  

%-------------------------- SAR --------------%

initiatedAt(sarMovement(Vessel) = true, T) :-
    happensAt(change_in_heading(Vessel), T),  
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    minSARSpeed(MinSpeed),  
    Speed >= MinSpeed.  

terminatedAt(sarMovement(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _CoG, _TrueHeading), T),  
    minSARSpeed(MinSpeed),  
    Speed < MinSpeed.  

terminatedAt(sarMovement(Vessel) = true, T) :-
    not happensAt(change_in_heading(Vessel), T).  

holdsFor(inSAR(Vessel) = true, I) :- % changed from sarMovement to inSAR.
    holdsFor(change_in_heading(Vessel) = true, Ich),  
    holdsFor(lowSpeed(Vessel) = true, Ils),  
    intersect_all([Ich, Ils], I).  

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
    holdsFor(stopped(Vessel) = true, Is),  
    holdsFor(lowSpeed(Vessel) = true, Ils), 
    holdsFor(withinArea(Vessel, Area) = true, Iwa),  
    union_all([Is, Ils], Isls),  
    intersect_all([Isls, Iwa], Ii),  
    thresholds(vloiter, Vloiter),  
    intDurGreater(Ii, Vloiter, I).  

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
    thresholds(vpilot, Vpilot),  
    intDurGreater(Ii, Vpilot, I).  

