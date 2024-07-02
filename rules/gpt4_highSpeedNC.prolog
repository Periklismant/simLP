initiatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    holdsAt(nearCoast(Vessel) = true, T),
    greater(Speed,5).

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    leq(Speed,5).

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    not holdsAt(nearCoast(Vessel) = true, T).
