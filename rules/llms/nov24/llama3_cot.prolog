%--------------- communication gap -----------%

starts_gap(Vessel) :- 
	change_in_speed_end(Vessel), 
	stop_start(Vessel), 
	proximity(Vessel,Port).

starts_gap_far(Vessel) :- 
	change_in_speed_end(Vessel), 
	stop_start(Vessel), 
	not proximities(Vessel, Port).

ends_gap(Vessel) :- 
	change_in_speed_start(Vessel), 
	stop_end(Vessel).

ends_gap(Vessel) :- 
	slow_motion_start(Vessel), 
	slow_motion_end(Vessel).

gap(Vessel) :- 
	starts_gap(Vessel), 
	not ends_gap(Vessel).

%-------------- lowspeed----------------------%

starts_lowSpeed(Vessel) :- 
	slow_motion_start(Vessel).

ends_lowSpeed(Vessel) :- 
	slow_motion_end(Vessel).

lowSpeed(Vessel) :- 
	starts_lowSpeed(Vessel), 
	not ends_lowSpeed(Vessel).

no_lowSpeed(Vessel) :- 
	gap_start(Vessel), 
	not starts_lowSpeed(Vessel).

%-------------- changingSpeed ----------------%

starts_changingSpeed(Vessel) :- 
	previous_velocity(Vessel, OldSpeed), 
	current_velocity(Vessel, NewSpeed), 
	not equal(OldSpeed, NewSpeed).

ends_changingSpeed(Vessel) :- 
	previous_velocity(Vessel, OldSpeed), 
	current_velocity(Vessel, NewSpeed), 
	equal(OldSpeed, NewSpeed).

changingSpeed(Vessel) :- 
	starts_changingSpeed(Vessel), 
	not ends_changingSpeed(Vessel).

no_changingSpeed(Vessel) :- 
	gap_start(Vessel), 
	not starts_changingSpeed(Vessel).


%------------ highSpeedNearCoast -------------%

starts_HighSpeedNearCoast(Vessel) :- 
	proximity(Vessel,Port), 
	velocity(Vessel, Speed, _, _), 
	thresholds(hcNearCoastMax, HcNearCoastMax), 
	Speed > HcNearCoastMax.

ends_HighSpeedNearCoast(Vessel) :- 
	proximity(Vessel,Port), 
	velocity(Vessel, Speed, _, _), 
	thresholds(hcNearCoastMax, HcNearCoastMax), 
	Speed <= HcNearCoastMax, 
	or leavesArea(Vessel, Port).

HighSpeedNearCoast(Vessel) :- 
	starts_HighSpeedNearCoast(Vessel), 
	not ends_HighSpeedNearCoast(Vessel).


%--------------- movingSpeed -----------------%

starts_movingSpeed(Vessel) :- 
	type(Vessel, Type), 
	velocity(Vessel, Speed, _, _), 
	thresholds(min_speed_Type, MinSpeed), 
	less_than(Speed, MinSpeed).

starts_normalSpeed(Vessel) :- 
	type(Vessel, Type), 
	velocity(Vessel, Speed, _, _), 
	thresholds(min_speed_Type, MinSpeed), 
	thresholds(max_speed_Type, MaxSpeed), 
	and(Speed, greater_than(MinSpeed), 
	less_than(MaxSpeed)).

starts_aboveSpeed(Vessel) :- 
	type(Vessel, Type), 
	velocity(Vessel, Speed, _, _), 
	thresholds(min_speed_Type, MinSpeed), 
	thresholds(max_speed_Type, MaxSpeed), 
	greater_than(Speed, MaxSpeed).

ends_movingSpeed(Vessel) :- 
	velocity(Vessel, Speed, _, _), 
	thresholds(min_speed_Type, MinSpeed), 
	less_than(Speed, MinSpeed).

movingSpeed(Vessel) :- 
	starts_movingSpeed(Vessel) or starts_normalSpeed(Vessel) or 	starts_aboveSpeed(Vessel), 
	not ends_movingSpeed(Vessel).

no_movingSpeed(Vessel) :- 
	gap_start(Vessel), 
	not starts_movingSpeed(Vessel) and not starts_normalSpeed(Vessel) and not 	starts_aboveSpeed(Vessel).

%----------------- drifitng ------------------%

starts_drifting(Vessel) :- 
	and(event_time(), (angle_diff(Vessel, BowDirection), greater_than(max_angle_diff))).

drifting(Vessel) :- 
	starts_drifting(Vessel) and not ends_drifting(Vessel).

