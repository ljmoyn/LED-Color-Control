function [x,y,a,b,theta] = macAdamEllipse(xcenter,ycenter,steps,g11,g22,g12)
% Returns the x,y chromaticity coordinates defining a MacAdam ellipse
% centered at x = xcenter, y = ycenter with the specified step size

% if (xcenter>0.75 || xcenter<0 || ycenter> 0.85 || ycenter<0)
%     fprintf(2,'%s\n','One or more coordinates are out of range!')
%     return
% end
% 
% % Load MacAdam Ellipse contruction data
% xi = 0.00:0.005:0.75;
% yi = 0.00:0.005:0.85;
% [XI,YI] = meshgrid(xi,yi);
% ZIg11 = importdata('RequiredData/ZIg11.txt');
% ZItwog12 = importdata('RequiredData/ZItwog12.txt');
% ZIg22 = importdata('RequiredData/ZIg22.txt');
% 
% g11 = interp2(XI,YI,ZIg11,xcenter,ycenter,'cubic')*10^4;
% twog12 = interp2(XI,YI,ZItwog12,xcenter,ycenter,'cubic')*10^4;
% g22 = interp2(XI,YI,ZIg22,xcenter,ycenter,'cubic')*10^4;
% g12 = twog12/2;

% steps = numSteps; % max(ds);

if g11==g22
    theta = pi/4;
else
    if g12<=0
        theta = atan(2*g12/(g11-g22))/2;
    else
        theta = pi/2 + atan(2*g12/(g11-g22))/2;
    end
end

a = steps.*sqrt(abs(1/(g22+g12*cot(theta))));
b = steps.*sqrt(abs(1/(g11-g12*cot(theta))));

%disp([a;b;theta;g11;twog12; g22])

[x,y] = defineEllipse(a,b,xcenter,ycenter,theta);

%{
figure(2)
plot(xpt,ypt,'b*')

hold on
plot(x,y,'b')
axis equal
grid on
title([num2str(numSteps,2) ' Step MacAdam Ellipse'])
xlabel('x')
ylabel('y')

% Print ellipse values to monitor
fprintf(1,'%s\t%s\n','x','y')
for i = 1:length(x)
    fprintf(1,'%f\t%f\n',x(i),y(i))
end

% ******* Plot Spectrum Locus ******
% Generate spectrum locus for u,v space
%load('CIE31_1', 'wavelength','xbar','ybar','zbar');
CIE31 = load('CIE31by1nm.txt');
xbar = CIE31(:,2);
ybar = CIE31(:,3);
zbar = CIE31(:,4);

n = length(xbar);
for i = 1:n
    spd = zeros(n,1);
    spd(i) = 1;
    X = sum(spd .* xbar);
    Y = sum(spd .* ybar);
    Z = sum(spd .* zbar);

    xlocus(i) = X/(X+Y+Z);
    ylocus(i) = Y/(X+Y+Z);
end
xlocus(length(xbar)+1) = xlocus(1);
ylocus(length(xbar)+1) = ylocus(1);

figure(2)
hold on
plot(xlocus,ylocus,'k')
hold off
%}

