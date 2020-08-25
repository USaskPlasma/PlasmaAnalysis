function [r, a] = MakeStruct(FPATH, FNAME, StrucName)
    % Purpose: Create structure for data from read in data
    %
    % Pre-Conditions:
    %   FPATH: Path string to files
    %   FNAME: Cell array of one of more names of files
    %   StrucName: Cell array of names to be given to the structures
    %
    % Return:
    %   r: a structure for individual runs for each file
    %   a: a structure for average/final values as well as ion current or
    %       EEDFs of files are present
    
    N = length(FNAME);
    
    % Names for values
    Names = {'Vfl','Vfl_err','Te_A', 'Te_err_A', 'Vpl_A', 'Vpl_err_A', 'Ie_sat_A', 'Ie_sat_err_A', 'Ne_A', 'Ne_err_A',...
                             'Te_N', 'Te_err_N', 'Vpl_N', 'Vpl_err_N', 'Ie_sat_N', 'Ie_sat_err_N', 'Ne_N', 'Ne_err_N',...
                             'Te_LM','Te_err_LM','Vpl_LM','Vpl_err_LM','Ie_sat_LM','Ie_sat_err_LM','Ne_LM','Ne_err_LM',...
                             'N_OML', 'N_err_OML', 'Rsq_OML',...
                             'N_ABR', 'N_err_ABR', 'Te_ABR', 'Te_err_ABR', 'Rsq_ABR',...
                             'N_BRL', 'N_err_BRL', 'Te_BRL', 'Te_err_BRL', 'Rsq_BRL'};
                     
    for fileId = 1 : N
        % reads in file and gets the number of runs
        d = csvread([FPATH FNAME{fileId}]);
        runs = length(d(:,1))-1;
        
        % Assigns values to structures accordingly
        for ix = 1 : length(Names)
            r.(StrucName{fileId}).(Names{ix}) = d(1:runs,ix);
            a.(StrucName{fileId}).(Names{ix}) = d(runs+1,ix);
        end
        r.(StrucName{fileId}).runs = runs;
        
        %  Try to get average voltage, current and second derivative current data
        try
            d = csvread([FPATH FNAME{fileId}(1:end-4) '_AvgData.csv']);
            a.(StrucName{fileId}).V = d(:,1);
            a.(StrucName{fileId}).V_err = d(:,2);
            a.(StrucName{fileId}).I = d(:,3);
            a.(StrucName{fileId}).I_err = d(:,4);
            if ~isnan(d(1,5)) % column 5 is d2IdV2 values, if this column is NaN then it was never included in the analysis 
                a.(StrucName{fileId}).d2IdV2 = d(:,5);
                a.(StrucName{fileId}).d2IdV2_err = d(:,6);
            end
        end
        
        % Try to get EEDFs and ion current
        try
            d = csvread([FPATH FNAME{fileId}(1:end-4) '_EEDF_A.csv']);
            a.(StrucName{fileId}).V_EEDF_A = d(:,1);
            a.(StrucName{fileId}).EEDF_A = d(:,2);
        end
        try
            d = csvread([FPATH FNAME{fileId}(1:end-4) '_EEDF_N.csv']);
            a.(StrucName{fileId}).V_EEDF_N = d(:,1);
            a.(StrucName{fileId}).EEDF_N = d(:,2);            
        end
        try
            d = csvread([FPATH FNAME{fileId}(1:end-4) '_Iion_OML.csv']);
            a.(StrucName{fileId}).V_OML = d(:,1);
            a.(StrucName{fileId}).I_OML = d(:,2);
        end
        try
            d = csvread([FPATH FNAME{fileId}(1:end-4) '_Iion_ABR.csv']);
            a.(StrucName{fileId}).V_ABR = d(:,1);
            a.(StrucName{fileId}).I_ABR = d(:,2);
        end
        try
            d = csvread([FPATH FNAME{fileId}(1:end-4) '_Iion_BRL.csv']);
            a.(StrucName{fileId}).V_BRL = d(:,1);
            a.(StrucName{fileId}).I_BRL = d(:,2);
        end
    end
    
    % This gives the option to use *.all.* in order to easily access a
    % value from all files at once
    for ix = 1 : length(Names)
        a.all.(Names{ix}) = NaN(N,1);
        
        for fileId = 1 : N          
            a.all.(Names{ix})(fileId) = a.(StrucName{fileId}).(Names{ix}); 
        end
        
    end
    
end