%--------------- communication gap -----------%

initiatedAt(communicationGapStarted(Vessel), T) :- 
	not holdsFor(message_sent(Vessel)), 
	not holdsFor(communicationGapStopped(Vessel)), I, lastTime(T).

terminatedAt(communicationGapStopped(Vessel), T) :- 
	holdsFor(message_sent(Vessel)), I.

%-------------- lowspeed----------------------%

initiatedAt(lowSpeedStarted(Vessel), T) :- 
	holdsFor(velocity(Vessel, Speed, _)), 
	Speed < thresholds(trawlSpeedMin,LowSpeedMin), 
	I, 
	not heldAfter(lowSpeedStopped(Vessel), T).

terminatedAt(lowSpeedStopped(Vessel), T) :- 
	holdsFor(velocity(Vessel, Speed, _)), 
	not (Speed < thresholds(trawlSpeedMin, LowSpeedMin)) 
	or heldAt(communicationGapStarted(_), _), 
	I.

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeedStarted(Vessel), T) :- 
	not heldAt(changingSpeedStopped(Vessel), _) 
	and (holdsFor(velocity(Vessel, Speed1, _)) 
	or holdsFor(velocity(Vessel, _, Speed2))) 
	and Speed1 <> Speed2, 
	I.

terminatedAt(changingSpeedStopped(Vessel), T) :- 
	not heldAt(changingSpeedStarted(Vessel), _) or
	heldAt(communicationGapStarted(_), _), 
	I.

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoastStarted(Vessel), T) :- 
	holdsFor(velocity(Vessel, Speed, _)), 
	Speed > thresholds(hcNearCoastMax, HcNearCoastMax), 
	holdsFor(withinArea(_, CoastalArea)), 
	I, 
	not heldAfter(highSpeedNearCoastStopped(Vessel), T).

terminatedAt(highSpeedNearCoastStopped(Vessel), T) :- 
	holdsFor(velocity(Vessel, Speed, _)), 
	Speed <= thresholds(hcNearCoastMax, HcNearCoastMax) v ~holdsFor(withinArea(_, CoastalArea)), 
	I.

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeedStarted(Vessel), T) :- 
	Speed > 0 and (Speed >= thresholds(low, MovingLowThreshold) 
	or Speed <= thresholds(high, MovingHighThreshold)), 
	I.

terminatedAt(movingSpeedStopped(Vessel), T) :- 
	(Speed < thresholds(low, StoppingThreshold)) or
	heldAt(communicationGapStarted(_), _), 
	I.

%----------------- drifitng ------------------%

initiatedAt(driftingStarted(Vessel), T) :- 
	course(Vessel, Course, _), 
	abs(Course - previousCourse(Vessel)) > courseThreshold 
	and (harshWeatherCondition(W) or seaCurrentIntensity(I) >= seaCurrentThreshold(T)),
	I.

terminatedAt(driftingStopped(Vessel), T) :- 
	course(Vessel, Course, _), 
	abs(Course - previousCourse(Vessel)) <= courseThreshold or underway(Vessel), 
	I.

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeedStarted(Vessel), T) :- 
	holdsFor(velocity(Vessel, Speed, _)), 
	Speed > thresholds(trawlSpeedMin, TrawlSpeedMin) 
	and Speed < thresholds(trawlSpeedMax, TrawlSpeedMax),
	holdsFor(withinArea(_, Area)), 
	I, 
	not heldAfter(trawlSpeedStopped(Vessel), T).

terminatedAt(trawlSpeedStopped(Vessel), T) :- 
	holdsFor(velocity(Vessel, Speed, _)), 
	not (Speed > thresholds(trawlSpeedMin, 
	TrawlSpeedMin) and Speed < thresholds(trawlSpeedMax, TrawlSpeedMax)) 
	or heldAt(communicationGapStarted(_), _) v ~holdsFor(withinArea(_, Area)), 
	I.

%--------------- trawling --------------------%

