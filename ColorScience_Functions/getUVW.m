function [U,V,W]=getUVW(X,Y,Z,standard_x,standard_y)

    uprime=4*X/(X+15*Y+3*Z);
    vprime=9*Y/(X+15*Y+3*Z);
    
    standard_u=4*standard_x/(-2*standard_x+12*standard_y+3);
    standard_v=9*standard_y/(-2*standard_x+12*standard_y+3);  
    
    W=25*Y^(1/3)-17;
    U=13*W.*(uprime-standard_u);
    V=13*W.*(vprime-standard_v);