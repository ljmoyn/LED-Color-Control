function [x,y] = defineEllipse(a,b,xcenter,ycenter,theta)
    z = 0:.1:2*pi;

    % Calculate x,y coordinates defining ellipse
    x = a*cos(z);
    y = b*sin(z);

    % convert to polar coordinates
    r = (x.^2 +y.^2).^0.5;
    angle = atan2(y,x)+theta;% add angle that ellpse is tilted, theta.
    % A four quadrant arctangent function is needed.

    % convert back to rectangular coordinates and translate to chromaticity where
    % ellipse is centered.
    x = r.*cos(angle)+xcenter;
    y = r.*sin(angle)+ycenter;

    % MatLab commands to plot ellipse
    x(end+1) = x(1); % Repeat first value to close ellipse when plotting
    y(end+1) = y(1);
    x = x';
    y = y';
