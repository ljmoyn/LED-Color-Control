clear 
close all
clc

load('channel_linearity.mat')

x=0:1/327:1;
yr=total_mean_red./max(total_mean_red);
yg=total_mean_green./max(total_mean_green);
yb=total_mean_blue./max(total_mean_blue);
ya=total_mean_amber./max(total_mean_amber);
yw=total_mean_clear./max(total_mean_clear);



figure()
hold on
plot(x,yr,'r','LineWidth',2)
plot(x,yg,'g','LineWidth',2)
plot(x,yb,'b','LineWidth',2)
plot(x,ya,'y','LineWidth',2)
plot(x,yw,'k','LineWidth',2)

figure()
hold on
plot(yr,x,'r','LineWidth',2)
plot(yg,x,'g','LineWidth',2)
plot(yb,x,'b','LineWidth',2)
plot(ya,x,'y','LineWidth',2)
plot(yw,x,'k','LineWidth',2)