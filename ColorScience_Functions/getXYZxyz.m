function [X,Y,Z,x,y,z]=getXYZxyz(SPD,xcmf,ycmf,zcmf,Wavelength)
    k=683;
    %k = 100./sum(handles.ycmf.*s*(handles.Wavelength(2)-handles.Wavelength(1)));
    %handles.X(1)=sum(handles.xcmf.*s)/size(s,2);
    %handles.Y(1)=sum(handles.ycmf.*s)/size(s,2);
    %handles.Z(1)=sum(handles.zcmf.*s)/size(s,2);

    X=k*sum(xcmf.*SPD.*(Wavelength(2)-Wavelength(1)));
    Y=k*sum(ycmf.*SPD.*(Wavelength(2)-Wavelength(1)));
    Z=k*sum(zcmf.*SPD.*(Wavelength(2)-Wavelength(1)));

    x=X/(X+Y+Z);
    y=Y/(X+Y+Z);
    z=Z/(X+Y+Z);