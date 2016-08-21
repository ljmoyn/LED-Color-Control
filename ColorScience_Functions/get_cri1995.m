function [CRI,R] = get_cri1995(testsourcespd,referencesourcespd,cmf,CIETCS1nm,Wavelength)
    %calculate normalization constant k for perfect diffuse reflector of source
    ktest = 100./sum(cmf(:,2).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    kref = 100./sum(cmf(:,2).*referencesourcespd*(Wavelength(2)-Wavelength(1)));

    %Need have to apply von Kries chromatic adaptation 
    %first calculate c and d for both sources
    %this requires calculating the chromaticity in uv for the test source and
    %reference source
    
    %tristimulus values of the 15 samples when they are illuminated by the
    %test source
    XYZtest_samples= zeros(3,15);
    %tristimulus values of the 15 samples when they are illuminated by the
    %reference source            
    XYZreference_samples = zeros(3,15);    
    
    %XYZ, u, and v coordinates of the test source itself.
    %note: uv coordinates are for the 1960 UCS color space
    %http://en.wikipedia.org/wiki/CIE_1960_color_space
    %similar equations to u' and v' in CIE LUV space, but not to be
    %confused
    Xtest_source=ktest*sum(cmf(:,1).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Ytest_source=ktest*sum(cmf(:,2).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Ztest_source=ktest*sum(cmf(:,3).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Utest_source=4*Xtest_source./(Xtest_source+15*Ytest_source+3*Ztest_source);
    Vtest_source=6*Ytest_source./(Xtest_source+15*Ytest_source+3*Ztest_source);
    
    %XYZ, u, and v coordinates of the reference source itself    
    Xreference_source=kref*sum(cmf(:,1).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Yreference_source=kref*sum(cmf(:,2).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Zreference_source=kref*sum(cmf(:,3).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Ureference_source=4*Xreference_source./(Xreference_source+15*Yreference_source+3*Zreference_source);
    Vreference_source=6*Yreference_source./(Xreference_source+15*Yreference_source+3*Zreference_source);    
    
    
    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            XYZtest_samples(j,i-1) = ktest.*sum(CIETCS1nm(:,i).*cmf(:,j).*testsourcespd*(Wavelength(2)-Wavelength(1)));
        end
    end    
    
%     Xtest=ktest.*sum(CIETCS1nm(:,2:16).*repmat(cmf(:,1),1,15).*repmat(testsourcespd,1,15)*(Wavelength(2)-Wavelength(1)));
%     Ytest=ktest.*sum(CIETCS1nm(:,2:16).*repmat(cmf(:,2),1,15).*repmat(testsourcespd,1,15)*(Wavelength(2)-Wavelength(1)));
%     Ztest=ktest.*sum(CIETCS1nm(:,2:16).*repmat(cmf(:,3),1,15).*repmat(testsourcespd,1,15)*(Wavelength(2)-Wavelength(1))); 

    %disp([Xtest' XYZtest_samples(1,:)' Ytest' XYZtest_samples(2,:)' Ztest' XYZtest_samples(3,:)'])

    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            XYZreference_samples(j,i-1) = kref.*sum(CIETCS1nm(:,i).*cmf(:,j).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
        end
    end

    %UV coordinates of the 15 samples when they are illuminated by test and
    %reference sources respectively
    Ureference_samples=4*XYZreference_samples(1,:)./(XYZreference_samples(1,:)+15*XYZreference_samples(2,:)+3*XYZreference_samples(3,:));
    Vreference_samples=6*XYZreference_samples(2,:)./(XYZreference_samples(1,:)+15*XYZreference_samples(2,:)+3*XYZreference_samples(3,:));
    
    Utest_samples=4*XYZtest_samples(1,:)./(XYZtest_samples(1,:)+15*XYZtest_samples(2,:)+3*XYZtest_samples(3,:));
    Vtest_samples=6*XYZtest_samples(2,:)./(XYZtest_samples(1,:)+15*XYZtest_samples(2,:)+3*XYZtest_samples(3,:)); 
    
    %next we need to calculate c and d coefficients for both sources, as well
    %as for the samples illuminated by the test source
    Ctest_source=(4-Utest_source-10*Vtest_source)./Vtest_source;
    Dtest_source=(1.708*Vtest_source+.404-1.481*Utest_source)./Vtest_source;

    Creference_source=(4-Ureference_source-10*Vreference_source)/Vreference_source;
    Dreference_source=(1.708*Vreference_source+.404-1.481*Ureference_source)./Vreference_source;
    
    Ctest_samples=(4-Utest_samples-10*Vtest_samples)./Vtest_samples;
    Dtest_samples=(1.708*Vtest_samples+.404-1.481*Utest_samples)./Vtest_samples;
        
    %Recalculate the u and v coordinates of the samples illuminated by the
    %test source, applying von kries chromatic adaptation
    
    Utest_samples=(10.872+.404*Ctest_samples.*(Creference_source./Ctest_source)-4*Dtest_samples.*(Dreference_source./Dtest_source))./ ...
                  (16.518+1.481*Ctest_samples.*(Creference_source./Ctest_source)-Dtest_samples.*(Dreference_source./Dtest_source));
    
    Vtest_samples=5.520./(16.518+1.481*Ctest_samples.*(Creference_source./Ctest_source)-Dtest_samples.*(Dreference_source./Dtest_source));
    
    %calculate UVW for chromatically adapted object colors
    Wtest = 25.*(XYZtest_samples(2,:).^(1/3))-17;
    Utest = 13.*Wtest.*(Utest_samples-Ureference_source);
    Vtest = 13.*Wtest.*(Vtest_samples-Vreference_source);
    %UVWtest = horzcat(Utest',Vtest',Wtest');
    
    %calculate UVW for reference illumance object colors
    Wref = 25.*(XYZreference_samples(2,:).^(1/3))-17;
    Uref = 13.*Wref.*(Ureference_samples-Ureference_source);
    Vref = 13.*Wref.*(Vreference_samples-Vreference_source); 
    %UVWref = horzcat(Uref',Vref',Wref');

    deltaE = sqrt((Wtest-Wref).^2+(Utest-Uref).^2+(Vtest-Vref).^2);
    
    R = 100-(4.6.*deltaE);
    CRI = (sum(R(:,1:8))/8);
    %disp([CRIfun CRI f])
end    