function [handles]=replot_color_space(hObject,eventdata,handles)
if strcmp(handles.CIE_space,'CIE 1931 xy')==1
    set(handles.xyY_plot,'Visible','On')
    set(handles.LUV_plot,'Visible','Off')

    axes(handles.xyY_plot)

     cla reset
     hold on    

    imagesc([0 .8],[0 .9],handles.xyY_bg)
    xlim([0 .8])
    ylim([0 .9])
    scatter(handles.x(1),handles.y(1),70,'k','fill');
    scatter(handles.x(2),handles.y(2),70,'k','v','fill');
 
    if size(handles.alpha(handles.LED_state >= 1),2) >= 1
        plot(handles.LED_x,handles.LED_y,'ko')
        if size(handles.alpha(handles.LED_state >= 1),2) >= 3
            tempx=handles.LED_x(handles.LED_state >= 1);
            tempy=handles.LED_y(handles.LED_state >= 1);
            gamut_area=convhull(tempx,tempy);
            plot(tempx(gamut_area),tempy(gamut_area),'k-o')
        else
            plot(handles.LED_x(handles.LED_state >= 1),handles.LED_y(handles.LED_state >= 1),'k-o')
        end
    end
    if isempty(handles.match_active)==0
        [ellipse_x,ellipse_y,~,~,~] = macAdamEllipse(handles.x(1),handles.y(1),1,handles.g11,handles.g22,handles.g12);
        plot(ellipse_x,ellipse_y,'k')
        [ellipse_x,ellipse_y,~,~,~] = macAdamEllipse(handles.x(1),handles.y(1),2,handles.g11,handles.g22,handles.g12);
        plot(ellipse_x,ellipse_y,'k')
        [ellipse_x,ellipse_y,~,~,~] = macAdamEllipse(handles.x(1),handles.y(1),3,handles.g11,handles.g22,handles.g12);
        plot(ellipse_x,ellipse_y,'k')
    end

    legend('Ideal','Generated')
    xlabel('x')
    ylabel('y')  
    
    hold off

end
if strcmp(handles.CIE_space,'CIE 1976 UCS')==1
    set(handles.xyY_plot,'Visible','Off')
    set(handles.LUV_plot,'Visible','On')

    axes(handles.LUV_plot)

    cla reset
    hold on
    imagesc([0 .63],[0 .6],handles.LUV_bg)
    xlim([0 .63])
    ylim([0 .6])
    scatter(handles.LUV_u_prime(1),handles.LUV_v_prime(1),70,'k','fill')
    scatter(handles.LUV_u_prime(2),handles.LUV_v_prime(2),70,'k','v','fill')
    
    if size(handles.alpha(handles.LED_state >= 1),2) >= 1
        plot(handles.LED_LUV_u_prime,handles.LED_LUV_v_prime,'ko')
        if size(handles.alpha(handles.LED_state >= 1),2) >= 3
            tempu=handles.LED_LUV_u_prime(handles.LED_state >= 1);
            tempv=handles.LED_LUV_v_prime(handles.LED_state >=1);
            gamut_area=convhull(tempu,tempv);
            plot(tempu(gamut_area),tempv(gamut_area),'k-o')
        else
            plot(handles.LED_LUV_u_prime(handles.LED_state >= 1),handles.LED_LUV_v_prime(handles.LED_state >= 1),'k-o')        
        end
    end
    if isempty(handles.match_active)==0
        [ellipse_x,ellipse_y,~,~,~] = macAdamEllipse(handles.x(1),handles.y(1),1,handles.g11,handles.g22,handles.g12);
        ellipse_uprime=4.*ellipse_x./(-2.*ellipse_x+12.*ellipse_y+3);
        ellipse_vprime=9.*ellipse_y./(-2.*ellipse_x+12.*ellipse_y+3);
        plot(ellipse_uprime,ellipse_vprime,'k')

        [ellipse_x,ellipse_y,~,~,~] = macAdamEllipse(handles.x(1),handles.y(1),2,handles.g11,handles.g22,handles.g12);
        ellipse_uprime=4.*ellipse_x./(-2.*ellipse_x+12.*ellipse_y+3);
        ellipse_vprime=9.*ellipse_y./(-2.*ellipse_x+12.*ellipse_y+3);
        plot(ellipse_uprime,ellipse_vprime,'k')
        
        [ellipse_x,ellipse_y,~,~,~] = macAdamEllipse(handles.x(1),handles.y(1),3,handles.g11,handles.g22,handles.g12);
        ellipse_uprime=4.*ellipse_x./(-2.*ellipse_x+12.*ellipse_y+3);
        ellipse_vprime=9.*ellipse_y./(-2.*ellipse_x+12.*ellipse_y+3);
        plot(ellipse_uprime,ellipse_vprime,'k')
    end    
      
    legend('Ideal','Generated')
    xlabel('u''')
    ylabel('v''')
    hold off
end
    
axes(handles.RGB_plot)
cla reset

color_square=ones(1,2,3);
if handles.R(1) <= 255 && handles.R(1) >= 0 ...
&& handles.G(1) <= 255 && handles.G(1) >= 0 ...
&& handles.B(1) <= 255 && handles.B(1) >= 0 
    color_square(:,1,1)=handles.R(1)/255;
    color_square(:,1,2)=handles.G(1)/255;
    color_square(:,1,3)=handles.B(1)/255;

end
if handles.R(2) <= 255 && handles.R(2) >= 0 ...
&& handles.G(2) <= 255 && handles.G(2) >= 0 ...
&& handles.B(2) <= 255 && handles.B(2) >= 0     
    color_square(:,2,1)=handles.R(2)/255;
    color_square(:,2,2)=handles.G(2)/255;
    color_square(:,2,3)=handles.B(2)/255;
end
imagesc([0 1],[0 1],color_square)

