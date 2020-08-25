% Use this script to read in data from PlasmaAnalysis output files

% Fname and StrucName are to be cell arrays corresponding to the file name
%   and the respective structure name
FName = {'ProbeData_150W_15mT.csv','ProbeData_150W_25mT.csv'};
StrucName = {'W150_15mT','W150_25mT'};


FPath = [pwd '\Results\']; addpath([pwd '/Functions/'])
t = MakeTable(FPath, FName, StrucName);
[r, a] = MakeStruct(FPath, FName, StrucName);

% TO ACCESS DATA
%
% use t.name (name corresponding to StrucName) to get individual tables
%
% r includes data for all runs and a is of the averages.
%
% Use [r|a].name.valueName to get the value from the file (according to
% name) for a specific parameter (Te_N, Vpl_N, Ne_LM, N_BRL, etc).
%
% Notice: for the averages you can do a.all.valueName which will give a
% column of average values from each file according to the order of
% StrucName