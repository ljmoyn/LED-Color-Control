clear all
clc
close all

load CRI_and_increasing_LER_weight.mat

figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';
    CCT_temp=CCT_final(i,:);
    CRI_temp=CRI_final(i,:);

    CRI_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];

    plot(CCT_temp,CRI_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')

title('CRI Results')
ylabel('CRI')

legend_entries=repmat({''},1,trials);

CRI_type='CRI';
power_type='LER';

CRI_optimizer_states={'On' 'Off'};
power_optimizer_states={'On' 'Off'};
dE_optimizer_states={'Off' 'On'};
lux_optimizer_states={'Off' 'On'};
for i=1:trials
    if strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat('CRI','[',num2str(weights(i,1)),',',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'Off')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat(CRI_type,'[Off,',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'Off')    
        CRI_entry=strcat(CRI_type,'[',num2str(weights(i,1)),',Off]');
    else
        CRI_entry='';
    end
    if strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat('  LER[',num2str(weights(i,2)),',',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'Off')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat('  LER[Off,',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'Off')    
        power_entry=strcat('  LER[',num2str(weights(i,2)),',Off]');
    else
        power_entry='';
    end

    if strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'Off')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[Off,',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'Off')    
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',Off]');
    else
        dE_entry='';
    end              

    if strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'Off')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[Off,',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'Off')    
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',Off]');
    else
        lux_entry='';
    end            

    legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);
end
legend(legend_entries)

figure()
hold on
color_index=1;
for i=1:size(power_final,1)
    colors='rgbcymk';
    CCT_temp=CCT_final(i,:);
    power_temp=power_final(i,:);

    power_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];

    plot(CCT_temp,power_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
title('Power Results')
xlabel('CCT (k)')
if strcmp(power_type,'Power')==1
    title('Power Results')
    ylabel('Power (W)')
elseif strcmp(power_type,'LER')==1
    title('LER Results')
    ylabel('LER')         
end                
legend(legend_entries)        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



load CRI_and_increasing_power_weight.mat
figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';
    CCT_temp=CCT_final(i,:);
    CRI_temp=CRI_final(i,:);

    CRI_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];

    plot(CCT_temp,CRI_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')

title('CRI Results')
ylabel('CRI')

legend_entries=repmat({''},1,trials);

CRI_type='CRI';
power_type='Power';

CRI_optimizer_states={'On' 'Off'};
power_optimizer_states={'On' 'Off'};
dE_optimizer_states={'Off' 'On'};
lux_optimizer_states={'Off' 'On'};
for i=1:trials
    if strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat('CRI','[',num2str(weights(i,1)),',',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'Off')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat(CRI_type,'[Off,',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'Off')    
        CRI_entry=strcat(CRI_type,'[',num2str(weights(i,1)),',Off]');
    else
        CRI_entry='';
    end
    if strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat('  Power[',num2str(weights(i,2)),',',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'Off')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat('  Power[Off,',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'Off')    
        power_entry=strcat('  Power[',num2str(weights(i,2)),',Off]');
    else
        power_entry='';
    end

    if strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'Off')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[Off,',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'Off')    
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',Off]');
    else
        dE_entry='';
    end              

    if strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'Off')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[Off,',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'Off')    
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',Off]');
    else
        lux_entry='';
    end            

    legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);
end
legend(legend_entries)

figure()
hold on
color_index=1;
for i=1:size(power_final,1)
    colors='rgbcymk';
    CCT_temp=CCT_final(i,:);
    power_temp=power_final(i,:);

    power_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];

    plot(CCT_temp,power_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
title('Power Results')
xlabel('CCT (k)')
if strcmp(power_type,'Power')==1
    title('Power Results')
    ylabel('Power (W)')
elseif strcmp(power_type,'LER')==1
    title('LER Results')
    ylabel('LER')         
end                
legend(legend_entries)        

load CRI_and_increasing_JND_weight.mat

figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';
    CCT_temp=CCT_final(i,:);
    CRI_temp=CRI_final(i,:);

    CRI_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];

    plot(CCT_temp,CRI_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')

title('CRI Results')
ylabel('CRI')

legend_entries=repmat({''},1,trials);

CRI_type='CRI';
power_type='Power';

CRI_optimizer_states={'On' 'Off'};
power_optimizer_states={'Off' 'Off'};
dE_optimizer_states={'On' 'Off'};
lux_optimizer_states={'Off' 'Off'};
for i=1:trials
    if strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat('CRI','[',num2str(weights(i,1)),',',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'Off')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat(CRI_type,'[Off,',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'Off')    
        CRI_entry=strcat(CRI_type,'[',num2str(weights(i,1)),',Off]');
    else
        CRI_entry='';
    end
    if strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat(power_type,'[',num2str(weights(i,2)),',',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'Off')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat(power_type,'[Off,',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'Off')    
        power_entry=strcat(power_type,'[',num2str(weights(i,2)),',Off]');
    else
        power_entry='';
    end

    if strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'Off')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[Off,',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'Off')    
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',Off]');
    else
        dE_entry='';
    end              

    if strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'Off')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[Off,',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'Off')    
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',Off]');
    else
        lux_entry='';
    end            

    legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);
