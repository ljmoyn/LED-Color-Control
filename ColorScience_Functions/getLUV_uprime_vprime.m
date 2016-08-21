function [L,U,V,uprime,vprime]=getLUV_uprime_vprime(X,Y,Z,standard_x,standard_y)
    uprime=4*X/(X+15*Y+3*Z);
    vprime=9*Y/(X+15*Y+3*Z);
    
    standard_u=4*standard_x/(-2*standard_x+12*standard_y+3);
    standard_v=9*standard_y/(-2*standard_x+12*standard_y+3);  
    
    ref_Y=100;
    ref_X=standard_x*ref_Y/standard_y;
    
    if X/ref_X <= .008856
        L=(29/3)^3*(Y/ref_Y);
    else
        L=116*(Y/ref_Y)^(1/3)-16;
    end
    U=13*L*(uprime-standard_u);
    V=13*L*(vprime-standard_v);   