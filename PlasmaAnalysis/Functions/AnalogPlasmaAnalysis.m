function [Te, Vpl, Ie_sat, Ne, V_EEDF, EEDF] = AnalogPlasmaAnalysis(V,I,d2IdV2,Ii)
    % Purpose: To compute important plasma parameters using analog
    %   derivatives of the current vs. voltage data
    %
    % Pre-Conditions:
    %   V: Voltage data
    %   I: Current with respect to voltage
    %   d2IdV2: Second derivative of current w/ respect to voltage
    %   Ii: Provided ion current from best fit model
    %
    % Return:
    %   Te: Electron temperature
    %   Vpl: Plasma Potential
    %   Ie_sat: Electron saturation current
    %   Ne: Electron density
    %   V_EEDF: Voltage for electron energy distribution function
    %   EEDF: Electron energy distribution function
    global e me Area
    
    N = length(V); % number of data points
    
    % Interpolates data in order to have even voltage spacing
    V_interp = linspace(min(V),max(V),N);
    I_interp = interp1(V,I,V_interp,'pchip');
    d2IdV2_interp = interp1(V,d2IdV2,V_interp,'pchip');
    
    % find the max of second derivative which is normally between float
    % potential and plasma potential    
    maxId = find(d2IdV2_interp(round(N/2):end) == max(d2IdV2_interp(round(N/2):end)),1) + round(N/2) - 1;
    
    % if ion current is provided for this iteration it is taken into
    % account for the total current
    if ~isnan( Ii )
        Ii_interp = interp1(V,Ii,V_interp,'pchip');
        d2IidV2 = CentralDifferenceDerivative(V_interp, CentralDifferenceDerivative( V_interp, Ii_interp ));
        d2IdV2_interp = d2IdV2_interp + d2IidV2;
    end
    
    
    % finds the domain for the EEDF by looking for the zeros of d2IdV2
    %   adjacent to the maximum   
    domain = [ find( d2IdV2_interp(1:maxId) <= 0, 1, 'last' ) find( d2IdV2_interp(maxId:end) < 0, 1 )+maxId-1 ];
    
    % If less than 2 zeros are found for the domain some assumptions are made 
    if isempty(domain)
        domain = [1 N];
    elseif (length(domain) == 1) && (domain < maxId)
        domain(1) = domain(1) + 1;
        domain(2) = N;
    elseif (length(domain) == 1) && (domain > maxId)
        domain(2) = domain(1) - 1;
        domain(1) = 1;
    elseif (length(domain) == 2) && (domain(1) >= domain(2))
        domain(2) = domain(1);
        domain(1) = 1;
    else
        domain(1) = domain(1) + 1;
        domain(2) = domain(2) - 1;        
    end
    Vpl = interp1(d2IdV2_interp( domain(2)-1:domain(2)+1 ), V_interp( domain(2)-1:domain(2)+1 ), 0, 'pchip');
    
    % now for EEDF    
    d2IdV2_EEDF = flip(d2IdV2_interp( domain(1):domain(2)-1 )); % restricts and flips current's second derivative  
    V_EEDF = flip(Vpl - V_interp(domain(1):domain(2)-1));
    EEDF = ( 2 / (Area*e^2) ) .* sqrt( (2.*me.*V_EEDF)./ e ).*d2IdV2_EEDF; 
    
    % final calculations for plasma values
    Ie_sat = interp1(V_interp, I_interp, Vpl, 'pchip'); % finds current at plasma potential
    Ne = 1e-2*trapz(V_EEDF,e*EEDF); % dE=edV
    Te = ( 2e-2/(3.*Ne) ) .* trapz(V_EEDF, e.*V_EEDF.*EEDF); % E=eV et dE=edV, divided by e to convert to eV
    
end