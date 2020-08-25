function [Vfloat] = VfloatFinder(V,I)
%     Purpose: Finds the floating potential (first root) of the voltage/
%       current data by finding the point where I>0 and then interpolating
%       linearly to find root.
%     
%     Pre-Conditions:
%       V: Voltage
%       I: Current
%     
%     Return:
%       Vfloat: The floating potential of the plasma
    
    fp_id = find(I>=0,1);
    Vfp=V(fp_id-1:fp_id+1);
    Ifp=I(fp_id-1:fp_id+1);
    Pf= polyfit(Vfp,Ifp,1); % fit the current around floating potential with a line
    Vfloat=roots(Pf);
end