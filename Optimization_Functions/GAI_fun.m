function [f,ceq] = GAI_fun(x,R,CIETCS1nm,cmf,Wavelength,CRI_goal,mode,minmax)
    SPD=R*x';

    GAI=get_GAI(SPD,cmf,CIETCS1nm,Wavelength);
    ceq=[];
    if strcmp(mode,'constraint')==1
        if minmax(2)==1
            f=-GAI+CRI_goal;
        else
            f=-1*(-GAI+CRI_goal);
        end
    end
    if strcmp(mode,'maximize')==1
        if minmax(1)==1
            f=-GAI;
        else
            f=GAI;
        end
    end    
end