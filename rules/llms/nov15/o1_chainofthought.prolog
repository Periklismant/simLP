%--------------- communication gap -----------%

initiatedAt(communicationGap(Vessel, nearPorts)=true, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(communicationGap(Vessel, farFromPorts)=true, T) :-
    happensAt(gap_start(Vessel), T),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(communicationGap(Vessel, _AreaType)=true, T) :-
    happensAt(gap_end(Vessel), T).

happensAt(log_communicationGap_start(Vessel, nearPorts, T), T) :-
    initiatedAt(communicationGap(Vessel, nearPorts)=true, T).

happensAt(log_communicationGap_start(Vessel, farFromPorts, T), T) :-
    initiatedAt(communicationGap(Vessel, farFromPorts)=true, T).

happensAt(log_communicationGap_end(Vessel, AreaType, T), T) :-
    terminatedAt(communicationGap(Vessel, AreaType)=true, T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

happensAt(log_lowSpeed_start(Vessel, T), T) :-
    initiatedAt(lowSpeed(Vessel)=true, T).

happensAt(log_lowSpeed_end(Vessel, T), T) :-
    terminatedAt(lowSpeed(Vessel)=true, T).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

happensAt(log_changingSpeed_start(Vessel, T), T) :-
    initiatedAt(changingSpeed(Vessel)=true, T).

happensAt(log_changingSpeed_end(Vessel, T), T) :-
    terminatedAt(changingSpeed(Vessel)=true, T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _)=true, T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, MaxSpeed),
    Speed > MaxSpeed.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _)=true, T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, MaxSpeed),
    Speed =< MaxSpeed.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    not holdsAt(withinArea(Vessel, nearCoast)=true, T).

happensAt(log_highSpeedNearCoast_start(Vessel, T), T) :-
    initiatedAt(highSpeedNearCoast(Vessel)=true, T).

happensAt(log_highSpeedNearCoast_end(Vessel, T), T) :-
    terminatedAt(highSpeedNearCoast(Vessel)=true, T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel, below)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    thresholds(movingMax, MovingMax),
    normalThreshold(MovingMin, MovingMax, NormalThreshold),
    Speed >= MovingMin,
    Speed < NormalThreshold.

initiatedAt(movingSpeed(Vessel, normal)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    thresholds(movingMax, MovingMax),
    normalThreshold(MovingMin, MovingMax, NormalThreshold),
    Speed >= NormalThreshold,
    Speed =< MovingMax.

initiatedAt(movingSpeed(Vessel, above)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMax, MovingMax),
    Speed > MovingMax.

terminatedAt(movingSpeed(Vessel, _SpeedCategory)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    Speed < MovingMin.

terminatedAt(movingSpeed(Vessel, _SpeedCategory)=true, T) :-
    happensAt(gap_start(Vessel), T).

happensAt(log_movingSpeed_start(Vessel, below, T), T) :-
    initiatedAt(movingSpeed(Vessel, below)=true, T).

happensAt(log_movingSpeed_start(Vessel, normal, T), T) :-
    initiatedAt(movingSpeed(Vessel, normal)=true, T).

happensAt(log_movingSpeed_start(Vessel, above, T), T) :-
    initiatedAt(movingSpeed(Vessel, above)=true, T).

happensAt(log_movingSpeed_end(Vessel, SpeedCategory, T), T) :-
    terminatedAt(movingSpeed(Vessel, SpeedCategory)=true, T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(current_affect(Vessel, DegreeChange, T), T),
    holdsAt(affectedByCurrents(Vessel)=true, T),
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading)=true, T),
    thresholds(courseThreshold, CourseThreshold),
    DegreeChange > CourseThreshold.

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(weather_condition(Vessel, harsh, T), T),
    holdsAt(affectedByWeather(Vessel)=true, T),
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading)=true, T),
    thresholds(courseThreshold, CourseThreshold),
    % Assuming DegreeChange is derived from weather_condition event
    % If DegreeChange is specified, include it here
    % For simplicity, assume any harsh weather causes course deviation exceeding threshold
    true.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading)=true, T),
    thresholds(courseThreshold, CourseThreshold),
    % Assuming DegreeChange can be inferred from CourseOverGround
    % Define a predicate to calculate degree change based on CourseOverGround
    calculate_degree_change(Vessel, CourseOverGround, DegreeChange),
    DegreeChange =< CourseThreshold.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(underway(Vessel, T), T).

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(gap_start(Vessel, T), T).

