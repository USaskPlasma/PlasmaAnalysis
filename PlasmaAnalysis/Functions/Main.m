function[] = Main( Radius, Length, IonAMU, ...
                 V_prefix, I_prefix, ...
                 Iterations, ...
                 LangmuirAnalysis, AnalogAnalysis, NumericalAnalysis, IonAnalysis, ...
                 V_error_id, I_error_id, d2IdV2_error_id, ...
                 FileName, Save_Avg_IV_Data, EEDF_Out, Ion_Current_Out)
    % Main: does the things ... is the main function
    %
    % Pre-Conditions:
    %   Input-Parameters:
    %       
    %   Radius: probe radius in cm
    %   Length: probe length in cm
    %   IonAMU: ion mass in atomic mass unit
    %
    %   V_prefix: factor for correcting voltage input to volts
    %   I_prefix: factor for correction current input to amps
    %
    %   Iterations: how many iterations of electron current analysis and
    %       ion current analysis should be done.
    %   LangmuirAnalysis: boolean value for if Langmuir analysis is to be
    %       done
    %   AnalogAnalysis: boolean value for if analysis of analog derivatives
    %       is do be done
    %   NumericalAnalysis: boolean value for if analysis using numerical
    %       derivatives is to be done
    %   IonAnalysis: integer to specify which electron current analysis 
    %       is used for ion current analysis (3 for A, 2 for N, 1 for LM)
    %
    %   V_error_id: column for voltage error to be read in from file
    %   I_error_id: column for current error to be read in from file
    %   d2IdV2_error_id: column for analog d^2I/dV^2 to be read from file
    %
    %   FileName: optional parameter for what output files are to be named
    %   Save_Avg_IV_Data: boolean to determine if average voltage, current,
    %       and current second derivative and their errors should be saved
    %       to a .csv
    %   EEDF_Out: value to determine if EEDF output files are to be made
    %   Ion_Current_Out: boolean value for if ion current data output file
    %       is to be made
    %
    %   File-input:
    %   
    %   Input file is to be a comma-separated value file with the I-V curve
    %   number in the first column, voltage data in the second, current
    %   data in the third, and analog second derivative in the forth column
    %   (if provided).
    %
    % Post-Conditions:
    %   A file will be created in the local directory 'Results'
    %   the file contains values like electron temperature, ion density,
    %   plasma potential, etc.
    %   
    %   Files for the EEDF will be created in the same directory will be
    %   made depending on EEDF_Out. First column is ... voltage (in volts),
    %   second is the EEDF values. The file will end in _EEDF_A or _EEDF_N
    %   corresponding to the EEDF found from analog derivatives or
    %   numerical derivatives
    %
    %   A file for ion current data corresponding to the best ion current
    %   fit will be made depending on Ion_Current_Out. First column is
    %   probe voltage (in volts), second is ion current (in amps). The file
    %   will end in _Iion.
    %
    %   All files can be read into appropriate Matlab structures using the
    %   ReadInResults.m script.
                 
    %% Data inputs and formatting - constant values
    global e me e0 Area IonMass UI_off ContinueRuns   
        
        % Load Data
            % Select data file
            [FNAME, FPATH] = uigetfile();

            TextData = csvread([FPATH FNAME]);

            ScanNum = TextData(:,1);
            V = V_prefix.*TextData(:,2);    
            I = I_prefix.*TextData(:,3);
            if V_error_id
                V_err = V_prefix.*TextData(:,V_error_id);
            else
                V_err = NaN;
            end
            if I_error_id
                I_err = I_prefix.*TextData(:,I_error_id);
            else
                I_err = NaN;
            end

            if AnalogAnalysis
                d2IdV2 = I_prefix.*TextData(:,4);
                if d2IdV2_error_id
                    d2IdV2_err = I_prefix.*TextData(:,d2IdV2_error_id);
                end
            else
                d2IdV2 = NaN;
                d2IdV2_err = NaN;
            end
        %
        
        % Manipulate Data

            if I_error_id
                I_err = [(I + I_err), (I - I_err)];
                I_err = DataSorter(I_err,ScanNum);
            end
            if V_error_id
                V_err = [(V + V_err), (V - V_err)];
                V_err = DataSorter(V_err,ScanNum);
            end

            if AnalogAnalysis
                if d2IdV2_error_id
                    d2IdV2_err = [(d2IdV2 + d2IdV2_err), (d2IdV2 - d2IdV2_err)];
                    d2IdV2_err = DataSorter(d2IdV2_err,ScanNum);
                elseif I_error_id
                    d2IdV2_err = [d2IdV2, d2IdV2];
                    d2IdV2_err = DataSorter(d2IdV2_err,ScanNum);
                else
                    d2IdV2_err = NaN;
                end
                d2IdV2 = DataSorter(d2IdV2,ScanNum);
            end
            V = DataSorter(V,ScanNum);
            I = DataSorter(I,ScanNum);

            DataSets = length(V);
            Data_Out = NaN(DataSets+1,39);
        %
        
        % check if the electron current analysis used for ion current
        % analysis is avaliable
            if (IonAnalysis == 3) && ~(AnalogAnalysis)
                error('AnalogAnalysis results to be used for IonAnalysis but AnalogAnalysis not to be done.')
            elseif (IonAnalysis == 2) && ~(NumericalAnalysis)
                error('NumericalAnalysis results to be used for IonAnalysis but NumericalAnalysis not to be done.')
            elseif (IonAnalysis == 1) && ~(LangmuirAnalysis)
                error('LangmuirAnalysis results to be used for IonAnalysis but LangmuirAnalysis not to be done.')
            elseif ~any(IonAnalysis == [0 1 2 3])
                error('IonAnalysis does not correspond to any electron current analysis. Check IonAnalysis')
            end
        %

        % Constants/Simple Params
            e  = 1.602e-19;       % elementary charge
            me = 9.109e-31;       % electron mass
            e0 = 8.854187817e-12; % vacuum permittivity

            Area    = pi*(2*Radius*Length + Radius^2);
            IonMass = IonAMU*1.672e-27; % change AMU to kg
            ContinueRuns = false;
        %
            
    %% Data calculations, error, and collection
    for SetId = 1 : DataSets   
        %% Data calculations
        % Preallocates these values as NaN so that a CSV file can be written in a consistent format
        [Vfloat, Vfloat_err,...
         Te_A, Te_err_A, Vpl_A, Vpl_err_A, Ie_sat_A, Ie_sat_err_A, Ne_A, Ne_err_A,...
         Te_N, Te_err_N, Vpl_N, Vpl_err_N, Ie_sat_N, Ie_sat_err_N, Ne_N, Ne_err_N,...
         Te_LM, Te_err_LM, Vpl_LM, Vpl_err_LM, Ie_sat_LM, Ie_sat_err_LM, Ne_LM, Ne_err_LM] = deal(NaN);

        Vfloat = VfloatFinder(V{SetId},I{SetId}); % Find floating potential
        Ii = NaN;     % Preset Ii to NaN so analyses ignore ion current on first iteration
        NumericalTerminate = false; % Preset false so user can terminate numerical analysis later
        LangmuirBackup = false; % Preset false so LangmuirAnalysis may only happen is numerical analysis is aborted
        if ~ContinueRuns
            UI_off = false; % when UI_off is true NumericalPlasmaAnalysis and LangmuirMethodAnalysis will run with previous user inputs
        end

        % Electron characteristics analysis
        for RunTimes = 1 : Iterations        
            if AnalogAnalysis
                [Te_A, Vpl_A, Ie_sat_A, Ne_A, V_EEDF_A, EEDF_A] = AnalogPlasmaAnalysis(V{SetId},I{SetId},d2IdV2{SetId},Ii);
            end
            if NumericalAnalysis && ~NumericalTerminate
                [Te_N, Vpl_N, Ie_sat_N, Ne_N, V_EEDF_N, EEDF_N] = NumericalPlasmaAnalysis(V{SetId},I{SetId},Ii);
                if isnan(Te_N) % If numerical analysis is aborted then it will be skipped for this data set
                    NumericalTerminate = true;
                    LangmuirBackup = true; % Uses Langmuir method as backup if Numerical analysis is aborted and LangmuirAnalysis is false
                end
            end
            if LangmuirAnalysis || LangmuirBackup
                [Te_LM, Vpl_LM, Ie_sat_LM, Ne_LM, Te_err_LM, Vpl_err_LM, Ie_sat_err_LM, Ne_err_LM] = LangmuirMethodAnalysis(V{SetId},I{SetId},Ii,Vfloat);
            end

            % Selects data to be used in ion current analysis
            if AnalogAnalysis && (IonAnalysis == 3 || IonAnalysis == 0)
                Te = Te_A; Vpl = Vpl_A; Ie_sat = Ie_sat_A; Ne = Ne_A; V_EEDF = V_EEDF_A; EEDF = EEDF_A;
            elseif NumericalAnalysis && ~NumericalTerminate && (IonAnalysis == 2 || IonAnalysis == 0)
                Te = Te_N; Vpl = Vpl_N; Ie_sat = Ie_sat_N; Ne = Ne_N; V_EEDF = V_EEDF_N; EEDF = EEDF_N;
            elseif LangmuirAnalysis || LangmuirBackup
                Te = Te_LM; Vpl = Vpl_LM; Ie_sat = Ie_sat_LM; Ne = Ne_LM; V_EEDF = NaN; EEDF = NaN; Vpl_err = Vpl_err_LM; Ie_sat_err = Ie_sat_err_LM; Ne_err = Ne_err_LM;
            end
            % Ion current analysis
            [N_OML, N_err_OML, Rsq_OML] = OMLanalysis(V{SetId},I{SetId},Vfloat, Vpl, Te, Ne);
            [N_ABR, N_err_ABR, Te_ABR, Te_err_ABR, Rsq_ABR] = ABRanalysis(V{SetId},I{SetId},Vfloat, Vpl, Te, Ne);
            [N_BRL, N_err_BRL, Te_BRL, Te_err_BRL, Rsq_BRL] = BRLanalysis(V{SetId},I{SetId},Vfloat, Vpl, Te, Ne);
            Best_Ii = find( max([Rsq_OML,Rsq_ABR,Rsq_BRL]) == ([Rsq_OML,Rsq_ABR,Rsq_BRL]) );
            % Get best ion current fit
            switch Best_Ii
                case 1
                    Ii = OMLcurrent(Vpl - V{SetId},N_OML);
                case 2
                    Ii = ABRcurrent(Vpl - V{SetId},N_ABR);
                case 3
                    Ii = BRLcurrent(Vpl - V{SetId},N_BRL);
            end
        end    

        %% Error calculations
        UI_off = true; % when UI_off is true NumericalPlasmaAnalysis and LangmuirMethodAnalysis will run with previous user inputs
        clear EVfloat  EVfloat_err  ETe_A  ETe_err_A  EVpl_A  EVpl_err_A  EIe_sat_A  EIe_sat_err_A  ENe_A  ENe_err_A ETe_N  ETe_err_N  EVpl_N  EVpl_err_N  EIe_sat_N  EIe_sat_err_N  ENe_N  ENe_err_N ETe_LM  ETe_err_LM  EVpl_LM  EVpl_err_LM  EIe_sat_LM  EIe_sat_err_LM  ENe_LM  ENe_err_LM EN_OML  EN_err_OML  ERsq_OML EN_ABR  EN_err_ABR  ETe_ABR  ETe_err_ABR  ERsq_ABR EN_BRL  EN_err_BRL  ETe_BRL  ETe_err_BRL  ERsq_BRL EEEDF_N EV_EEDF_N EEEDF_A EV_EEDF_A 
        if iscell(V_err) && iscell(I_err)

            % float error
            EVfloat = [VfloatFinder(V_err{SetId}(:,1),I_err{SetId}(:,1)) VfloatFinder(V_err{SetId}(:,2),I_err{SetId}(:,1)) VfloatFinder(V_err{SetId}(:,1),I_err{SetId}(:,2)) VfloatFinder(V_err{SetId}(:,2),I_err{SetId}(:,2))];

            % Electric characteristics error
            Vfloat_err = max(abs(Vfloat - EVfloat));
            
            for Eid = 1 : 4
                Vid = mod(Eid-1,2)+1;
                Iid = floor((Eid-1)./2)+1;
                if AnalogAnalysis
                    [ETe_A(Eid), EVpl_A(Eid), EIe_sat_A(Eid), ENe_A(Eid), EV_EEDF_A(:,Eid), EEEDF_A(:,Eid)] = AnalogPlasmaAnalysis(V_err{SetId}(:,Vid),I_err{SetId}(:,Iid),d2IdV2_err{SetId}(:,Iid),Ii);
                end
                if NumericalAnalysis && ~NumericalTerminate
                    [ETe_N(Eid), EVpl_N(Eid), EIe_sat_N(Eid), ENe_N(Eid), EV_EEDF_N(:,Eid), EEEDF_N(:,Eid)] = NumericalPlasmaAnalysis(V_err{SetId}(:,Vid),I_err{SetId}(:,Iid),Ii);
                end
                if LangmuirAnalysis || LangmuirBackup
                    [ETe_LM(Eid), EVpl_LM(Eid), EIe_sat_LM(Eid), ENe_LM(Eid), ETe_err_LM(Eid), EVpl_err_LM(Eid), EIe_sat_err_LM(Eid), ENe_err_LM(Eid)] = LangmuirMethodAnalysis(V_err{SetId}(:,Vid),I_err{SetId}(:,Iid),Ii,Vfloat);
                end

                % Selects data to be used in ion current analysis
                if AnalogAnalysis && (IonAnalysis == 3 || IonAnalysis == 0)
                    ETe = ETe_A(Eid); EVpl = EVpl_A(Eid); EIe_sat = EIe_sat_A(Eid); ENe = ENe_A(Eid);
                elseif NumericalAnalysis && ~NumericalTerminate && (IonAnalysis == 2 || IonAnalysis == 0)
                    ETe = ETe_N(Eid); EVpl = EVpl_N(Eid); EIe_sat = EIe_sat_N(Eid); ENe = ENe_N(Eid);
                elseif LangmuirAnalysis || LangmuirBackup
                    ETe = ETe_LM(Eid); EVpl = EVpl_LM(Eid); EIe_sat = EIe_sat_LM(Eid); ENe = ENe_LM(Eid); EV_EEDF = NaN; EEEDF = NaN; EVpl_err = EVpl_err_LM; EIe_sat_err = EIe_sat_err_LM; ENe_err = ENe_err_LM;
                end

                % Ion current analysis            
                % Get best ion current fit
                [EN_OML(Eid), EN_err_OML(Eid), ERsq_OML(Eid)] = OMLanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe,ENe);
                [EN_ABR(Eid), EN_err_ABR(Eid), ETe_ABR(Eid), ETe_err_ABR(Eid), ERsq_ABR(Eid)] = ABRanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe, ENe);
                [EN_BRL(Eid), EN_err_BRL(Eid), ETe_BRL(Eid), ETe_err_BRL(Eid), ERsq_BRL(Eid)] = BRLanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe, ENe);
                switch Best_Ii
                    case 1                    
                        EIi(:,Eid) = OMLcurrent(EVpl - V{SetId},N_OML);
                    case 2
                        EIi(:,Eid) = ABRcurrent(EVpl - V{SetId},N_ABR);
                    case 3                    
                        EIi(:,Eid) = BRLcurrent(EVpl - V{SetId},N_BRL);
                end

            end

        elseif ~iscell(V_err) && iscell(I_err)

            % float error
            EVfloat = [VfloatFinder(V{SetId},I_err{SetId}(:,1)) VfloatFinder(V{SetId},I_err{SetId}(:,2))];

            % Electric characteristics error
            Vfloat_err = max(abs(Vfloat - EVfloat));
            for Eid = 1 : 2
                if AnalogAnalysis
                    [ETe_A(Eid), EVpl_A(Eid), EIe_sat_A(Eid), ENe_A(Eid), EV_EEDF_A(:,Eid), EEEDF_A(:,Eid)] = AnalogPlasmaAnalysis(V{SetId},I_err{SetId}(:,Eid),d2IdV2_err{SetId}(:,Eid),Ii);
                end
                if NumericalAnalysis && ~NumericalTerminate
                    [ETe_N(Eid), EVpl_N(Eid), EIe_sat_N(Eid), ENe_N(Eid), EV_EEDF_N(Eid,:), EEEDF_N(Eid,:)] = NumericalPlasmaAnalysis(V{SetId},I_err{SetId}(:,Eid),Ii);
                end
                if LangmuirAnalysis || LangmuirBackup
                    [ETe_LM(Eid), EVpl_LM(Eid), EIe_sat_LM(Eid), ENe_LM(Eid), ETe_err_LM(Eid), EVpl_err_LM(Eid), EIe_sat_err_LM(Eid), ENe_err_LM(Eid)] = LangmuirMethodAnalysis(V{SetId},I_err{SetId}(:,Eid),Ii,Vfloat);
                end

                % Selects data to be used in ion current analysis
                if AnalogAnalysis && (IonAnalysis == 3 || IonAnalysis == 0)
                    ETe = ETe_A(Eid); EVpl = EVpl_A(Eid); EIe_sat = EIe_sat_A(Eid); ENe = ENe_A(Eid);
                elseif NumericalAnalysis && ~NumericalTerminate && (IonAnalysis == 2 || IonAnalysis == 0)
                    ETe = ETe_N(Eid); EVpl = EVpl_N(Eid); EIe_sat = EIe_sat_N(Eid); ENe = ENe_N(Eid);
                elseif LangmuirAnalysis || LangmuirBackup
                    ETe = ETe_LM(Eid); EVpl = EVpl_LM(Eid); EIe_sat = EIe_sat_LM(Eid); ENe = ENe_LM(Eid); EV_EEDF = NaN; EEEDF = NaN; EVpl_err = EVpl_err_LM; EIe_sat_err = EIe_sat_err_LM; ENe_err = ENe_err_LM;
                end

                % Ion current analysis            
                % Get best ion current fit
                [EN_OML(Eid), EN_err_OML(Eid), ERsq_OML(Eid)] = OMLanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe,ENe);
                [EN_ABR(Eid), EN_err_ABR(Eid), ETe_ABR(Eid), ETe_err_ABR(Eid), ERsq_ABR(Eid)] = ABRanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe, ENe);
                [EN_BRL(Eid), EN_err_BRL(Eid), ETe_BRL(Eid), ETe_err_BRL(Eid), ERsq_BRL(Eid)] = BRLanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe, ENe);
                switch Best_Ii
                    case 1                    
                        EIi(:,Eid) = OMLcurrent(EVpl - V{SetId},N_OML);
                    case 2
                        EIi(:,Eid) = ABRcurrent(EVpl - V{SetId},N_ABR);
                    case 3                    
                        EIi(:,Eid) = BRLcurrent(EVpl - V{SetId},N_BRL);
                end
            end

        elseif iscell(V_err) && ~iscell(I_err)

            % float error
            EVfloat = [VfloatFinder(V_err{SetId}(:,1),I{SetId}) VfloatFinder(V_err{SetId}(:,2),I{SetId})];

            % Electric characteristics error
            Vfloat_err = max(abs(Vfloat - EVfloat));
            for Eid = 1 : 2
                Vid = mod(Eid-1,2)+1;
                Iid = floor((Eid-1)./2)+1;
                if AnalogAnalysis
                    [ETe_A(Eid), EVpl_A(Eid), EIe_sat_A(Eid), ENe_A(Eid), EV_EEDF_A, EEEDF_A] = AnalogPlasmaAnalysis(V_err{SetId}(:,Eid),I{SetId},d2IdV2{SetId},Ii);
                end
                if NumericalAnalysis && ~NumericalTerminate
                    [ETe_N(Eid), EVpl_N(Eid), EIe_sat_N(Eid), ENe_N(Eid), EV_EEDF_N, EEEDF_N] = NumericalPlasmaAnalysis(V_err{SetId}(:,Eid),I{SetId},Ii);
                end
                if LangmuirAnalysis || LangmuirBackup
                    [ETe_LM(Eid), EVpl_LM(Eid), EIe_sat_LM(Eid), ENe_LM(Eid), ETe_err_LM(Eid), EVpl_err_LM(Eid), EIe_sat_err_LM(Eid), ENe_err_LM(Eid)] = LangmuirMethodAnalysis(V_err{SetId}(:,Eid),I{SetId},Ii,Vfloat);
                end            

            % Selects data to be used in ion current analysis
                if AnalogAnalysis && (IonAnalysis == 3 || IonAnalysis == 0)
                    ETe = ETe_A(Eid); EVpl = EVpl_A(Eid); EIe_sat = EIe_sat_A(Eid); ENe = ENe_A(Eid);
                elseif NumericalAnalysis && ~NumericalTerminate && (IonAnalysis == 2 || IonAnalysis == 0)
                    ETe = ETe_N(Eid); EVpl = EVpl_N(Eid); EIe_sat = EIe_sat_N(Eid); ENe = ENe_N(Eid);
                elseif LangmuirAnalysis || LangmuirBackup
                    ETe = ETe_LM(Eid); EVpl = EVpl_LM(Eid); EIe_sat = EIe_sat_LM(Eid); ENe = ENe_LM(Eid); EV_EEDF = NaN; EEEDF = NaN; EVpl_err = EVpl_err_LM; EIe_sat_err = EIe_sat_err_LM; ENe_err = ENe_err_LM;
                end

                % Ion current analysis            
                % Get best ion current fit
                [EN_OML(Eid), EN_err_OML(Eid), ERsq_OML(Eid)] = OMLanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe,ENe);
                [EN_ABR(Eid), EN_err_ABR(Eid), ETe_ABR(Eid), ETe_err_ABR(Eid), ERsq_ABR(Eid)] = ABRanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe, ENe);
                [EN_BRL(Eid), EN_err_BRL(Eid), ETe_BRL(Eid), ETe_err_BRL(Eid), ERsq_BRL(Eid)] = BRLanalysis(V{SetId},I{SetId},EVfloat(Eid), EVpl, ETe, ENe);
                switch Best_Ii
                    case 1                    
                        EIi(:,Eid) = OMLcurrent(EVpl - V{SetId},N_OML);
                    case 2
                        EIi(:,Eid) = ABRcurrent(EVpl - V{SetId},N_ABR);
                    case 3                    
                        EIi(:,Eid) = BRLcurrent(EVpl - V{SetId},N_BRL);
                end
            end
        end

        if iscell(V_err) || iscell(I_err)
            % Sets calculates the max error where applicable
            if AnalogAnalysis
                Te_err_A      = max(abs(Te_A     - ETe_A    )); Vpl_err_A = max(abs(Vpl_A - EVpl_A)); 
                Ie_sat_err_A  = max(abs(Ie_sat_A - EIe_sat_A)); Ne_err_A  = max(abs(Ne_A  - ENe_A));
            end
            if NumericalAnalysis && ~NumericalTerminate
                Te_err_N      = max(abs(Te_N     - ETe_N    )); Vpl_err_N = max(abs(Vpl_N - EVpl_N)); 
                Ie_sat_err_N  = max(abs(Ie_sat_N - EIe_sat_N)); Ne_err_N  = max(abs(Ne_N  - ENe_N));
            end
            if LangmuirAnalysis || LangmuirBackup
                Te_err_LM     = max(abs( [(Te_LM     - (ETe_LM     + ETe_err_LM)),     (Te_LM     - (ETe_LM     - ETe_err_LM))] )); 
                Vpl_err_LM    = max(abs( [(Vpl_LM    - (EVpl_LM    + EVpl_err_LM)),    (Vpl_LM    - (EVpl_LM    - EVpl_err_LM))] )); 
                Ie_sat_err_LM = max(abs( [(Ie_sat_LM - (EIe_sat_LM + EIe_sat_err_LM)), (Ie_sat_LM - (EIe_sat_LM - EIe_sat_err_LM))] ));
                Ne_err_LM     = max(abs( [(Ne_LM     - (ENe_LM     + ENe_err_LM)),     (Ne_LM     - (ENe_LM     - ENe_err_LM))] ));
            end
            % Calculates the errors in ion characteristics
            N_err_OML  = max( abs( [(N_OML  - (EN_OML  +                      EN_err_OML )), (N_OML  - (EN_OML  -                       EN_err_OML))]));
            N_err_ABR  = max( abs( [(N_ABR  - (EN_ABR  + ~isnan(EN_err_ABR) .*EN_err_ABR )), (N_ABR  - (EN_ABR  - ~isnan(EN_err_ABR) .* EN_err_ABR))]));
            Te_err_ABR = max( abs( [(Te_ABR - (ETe_ABR + ~isnan(ETe_err_ABR).*ETe_err_ABR)), (Te_ABR - (ETe_ABR - ~isnan(ETe_err_ABR).* ETe_err_ABR))]));
            N_err_BRL  = max( abs( [(N_BRL  - (EN_BRL  + ~isnan(EN_err_BRL) .*EN_err_BRL )), (N_BRL  - (EN_BRL  - ~isnan(EN_err_BRL) .* EN_err_BRL))]));
            Te_err_BRL = max( abs( [(Te_BRL - (ETe_BRL + ~isnan(ETe_err_BRL).*ETe_err_BRL)), (Te_BRL - (ETe_BRL - ~isnan(ETe_err_BRL).* ETe_err_BRL))]));
        end
        
        %% Formatting Data outputs
        Data_Out(SetId,:) = [Vfloat, Vfloat_err, Te_A,  Te_err_A,  Vpl_A,  Vpl_err_A,  Ie_sat_A,  Ie_sat_err_A,  Ne_A,  Ne_err_A,...
                                                 Te_N,  Te_err_N,  Vpl_N,  Vpl_err_N,  Ie_sat_N,  Ie_sat_err_N,  Ne_N,  Ne_err_N,...
                                                 Te_LM, Te_err_LM, Vpl_LM, Vpl_err_LM, Ie_sat_LM, Ie_sat_err_LM, Ne_LM, Ne_err_LM,...
                                                 N_OML, N_err_OML,                     Rsq_OML,...
                                                 N_ABR, N_err_ABR, Te_ABR, Te_err_ABR, Rsq_ABR,...
                                                 N_BRL, N_err_BRL, Te_BRL, Te_err_BRL, Rsq_BRL];
        % EEDF data for output
        if ( EEDF_Out == 3 ) || ( EEDF_Out == 2 )
            EEDF_A_Out{SetId} = EEDF_A;
            V_EEDF_A_Out{SetId} = V_EEDF_A;
        end
        if ( EEDF_Out == 1 ) || ( EEDF_Out == 3 )
            EEDF_N_Out{SetId} = EEDF_N;
            V_EEDF_N_Out{SetId} = V_EEDF_N;
        end

        % Ion current data for output
        if Ion_Current_Out == 1
            Ii_Out{SetId} = Ii;
        end
    end
    % Store avg voltage, current, and current second derivative and error
    %   to be later written to .csv
    if Save_Avg_IV_Data
        if AnalogAnalysis
            IV_Avg_Data = getAvgData(V,V_err,I,I_err,d2IdV2,d2IdV2_err);
        else
            IV_Avg_Data = getAvgData(V,V_err,I,I_err, NaN, NaN);
        end
    end
    
    ContinueRuns = false;
    %

    %% Outputs
        % File naming and default value outputs
        % file name
        if isnan(FileName)
            FileName = FNAME(1:end-4);
        end

        % Default value outputs
        for Eix = 1 : 14
            Data_Out(DataSets+1,2*Eix-1:2*Eix) = ErrorCrunch(Data_Out(1:DataSets,2*Eix-1:2*Eix));
        end

        Data_Out(DataSets+1,29:39) = [mean(Data_Out(1:DataSets,29)), ErrorCrunch(Data_Out(1:DataSets,30:31)), ErrorCrunch(Data_Out(1:DataSets,32:33)),mean(Data_Out(1:DataSets,34)), ErrorCrunch(Data_Out(1:DataSets,35:36)), ErrorCrunch(Data_Out(1:DataSets,37:38)),mean(Data_Out(1:DataSets,39))];
        csvwrite([pwd '\Results\' FileName '.csv'],Data_Out)
        %
        
        % Average voltage, current, and current second derivative
        if Save_Avg_IV_Data
            csvwrite([pwd '\Results\' FileName '_AvgData.csv'],IV_Avg_Data)
        end
        %
        % EEDF from analog differentiation data output
        if ( EEDF_Out - 2 ) >= 0
            EEDF_Out = EEDF_Out - 2;
            V_EEDF_A = min([ V_EEDF_A_Out{:} ]) : (max(V_EEDF_A_Out{1}) - min(V_EEDF_A_Out{1}))/length(V_EEDF_A_Out{1}) : max([ V_EEDF_A_Out{:} ]);
            EEDF_A = zeros(length( V_EEDF_A ), 1);

            for EEDF_A_ix = 1 : length( EEDF_A_Out )
                EEDF_A_Out{ EEDF_A_ix } = interp1( V_EEDF_A_Out{ EEDF_A_ix }, EEDF_A_Out{ EEDF_A_ix }, V_EEDF_A );
                NaNIxs = find( isnan(EEDF_A_Out{ EEDF_A_ix }) );
                EEDF_A_Out{ EEDF_A_ix }(NaNIxs) = 0;
                EEDF_A = EEDF_A + EEDF_A_Out{ EEDF_A_ix }';
            end
            EEDF_A = EEDF_A ./ length( EEDF_A_Out );

            csvwrite([pwd '\Results\' FileName '_EEDF_A.csv'], [V_EEDF_A', EEDF_A])
        end
        %
        
        % EEDF from numerical differentiation data output
        if ( EEDF_Out - 1 ) == 0
            EEDF_Out = EEDF_Out - 1;
            V_EEDF_N = min([ V_EEDF_N_Out{:} ]) : (max(V_EEDF_N_Out{1}) - min(V_EEDF_N_Out{1}))/length(V_EEDF_N_Out{1}) : max([ V_EEDF_N_Out{:} ]);
            EEDF_N = zeros(length( V_EEDF_N ), 1);

            for EEDF_N_ix = 1 : length( EEDF_N_Out )
                EEDF_N_Out{ EEDF_N_ix } = interp1( V_EEDF_N_Out{ EEDF_N_ix }, EEDF_N_Out{ EEDF_N_ix }, V_EEDF_N );
                NaNIxs = find( isnan(EEDF_N_Out{ EEDF_N_ix }) );
                EEDF_N_Out{ EEDF_N_ix }(NaNIxs) = 0;
                EEDF_N = EEDF_N + EEDF_N_Out{ EEDF_N_ix }';
            end
            EEDF_N = EEDF_N ./ length( EEDF_N_Out );

            csvwrite([pwd '\Results\' FileName '_EEDF_N.csv'], [V_EEDF_N', EEDF_N])
        end
        %
        
        % Ion current output
        if Ion_Current_Out
            V_Out = max(min([ V{:} ])) : V{1}(2) - V{1}(1) : min(max([ V{:} ]));
            Ii = zeros(length( V_Out ), 1);

            for Ii_ix = 1 : length( Ii_Out )
                Ii_Out{ Ii_ix } = interp1( V{ Ii_ix }, Ii_Out{ Ii_ix }, V_Out);
                NaNIxs = find( isnan( Ii_Out{ Ii_ix } ) );
                Ii_Out{ Ii_ix }(NaNIxs) = 0;
                Ii = Ii + Ii_Out{ Ii_ix }';
            end
            Ii = Ii ./ length( Ii_Out );
            
            switch Best_Ii
                case 1
                    Ii_String = 'OML';
                case 2
                    Ii_String = 'ABR';
                case 3
                    Ii_String = 'BRL';
            end
            csvwrite([pwd '\Results\' FileName '_Iion_' Ii_String '.csv'], [V_Out', Ii]);
        end
        %
end