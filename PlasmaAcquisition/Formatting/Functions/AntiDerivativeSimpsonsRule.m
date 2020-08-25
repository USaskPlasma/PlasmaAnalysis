function [Y] = AntiDerivativeSimpsonsRule(x,y)
%     Purpose: Take the numerical anitderivative of y (i.e. integral of y
%       from [x(1),x] using Simpson's Rule and quadratic interpolation
%     
%     Notice: this function won't check if your domain is linearly spaced!
%     
%     Pre-Conditions:
%       x: Independant linearly-spaced variable with an odd number of 
%           points (and >1 point)
%       y: Dependant variable with values corresponding to x
%     
%     Return:
%       Y: Anti-derivative computed at all points for x
    
    N = length(y);
    
    if ~mod(N,2)
        error('Even number of points entered. An odd number of data points are required.')        
    elseif N == 1
        error('You need more than one data point in order to integrate.')
    end
    
    Y = zeros(1,N);
    
    % Standard Simpsons Rule
    for id = 3 : 2 : N
        Y(id) = Y(id-2) + y(id-2) + 4*y(id-1) + y(id);
    end
    Y = Y.*( x(end)-x(1) )/(3*(N-1));
    
    % Fills in even points using quadratic interpolating polynomials
    for id = 2 : 2 : N
        Y(id) = Y(id-1) + y(id-1)*(x(id)-x(id-1)) + ...
                (y(id)-y(id-1))*(x(id)-x(id-1))/2 + ...
            ( ( (y(id+1)-y(id))/(x(id+1)-x(id)) - (y(id)-y(id-1))/(x(id)-x(id-1)) ) /( x(id+1)-x(id-1) ))*((x(id-1)-x(id))^3)/6;
    end
end