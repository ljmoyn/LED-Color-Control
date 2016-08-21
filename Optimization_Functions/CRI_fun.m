function [f,ceq] = CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,CRI_goal,mode,minmax)
    testSPD=R*x';

    [~,~,~,xluv,yluv,~]...
        =getXYZxyz(testSPD,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength);

    CCT=getCCT(xluv,yluv);
    nrefspd = get_nrefspd(CCT,DSPD,Wavelength,560);

    [Ra,R] = get_cri1995(testSPD,nrefspd(:,2),cmf,CIETCS1nm,Wavelength); 
    ceq=[];
    if strcmp(mode,'constraint')==1
        if minmax(2)==1
            f=-Ra+CRI_goal;
        else
            f=-1*(-Ra+CRI_goal);
        end
    end
    if strcmp(mode,'maximize')==1
        if minmax(1)==1
            f=-Ra;
        else
            f=Ra;
        end
    end    
end