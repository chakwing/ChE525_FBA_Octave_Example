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

	% Setup the bV and the constraint types required by the solver -
	STM_BALANCED_BLOCK = DF.BALANCED_MATRIX;

	% Get the dimension of the balanced block -
	[NUM_BALANCED,NUM_RATES] = size(STM_BALANCED_BLOCK);

	% Formulate the bV -
	bV = zeros(NUM_BALANCED,1);

	% Formulate the CTYPE vector -
	for species_index=1:NUM_BALANCED
		CTYPE(species_index,1) = 'S';
	end;

	% Formulate the VARTYPE vector -
	for rate_index=1:NUM_RATES
		VARTYPE(rate_index,1) = 'C';
	end;

	% This code puts bounds on the species, i.e., the mass balances run from l < xmb < u
	SBA=DF.SPECIES_BOUND_ARRAY;
	if (~isempty(SBA))

		% Setup -
		AC=DF.SPECIES_CONSTRAINTS;
		CM = [STM_BALANCED_BLOCK ; AC ; AC];

		N=size(SBA,1);
		for species_index=1:N
			CTYPE(species_index+NUM_BALANCED,1) = 'U';
			bV(species_index+NUM_BALANCED,1)=SBA(species_index,3);
		end;

		M=size(CTYPE,1);
		for species_index=1:N
			CTYPE(species_index+M,1) = 'L';
			bV(species_index+M,1)=SBA(species_index,2);
		end;
	end;

	% Set the sense flag -
	SENSE = 1;

	% Setup the PARAM structure -
	PARAM.msglev = 3;

	% Type of LPSOLVE -

	LPSOLVER = 1;
	% Call GLPK -
	[FLOW,fmin,status,extra]=glpk(OBJVECTOR,CM,bV,LB,UB,CTYPE,VARTYPE,SENSE,PARAM);

	% Calc the actual bV -
	UPTAKE = AC*FLOW;
return;
