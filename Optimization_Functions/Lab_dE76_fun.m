function [c,ceq] = Lab_dE76_fun(x,R,standard_x,standard_y,xcmf,ycmf,zcmf,ideal_data,Wavelength,dE_goal,mode,minmax)

    testSPD=R*x';
    
    [X,Y,Z,~,~,~]...
        =getXYZxyz(testSPD',xcmf,ycmf,zcmf,Wavelength);     

    [L,a,b]...
        =getLab(X,Y,Z,standard_x,standard_y);

    [dE76,dE94,dE00]...
        =getdE_Lab(L,ideal_data(1),a,ideal_data(2),b,ideal_data(3));
    if strcmp(mode,'constraint')==1
        if minmax(2) == 1
            c=-1*(dE76-dE_goal);
        else
            c=dE76-dE_goal;
        end
    else
        if minmax(1) == 1
            c=-1*dE76;
        else
            c=dE76;
        end
    end
    ceq=[];

end