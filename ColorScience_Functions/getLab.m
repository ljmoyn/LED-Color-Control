function [L,a,b]=getLab(X,Y,Z,standard_x,standard_y)

        ref_Y=100;
        ref_X=standard_x*ref_Y/standard_y;
        ref_Z=standard_y*ref_Y/(1-standard_x-standard_y);
        
        if X/ref_X > .008856
            f1=(X/ref_X)^(1/3);
        else
            f1=7.787*(X/ref_X)+.13793;
        end
        
        if Y/ref_Y > .008856
            f2=(Y/ref_Y)^(1/3);
        else
            f2=7.787*(Y/ref_Y)+.13793;
        end
        
        if Z/ref_Z > .008856
            f3=(Z/ref_Z)^(1/3);
        else
            f3=7.787*(Z/ref_Z)+.13793;
        end

        L=116*f2-16;
        a=500*(f1-f2);
        b=200*(f2-f3);