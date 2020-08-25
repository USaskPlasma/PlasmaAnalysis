function [IV_Avg_Data] = getAvgData(V, V_err, I, I_err, d2IdV2, d2IdV2_err)
    % Purpose: get average data and errors for V, I, and d2IdV2 if user
    %   wants these outputs
    %
    % Pre-Conditions:
    %   V: all voltage data
    %   V_err: all voltage experimental error data
    %   I: all current data
    %   I_err: all current experimental error data
    %   d2IdV2: all analog second derivative data
    %   d2IdV2_err: all analog second derivative experimental error data
    
    N = length(V);
    % get bounds and step for voltage 
    Vb_s = NaN(N,3); % Voltage vbounds and step
    for Vb_ix = 1 : N
        Vb_s(Vb_ix, 1) = min( V{Vb_ix} ); % Voltage minimums
        Vb_s(Vb_ix, 2) = max( V{Vb_ix} ); % Voltage maximums
        Vb_s(Vb_ix, 3) = (Vb_s(Vb_ix, 2) - Vb_s(Vb_ix, 1))/length( V{Vb_ix} );
    end
    MinV = max( Vb_s(:,1) ); MaxV = min( Vb_s(:,2) ); Step = mean(Vb_s(:,3));
    
    V_Avg = (MinV : Step : MaxV)';
    L = length(V_Avg); % to be used to determine number of points needed
    
    % handle voltage error
    % if no experimental error given than all set to NaN
    if ~iscell(V_err)
        V_err_Avg = NaN(L,1);
    else
        V_err_Avg = zeros(L,1);
        for V_err_ix = 1 : N
            V_err_Avg = V_err_Avg + interp1( V{V_err_ix}, V_err{V_err_ix}(:,1) - V{V_err_ix}, V_Avg, 'pchip');
        end
        V_err_Avg = V_err_Avg./N;
    end
    
    % handle average current and error
    I_Set = zeros(N,L);
    I_err_Set = NaN(N,L);
    for I_ix = 1 : N
        I_Set(I_ix,:) = interp1( V{I_ix}, I{I_ix}, V_Avg, 'pchip');
        if iscell(I_err)
            I_err_Set(I_ix,:) = interp1( V{I_ix}, I_err{I_ix}(:,1) - I{I_ix}, V_Avg, 'pchip');
        end
    end
    
    I_Avg_Data = NaN(2*L,1); % A conglomeration of I_Avg and I_err_Avg
    for I_pt_ix = 1 : L
        I_Avg_Data( 2*I_pt_ix - 1 : 2*I_pt_ix ) = ErrorCrunch([ I_Set(:,I_pt_ix) I_err_Set(:,I_pt_ix) ]);
    end
    I_Avg = I_Avg_Data(1:2:end);
    I_err_Avg = I_Avg_Data(2:2:end);
    
    % handle average current second derivative and error
    if iscell(d2IdV2)
        d2I_Set = zeros(N,L);
        d2I_err_Set = NaN(N,L);
        for d2I_ix = 1 : N
            d2I_Set(d2I_ix,:) = interp1( V{d2I_ix}, d2IdV2{d2I_ix}, V_Avg, 'pchip');
            if iscell(d2IdV2_err)
                d2I_err_Set(d2I_ix,:) = interp1( V{d2I_ix}, d2IdV2_err{d2I_ix}(:,1) - d2IdV2{d2I_ix}, V_Avg, 'pchip');
            end
        end

        d2I_Avg_Data = NaN(2*L,1); % A conglomeration of d2IdV2_Avg and d2IdV2_err_Avg
        for d2I_pt_ix = 1 : L
            d2I_Avg_Data( 2*d2I_pt_ix - 1 : 2*d2I_pt_ix ) = ErrorCrunch([ d2I_Set(:,d2I_pt_ix) d2I_err_Set(:,d2I_pt_ix) ]);
        end
        d2IdV2_Avg = d2I_Avg_Data(1:2:end);
        d2IdV2_err_Avg = d2I_Avg_Data(2:2:end);
        
        IV_Avg_Data = [V_Avg V_err_Avg I_Avg I_err_Avg d2IdV2_Avg d2IdV2_err_Avg];
    else
        IV_Avg_Data = [V_Avg V_err_Avg I_Avg I_err_Avg NaN(L,1)];
    end 
    
    
end