initiatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    holdsAt(nearCoast(Vessel) = true, T),
    greater(Speed,5).

