function [Ii] = BRLcurrent(Vi, N)
    % Purpose: return the BRL current for given voltage and plasma density
    %
    % Pre-Conditions:
    %   Vp: Measured probe potential corrected for plasma potential
    %   N: Plasma density
    %
    % Return:
    %   Ii: the ion current for Vi according to the BRL model
    
    global Radius Area  Te_BRL IonAMU
    Te = Te_BRL; % ensures that the electron temp used is the same as the temp used to find N using BRLanalysis
    
    eta = Vi./Te;
    eta_cut = find(eta<0,1);
    eta(eta_cut:end) = 0;
    
    BRL_coeff = 1.602*Area*sqrt(95.8/( 2*pi*IonAMU ));
    Xi_c = (Radius/740)*1e5*sqrt(10);
    
    Ii = nthroot(( 1 ./ ( (1./( (1.12 + 1./( 1./(0.000342258515120471*(Xi_c*sqrt(N*1e-11/Te))^(6.86767563480315) ) - 1./( 0.144752959352046.*log((Xi_c.*sqrt(N*1e-11/Te))./110) ) )).*((eta).^(0.50 + 0.008.*(Xi_c*sqrt(N*1e-11./Te)).^(1.5).*exp(-0.18.*(Xi_c.*sqrt(N*1e-11/Te)).^(0.8)))) ).^4)+ (1./( (1.06535496204454 + 0.95200710856877.*(Xi_c*sqrt(N*1e-11/Te)).^(-1.00828247177986)).*((eta).^(0.0479983825339243 + 1.54032326454982*(Xi_c*sqrt(N*1e-11/Te)).^(0.299761386116681)*exp(-1.13544899709102*(Xi_c*sqrt(N*1e-11/Te))^(0.369774411668425)))) ).^4) ) ),4).*( BRL_coeff*N*1e-11*sqrt(Te) )./1000;


end