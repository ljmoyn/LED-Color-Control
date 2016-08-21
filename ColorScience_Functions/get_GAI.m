function [GAI] = get_GAI(SPD,cmf,CIETCS1nm,Wavelength)
    %calculate normalization constant k for perfect diffuse reflector of source
    ktest = 100./sum(cmf(:,2).*SPD*(Wavelength(2)-Wavelength(1)));
    XYZtest_samples= zeros(3,15); 
    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            XYZtest_samples(j,i-1) = ktest.*sum(CIETCS1nm(:,i).*cmf(:,j).*SPD*(Wavelength(2)-Wavelength(1)));
        end
    end 
    
    Utest_samples=4*XYZtest_samples(1,:)./(XYZtest_samples(1,:)+15*XYZtest_samples(2,:)+3*XYZtest_samples(3,:));
    Vtest_samples=9*XYZtest_samples(2,:)./(XYZtest_samples(1,:)+15*XYZtest_samples(2,:)+3*XYZtest_samples(3,:));     
    
    Utest_samples=[Utest_samples(1:8),Utest_samples(1)];
    Vtest_samples=[Vtest_samples(1:8),Vtest_samples(1)];
    GAI=polyarea(Utest_samples,Vtest_samples);
    % Normalize gamut area to equal energy source 
    GAI=GAI/0.00728468*100;
    