clear all
clc

load daylighting_baseline.mat
CCT=CCT_final;
CRI_baseline=CRI_final;

load daylighting_artificial.mat
CRI_artificial=CRI_final;

load daylighting_partly_cloudy.mat
CRI_partly_cloudy=CRI_final;

figure()
c='r';
hold on
plot(CCT,CRI_baseline,'Marker','o','MarkerEdgeColor',c,'MarkerFaceColor',c,'LineWidth',2,'Color',c)
c='g';
plot(CCT,CRI_artificial,'Marker','<','MarkerEdgeColor',c,'MarkerFaceColor',c,'LineWidth',2,'Color',c)
c='b';
plot(CCT,CRI_partly_cloudy,'Marker','<','MarkerEdgeColor',c,'MarkerFaceColor',c,'LineWidth',2,'Color',c)


% c='k';
% scatter(3034,97,'Marker','o','MarkerEdgeColor',c,'MarkerFaceColor',c)
% scatter(3034,96,'Marker','<','MarkerEdgeColor',c,'MarkerFaceColor',c)
% 
% c='m';
% scatter(4792,94,'Marker','o','MarkerEdgeColor',c,'MarkerFaceColor',c)
% scatter(4792,98,'Marker','<','MarkerEdgeColor',c,'MarkerFaceColor',c)

xlabel('CCT (k)')
title('Daylighting Results')
ylabel('CRI')
legend('Simulation without Daylight (Baseline)','Simulation with artificial daylight', ...
    'Simulation with Daylight (Partly Cloudy)','Solais, with Artificial Daylight','Solais, without Daylight', ...
    'Ecosmart with Artificial Daylight Daylight','Ecosmart, without Daylight')