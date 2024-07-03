terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    not holdsAt(nearCoast(Vessel) = true, T).
