 global Radius Confidence IonAMU Length; addpath([pwd '/Functions/'])

% Input Params
    Radius  = 0.015/2; % in cm
    Length  = 1.02; % in cm
    
    % IonAMU = sum( ci*sqrt( mi/qi ) )^2
    % ci = fraction of ion in plasma
    % qi = number of excess charges of ion
    % mi = ion mass (in AMU)
    IonAMU  = (0.85*sqrt(28) + 0.15*sqrt(14))^2; % effective ion mass
    
    V_prefix = 1; % i.e. for volts put 1, for mV put 1e-3
    I_prefix = 1; % i.e. for amps put 1, for mA put 1e-3 
    
    Confidence = 0.95; % Confidence value for error calculations
    
    Iterations        = 5; % Number of iterations done on each data set    
    AnalogAnalysis    = true; % Are current/time derivatives included?
    NumericalAnalysis = true; % Anaylze using numerical differentiation
    LangmuirAnalysis  = true; % Analyze using Langmuir method
    
    % Which electron characteristic analysis results (Vpl, Te, Ne) should 
    % be used for ion-current analysis?
    IonAnalysis = 3; % 3 for AnalogAnalysis, 2 for NumericalAnalysis, 1 for LangmuirAnalysis
    
    % Error must be absolute error
    % (voltage data is second column, current
    %   data is third column, d2IdV2 is in fourth column if it's provided)
    V_error_id      = 5; % If error for voltage, current, or current
    I_error_id      = 0; %   analog second derivative is provided specify
    d2IdV2_error_id = 0; %   the column it's located in. Otherwise put 0.
%

% Output Params
    FileName          = NaN;  % Use NaN to default to (InputFile).csv
    Save_Avg_IV_Data  = 1; % Save voltage, current, and d2I/dV2 data to .csv 
    EEDF_Out          = 3; % Enter a sum: 2*Analog + 1*Numerical or enter 0 for no EEDF
    Ion_Current_Out   = 1; % Enter boolean: true for best ion-current fit, false for no ion-current
%

Main( Radius, Length, IonAMU, ...
      V_prefix, I_prefix, ...
      Iterations, ...
      LangmuirAnalysis, AnalogAnalysis, NumericalAnalysis, IonAnalysis, ...
      V_error_id, I_error_id, d2IdV2_error_id, ...
      FileName, Save_Avg_IV_Data, EEDF_Out, Ion_Current_Out);