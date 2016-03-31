% =========================================================================== %
% FluxDriver.m - Solves the LP problem associated with an FBA calculation. 
%
% Input Args:
% pDataFile		-	Pointer to the DataFile function (@DataFile)
% OBJ			-	Index vector of fluxes to max/min
% MIN_MAX_FLAG	-	Flag = 1 -> minimize, Flag = -1 -> maximize
% DFIN			-	DataStruct in memory ([] if you want to load from disk)
%
% Output Args:
% FLOW			-	NFLUX x 1 vector with the network flux
% status		-	status returned by glpk (180 means job completed OK)
% UPTAKE		-	NFREE_METAB x 1 vector with unbalanced upatke/production
%
% =========================================================================== %
function [FLOW,status,UPTAKE] = FluxDriver(pDataFile,OBJ,MIN_MAX_FLAG,DFIN)

	% Check to see if we are passing in a data struct -
	if (isempty(DFIN))
		DF = feval(pDataFile,MIN_MAX_FLAG,OBJ);
	else
		DF = DFIN;
	end;

	% Get some stuff from the DF -
	STM = DF.STOICHIOMETRIC_MATRIX;
	[NM,NRATES] = size(STM);

	% Formulate objective vector (default is to minimize fluxes)
	if (isempty(OBJ))
		f=ones(1,NRATES);
	else
		f=zeros(1,NRATES);

		NI=length(OBJ);
		for obj_index=1:NI
			if (MIN_MAX_FLAG==1)
				f(OBJ(obj_index))=1;
			else
				f(OBJ(obj_index))=-1;
			end;
		end;
	end;

	OBJVECTOR = f;

	% Get bounds from the DF -
	vb = DF.FLUX_BOUNDS;
	LB = vb(:,1);
	UB = vb(:,2);

	% --------------------- Equality constraints ---------------------- %
	% Setup the bV and the constraint types required by the solver -
	STM_BALANCED_BLOCK = DF.BALANCED_MATRIX;
	AEq = STM_BALANCED_BLOCK;

	% Get the dimension of the balanced block -
	[NUM_BALANCED,NUM_RATES] = size(STM_BALANCED_BLOCK);

	% Formulate the bV -
	bVEq = zeros(NUM_BALANCED,1);
	% --------------------- Equality constraints ---------------------- %
	
	% --------------------- Inequality constraints -------------------- %
	UNBALANCED_STM = DF.SPECIES_CONSTRAINTS;
	SBA = DF.SPECIES_BOUND_ARRAY;
	SBA_LOWER = SBA(:,2);
	SBA_UPPER = SBA(:,3);
	A = [UNBALANCED_STM ; -1*UNBALANCED_STM];
	bV = [SBA_UPPER ; -1*SBA_LOWER];
	% --------------------- Inequality constraints -------------------- %
	
    % Set some values for the options parameter of LINPROG
    options=optimset('TolFun',1e-6);
	
    % Call the LP solver -
    [FLOW,fVal,status,OUT,LAM] = linprog(OBJVECTOR,A,bV,AEq,bVEq,LB,UB,[],options);
	
	
	UPTAKE = UNBALANCED_STM*FLOW;
return;