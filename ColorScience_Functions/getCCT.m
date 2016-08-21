function [CCT]=getCCT(x,y)
    %x and y are NOT tristimulus values XY
    %n=(x-.3366)/(y-.1735);
    %CCT=-949.86315+6253.80338*exp(-n/.92159)+28.70599*exp(-n/.20039)+.00004*exp(-n/.07125);
    %CCT=4792;
    x=round(x*1000)./1000;
    y=round(y*1000)./1000;
    n=(x-.3320)/(y-.1858);
    CCT=-449*n^3+3525*n^2-6823.3*n+5520.33;