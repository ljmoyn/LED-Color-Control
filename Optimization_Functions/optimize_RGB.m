function x=optimize_RGB(R,Aeq,beq,lb,ub,cmf,Wavelength,ideal_RGB,RGB_mat)
    options_lsqlin = optimoptions('lsqlin','Display','off','Algorithm','active-set');

    %if n LEDs have been imported, this is a 3xn matrix to hold the XYZ
    %values of the individual LEDs
    XYZ_LEDs=zeros(3,size(R,2));

    for n=1:size(R,2)
        [XYZ_LEDs(1,n),XYZ_LEDs(2,n),XYZ_LEDs(3,n),~,~,~]=getXYZxyz(R(:,n),cmf(:,1),cmf(:,2),cmf(:,3),Wavelength);
        RGB_LEDs(:,n)=RGB_mat*XYZ_LEDs(:,n);
    end
    x=lsqlin(RGB_LEDs,ideal_RGB,[],[],Aeq,beq,lb,ub,[],options_lsqlin);


end