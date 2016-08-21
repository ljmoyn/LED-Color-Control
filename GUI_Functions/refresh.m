function [handles]=refresh(hObject,eventdata,handles)

    %set(handles.current_unit_text,'string',handles.current_unit_type) 
    set(handles.ideal_lux_edit,'string',num2str(handles.Ideal_lux(:,handles.match_active==1)))
    
    if handles.choose_NLEDs==0 || size(handles.LED_data,2) < 1
       set(handles.choose_NLEDs_editbox,'Value',1)
       set(handles.choose_NLEDs_editbox,'Enable','Off')
    else
       set(handles.choose_NLEDs_editbox,'Enable','On')
    end
    
    for n=1:size(handles.alpha,2)
        if isnan(handles.alpha(n))==1
            handles.alpha(n)=1;
        else    
            if handles.alpha(n) < 0
               handles.alpha(n)=0; 
            end
            if handles.alpha(n) > handles.max_alpha
               handles.alpha(n)=handles.max_alpha; 
            end
        end
        
        if isnan(handles.LED_lux(n))==1
            handles.alpha(n)=100;
        else    
            if handles.alpha(n) < 0
               handles.alpha(n)=0; 
            end
        end      
        
    end    
    
    if size(handles.LED_data,2) > 5
        handles.LED_pages=handles.LED_pages+1;
    end
    
    if handles.LED_pagenum <= 0
        set(handles.prev_page,'Enable','off') 
    else
        set(handles.prev_page,'Enable','on')         
    end

    if size(handles.LED_data,2) < 1+(handles.LED_pagenum+1)*5
       set(handles.next_page,'Enable','off') 
    else
       set(handles.next_page,'Enable','on')         
    end    
    
    if size(handles.match_data) >= 1
        s=handles.match_data(:,handles.match_active==1);
        s=s';

        [handles.X(1),handles.Y(1),handles.Z(1),handles.x(1),handles.y(1),handles.z(1)]...
            =getXYZxyz(s,handles.xcmf,handles.ycmf,handles.zcmf,handles.Wavelength); 
        
        handles.g11 = interp2(handles.MacAdamsXI,handles.MacAdamsYI,handles.ZIg11,handles.x(1),handles.y(1),'cubic')*10^4;
        twog12 = interp2(handles.MacAdamsXI,handles.MacAdamsYI,handles.ZItwog12,handles.x(1),handles.y(1),'cubic')*10^4;
        handles.g22 = interp2(handles.MacAdamsXI,handles.MacAdamsYI,handles.ZIg22,handles.x(1),handles.y(1),'cubic')*10^4;
        handles.g12 = twog12/2;
     
        handles.power(1)=0;
        
        [handles.R(1),handles.G(1),handles.B(1),handles.RGB_brightness_mod(1)]...
            =getRGB(handles.RGB_mat,handles.X(1),handles.Y(1),handles.Z(1));
        
        [handles.UVW_u(1),handles.UVW_v(1),handles.W(1)]...
            =getUVW(handles.X(1),handles.Y(1),handles.Z(1),handles.standard_illuminant(1),handles.standard_illuminant(2));
  
        [handles.LUV_L(1),handles.LUV_u(1),handles.LUV_v(1),handles.LUV_u_prime(1),handles.LUV_v_prime(1)]...
            =getLUV_uprime_vprime(handles.X(1),handles.Y(1),handles.Z(1),handles.standard_illuminant(1),handles.standard_illuminant(2));

        handles.cct(1)=getCCT(handles.x(1),handles.y(1));       
        
        nrefspd = get_nrefspd(handles.cct(1),handles.DSPD,handles.Wavelength,560);
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
        [Ra,R] = get_cri1995(s',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength);
        [CQS] = get_CQS(s',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength,handles.cct(1));

        handles.GAI(1)=get_GAI(s',cmf,handles.CIETCS1nm,handles.Wavelength);      
        
        handles.CRI(1)=Ra;
        handles.CQS(1)=CQS;
        handles.LER(1)=get_LER(s',handles.vl1924e1nm,handles.Wavelength);

        
        [handles.Lab_L(1),handles.a(1),handles.b(1)]...
            =getLab(handles.X(1),handles.Y(1),handles.Z(1),handles.standard_illuminant(1),handles.standard_illuminant(2));

    end
    
    %if size(handles.LED_data,2) >= 1
    if size(handles.alpha(handles.LED_state >= 1),2) == 0
        %set values back to starting
        handles.generated=zeros(size(handles.Wavelength));
        handles.cct(2)=0;
        handles.X(2)=0;handles.Y(2)=0;handles.Z(2)=0;
        handles.R(2)=0;handles.G(2)=0;handles.B(2)=0;handles.RGB_LEDs=[];
        handles.RGB_brightness_mod(2)=0;
        handles.x(2)=0;handles.y(2)=0;handles.z(2)=0;
        handles.LUV_u_prime(2)=0;handles.LUV_v_prime(2)=0;
        handles.LUV_u(2)=0;handles.LUV_v(2)=0;handles.LUV_L(2)=0;
        handles.UVW_u(2)=0;handles.UVW_v(2)=0;handles.W(2)=0;
        handles.Lab_L(2)=0;handles.a(2)=0;handles.b(2)=0;
        handles.LUV_dE=-1;handles.uvChroma_dE=-1;handles.dE76=-1;handles.dE94=-1;handles.dE00=-1;
        handles.CRI(2)=0;handles.power(2)=0;handles.CQS(2)=0;
    else
        alpha_applied=ones(size(handles.Wavelength,2),size(handles.alpha,2));
        for n=1:size(handles.alpha,2)
            if handles.LED_state(n)>=1             
                alpha_applied(:,n)=handles.LED_data(:,n).*handles.alpha(n).*handles.LED_N(n);
            else
                alpha_applied(:,n)=0;
            end
        end
        handles.generated=sum(alpha_applied,2);        
        handles.generated=handles.generated';

        handles.power(2)=sum(handles.LED_power(handles.LED_state >= 1).*handles.LED_N(handles.LED_state >= 1).*handles.alpha(handles.LED_state >= 1));

        [handles.X(2),handles.Y(2),handles.Z(2),handles.x(2),handles.y(2),handles.z(2)]...
            =getXYZxyz(handles.generated,handles.xcmf,handles.ycmf,handles.zcmf,handles.Wavelength);                  

        [handles.R(2),handles.G(2),handles.B(2),handles.RGB_brightness_mod(2)]...
            =getRGB(handles.RGB_mat,handles.X(2),handles.Y(2),handles.Z(2));

        [handles.UVW_u(2),handles.UVW_v(2),handles.W(2)]...
            =getUVW(handles.X(2),handles.Y(2),handles.Z(2),handles.standard_illuminant(1),handles.standard_illuminant(2));   

        [handles.LUV_L(2),handles.LUV_u(2),handles.LUV_v(2),handles.LUV_u_prime(2),handles.LUV_v_prime(2)]...
            =getLUV_uprime_vprime(handles.X(2),handles.Y(2),handles.Z(2),handles.standard_illuminant(1),handles.standard_illuminant(2));

        handles.cct(2)=getCCT(handles.x(2),handles.y(2));

        nrefspd = get_nrefspd(handles.cct(2),handles.DSPD,handles.Wavelength,560);
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
        [Ra,R] = get_cri1995(handles.generated',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength);
        [CQS] = get_CQS(handles.generated',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength,handles.cct(2));

        handles.GAI(2)=get_GAI(handles.generated',cmf,handles.CIETCS1nm,handles.Wavelength);      
        handles.CRI(2)=Ra;        
        handles.CQS(2)=CQS;
        handles.LER(2)=get_LER(handles.generated',handles.vl1924e1nm,handles.Wavelength);

        [handles.Lab_L(2),handles.a(2),handles.b(2)]...
            =getLab(handles.X(2),handles.Y(2),handles.Z(2),handles.standard_illuminant(1),handles.standard_illuminant(2));
    end
    
    if size(handles.match_data,2) >= 1 && size(handles.LED_data,2) >= 1
        handles.xy_dE=sqrt((handles.x(1)-handles.x(2))^2+(handles.y(1)-handles.y(2))^2);
        
        handles.LUV_dE=getdE_LUV(handles.LUV_L(1),handles.LUV_L(2),handles.LUV_u(1),handles.LUV_u(2),handles.LUV_v(1),handles.LUV_v(2));
        [handles.dE76,handles.dE94,handles.dE00]=...
            getdE_Lab(handles.Lab_L(1),handles.Lab_L(2),handles.a(1),handles.a(2),handles.b(1),handles.b(2));
        handles.uvChroma_dE=sqrt((handles.LUV_u_prime(1)-handles.LUV_u_prime(2)).^2+(handles.LUV_v_prime(1)-handles.LUV_v_prime(2)).^2);
        
        handles.JND=getJNDs(handles.generated,handles.x(1),handles.y(1),handles.xcmf,handles.ycmf, handles.zcmf,handles.Wavelength,handles.g11,handles.g22,handles.g12);
    end
        
    if strcmp(handles.power_optimizer_states(1),'On')==1
        set(handles.power_weight_edit,'String',handles.power_weight)
    else
        set(handles.power_weight_edit,'String','Off')
    end
    if strcmp(handles.CRI_optimizer_states(1),'On')==1
        set(handles.CRI_weight_edit,'String',handles.CRI_weight)
    else
        set(handles.CRI_weight_edit,'String','Off')
    end
    
    if strcmp(handles.dE_optimizer_states(1),'On')==1
        set(handles.dE_weight_edit,'String',handles.dE_weight)
    else
        set(handles.dE_weight_edit,'String','Off')
    end
    
    if strcmp(handles.lux_optimizer_states(1),'On')==1
        set(handles.lux_weight_edit,'String',handles.lux_weight)
    else
        set(handles.lux_weight_edit,'String','Off')
    end
    
    if strcmp(handles.power_optimizer_states(2),'On')==1
        if handles.power_goal > 683 && strcmp(handles.optimize_power_type,'LER')==1 
           handles.power_goal=683; 
        end
        set(handles.power_goal_edit,'String',handles.power_goal)
    else
        set(handles.power_goal_edit,'String','Off')
    end
    if strcmp(handles.CRI_optimizer_states(2),'On')==1
        set(handles.CRI_goal_edit,'String',handles.CRI_goal)
    else
        set(handles.CRI_goal_edit,'String','Off')
    end
    
    if strcmp(handles.dE_optimizer_states(2),'On')==1
        set(handles.dE_goal_edit,'String',handles.dE_goal)
    else
        set(handles.dE_goal_edit,'String','Off')
    end
    if strcmp(handles.lux_optimizer_states(2),'On')==1
        set(handles.lux_goal_edit,'String',handles.lux_goal)
    else
        set(handles.lux_goal_edit,'String','Off')
    end        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(handles.simulation_power_states(1),'On')==1
        set(handles.simulation_power_weight_edit,'String',handles.simulation_power_increments(1))
    else
        set(handles.simulation_power_weight_edit,'String','Off')
    end
    
    if strcmp(handles.simulation_CRI_states(1),'On')==1
        set(handles.simulation_CRI_weight_edit,'String',handles.simulation_CRI_increments(1))
    else
        set(handles.simulation_CRI_weight_edit,'String','Off')
    end
    
    if strcmp(handles.simulation_dE_states(1),'On')==1
        set(handles.simulation_dE_weight_edit,'String',handles.simulation_dE_increments(1))
    else
        set(handles.simulation_dE_weight_edit,'String','Off')
    end
    
    if strcmp(handles.simulation_lux_states(1),'On')==1
        set(handles.simulation_lux_weight_edit,'String',handles.simulation_lux_increments(1))
    else
        set(handles.simulation_lux_weight_edit,'String','Off')
    end
    
    if strcmp(handles.simulation_power_states(2),'On')==1
        set(handles.simulation_power_constraint_edit,'String',handles.simulation_power_increments(2))
    else
        set(handles.simulation_power_constraint_edit,'String','Off')
    end
    
    if strcmp(handles.simulation_CRI_states(2),'On')==1
        set(handles.simulation_CRI_constraint_edit,'String',handles.simulation_CRI_increments(2))
    else
        set(handles.simulation_CRI_constraint_edit,'String','Off')
    end
    
    if strcmp(handles.simulation_dE_states(2),'On')==1
        set(handles.simulation_dE_constraint_edit,'String',handles.simulation_dE_increments(2))
    else
        set(handles.simulation_dE_constraint_edit,'String','Off')
    end
    
    if strcmp(handles.simulation_lux_states(2),'On')==1
        set(handles.simulation_lux_constraint_edit,'String',handles.simulation_lux_increments(2))
    else
        set(handles.simulation_lux_constraint_edit,'String','Off')
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if handles.simulation_activated==0
        set(handles.simulation_panel,'Visible','Off')
    else
        set(handles.simulation_panel,'Visible','On')
    end
    
    handles.lux=sum(handles.alpha(handles.LED_state >= 1).*handles.LED_lux(handles.LED_state >= 1).*handles.LED_N(handles.LED_state >= 1));
    set(handles.optimizer_lux_value,'String',handles.lux)
            
        if strcmp(handles.optimize_CRI_type,'CRI')==1
            set(handles.optimizer_CRI_label,'String','CRI')
            set(handles.optimizer_CRI_value,'String',handles.CRI(2))
        elseif strcmp(handles.optimize_CRI_type,'CQS')==1
            set(handles.optimizer_CRI_label,'String','CQS')
            set(handles.optimizer_CRI_value,'String',handles.CQS(2))
        elseif strcmp(handles.optimize_CRI_type,'GAI')==1
            set(handles.optimizer_CRI_label,'String','GAI')
            set(handles.optimizer_CRI_value,'String',handles.GAI(2))
        end
        if strcmp(handles.optimize_power_type,'Power')==1
            set(handles.optimizer_power_label,'String','Power')
            set(handles.optimizer_power_value,'String',handles.power(2))
        elseif strcmp(handles.optimize_power_type,'LER')==1
            set(handles.optimizer_power_label,'String','LER')
            set(handles.optimizer_power_value,'String',handles.LER(2))
        end
        if strcmp(handles.optimize_dE_type,'LUV')==1
            set(handles.optimizer_dE_label,'String','LUV dE')
            set(handles.optimizer_dE_value,'String',handles.LUV_dE)
        elseif strcmp(handles.optimize_dE_type,'Lab')==1
            set(handles.optimizer_dE_label,'String','Lab dE76')
            set(handles.optimizer_dE_value,'String',handles.dE76)
        elseif strcmp(handles.optimize_dE_type,'JND')==1
            set(handles.optimizer_dE_label,'String','JNDs')
            set(handles.optimizer_dE_value,'String',handles.JND)
        end    
    set(handles.matching_spectrum_popup,'string',handles.matching_spectrum_names)
    
    if size(handles.matching_spectrum_names,2) >= 1
        set(handles.ideal_lux_edit,'string',num2str(handles.Ideal_lux(:,handles.match_active==1)));
    end

    if handles.simulation_CRI_direction(1) == 1
        set(handles.simulation_CRI_weight_toggle,'String','Increasing')
        set(handles.simulation_CRI_weight_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.simulation_CRI_weight_toggle,'String','Decreasing')
        set(handles.simulation_CRI_weight_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.simulation_CRI_direction(2) == 1
        set(handles.simulation_CRI_constraint_toggle,'String','Increasing')
        set(handles.simulation_CRI_constraint_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.simulation_CRI_constraint_toggle,'String','Decreasing')
        set(handles.simulation_CRI_constraint_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.simulation_power_direction(1) == 1
        set(handles.simulation_power_weight_toggle,'String','Increasing')
        set(handles.simulation_power_weight_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.simulation_power_weight_toggle,'String','Decreasing')
        set(handles.simulation_power_weight_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.simulation_power_direction(2) == 1
        set(handles.simulation_power_constraint_toggle,'String','Increasing')
        set(handles.simulation_power_constraint_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.simulation_power_constraint_toggle,'String','Decreasing')
        set(handles.simulation_power_constraint_toggle,'BackgroundColor',[.76 .87 .78])        
    end 
    
    if handles.simulation_dE_direction(1) == 1
        set(handles.simulation_dE_weight_toggle,'String','Increasing')
        set(handles.simulation_dE_weight_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.simulation_dE_weight_toggle,'String','Decreasing')
        set(handles.simulation_dE_weight_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.simulation_dE_direction(2) == 1
        set(handles.simulation_dE_constraint_toggle,'String','Increasing')
        set(handles.simulation_dE_constraint_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.simulation_dE_constraint_toggle,'String','Decreasing')
        set(handles.simulation_dE_constraint_toggle,'BackgroundColor',[.76 .87 .78])        
    end 
    
    if handles.simulation_lux_direction(2) == 1
        set(handles.simulation_lux_constraint_toggle,'String','Increasing')
        set(handles.simulation_lux_constraint_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.simulation_lux_constraint_toggle,'String','Decreasing')
        set(handles.simulation_lux_constraint_toggle,'BackgroundColor',[.76 .87 .78])        
    end 
    
    if handles.CRI_minmax(1) == 1
        set(handles.CRI_weight_minmax_toggle,'String','Maximize')
        set(handles.CRI_weight_minmax_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.CRI_weight_minmax_toggle,'String','Minimize')
        set(handles.CRI_weight_minmax_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.CRI_minmax(2) == 1
        set(handles.CRI_constraint_minmax_toggle,'String','Greater Than')
        set(handles.CRI_constraint_minmax_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.CRI_constraint_minmax_toggle,'String','Less Than')
        set(handles.CRI_constraint_minmax_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.power_minmax(1) == 1
        set(handles.power_weight_minmax_toggle,'String','Maximize')
        set(handles.power_weight_minmax_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.power_weight_minmax_toggle,'String','Minimize')
        set(handles.power_weight_minmax_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.power_minmax(2) == 1
        set(handles.power_constraint_minmax_toggle,'String','Greater Than')
        set(handles.power_constraint_minmax_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.power_constraint_minmax_toggle,'String','Less Than')
        set(handles.power_constraint_minmax_toggle,'BackgroundColor',[.76 .87 .78])        
    end    
    
    if handles.dE_minmax(1) == 1
        set(handles.dE_weight_minmax_toggle,'String','Maximize')
        set(handles.dE_weight_minmax_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.dE_weight_minmax_toggle,'String','Minimize')
        set(handles.dE_weight_minmax_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.dE_minmax(2) == 1
        set(handles.dE_constraint_minmax_toggle,'String','Greater Than')
        set(handles.dE_constraint_minmax_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.dE_constraint_minmax_toggle,'String','Less Than')
        set(handles.dE_constraint_minmax_toggle,'BackgroundColor',[.76 .87 .78])        
    end
    
    if handles.lux_minmax(2) == 1
        set(handles.lux_constraint_minmax_toggle,'String','Greater Than')
        set(handles.lux_constraint_minmax_toggle,'BackgroundColor',[.73 .83 .96])
    else
        set(handles.lux_constraint_minmax_toggle,'String','Less Than')
        set(handles.lux_constraint_minmax_toggle,'BackgroundColor',[.76 .87 .78])        
    end      
    
    LED_state_text={' Off' ' On' ' Fixed'};
    
    if size(handles.alpha,2) >= 1+handles.LED_pagenum*5
        set(handles.LED1_toggle,'Visible','on')
        set(handles.LED1_text,'Visible','on')
        set(handles.LED1_slider,'Visible','on')
        set(handles.lux1_edit,'Visible','on');
        set(handles.N1_edit,'Visible','on');
        set(handles.power1_edit,'Visible','on');
        
        set(handles.LED1_text,'string',num2str(handles.alpha(1+handles.LED_pagenum*5)));
        set(handles.LED1_slider,'value',handles.alpha(1+handles.LED_pagenum*5));

        set(handles.lux1_edit,'string',num2str(handles.LED_lux(1+handles.LED_pagenum*5)));
        set(handles.N1_edit,'string',num2str(handles.LED_N(1+handles.LED_pagenum*5)));
        set(handles.power1_edit,'string',num2str(handles.LED_power(1+handles.LED_pagenum*5)));

        set(handles.LED1_toggle,'String',strcat(num2str(1+handles.LED_pagenum*5),LED_state_text(handles.LED_state(1+handles.LED_pagenum*5)+1)));
        
        if handles.plot_color_toggle==1;
            set(handles.LED1_slider,'Enable','off')
        else
            set(handles.LED1_slider,'Enable','on')
        end
        
    else
        set(handles.LED1_toggle,'Visible','off')
        set(handles.LED1_text,'Visible','off')
        set(handles.LED1_slider,'Visible','off')
        set(handles.lux1_edit,'Visible','off');
        set(handles.N1_edit,'Visible','off');
        set(handles.power1_edit,'Visible','off');
    end
    
    if size(handles.alpha,2) >= 2+handles.LED_pagenum*5
        set(handles.LED2_toggle,'Visible','on')
        set(handles.LED2_text,'Visible','on')
        set(handles.LED2_slider,'Visible','on')
        set(handles.lux2_edit,'Visible','on');
        set(handles.N2_edit,'Visible','on');
        set(handles.power2_edit,'Visible','on');
        
        set(handles.LED2_text,'string',num2str(handles.alpha(2+handles.LED_pagenum*5)));
        set(handles.LED2_slider,'value',handles.alpha(2+handles.LED_pagenum*5));
        set(handles.power2_edit,'string',num2str(handles.LED_power(2+handles.LED_pagenum*5)));

        set(handles.lux2_edit,'string',num2str(handles.LED_lux(2+handles.LED_pagenum*5)));
        set(handles.N2_edit,'string',num2str(handles.LED_N(2+handles.LED_pagenum*5)));        
        
        set(handles.LED2_toggle,'String',strcat(num2str(2+handles.LED_pagenum*5),LED_state_text(handles.LED_state(2+handles.LED_pagenum*5)+1)));
        
        if handles.plot_color_toggle==1;
            set(handles.LED2_slider,'Enable','off')
        else
            set(handles.LED2_slider,'Enable','on')
        end
        
    else
        set(handles.LED2_toggle,'Visible','off')
        set(handles.LED2_text,'Visible','off')
        set(handles.LED2_slider,'Visible','off')
        set(handles.lux2_edit,'Visible','off');
        set(handles.N2_edit,'Visible','off');
        set(handles.power2_edit,'Visible','off');
    end 
    
    if size(handles.alpha,2) >= 3+handles.LED_pagenum*5
        set(handles.LED3_toggle,'Visible','on')
        set(handles.LED3_text,'Visible','on')
        set(handles.LED3_slider,'Visible','on')
        set(handles.lux3_edit,'Visible','on');
        set(handles.N3_edit,'Visible','on');
        set(handles.power3_edit,'Visible','on');
        
        set(handles.LED3_text,'string',num2str(handles.alpha(3+handles.LED_pagenum*5)));
        set(handles.LED3_slider,'value',handles.alpha(3+handles.LED_pagenum*5));
        
        set(handles.lux3_edit,'string',num2str(handles.LED_lux(3+handles.LED_pagenum*5)));
        set(handles.N3_edit,'string',num2str(handles.LED_N(3+handles.LED_pagenum*5)));
        set(handles.power3_edit,'string',num2str(handles.LED_power(3+handles.LED_pagenum*5)));
        
        set(handles.LED3_toggle,'String',strcat(num2str(3+handles.LED_pagenum*5),LED_state_text(handles.LED_state(3+handles.LED_pagenum*5)+1)));
        
        if handles.plot_color_toggle==1;
            set(handles.LED3_slider,'Enable','off')
        else
            set(handles.LED3_slider,'Enable','on')    
        end
    else
        set(handles.LED3_toggle,'Visible','off')
        set(handles.LED3_text,'Visible','off')
        set(handles.LED3_slider,'Visible','off')
        set(handles.lux3_edit,'Visible','off');
        set(handles.N3_edit,'Visible','off');
        set(handles.power3_edit,'Visible','off');
    end    
    
    if size(handles.alpha,2) >= 4+handles.LED_pagenum*5
        set(handles.LED4_toggle,'Visible','on')
        set(handles.LED4_text,'Visible','on')
        set(handles.LED4_slider,'Visible','on')
        set(handles.lux4_edit,'Visible','on');
        set(handles.N4_edit,'Visible','on');
        set(handles.power4_edit,'Visible','on');
        
        set(handles.LED4_text,'string',num2str(handles.alpha(4+handles.LED_pagenum*5)));
        set(handles.LED4_slider,'value',handles.alpha(4+handles.LED_pagenum*5));
        
        set(handles.lux4_edit,'string',num2str(handles.LED_lux(4+handles.LED_pagenum*5)));
        set(handles.N4_edit,'string',num2str(handles.LED_N(4+handles.LED_pagenum*5)));
        set(handles.power4_edit,'string',num2str(handles.LED_power(4+handles.LED_pagenum*5)));
        
        set(handles.LED4_toggle,'String',strcat(num2str(4+handles.LED_pagenum*5),LED_state_text(handles.LED_state(4+handles.LED_pagenum*5)+1)));        

        if handles.plot_color_toggle==1;
            set(handles.LED4_slider,'Enable','off')
        else
            set(handles.LED4_slider,'Enable','on')    
        end
    else
        set(handles.LED4_toggle,'Visible','off')
        set(handles.LED4_text,'Visible','off')
        set(handles.LED4_slider,'Visible','off')
        set(handles.lux4_edit,'Visible','off');
        set(handles.N4_edit,'Visible','off');
        set(handles.power4_edit,'Visible','off');
    end  
    
    if size(handles.alpha,2) >= 5+handles.LED_pagenum*5
        set(handles.LED5_toggle,'Visible','on')
        set(handles.LED5_text,'Visible','on')
        set(handles.LED5_slider,'Visible','on')
        set(handles.lux5_edit,'Visible','on');
        set(handles.N5_edit,'Visible','on');
        set(handles.power5_edit,'Visible','on');
        
        set(handles.LED5_text,'string',num2str(handles.alpha(5+handles.LED_pagenum*5)));
        set(handles.LED5_slider,'value',handles.alpha(5+handles.LED_pagenum*5));
        
        set(handles.lux5_edit,'string',num2str(handles.LED_lux(5+handles.LED_pagenum*5)));
        set(handles.N5_edit,'string',num2str(handles.LED_N(5+handles.LED_pagenum*5)));
        set(handles.power5_edit,'string',num2str(handles.LED_power(5+handles.LED_pagenum*5)));
        
        set(handles.LED5_toggle,'String',strcat(num2str(5+handles.LED_pagenum*5),LED_state_text(handles.LED_state(5+handles.LED_pagenum*5)+1)));

        if handles.plot_color_toggle==1;
            set(handles.LED5_slider,'Enable','off')
        else
            set(handles.LED5_slider,'Enable','on')    
        end
    else
        set(handles.LED5_toggle,'Visible','off')
        set(handles.LED5_text,'Visible','off')
        set(handles.LED5_slider,'Visible','off')
        set(handles.lux5_edit,'Visible','off');
        set(handles.N5_edit,'Visible','off');
        set(handles.power5_edit,'Visible','off');
    end
end