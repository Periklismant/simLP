%--------------- communication gap -----------%

initiatedAt(gap(Vessel, nearPorts)=true, T) :-
happensAt(gap_start(Vessel), T),
holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel, farFromPorts)=true, T) :-
happensAt(gap_start(Vessel), T),
\+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel, _Status)=true, T) :-
happensAt(gap_end(Vessel), T).

holdsFor(gap(Vessel)=nearPorts, I) :-
holdsFor(gap(Vessel, nearPorts)=true, I1),
\+ holdsFor(gap(Vessel, farFromPorts)=true, I2),
intersect_all([I1, I2], I).

holdsFor(gap(Vessel)=farFromPorts, I) :-
holdsFor(gap(Vessel, farFromPorts)=true, I1),
\+ holdsFor(gap(Vessel, nearPorts)=true, I2),
intersect_all([I1, I2], I).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T),
    typeSpeed(low, Min, Max, Avg),
    holdsAt(movingSpeed(Vessel)=below, T),
    velocity(Vessel, Speed, CourseOverGround, TrueHeading),
    Speed >= Min,
    Speed =< Max.

terminatedAt(lowSpeed(Vessel)=true, T) :-
happensAt(slow_motion_end(Vessel), T),
typeSpeed(low, Min, Max, Avg),
velocity(Vessel, Speed, CourseOverGround, TrueHeading),
Speed < Min.

terminatedAt(lowSpeed(Vessel)=true, T) :-
happensAt(gap_start(Vessel), T).

%-------------- changingSpeed ----------------%

