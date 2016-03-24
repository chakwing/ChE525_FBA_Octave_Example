% ------------------------------------------------------------------------------------- %
% Copyright (c) 2014 Varnerlab, 
% School of Chemical and Biomolecular Engineering, 
% Cornell University, Ithaca NY 14853 USA.
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is 
% furnished to do so, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% Solve.m
% Solution script to solve FBA problems. Sets options for FluxDriver.m
% ------------------------------------------------------------------------------------- %
%
% =================== PHASE ONE: PROBLEM SETUP ======================================== %
% Setup uptake/production constraints -
qUptake_Ax = 1.0;

% Bounds for D uptake => bounds on d(Dx)/dt
LOWER_BOUND_DXT_BALANCE = -inf;
UPPER_BOUND_DXT_BALANCE = 0;

% index -
INDEX_BOUNDS_A 	= 1;
INDEX_BOUNDS_B	= 2;
INDEX_BOUNDS_C	= 3;
INDEX_BOUNDS_D	= 4;

% Are we minimizing (1) -or- maximizing (-1)?
MIN_MAX_FLAG = -1;
FLUX_INDEX_PRODUCTION = 6; 
OBJ_VECTOR = [FLUX_INDEX_PRODUCTION];
% ====================================================================================== %
%
% =================== PHASE TWO: PROBLEM SOLUTION ====================================== %
% Set the pointer to the DataFile for the FBA problem
pDataFile = @DataFile;

% Create an instance of the data file -
DF = feval(pDataFile,MIN_MAX_FLAG,OBJ_VECTOR);

% Set problem specific constraints -
SBA = DF.SPECIES_BOUND_ARRAY;

% Bounds on d(A_x)/dt -
SBA(INDEX_BOUNDS_A,2) = -1*qUptake_Ax;
SBA(INDEX_BOUNDS_A,3) = -1*qUptake_Ax;

% Bounds on d(B_x)/dt -
%SBA(INDEX_BOUNDS_B,2) = qProduction_Bx;
%SBA(INDEX_BOUNDS_B,3) = 10*qProduction_Bx;

% Bounds on d(C_x)/dt -
%SBA(INDEX_BOUNDS_C,2) = qProduction_Cx;
%SBA(INDEX_BOUNDS_C,3) = 10*qProduction_Cx;

% Bounds on d(D_x)/dt -
SBA(INDEX_BOUNDS_D,2) = LOWER_BOUND_DXT_BALANCE;
SBA(INDEX_BOUNDS_D,3) = UPPER_BOUND_DXT_BALANCE;

% set the bounds -
DF.SPECIES_BOUND_ARRAY = SBA;

% Call the FBA solver -
[FLOW,status,UPTAKE] = FluxDriver(pDataFile,OBJ_VECTOR,MIN_MAX_FLAG,DF);
% ====================================================================================== %