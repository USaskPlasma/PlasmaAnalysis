function [Te, Vpl, Ie_sat, Ne, V_EEDF, EEDF] = NumericalPlasmaAnalysis(V,I,Ii)
    % Purpose: To compute important plasma parameters using numerical
    %   derivatives of the current vs. voltage data
    %
    % Pre-Conditions:
    %   V: Voltage data
    %   I: Current data
    %   Ii: Provided ion current
    %
    % Return:
    %   Te: Electron temperature
    %   Vpl: Plasma Potential
    %   Ie_sat: Electron saturation current
    %   Ne: Electron density
    %   V_EEDF_N: Voltage for electron energy distribution function
    %   EEDF: Electron energy distribution function
    
    % global flags from NumericInputs GUI
    global flagContinue e me Area PolyOrder WinLen flagAbort UI_off
    flagContinue = 0;
    flagAbort = 0;
    
    N = length(V); % number of data points
    
    % Interpolates data in order to have even voltage spacing
    V_interp = linspace(min(V),max(V),N);
    I_interp = interp1(V,I,V_interp,'pchip');
    
    % If ion current is not provided then it is set to an array of zeros    
    if isnan(Ii)
        Ii = zeros(N,1)';
    else
        Ii = interp1(V,Ii,V_interp,'pchip');
    end
    
    if ~UI_off
        % Creates new figure with Current/Voltage interpolated values
        figure()
        hold on
        plot(V_interp,I_interp+Ii,'k','linewidth',1.2)
        grid on
        grid minor
        axis tight
        title(['Current vs. Voltage (', num2str(N), ' Pts) and Their Numerical Derivatives (Scaled)'])
        xlabel('Bias Voltage, (V)')
        ylabel('I')
        set(gcf, 'Position', get(gcf,'Position').*[1 0.8 0 0] + [0 0 700 525]);
        legend({' I '},'Location','northwest')
        hold off

        % Gets GUI handles which will be used to aquire inputs
        NumericIn = NumericInputs;
        UserIn = guihandles( NumericIn );

        try % Tries to prefill the GUI if the variables were defined in this function on an earlier call
            UserIn.PolyOrder.String = num2str(PolyOrder);
            UserIn.WinLen.String = num2str(WinLen);

            % Uses savistzkyGolatFilt to smooth and differentiate
            I_smooth = savitzkyGolayFilt(I_interp+Ii,PolyOrder,0,WinLen);
            dIidV = CentralDifferenceDerivative(V_interp,Ii);
            dIdV = savitzkyGolayFilt(I_interp,PolyOrder,1,WinLen)/(V_interp(1)-V_interp(2)) + dIidV;
            d2IidV2 = CentralDifferenceDerivative(V_interp,dIidV);
            d2IdV2 = savitzkyGolayFilt(I_interp,PolyOrder,2,WinLen)/( (V_interp(1)-V_interp(2))^2 ) + d2IidV2;

            % Plots smoothed data and numerical derivatives
            plot(V_interp,I_interp,'k','linewidth',1.2)
            hold on
            plot(V_interp,I_smooth,'--m','linewidth',1.2)
            plot(V_interp,dIdV.*max(I_interp)./max(dIdV),'b','linewidth',1.2)
            plot(V_interp,d2IdV2.*max(I_interp)./max(d2IdV2),'r','linewidth',1.2)
            grid on
            grid minor
            axis tight
            title(['Current vs. Voltage (', num2str(N), ' Pts) and Their Numerical Derivatives (Scaled)'])
            xlabel('Bias Voltage, (V)')
            ylabel('I, dI/dV, d^{2}I/dV^{2}')
            legend({' I ', ' I\_smoothed ', ' dI/dV ', ' d^{2}I/dV^{2} '},'Location','northwest')
            hold off
        end

        while ~flagContinue % Once 'Continue' is pressed the loop ends
            % Continue and Update buttons have uiresume on callback
            uiwait(NumericIn)

            if flagAbort
                Abort = num2cell(NaN(1,6));
                [Te, Vpl, Ie_sat, Ne, V_EEDF, EEDF] = deal(Abort{:});
                return
            end

            % Aquires data from fields
            PolyOrder = str2double(UserIn.PolyOrder.String);
            WinLen = str2double(UserIn.WinLen.String);

            if mod(WinLen,2) ~= 1
                errordlg('The window length must be an odd integer')
            elseif round(PolyOrder) ~= PolyOrder || PolyOrder < 2
                errordlg('Polynomial order must be an integer greater than 2.')
            elseif PolyOrder > WinLen-1
                errordlg('The Polynomial order must be less than the window length.')
            else
                % Uses savistzkyGolatFilt to smooth and differentiate
                I_smooth = savitzkyGolayFilt(I_interp+Ii,PolyOrder,0,WinLen);
                dIidV = CentralDifferenceDerivative(V_interp,Ii);
                dIdV = savitzkyGolayFilt(I_interp,PolyOrder,1,WinLen)/(V_interp(1)-V_interp(2)) + dIidV;
                d2IidV2 = CentralDifferenceDerivative(V_interp,dIidV);
                d2IdV2 = savitzkyGolayFilt(I_interp,PolyOrder,2,WinLen)/( (V_interp(1)-V_interp(2))^2 ) + d2IidV2;

                % Plots smoothed data and numerical derivatives
                plot(V_interp,I_interp,'k','linewidth',1.2)
                hold on
                plot(V_interp,I_smooth,'--m','linewidth',1.2)
                plot(V_interp,dIdV.*max(I_interp)./max(dIdV),'b','linewidth',1.2)
                plot(V_interp,d2IdV2.*max(I_interp)./max(d2IdV2),'r','linewidth',1.2)
                grid on
                grid minor
                axis tight
                title(['Current vs. Voltage (', num2str(N), ' Pts) and Their Numerical Derivatives (Scaled)'])
                xlabel('Bias Voltage, (V)')
                ylabel('I, dI/dV, d^{2}I/dV^{2}')
                legend({' I ', ' I\_smoothed ', ' dI/dV ', ' d^{2}I/dV^{2} '},'Location','northwest')
                hold off
            end

        end
        close, closereq % closes plot and GUI
        
    else
        % Uses savistzkyGolatFilt to smooth and differentiate
        I_smooth = savitzkyGolayFilt(I_interp+Ii,PolyOrder,0,WinLen);
        dIidV = CentralDifferenceDerivative(V_interp,Ii);
        dIdV = savitzkyGolayFilt(I_interp,PolyOrder,1,WinLen)/(V_interp(1)-V_interp(2)) + dIidV;
        d2IidV2 = CentralDifferenceDerivative(V_interp,dIidV);
        d2IdV2 = savitzkyGolayFilt(I_interp,PolyOrder,2,WinLen)/( (V_interp(1)-V_interp(2))^2 ) + d2IidV2;
    end
      
    % find the max of second derivative which is normally between float
    % potential and plasma potential
    maxId = find( (d2IdV2(round(N/2):end)-d2IidV2(round(N/2):end)) == max(d2IdV2(round(N/2):end)-d2IidV2(round(N/2):end)),1) + round(N/2) - 1;
    
    % finds the domain for the EEDF by looking for the zeros of d2IdV2
    %   adjacent to the maximum   
    domain = [ find( d2IdV2(1:maxId) <= 0, 1, 'last' ) find( d2IdV2(maxId:end) < 0, 1 )+maxId-1 ];
    
    % If less than 2 zeros are found for the domain some assumptions are made 
    if isempty(domain)
        domain = [1 N-1];
    elseif (length(domain) == 1) && (domain < maxId)
        domain(1) = domain(1) + 1;
        domain(2) = N;
    elseif (length(domain) == 1) && (domain > maxId)
        domain(2) = domain(1) - 1;
        domain(1) = 1;
    else
        domain(1) = domain(1) + 1;
        domain(2) = domain(2) - 1;    
    end
    Vpl = interp1(d2IdV2( domain(2)-1:domain(2)+1 ), V_interp( domain(2)-1:domain(2)+1 ), 0, 'pchip');
    domain(2) = find( V > Vpl,1)-1;
    
    % now for EEDF    
    d2IdV2_EEDF = flip(d2IdV2( domain(1):domain(2) )); % restricts and flips current's second derivative  
    V_EEDF = flip(Vpl - V_interp(domain(1):domain(2)));
    EEDF = ( 2 / (Area*e^2) ) .* sqrt( (2.*me.*V_EEDF)./ e ).*d2IdV2_EEDF; 
    
    % final calculations for plasma values
    Ie_sat = interp1(V_interp, I_smooth, Vpl, 'pchip'); % finds current at plasma potential
    Ne = 1e-2*trapz(V_EEDF,e*EEDF); % dE=edV
    Te = ( 2e-2/(3.*Ne) ) .* trapz(V_EEDF, e.*V_EEDF.*EEDF); % E=eV et dE=edV, divided by e to convert to eV  
end