end
legend(legend_entries)      

figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';

    CCT_temp=CCT_final(i,:);
    dE_temp=dE_final(i,:);

    dE_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];            

    plot(CCT_temp,dE_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')
title('JND Results')
ylabel('JNDs')
legend(legend_entries)

load dE_weight_decreasing_CRI_constraint.mat

figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';
    CCT_temp=CCT_final(i,:);
    CRI_temp=CRI_final(i,:);

    CRI_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];

    plot(CCT_temp,CRI_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')

title('CRI Results')
ylabel('CRI')

legend_entries=repmat({''},1,trials);

CRI_type='CRI';
power_type='Power';

CRI_optimizer_states={'Off' 'On'};
power_optimizer_states={'Off' 'Off'};
dE_optimizer_states={'On' 'Off'};
lux_optimizer_states={'Off' 'On'};
for i=1:trials
    if strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat('CRI','[',num2str(weights(i,1)),',',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'Off')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat(CRI_type,'[Off,',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'Off')    
        CRI_entry=strcat(CRI_type,'[',num2str(weights(i,1)),',Off]');
    else
        CRI_entry='';
    end
    if strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat(power_type,'[',num2str(weights(i,2)),',',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'Off')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat(power_type,'[Off,',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'Off')    
        power_entry=strcat(power_type,'[',num2str(weights(i,2)),',Off]');
    else
        power_entry='';
    end

    if strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'Off')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[Off,',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'Off')    
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',Off]');
    else
        dE_entry='';
    end              

    if strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'Off')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[Off,',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'Off')    
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',Off]');
    else
        lux_entry='';
    end            

    legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);
end
legend(legend_entries)      

figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';

    CCT_temp=CCT_final(i,:);
    dE_temp=dE_final(i,:);

    dE_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];            

    plot(CCT_temp,dE_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')
title('JND Results')
ylabel('JNDs')
legend(legend_entries)

load increasing_lux_constraint.mat

figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';
    CCT_temp=CCT_final(i,:);
    CRI_temp=CRI_final(i,:);

    CRI_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];

    plot(CCT_temp,CRI_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')

title('CRI Results')
ylabel('CRI')

legend_entries=repmat({''},1,trials);

CRI_type='CRI';
power_type='Power';

CRI_optimizer_states={'Off' 'On'};
power_optimizer_states={'Off' 'Off'};
dE_optimizer_states={'Off' 'On'};
lux_optimizer_states={'Off' 'On'};
for i=1:trials
    if strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat('CRI','[',num2str(weights(i,1)),',',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'Off')==1 && strcmp(CRI_optimizer_states(2),'On')
        CRI_entry=strcat(CRI_type,'[Off,',num2str(constraints(i,1)),']');
    elseif strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'Off')    
        CRI_entry=strcat(CRI_type,'[',num2str(weights(i,1)),',Off]');
    else
        CRI_entry='';
    end
    if strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat(power_type,'[',num2str(weights(i,2)),',',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'Off')==1 && strcmp(power_optimizer_states(2),'On')
        power_entry=strcat(power_type,'[Off,',num2str(constraints(i,2)),']');
    elseif strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'Off')    
        power_entry=strcat(power_type,'[',num2str(weights(i,2)),',Off]');
    else
        power_entry='';
    end

    if strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'Off')==1 && strcmp(dE_optimizer_states(2),'On')
        dE_entry=strcat('  dE[Off,',num2str(constraints(i,3)),']');
    elseif strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'Off')    
        dE_entry=strcat('  dE[',num2str(weights(i,3)),',Off]');
    else
        dE_entry='';
    end              

    if strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'Off')==1 && strcmp(lux_optimizer_states(2),'On')
        lux_entry=strcat('  Lux[Off,',num2str(constraints(i,4)),']');
    elseif strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'Off')    
        lux_entry=strcat('  Lux[',num2str(weights(i,4)),',Off]');
    else
        lux_entry='';
    end            

    legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);
end
legend(legend_entries)      

figure()
hold on
color_index=1;
for i=1:size(CRI_final,1)
    colors='rgbcymk';

    CCT_temp=CCT_final(i,:);
    dE_temp=dE_final(i,:);

    dE_temp(CCT_temp==-1)=[];
    CCT_temp(CCT_temp==-1)=[];            

    plot(CCT_temp,dE_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    color_index=color_index+1;
end
xlabel('CCT (k)')
title('JND Results')
ylabel('JNDs')
legend(legend_entries)
