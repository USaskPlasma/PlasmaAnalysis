function [Ii] = ABRcurrent(Vi, N)
    % Purpose: return the ABR current for given voltage and plasma density
    %
    % Pre-Conditions:
    %   Vi: Measured probe potential corrected for plasma potential
    %   N: Plasma density
    %
    % Return:
    %   Ii: the ion current for Vi according to the ABR model
    
    global Radius IonAMU Length Te_ABR
    Te = Te_ABR; % ensures that the electron temp used is the same as the temp used to find N using ABRanalysis
    % Sets all voltage past plasma potential to 0
    eta = Vi./Te;
    eta_cut = find(eta<0,1);
    eta(eta_cut:end) = 0;
    
    I_c = 0.327*Length*sqrt(1/IonAMU);
    Xi_c = (Radius/740)*1e5*sqrt(10);
    
    Ii = ( (I_c/Xi_c).*sqrt(Te) .* Te .* nthroot(( ( (0.864*(Xi_c*sqrt(N*1e-11/Te))^(1.5) + 0.2688*(Xi_c*sqrt(N*1e-11/Te))^(2.050)).*(eta).^(0.478519718736423 - 0.0307805633538346*log((Xi_c*sqrt(N*1e-11/Te))) - 0.0122913659851921*(log((Xi_c*sqrt(N*1e-11/Te))))^2) ).^4 + ( (1.008*(Xi_c*sqrt(N*1e-11/Te))^(1.7) + 0.336*(Xi_c*sqrt(N*1e-11/Te))^(2.050)).*(eta).^(0.384361192195781 - 0.148259315734755*log((Xi_c*sqrt(N*1e-11/Te))) + 0.0130482774322456*(log((Xi_c*sqrt(N*1e-11/Te))))^2) ).^4 ),4))./1000;


end