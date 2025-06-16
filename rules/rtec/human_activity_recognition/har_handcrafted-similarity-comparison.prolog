/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
	happensAt(start(walking(Id)=true), T),
	\+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
	happensAt(start(running(Id)=true), T),
	\+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
	happensAt(start(active(Id)=true), T),
	\+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
	happensAt(start(abrupt(Id)=true), T),
	\+ happensAt(disappear(Id), T).

terminatedAt(person(Id)=true, T) :-
	happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person,Object)=true, T) :-
	happensAt(appear(Object), T), 
	holdsAt(inactive(Object)=true, T),
	holdsAt(person(Person)=true, T),
	thresholds(leavingObjectThr, LeavingObjectThr),
	holdsAt(close(Person,Object,LeavingObjectThr)=true, T).

terminatedAt(leaving_object(_Person,Object)=true, T) :-
	happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1,P2)=true, MI) :-
	holdsFor(walking(P1)=true, WP1),
	holdsFor(walking(P2)=true, WP2),
	intersect_all([WP1,WP2], WI),
	thresholds(movingThr, MovingThr),
	holdsFor(close(P1,P2,MovingThr)=true, CI),
	intersect_all([WI,CI], MI).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1,P2)=true, FightingI) :-
	holdsFor(abrupt(P1)=true, AbruptP1I),
	holdsFor(abrupt(P2)=true, AbruptP2I),
	union_all([AbruptP1I,AbruptP2I], AbruptI),
	thresholds(fightingThr, FightingThr),
	holdsFor(close(P1,P2,FightingThr)=true, CloseI),
	intersect_all([AbruptI,CloseI], AbruptCloseI),
	holdsFor(inactive(P1)=true, InactiveP1I),
	holdsFor(inactive(P2)=true, InactiveP2I),
	union_all([InactiveP1I,InactiveP2I], InactiveI),
	relative_complement_all(AbruptCloseI, [InactiveI], FightingI).


