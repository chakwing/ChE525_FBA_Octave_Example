
Flux Balance Analysis (FBA) solution script
===========================================

> Copyright (c) 2014 Varnerlab, 
> School of Chemical and Biomolecular Engineering, 
> Cornell University, Ithaca NY 14853 USA.
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is 
> furnished to do so, subject to the following conditions:
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE. 

Introduction
------------
In this repository you'll find [Octave](https://www.gnu.org/software/octave/) code for the flux balance analysis of the sample network: `Complex-network-example-crop.pdf`. This networks contains four extracellular species (`Ax,Bx,Cx and Dx`) and seven intracellular species (`A,B,C,ADP/ATP and NAD/NADH`) and mimics the tradeoff between oxidative versus substrate level phosphorylation. To solve this model, you'll need to have GNU Octave with the GLPK option installed on your computer. GNU Octave/GLPK is free and can be downloaded from [here](https://www.gnu.org/software/octave/download.html).

###Files
* DataFile.m		Parameter struct that holds problem specific information
* Network.dat		Stoichiometric matrix file (text file)
* FB.dat			List of flux bounds (text file)
* FluxDriver.m	Code which interfaces with the linear programming solver
* Solve.m			Main solution script (you will make changes to this script and execute)	

__How do I solve the FBA problem?__
To solve the FBA problem you execute the Solve.m script. 
Solve will load the DataFile struct from disk, and package all the problem parameters
such as the stoichiometric matrix, flux bounds etc into the DF struct. Solve calls
FluxDriver which interfaces with the linear programming solver. The LP solver returns
the estimated flux profile, and a status flag to determine if the solution was successful. 

__What do I need to change to change the LP problem?__
If the lower bound is: 

`LOWER_BOUND_DXT_BALANCE = 0;`

this means *no* Dx is taken up. On the other hand, if the lower bound is:

`LOWER_BOUND_DXT_BALANCE = -1;`

then d(Dx)/dt > = `LOWER_BOUND_DXT_BALANCE`. If we wanted to simulate unconstrained
Dx uptake, then we would set the lower bound to be:

`LOWER_BOUND_DXT_BALANCE = -inf;`

__What does the LP calculation produce?__

FluxDriver has three output args:

* FLOW			-	NFLUX x 1 vector with the network flux
* status			-	status returned by the octave/matlab LP solver. Octave = GLPK 180 means job completed OK, Matlab = linprog 1 means job completed OK
* UPTAKE			-	NFREE_METAB x 1 vector with unbalanced upatke/production ( d*/dt terms for type II) metabolites
