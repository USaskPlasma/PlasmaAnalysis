function [N, N_err, Rsq] = OMLanalysis(V, I, Vfloat, Vpl, Te, Ne)
    % Purpose: Use OML theory to calculate plasma density by fitting a
    %   function of probe potential to the ion current by varrying density
    %
    % Pre-Conditions:
    %   V: Voltage data
    %   I: Current data
    %   Vfloat: Plasma's floating potential 
    %   Vpl: Plasma potential
    %   Te: Electron temperature
    %   Ne: Electron density for initial guess
    %
    % Return:
    %   N: The plasma density
    %   N_err: The numerical error in N associated with fitting OML current
    %       to the measured ion current
    %   Rsq: the Rsquared value for the model's fit
    
    global Area Confidence IonAMU
    
    float_id = find(V>( Vfloat - 3*Te ),1,'first')-1;
    Vi = -(V(1:float_id) - Vpl);
    Ii = -1000.*I(1:float_id);
    
       
    % modelFun = Area*n*e*(sqrt(2)/pi)*sqrt( abs(e*Vi)/IonMass ) = n_fac*OML_coeff*sqrt(abs(Vi));
    OML_coeff = 7.05*Area*sqrt(1/IonAMU);  
    Grad = OML_coeff*sqrt(Vi);
    
    function [F,Gradient] = modelFun(n_fac)
        F = OML_coeff*sqrt(Vi)*n_fac - Ii;
        if nargout > 1
            Gradient = Grad;
        end
    end
    options = optimset('Jacobian','on','Algorithm', 'levenberg-marquardt', 'Display','off');
    % Optimaze N using lsqnonlin
    [N_factor,resnorm,residual] = lsqnonlin(@modelFun,Ne*1e-11,[],[],options);
    N = N_factor*1e11;

    N_err = 1e11*(max(abs( N_factor - nlparci(N_factor,residual,'jacobian',Grad,'alpha',1-Confidence) )));
    Rsq = 1 - sum( (modelFun(N_factor)).^2 ) / sum((Ii-mean(Ii)).^2);
end