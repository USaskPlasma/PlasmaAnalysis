function [y] = CentralDifferenceDerivative(x, Y)
    % Purpose: Takes the numerical derivative of Y(x) using the central
    %   difference method (end points are calculated using forward and
    %   backwards difference method)
    %
    % Pre-Conditions:
    %   x: The indepedant variable spaced linearly
    %   Y: The function of x which is being differentiated
    %
    % Return:
    %   y: The numerical derivative dY(x)/dx
    
    N = length(Y);
    
    if length(x) ~= N
        error('Y(x) and x have a different number of points. Check inputs.')
    end
    
    % Preallocates with NaNs to distinguish errors that would just show as
    %   0
    y = NaN(1,N);
    
    y(1) = (Y(2) - Y(1)  )/( x(2) - x(1)  );
    y(N) = (Y(N) - Y(N-1))/( x(N) - x(N-1));
    
    for id = 2 : N-1 
        y(id) = (1/2) * ( (Y(id+1) - Y(id) )/( x(id+1) - x(id) ) + ( Y(id) - Y(id-1) )/( x(id) - x(id-1) )  );
    end
end