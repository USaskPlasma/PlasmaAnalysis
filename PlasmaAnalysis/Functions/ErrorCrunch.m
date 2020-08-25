function [ X ] = ErrorCrunch( x )
    % Purpose: Computes the mean and the error associated with the
    %   confidence interval
    %
    % Pre-Conditions:
    %   x: Array of values and their experimental error to compute the mean 
    %       and error of. First column is of values from analysis and the
    %       second is of the corresponding values experimental error
    %
    % Return:
    %   X(1): Mean values
    %   X(2): Error associated with confidence interval
    global Confidence
    X = NaN(1,2);

    X(1) = mean(x(:,1));
    
    N = length(x(:,1));
    SEM = std(x(:,1))./sqrt(N); % Standard error
    ts = tinv(Confidence,N-1); % T-Score
    X(2) = SEM.*ts;
    
    if (length(x(1,:)) == 2) && ~isnan(x(1,2))
        X(2) = X(2) + mean(x(:,2));
    end

end