ends_drifting(Vessel) :- 
	not starts_drifting(Vessel), 
	or(angle_diff(Vessel, BowDirection), less_than(max_angle_diff)) 
	or (velocity(Vessel, Speed, _, _), equal_to(0)).

%---------------- trawlSpeed -----------------%

starts_trawlSpeed(Vessel) :- 
	fishing_area(Vessel), 
	velocity(Vessel, Speed, _, _), 
	thresholds(trawlspeedMin, TrawlspeedMin), 
	thresholds(trawlspeedMax, TrawlspeedMax), 
	min(Speed, TrawlspeedMax) and max(Speed, TrawlspeedMin).

ends_trawlSpeed(Vessel) :- 
	fishing_area(Vessel), velocity(Vessel, Speed, _, _), 
	thresholds(trawlspeedMin, 
	TrawlspeedMin), 
	thresholds(trawlspeedMax, TrawlspeedMax), 
	not (min(Speed, TrawlspeedMax) and max(Speed, TrawlspeedMin)).

trawlSpeed(Vessel) :- 
	starts_trawlSpeed(Vessel), 
	not ends_trawlSpeed(Vessel).

no_trawlSpeed(Vessel) :- 
	gap_start(Vessel), 
	not starts_trawlSpeed(Vessel).

%--------------- trawling --------------------%

starts_trawlingMovement(Vessel) :- 
	change_heading(Vessel), 
	proximity(Vessel, FishingArea).

ends_trawlingMovement(Vessel) :- 
	not proximity(Vessel, FishingArea).

trawlingMovement(Vessel) :- 
	starts_trawlingMovement(Vessel), 
	not ends_trawlingMovement(Vessel).

starts_trawling(Vessel) :- 
	fishing_area(Vessel), 
	velocity(Vessel, Speed, _, _), 
	thresholds(trawling_min_speed, TrawlingMinSpeed), 
	thresholds(trawling_max_speed, TrawlingMaxSpeed), 
	and(Speed, greater_than(TrawlingMinSpeed), 
	less_than(TrawlingMaxSpeed)), 
	sailing_type(Vessel, "trawling").

ends_trawling(Vessel) :- 
	not fishing_area(Vessel).

trawling_duration(Vessel, Duration) :- 
	starts_trawling(Vessel), 
	and(event_time(), 
	event_duration(Duration)), 
	greater_than(Duration, trawling_min_duration).

trawling(Vessel) :- 
	starts_trawling(Vessel) and not ends_trawling(Vessel).

%-------------- anchoredOrMoored ---------------%

starts_anchoredOrMoored(Vessel) :- 
	anchorage_area(Vessel), 
	distance(Vessel, Port, Distance), 
	greater_than(Distance, mooring_distance).

starts_anchoredOrMoored(Vessel) :- 
	mooring_area(Vessel), 
	distance(Vessel, Port, Distance), 
	less_than(Distance, mooring_distance).

ends_anchoredOrMoored(Vessel) :- 
	not anchorage_area(Vessel) and not mooring_area(Vessel).

anchoredOrMoored(Vessel) :- 
	starts_anchoredOrMoored(Vessel) and not ends_anchoredOrMoored(Vessel).

%---------------- tugging (B) ----------------%

starts_tuggingSpeed(Vessel) :- 
	velocity(Vessel, Speed, _, _), 
	thresholds(tuggingMin, TuggingMin), 
	thresholds(tuggingMax, TuggingMax), 
	min(Speed, TuggingMax) and max(Speed, TuggingMin).

ends_tuggingSpeed(Vessel) :- 
	velocity(Vessel, Speed, _, _), 
	thresholds(tuggingMin, TuggingMin), 
	thresholds(tuggingMax, TuggingMax), 
	not (min(Speed, TuggingMax) and max(Speed, TuggingMin)).

tuggingSpeed(Vessel) :- 
	starts_tuggingSpeed(Vessel), 
	not ends_tuggingSpeed(Vessel).

no_tuggingSpeed(Vessel) :- 
	gap_start(Vessel), 
	not starts_tuggingSpeed(Vessel).

starts_tugging(Vessel1, Vessel2) :- 
	tugboat(Vessel2), 
	proximity(Vessel1, Vessel2, Distance), 
	and(Distance, less_than(tug_distance)), 
	velocity(Vessel1, Speed, _, _), 
	velocity(Vessel2, TugSpeed, _, _), 
	thresholds(tug_min_speed, MinTugSpeed), 
	thresholds(tug_max_speed, MaxTugSpeed), 
	and(Speed, greater_than(MinTugSpeed), 
	less_than(MaxTugSpeed)) and(TugSpeed, greater_than(MinTugSpeed), 	less_than(MaxTugSpeed)).

