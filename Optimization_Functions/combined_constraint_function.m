function [c,ceq]=combined_constraint_function(x,R,CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,power_type,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,LED_power,LED_N,LED_lux,cmf,Wavelength,g11,g22,g12,vl1924e1nm,L0_norm_state)
if strcmp(CRI_optimizer_states(2),'On')==1
    %Calculate constraint on CRI
    if strcmp(CRI_type,'CRI')==1
        CRI_constraint=CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(1),'constraint',CRI_minmax);
    %Calculate constraint on CQS    
    elseif strcmp(CRI_type,'CQS')==1
        CRI_constraint=CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(1),'constraint',CRI_minmax);
    elseif strcmp(CRI_type,'GAI')==1
        CRI_constraint=GAI_fun(x,R,CIETCS1nm,cmf,Wavelength,constraints(1),'constraint',CRI_minmax);
    else
        CRI_constraint=[];
    end
else
    CRI_constraint=[];
end

%calculate power constraint
if strcmp(power_optimizer_states(2),'On')==1
    if strcmp(power_type,'Power')==1
        power_constraint=power_fun(x,LED_power,LED_N,constraints(2),'constraint',power_minmax);
    elseif strcmp(power_type,'LER')==1
        power_constraint=LER_fun(x,R,vl1924e1nm,Wavelength,constraints(2),'constraint',power_minmax);
    else
        power_constraint=[];
    end
else
    power_constraint=[];
end

if strcmp(dE_optimizer_states(2),'On')==1
    %calculate JND constraont
    if strcmp(dE_type,'JND')==1
        dE_constraint=JND_fun(x,R,ideal_xy,cmf,Wavelength,g11,g22,g12,constraints(3),'constraint',dE_minmax);
    %calculate LUV constraint    
    elseif strcmp(dE_type,'LUV')==1
        dE_constraint=LUV_dE_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_LUV,Wavelength,constraints(3),'constraint',dE_minmax);
    %calculate Lab constraint
    elseif strcmp(dE_type,'Lab')==1
        dE_constraint=Lab_dE76_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_Lab,Wavelength,constraints(3),'constraint',dE_minmax);
    else
        dE_constraint=[];
    end
else
    dE_constraint=[];
end
if strcmp(lux_optimizer_states(2),'On')==1
    if lux_minmax(2)==1
        lux_constraint=-sum(x.*LED_lux)+constraints(4);
        lux_upper_bound=sum(x.*LED_lux)-constraints(4)-10;
    else
        lux_constraint=-1*(-sum(x.*LED_lux)+constraints(4));
        lux_upper_bound=-1*(sum(x.*LED_lux)-constraints(4))-10;        
    end
else
    lux_constraint=[];
    lux_upper_bound=[];
end
if size(L0_norm_state,2) > 1
    %L0_norm_constraint1=L0_norm(modified_x)-L0_norm_state(2)-.5;
    L0_norm_constraint2=L0_norm(x)-L0_norm_state(2);
else
    %L0_norm_constraint1=[];
    L0_norm_constraint2=[];
end

ceq=[];
c=[CRI_constraint dE_constraint power_constraint lux_constraint lux_upper_bound L0_norm_constraint2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% if strcmp(dE_type,'LUV')==1 && strcmp(CRI_type,'CRI')==1
%     if strcmp(optimizer_states(2,3),'On')==1
%         dE_constraint=LUV_dE_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_LUV,Wavelength,constraints(1),'constraint');
%     else
%         dE_constraint=[];
%     end
%     if strcmp(optimizer_states(2,1),'On')==1
%         CRI_constraint=CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(2),'constraint');
%     else
%         CRI_constraint=[];
%     end
%     if strcmp(optimizer_states(2,2),'On')==1
%         power_constraint=power_fun(x,LED_power,LED_N,constraints(3),'constraint');
%     else
%         power_constraint=[];
%     end
% elseif strcmp(dE_type,'JND')==1 && strcmp(CRI_type,'CRI')==1
%     if strcmp(optimizer_states(2,3),'On')==1
%         dE_constraint=JND_fun(x,R,ideal_xy,cmf,Wavelength,g11,g22,g12,constraints(1),'constraint');
%     else
%         dE_constraint=[];
%     end
%     if strcmp(optimizer_states(2,1),'On')==1
%         CRI_constraint=CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(2),'constraint');
%     else
%         CRI_constraint=[];
%     end
%     if strcmp(optimizer_states(2,2),'On')==1
%         power_constraint=power_fun(x,LED_power,LED_N,constraints(3),'constraint');
%     else
%         power_constraint=[];
%     end
% 
% elseif strcmp(dE_type,'Lab')==1 && strcmp(CRI_type,'CRI')==1
%     if strcmp(optimizer_states(2,3),'On')==1
%         dE_constraint=Lab_dE76_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_Lab,Wavelength,constraints(1),'constraint');
%     else
%         dE_constraint=[];
%     end
%     if strcmp(optimizer_states(2,1),'On')==1
%         CRI_constraint=CRI_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(2),'constraint');
%     else
%         CRI_constraint=[];
%     end
%     if strcmp(optimizer_states(2,2),'On')==1
%         power_constraint=power_fun(x,LED_power,LED_N,constraints(3),'constraint');
%     else
%         power_constraint=[];
%     end
% 
% %CQS optimizations    
% elseif strcmp(dE_type,'LUV')==1 && strcmp(CRI_type,'CQS')==1
%     if strcmp(optimizer_states(2,3),'On')==1
%         dE_constraint=LUV_dE_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_LUV,Wavelength,constraints(1),'constraint');
%     else
%         dE_constraint=[];
%     end
%     if strcmp(optimizer_states(2,1),'On')==1
%         CRI_constraint=CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(2),'constraint');
%     else
%         CRI_constraint=[];
%     end
%     if strcmp(optimizer_states(2,2),'On')==1
%         power_constraint=power_fun(x,LED_power,LED_N,constraints(3),'constraint');
%     else
%         power_constraint=[];
%     end
%     
% elseif strcmp(dE_type,'JND')==1 && strcmp(CRI_type,'CQS')==1
%     if strcmp(optimizer_states(2,3),'On')==1
%         dE_constraint=JND_fun(x,R,ideal_xy,cmf,Wavelength,g11,g22,g12,constraints(1),'constraint');
%     else
%         dE_constraint=[];
%     end
%     if strcmp(optimizer_states(2,1),'On')==1
%         CRI_constraint=CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(2),'constraint');
%     else
%         CRI_constraint=[];
%     end
%     if strcmp(optimizer_states(2,2),'On')==1
%         power_constraint=power_fun(x,LED_power,LED_N,constraints(3),'constraint');
%     else
%         power_constraint=[];
%     end
%     
% elseif strcmp(dE_type,'Lab')==1 && strcmp(CRI_type,'CQS')==1
%     if strcmp(optimizer_states(2,3),'On')==1
%         dE_constraint=Lab_dE76_fun(x,R,standard_xy(1),standard_xy(2),cmf(:,1)',cmf(:,2)',cmf(:,3)',ideal_Lab,Wavelength,constraints(1),'constraint');
%     else
%         dE_constraint=[];
%     end
%     if strcmp(optimizer_states(2,1),'On')==1
%         CRI_constraint=CQS_fun(x,R,CIETCS1nm,DSPD,cmf,Wavelength,constraints(2),'constraint');
%     else
%         CRI_constraint=[];
%     end
%     if strcmp(optimizer_states(2,2),'On')==1
%         power_constraint=power_fun(x,LED_power,LED_N,constraints(3),'constraint');
%     else
%         power_constraint=[];
%     end
% end

        
end