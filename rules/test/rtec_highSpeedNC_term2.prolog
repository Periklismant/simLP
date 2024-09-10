terminatedAt(highSpeedNearCoast(Vessel)=true, T):-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).
