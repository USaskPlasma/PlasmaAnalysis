function [X] = DataSorter(x, ScanNum)
    % Purpose: Serperate individual scans into cells for individual
    %   analysis. Also chops off first and last Data points
    %
    % Pre-Conditions:
    %   x: Data column to manipulate
    %   ScanNum: column corresponding to x which numbers the data set
    %
    % Return:
    %   X: The input data sorted into columns and put in cells 
    %       corresponding to the scan number
    
    if isnan(ScanNum)
        X = {x(2:end-1,:)};
    else
        ScanId = 1;
        ScanIx1 = 1;
        X = {}; % This isn't preallocated but this should be too intensive
        
        MoreScans = true;        
        while MoreScans            
            ScanIx2 = find(ScanNum>ScanId,1)-1;
            
            if isempty(ScanIx2)
                X{ScanId} = x(ScanIx1+1:end-1,:);
                MoreScans = false;
            else
                X{ScanId} = x(ScanIx1+1:ScanIx2-1,:);
                ScanId = ScanId+1;
                ScanIx1 = ScanIx2+1;
            end            
        end       
    end
end