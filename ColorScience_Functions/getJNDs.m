function JND=getJNDs(SPD,ideal_x,ideal_y,xcmf,ycmf,zcmf,Wavelength,g11,g22,g12)
    [~,~,~,x,y,~]...
        =getXYZxyz(SPD,xcmf,ycmf,zcmf,Wavelength);
    
    %1 JND is a 3-step macadam Ellipse
    dx=x-ideal_x;
    dy=y-ideal_y;
    if dx==0 && dy==0
        JND=0;
    else    
        if dy==0
            slope=0;
        elseif dx==0
            slope=10000;
        else
            slope=dy/dx;
        end
        %push test x,y farther from ideal x,y to guarantee that the line connecting 
        %them crosses the MacAdam ellipse
        %line (ideal_x,ideal_y) ---> (farther_x,farther_y) is the same as line
        %line (ideal_x,ideal_y) ---> (x,y), except extended

        if ideal_x > x
           farther_x=-10;
        else
           farther_x=10; 
        end
        farther_y=ideal_y+slope*(farther_x-ideal_x);

        [ellipse_x,ellipse_y,~,~,~] = macAdamEllipse(ideal_x,ideal_y,3,g11,g22,g12);

        intersection = InterX([ellipse_x';ellipse_y'],[farther_x ideal_x;farther_y ideal_y]);

        %[xcross,ycross]=polyxpoly(ellipse_x,ellipse_y,[farther_x-ideal_xy(1)],[farther_y-ideal_xy(2)]);
        oneJND=sqrt((ideal_x-intersection(1,1)).^2+(ideal_y-intersection(2,1)).^2);
        %disp([ideal_xy(1)-intersection(1,1) ideal_xy(2)-intersection(2,1)])

        JND=getdE_xy(ideal_x,ideal_y,x,y)/oneJND;
    end