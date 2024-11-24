%--------------- communication gap -----------%

start_communication_gap(NearPort) :-
    receiving_messages(false), 
    port_distance(Vessel, NearPort, Distance),
    nearCoast(Distance). 

start_communication_gap_far(AllPorts) :-
    receiving_messages(false),
    not(nearAnyPort(AllPorts)). 

end_communication_gap :-
    receiving_messages(true).

%-------------- lowspeed----------------------%

start_low_speed :-
    vesselMoving,
    currentSpeed(Speed),
    Speed < MinimumLowSpeed.

low_speed :-
    vesselMoving,
    currentSpeed(Speed),
    Speed < MinimumLowSpeed.

end_low_speed :-
    not vesselMoving,
    \+ previousVesselMoving.

end_low_speed :-
    signalTransmissionGap.

%-------------- changingSpeed ----------------%

start_changing_speed :-
    currentSpeed(PreviousSpeed),
    \+ (currentSpeed(CurrentSpeed) = PreviousSpeed),
    vesselMoving.

changing_speed :-
    currentSpeed(PreviousSpeed),
    \+ (currentSpeed(CurrentSpeed) = PreviousSpeed),
    vesselMoving.

end_changing_speed :-
    currentSpeed(PreviousSpeed),
    (currentSpeed(CurrentSpeed) = PreviousSpeed),
    vesselMoving.

%------------ highSpeedNearCoast -------------%

start_high_speed_near_coast :-
    inCoastalArea,
    currentSpeed(Speed),
    Speed > CoastalSpeedLimit.

high_speed_near_coast :-
    inCoastalArea,
    currentSpeed(Speed),
    Speed > CoastalSpeedLimit.

end_high_speed_near_coast :-
    \+ inCoastalArea,
    currentSpeed(Speed),
    Speed < CoastalSpeedLimit.

%--------------- movingSpeed -----------------%

start_moving_speed(VesselType) :-
    vessel_type(VesselType),
    vesselMoving,
    vessel_type(VesselType).

moving_speed_below_min(VesselType) :-
    vessel_type(VesselType),
    vesselMoving,
    vessel_type(VesselType),
    currentSpeed(CurrentSpeed),
    min_speed(VesselType, MinimumSpeed),
    CurrentSpeed < MinimumSpeed.

moving_speed_normal(VesselType) :-
    vessel_type(VesselType),
    vesselMoving,
    vessel_type(VesselType),
    currentSpeed(CurrentSpeed),
    min_speed(VesselType, MinimumSpeed),
    max_speed(VesselType, MaximumSpeed),
    MinimumSpeed =< CurrentSpeed,
    CurrentSpeed =< MaximumSpeed.

moving_speed_above_max(VesselType) :-
    vessel_type(VesselType),
    vesselMoving,
    vessel_type(VesselType),
    currentSpeed(CurrentSpeed),
    max_speed(VesselType, MaximumSpeed),
    CurrentSpeed > MaximumSpeed.

end_moving_speed :-
    currentSpeed(CurrentSpeed),
    min_speed(VesselType, MinimumSpeed),
    CurrentSpeed < MinimumSpeed.

%----------------- drifitng ------------------%

start_drifting :-
    angle_difference(Angle) > max_angle_limit, .
    moving(Vessel). 

end_drifting :-
    ( angle_difference(Angle) <= max_angle_limit ; not(moving(Vessel)) ). 

%---------------- trawlSpeed -----------------%

start_trawl_speed :-
    inFishingArea,
    currentSpeed(Speed),
    Speed > MinTrawlSpeed,
    Speed < MaxTrawlSpeed.

trawl_speed :-
    inFishingArea,
    currentSpeed(Speed),
    Speed > MinTrawlSpeed,
    Speed < MaxTrawlSpeed.

end_trawl_speed :-
    currentSpeed(Speed),
    Speed < MinTrawlSpeed,
    Speed > MaxTrawlSpeed,
    \+ signalTransmissionGap.

end_trawl_speed :-
    signalTransmissionGap.

%--------------- trawling --------------------%

start_trawling_movement :-
    inFishingArea,
    headingChanged,
    \+ previousHeadingChanged.

trawling_movement :-
    inFishingArea,
    headingChanged,
    \+ previousHeadingChanged.

end_trawling_movement :-
    not inFishingArea.

start_trawling :-
    in_fishing_area,
    currentSpeed(CurrentSpeed),
    min_speed_trawling(MinimumSpeed),
    max_speed_trawling(MaximumSpeed),
    CurrentSpeed >= MinimumSpeed,
    CurrentSpeed <= MaximumSpeed,
    sailing_manner_trawling.

