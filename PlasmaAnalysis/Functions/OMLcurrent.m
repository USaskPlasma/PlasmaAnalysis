function [Ii] = OMLcurrent(Vi, N)
    % Purpose: return the OML current for given voltage and plasma density
    %
    % Pre-Conditions:
    %   Vp: Measured probe potential corrected for plasma potential
    %   N: Plasma density
    %
    % Return:
    %   Ii: the ion current for Vi according to the OML model
    global Area IonAMU
    % Sets all voltage past plasma potential to 0
    Vi_cut = find(Vi<0,1);
    Vi(Vi_cut:end) = 0;
    
    Ii = (1e-11*N*7.05*Area*sqrt(1/IonAMU)*sqrt(Vi))./1000;
end