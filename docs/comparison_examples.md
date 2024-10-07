Event Description 1: 
holdsFor(=(anchoredOrMoored(Vessel),true),I) :- 
	holdsFor(=(stopped(Vessel),farFromPorts),Isffp),
	holdsFor(=(withinArea(Vessel,anchorage),true),Iwa),
	intersect_all(list(Isffp,Iwa),Isa),
	holdsFor(=(stopped(Vessel),nearPorts),Isn),
	union_all(list(Isa,Isn),Ii),
	threshold(vaorm,Vaorm),
	intDurGreater(Ii,Vaorm,I).


Event Description 2: 
holdsFor(=(anchoredOrMoored(Vessel),true),I) :- 
	holdsFor(=(stopped(Vessel),farFromPorts),Istfp),
	holdsFor(=(withinArea(Vessel,anchorage),true),Ia),
	intersect_all(list(Istfp,Ia),Ista),
	holdsFor(=(stopped(Vessel),nearPorts),Istnp),
	union_all(list(Ista,Istnp),Ii),
	thresholds(aOrMTime,AOrMTime),
	intDurGreater(Ii,AOrMTime,I).

Similarity: 0.854

Comments: "threshold" predicates have a different name.