happensAt(log_drifting_start(Vessel, T), T) :-
    initiatedAt(drifting(Vessel)=true, T).

happensAt(log_drifting_end(Vessel, T), T) :-
    terminatedAt(drifting(Vessel)=true, T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _)=true, T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    thresholds(trawlspeedMin, MinSpeed),
    thresholds(trawlspeedMax, MaxSpeed),
    Speed > MinSpeed,
    Speed < MaxSpeed.

terminatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _)=true, T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    thresholds(trawlspeedMin, MinSpeed),
    Speed =< MinSpeed.

terminatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _)=true, T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    thresholds(trawlspeedMax, MaxSpeed),
    Speed >= MaxSpeed.

terminatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    not holdsAt(withinArea(Vessel, AreaType)=true, T).

happensAt(log_trawlSpeed_start(Vessel, AreaType, T), T) :-
    initiatedAt(trawlSpeed(Vessel, AreaType)=true, T).

happensAt(log_trawlSpeed_end(Vessel, AreaType, T), T) :-
    terminatedAt(trawlSpeed(Vessel, AreaType)=true, T).

%--------------- trawling --------------------%

initiatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    holdsAt(velocity(Vessel, Speed, _, _)=true, T),
    thresholds(trawlspeedMin, MinSpeed),
    thresholds(trawlspeedMax, MaxSpeed),
    Speed >= MinSpeed,
    Speed =< MaxSpeed.

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    initiatedAt(trawlSpeed(Vessel, AreaType)=true, T).

terminatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, AreaType).

terminatedAt(trawlSpeed(Vessel, AreaType)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    terminatedAt(trawlSpeed(Vessel, AreaType)=true, T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlSpeed(Vessel, AreaType)=true, I1),
    holdsFor(trawlingMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I),
    thresholds(trawlingTime, TrTime),
    intDurGreater(I, TrTime, I).

happensAt(log_trawlSpeed_start(Vessel, AreaType, T), T) :-
    initiatedAt(trawlSpeed(Vessel, AreaType)=true, T).

happensAt(log_trawlingMovement_start(Vessel, T), T) :-
    initiatedAt(trawlingMovement(Vessel)=true, T).

happensAt(log_trawlSpeed_end(Vessel, AreaType, T), T) :-
    terminatedAt(trawlSpeed(Vessel, AreaType)=true, T).

happensAt(log_trawlingMovement_end(Vessel, T), T) :-
    terminatedAt(trawlingMovement(Vessel)=true, T).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(stopped(Vessel)=farFromPorts, T).
    
initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, anchorage)=true, T).

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(stopped(Vessel)=nearPorts, T).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, I1),
    holdsFor(withinArea(Vessel, anchorage)=true, I2),
    holdsFor(stopped(Vessel)=nearPorts, I3),
    union_all([I1, I2, I3], I).

%---------------- tugging (B) ----------------%