continuing_trawling :-
    in_fishing_area,
    currentSpeed(CurrentSpeed),
    min_speed_trawling(MinimumSpeed),
    max_speed_trawling(MaximumSpeed),
    CurrentSpeed >= MinimumSpeed,
    CurrentSpeed <= MaximumSpeed,
    sailing_manner_trawling,
    time_elapsed(Duration),
    Duration > minimum_duration_trawling.

end_trawling :-
    not(in_fishing_area),
    currentSpeed(CurrentSpeed),
    min_speed_trawling(MinimumSpeed),
    max_speed_trawling(MaximumSpeed),
    ( CurrentSpeed < MinimumSpeed ; CurrentSpeed > MaximumSpeed ),
    not(sailing_manner_trawling).

%-------------- anchoredOrMoored ---------------%

start_anchoredOrMoored :-
    vessel_stopped,
    ( not(near_port) ; in_anchorage ).

in_anchorage :-
    not(near_port), 
    in_anchorage_area. 

end_anchoredOrMoored :-
    not(vessel_stopped).

%---------------- tugging (B) ----------------%

start_tugging_speed :-
    vesselMoving,
    currentSpeed(Speed),
    Speed >= MinimumTuggingSpeed,
    Speed <= MaximumTuggingSpeed.

tugging_speed :-
    vesselMoving,
    currentSpeed(Speed),
    Speed >= MinimumTuggingSpeed,
    Speed <= MaximumTuggingSpeed.

end_tugging_speed :-
    not (vesselMoving and currentSpeed(Speed) between MinimumTuggingSpeed and MaximumTuggingSpeed),
    \+ previousVesselMoving.

end_tugging_speed :-
    signalTransmissionGap.

start_tugging :-
    ( vessel_1(X) ; vessel_2(X) ), 
    tugboat(X),
    close_to(vessel_1(X), vessel_2(X)),
    ( speed_within_bounds(vessel_1(X)) ; speed_within_bounds(vessel_2(X)) ).

continuing_tugging :-
    ( vessel_1(X) ; vessel_2(X) ), 
    close_to(vessel_1(X), vessel_2(X)),
    ( speed_within_bounds(vessel_1(X)) ; speed_within_bounds(vessel_2(X)) ),
    duration_exceeds_threshold.

end_tugging :-
    ( vessel_1(X) ; vessel_2(X) ), 
    not(close_to(vessel_1(X), vessel_2(X))),
    not(speed_within_bounds(vessel_1(X))),
    not(speed_within_bounds(vessel_2(X))).

%-------- pilotOps ---------------------------%

start_pilot_ops :-
    ( pilot_vessel(X) ; guided_vessel(X) ),
    pilot(X),
    close_to(pilot_vessel(X), guided_vessel(X)),
    ( low_speed(pilot_vessel(X)) ; idle(guided_vessel(X)) ),
    not_in_coastal_area(pilot_vessel(X)).

%-------------------------- SAR --------------%

start_sar_speed :-
    vesselMoving,
    currentSpeed(Speed),
    Speed >= MinimumSarSpeed.

sar_speed :-
    vesselMoving,
    currentSpeed(Speed),
    Speed >= MinimumSarSpeed.

end_sar_speed :-
    not (vesselMoving and currentSpeed(Speed) >= MinimumSarSpeed),
    \+ previousVesselMoving.

end_sar_speed :-
    signalTransmissionGap.

start_sar_movement :-
    ( speed_changed ; heading_changed ).

end_sar_movement :-
    gap_in_signal_transmissions.

start_inSAR :-
    ( pilot_vessel(Vessel) ; rescue_vessel(Vessel) ), 
    typical_speed(Speed), 
    moving(Vessel), 
    typical_pattern(Pattern). 

continuous_inSAR :-
    ( pilot_vessel(Vessel) ; rescue_vessel(Vessel) ),
    typical_speed(Speed),
    moving(Vessel),
    typical_pattern(Pattern).

end_inSAR :-
    ( \+ typical_speed(Speed) ; \+ moving(Vessel) ; \+ typical_pattern(Pattern) ). 

%-------- loitering --------------------------%

start_loitering :-
    ( \+ near_port(Vessel) ; \+ near_coast(Vessel) ), 
    idle_or_low_speed(Idle), 
    \+ anchored(Vessel). 
    \+ moored(Vessel). 
    ( duration_since_entered_area(Time) > min_loitering_duration ).

continuous_loitering :-
    ( \+ near_port(Vessel) ; \+ near_coast(Vessel) ),
    idle_or_low_speed(Idle),
    \+ anchored(Vessel).
    \+ moored(Vessel). 

end_loitering :-
    ( idle_or_low_speed(\+ Idle) ; duration_since_left_area(Time) > min_loitering_duration ), 
    ( near_port(Vessel) ; near_coast(Vessel) ; anchored(Vessel) ; moored(Vessel) ). 