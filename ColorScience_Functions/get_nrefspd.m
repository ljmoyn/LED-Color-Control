%credit pspectro
function nrefspd = get_nrefspd(CCT,DSPD,Wavelength,normWavelength)
    %CCT=7000;
    %blackbody spd
    if CCT < 5000
        Wavelength_nm=Wavelength*10^-9;
        c1 = 1.19268*10^-16;%3.7418e-16;
        c2 = 1.438775225*10^-2;
        refspd = horzcat(Wavelength',c1./(Wavelength_nm.^5.*(exp(c2./(Wavelength_nm.*CCT))-1))');
    end
    %daylight spd    
    if CCT >= 5000
        %linearly interpolate DSPD
        %DSPD = horzcat(range',interp1(DSPD(:,1),DSPD(:,[2 3 4]),range,'linear'));

        %calculate x_d,y_d based on input color temperature
        if CCT <= 7000
            xd = .244063 + .09911*(1e3/CCT) + 2.9678*(1e6/(CCT^2)) - 4.6070*(1e9/(CCT^3));
        else 
            xd = .237040 + .24748*(1e3/CCT) + 1.9018*(1e6/CCT^2) - 2.0064*(1e9/CCT^3);
        end

        yd = -3.000*xd^2 + 2.870*xd - 0.275;

        %calculate relatative SPD
        M = 0.0241 + 0.2562*xd - 0.7341*yd;
        M1 = (-1.3515 - 1.7703*xd + 5.9114*yd)/M;
        M2 = (0.03000 - 31.4424*xd + 30.0717*yd)/M;

        refspd = horzcat(DSPD(:,1),DSPD(:,2) + M1.*DSPD(:,3) + M2.*DSPD(:,4));    
    end 
     
%     startval = find(refspd(:,1) == min(range));
%     endval = find(refspd(:,1) == max(range));

    %normalize spd around given wavelength
    nrefspd = horzcat(Wavelength',1.*(refspd(:,2)./refspd(refspd(:,1) == normWavelength,2)));
    %save('blackbody_7000.mat','nrefspd')

end