ends_tugging(Vessel1, Vessel2) :- 
	not proximity(Vessel1, Vessel2, Distance), 
	or(not tugboat(Vessel2), 
	not Vessel1 equal to Vessel2).

tugging_duration(Vessel1, Vessel2, Duration) :- 
	starts_tugging(Vessel1, Vessel2), 
	and(event_time(), 
	event_duration(Duration)), 
	greater_than(Duration, tugging_min_duration).

tugging(Vessel1, Vessel2) :- 
	starts_tugging(Vessel1, Vessel2) and not ends_tugging(Vessel1, Vessel2).

%-------- pilotOps ---------------------------%

starts_pilotOps(PilotVessel, Vessel) :- 
	pilot_vessel(PilotVessel), 
	proximity(PilotVessel, Vessel, Distance), 
	and(Distance, less_than(pilot_distance)), 
	velocity(PilotVessel, Speed, _, _), 
	velocity(Vessel, VesselSpeed, _, _), 
	thresholds(pilot_min_speed, MinPilotSpeed), 
	or(Speed, greater_than(MinPilotSpeed), 
	equal_to(0)) and(VesselSpeed, 
	greater_than(MinPilotSpeed), 
	equal_to(0)), 
	coastal_area(PilotVessel, _).

ends_pilotOps(PilotVessel, Vessel) :- 
	not proximity(PilotVessel, Vessel, Distance), 
	or(not pilot_vessel(PilotVessel), 
	not Vessel equal to PilotVessel).

pilotOps(PilotVessel, Vessel) :- 
	starts_pilotOps(PilotVessel, Vessel) and not ends_pilotOps(PilotVessel, Vessel), 	and(coastal_area(PilotVessel, _), false).

%-------------------------- SAR --------------%

starts_sarSpeed(Vessel) :- 
	velocity(Vessel, Speed, _, _), 
	thresholds(sarResultMin, SarResultMin), 
	greater_than(Speed, SarResultMin).

ends_sarSpeed(Vessel) :- 
	velocity(Vessel, Speed, _, _), 
	thresholds(sarResultMin, SarResultMin), 
	less_than(Speed, SarResultMin).

sarSpeed(Vessel) :- 
	starts_sarSpeed(Vessel), 
	not ends_sarSpeed(Vessel).

no_sarSpeed(Vessel) :- 
	gap_start(Vessel), 
	not starts_sarSpeed(Vessel).

starts_sarMovement(Vessel) :- 
	and(event_time(), (velocity_change(Vessel) or heading_change(Vessel))).

sarMovement(Vessel) :- 
	starts_sarMovement(Vessel), 
	last_signal_event(last_signal_time).

ends_sarMovement(Vessel) :- 
	not starts_sarMovement(Vessel), 
	or(last_signal_time plus_time_gap, greater_than(max_sar_duration)).

starts_inSAR(Vessel) :- 
	and(event_time(), (velocity(Vessel, Speed, _, _), greater_than(min_sar_speed)), sar_manner(Vessel)).

inSAR(Vessel) :- 
	starts_inSAR(Vessel) and not ends_inSAR(Vessel).

ends_inSAR(Vessel) :- 
	not starts_inSAR(Vessel), 
	or(velocity(Vessel, Speed, _, _), less_than(min_sar_speed)) or (sar_manner(Vessel), false).

%-------- loitering --------------------------%

starts_loitering(Vessel) :- 
	and(event_time(), (velocity(Vessel, Speed, _, _), less_than(min_speed)), 	distance_from_coast(Vessel, Distance), 
	not(anchored(Vessel)) and not(moored(Vessel))).

loitering(Vessel) :- 
	starts_loitering(Vessel) and not ends_loitering(Vessel).

ends_loitering(Vessel) :- 
	not starts_loitering(Vessel), or(velocity(Vessel, Speed, _, _), 	greater_than(min_speed)) or (distance_from_coast(Vessel, Distance), 	less_than(coast_threshold)) or (anchored(Vessel) or moored(Vessel)).

duration_loitering(Vessel) :- 
	(ends_loitering(Vessel)) and (event_time() - starts_loitering(Vessel) >= 	min_duration_threshold).