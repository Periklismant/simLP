%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_Status, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    greater_than(Speed, HcNearCoastMax).

terminatedAt(highSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    not greater_than(Speed, HcNearCoastMax).

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(highSpeed(Vessel)=true, T), % the definition of this fluent corresponds to the speed comparison in the ground rules.
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    inRange(Speed, 0, HcNearCoastMax).
    %not greater_than(Speed, HcNearCoastMax).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).
    %happensAt(leavesArea(Vessel, Area), T),
    %areaType(Area, nearCoast).

%--------------- movingSpeed -----------------%

initiatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    inRange(Speed, MovingMin, inf).
    %greater_than(Speed, MovingMin).

terminatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    \+inRange(Speed, MovingMin, inf).
    %not greater_than(Speed, MovingMin).

terminatedAt(movingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).
    %happensAt(gap_start(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    absoluteAngleDiff(CourseOverGround, TrueHeading, AngleDiff),
    AngleDiff > AdriftAngThr.
    %greater_than(AngleDiff, AdriftAngThr).

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, CourseOverGround, TrueHeading), T),
    thresholds(adriftAngThr, AdriftAngThr),
    absoluteAngleDiff(CourseOverGround, TrueHeading, AngleDiff),
    AngleDiff =< AdriftAngThr.
    %not greater_than(AngleDiff, AdriftAngThr).

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(movingMin, MovingMin),
    greater_than(Speed, MovingMin).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlSpeedMin, TrawlspeedMin),
    thresholds(trawlSpeedMax, TrawlspeedMax),
    inRange(Speed, TrawlspeedMin, TrawlspeedMax),
    holdsAt(withinArea(Vessel, fishing)=true, T).
    %greater_than(Speed, TrawlspeedMin),
    %less_than(Speed, TrawlspeedMax),
    %holdsAt(withinArea(Vessel, trawlingArea)=true, T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlSpeedMin, TrawlspeedMin),
    thresholds(trawlSpeedMax, TrawlspeedMax),
    \+inRange(Speed, TrawlspeedMin, TrawlspeedMax).
    %not greater_than(Speed, TrawlspeedMin).

%terminatedAt(trawlSpeed(Vessel)=true, T) :-
    %happensAt(velocity(Vessel, Speed, _, _), T),
    %thresholds(trawlSpeedMax, TrawlspeedMax),
    %not less_than(Speed, TrawlspeedMax).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).
    %happensAt(gap_start(Vessel), T).

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, _, _), T),
    not holdsAt(withinArea(Vessel, fishing)=true, T).

%--------------- trawling --------------------%

%initiatedAt(trawlSpeed(Vessel)=true, T) :-
%    happensAt(velocity(Vessel, Speed, _, _), T),
%    thresholds(trawlspeedMin, TrawlspeedMin),
%    thresholds(trawlspeedMax, TrawlspeedMax),
%    greater_than(Speed, TrawlspeedMin),
%    less_than(Speed, TrawlspeedMax),
%    holdsAt(withinArea(Vessel, trawlingArea)=true, T).

%terminatedAt(trawlSpeed(Vessel)=true, T) :-
%    happensAt(velocity(Vessel, Speed, _, _), T),
%    thresholds(trawlspeedMin, TrawlspeedMin),
%    not greater_than(Speed, TrawlspeedMin).

%terminatedAt(trawlSpeed(Vessel)=true, T) :-
%    happensAt(velocity(Vessel, Speed, _, _), T),
%    thresholds(trawlspeedMax, TrawlspeedMax),
%    not less_than(Speed, TrawlspeedMax).

%terminatedAt(trawlSpeed(Vessel)=true, T) :-
%    happensAt(gap_start(Vessel), T).

%terminatedAt(trawlSpeed(Vessel)=true, T) :-
%    happensAt(velocity(Vessel, _, _, _), T),
%    not holdsAt(withinArea(Vessel, trawlingArea)=true, T).

