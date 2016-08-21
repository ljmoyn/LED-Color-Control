close all
clear all
clc

load('CQS_and_increasing_power_weight.mat')
colors='rgbcymk';
figure()
legend_entries={};
hold on
for i=1:6
    
    plot(CCT_final(i,:),CRI_final(i,:),'Marker','o','MarkerEdgeColor',colors(i),'MarkerFaceColor',colors(i),'LineWidth',2,'Color',colors(i))

    CRI_entry=strcat('CQS[1,Off]');
    dE_entry=strcat(' dE[Off,1]');
    power_entry=strcat(' Power[',num2str(weights(i,2)),',Off]');    
    lux_entry=strcat(' Lux[Off,50]');
        
    legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);    
    
end
legend(legend_entries)
title('CQS Results')
ylabel('CQS')
xlabel('CCT (k)')

figure()
legend_entries={};
hold on
for i=1:6
    
    plot(CCT_final(i,:),power_final(i,:),'Marker','o','MarkerEdgeColor',colors(i),'MarkerFaceColor',colors(i),'LineWidth',2,'Color',colors(i))

    CRI_entry=strcat('CQS[1,Off]');
    dE_entry=strcat(' dE[Off,1]');
    power_entry=strcat(' Power[',num2str(weights(i,2)),',Off]');    
    lux_entry=strcat(' Lux[Off,50]');
        
    legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);    
    
end
legend(legend_entries)
title('Power Results')
ylabel('Power (w)')
xlabel('CCT (k)')