function f=uvChroma_fun(x,R,xcmf,ycmf,zcmf,ideal_u,ideal_v,standard_x,standard_y,Wavelength,minmax)
    testSPD=R*x';

    [X,Y,Z,~,~,~]...
        =getXYZxyz(testSPD',xcmf,ycmf,zcmf,Wavelength);

    [~,~,~,uprime,vprime]...
        =getLUV_uprime_vprime(X,Y,Z,standard_x,standard_y);

    f=sqrt((ideal_u-uprime).^2+(ideal_v-vprime).^2);
%     dE=sqrt((ideal_u-(4*sum(xcmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x)))).^2....
%            +(ideal_v-(9*sum(ycmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x)))).^2);