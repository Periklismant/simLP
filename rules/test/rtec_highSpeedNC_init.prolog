initiatedAt(highSpeedNearCoast(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _, _), T),
    greater(Speed, 5),
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

