%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
	happensAt(gap_start(Vessel), T),
	holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
	happensAt(gap_start(Vessel), T),
	\+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_Status, T) :-
	happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
	happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
	happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
	happensAt(start(gap(Vessel)=_GapStatus), T).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
	happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
	happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
	happensAt(start(gap(Vessel)=_GapStatus), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
	happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
	thresholds(hcNearCoastMax, HcNearCoastMax),
	Speed > HcNearCoastMax,
	holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
	happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
	thresholds(hcNearCoastMax, HcNearCoastMax),
	Speed < HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
	holdsAt(withinArea(Vessel, nearCoast)=false, T).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel)=above, T) :-
	happensAt(velocity(Vessel, Speed, _, _), T),
	thresholds(movingMin, MovingMin),
	Speed > MovingMax.

initiatedAt(movingSpeed(Vessel)=normal, T) :-
	happensAt(velocity(Vessel, Speed, _, _), T),
	thresholds(movingMin, MovingMin),
	thresholds(movingMax, MovingMax),
	MovingMin =< Speed, Speed =< MovingMax.

initiatedAt(movingSpeed(Vessel)=below, T) :-
	happensAt(velocity(Vessel, Speed, _, _), T),
	thresholds(movingMin, MovingMin),
	Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=_, T) :-
	happensAt(velocity(Vessel, Speed, _, _), T),
	thresholds(movingMin, MovingMin),
	Speed < MovingMin.

terminatedAt(movingSpeed(Vessel)=_, T) :-
	happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) =< AdriftAngThr.
terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T),
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) =< AdriftAngThr.
terminatedAt(drifting(Vessel)=true, T) :-
	holdsAt(stopped(Vessel)=true, T),
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    abs(CourseOverGround - TrueHeading) =< AdriftAngThr.

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
typeSpeed(trawling, TrawlspeedMin, TrawlspeedMax, _Avg),
Speed >= TrawlspeedMin,
Speed =< TrawlspeedMax,
holdsAt(fishingArea(AreaID)=true, T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
happensAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
\+ (
typeSpeed(trawling, TrawlspeedMin, TrawlspeedMax, _Avg),
Speed >= TrawlspeedMin,
Speed =< TrawlspeedMax
).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
happensAt(change_in_heading(Vessel), T),
holdsAt(areaType(Area, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
happensAt(leavesArea(Vessel, Area), T),
areaType(Area, fishingArea).

initiatedAt(trawlingMovement(Vessel)=true, T) :-
happensAt(change_in_heading(Vessel), T),
happensAt(slow_motion_start(Vessel), T1), T1=<T,
holdsAt(areaType(Area, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
happensAt(slow_motion_end(Vessel), T1), T1>=T,
happensAt(leavesArea(Vessel, Area), T),
areaType(Area, fishingArea).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, fishingArea)=true, I1),
    typeSpeed(trawling, TrawlspeedMin, TrawlspeedMax, _),
    holdsFor(movingSpeed(Vessel)=TrawlspeedMin, I2),
    holdsFor(movingSpeed(Vessel)=TrawlspeedMax, I3),
    union_all([I1, I2, I3], I4),
    holdsFor(vesselType(Vessel, trawler)=true, _),
    holdsFor(lowSpeed(Vessel)=true, I5),
    holdsFor(change_in_speed_end(Vessel), T),
    holdsAt(movingSpeed(Vessel)=_, T),
    throsholds(trawlingTime, TrawlingTime),
    intDurGreater(I4, TrawlingTime, I).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
	happensAt(stop_start(Vessel), T),
	holdsAt(withinArea(Vessel, farFromPorts)=true, T).
initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
	happensAt(stop_start(Vessel), T),
	holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
	happensAt(stop_end(Vessel), T).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
	happensAt(start(gap(Vessel)=_GapStatus), T).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
	happensAt(velocity(Vessel, Speed, _, _), T),
	vesselType(Vessel, tugboat),
	typeSpeed(tugboat, TuggingMin, TuggingMax, _),
	Speed >= TuggingMin,
	Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
	happensAt(velocity(Vessel, Speed, _, _), T),
	vesselType(Vessel, tugboat),
	\+(typeSpeed(tugboat, TuggingMin, TuggingMax, _),
	Speed >= TuggingMin,
	Speed =< TuggingMax).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
	happensAt(gap_start(Vessel), T).

holdsFor(tugging(Tugboat, TowedVessel)=true, I) :-
    vesselType(Tugboat, tugboat),
    vesselType(TowedVessel, _), % Towed vessel can be of any type
    holdsFor(proximity(Tugboat, TowedVessel)=true, Ip),
    typeSpeed(tugging, TuggingMin, TuggingMax, _),
    thresholds(tuggingTime, TuggingTime),
    holdsFor(speed(Tugboat)=V1, It1),
    holdsFor(speed(TowedVessel)=V2, It2),
    It1\=[], It2\=[],
    V1 >= TuggingMin, V1 =< TuggingMax,
    V2 >= TuggingMin, V2 =< TuggingMax,
    intersect_all([Ip, It1, It2], If),
    intDurGreater(If, TuggingTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
	holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
	vesselType(Vessel1, PilotVessel),
	vesselType(Vessel2, OtherVessel),
	PilotVessel = pilot,
	holdsFor(lowSpeed(Vessel1)=true, Il1),
	holdsFor(lowSpeed(Vessel2)=true, Il2),
	holdsFor(stopped(Vessel1)=farFromPorts, Is1),
	holdsFor(stopped(Vessel2)=farFromPorts, Is2),
	union_all([Il1, Is1], I1b),
	union_all([Il2, Is2], I2b),
	intersect_all([I1b, I2b, Ip], If), If\=[],
	thresholds(hcNearCoastMax, HcNearCoastMax),
	velocity(Vessel1, Sp1, Co1, Hd1),
	velocity(Vessel2, Sp2, Co2, Hd2),
	holdsAt(Sp1 < HcNearCoastMax, If),
	holdsAt(Sp2 < HcNearCoastMax, If),
	thresholds(pilotTime, PilotTime),
	intDurGreater(If, PilotTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
happensAt(velocity(Vessel, Speed, _, _), T),
Speed > thresholds(sarMinSpeed, SarMinSpeed).

terminatedAt(sarSpeed(Vessel)=true, T) :-
happensAt(velocity(Vessel, Speed, _, _), T),
Speed =< thresholds(sarMinSpeed, SarMinSpeed).

terminatedAt(sarSpeed(Vessel)=true, T) :-
happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
happensAt(change_in_speed_start(Vessel), T);
happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
happensAt(gap_start(Vessel), T).

holdsFor(sarMovement(Vessel)=true, I) :-
	typeSpeed(sar, SarMinSpeed, SarMaxSpeed, _),
	holdsFor(movingSpeed(Vessel) = Speed, I),
	SarMinSpeed =< Speed, Speed =< SarMaxSpeed,
	vesselType(Vessel, sar).

holdsFor(inSAR(Vessel)=true, I) :-
	typeSpeed(sar, SarMinSpeed, _, _),
	holdsFor(velocity(Vessel, Speed, _, _), I),
	Speed >= SarMinSpeed,
	holdsFor(proximity(Vessel, _)=true, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
	(
		(
			holdsFor(lowSpeed(Vessel)=true, I1),
			durationGreaterThan(I1, LoiteringTime)
		)
	;
		(
			holdsFor(stopped(Vessel)=farFromPorts, I1),
			durationGreaterThan(I1, LoiteringTime)
		)
	),
	\+ holdsAt(withinArea(Vessel, nearCoast)=true, T),
	\+ anchored(Vessel),
	\+ moored(Vessel).

holdsFor(anchored(Vessel)=true, I) :-
	thresholds(aOrMTime, AOrMTime),
	sum_intervals([T1, T2], I),
	happensAt(change_in_speed_end(Vessel), T1),
	happensAt(change_in_speed_start(Vessel), T2),
	T2 - T1 > AOrMTime.

holdsFor(moored(Vessel)=true, I) :-
	thresholds(aOrMTime, AOrMTime),
	holdsFor(anchored(Vessel)=true, IA),
	sum_intervals(IA, ISum),
	sum_intervals(I, ISum),
	durationGreaterThan(I, AOrMTime).
