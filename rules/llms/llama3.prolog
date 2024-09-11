%----------------within area -----------------%

holdsFor(withinArea(Vessel, AreaOfInterest) = true, I) :-
    holdsFor(inside(AreaOfInterest) = true, I1),
    holdsFor(located(Vessel) = true, I2),
    union_all([I1 ,I2], I3),
    end(I3).

%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=true,T) :-
    lastMessageTime(Vessel,T1),
    timeStamp(T) - timeStamp(T1) >= 30 * 60. % 30 minutes = 1800 seconds

terminatedAt(gap(Vessel)=false,T) :-
    happensAt(messageReceived(Vessel),T).

terminatedAt(gap(Vessel)=true,T) :-
    happensAt(gap_start(Vessel),T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(located(Vessel) = true, T),
    distanceFromCoast(Vessel) =< 300,
    speed(Vessel) > 5.

terminatedAt(highSpeedNearCoast(Vessel) = false, T) :-
    happensAt( movesAwayFromCoast(Vessel), T).

%----------------- drifitng ------------------%

initiatedAt(drifting(Vessel) = true, T) :-
    happensAt(cog(Vessel, CoG), T),
    distance(CoG, desiredCourse(Vessel)) > threshold(DriftThreshold,_).

terminatedAt(drifting(Vessel) = false, T) :-
    happensAt(cog(Vessel, CoG), T),
    distance(CoG, desiredCourse(Vessel)) =< threshold(DriftThreshold,_).

%--------------- trawling --------------------%

initiatedAt(trawling(Vessel) = true, T) :-
    happensAt(speed(Vessel, Speed) = steady_trawling_speed, T),
    holdsAt(headingAngle(Vessel, Heading) >= trawling_heading_angle_min,
    holdsAt(headingAngle(Vessel, Heading) =< trawling_heading_angle_max, T)).

terminatedAt(trawling(Vessel) = false, T) :-
    happensAt(speed(Vessel, Speed) \= steady_trawling_speed, T).

terminatedAt(trawling(Vessel) = false, T) :-
    not holdsAt(headingAngle(Vessel, Heading) >= trawling_heading_angle_min, T), 
    not holdsAt(headingAngle(Vessel, Heading) =< trawling_heading_angle_max, T).

initiatedAt(trawling(Vessel) = true, T) :-
    holdsFor(headingAngle(Vessel, Heading) >= trawling_heading_angle_min,
             holdsInterval(T, Start), holdsInterval(T, End)),
    holdsFor(speed(Vessel, Speed) = steady_trawling_speed,
             holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(trawling(Vessel) = false, T) :-
    not holdsFor(headingAngle(Vessel, Heading) >= trawling_heading_angle_min,
                 holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(trawling(Vessel) = false, T) :-
    not holdsFor(speed(Vessel, Speed) = steady_trawling_speed,
                 holdsInterval(T, Start), holdsInterval(T, End)).

%-------------- anchoredOrMoored ---------------%

initiatedAt(anchoredOrMoored(Vessel) = true, T) :-
    happensAt(anchorDeployed(Vessel), T).

initiatedAt(anchoredOrMoored(Vessel) = true, T) :-
    happensAt(moored(Vessel), T).

terminatedAt(anchoredOrMoored(Vessel) = false, T) :-
    happensAt(anchorRetracted(Vessel), T).

terminatedAt(anchoredOrMoored(Vessel) = false, T) :-
    happensAt(unmoored(Vessel), T).

initiatedAt(anchoredOrMoored(Vessel) = true, T) :-
    holdsFor(anchorDeployed(Vessel), holdsInterval(T, Start), holdsInterval(T, End)).

initiatedAt(anchoredOrMoored(Vessel) = true, T) :-
    holdsFor(moored(Vessel), holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(anchoredOrMoored(Vessel) = false, T) :-
    holdsFor(anchorRetracted(Vessel), holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(anchoredOrMoored(Vessel) = false, T) :-
    holdsFor(unmoored(Vessel), holdsInterval(T, Start), holdsInterval(T, End)).

%---------------- tugging (B) ----------------%

initiatedAt(tugging(Vessel1, Vessel2) = true, T) :-
    holdsFor(distance(Vessel1, Vessel2) =< tugging_distance_threshold,
             holdsInterval(T, Start), holdsInterval(T, End)),
    holdsFor(speed(Vessel1, Speed) < normal_speed_threshold,
            holdsInterval(T, Start), holdsInterval(T, End)),
    holdsFor(speed(Vessel2, Speed) < normal_speed_threshold,
            holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(tugging(Vessel1, Vessel2) = false, T) :-
    not holdsFor(distance(Vessel1, Vessel2) =< tugging_distance_threshold,
                 holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(tugging(Vessel1, Vessel2) = false, T) :-
    speed(Vessel1, Speed) >= normal_speed_threshold.

terminatedAt(tugging(Vessel1, Vessel2) = false, T) :-
    speed(Vessel2, Speed) >= normal_speed_threshold.


%-------- pilotOps ---------------------------%

initiatedAt(piloting(Vessel1, Pilot) = true, T) :-
    holdsFor(distance(Pilot_boat, Vessel1) =< piloting_distance_threshold,
             holdsInterval(T, Start), holdsInterval(T, End)),
    holdsFor(boarded(Vessel1, Pilot) = true,
            holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(piloting(Vessel1, Pilot) = false, T) :-
    not holdsFor(distance(Pilot_boat, Vessel1) =< piloting_distance_threshold,
                 holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(piloting(Vessel1, Pilot) = false, T) :-
    boarded(Vessel1, Pilot) = false.

%---------------- rendezVous -----------------%

initiatedAt(vessel_rendez_vous(Vessel1, Vessel2) = true, T) :-
    holdsFor(distance(Vessel1, Vessel2) =< rendezvous_distance_threshold,
             holdsInterval(T, Start), holdsInterval(T, End)),
    holdsFor(speed(Vessel1, Speed) < rendezvous_speed_threshold,
             holdsInterval(T, Start), holdsInterval(T, End)),
    holdsFor(speed(Vessel2, Speed) < rendezvous_speed_threshold,
             holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(vessel_rendez_vous(Vessel1, Vessel2) = false, T) :-
    not holdsFor(distance(Vessel1, Vessel2) =< rendezvous_distance_threshold,
                 holdsInterval(T, Start), holdsInterval(T, End)).

terminatedAt(vessel_rendez_vous(Vessel1, Vessel2) = false, T) :-
    speed(Vessel1, Speed) >= rendezvous_speed_threshold.

terminatedAt(vessel_rendez_vous(Vessel1, Vessel2) = false, T) :-
    speed(Vessel2, Speed) >= rendezvous_speed_threshold.

%-------- loitering --------------------------%

initiatedAt(loitering(Vessel) = true, T) :-
holdsFor(duration(T) >= loitering_duration_threshold,
         holdsInterval(T, Start), holdsInterval(T, End)),
not holdsFor(achieved(_Goal), T).
%not exists Goal(GoalType, Goal) : holdsFor(achieved(Goal), T),

terminatedAt(loitering(Vessel) = false, T) :-
    duration(T) < loitering_duration_threshold.
terminatedAt(loitering(Vessel) = false, T) :-
    holdsFor(achieved(_Goal), T).
%exists Goal(GoalType, Goal) : holdsFor(achieved(Goal), T).
