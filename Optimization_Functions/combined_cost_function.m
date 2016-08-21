function [f] = combined_cost_function(x,R,CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,LED_power,LED_N,L0_norm_state)
if strcmp(CRI_optimizer_states(1),'On')==1
    %Calculate constraint on CRI
    if strcmp(CRI_type,'CRI')==1
        CRI_term=weights(1)*CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize',CRI_minmax);
    %Calculate constraint on CQS    
    elseif strcmp(CRI_type,'CQS')==1
        CRI_term=weights(1)*CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize',CRI_minmax);    
    elseif strcmp(CRI_type,'GAI')==1
        CRI_term=weights(1)*GAI_fun(x,R,CIETCS1nm,cmf,Wavelength,0,'maximize',CRI_minmax);        
    else
        CRI_term=0;
    end
else
    CRI_term=0;
end

%calculate power constraint
if strcmp(power_optimizer_states(1),'On')==1
    if strcmp(power_type,'Power')==1
        power_term=weights(2)*power_fun(x,LED_power,LED_N,0,'minimize',power_minmax);
    elseif strcmp(power_type,'LER')==1
        power_term=weights(2)*LER_fun(x,R,vl1924e1nm,Wavelength,0,'minimize',power_minmax);        
    else
        power_term=0;
    end
else
    power_term=0;
end

if strcmp(dE_optimizer_states(1),'On')==1
    %calculate JND constraont
    if strcmp(dE_type,'JND')==1
        dE_term=weights(3)*JND_fun(x,R,ideal_xy,cmf,Wavelength,g11,g22,g12,1,'minimize',dE_minmax);
    %calculate LUV constraint    
    elseif strcmp(dE_type,'LUV')==1
        dE_term=weights(3)*LUV_dE_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_LUV,Wavelength,0,'minimize',dE_minmax);
    %calculate Lab constraint
    elseif strcmp(dE_type,'Lab')==1
        dE_term=weights(3)*Lab_dE76_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_Lab,Wavelength,0,'minimize',dE_minmax);
    else
        dE_term=[];
    end
else
    dE_term=[];
end
if L0_norm_state(1) == 1 && size(L0_norm_state,2) == 1
    L0_norm_term=100000*L0_norm(x);
else
    L0_norm_term=[];
end

final=[CRI_term power_term dE_term L0_norm_term]; 
%dE CRI power
f=sum(final);
% if strcmp(dE_type,'LUV')==1 && strcmp(CRI_type,'CRI')==1
%     if strcmp(optimizer_states(1,3),'On')==1
%         dE_term=weights(1)*LUV_dE_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_LUV,Wavelength,0,'minimize');
%     else
%         dE_term=0;
%     end
%     if strcmp(optimizer_states(1,1),'On')==1
%         CRI_term=weights(2)*CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize');
%     else
%         CRI_term=0;
%     end
%     if strcmp(optimizer_states(1,2),'On')==1
%         power_term=weights(3)*power_fun(x,LED_power,LED_N,0,'minimize');
%     else
%         power_term=0;
%     end
% 
% elseif strcmp(dE_type,'JND')==1 && strcmp(CRI_type,'CRI')==1
%     if strcmp(optimizer_states(1,3),'On')==1
%         dE_term=weights(1)*JND_fun(x,R,ideal_xy,cmf,Wavelength,g11,g22,g12,1,'minimize');
%     else
%         dE_term=0;
%     end
%     if strcmp(optimizer_states(1,1),'On')==1
%         CRI_term=weights(2)*CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize');
%     else
%         CRI_term=0;
%     end
%     if strcmp(optimizer_states(1,2),'On')==1
%         power_term=weights(3)*power_fun(x,LED_power,LED_N,0,'minimize');
%     else
%         power_term=0;
%     end
%     
% elseif strcmp(dE_type,'Lab')==1 && strcmp(CRI_type,'CRI')==1
%     if strcmp(optimizer_states(1,3),'On')==1
%         dE_term=weights(1)*Lab_dE76_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1),cmf(:,2),cmf(:,3),ideal_Lab,Wavelength,0,'minimize');
%     else
%         dE_term=0;
%     end
%     if strcmp(optimizer_states(1,1),'On')==1
%         CRI_term=weights(2)*CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize');
%     else
%         CRI_term=0;
%     end
%     if strcmp(optimizer_states(1,2),'On')==1
%         power_term=weights(3)*power_fun(x,LED_power,LED_N,0,'minimize');
%     else
%         power_term=0;
%     end
% 
% %CQS Optimization
% elseif strcmp(dE_type,'LUV')==1 && strcmp(CRI_type,'CQS')==1
%     if strcmp(optimizer_states(1,3),'On')==1
%         dE_term=weights(1)*LUV_dE_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_LUV,Wavelength,0,'minimize');
%     else
%         dE_term=0;
%     end
%     if strcmp(optimizer_states(1,1),'On')==1
%         CRI_term=weights(2)*CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize');
%     else
%         CRI_term=0;
%     end
%     if strcmp(optimizer_states(1,2),'On')==1
%         power_term=weights(3)*power_fun(x,LED_power,LED_N,0,'minimize');
%     else
%         power_term=0;
%     end
% 
% elseif strcmp(dE_type,'JND')==1 && strcmp(CRI_type,'CQS')==1
%     if strcmp(optimizer_states(1,3),'On')==1
%         dE_term=weights(1)*JND_fun(x,R,ideal_xy,cmf,Wavelength,g11,g22,g12,1,'minimize');
%     else
%         dE_term=0;
%     end
%     if strcmp(optimizer_states(1,1),'On')==1
%         CRI_term=weights(2)*CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize');
%     else
%         CRI_term=0;
%     end
%     if strcmp(optimizer_states(1,2),'On')==1
%         power_term=weights(3)*power_fun(x,LED_power,LED_N,0,'minimize');
%     else
%         power_term=0;
%     end
%     
% elseif strcmp(dE_type,'Lab')==1 && strcmp(CRI_type,'CQS')==1
%     if strcmp(optimizer_states(1,3),'On')==1
%         dE_term=weights(1)*Lab_dE76_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1),cmf(:,2),cmf(:,3),ideal_Lab,Wavelength,0,'minimize');
%     else
%         dE_term=0;
%     end
%     if strcmp(optimizer_states(1,1),'On')==1
%         CRI_term=weights(2)*CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,0,'maximize');
%     else
%         CRI_term=0;
%     end
%     if strcmp(optimizer_states(1,2),'On')==1
%         power_term=weights(3)*power_fun(x,LED_power,LED_N,0,'minimize');
%     else
%         power_term=0;
%     end
% end

end