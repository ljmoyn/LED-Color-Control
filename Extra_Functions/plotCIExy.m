clear all
close all

[WL, xFcn, yFcn, zFcn] = colorMatchFcn('1931_full');

v=[0:.001:1];
[x,y]=meshgrid(v,v); y=flipud(y);
z=(1-x-y);
rgb=applycform(cat(3,x,y,z),makecform('xyz2srgb'));
ciex=xFcn./sum([xFcn; yFcn; zFcn],1);
ciey=yFcn./sum([xFcn; yFcn; zFcn]);
nciex=ciex*size(rgb,2);
nciey=size(rgb,1)-ciey*size(rgb,1);

%mask=~any(rgb==0,3); mask=cat(3,mask,mask,mask);
mask=roipoly(rgb,nciex,nciey); mask=cat(3,mask,mask,mask);
figure; imshow(rgb.*mask+~mask); hold on;

[C,IA,IB]=intersect(WL,[400 460 470 480 490 520 540 560 580 600 620 700]);
text(nciex(IA),nciey(IA),num2str(WL(IA).'));
axis on;
set(gca,'XTickLabel',get(gca,'XTick')/(size(rgb,2)-1));
set(gca,'YTickLabel',1-get(gca,'YTick')/(size(rgb,1)-1));

[color_lambda, RGB] = createSpectrum('1931_full');

% lambda1=1;
% lambda2=2;
% color_lambda_shift=WL(2)-WL(1);
% while lambda1 < size(WL,2) && lambda2 < size(WL,2)
%     plot(nciex(lambda1:lambda2),nciey(lambda1:lambda2),'Color',RGB(1,color_lambda_shift+lambda1,:),'LineWidth',2)
%     lambda1=lambda1+1;
%     lambda2=lambda2+1;
% end
plot(nciex,nciey,'k','LineWidth',2)
violet_line_x=[nciex(1) nciex(end)];
violet_line_y=[nciey(1) nciey(end)];
plot(violet_line_x,violet_line_y,'k','LineWidth',2)
%plot(nciex,nciey,'k','LineWidth',2)
grid
title('CIE Chromaticity'); xlabel('x'); ylabel('y');

% Wavelength=360:1:830;
% 
% cmf=importdata('RequiredData/cmf_1nm_xyz2deg_xyz10deg.txt');
% cmf=cmf(:,[1 2:4]);
% 
% xcmf=spline(cmf(:,1),cmf(:,2),Wavelength);
% xcmf(Wavelength < min(cmf(:,1)))=0;
% xcmf(Wavelength > max(cmf(:,1)))=0;
% 
% ycmf=spline(cmf(:,1),cmf(:,3),Wavelength);
% ycmf(Wavelength < min(cmf(:,1)))=0;
% ycmf(Wavelength > max(cmf(:,1)))=0;
% 
% zcmf=spline(cmf(:,1),cmf(:,4),Wavelength);
% zcmf(Wavelength < min(cmf(:,1)))=0;
% zcmf(Wavelength > max(cmf(:,1)))=0;
% 
% % x_bar, etc are column vectors at wavelengths, wl.
% x = xcmf./(xcmf + ycmf + zcmf);
% y = ycmf./(xcmf + ycmf + zcmf);
%  
% figure()
% 
% wl = Wavelength;
% n = length(wl);
% 
% % blue blue cyan green yellow orange red red
% wl0 = [360 470 492 520 575 600 630 830]'; % wavelengths in nm.
% rgb0 = [0 0 1;0 0 1;0 1 1;0 1 0;1 1 0;1 0.5 0;1 0 0;1 0 0];
% rgb = [pchip(wl0,rgb0(:,1),wl), pchip(wl0,rgb0(:,2),wl),...
%     pchip(wl0,rgb0(:,3),wl)];
% rgb=rgb';
% for k = 1:n-1
%     disp({'testing ',k})
%     disp([size(rgb(k,:)) size(rgb(k+1,:))])
%     rgb2 = permute([1 1 1;rgb(k,:);rgb(k+1,:)],[1 3 2]);
%     patch([1/3;x(k:k+1)],[1/3;y(k:k+1)],rgb2,'edgecolor','none');
% end
% rgb2 = permute([1 1 1;rgb(end,:);rgb(1,:)],[1 3 2]);
% patch([1/3;x([end 1])],[1/3;y([end 1])],rgb2,'edgecolor','none');
%  
% patch(x,y,'-k','facecolor','none','edgecolor','k')
%  
% hold on
% plot(1/3,1/3,'ok')
% hold off
%  
% axis equal
% axis([0 .8 0 .9])