initiatedAt(trawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(trawlSpeed(Vessel)=true, T),
    holdsAt(withinArea(Vessel, trawlingArea)=true, T).

terminatedAt(trawling(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, _, _), T),
    not holdsAt(withinArea(Vessel, trawlingArea)=true, T).

terminatedAt(trawling(Vessel)=true, T) :-
    happensAt(velocity(Vessel, _, _, _), T),
    not holdsAt(trawlSpeed(Vessel)=true, T).

terminatedAt(trawling(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%-------------- anchoredOrMoored ---------------%

%initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
%    initiatedAt(stopped(Vessel)=farFromPorts, T).

%initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
%    initiatedAt(stopped(Vessel)=nearPorts, T).

%initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
%    happensAt(stop_start(Vessel), T),
%    holdsAt(withinArea(Vessel, anchorage)=true, T).

%terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
%    happensAt(stop_end(Vessel), T).

%terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
%    happensAt(gap_start(Vessel), T).

%terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
%    happensAt(leavesArea(Vessel, Area), T),
%    areaType(Area, anchorage),
%    holdsAt(stopped(Vessel)=_Status, T).

%holdsFor(anchoredOrMoored(Vessel)=true, I) :-
%    holdsFor(anchoredOrMoored(Vessel)=true, I1),
%    thresholds(aOrMTime, AOrMTime),
%    intDurGreater(I1, AOrMTime, I).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, I1),
    holdsFor(stopped(Vessel)=nearPorts, I2),
    holdsFor(stopped(Vessel)=_Status, I3),
    holdsFor(withinArea(Vessel, anchorage)=true, I4),
    intersect_all([I3, I4], I5),
    union_all([I1, I2, I5], I6),
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(I6, AOrMTime, I).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    inRange(Speed, TuggingMin, TuggingMax).
    %greater_than(Speed, TuggingMin),
    %less_than(Speed, TuggingMax).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    \+inRange(Speed, TuggingMin, TuggingMax).
    %not greater_than(Speed, TuggingMin).

%terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    %happensAt(velocity(Vessel, Speed, _, _), T),
    %thresholds(tuggingMax, TuggingMax),
    %not less_than(Speed, TuggingMax).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).
    %happensAt(gap_start(Vessel), T).

initiatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    holdsAt(tuggingSpeed(Vessel1)=true, T),
    holdsAt(tuggingSpeed(Vessel2)=true, T).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(velocity(Vessel1, _, _, _), T),
    not holdsAt(tuggingSpeed(Vessel1)=true, T).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(velocity(Vessel2, _, _, _), T),
    not holdsAt(tuggingSpeed(Vessel2)=true, T).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    not holdsAt(proximity(Vessel1, Vessel2)=true, T).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(gap_start(Vessel1), T).

terminatedAt(tugging(Vessel1, Vessel2)=true, T) :-
    happensAt(gap_start(Vessel2), T).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    holdsFor(withinArea(Vessel1, nearCoast)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Iw2),
    union_all([Is1, Iw1], I1b),
    union_all([Is2, Iw2], I2b),
    intersect_all([Il1, Il2, I1b, I2b, Ip], If),
    If \= [],
    thresholds(pilotingTime, PilotingTime),
    intDurGreater(If, PilotingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sar(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarSpeedMax, SarSpeedMax),
    inRange(Speed, 0, SarSpeedMax).
    %less_than(Speed, SarSpeedMax).

terminatedAt(sar(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarSpeedMax, SarSpeedMax),
    \+inRange(Speed, 0, SarSpeedMax).
    %not less_than(Speed, SarSpeedMax).

terminatedAt(sar(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).
    %happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(start(changingSpeed(Vessel)=true), T).
    %happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).
    %happensAt(gap_start(Vessel), T).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    holdsFor(withinArea(Vessel, nearCoast)=true, I3),
    holdsFor(anchoredOrMoored(Vessel)=true, I4),
    union_all([I1, I2, I3, I4], I5),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I5, LoiteringTime, I).