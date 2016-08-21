function [c,ceq] = CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,CQS_goal,mode,minmax)
    testSPD=R*x';
    
    [~,~,~,xluv,yluv,~]...
        =getXYZxyz(testSPD,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength);

    CCT=getCCT(xluv,yluv);
    nrefspd = get_nrefspd(CCT,DSPD,Wavelength,560);
    
    CQS = get_CQS(testSPD,nrefspd(:,2),cmf,CIETCS1nm,Wavelength,CCT);
    ceq=[];
    if strcmp(mode,'constraint')==1
        if minmax(2)==1
            c=-CQS+CQS_goal;
        else
            c=-1*(CQS+CQS_goal);
        end
    end
    if strcmp(mode,'maximize')==1
        if minmax(1)==1
            c=-CQS;
        else
            c=CQS;
        end
    end        