function DF = DataFile(MAX_FLAG,OBJ_VEC)
	
% Load the network -
STM = load('Network.dat');

% Load the FB -
FB = load('FB.dat');

% Get the dimension of the system - 
[NR,NCO]=size(STM);

% Free metabolites -
IDX_FREE_METABOLITES = [
	8	;	% A_x
	9	;	% B_x
	10	;	% C_x
	11	;	% D_x
];

IDX_BALANCED_METABOLITES = setdiff(1:NR,IDX_FREE_METABOLITES);
N_IDX_BALANCED_METABOLITES = length(IDX_BALANCED_METABOLITES);

% Setup bounds on species - 
BASE_BOUND = 10;
SPECIES_BOUND=[
	8	-1	BASE_BOUND				;	% 1	A_x
	9	0	BASE_BOUND				;	% 2	B_x
	10	0	BASE_BOUND				;	% 3	C_x
	11	-1*BASE_BOUND 	BASE_BOUND	;	% 4 D_x	
];

% Split the stochiometrix matrix - 
S	=	STM(IDX_BALANCED_METABOLITES,:);
SDB	=	STM(SPECIES_BOUND(:,1),:);

% === DO NOT EDIT BELOW THIS LINE ===================== %
DF.STOICHIOMETRIC_MATRIX = STM;
DF.SPECIES_BOUND_ARRAY=SPECIES_BOUND;
DF.FLUX_BOUNDS = FB;
DF.BALANCED_MATRIX = S;
DF.SPECIES_CONSTRAINTS=SDB;
% ===================================================== %
return;