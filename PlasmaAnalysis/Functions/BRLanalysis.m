function [N, N_err, Te, Te_err, Rsq] = BRLanalysis(V, I, Vfloat, Vpl, Te, Ne)
    % Purpose: Use BRL theory to calculate plasma density by fitting a
    %   function of probe potential to the ion current by varrying density
    %
    % Pre-Conditions:
    %   V: Voltage data
    %   I: Current data
    %   Vfloat: Plasma's floating potential
    %   Vpl: Plasma potential
    %   Te: Electron temperature
    %   Ne: Electron density for guessing plasma density
    %
    % Return:
    %   N: The plasma density
    %   N_err: The numerical error in N associated with fitting BRL current
    %       to the measured ion current
    %   Rsq: the Rsquared value for the model's fit
    
    global IonAMU Area Radius Confidence Te_BRL
        
    first_id = 1;    
    float_id = find(V>(Vfloat - 3*Te),1,'first');
    Vi = Vpl - V(first_id:float_id);
    Ii = (-1000.*I(first_id:float_id));
    
    BRL_coeff = 1.602*Area*sqrt(95.8/( 2*pi*IonAMU ));
    Xi_c = (Radius/740)*1e5*sqrt(10);
    % A = (1.12 + 1/( (1/(0.000342258515120471*(Xi_c*sqrt(c(1)/c(2)))^(6.86767563480315) )) - (1/( 0.144752959352046*log((Xi_c*sqrt(c(1)/c(2)))/110) )) ))
    % B = (0.50 + 0.008*(Xi_c*sqrt(c(1)/c(2)))^(1.5)*exp(-0.18*(Xi_c*sqrt(c(1)/c(2)))^(0.8)))
    % C = (1.06535496204454 + 0.95200710856877*(Xi_c*sqrt(c(1)/c(2)))^(-1.00828247177986))
    % D = (0.0479983825339243 + 1.54032326454982*(Xi_c*sqrt(c(1)/c(2)))^(0.299761386116681)*exp(-1.13544899709102*(Xi_c*sqrt(c(1)/c(2)))^(0.369774411668425)))
    
    try
        modelFun = @(c,Vi)nthroot(abs( 1 ./ ( (1./( (1.12 + 1./( 1./(0.000342258515120471*(Xi_c*sqrt(c(1)/c(2)))^(6.86767563480315) ) - 1./( 0.144752959352046.*log((Xi_c.*sqrt(c(1)/c(2)))./110) ) )).*((Vi./c(2)).^(0.50 + 0.008.*(Xi_c*sqrt(c(1)./c(2))).^(1.5).*exp(-0.18.*(Xi_c.*sqrt(c(1)/c(2))).^(0.8)))) ).^4)+ (1./( (1.06535496204454 + 0.95200710856877.*(Xi_c*sqrt(c(1)/c(2))).^(-1.00828247177986)).*((Vi./c(2)).^(0.0479983825339243 + 1.54032326454982*(Xi_c*sqrt(c(1)/c(2))).^(0.299761386116681)*exp(-1.13544899709102*(Xi_c*sqrt(c(1)/c(2)))^(0.369774411668425)))) ).^4) ) ),4).*( BRL_coeff*c(1)*sqrt(c(2)) );
        BRLModel = fitnlm(Vi,Ii,modelFun,[1e-11*Ne, Te]);
        BRL_coeffs = BRLModel.Coefficients.Estimate;
    catch
        BRL_coeffs = [0 0];
    end
    % If the electron temperature is way too far off then only the plasma density will be found
    if BRL_coeffs(2) > 2*Te || BRL_coeffs(2) < Te/2
        modelFunN = @(c,Vi)nthroot(( 1 ./ ( (1./( (1.12 + 1./( 1./(0.000342258515120471*(Xi_c*sqrt(abs(c(1))/Te))^(6.86767563480315) ) - 1./( 0.144752959352046.*log((Xi_c.*sqrt(abs(c(1))/Te))./110) ) )).*((Vi./Te).^(0.50 + 0.008.*(Xi_c*sqrt(abs(c(1))./Te)).^(1.5).*exp(-0.18.*(Xi_c.*sqrt(abs(c(1))/Te)).^(0.8)))) ).^4)+ (1./( (1.06535496204454 + 0.95200710856877.*(Xi_c*sqrt(abs(c(1))/Te)).^(-1.00828247177986)).*((Vi./Te).^(0.0479983825339243 + 1.54032326454982*(Xi_c*sqrt(abs(c(1))/Te)).^(0.299761386116681)*exp(-1.13544899709102*(Xi_c*sqrt(abs(c(1))/Te))^(0.369774411668425)))) ).^4) ) ),4).*( BRL_coeff*c(1)*sqrt(Te) );
        % fits the plasma density parameter in the BRL model to ion current
        BRLModelN = fitnlm(Vi,Ii,modelFunN,1e-11*Ne);
        
        N = abs(BRLModelN.Coefficients.Estimate*1e11);
        if N > 5*Ne || N < Ne/5
            N = NaN; N_err = NaN; Te = NaN; Te_err = NaN; Rsq = NaN;
            return
        end
        
        N_err = max(abs(N - coefCI(BRLModelN,1-Confidence).*1e11));
        
        Rsq = BRLModelN.Rsquared.Adjusted;
        Te_BRL = Te; % makes global the Te used for the BRL model fit for this function and BRLcurrent
        
        Te = NaN; % Sets the returned value of Te to NaN to indicate that it couldn't be found
        Te_err = NaN;
    else
        N = abs(BRL_coeffs(1)*1e11);
        Te = BRL_coeffs(2);
        Err = coefCI(BRLModel,1-Confidence);
        N_err = max([BRL_coeffs(1)-Err(1,1) Err(1,2)-BRL_coeffs(1)])*1e11;
        Te_err = max([Te-Err(2,1) Err(2,2)-Te]);
        Rsq = BRLModel.Rsquared.Adjusted;
        Te_BRL = Te; % makes global the Te used for the BRL model fit for this function and BRLcurrent
    end  
end