initiatedAt(tugging(Vessel, TugBoat)=true, T) :-
    happensAt(velocity(Vessel, SpeedV, _, _) = true, T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    thresholds(tuggingMin, MinSpeed),
    thresholds(tuggingMax, MaxSpeed),
    SpeedV >= MinSpeed,
    SpeedV =< MaxSpeed,
    holdsAt(proximity(Vessel, TugBoat)=true, T),
    happensAt(velocity(TugBoat, SpeedT, _, _) = true, T),
    SpeedT >= MinSpeed,
    SpeedT =< MaxSpeed.

initiatedAt(tuggingSpeed(Vessel, TugBoat)=true, T) :-
    initiatedAt(tugging(Vessel, TugBoat)=true, T).

terminatedAt(tugging(Vessel, TugBoat)=true, T) :-
    happensAt(velocity(Vessel, SpeedV, _, _) = true, T),
    thresholds(tuggingMin, MinSpeed),
    thresholds(tuggingMax, MaxSpeed),
    SpeedV < MinSpeed.

terminatedAt(tugging(Vessel, TugBoat)=true, T) :-
    happensAt(velocity(Vessel, SpeedV, _, _) = true, T),
    thresholds(tuggingMin, MinSpeed),
    thresholds(tuggingMax, MaxSpeed),
    SpeedV > MaxSpeed.

terminatedAt(tugging(Vessel, TugBoat)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(tugging(Vessel, TugBoat)=true, T) :-
    not holdsAt(withinArea(Vessel, AreaType)=true, T).

terminatedAt(tuggingSpeed(Vessel, TugBoat)=true, T) :-
    terminatedAt(tugging(Vessel, TugBoat)=true, T).

happensAt(log_tugging_start(Vessel, TugBoat, T), T) :-
    initiatedAt(tugging(Vessel, TugBoat)=true, T).

happensAt(log_tuggingSpeed_start(Vessel, TugBoat, T), T) :-
    initiatedAt(tuggingSpeed(Vessel, TugBoat)=true, T).

happensAt(log_tugging_end(Vessel, TugBoat, T), T) :-
    terminatedAt(tugging(Vessel, TugBoat)=true, T).

happensAt(log_tuggingSpeed_end(Vessel, TugBoat, T), T) :-
    terminatedAt(tuggingSpeed(Vessel, TugBoat)=true, T).

%-------- pilotOps ---------------------------%

initiatedAt(pilotOps(VesselPilot, VesselTowed)=true, T) :-
    happensAt(pilot_board(VesselPilot, VesselTowed, T), T),
    holdsAt(withinArea(VesselPilot, AreaID)=true, T),
    holdsAt(withinArea(VesselTowed, AreaID)=true, T),
    holdsAt(proximity(VesselPilot, VesselTowed)=true, T),
    holdsAt(isPilot(VesselPilot)=true, T),
    holdsAt(velocity(VesselPilot, SpeedPilot, _, _) = true, T),
    holdsAt(velocity(VesselTowed, SpeedTowed, _, _) = true, T),
    thresholds(lowSpeedMin, LowSpeedMin),
    thresholds(lowSpeedMax, LowSpeedMax),
    SpeedPilot >= LowSpeedMin,
    SpeedPilot =< LowSpeedMax,
    SpeedTowed >= LowSpeedMin,
    SpeedTowed =< LowSpeedMax.

initiatedAt(pilotSpeed(VesselPilot, VesselTowed)=true, T) :-
    initiatedAt(pilotOps(VesselPilot, VesselTowed)=true, T).

terminatedAt(pilotOps(VesselPilot, VesselTowed)=true, T) :-
    happensAt(gap_start(VesselTowed, T), T).

terminatedAt(pilotOps(VesselPilot, VesselTowed)=true, T) :-
    happensAt(pilot_disembark(VesselPilot, VesselTowed, T), T).

terminatedAt(pilotOps(VesselPilot, VesselTowed)=true, T) :-
    happensAt(leave_area(VesselPilot, AreaID, T), T).

terminatedAt(pilotOps(VesselPilot, VesselTowed)=true, T) :-
    happensAt(leave_area(VesselTowed, AreaID, T), T).

terminatedAt(pilotSpeed(VesselPilot, VesselTowed)=true, T) :-
    terminatedAt(pilotOps(VesselPilot, VesselTowed)=true, T).

happensAt(log_pilotOps_start(VesselPilot, VesselTowed, AreaID, T), T) :-
    initiatedAt(pilotOps(VesselPilot, VesselTowed)=true, T),
    holdsAt(withinArea(VesselPilot, AreaID)=true, T),
    holdsAt(withinArea(VesselTowed, AreaID)=true, T).

happensAt(log_pilotSpeed_start(VesselPilot, VesselTowed, T), T) :-
    initiatedAt(pilotSpeed(VesselPilot, VesselTowed)=true, T).

happensAt(log_pilotOps_end(VesselPilot, VesselTowed, AreaID, T), T) :-
    terminatedAt(pilotOps(VesselPilot, VesselTowed)=true, T),
    holdsAt(withinArea(VesselPilot, AreaID)=false, T).

happensAt(log_pilotOps_end(VesselPilot, VesselTowed, AreaID, T), T) :-
    terminatedAt(pilotOps(VesselPilot, VesselTowed)=true, T),
    holdsAt(withinArea(VesselTowed, AreaID)=false, T).

happensAt(log_pilotSpeed_end(VesselPilot, VesselTowed, T), T) :-
    terminatedAt(pilotSpeed(VesselPilot, VesselTowed)=true, T).

%-------------------------- SAR --------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(current_affect(Vessel, DegreeChange, T), T),
    holdsAt(affectedByCurrents(Vessel)=true, T),
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading)=true, T),
    thresholds(sarSpeed, SarSpeedThreshold),
    DegreeChange > SarSpeedThreshold,
    Speed < SarSpeedThreshold.

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(weather_condition(Vessel, harsh, T), T),
    holdsAt(affectedByWeather(Vessel)=true, T),
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading)=true, T),
    thresholds(sarSpeed, SarSpeedThreshold),
    Speed < SarSpeedThreshold.

