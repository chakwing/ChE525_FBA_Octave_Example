% Script for network analysis -


% Load the stoichiometric network - 
stoichiometric_matrix = load('Network.dat');

% Make the binary version -
% *** HACK: We have only 0,1,-1, so take the absolute value
binary_stoichiometric_matrix = abs(stoichiometric_matrix);

% Compute the metabolite connectivity matrix -
metabolite_connectivity_matrix = binary_stoichiometric_matrix*transpose(binary_stoichiometric_matrix);

% Compute the reaction connectivity matrix -
reaction_connectivity_matrix =  transpose(binary_stoichiometric_matrix)*binary_stoichiometric_matrix;

% calculate the metabolite crosstalk -
crosstalk_metabolite = tril(metabolite_connectivity_matrix - eye(11,11).*diag(metabolite_connectivity_matrix));

% calculate the reaction crosstalk -
crosstalk_reaction = tril(reaction_connectivity_matrix - eye(8,8).*diag(reaction_connectivity_matrix));

