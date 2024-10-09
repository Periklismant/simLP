initiatedAt(withinArea(Vessel,AreaType)=true,T) :-
 happensAt(enters(Vessel,AreaID),T),
 areaType(AreaID,AreaType).

