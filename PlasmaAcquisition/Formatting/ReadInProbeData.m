clear
% Input Parameters
    minV_sweep = -50; % minimum voltage of sweep
    maxV_sweep = 35; % maximum voltage of sweep

    minV = -40; % minimum voltage to be used
    maxV = 30; % maximum voltage to be used

    freq_sweep = 10; % frequency of voltage sweeps

    sweepsPerSet = 3; % how many IV curves will be averaged for a data set
    maxSets = 3; % how many data sets will be made
    
    secondDerivative = true; % are analog second derivatives available?
%

% get files
d = uigetdir();
files = dir(fullfile(d, '*.lvm'));
filenum = length(files);

% load functions and some hardware data
conversion = load([pwd '\Hardware_Data\LangmuirProbeVoltageConversionCoefficients.mat']);
V_error = load([pwd '\Hardware_Data\VoltageError.mat']);
addpath([pwd '/Functions/'])

% voltage to interpolate data onto
V_space = linspace(minV,maxV,399);
V_space_error = interp1( V_error.amp_final, V_error.amp_final_error, V_space, 'pchip' );

fileix = 1;
while fileix ~= filenum+1
    flagContinue = true;
    clear I_int d2I_int I_acc d2I_acc
    
    % opening file for I-V data and copying all text
    fid_I = fopen([d '\' files(fileix).name], 'r');
    Ct_I                              = textscan(fid_I,'%s');
    fclose(fid_I);
    Ct_I = Ct_I{:};
    % finds the words 'Comment' and 'Channels' which are used to find the numerical data
    findingComment_I                  = strfind(Ct_I,'Comment');
    findingChannels_I                 = strfind(Ct_I,'Channels');
    
    % using Comment and Channels the indices of the data are found
    I_ids = [];
    for x = 1 : length(Ct_I)
       if findingComment_I{x} == 1
           I_ids(end+1) = x;
       end
       if findingChannels_I{x} == 1
           I_ids(end+1) = x;
       end
    end
    I_ids = [I_ids(2:end), length(Ct_I)+1];
    
    % preallocates cell array of interpolated current data
    sweepNum = length(I_ids)/2;
    I_int = cell( 1, sweepNum );
    
    for sweepIx = 1 : sweepNum
        % gets the number of data points to be read in
        I_num = floor(( I_ids(sweepIx*2) - I_ids(sweepIx*2-1)-1)/2);
        
        % preallocates some arrays
        V_I = zeros( I_num,1 );
        I = V_I;
        
        % This is where the data is actually read to the arrays
        for I_ix = 1 : I_num
            V_I(I_ix) = str2double( Ct_I{ I_ids(sweepIx*2-1) + 2*I_ix -1} );
            I(I_ix) = str2double( Ct_I{ I_ids(sweepIx*2-1) + 2*I_ix} );
        end
        
        % Voltage is converted based on Barrett Taylor's quintic polynomial
        %   fit for voltage amplification
        V_I   = conversion.coefficients_fifth(6) + V_I  .*( conversion.coefficients_fifth(5) + ...
                                                   V_I  .*( conversion.coefficients_fifth(4) + ...
                                                   V_I  .*( conversion.coefficients_fifth(3) + ...
                                                   V_I  .*( conversion.coefficients_fifth(2) + ...
                                                   V_I  .*  conversion.coefficients_fifth(1)))));
        
        % Find unique values
        [ V_I, unique_I ] = unique( V_I );
        I = I(unique_I)./1000; % Current data is divided by 1k as the data is actually voltage and a 1k ohm resistor is used to measure the voltage and V = IR
        
        % Interpolate data to fit on the same space
        I_int{sweepIx} = interp1(V_I,I,V_space,'pchip');
        
    end
    
    accepted_ISweeps = 0;
    maxAcceptedSweeps = sweepsPerSet*maxSets;
    
    figure()
    for sweepIx = 1 : sweepNum
        if accepted_ISweeps ~= maxAcceptedSweeps;
            % plot to see I-V curve
            plot( V_space, I_int{sweepIx} )
            grid on; grid minor
            xlabel('Voltage, V (Volts)')
            ylabel('Current, I (Amps)')
            title('Current vs Voltage Probe Curve')
            
            % get acceptance or rejection of curve from user input
            UserIn = '0';
            w = waitforbuttonpress;
            if w
                UserIn = get(gcf, 'CurrentCharacter');
            end
            
            while ~any(UserIn == ['y' 'n' 'r' 'b'])
                disp('Press y or n to accept or discard this I-V curve. Press r to redo this files data. Press b to redo previous file')
                w = waitforbuttonpress;
                if w
                    UserIn = get(gcf, 'CurrentCharacter');
                end
            end
            
            % continue based on user input
            if UserIn == 'y'
                accepted_ISweeps = accepted_ISweeps + 1;
                I_acc{accepted_ISweeps} = I_int{sweepIx};
            elseif UserIn == 'r'                
                flagContinue = false;
                break
            elseif UserIn == 'b'
                fileix = fileix - (1+secondDerivative);
                flagContinue = false;
                break
            end
        end
    end
    close
    
    if flagContinue
        fileix = fileix + 1;
        % now does the same for current second derivative if avaliable
        if secondDerivative
            % opening file for I-V data and copying all text
            fid_d2I = fopen([d '\' files(fileix).name], 'r');
            Ct_d2I                              = textscan(fid_d2I,'%s');
            fclose(fid_d2I);
            Ct_d2I = Ct_d2I{:};
            % finds the words 'Comment' and 'Channels' which are used to find the numerical data
            findingComment_d2I                  = strfind(Ct_d2I,'Comment');
            findingChannels_d2I                 = strfind(Ct_d2I,'Channels');

            % using Comment and Channels the indices of the data are found
            d2I_ids = [];
            for x = 1 : length(Ct_d2I)
               if findingComment_d2I{x} == 1
                   d2I_ids(end+1) = x;
               end
               if findingChannels_d2I{x} == 1
                   d2I_ids(end+1) = x;
               end
            end
            d2I_ids = [d2I_ids(2:end), length(Ct_d2I)+1];

            % preallocates cell array of interpolated current data
            sweepNum = length(d2I_ids)/2;
            d2I_int = cell( 1, sweepNum );

            for sweepIx = 1 : sweepNum
                % gets the number of data points to be read in
                d2I_num = floor(( d2I_ids(sweepIx*2) - d2I_ids(sweepIx*2-1)-1)/2);

                % preallocates some arrays
                V_d2I = zeros( d2I_num,1 );
                d2I = V_d2I;

                % This is where the data is actually read to the arrays
                for d2I_ix = 1 : d2I_num
                    V_d2I(d2I_ix) = str2double( Ct_d2I{ d2I_ids(sweepIx*2-1) + 2*d2I_ix -1} );
                    d2I(d2I_ix) = str2double( Ct_d2I{ d2I_ids(sweepIx*2-1) + 2*d2I_ix} );
                end

                % Voltage is converted based on Barrett Taylor's quintic polynomial
                %   fit for voltage amplification
                V_d2I   = conversion.coefficients_fifth(6) + V_d2I  .*( conversion.coefficients_fifth(5) + ...
                                                             V_d2I  .*( conversion.coefficients_fifth(4) + ...
                                                             V_d2I  .*( conversion.coefficients_fifth(3) + ...
                                                             V_d2I  .*( conversion.coefficients_fifth(2) + ...
                                                             V_d2I  .*  conversion.coefficients_fifth(1)))));

                % Find unique values
                [ V_d2I, unique_d2I ] = unique( V_d2I );
                d2I = (d2I(unique_d2I)./1000)*( 1 / (freq_sweep*(maxV_sweep-minV_sweep)))^2; % changes d2Idt2 to d2IdV2

                % Interpolate data to fit on the same space
                d2I_int{sweepIx} = interp1(V_d2I,d2I,V_space,'pchip');
                
                % corrects somewhat for phase shifting and the spike caused
                % by the cycling of the saw-tooth wave
                d2I_int{sweepIx}(1:100) = 0;
                % d2I_int{sweepIx} = FourierPhaseShift( d2I_int{sweepIx} );
                

            end

            accepted_d2ISweeps = 0;
            maxAcceptedSweeps = sweepsPerSet*maxSets;

            figure()
            for sweepIx = 1 : sweepNum
                if accepted_d2ISweeps ~= maxAcceptedSweeps;
                    % plot to see I-V curve
                    plot( V_space, d2I_int{sweepIx} )
                    grid on; grid minor
                    xlabel('Voltage, V (Volts)')
                    ylabel('Second Derivative of Current, d^{2}I/{dV^{2}} (Amps/Volts^{2})')
                    title('Second Derivative of Current vs Voltage Probe Curve')

                    % get acceptance or rejection of curve from user input
                    UserIn = '0';
                    w = waitforbuttonpress;
                    if w
                        UserIn = get(gcf, 'CurrentCharacter');
                    end

                    while ~any(UserIn == ['y' 'n' 'r' 'b'])
                        disp('Press y or n to accept or discard this I-V curve. Press r to redo this files data. Press b to redo previous file')
                        w = waitforbuttonpress;
                        if w
                            UserIn = get(gcf, 'CurrentCharacter');
                        end
                    end

                    % continue based on user input
                    if UserIn == 'y'
                        accepted_d2ISweeps = accepted_d2ISweeps + 1;
                        d2I_acc{accepted_d2ISweeps} = d2I_int{sweepIx};
                    elseif UserIn == 'r'
                        fileix = fileix - 1;
                        flagContinue = false;
                        break
                    elseif UserIn == 'b'
                        fileix = fileix - 3;
                        flagContinue = false;
                        break
                    end
                end
            end
            close            
        end
        
        % begins process of writing to file
        if flagContinue
            if secondDerivative
                fileix = fileix+1;
                % numbers of run averages to be made
                avgNum = floor(min([length(I_acc) length(d2I_acc)])/sweepsPerSet);
                
                % Format data
                avgRunIx = ones( avgNum*399,1);
                for avgIx = 1 : avgNum
                    avgRunIx( 399*avgIx+1:end ) = avgRunIx( 399*avgIx+1:end ) + 1;
                    I_acc{avgIx} = (I_acc{avgIx*3-2} + I_acc{avgIx*3-1} + I_acc{avgIx*3})./3;
                    d2I_acc{avgIx} = (d2I_acc{avgIx*3-2} + d2I_acc{avgIx*3-1} + d2I_acc{avgIx*3})./3;
                end

                % Correct d2I_acc by shifting and scaling to match I after
                % integrating twice
                I_avg = zeros(399,1);
                d2I_avg = zeros(399,1);
                for avg_ix = 1 : avgNum
                    I_avg = I_avg + I_acc{avg_ix}';
                    d2I_avg = d2I_avg + d2I_acc{avg_ix}';
                end
                I_avg = I_avg./avgNum;
                d2I_avg = d2I_avg./avgNum;
                I_anti = AntiDerivativeSimpsonsRule( V_space(201:end), AntiDerivativeSimpsonsRule( V_space(201:end), d2I_avg(201:end)))';

                options = optimoptions('lsqnonlin','StepTolerance',1e-13,'OptimalityTolerance',1e-13,'FunctionTolerance',1e-13,'Display','off');
                fun = @(c)( c(1).*I_anti(21+round(1e9*c(2)):end-20+round(1e9*c(2))) + c(3).*V_space(221:end-20)' + c(4) - I_avg(221:end-20));
                C = lsqnonlin(fun, [1 0 0 0], [0 -20*1e-9 -inf -inf], [inf 20*1e-9 inf inf], options);
                C(2) = round(C(2)*1e9);

                for avg_ix = 1 : avgNum
                    if C(2) > 0
                        d2I_acc{ avg_ix } = [ C(1).*d2I_acc{ avg_ix }(1+C(2):end) zeros(1,C(2))  ];
                    else
                        d2I_acc{ avg_ix } = [ zeros(1,-C(2)) C(1).*d2I_acc{ avg_ix }(1:end+C(2)) ]; 
                    end
                end

                I_acc = [I_acc{1:avgNum}]';
                d2I_acc = [d2I_acc{1:avgNum}]';

                csvwrite([pwd '\FormattedData\' files(fileix-1).name(1:end-6), '.csv'],[avgRunIx, repmat(V_space,1,avgNum)', I_acc, d2I_acc, repmat(V_space_error,1,avgNum)'])

            else
                % numbers of run averages to be made
                avgNum = floor(length(I_acc)/sweepsPerSet);
                
                % Format data
                avgRunIx = ones( avgNum*399,1);
                for avgIx = 1 : avgNum
                    avgRunIx( 399*avgIx+1:end ) = avgRunIx( 399*avgIx+1:end ) + 1;
                    I_acc{avgIx} = (I_acc{avgIx*3-2} + I_acc{avgIx*3-1} + I_acc{avgIx*3})./3;
                end

                % Correct d2I_acc by shifting and scaling to match I after
                % integrating twice
                I_avg = zeros(399,1);
                for avg_ix = 1 : avgNum
                    I_avg = I_avg + I_acc{avg_ix}';
                end
                I_avg = I_avg./avgNum;                               

                I_acc = [I_acc{1:avgNum}]';

                csvwrite([pwd '\FormattedData\' files(fileix-1).name(1:end-6), '.csv'],[avgRunIx, repmat(V_space,1,avgNum)', I_acc, repmat(V_space_error,1,avgNum)'])
            end
        end
    end    
    
end