initiatedAt(trawlingStarted(Vessel), T) :- 
	(velocity(Vessel, _, _) = velocity(Vessel, trawlSpeed, _)) and
	(position(Vessel, _, _, _, TimeStamp1) = position(Vessel, _, _, _, TimeStamp2)) 
	and ((TimeStamp2 - TimeStamp1 > trawlingDurationThreshold) or 	(abs(cosineSimilarity(direction(Vessel, TimeStamp1), direction(Vessel, TimeStamp2 < turningRadiusThreshold))) 
	and withinArea(Vessel, TimeStamp2), 
	I.

terminatedAt(trawlingStopped(Vessel), T) :- 
	not withinArea(Vessel, T), 
	I.

holdsFor(trawling(Vessel), T1, T2) :- 
	trawlingActivity(Vessel) atTime T1, 
	not trawlingActivity(Vessel) atTime (T2 + 1).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMooredStarted(Vessel), T) :- 
	idle(Vessel, _), 
	not portInsideArea(_, areaNearPorts, _),
	(velocity(Vessel, _, _) = 0 or velocity(Vessel, _, _) is_unknown), 	(withinArea(Vessel, anchorageArea, T) 
	or withinArea(Vessel, areaFarFromPorts, T)), 
	I.

terminatedAt(anchoredOrMooredStopped(Vessel), T) :- 
	not idle(Vessel, _) or portInsideArea(_, areaNearPorts, _), 
	I.

holdsFor(anchoredOrMoored(Vessel), T1, T2) :- 
	(isAnchored(Vessel, _) atTime T1, isAnchored(Vessel, _) atTime T2) 
	or (isMoored(Vessel, _) atTime T1, isMoored(Vessel, _) atTime T2).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingStarted(TugBoat), T) :- 
	not movingByItself(TowedVessel, _),
	withinRange(DistanceToOtherVessel(TugBoat, TowedVessel, _, _),	tuggingDistanceThresholdMin,
	tuggingDistanceThresholdMax), 
	I.

terminatedAt(tuggingStopped(TugBoat), T) :- 
	not withinRange(DistanceToOtherVessel(TugBoat, TowedVessel, _, _),	tuggingDistanceThresholdMin, tuggingDistanceThresholdMax) 
	or communicationGapStarted(_, _), 
	I.

holdsFor(tugging(Vessel), T1, T2) :- 
	towing(_, Vessel) atTime T1,
	towing(_, Vessel) atTime T2.

%-------- pilotOps ---------------------------%

initiatedAt(pilotingStarted(PilotVessel), T) :- 
	isPilot(PilotVessel, true), withinCoastalArea(Location, _),
	distanceToOtherVessel(PilotVessel, OtherVessel, _, Distance), 
	Distance <= pilotDistanceThreshold, otherVesselIdle(OtherVessel), 	not(portId(OtherVessel, _, _)), 
	I.

terminatedAt(pilotingStopped(PilotVessel), T) :- 
	distanceToOtherVessel(PilotVessel, OtherVessel, _, Distance), 
	Distance > pilotDistanceThreshold 
	or communicationGapStarted(_, _), 
	I.

holdsFor(pilotOps(Vessel), T1, T2) :- 
	pilotAssignment(_, Vessel, _) atTime T1, 
	not pilotAssignment(_, Vessel, _) atTime (T2 + 1).

%-------------------------- SAR --------------%

initiatedAt(engagingInSAR(Vessel), T) :- 
	velocity(Vessel, Speed, _), 
	Speed < sarSpeedThreshold(T).

terminatedAt(notEngagingInSAR(Vessel), T) :- 
	velocity(Vessel, Speed, _), 
	Speed >= sarSpeedThreshold(T).

holdsFor(SAR(Vessel), T1, T2) :- 
	SARMission(Vessel) atTime T1, 
	not SARMission(Vessel) atTime (T2 + 1).


%-------- loitering --------------------------%

initiatedAt(loitering(Vessel), T) :- 
	velocity(Vessel, Speed, _), 
	Speed <= lowSpeedThreshold(T) or isIdle(Vessel,T) 
	or distanceFromPorts(Vessel, Distance, _) >= farFromPortsThreshold(T) 
	or isNearCoast(Vessel, Coast, _) = True
	or (isAnchored(Vessel, Anchor, _) = True 
	and isMoored(Vessel, Moor, _) = False).

terminatedAt(notLoitering(Vessel), T) :- 
	velocity(Vessel, Speed, _), Speed > lowSpeedThreshold(T) 
	or isIdle(Vessel, T) = False 
	or distanceFromPorts(Vessel, Distance, _) < farFromPortsThreshold(T) 
	or isNearCoast(Vessel, Coast, _) = False 
	or (isAnchored(Vessel, Anchor, _) = False 
	and isMoored(Vessel, Moor, _) =True).

holdsFor(loitering(Vessel), T1, T2) :- 
	isLoitering(Vessel) atTime T1,
	not isLoitering(Vessel) atTime (T2 + 1).