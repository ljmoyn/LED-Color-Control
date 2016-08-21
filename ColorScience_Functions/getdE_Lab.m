function [dE76,dE94,dE00]=getdE_Lab(L1,L2,a1,a2,b1,b2)
        dE76=sqrt((L1-L2)^2+(a1-a2)^2+(b1-b2)^2);
        
        kL=1;
        k1=.045;
        k2=.015;
        dL=L1-L2;
        C1=sqrt(a1^2+b1^2);
        C2=sqrt(a2^2+b2^2);
        dC=C1-C2;
        da=a1-a2;
        db=b1-b2;
        dH=sqrt(da^2+db^2-dC^2); 
        SC=1+k1*C1;
        SH=1+k2*C1;
        SL=1; kC=1; kH=1;
        
        dE94=sqrt((dL/(kL*SL))^2+(dC/(kC*SC))^2+(dH/(kH*SH))^2);
        
        dL=L2-L1;
        Lbar=mean([L1 L2]); Cbar=mean([C1 C2]);
        
        a1=a1+.5*a1*(1-sqrt(Cbar^7/(Cbar^7+25^7)));
        a2=a2+.5*a2*(1-sqrt(Cbar^7/(Cbar^7+25^7)));
        
        C1_prime=sqrt(a1^2+b1^2);
        C2_prime=sqrt(a2^2+b2^2);
        dC_prime=C2_prime-C1_prime;
        Cbar_prime=mean([C1_prime C2_prime]);
        
        h1=mod((180/pi)*atan2(b1,a1),360);
        h2=mod((180/pi)*atan2(b2,a2),360);
        
        if abs(h1-h2)<=180
            dh=h2-h1; 
        end
        if abs(h1-h2) > 180 && h2 <= h1
            dh=h2-h1+360; 
        end
        if abs(h1-h2) > 180 && h2 > h1
            dh=h2-h1-360;
        end
        
        dH=2*sqrt(C1_prime*C2_prime)*sind(dh/2);
        if abs(h1-h2) > 180
            Hbar=(h1+h2+360)/2;
        end
        if abs(h1-h2) <= 180
            Hbar=(h1+h2)/2;
        end
        if C1_prime==0 || C2_prime==0
            Hbar=h1+h2; 
        end
        
        T=1-.17*cosd(Hbar-30)+.24*cosd(2*Hbar)+.32*cosd(3*Hbar+6)-.2*cosd(4*Hbar-63);
        SL=1+.015*(Lbar-50)^2/sqrt(20+(Lbar-50)^2);
        SC=1+.045*Cbar_prime;
        SH=1+.015*Cbar_prime*T;
        RT=-2*sqrt(Cbar_prime^7/(Cbar_prime^7+25^7))*sind(60*exp(-1*((Hbar-275)/25)^2));
        
        dE00=sqrt((dL/(kL*SL))^2+(dC_prime/(kC*SC))^2+(dH/(kH*SH))^2+RT*dC_prime*dH/(kC*SC*kH*SH));
