function [Te_err, Vpl_err, Ie_sat_err, Ne_err] = LangmuirMethodError(Vpe, Ipe, Ve, Ie, Ne_Pre, Te, Vpl, Ie_sat, Ne)
    % Purpose: Calculate the max errors based on the confidence of fit
    %   for the linear fits for Pi, Ppe, Pe
    %
    % Pre-Conditions:
    %   Vpe: Voltage range for pre electron saturation current region
    %   Ipe: Current for pre electron saturation current
    %   Ve: Voltage range for electron saturation current region
    %   Ie: Current for electron saturation current region
    %   Ne_Pre: most of the calculation for electron density
    %   Te: Electron Temperature
    %   Vpl: Plasma potential
    %   Ie_sat: Electron saturation current
    %   Ne: Electron density
    %
    % Return:
    %   Te_err: Error for electron temperature
    %   Vpl_err: Error for plasma potential
    %   Ie_sat_err: Error for electron saturation current
    %   Ne_err: Error for electron density
    
    global Confidence
    
    % make fits for max and min Pi
    Ppe = fit(Vpe, log(abs(Ipe)), 'poly1');
    Pe  = fit(Ve,  log(abs(Ie)), 'poly1');
    
    % Gets coefficients of fit
    Ppe_coefs = confint(Ppe,Confidence); 
    Pe_coefs  = confint(Pe,Confidence); 
    
    % Error in electron temperature 
    Te_err = 1./Ppe_coefs(:,1);
        
    % Some preallocations
    Vpl_err = NaN(1,2);
    Ie_sat_err = NaN(1,2);
    Ne_err = NaN(1,2);
    
    % Find error for max and min of fits for Ppe and Pe
    for Eid = 1 : 2
            Vpl_err(Eid) = ( Pe_coefs(Eid,2) - Ppe_coefs(Eid,2) )/( Ppe_coefs(Eid,1) - Pe_coefs(Eid,1) );
            Ie_sat_err(Eid) = exp( polyval( [Ppe_coefs(Eid,1) Ppe_coefs(Eid,2)],Vpl_err(Eid)) );
            Ne_err(Eid) = ( Ie_sat_err(Eid)/sqrt( Te_err(Eid) ))*Ne_Pre;
    end
    
    % after all possible values are found the max absolute error
    % is then found and returned
    Te_err = max(abs(Te_err - Te));
    Vpl_err = max(abs(Vpl_err - Vpl));
    Ie_sat_err = max(abs(Ie_sat_err - Ie_sat));
    Ne_err = max(abs(Ne_err - Ne));
end