terminatedAt(drifting(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading)=true, T),
    thresholds(sarSpeed, SarSpeedThreshold),
    Speed > SarSpeedThreshold.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(gap_start(Vessel, T), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed(Vessel, T), T),
    holdsAt(drifting(Vessel)=true, T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel, T), T),
    holdsAt(drifting(Vessel)=true, T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel, T), T).

happensAt(log_drifting_start(Vessel, T), T) :-
    initiatedAt(drifting(Vessel)=true, T).

happensAt(log_drifting_end(Vessel, T), T) :-
    terminatedAt(drifting(Vessel)=true, T).

happensAt(log_sarMovement_start(Vessel, T), T) :-
    initiatedAt(sarMovement(Vessel)=true, T).

happensAt(log_sarMovement_end(Vessel, T), T) :-
    terminatedAt(sarMovement(Vessel)=true, T).

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel)=true, T) :-
    holdsFor(withinArea(Vessel, AreaID)=true, Interval),
    thresholds(loiteringDuration, LoiteringDuration),
    duration(Interval, Duration),
    Duration >= LoiteringDuration,
    holdsAt(velocity(Vessel, Speed, _, _) = true, T),
    thresholds(loiteringMinSpeed, LoiteringMinSpeed),
    thresholds(loiteringMaxSpeed, LoiteringMaxSpeed),
    Speed >= LoiteringMinSpeed,
    Speed =< LoiteringMaxSpeed.

initiatedAt(loitering(Vessel)=true, T) :-
    holdsFor(withinArea(Vessel, AreaID)=true, Interval),
    thresholds(loiteringDuration, LoiteringDuration),
    duration(Interval, Duration),
    Duration >= LoiteringDuration,
    holdsAt(isAnchored(Vessel)=true, T).

initiatedAt(loitering(Vessel)=true, T) :-
    holdsFor(withinArea(Vessel, AreaID)=true, Interval),
    thresholds(loiteringDuration, LoiteringDuration),
    duration(Interval, Duration),
    Duration >= LoiteringDuration,
    holdsAt(isMoored(Vessel)=true, T).

initiatedAt(loiteringMovement(Vessel)=true, T) :-
    initiatedAt(loitering(Vessel)=true, T).

terminatedAt(loitering(Vessel)=true, T) :-
    happensAt(leave_area(Vessel, AreaID, T), T).

terminatedAt(loitering(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _) = true, T),
    thresholds(loiteringMinSpeed, LoiteringMinSpeed),
    thresholds(loiteringMaxSpeed, LoiteringMaxSpeed),
    Speed < LoiteringMinSpeed.

terminatedAt(loitering(Vessel)=true, T) :-
    holdsAt(velocity(Vessel, Speed, _, _) = true, T),
    thresholds(loiteringMinSpeed, LoiteringMinSpeed),
    thresholds(loiteringMaxSpeed, LoiteringMaxSpeed),
    Speed > LoiteringMaxSpeed.

terminatedAt(loitering(Vessel)=true, T) :-
    happensAt(gap_start(Vessel, T), T).

terminatedAt(loiteringMovement(Vessel)=true, T) :-
    terminatedAt(loitering(Vessel)=true, T).

happensAt(log_loitering_start(Vessel, AreaID, T), T) :-
    initiatedAt(loitering(Vessel)=true, T),
    holdsAt(withinArea(Vessel, AreaID)=true, T).

happensAt(log_loitering_end(Vessel, AreaID, T), T) :-
    terminatedAt(loitering(Vessel)=true, T).

happensAt(log_loiteringMovement_start(Vessel, T), T) :-
    initiatedAt(loiteringMovement(Vessel)=true, T).

happensAt(log_loiteringMovement_end(Vessel, T), T) :-
    terminatedAt(loiteringMovement(Vessel)=true, T).