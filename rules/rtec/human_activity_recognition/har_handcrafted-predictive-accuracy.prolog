/*********************************** CAVIAR CE DEFINITIONS *************************************/

/****************************************
 *		  CLOSE 		*
 ****************************************/

holdsFor(close_24(Id1,Id2)=true, I) :-
	holdsFor(distance(Id1,Id2,24)=true, I).

holdsFor(close_25(Id1,Id2)=true, I) :-
	holdsFor(close_24(Id1,Id2)=true, I1),
	holdsFor(distance(Id1,Id2,25)=true, I2),
	union_all([I1,I2], I).

holdsFor(close_30(Id1,Id2)=true, I) :-
	holdsFor(close_25(Id1,Id2)=true, I1),
	holdsFor(distance(Id1,Id2,30)=true, I2),
	union_all([I1,I2], I).

holdsFor(close_34(Id1,Id2)=true, I) :-
	holdsFor(close_30(Id1,Id2)=true, I1),
	holdsFor(distance(Id1,Id2,34)=true, I2),
	union_all([I1,I2], I).

% we don't need the close(_,_)=false for values 24, 25 and 30
% as they are not used anywhere
holdsFor(close_34(Id1,Id2)=false, I) :-
	holdsFor(close_34(Id1,Id2)=true, I1),
	complement_all([I1], I).

% this is a variation of close

% Similar to the above we only need
%  closeSymmetric for value 30
holdsFor(closeSymmetric_30(Id1,Id2)=true, I) :-
	holdsFor(close_30(Id1,Id2)=true, I1),
	holdsFor(close_30(Id2,Id1)=true, I2),
	union_all([I1,I2], I).



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

% ----- initiate leaving_object

initiatedAt(leaving_object(Person,Object)=true, T) :-
	happensAt(appear(Object), T),
	holdsAt(inactive(Object)=true, T),
	holdsAt(person(Person)=true, T),
	% leaving_object is not symmetric in the pair of ids
	% and thus we need closeSymmetric here as opposed to close
	holdsAt(closeSymmetric_30(Person, Object)=true, T).

% ----- terminate leaving_object: pick up object

initiatedAt(leaving_object(_Person,Object)=false, T) :-
	happensAt(disappear(Object), T).


/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1,P2)=true, MI) :-
	holdsFor(walking(P1)=true, WP1),
	holdsFor(walking(P2)=true, WP2),
	intersect_all([WP1,WP2], WI),
	holdsFor(close_34(P1,P2)=true, CI),
	intersect_all([WI,CI], MI).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1,P2)=true, FightingI) :-
	holdsFor(abrupt(P1)=true, AbruptP1I),
	holdsFor(abrupt(P2)=true, AbruptP2I),
	union_all([AbruptP1I,AbruptP2I], AbruptI),
	holdsFor(close_34(P1,P2)=true, CloseI),
	intersect_all([AbruptI,CloseI], AbruptCloseI),
	holdsFor(inactive(P1)=true, InactiveP1I),
	holdsFor(inactive(P2)=true, InactiveP2I),
	union_all([InactiveP1I,InactiveP2I], InactiveI),
	relative_complement_all(AbruptCloseI, [InactiveI], FightingI).
