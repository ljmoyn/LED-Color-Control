function [c,ceq] = LUV_dE_fun(x,R,standard_x,standard_y,xcmf,ycmf,zcmf,ideal_data,Wavelength,dE_goal,mode,minmax)

testSPD=R*x';

[X,Y,Z,~,~,~]...
    =getXYZxyz(testSPD',xcmf,ycmf,zcmf,Wavelength);

[L,U,V,~,~]...
    =getLUV_uprime_vprime(X,Y,Z,standard_x,standard_y);

dE=getdE_LUV(ideal_data(1),L,ideal_data(2),U,ideal_data(3),V);
if strcmp(mode,'constraint')==1
    if minmax(2)==1
        c=-1*(dE-dE_goal);
    else
        c=dE-dE_goal;
    end
else
    if minmax(1)==1
        c=-1*dE;
    else
        c=dE;
    end
end
ceq=[];
%order matters sum(handles.ycmf*R.*x)!=sum(x.*handles.ycmf*R)
%     k=683;
%     stepsize=Wave(2)-Wave(1);
%     if  ratio(2)<=(6/29)^3
%          f=sqrt((ideal_data(1)-(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*x)).^2 ...
%        +(ideal_data(2)-13*(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*x)*(4*sum(xcmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_u)).^2 ...
%        +(ideal_data(3)-13*(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*x)*(9*sum(ycmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_v)).^2);
%     else
%        f=sqrt((ideal_data(1)-(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16)).^2 ...
%        +(ideal_data(2)-13*(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16)*(4*sum(xcmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_u)).^2 ...
%        +(ideal_data(3)-13*(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16)*(9*sum(ycmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_v)).^2);
%     end    
% end
