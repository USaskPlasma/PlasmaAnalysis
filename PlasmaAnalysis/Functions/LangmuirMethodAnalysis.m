function [Te, Vpl, Ie_sat, Ne, Te_err, Vpl_err, Ie_sat_err, Ne_err] = LangmuirMethodAnalysis(V,I,Ii,Vfloat)
    % Purpose: To calculator plasma potential and electron current
    %   saturation using extrapolation with user inputs
    %
    % Pre-Conditions:
    %   V: Voltage data
    %   I: Corresponding current data
    %   Ii: Provided ion current
    %   Vfloat: Floating potential for plotting purposes
    %
    % Return:
    %   Te: Electron Temperature
    %   Vpl: Plasma potential
    %   Ie_sat: Electron saturation current
    %   Ne: Electron density
    %   Te_err: Max absolute error in electron temperature
    %   Vpl_err: Max absolute error in plasma potential
    %   Ie_sat_err: Max absolute error in electron saturation current
    %   Ne_err: Max absolute error in electron density
    
    % global flags from VoltageInputs GUI
    global flagContinue e me Area Min_Vpe Max_Vpe Min_Ve Max_Ve UI_off
    flagContinue = 0;
    
    % Checks if ion current is provided for later use
    if ~isnan(Ii)
        I = I + Ii;
    end
    
    if ~UI_off
        % Cuts off part to the left of the float potential
        LeftIx = find( V > (Vfloat - 10),1 );
        V = V( LeftIx:end );
        I = I( LeftIx:end );
        
        % Creates new figure with Current/Voltage data
        figure()
        hold on
        plot(V,log(abs(I)),'k','linewidth',1.2)
        grid on
        grid minor
        axis tight
        title('Logarithm of Current vs. Bias Voltage to Determine Plasma Characteristics')
        xlabel('Bias Voltage, (V)')
        ylabel('Logarithm of Current, ln(I)')
        set(gcf, 'Position', get(gcf,'Position').*[1 0.8 0 0] + [0 0 700 525]);
        legend({'ln( I(V) )'},'Location','northwest')

        % These are needed later for when more plots are added
        xVal = xlim;
        yVal = ylim;
        
        % Gets GUI handles which will be used to aquire inputs
        VoltageIn = VoltageInputs;
        UserIn = guihandles( VoltageIn );

        try % Tries to prefill the GUI if the variables were defined in this function on an earlier call
            UserIn.Min_Ipe.String = num2str(Min_Vpe);
            UserIn.Max_Ipe.String = num2str(Max_Vpe);
            UserIn.Min_Ie.String  = num2str(Min_Ve);
            UserIn.Max_Ie.String  = num2str(Max_Ve);

            % Text for the legend which will be appended/concatinated to
            legendtxt = {'ln( I(V) )'};

            % More of a messy hack. I try to make linear extrapolating
            % functions to show where the Ipre_e_sat, and Ie_sat are
            try
                Vpe_Ids = find(V>=Min_Vpe & V<=Max_Vpe);
                Vpe = V(Vpe_Ids);
                Ipe = I(Vpe_Ids);
                Ppe = fit(Vpe,log(abs(Ipe)),'poly1');
                legendtxt = cat(1,legendtxt,{'Pre Electron Saturation'});
                plot([xVal(1) xVal(2)], [Ppe(xVal(1)) Ppe(xVal(2))])
            end        
            try
                Ve_Ids = find(V>=Min_Ve & V<=Max_Ve);
                Ve = V(Ve_Ids);
                Ie = I(Ve_Ids);
                Pe= fit(Ve,log(abs(Ie)),'poly1');
                legendtxt = cat(1,legendtxt,{'Electron Current Saturation'});
                plot([xVal(1) xVal(2)], [Pe(xVal(1)) Pe(xVal(2))])
            end

            % Reset y-axis which may have changed and update legend
            ylim([yVal(1) yVal(2)])
            legend(legendtxt,'Location','northwest')
        end

        while ~flagContinue
            % Continue and Update buttons have uiresume on callback
            uiwait(VoltageIn)

            % Aquires data from fields
            Min_Vpe = str2double(UserIn.Min_Ipe.String);
            Max_Vpe = str2double(UserIn.Max_Ipe.String);
            Min_Ve = str2double(UserIn.Min_Ie.String);
            Max_Ve = str2double(UserIn.Max_Ie.String);

            % Text for the legend which will be appended/concatinated to
            legendtxt = {'ln( I(V) )'};

            % Bit of a hack: the Voltage/Current data is replotted every loop
            hold off
            plot(V,log(abs(I)),'k','linewidth',1.2)
            hold on
            grid on
            grid minor
            axis tight
            title('Logarithm of Current vs. Bias Voltage to Determine Plasma Characteristics')
            xlabel('Bias Voltage, (V)')
            ylabel('Logarithm of Current, ln(I)')
            xlim([xVal(1) xVal(2)]);
            
            % More of a messy hack. I try to make linear extrapolating
            % functions to show where the Ipre_e_sat, and Ie_sat are
            try
                Vpe_Ids = find(V>=Min_Vpe & V<=Max_Vpe);
                Vpe = V(Vpe_Ids);
                Ipe = I(Vpe_Ids);
                Ppe = fit(Vpe,log(abs(Ipe)),'poly1');
                legendtxt = cat(1,legendtxt,{'Pre Electron Saturation'});
                plot([xVal(1) xVal(2)], [Ppe(xVal(1)) Ppe(xVal(2))])
            end        
            try
                Ve_Ids = find(V>=Min_Ve & V<=Max_Ve);
                Ve = V(Ve_Ids);
                Ie = I(Ve_Ids);
                Pe= fit(Ve,log(abs(Ie)),'poly1');
                legendtxt = cat(1,legendtxt,{'Electron Current Saturation'});
                plot([xVal(1) xVal(2)], [Pe(xVal(1)) Pe(xVal(2))])
            end

            % Reset y-axis which may have changed and update legend
            ylim([yVal(1) yVal(2)])
            legend(legendtxt,'Location','northwest')

        end    
        close, closereq % close plot and GUI
    
    else
        Vpe_Ids = find(V>=Min_Vpe & V<=Max_Vpe);
        Vpe = V(Vpe_Ids);
        Ipe = I(Vpe_Ids);
        Ppe = fit(Vpe,log(abs(Ipe)),'poly1');
        
        Ve_Ids = find(V>=Min_Ve & V<=Max_Ve);
        Ve = V(Ve_Ids);
        Ie = I(Ve_Ids);
        Pe= fit(Ve,log(abs(Ie)),'poly1');
    end
    % Ion current needs to be subtracted off. Linear fits will be
    % re-calculated to take this into account
    
    Ne_Pre = ( 1 /(e*Area) )*sqrt(2*pi*me/(e))*1e-2;
    
    Te = 1/(Ppe.p1); % Electron Temp = 1/slope of the log of pre Ie_sat region
    Vpl = ( Pe.p2 - Ppe.p2 )/( Ppe.p1 - Pe.p1 ); % Intersection of Ie(V) and Ie_sat(V)
    Ie_sat = exp(Pe(Vpl)); % Ie_sat = Current at Vpl
    Ne = ( Ie_sat/sqrt(Te) )*Ne_Pre; % electron density in cm^{-3}
    
    % Numerical error analysis done in a seperate function
    [Te_err, Vpl_err, Ie_sat_err, Ne_err] = LangmuirMethodError(Vpe, Ipe, Ve, Ie, Ne_Pre, Te, Vpl, Ie_sat, Ne);

end