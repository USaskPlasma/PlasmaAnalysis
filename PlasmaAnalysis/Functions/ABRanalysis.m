function [N, N_err, Te, Te_err, Rsq] = ABRanalysis(V, I, Vfloat, Vpl, Te, Ne)
    % Purpose: Use ABR theory to calculate plasma density by fitting a
    %   function of probe potential to the ion current by varrying density
    %
    % Pre-Conditions:
    %   V: Voltage data
    %   I: Current data
    %   Vfloat: Plasma's floating potential
    %   Vpl: Plasma potential
    %   Te: Electron temperature
    %   Ne: Electron density (for estimating plasma density)
    %
    % Return:
    %   N: The plasma density
    %   N_err: The numerical error in N associated with fitting ABR current
    %       to the measured ion current
    %   Te: Fitted electron temperature
    %   Te_err: Error in electron temperature 
    %   Rsq: the Rsquared value for the model's fit
    
    global Radius Confidence IonAMU Length Te_ABR
    
    first_id = 1;    
    float_id = find(V>(Vfloat - 3*Te),1,'first');
    Vi = Vpl - V(first_id:float_id);
    Ii = (-1000.*I(first_id:float_id));

    I_c = 0.327*Length*sqrt(1/IonAMU);
    Xi_c = (Radius/740)*1e5*sqrt(10);
    
    % A = 0.864*(Xi_c*sqrt(c(1)/c(2)))^(1.5) + 0.2688*(Xi_c*sqrt(c(1)/c(2)))^(2.050)
    % B = 0.478519718736423 - 0.0307805633538346*log((Xi_c*sqrt(c(1)/c(2)))) - 0.0122913659851921*(log((Xi_c*sqrt(c(1)/c(2)))))^2
    % C = 1.008*(Xi_c*sqrt(c(1)/c(2)))^(1.7) + 0.336*(Xi_c*sqrt(c(1)/c(2)))^(2.050)
    % D = 0.384361192195781 - 0.148259315734755*log((Xi_c*sqrt(c(1)/c(2)))) + 0.0130482774322456*(log((Xi_c*sqrt(c(1)/c(2)))))^2
    % xi = (Xi_c*sqrt(c(1)/c(2)))

    % First tries to get both plasma density and electron temperature
    try
        modelFun = @(c,Vi)( (I_c/Xi_c).*sqrt(abs(c(2))) .* c(2) .* nthroot(abs( ( (0.864*(Xi_c*sqrt(c(1)/c(2)))^(1.5) + 0.2688*(Xi_c*sqrt(c(1)/c(2)))^(2.050)).*(Vi./c(2)).^(0.478519718736423 - 0.0307805633538346*log((Xi_c*sqrt(c(1)/c(2)))) - 0.0122913659851921*(log((Xi_c*sqrt(c(1)/c(2)))))^2) ).^4 + ( (1.008*(Xi_c*sqrt(c(1)/c(2)))^(1.7) + 0.336*(Xi_c*sqrt(c(1)/c(2)))^(2.050)).*(Vi./c(2)).^(0.384361192195781 - 0.148259315734755*log((Xi_c*sqrt(c(1)/c(2)))) + 0.0130482774322456*(log((Xi_c*sqrt(c(1)/c(2)))))^2) ).^4 ),4));
        ABRModel = fitnlm(Vi,Ii,modelFun,[1e-11*Ne, Te]);
        ABR_coeffs = ABRModel.Coefficients.Estimate;
    catch
        ABR_coeffs = [0 0]; 
    end
    % If the electron temperature is way too far off then only the plasma density will be found
    if ABR_coeffs(2) > 2*Te || ABR_coeffs(2) < Te/2
        modelFunN = @(n_fac,Vi)( (I_c/Xi_c).*sqrt(Te) .* sign(n_fac) .* Te .* nthroot(( ( (0.864*(Xi_c*sqrt(abs(n_fac)/Te))^(1.5) + 0.2688*(Xi_c*sqrt(abs(n_fac)/Te))^(2.050)).*(Vi./Te).^(0.478519718736423 - 0.0307805633538346*log((Xi_c*sqrt(abs(n_fac)/Te))) - 0.0122913659851921*(log((Xi_c*sqrt(abs(n_fac)/Te))))^2) ).^4 + ( (1.008*(Xi_c*sqrt(abs(n_fac)/Te))^(1.7) + 0.336*(Xi_c*sqrt(abs(n_fac)/Te))^(2.050)).*(Vi./Te).^(0.384361192195781 - 0.148259315734755*log((Xi_c*sqrt(abs(n_fac)/Te))) + 0.0130482774322456*(log((Xi_c*sqrt(abs(n_fac)/Te))))^2) ).^4 ),4));
        % fits the plasma density parameter in the ABR model to ion current
        ABRModelN = fitnlm(Vi,Ii,modelFunN,1e-11*Ne);
        
        N = abs(ABRModelN.Coefficients.Estimate*1e11);
        if N > 5*Ne || N < Ne/5
            N = NaN; N_err = NaN; Te = NaN; Te_err = NaN; Rsq = NaN;
            return
        end
        
        N_err = max(abs(N - coefCI(ABRModelN,1-Confidence).*1e11));
        
        Rsq = ABRModelN.Rsquared.Adjusted;
        Te_ABR = Te; % makes global the Te used for the ABR model fit for this function and ABRcurrent
        
        Te = NaN; % Sets the returned value of Te to NaN to indicate that it couldn't be found
        Te_err = NaN;
    else
        N = abs(ABR_coeffs(1)*1e11);
        Te = ABR_coeffs(2);
        Err = coefCI(ABRModel,1-Confidence);
        N_err = max([ABR_coeffs(1)-Err(1,1) Err(1,2)-ABR_coeffs(1)])*1e11;
        Te_err = max([Te-Err(2,1) Err(2,2)-Te]);
        Rsq = ABRModel.Rsquared.Adjusted;
        Te_ABR = Te; % makes global the Te used for the ABR model fit for this function and ABRcurrent
    end
end