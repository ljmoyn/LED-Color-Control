function [R,G,B,brightness_mod]=getRGB(RGB_mat,X,Y,Z)
    RGB=RGB_mat*[X; Y; Z];
    max_RGB=max([RGB(1) RGB(2) RGB(3)]);
    brightness_mod=1;
    if max_RGB > 255
        brightness_mod=255/max_RGB;
    end
    RGB=RGB*brightness_mod;
    for i=1:3
       if RGB(i) > 255
          RGB(i)=255; 
       end
    end
    R=RGB(1);
    G=RGB(2);
    B=RGB(3);