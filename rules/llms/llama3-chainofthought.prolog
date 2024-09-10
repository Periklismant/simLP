%----------------within area -----------------%

initiatedAt(withinArea(Vessel,AreaType)=true,T) ←
 happensAt(entersArea(Vessel,AreaID),T),
 areaType(AreaID,AreaType).

terminatedAt(withinArea(Vessel,AreaType)=true,T) ←
 happensAt(leavesArea(Vessel,AreaID),T),
 areaType(AreaID,AreaType).

 terminatedAt(withinArea(Vessel,AreaType)=true,T) ←
 happensAt(gap_start(Vessel),T).


%--------------- communication gap -----------%

initiatedAt(gap(Vessel) = nearPorts, T)  ←
 happensAt(gap_start(Vessel), T),
 holdsAt(withinArea(Vessel,nearPorts)=true, T).

 initiatedAt(gap(Vessel) = farFromPorts, T)  ←
 happensAt(gap_start(Vessel), T),
 not holdsAt(withinArea(Vessel,nearPorts)=true, T).

 terminatedAt(gap(Vessel) =_Value, T)  ←
 happensAt(gap_end(Vessel), T).


%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel), T) ←
happensAt(enterCoastalZone(Vessel), T),
holdsAt(highSpeed(Vessel)=true, T),
holdsAt(nearCoast(Vessel)=true, T).

terminatedAt(highSpeedNearCoast(Vessel), T) ←
not holdsAt(holdsAt(highSpeed(Vessel)=true, T)) or
not holdsAt(holdAs(nearCoast(Vessel)=true, T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) ←
happensAt(gpsData(Vessel, courseOverGround), T),
holdsAt(deviatesFromIntendedCourse(Vessel)>driftingThreshold, T),
holdsAt(durationSinceDeviation>driftingDuration, T).

terminatedAt(drifting(Vessel)=true, T) ←
happensAt(gpsData(Vessel, courseOverGround), T),
holdsAt(abs(deviatesFromIntendedCourse(Vessel)) ≤ driftingThreshold, T).

%--------------- trawling --------------------%

initiatedAt(trawling(Trawler) = true, T) ←
happensAt(velocity(Trawler, _Speed,_CoG,_TrueHeading), T),
holdsAt(abs(_CoG - _TrueHeading) ≤ headingAngleThreshold, T).

terminatedAt(trawling(Trawler) = true, T) ←
happensAt(velocity(Trawler, _Speed,_CoG,_TrueHeading), T),
not holdsAt(_Speed = trawlingSpeed, T) or
abs(_CoG - _TrueHeading) > headingAngleThreshold.

trawlingMovement(Vessel) = true if
vesselType(Vessel, fishing) and
withinArea(Vessel, fishing) and
change_in_heading(Vessel).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) ←
holdsFor(stopped(Vessel) = farFromPorts, Isffp),
holdsFor(withinArea(Vessel, anchorage) = true, Iwa),
intersect_all([Isffp,Iwa],Isa),
holdsFor(stopped(Vessel) = nearPorts, Isn),
union_all([Isa,Isn],Ii),
threshold(vaorm, Vaorm), intDurGreater(Ii, Vaorm,I).

%---------------- tugging (B) ----------------%

holdsFor(tugging(TugVessel, TowedVessel) = true, I) ←
intersect_all([closeProximity(TugVessel, TowedVessel), lowSpeed(TugVessel, TowedVessel)], Isa),
union_all([isTowed(TowedVessel) = towing(TugVessel, TowedVessel), isPulling(TugVessel) = pulling(TugVessel, TowedVessel)], Ii),
threshold(vtgg, Vtgg), intDurGreater(Ii, Vtgg, I).


%-------- pilotOps ---------------------------%

holdsFor(piloting(PilotVessel, VesselToBeManoeuvred) = true, I) ←
intersect_all([navigating(PilotVessel, specificArea), approached(VesselToBeManoeuvred, PilotVessel)], Isa),
union_all([boarded(PilotVessel, VesselToBeManoeuvred), navigated(VesselToBeManoeuvred, PilotVessel)], Ii),
threshold(vpil, Vpil), intDurGreater(Ii, Vpil, I).

%---------------- rendezVous -----------------%

holdsFor(vesselRendezvous(VesselA, VesselB) = true, I) ←
intersect_all([nearby(VesselA, VesselB, openSea), lowSpeedOrStopped(VesselA)], Isa),
union_all([lowSpeedOrStopped(VesselB)], Isa),
threshold(vrv, Vrv), intDurGreater(Ia, Vrv, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) ←
intersect_all([inParticularArea(Vessel), noEvidentPurpose(Vessel)], Isa),
duration(I, longPeriod, threshold(lt, Lt)),
intDurGreater(Ia, Lt, I).