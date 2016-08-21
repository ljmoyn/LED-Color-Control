function [f,ceq] = LER_fun(x,R,vl1924e1nm,Wavelength,power_goal,mode,minmax)
    SPD=R*x';
    
    %TODO
    %1. Write get_LET
    %2. Calculate LER in Refresh
    %3. Display LER on analysis
    %4. write LER_fun
    %5. add LER_fun to combined_cost and combined_constraint
    LER=get_LER(SPD,vl1924e1nm,Wavelength);
    
    if strcmp(mode,'minimize')==1
        if minmax(1)==1
            f=-LER;
            ceq=[];            
        else
            f=LER;
            ceq=[];
        end
    else
        if minmax(2) ==1
            f=-LER+power_goal;
            ceq=[];
        else
            f=-1*(-LER+power_goal);
            ceq=[];
        end
    end

end