initiatedAt(changingSpeed(Vessel)=true, T) :-
happensAt(change_in_speed_start(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
happensAt(change_in_speed_end(Vessel), T).

terminatedAt(changingSpeed(Vessel)=true, T) :-
happensAt(gap_start(Vessel), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    withinCoastalArea(Vessel, T),
    Speed > HcNearCoastMax,
    thresholds(hcNearCoastMax, HcNearCoastMax).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    Speed =< HcNearCoastMax,
    withinCoastalArea(Vessel, T),
    thresholds(hcNearCoastMax, HcNearCoastMax).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    happensAt(leavesArea(Vessel, CoastalArea), T),
    withinCoastalArea(Vessel, T),
    thresholds(hcNearCoastMax, HcNearCoastMax).

%--------------- movingSpeed -----------------%

holdsFor(movingSpeed(Vessel)=below, I) :-
    vesselType(Vessel, Type),
    typeSpeed(Type, _, MovingMax, _),
    holdsFor(velocity(Vessel, Speed, _, _), I),
    Speed < MovingMin,
    thresholds(movingMin, MovingMin),
    thresholds(movingMax, MovingMax).

holdsFor(movingSpeed(Vessel)=normal, I) :-
    vesselType(Vessel, Type),
    typeSpeed(Type, MovingMin, MovingMax, _),
    holdsFor(velocity(Vessel, Speed, _, _), I),
    MovingMin =< Speed,
    Speed =< MovingMax.

holdsFor(movingSpeed(Vessel)=above, I) :-
    vesselType(Vessel, Type),
    typeSpeed(Type, _, MovingMax, _),
    holdsFor(velocity(Vessel, Speed, _, _), I),
    Speed > MovingMax.

%----------------- drifitng ------------------%

holdsFor(drifting(Vessel)=true, I) :-
    initiatedAt(drifting(Vessel)=true, Tin),
    terminatedAt(drifting(Vessel)=true, Tout),
    Tout > Tin,
    I = [Tin..Tout],
    happensAt(change_in_heading(Vessel), Tin),
    thresholds(adriftAngThr, AdriftAngThr),
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), Tin),
    abs(CourseOverGround - TrueHeading) > AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    thresholds(adriftAngThr, AdriftAngThr),
    holdsAt(velocity(Vessel, Speed, CourseOverGround, TrueHeading), T),
    abs(CourseOverGround - TrueHeading) =< AdriftAngThr.

terminatedAt(drifting(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

%---------------- trawlSpeed -----------------%

initiatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    happensAt(entersArea(Vessel, FishingArea), T),
    typeSpeed(Trawling, TrawlingsMin, TrawlingsMax, TrawlingsAvg),
    holdsAt(movingSpeed(Vessel)=true, T),
    holdsAt(movingSpeed(Vessel)=Speed, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed >= TrawlspeedMin,
    Speed =< TrawlspeedMax,
    Speed >= TrawlingsMin,
    Speed =< TrawlingsMax.

terminatedAt(trawlSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(movingSpeed(Vessel)=true, T),
    holdsAt(movingSpeed(Vessel)=Speed, T),
    thresholds(trawlspeedMin, TrawlspeedMin),
    thresholds(trawlspeedMax, TrawlspeedMax),
    Speed < TrawlspeedMin,
    Speed > TrawlspeedMax.

%--------------- trawling --------------------%

holdsFor(trawlingMovement(Vessel)=true, I) :-
    holdsFor(proximity(Vessel, coastalArea)=true, Ic),
    typeSpeed(trawling, TrawlspeedMin, TrawlspeedMax, _),
    holdsFor(velocity(Vessel, Speed, CourseOverGround, TrueHeading)=true, Is),
    Speed >= TrawlspeedMin, Speed =< TrawlspeedMax,
    relative_complement_all(Is, Ic, It),
    happensAt(change_in_heading(Vessel), Tt),
    intersect_all([It, I], Il),
    happensAt(entersArea(Vessel, fishingArea), Ts),
    intersect_all([Il, I], Ie),
    happensAt(leavesArea(Vessel, fishingArea), Te),
    relative_complement_all(Ie, [Ts, Te], If),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(If, TrawlingTime, I).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(sailingInFishingArea(Vessel)=true, Ip),
    typeSpeed(trawling, TrawlspeedMin, TrawlspeedMax, _),
    holdsFor(movingSpeed(Vessel)=V, I1),
    TrawlspeedMin =< V, V =< TrawlspeedMax,
    vesselType(Vessel, trawler),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(I1, TrawlingTime, I),
    holdsFor(mannerOfSailing(Vessel)=typicalForTrawling, I2),
    intersect_all([Ip, I1, I2], I), I\=[].

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, farFromPorts)=true, T),
    holdsAt(inAnchorageArea(Vessel)=true, T).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

terminatedAt(anchoredOrMoored(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
holdsFor(stopped(Vessel)=nearPorts, I) ;
( holdsFor(stopped(Vessel)=farFromPorts, I1),
holdsFor(inAnchorageArea(Vessel)=true, I2),
intersect_all([I1, I2], I) \= []) .

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    TuggingMin =< Speed,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed < TuggingMin,
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(tugging(Tugboat, BeingTowed)=true, T) :-
happensAt(change_in_speed_start(Tugboat), T),
happensAt(change_in_speed_start(BeingTowed), T),
typeSpeed(tugging, TuggingMin, TuggingMax, _),
holdsAt(movingSpeed(Tugboat)=SpeedTug, T),
holdsAt(movingSpeed(BeingTowed)=SpeedTowed, T),
SpeedTug >= TuggingMin,
SpeedTug =< TuggingMax,
SpeedTowed >= TuggingMin,
SpeedTowed =< TuggingMax,
proximity(Tugboat, BeingTowed)=true,
thresholds(tuggingTime, TuggingTimeThr),
\+ holdsAt(tugging(Tugboat, BeingTowed)=true, T-1),
TuggingTimeThr < T.

terminatedAt(tugging(Tugboat, BeingTowed)=true, T) :-
happensAt(change_in_speed_end(Tugboat), T),
happensAt(change_in_speed_end(BeingTowed), T),
\+ holdsAt(tugging(Tugboat, BeingTowed)=true, T+1).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
vesselType(Vessel1, pilotVessel),
vesselType(Vessel2, regularVessel),
holdsFor(lowSpeed(Vessel1)=true, Il1),
holdsFor(lowSpeed(Vessel2)=true, Il2),
holdsFor(stopped(Vessel1)=farFromPorts, Is1),
holdsFor(stopped(Vessel2)=farFromPorts, Is2),
union_all([Il1, Is1], I1b),
union_all([Il2, Is2], I2b),
intersect_all([I1b, I2b, Ip], If), If\=[],
\+ holdsFor(withinArea(Vessel1, nearCoast)=true, T),
\+ holdsFor(withinArea(Vessel2, nearCoast)=true, T),
holdsFor(withinArea(Vessel1, nearPorts)=false, T1),
holdsFor(withinArea(Vessel2, nearPorts)=false, T2),
union_all([T, T1, T2], I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
happensAt(change_in_speed_start(Vessel), T),
typeSpeed(sar, SarMinSpeed, _, _),
holdsAt(velocity(Vessel, Speed, _, _), T),
Speed > SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
happensAt(change_in_speed_end(Vessel), T),
typeSpeed(sar, SarMinSpeed, _, _),
holdsAt(velocity(Vessel, Speed, _, _), T),
Speed =< SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
happensAt(change_in_speed_start(Vessel), T);
happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
happensAt(gap_start(Vessel), T).

holdFor(sarMovement(Vessel)=true, I) :-
happensAt(change_in_speed_start(Vessel), T1),
happensAt(change_in_speed_end(Vessel), T2),
T1 in I,
T2 in I,
happensAt(change_in_heading(Vessel), T3),
T3 in I,
\+ happensAt(gap_start(Vessel), T),
T in I.

initiatedAt(inSAR(Vessel)=true, T) :-
happensAt(start_sar(Vessel), T),
vesselType(Vessel, pilot),
typeSpeed(sar, SarMinSpeed, _, _),
holdsAt(velocity(Vessel, Speed, _, _), T),
Speed >= SarMinSpeed.

terminatedAt(inSAR(Vessel)=true, T) :-
happensAt(end_sar(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
holdsFor(inSAR(Vessel)=true, T0),
holdsFor(inSAR(Vessel)=true, T1),
T1 > T0,
T0 \= T1,
I = [T0, T1].

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
holdsFor(movingSpeed(Vessel)=below, I1),
holdsFor(movingSpeed(Vessel)=normal, I2),
holdsFor(movingSpeed(Vessel)=above, I3),
union_all([I1,I2,I3], I4),
thresholds(loiteringTime, LoiteringThreshold),
intDurGreater(I4, LoiteringThreshold, I).

holdsFor(loitering(Vessel)=true, I) :-
happensAt(stop_start(Vessel), T),
\+ holdsAt(withinArea(Vessel, nearPorts)=true, T),
holdsFor(stopped(Vessel)=farFromPorts, I1),
holdsFor(withinArea(Vessel, nearCoast)=false, I2),
union_all([I1,I2], I3),
thresholds(loiteringTime, LoiteringThreshold),
intDurGreater(I3, LoiteringThreshold, I).
