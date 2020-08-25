function [t] = MakeTable(FPATH, FNAME, StrucName)
    % Purpose: Create structure of tables for data from read in data
    %
    % Pre-Conditions:
    %   FPATH: Path string to files
    %   FNAME: Cell array of one of more names of files
    %   StrucName: Cell array of names to be given to the structures
    %
    % Return:
    %   t: a structure of tables corresponding to the files and StrucName
    N = length(FNAME);
    format shortg
    % Names for values
    Names = {'Vfl','Vfl_err','Te_A', 'Te_err_A', 'Vpl_A', 'Vpl_err_A', 'Ie_sat_A', 'Ie_sat_err_A', 'Ne_A', 'Ne_err_A',...
                         'Te_N', 'Te_err_N', 'Vpl_N', 'Vpl_err_N', 'Ie_sat_N', 'Ie_sat_err_N', 'Ne_N', 'Ne_err_N',...
                         'Te_LM', 'Te_err_LM', 'Vpl_LM', 'Vpl_err_LM', 'Ie_sat_LM', 'Ie_sat_err_LM', 'Ne_LM', 'Ne_err_LM',...
                         'N_OML', 'N_err_OML', 'Rsq_OML',...
                         'N_ABR', 'N_err_ABR', 'Te_ABR', 'Te_err_ABR', 'Rsq_ABR',...
                         'N_BRL', 'N_err_BRL', 'Te_BRL', 'Te_err_BRL', 'Rsq_BRL'};
                     
    for fileId = 1 : N
        % reads in file and gets the number of runs
        d = csvread([FPATH FNAME{fileId}]);
        runs = length(d(:,1))-1;

        % Creates row names for the table
        rowNames = {'Avg'};
        for runId = runs : -1: 1
            rowNames = [{['Run ' num2str(runId)]}; rowNames];
        end
        
        % Creates an empty table with only row names
        t.(StrucName{fileId}) = table('RowNames',rowNames);
        
        % Assigns each value to each column accordingly
        for ix = 1 : 39
            t.(StrucName{fileId}).(Names{ix}) = d(1:runs+1,ix);           
        end 
    end
end