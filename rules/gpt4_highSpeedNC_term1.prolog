terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed), T),
    leq(Speed,5).

