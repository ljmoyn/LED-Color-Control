%this function based on the procedure outlined by Wendy Davis and Yoshi Ohno
%http://opticalengineering.spiedigitallibrary.org/article.aspx?articleid=1096282
function [CQS] = get_CQS(testsourcespd,referencesourcespd,cmf,CIETCS1nm,Wavelength,testCCT)
    %calculate normalization constant k for perfect diffuse reflector of source
    ktest = 100./sum(cmf(:,2).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    kref = 100./sum(cmf(:,2).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    
    %tristimulus values of the 15 samples when they are illuminated by the
    %test source
    XYZtest_samples= zeros(3,15);
    %tristimulus values of the 15 samples when they are illuminated by the
    %reference source    
    XYZreference_samples = zeros(3,15);    
    
    %XYZ, u', and v' coordinates of the test source itself
    
    Xtest_source=ktest*sum(cmf(:,1).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Ytest_source=ktest*sum(cmf(:,2).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Ztest_source=ktest*sum(cmf(:,3).*testsourcespd*(Wavelength(2)-Wavelength(1)));

    %XYZ, u', and v' coordinates of the reference source itself    
    Xreference_source=kref*sum(cmf(:,1).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Yreference_source=kref*sum(cmf(:,2).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Zreference_source=kref*sum(cmf(:,3).*referencesourcespd*(Wavelength(2)-Wavelength(1)));

    %calculate the tristimulus values for each of the 15 color samples
    %illuminated by the test source
    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            XYZtest_samples(j,i-1) = ktest.*sum(CIETCS1nm(:,i).*cmf(:,j).*testsourcespd*(Wavelength(2)-Wavelength(1)));
        end
    end
    
    %calculate the tristimulus values for each of the 15 color samples
    %illuminated by the reference source
    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            XYZreference_samples(j,i-1) = kref.*sum(CIETCS1nm(:,i).*cmf(:,j).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
        end
    end
    
    %transform matrix for XYZ ---> RGB
    M=[.7982 .3389 -.1371;
       -.5918 1.5512 .0406; 
       .0008 .0239 .9753];
    
    %The chromatic adaptation transform involves changing from XYZ to RGB,
    %modifying the values, and changing back to XYZ
   
    %calculate the RGB values of the 15 color samples illuminated by the
    %test source
    RGBtest_samples=zeros(3,15);
    for i=1:15
        RGBtest_samples(:,i)=M*XYZtest_samples(:,i);
    end
    
    XYZtest_source=[Xtest_source;Ytest_source;Ztest_source];
    XYZreference_source=[Xreference_source;Yreference_source;Zreference_source];
    
    %RGB values of the test and reference sources
    RGBtest_source=M*XYZtest_source;
    RGBreference_source=M*XYZreference_source;
    
    %calculate the corresponding RGB values for the 15 color samples
    %illuminated by the test source
    alpha=Ytest_source/Yreference_source;
    RGBtest_corresponding=zeros(3,15);
    for i=1:15
        for j=1:3
            RGBtest_corresponding(j,i)=RGBtest_samples(j,i)*alpha*RGBreference_source(j)./RGBtest_source(j);
        end
    end    
    %disp(RGBtest_samples')
    %disp([RGBreference_source RGBtest_source RGBreference_source./RGBtest_source])
    
    %RGB ---> XYZ transform matrix
    M_inverse=[1.076450 -.237662 .161212;
               .410964 .554342 .034694;
               -.010954 -.013389 1.024343];
    
    %transform RGB values of 15 test samples illuminated by test source to
    %XYZ
    
    %problem introduced here. Rarely get negative XYZ values, which eventually lead to complex
    %solutions
    for i=1:15
        XYZtest_samples(:,i)=M_inverse*RGBtest_corresponding(:,i);
    end       
    
    %
    XYZtest_samples(XYZtest_samples < 0)=0;
    
    %Calculate coordinates in L*a*b* color space for the 15 color samples 
    %illuminated by the test source  
    Ltest=116*(XYZtest_samples(2,:)/XYZtest_source(2)).^(1/3)-16;
    atest=500*((XYZtest_samples(1,:)/XYZtest_source(1)).^(1/3)-(XYZtest_samples(2,:)/XYZtest_source(2)).^(1/3));
    btest=200*((XYZtest_samples(2,:)/XYZtest_source(2)).^(1/3)-(XYZtest_samples(3,:)/XYZtest_source(3)).^(1/3));
    
    %Calculate coordinates in L*a*b* color space for the 15 color samples 
    %illuminated by the test source  
    Lreference=116*(XYZreference_samples(2,:)/XYZreference_source(2)).^(1/3)-16;
    areference=500*((XYZreference_samples(1,:)/XYZreference_source(1)).^(1/3)-(XYZreference_samples(2,:)/XYZreference_source(2)).^(1/3));
    breference=200*((XYZreference_samples(2,:)/XYZreference_source(2)).^(1/3)-(XYZreference_samples(3,:)/XYZreference_source(3)).^(1/3));    

    %calculate chroma
    Ctest=(atest.^2+btest.^2).^(1/2);
    Creference=(areference.^2+breference.^2).^(1/2);
    
    %calculate differences between test source and reference source
    dL=Ltest-Lreference;
    da=atest-areference;
    db=btest-breference;
    dC=Ctest-Creference;
    
    %basic color difference
    dE=(dL.^2+da.^2+db.^2).^(1/2);
    
    %saturation factor such that an increase in object chroma is not penalized.
    if dC <=0
        dE_sat=dE;
    else
        dE_sat=(dE.^2-dC.^2).^(1/2);
    end
    
    %rms rather than simple averaging of the color differences for each
    %sample
    dE_rms=sqrt(sum(dE_sat.^2)/15);
    CQS_rms=100-3.1*dE_rms;
    
    %scale the CQS so it always between 0 and 100
    CQS_scaled=10*log(exp(CQS_rms/10)+1);
    
    %CCT factor, penalizes lamps with very low CCTs
    if testCCT < 3500
        Mcct=testCCT^3*(9.2672*10^-11)-testCCT^2*(8.3959*10^-7)+testCCT*.00255-1.612;
    else
        Mcct=1;
    end
    
    %final CQS
    CQS=Mcct*CQS_scaled;
end