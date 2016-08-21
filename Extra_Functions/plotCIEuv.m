clear all
close all

[WL, xFcn, yFcn, zFcn] = colorMatchFcn('1931_full');


v=[0:.001:1];
[x,y]=meshgrid(v,v); y=flipud(y);
z=(1-x-y);
rgb=applycform(cat(3,x,y,z),makecform('xyz2srgb'));


ciex=xFcn./sum([xFcn; yFcn; zFcn],1);
ciey=yFcn./sum([xFcn; yFcn; zFcn]);
cieu=4.*ciex./(-2.*ciex+12.*ciey+3);
ciev=9.*ciey./(-2.*ciex+12.*ciey+3);

ciex=cieu;
ciey=ciev;

nciex=ciex*size(rgb,2);
nciey=size(rgb,1)-ciey*size(rgb,1);

mask=~any(rgb==0,3); mask=cat(3,mask,mask,mask);
%mask=roipoly(rgb,nciex,nciey); mask=cat(3,mask,mask,mask);
figure; imshow(rgb.*0); 
hold on;
[C,IA,IB]=intersect(WL,[430 460 470 480 490 520 540 560 580 600 620 680]);

%disp([size(nciex) size(nciey)])
%disp(IA)

text(nciex(IA),nciey(IA),num2str(WL(IA).'));
axis on;
axis ij;
set(gca,'XTickLabel',get(gca,'XTick')/(size(rgb,2)-1));
set(gca,'YTickLabel',1-get(gca,'YTick')/(size(rgb,1)-1));

[color_lambda, RGB] = createSpectrum('1931_full');

lambda1=1;
lambda2=2;
color_lambda_shift=WL(2)-WL(1);
while lambda1 < size(WL,2) && lambda2 < size(WL,2)
    plot(nciex(lambda1:lambda2),nciey(lambda1:lambda2),'Color',RGB(1,color_lambda_shift+lambda1,:),'LineWidth',2)
    lambda1=lambda1+1;
    lambda2=lambda2+1;
end
violet_line_x=[nciex(1) nciex(end)];
violet_line_y=[nciey(1) nciey(end)];
plot(violet_line_x,violet_line_y,'o-k','LineWidth',2)
%plot(nciex,nciey,'k','LineWidth',2)
title('CIE Chromaticity'); xlabel('x'); ylabel('y');