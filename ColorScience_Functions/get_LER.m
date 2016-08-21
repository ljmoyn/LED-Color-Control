function LER=get_LER(SPD,vl1924e1nm,Wavelength)

    LER=683*sum(vl1924e1nm*SPD.*(Wavelength(2)-Wavelength(1)))/ ...
        sum(SPD.*(Wavelength(2)-Wavelength(1)));
