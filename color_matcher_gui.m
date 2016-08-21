function varargout = color_matcher_gui(varargin)
% COLOR_MATCHER_GUI MATLAB code for color_matcher_gui.fig
%      COLOR_MATCHER_GUI, by itself, creates a new COLOR_MATCHER_GUI or raises the existing
%      singleton*.
%
%      H = COLOR_MATCHER_GUI returns the handle to a new COLOR_MATCHER_GUI or the handle to
%      the existing singleton*.
%
%      COLOR_MATCHER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLOR_MATCHER_GUI.M with the given input arguments.
%
%      COLOR_MATCHER_GUI('Property','Value',...) creates a new COLOR_MATCHER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before color_matcher_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to color_matcher_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help color_matcher_gui

% Last Modified by GUIDE v2.5 13-May-2015 15:17:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @color_matcher_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @color_matcher_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before color_matcher_gui is made visible.
function color_matcher_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to color_matcher_gui (see VARARGIN)
% Choose default command line output for color_matcher_gui

addpath('GUI_Functions');
addpath('ColorScience_Functions');
addpath('Optimization_Functions');
addpath('Extra_Functions');

set(handles.tab1_button,'BackgroundColor',[.8 .88 .97])

handles.optimize_x=[];

%set up graphics for CIE Color spaces
handles.xyY_bg=imread('RequiredData/xyYaxes_fullcolor.png');
handles.xyY_bg=flipdim(handles.xyY_bg,1);

handles.LUV_bg=imread('RequiredData/LUVaxes.png');
handles.LUV_bg=flipdim(handles.LUV_bg,1);

handles.slider_holding=0;

%Set up LED/Ideal control variables
%alpha refers to the LED multipliers
%handles.ideal_multiplier=[];
handles.output = hObject;
handles.LED_state=[];
handles.alpha=[];
handles.generated=[];
handles.match_active=[];
handles.LED_lux=[];
handles.LED_power=[];
handles.Ideal_lux=[];
handles.match_data=[];
handles.LED_data=[];
handles.Wavelength=380:1:830;
handles.max_alpha=1;
handles.normalize=0;
handles.LED_N=[];

handles.current_unit_type='Spectral Irradiance (W*m^-2*nm^-1)';

handles.daylight_index=0;
handles.daylight_toggle=0;

handles.plot_color_toggle=0;
handles.plot_legend=0;

%Set up page system
handles.LED_pages=0;
handles.LED_pagenum=0;
set(handles.prev_page,'Enable','off') 
set(handles.next_page,'Enable','off')

%set up popup menus and other lists
options={'CIE 1931 xy';
         'CIE 1976 UCS'};
set(handles.CIE_popup,'string',options);
handles.CIE_space='CIE 1931 xy';
     
temp=[''];
handles.matching_spectrum_names=cellstr(temp);
handles.clean=1;

options={'Least-Squares Spectrum Match';
    'Least-Squares RGB Match'};
set(handles.optimize_simple_options,'string',options);
handles.optimize_simple_type='Least-Squares Spectrum Match';

options={
    'Maximized CRI with JND constraint';
    'Minimized LUV dE with CRI and power constraints'};
set(handles.optimize_complex_options,'string',options);
handles.optimize_complex_type='Maximized CRI with JND constraint';

% options={'Maximized CRI with JND constraint, Full CCT Range';
%           'Plot Efficiency Vector';
%           'Max CRI With Constraints';
%           'CRI with Increasing Power Weight';
%           'JND with Increasing Power Weight'};
% 
% set(handles.optimize_capabilities_options,'string',options);
% handles.optimize_capabilities_type='Maximized CRI with JND constraint, Full CCT Range';

options={
    'Individual LED Spectra';
    'Generated and Ideal Spectra'};
set(handles.spectrum_plot_dropdown,'string',options);
handles.spectrum_plot_type='Individual LED Spectra';

options={
    '3000k-7000k CCT ideal blackbody curves, 100k increments'};
set(handles.simulation_ideal_dropdown,'string',options);
handles.simulation_ideal_type='3000k-7000k CCT ideal blackbody curves, 100k increments';

% options={
%     'Spectral Power (W/m)   ';
%     'Unknown (Lux available)'};
% set(handles.units_popup,'string',options);
% handles.unit_type='Spectral Power (W/m)';
% handles.current_unit_type='Spectral Power (W/m)';

%Import and set up required data for calculations
temp=importdata('RequiredData/illuminants_xy_2deg.txt');
handles.illuminant_data_xy_2deg=temp.data;
handles.illuminant_names=temp.rowheaders;

handles.standard_illuminant=[0.44757 0.40745];
set(handles.reference_illuminant_popup,'string',handles.illuminant_names);

temp=importdata('RequiredData/illuminants_xy_10deg.txt');
handles.illuminant_data_xy_10deg=temp.data;

load RequiredData/DSPD.mat
handles.DSPD=DSPD;

load RequiredData/CIETCS1nm.mat
handles.CIETCS1nm=CIETCS1nm;

% CIETCS5nm=importdata('RequiredData/CIETCS5nm.txt');
% handles.CIETCS1nm=CIETCS5nm;

temp=handles.Wavelength';
for i=2:size(handles.DSPD,2)
    data=spline(handles.DSPD(:,1),handles.DSPD(:,i),handles.Wavelength);
    data(handles.Wavelength < min(handles.DSPD(:,1)))=0;
    data(handles.Wavelength > max(handles.DSPD(:,1)))=0;
    temp=[temp data'];
end
handles.DSPD=temp;

temp=handles.Wavelength';
for i=2:size(handles.CIETCS1nm,2)
    data=spline(handles.CIETCS1nm(:,1),handles.CIETCS1nm(:,i),handles.Wavelength);
    data(handles.Wavelength < min(handles.CIETCS1nm(:,1)))=0;
    data(handles.Wavelength > max(handles.CIETCS1nm(:,1)))=0;
    temp=[temp data'];
end
handles.CIETCS1nm=temp;

%3 columns: kelvin, u, v with 1 kelvin resolution. Credit pspectro 
load RequiredData/uvbbCCT_corr.mat
handles.uvbbCCT=uvbbCCT_corr;
%handles.uvbbCCT=importdata('RequiredData/uvbbCCT.txt');

load RequiredData/vl1924e1nm.mat
efficiency_fun=vl1924e1nm;

handles.vl1924e1nm=spline(efficiency_fun(:,1),efficiency_fun(:,2),handles.Wavelength);
handles.vl1924e1nm(handles.Wavelength < min(efficiency_fun(:,1)))=0;
handles.vl1924e1nm(handles.Wavelength > max(efficiency_fun(:,1)))=0;

%http://www.cvrl.org/cmfs.htm
%cmf=importdata('RequiredData/xyz_cmf_2deg.txt');
%load RequiredData/cie1931xyz1nm.mat

cmf=importdata('RequiredData/cmf_1nm_xyz2deg_xyz10deg.txt');
cmf=cmf(:,[1 2:4]);

xcmf=spline(cmf(:,1),cmf(:,2),handles.Wavelength);
xcmf(handles.Wavelength < min(cmf(:,1)))=0;
xcmf(handles.Wavelength > max(cmf(:,1)))=0;

ycmf=spline(cmf(:,1),cmf(:,3),handles.Wavelength);
ycmf(handles.Wavelength < min(cmf(:,1)))=0;
ycmf(handles.Wavelength > max(cmf(:,1)))=0;

zcmf=spline(cmf(:,1),cmf(:,4),handles.Wavelength);
zcmf(handles.Wavelength < min(cmf(:,1)))=0;
zcmf(handles.Wavelength > max(cmf(:,1)))=0;

handles.xcmf=xcmf;
handles.ycmf=ycmf;
handles.zcmf=zcmf;

% nrefspd = get_nrefspd(1200,handles.DSPD,handles.Wavelength,560);
% save('nref.mat','nrefspd')

%first=weight, second =constraint
%1=maximize/greater than, 0=minimize/less than
handles.CRI_minmax=[1 1];
handles.power_minmax=[0 0];
handles.dE_minmax=[0 0];
handles.lux_minmax=[1 1];

%Set up color space data variables
%[ideal generated]
handles.cct=[0 0];

handles.X=[0 0];
handles.Y=[0 0];
handles.Z=[0 0];

handles.R=[0 0];
handles.G=[0 0];
handles.B=[0 0];

%for n LEDs imported, this is a 3xn matrix of the RGBs of each individual
%LED. When multiplied by a vector of the LED multipliers, it should give
%the RGB of the generated function
handles.RGB_LEDs=[];

handles.RGB_brightness_mod=[0 0];

handles.RGB_mat=[ 2.0413690 -0.5649464 -0.3446944;
                 -0.9692660  1.8760108  0.0415560;
                  0.0134474 -0.1183897  1.0154096];

handles.x=[0 0];
handles.y=[0 0];
handles.z=[0 0];

xi = 0.00:0.005:0.75;
yi = 0.00:0.005:0.85;
[handles.MacAdamsXI,handles.MacAdamsYI] = meshgrid(xi,yi);
handles.ZIg11 = importdata('RequiredData/ZIg11.txt');
handles.ZItwog12 = importdata('RequiredData/ZItwog12.txt');
handles.ZIg22 = importdata('RequiredData/ZIg22.txt');

handles.g11 = interp2(handles.MacAdamsXI,handles.MacAdamsYI,handles.ZIg11,handles.x(1),handles.y(1),'cubic')*10^4;
twog12 = interp2(handles.MacAdamsXI,handles.MacAdamsYI,handles.ZItwog12,handles.x(1),handles.y(1),'cubic')*10^4;
handles.g22 = interp2(handles.MacAdamsXI,handles.MacAdamsYI,handles.ZIg22,handles.x(1),handles.y(1),'cubic')*10^4;
handles.g12 = twog12/2;    

handles.LUV_u_prime=[0 0];
handles.LUV_v_prime=[0 0];
handles.LUV_u=[0 0];
handles.LUV_v=[0 0];
handles.LUV_L=[0 0];

handles.UVW_u=[0 0];
handles.UVW_v=[0 0];

handles.W=[0 0];

handles.Lab_L=[0 0];
handles.a=[0 0];
handles.b=[0 0];

handles.xy_dE=-1;
handles.LUV_dE=-1;
handles.uvChroma_dE=-1;
handles.dE76=-1;
handles.dE94=-1;
handles.dE00=-1;
handles.JND=-1;

handles.power=[0 0];
handles.LER=[0 0];
handles.CRI=[0 0];
handles.CQS=[0 0];
handles.GAI=[0 0];

handles.CRI_goal=1;
handles.CRI_weight=1;

handles.power=0;
handles.lux=0;
handles.power_goal=1;
handles.power_weight=1;

% {CRI_weight power_weight dE_weight lux; CRI_constraint power_constraint dE_constraint lux}
%handles.optimizer_states={'On' 'On' 'On' 'Off'; 'On' 'On' 'On' 'On'};

handles.simulation_trials=1;
handles.simulation_attempts=1;

handles.simulation_activated=0;

handles.simulation_CRI_states={'Off' 'Off'};
handles.simulation_power_states={'Off' 'Off'};
handles.simulation_dE_states={'Off' 'Off'};
handles.simulation_lux_states={'Off' 'Off'};

handles.simulation_CRI_increments=[1 1];
handles.simulation_power_increments=[1 1];
handles.simulation_dE_increments=[1 1];
handles.simulation_lux_increments=[1 1];
handles.simulation_CRI_direction=[1 1];
handles.simulation_power_direction=[1 1];
handles.simulation_dE_direction=[1 1];
handles.simulation_lux_direction=[1 1];

handles.CRI_optimizer_states={'On' 'On'};
handles.power_optimizer_states={'On' 'On'};
handles.dE_optimizer_states={'On' 'On'};
handles.lux_optimizer_states={'Off' 'On'};

handles.choose_NLEDs=0;
handles.minimize_NLEDs=0;
handles.choose_NLEDs_value=1;

handles.dE_weight=1;
handles.dE_goal=1;

handles.lux_weight=1;
handles.lux_goal=1;

handles.optimize_dE_type='JND';
handles.optimize_CRI_type='CRI';
handles.optimize_power_type='Power';
%stats for the individual LEDs
handles.LED_cct=[];

handles.LED_X=[];
handles.LED_Y=[];
handles.LED_Z=[];

handles.LED_R=[];
handles.LED_G=[];
handles.LED_B=[];

handles.LED_RGB_brightness_mod=[];

handles.LED_x=[];
handles.LED_y=[];
handles.LED_z=[];

handles.LED_LUV_u_prime=[];
handles.LED_LUV_v_prime=[];
handles.LED_LUV_u=[];
handles.LED_LUV_v=[];
handles.LED_LUV_L=[];

handles.LED_UVW_u=[];
handles.LED_UVW_v=[];

handles.LED_W=[];

handles.LED_Lab_L=[];
handles.LED_a=[];
handles.LED_b=[];

handles.LED_CRI=[];
handles.LED_power=[];
handles.LED_CQS=[];

%optimization variables
handles.iterations=0;

%initialize button states
set(handles.optimize_complex,'Enable','off')
set(handles.optimize_simple,'Enable','off')
set(handles.optimize_capabilities,'Enable','off') 
set(handles.matching_spectrum_popup,'Enable','off')
set(handles.ideal_lux_edit,'Enable','off')

set(handles.LED1_toggle,'Value',1);
set(handles.LED2_toggle,'Value',1);
set(handles.LED3_toggle,'Value',1);
set(handles.LED4_toggle,'Value',1);
set(handles.LED5_toggle,'Value',1);
set(handles.range1,'Value',1);

%set(handles.range1,'Visible','off')
%set(handles.range2,'Visible','off')

set(handles.LED1_toggle,'Visible','off')
set(handles.LED1_text,'Visible','off')
set(handles.LED1_slider,'Visible','off')

set(handles.LED2_toggle,'Visible','off')
set(handles.LED2_text,'Visible','off')
set(handles.LED2_slider,'Visible','off')

set(handles.LED3_toggle,'Visible','off')
set(handles.LED3_text,'Visible','off')
set(handles.LED3_slider,'Visible','off')

set(handles.LED4_toggle,'Visible','off')
set(handles.LED4_text,'Visible','off')
set(handles.LED4_slider,'Visible','off')

set(handles.LED5_toggle,'Visible','off')
set(handles.LED5_text,'Visible','off')
set(handles.LED5_slider,'Visible','off')

% Set the colors indicating a selected/unselected tab
% handles.unselectedTabColor=get(handles.tab1text,'BackgroundColor');
% handles.selectedTabColor=handles.unselectedTabColor-0.1;

% set(handles.tab1text,'Visible','off') 
% set(handles.tab2text,'Visible','off') 
% set(handles.tab3text,'Visible','off') 
% set(handles.tab4text,'Visible','off') 
% set(handles.tab5text,'Visible','off') 
% set(handles.tab6text,'Visible','off') 
% 
% % Set units to normalize for easier handling
% set(handles.tab1text,'Units','normalized')
% set(handles.tab2text,'Units','normalized')
% set(handles.tab3text,'Units','normalized')
% set(handles.tab4text,'Units','normalized')
% set(handles.tab5text,'Units','normalized')
% set(handles.tab6text,'Units','normalized')
% 
% set(handles.tab1Panel,'Units','normalized')
% set(handles.tab3Panel,'Units','normalized')
% set(handles.tab3Panel,'Units','normalized')
% set(handles.tab4Panel,'Units','normalized')
% set(handles.tab5Panel,'Units','normalized')
% set(handles.tab6Panel,'Units','normalized')
% 
% % Tab 1
% pos1=get(handles.tab1text,'Position');
% handles.a1=axes('Units','normalized',...
%                 'Box','on',...
%                 'XTick',[],...
%                 'YTick',[],...
%                 'Color',handles.selectedTabColor,...
%                 'Position',[pos1(1) pos1(2) pos1(3) pos1(4)+0.01],...
%                 'ButtonDownFcn','color_matcher_gui(''a1bd'',gcbo,[],guidata(gcbo))');
% handles.t1=text('String','Spectrum Setup',...
%                 'Units','normalized',...
%                 'Position',[(pos1(3)-pos1(1))/2,pos1(2)/2+pos1(4)],...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','middle',...
%                 'Margin',0.001,...
%                 'FontSize',8,...
%                 'Backgroundcolor',handles.selectedTabColor,...
%                 'ButtonDownFcn','color_matcher_gui(''t1bd'',gcbo,[],guidata(gcbo))');
% 
% % Tab 2
% pos2=get(handles.tab2text,'Position');
% pos2(1)=pos1(1)+pos1(3);
% handles.a2=axes('Units','normalized',...
%                 'Box','on',...
%                 'XTick',[],...
%                 'YTick',[],...
%                 'Color',handles.unselectedTabColor,...
%                 'Position',[pos2(1) pos2(2) pos2(3) pos2(4)+0.01],...
%                 'ButtonDownFcn','color_matcher_gui(''a2bd'',gcbo,[],guidata(gcbo))');
% handles.t2=text('String','Color Spaces',...
%                 'Units','normalized',...
%                 'Position',[pos2(3)/2,pos2(2)/2+pos2(4)],...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','middle',...
%                 'Margin',0.001,...
%                 'FontSize',8,...
%                 'Backgroundcolor',handles.unselectedTabColor,...
%                 'ButtonDownFcn','color_matcher_gui(''t2bd'',gcbo,[],guidata(gcbo))');
%            
% % Tab 3 
% pos3=get(handles.tab3text,'Position');
% pos3(1)=pos2(1)+pos2(3);
% handles.a3=axes('Units','normalized',...
%                 'Box','on',...
%                 'XTick',[],...
%                 'YTick',[],...
%                 'Color',handles.unselectedTabColor,...
%                 'Position',[pos3(1) pos3(2) pos3(3) pos3(4)+0.01],...
%                 'ButtonDownFcn','color_matcher_gui(''a3bd'',gcbo,[],guidata(gcbo))');
% handles.t3=text('String','tab3',...
%                 'Units','normalized',...
%                 'Position',[pos3(3)/2,pos3(2)/2+pos3(4)],...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','middle',...
%                 'Margin',0.001,...
%                 'FontSize',8,...
%                 'Backgroundcolor',handles.unselectedTabColor,...
%                 'ButtonDownFcn','color_matcher_gui(''t3bd'',gcbo,[],guidata(gcbo))');
% 
% % Tab 4 
% pos4=get(handles.tab4text,'Position');
% pos4(1)=pos3(1)+pos3(3);
% handles.a4=axes('Units','normalized',...
%                 'Box','on',...
%                 'XTick',[],...
%                 'YTick',[],...
%                 'Color',handles.unselectedTabColor,...
%                 'Position',[pos4(1) pos4(2) pos4(3) pos4(4)+0.01],...
%                 'ButtonDownFcn','color_matcher_gui(''a4bd'',gcbo,[],guidata(gcbo))');
% handles.t4=text('String','Help',...
%                 'Units','normalized',...
%                 'Position',[pos4(3)/2,pos4(2)/2+pos4(4)],...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','middle',...
%                 'Margin',0.001,...
%                 'FontSize',8,...
%                 'Backgroundcolor',handles.unselectedTabColor,...
%                 'ButtonDownFcn','color_matcher_gui(''t4bd'',gcbo,[],guidata(gcbo))');            
% 
% % Tab 5 
% pos5=get(handles.tab5text,'Position');
% pos5(1)=pos4(1)+pos4(3);
% handles.a5=axes('Units','normalized',...
%                 'Box','on',...
%                 'XTick',[],...
%                 'YTick',[],...
%                 'Color',handles.unselectedTabColor,...
%                 'Position',[pos5(1) pos5(2) pos5(3) pos5(4)+0.01],...
%                 'ButtonDownFcn','color_matcher_gui(''a5bd'',gcbo,[],guidata(gcbo))');
% handles.t5=text('String','tab5',...
%                 'Units','normalized',...
%                 'Position',[pos5(3)/2,pos5(2)/2+pos5(4)],...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','middle',...
%                 'Margin',0.001,...
%                 'FontSize',8,...
%                 'Backgroundcolor',handles.unselectedTabColor,...
%                 'ButtonDownFcn','color_matcher_gui(''t5bd'',gcbo,[],guidata(gcbo))');            
% 
% % Tab 6 
% pos6=get(handles.tab6text,'Position');
% pos6(1)=pos5(1)+pos5(3);
% handles.a6=axes('Units','normalized',...
%                 'Box','on',...
%                 'XTick',[],...
%                 'YTick',[],...
%                 'Color',handles.unselectedTabColor,...
%                 'Position',[pos6(1) pos6(2) pos6(3) pos6(4)+0.01],...
%                 'ButtonDownFcn','color_matcher_gui(''a6bd'',gcbo,[],guidata(gcbo))');
% handles.t6=text('String','tab6',...
%                 'Units','normalized',...
%                 'Position',[pos6(3)/2,pos6(2)/2+pos6(4)],...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','middle',...
%                 'Margin',0.001,...
%                 'FontSize',8,...
%                 'Backgroundcolor',handles.unselectedTabColor,...
%                 'ButtonDownFcn','color_matcher_gui(''t6bd'',gcbo,[],guidata(gcbo))');            
%             
% % Manage panels (place them in the correct position and manage visibilities)
% pan1pos=get(handles.tab1Panel,'Position');
% set(handles.tab3Panel,'Position',pan1pos)
% set(handles.tab3Panel,'Position',pan1pos)
% set(handles.tab4Panel,'Position',pan1pos)
% set(handles.tab5Panel,'Position',pan1pos)
% set(handles.tab6Panel,'Position',pan1pos)
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Update handles structure
handles=refresh(hObject,eventdata,handles);
handles=refresh_color_space(hObject,eventdata,handles);
handles=replot_color_space(hObject,eventdata,handles);

guidata(hObject, handles);

% UIWAIT makes color_matcher_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = color_matcher_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% % Text object 1 callback (tab 1)
% function t1bd(hObject,eventdata,handles)
% 
% set(hObject,'BackgroundColor',handles.selectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.a1,'Color',handles.selectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.tab1Panel,'Visible','on')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% 
% handles=refresh(hObject,eventdata,handles);
% handles=replot(hObject,eventdata,handles);
% guidata(hObject, handles);
% 
% end
% 
% % Text object 2 callback (tab 2)
% function t2bd(hObject,eventdata,handles)
% 
% set(hObject,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.a2,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.tab3Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% 
% handles=refresh(hObject,eventdata,handles);
% handles=refresh_color_space(hObject,eventdata,handles);
% handles=replot_color_space(hObject,eventdata,handles);
% guidata(hObject, handles);
% 
% end
% % Text object 3 callback (tab 3)
% function t3bd(hObject,eventdata,handles)
% 
% set(hObject,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.a3,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.tab3Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% end
% 
% % Text object 4 callback (tab 4)
% function t4bd(hObject,eventdata,handles)
% 
% set(hObject,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.a4,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.tab4Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% 
% end
% 
% % Text object 5 callback (tab 5)
% function t5bd(hObject,eventdata,handles)
% 
% set(hObject,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.a5,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.tab5Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% 
% end
% 
% % Text object 6 callback (tab 6)
% function t6bd(hObject,eventdata,handles)
% 
% set(hObject,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.a6,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% 
% set(handles.tab6Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% end
% 
% % Axes object 1 callback (tab 1)
% function a1bd(hObject,eventdata,handles)
% 
% set(hObject,'Color',handles.selectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.t1,'BackgroundColor',handles.selectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.tab1Panel,'Visible','on')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% 
% end
% 
% % Axes object 2 callback (tab 2)
% function a2bd(hObject,eventdata,handles)
% 
% set(hObject,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.t2,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.tab3Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% 
% end
% 
% % Axes object 3 callback (tab 3)
% function a3bd(hObject,eventdata,handles)
% 
% set(hObject,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.t3,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.tab3Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% 
% end
% % Axes object 4 callback (tab 4)
% function a4bd(hObject,eventdata,handles)
% 
% set(hObject,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.t4,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.tab4Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% end
% % Axes object 5 callback (tab 5)
% function a5bd(hObject,eventdata,handles)
% 
% set(hObject,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a6,'Color',handles.unselectedTabColor)
% 
% set(handles.t5,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t6,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.tab5Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab6Panel,'Visible','off')
% end
% % Axes object 6 callback (tab 6)
% function a6bd(hObject,eventdata,handles)
% 
% set(hObject,'Color',handles.selectedTabColor)
% set(handles.a1,'Color',handles.unselectedTabColor)
% set(handles.a2,'Color',handles.unselectedTabColor)
% set(handles.a3,'Color',handles.unselectedTabColor)
% set(handles.a4,'Color',handles.unselectedTabColor)
% set(handles.a5,'Color',handles.unselectedTabColor)
% 
% set(handles.t6,'BackgroundColor',handles.selectedTabColor)
% set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
% set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
% 
% set(handles.tab6Panel,'Visible','on')
% set(handles.tab1Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab3Panel,'Visible','off')
% set(handles.tab4Panel,'Visible','off')
% set(handles.tab5Panel,'Visible','off')
% end
% --- Executes on button press in LED1_toggle.



function LED1_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LED1_toggle
if handles.LED_state(1+handles.LED_pagenum*5) < 2
    handles.LED_state(1+handles.LED_pagenum*5)=handles.LED_state(1+handles.LED_pagenum*5)+1;
else
    handles.LED_state(1+handles.LED_pagenum*5)=0;
end
% if get(hObject,'Value')==1
%     set(handles.LED1_slider,'Enable','on')
%     set(handles.LED1_text,'Enable','on')
% else
%     set(handles.LED1_slider,'Enable','off')  
%     set(handles.LED1_text,'Enable','off')    
% end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

function LED1_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LED1_text as text
%        str2double(get(hObject,'String')) returns contents of LED1_text as a double

handles.alpha(1+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end
% --- Executes during object creation, after setting all properties.
function LED1_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on slider movement.
function LED1_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.alpha(1+handles.LED_pagenum*5) ~= get(hObject,'Value')
    set(handles.LED1_slider,'Enable','off')
    drawnow

    handles.alpha(1+handles.LED_pagenum*5)=get(hObject,'Value');
    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    
    set(handles.LED1_slider,'Enable','on')

end
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function LED1_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end
% --- Executes on button press in import_LED_pushbutton.
function import_LED_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to import_LED_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Assumes the first column is wavelength and eqach subsequent column is an
%LED spectrum. Limited to 5 LEDs

%open file browser window
[filename, pathname]=uigetfile({'*.*';'*.txt';'*.m';'*.csv'});

%filename is a double (0) if cancel is slected or window closed
if ischar(filename)
    FileNameString=fullfile(pathname, filename); %Same as FullFileName
    InputData=importdata(FileNameString);

    if handles.daylight_toggle == 1
        if handles.daylight_index ~= 0
            %Separate lux data (if it is supposed to be there) from the rest of the
            %data. If it is meant to be there but isn't, output a formatting error
            %to the user and cancel the data import.     
            count=1;
            tempLux=0;
            if InputData(1,1)==0
                tempLux=InputData(1,2:end);
                prevLux=handles.LED_lux(handles.daylight_index);
          
                handles.LED_lux(handles.daylight_index)=tempLux-sum(handles.alpha.*handles.LED_lux)+sum(handles.alpha(handles.daylight_index)*prevLux);
                count=count+1;
            elseif InputData(2,1)==0
                tempLux=InputData(2,2:end);
                prevLux=handles.LED_lux(handles.daylight_index);
                handles.LED_lux(handles.daylight_index)=tempLux-sum(handles.alpha.*handles.LED_lux-handles.alpha(handles.daylight_index)*prevLux);
                count=count+1;
            else
                handles.LED_lux(handles.daylight_index)=100*ones(size(InputData,2));
            end

%             if InputData(1,1)==-1
%                 tempPower=InputData(1,2:end);
%                 prevPower=handles.LED_power(handles.daylight_index);
%                 handles.LED_power(handles.daylight_index)=tempPower-(sum(handles.alpha.*handles.LED_power)-handles.alpha(handles.daylight_index).*prevPower);
%                 count=count+1;
%             elseif InputData(2,1)==-1
%                 tempPower=InputData(2,2:end);
%                 prevPower=handles.LED_power(handles.daylight_index);
%                 handles.LED_power(handles.daylight_index)=tempPower-(sum(handles.alpha.*handles.LED_power)-handles.alpha(handles.daylight_index).*prevPower);
%                 count=count+1;
%             else
                handles.LED_power(handles.daylight_index)=0;
            %end

            InputData=InputData(count:end,:);

            tempWave=InputData(count:end,1);
            
            %spline the data to match the standardized wavelength range and
            %sampling frequency
            data=spline(tempWave,InputData(count:end,2),handles.Wavelength);
            data(handles.Wavelength < min(tempWave))=0;
            data(handles.Wavelength > max(tempWave))=0;

            %normalize data to 1
            data=(data-min(data)) ./ (max(data)-min(data));
            k=683;

            
            %correct normalization based on lux values
            coeff=tempLux/(k*sum(data(1,:).*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
            
            alpha_applied=ones(size(handles.Wavelength,2),size(handles.alpha,2))-1;
            for n=1:size(handles.alpha,2)
                if handles.LED_state(n)>=1 && n ~= handles.daylight_index             
                    alpha_applied(:,n)=handles.LED_data(:,n).*handles.alpha(n).*handles.LED_N(n);
                else
                    alpha_applied(:,n)=0;
                end
            end
            generated=sum(alpha_applied,2); 
            
            data=coeff*data - generated';            
            
%             %spline the data to match the standardized wavelength range and
%             %sampling frequency
%             k=683;
%             tempLux=InputData(1,2:end);
%             %disp('testing')
%             %disp(tempLux)
%             tempWave=InputData(2:end,1);
%             
%             data=spline(tempWave,InputData(2:end,2),handles.Wavelength);
%             data(handles.Wavelength < min(tempWave))=0;
%             data(handles.Wavelength > max(tempWave))=0;         
% 
%             coeff=tempLux/(k*sum(data(1,:).*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
%             data=coeff*data - handles.generated+handles.LED_data(:,handles.daylight_index);            

            
            
                %update control variables for appropriate number of LEDs
                handles.RGB_LEDs(:,handles.daylight_index)=zeros(3,1);
                handles.LED_state(handles.daylight_index)=2;
                handles.alpha(handles.daylight_index)=1;
                handles.LED_N(handles.daylight_index)=1;

                handles.current_unit_type='Spectral Irradiance (W*m^-2*nm^-1)';

                %add the processed data to the handle
                handles.LED_data(:,handles.daylight_index)=data';

                i=handles.daylight_index;
                spd=handles.LED_data(:,i)';

                [handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.LED_x(i),handles.LED_y(i),handles.LED_z(i)]...
                    =getXYZxyz(spd,handles.xcmf,handles.ycmf,handles.zcmf,handles.Wavelength);                  

                [handles.LED_R(i),handles.LED_G(i),handles.LED_B(i),handles.LED_RGB_brightness_mod(i)]...
                    =getRGB(handles.RGB_mat,handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i));

                [handles.LED_UVW_u(i),handles.LED_UVW_v(i),handles.LED_W(i)]...
                    =getUVW(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));   

                [handles.LED_LUV_L(i),handles.LED_LUV_u(i),handles.LED_LUV_v(i),handles.LED_LUV_u_prime(i),handles.LED_LUV_v_prime(i)]...
                    =getLUV_uprime_vprime(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));

                handles.LED_cct(i)=getCCT(handles.LED_x(i),handles.LED_y(i));

                nrefspd = get_nrefspd(handles.LED_cct(i),handles.DSPD,handles.Wavelength,560);
                cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
                [Ra,R] = get_cri1995(spd',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength);
                [CQS] = get_CQS(spd',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength,handles.LED_cct(i));
                handles.LED_CRI(i)=Ra;        
                handles.LED_CQS(i)=CQS;

                [handles.LED_Lab_L(i),handles.LED_a(i),handles.LED_b(i)]...
                    =getLab(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));
        else
            
            handles.daylight_index=size(handles.LED_data,2)+1;
            
            %Separate lux data (if it is supposed to be there) from the rest of the
            %data. If it is meant to be there but isn't, output a formatting error
            %to the user and cancel the data import.     
            count=1;
            tempLux=0;
            
            if InputData(1,1)==0
                tempLux=InputData(1,2:end);
                handles.LED_lux=[handles.LED_lux tempLux-sum(handles.alpha.*handles.LED_lux)];

                count=count+1;
            elseif InputData(2,1)==0
                tempLux=InputData(2,2:end);
                handles.LED_lux=[handles.LED_lux tempLux-sum(handles.alpha.*handles.LED_lux)];
                count=count+1;
            else
                handles.LED_lux=[handles.LED_lux 100*ones(size(InputData,2))];
            end

%             if InputData(1,1)==-1
%                 tempPower=InputData(1,2:end);
%                 handles.LED_power=[handles.LED_power tempPower-sum(handles.alpha.*handles.LED_power)];
%                 count=count+1;
%             elseif InputData(2,1)==-1
%                 tempPower=InputData(2,2:end);
%                 handles.LED_power=[handles.LED_power tempPower-sum(handles.alpha.*handles.LED_power)];
%                 count=count+1;
%             else
                handles.LED_power=[handles.LED_power 0];
            %end           
            
            InputData=InputData(count:end,:);

            tempWave=InputData(:,1);
            
            %spline the data to match the standardized wavelength range and
            %sampling frequency
            data=spline(tempWave,InputData(:,2),handles.Wavelength);
            data(handles.Wavelength < min(tempWave))=0;
            data(handles.Wavelength > max(tempWave))=0;

            %normalize data to 1
            data=(data-min(data)) ./ (max(data)-min(data));
            k=683;

            %correct normalization based on lux values
            coeff=tempLux/(k*sum(data(1,:).*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
            
            alpha_applied=ones(size(handles.Wavelength,2),size(handles.alpha,2));
            for n=1:size(handles.alpha,2)
                if handles.LED_state(n)>=1             
                    alpha_applied(:,n)=handles.LED_data(:,n).*handles.alpha(n).*handles.LED_N(n);
                else
                    alpha_applied(:,n)=0;
                end
            end
            generated=sum(alpha_applied,2);
            
            data=coeff*data;
            %disp([data' generated])
            
            data=data - generated';
            
            handles.current_unit_type='Spectral Irradiance (W*m^-2*nm^-1)';

            %add the processed data to the handle
            handles.LED_data=[handles.LED_data data'];            
            

            %update control variables for appropriate number of LEDs
            handles.RGB_LEDs=[handles.RGB_LEDs zeros(3,1)];
            handles.LED_state(end+1)=2;
            handles.alpha(end+1)=1;
            handles.LED_N(end+1)=1;

            i=size(handles.alpha,2);
            spd=handles.LED_data(:,i)';

            [handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.LED_x(i),handles.LED_y(i),handles.LED_z(i)]...
                =getXYZxyz(spd,handles.xcmf,handles.ycmf,handles.zcmf,handles.Wavelength);                  

            [handles.LED_R(i),handles.LED_G(i),handles.LED_B(i),handles.LED_RGB_brightness_mod(i)]...
                =getRGB(handles.RGB_mat,handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i));

            [handles.LED_UVW_u(i),handles.LED_UVW_v(i),handles.LED_W(i)]...
                =getUVW(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));   

            [handles.LED_LUV_L(i),handles.LED_LUV_u(i),handles.LED_LUV_v(i),handles.LED_LUV_u_prime(i),handles.LED_LUV_v_prime(i)]...
                =getLUV_uprime_vprime(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));

            handles.LED_cct(i)=getCCT(handles.LED_x(i),handles.LED_y(i));

            nrefspd = get_nrefspd(handles.LED_cct(i),handles.DSPD,handles.Wavelength,560);
            cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
            [Ra,R] = get_cri1995(spd',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength);
            [CQS] = get_CQS(spd',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength,handles.LED_cct(i));
            handles.LED_CRI(i)=Ra;        
            handles.LED_CQS(i)=CQS;

            [handles.LED_Lab_L(i),handles.LED_a(i),handles.LED_b(i)]...
                =getLab(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));
        end
    else
        %Separate lux data (if it is supposed to be there) from the rest of the
        %data. If it is meant to be there but isn't, output a formatting error
        %to the user and cancel the data import.     
        count=1;
        if InputData(1,1)==0
            tempLux=InputData(1,2:end);
            handles.LED_lux=[handles.LED_lux tempLux];
            count=count+1;
        elseif InputData(2,1)==0
            tempLux=InputData(2,2:end);
            handles.LED_lux=[handles.LED_lux tempLux];
            count=count+1;
        else
            handles.LED_lux=[handles.LED_lux 100*ones(size(InputData,2))];
        end

        if InputData(1,1)==-1
            tempPower=InputData(1,2:end);
            handles.LED_power=[handles.LED_power tempPower];
            count=count+1;
        elseif InputData(2,1)==-1
            tempPower=InputData(2,2:end);
            handles.LED_power=[handles.LED_power tempPower];
            count=count+1;
        else
            handles.LED_power=[handles.LED_power 10*ones(size(InputData,2)-1)];
        end

        InputData=InputData(count:end,:);

        tempWave=InputData(:,1);
    

        %loop through each column of data (each column is a spectrum for a
        %single LED)
        for n=2:size(InputData,2)
            %update control variables for appropriate number of LEDs
            handles.RGB_LEDs=[handles.RGB_LEDs zeros(3,1)];
            handles.LED_state(end+1)=1;
            handles.alpha(end+1)=1;
            handles.LED_N(end+1)=1;
            
            %spline the data to match the standardized wavelength range and
            %sampling frequency
            data=spline(tempWave,InputData(:,n),handles.Wavelength);
            data(handles.Wavelength < min(tempWave))=0;
            data(handles.Wavelength > max(tempWave))=0;

            %normalize data to 1
            data=(data-min(data)) ./ (max(data)-min(data));
            k=683;

            %correct normalization based on lux values
            coeff=handles.LED_lux(size(handles.LED_lux,2)-(size(InputData,2)-1)+n-1)/(k*sum(data(1,:).*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
            data=coeff*data;
            handles.current_unit_type='Spectral Irradiance (W*m^-2*nm^-1)';

            %add the processed data to the handle
            handles.LED_data=[handles.LED_data data'];
            
            i=size(handles.alpha,2);
            spd=handles.LED_data(:,i)';

            [handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.LED_x(i),handles.LED_y(i),handles.LED_z(i)]...
                =getXYZxyz(spd,handles.xcmf,handles.ycmf,handles.zcmf,handles.Wavelength);                  

            [handles.LED_R(i),handles.LED_G(i),handles.LED_B(i),handles.LED_RGB_brightness_mod(i)]...
                =getRGB(handles.RGB_mat,handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i));

            [handles.LED_UVW_u(i),handles.LED_UVW_v(i),handles.LED_W(i)]...
                =getUVW(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));   

            [handles.LED_LUV_L(i),handles.LED_LUV_u(i),handles.LED_LUV_v(i),handles.LED_LUV_u_prime(i),handles.LED_LUV_v_prime(i)]...
                =getLUV_uprime_vprime(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));

            handles.LED_cct(i)=getCCT(handles.LED_x(i),handles.LED_y(i));

            nrefspd = get_nrefspd(handles.LED_cct(i),handles.DSPD,handles.Wavelength,560);
            cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
            [Ra,R] = get_cri1995(spd',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength);
            [CQS] = get_CQS(spd',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength,handles.LED_cct(i));
            handles.LED_CRI(i)=Ra;        
            handles.LED_CQS(i)=CQS;

            [handles.LED_Lab_L(i),handles.LED_a(i),handles.LED_b(i)]...
                =getLab(handles.LED_X(i),handles.LED_Y(i),handles.LED_Z(i),handles.standard_illuminant(1),handles.standard_illuminant(2));
             
        end
    end

        %only allow optimization when both LEDs and ideal spectra have been
        %imported
        if size(handles.LED_state(handles.LED_state >= 1),2) >= 1 && size(handles.match_active(handles.match_active==1),2)>=1
            set(handles.optimize_complex,'Enable','on')
            set(handles.optimize_simple,'Enable','on')
            set(handles.optimize_capabilities,'Enable','on') 
        end
        %imported data only makes sense if it's all the same units. Remove
        %the option to change after the first import
        %set(handles.units_popup,'Enable','off') 
end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on button press in import_match_pushbutton.
function import_match_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to import_match_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile({'*.*';'*.txt';'*.m';'*.csv'});

%filename is a double (0) if cancel is slected or the window is closed
if ischar(filename) 
    FileNameString=fullfile(pathname, filename);
    InputData=importdata(FileNameString);
    tempWave=InputData(:,1);
    
    count=1;
    %handles lux data and give formatting error if necessary
        if InputData(1,1)==0
            handles.Ideal_lux=[handles.Ideal_lux InputData(1,2:end)];
            count=count+1;
        else
            handles.Ideal_lux=[handles.Ideal_lux 100];
        end
        tempWave=tempWave(count:end);
        InputData=InputData(count:end,:);

        %enables the popup list if this is the first ideal import
        if size(handles.match_active,2)==0
            set(handles.matching_spectrum_popup,'Enable','on')
            set(handles.ideal_lux_edit,'Enable','on')
        end

        %removes the first "empty" element from the popup list during the
        %first import. There is probably a neater way to do this.
        if handles.clean==1
            handles.matching_spectrum_names(:,1)=[];
            handles.clean=0;
        end

        %loop through each column of the imported data        
        for n=2:size(InputData,2)
            
            %handles the case where this file has been imported before. Gives
            %it a different name and associated constants even though the
            %data is the same
            if size(handles.matching_spectrum_names(strcmp(handles.matching_spectrum_names,filename)==1),2) >= 1
                temp_names=regexprep(handles.matching_spectrum_names,'---(\w*)','');
                repeat=size(temp_names(strcmp(temp_names,filename)==1),2)+1;
                handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=strcat(filename,'---',num2str(repeat)); 
                
            %one spectrum in this file
            elseif size(InputData,2) <= 2
                handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=filename;
                
            %handles the case where there are multiple spectra in the same 
            %file. Gives each a unique id      
            else
                handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=strcat(filename,'---',num2str(n-1));
            end
            
            %set up associated constants
            %handles.ideal_multiplier(end+1)=1;
            
            %if this is the first ideal spectrum to be imported, set it as
            %the active spectrum. Otherwise leave it as inactive
            if size(handles.match_active,2)==0 && n==2
                handles.match_active(end+1)=1;
            else
                handles.match_active(end+1)=0;            
            end
            
            %spline the data with the standardized wavelength
            data=spline(tempWave,InputData(:,n),handles.Wavelength);
            data(handles.Wavelength < min(tempWave))=0;
            data(handles.Wavelength > max(tempWave))=0;
            
            %apply lux if available to undo normalization of the data
            data=(data-min(data)) ./ (max(data)-min(data));
            k=683;
            
            coeff=handles.Ideal_lux(size(handles.Ideal_lux,2)-(size(InputData,2)-1)+n-1)/(k*sum(data(1,:).*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
            data=coeff*data;
            handles.current_unit_type='Spectral Irradiance (W*m^-2*nm^-1)';

            %add processed data to the handle
            handles.match_data=[handles.match_data data'];
        end

        %only allow optimization if both LED and ideal spectra have been
        %imported
        if size(handles.LED_state(handles.LED_state >= 1),2) >= 1 && size(handles.match_active(handles.match_active==1),2)>=1
            set(handles.optimize_complex,'Enable','on')
            set(handles.optimize_simple,'Enable','on')
            set(handles.optimize_capabilities,'Enable','on') 
        end
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on button press in optimize_complex.


% --- Executes on key press with focus on LED1_toggle and none of its controls.
function LED1_toggle_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to LED1_toggle (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on selection change in matching_spectrum_popup.
function matching_spectrum_popup_Callback(hObject, eventdata, handles)
% hObject    handle to matching_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns matching_spectrum_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from matching_spectrum_popup
contents=cellstr(get(hObject,'String'));
handles.match_active(:)=0;
index=find(strcmp(contents{get(hObject,'Value')}, handles.matching_spectrum_names));
handles.match_active(index)=1;

set(handles.matching_spectrum_popup,'Value', index)


handles=refresh(hObject,eventdata,handles);

handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function matching_spectrum_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matching_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in LED2_toggle.
function LED2_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.LED_state(2+handles.LED_pagenum*5) < 2
    handles.LED_state(2+handles.LED_pagenum*5)=handles.LED_state(2+handles.LED_pagenum*5)+1;
else
    handles.LED_state(2+handles.LED_pagenum*5)=0;
end% 
% if get(hObject,'Value')==1
%     set(handles.LED2_slider,'Enable','on')
%     set(handles.LED2_text,'Enable','on')
% else
%     set(handles.LED2_slider,'Enable','off')  
%     set(handles.LED2_text,'Enable','off')    
% end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED2_toggle
end


function LED2_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(2+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED2_text as text
%        str2double(get(hObject,'String')) returns contents of LED2_text as a double
end

% --- Executes during object creation, after setting all properties.
function LED2_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on slider movement.
function LED2_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.alpha(2+handles.LED_pagenum*5) ~= get(hObject,'Value')
    set(handles.LED2_slider,'Enable','off')
    drawnow

    handles.alpha(2+handles.LED_pagenum*5)=get(hObject,'Value');
    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    
    set(handles.LED2_slider,'Enable','on')

end

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function LED2_slider_CreateFcn(hObject, ~, handles)
% hObject    handle to LED2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on button press in LED3_toggle.
function LED3_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED3_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.LED_state(3+handles.LED_pagenum*5) < 2
    handles.LED_state(3+handles.LED_pagenum*5)=handles.LED_state(3+handles.LED_pagenum*5)+1;
else
    handles.LED_state(3+handles.LED_pagenum*5)=0;
end

% if get(hObject,'Value')==1
%     set(handles.LED3_slider,'Enable','on')
%     set(handles.LED3_text,'Enable','on')
% else
%     set(handles.LED3_slider,'Enable','off')  
%     set(handles.LED3_text,'Enable','off')    
% end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED3_toggle
end


function LED3_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED3_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(3+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED3_text as text
%        str2double(get(hObject,'String')) returns contents of LED3_text as a double
end

% --- Executes during object creation, after setting all properties.
function LED3_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED3_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on slider movement.
function LED3_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.alpha(3+handles.LED_pagenum*5) ~= get(hObject,'Value')
    set(handles.LED3_slider,'Enable','off')
    drawnow

    handles.alpha(3+handles.LED_pagenum*5)=get(hObject,'Value');
    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    
    set(handles.LED3_slider,'Enable','on')

end
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function LED3_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on button press in LED4_toggle.
function LED4_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED4_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.LED_state(4+handles.LED_pagenum*5) < 2
    handles.LED_state(4+handles.LED_pagenum*5)=handles.LED_state(4+handles.LED_pagenum*5)+1;
else
    handles.LED_state(4+handles.LED_pagenum*5)=0;
end% if get(hObject,'Value')==1
%     set(handles.LED4_slider,'Enable','on')
%     set(handles.LED4_text,'Enable','on')
% else
%     set(handles.LED4_slider,'Enable','off')  
%     set(handles.LED4_text,'Enable','off')    
% end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED4_toggle
end


function LED4_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED4_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(4+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED4_text as text
%        str2double(get(hObject,'String')) returns contents of LED4_text as a double
end

% --- Executes during object creation, after setting all properties.
function LED4_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED4_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on slider movement.
function LED4_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED4_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.alpha(4+handles.LED_pagenum*5) ~= get(hObject,'Value')
    set(handles.LED4_slider,'Enable','off')
    drawnow

    handles.alpha(4+handles.LED_pagenum*5)=get(hObject,'Value');
    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    
    set(handles.LED4_slider,'Enable','on')

end
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function LED4_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED4_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on button press in LED5_toggle.
function LED5_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED5_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.LED_state(5+handles.LED_pagenum*5) < 2
    handles.LED_state(5+handles.LED_pagenum*5)=handles.LED_state(5+handles.LED_pagenum*5)+1;
else
    handles.LED_state(5+handles.LED_pagenum*5)=0;
end
% if get(hObject,'Value')==1
%     set(handles.LED5_slider,'Enable','on')
%     set(handles.LED5_text,'Enable','on')
% else
%     set(handles.LED5_slider,'Enable','off')  
%     set(handles.LED5_text,'Enable','off')    
% end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED5_toggle
end


function LED5_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED5_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(5+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED5_text as text
%        str2double(get(hObject,'String')) returns contents of LED5_text as a double
end

% --- Executes during object creation, after setting all properties.
function LED5_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED5_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on slider movement.
function LED5_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED5_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.alpha(5+handles.LED_pagenum*5) ~= get(hObject,'Value')
    set(handles.LED5_slider,'Enable','off')
    drawnow

    handles.alpha(5+handles.LED_pagenum*5)=get(hObject,'Value');
    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    
    set(handles.LED5_slider,'Enable','on')

end
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function LED5_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED5_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on button press in prev_page.
function prev_page_Callback(hObject, eventdata, handles)
% hObject    handle to prev_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_pagenum=handles.LED_pagenum-1;

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);
end
% --- Executes on button press in next_page.
function next_page_Callback(hObject, eventdata, handles)
% hObject    handle to next_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_pagenum=handles.LED_pagenum+1;

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);
end

% --- Executes on button press in range1.
function range1_Callback(hObject, eventdata, handles)
% hObject    handle to range1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of range1
if get(hObject,'Value')==1
    set(handles.range2,'Value',0);
    
    set(handles.LED1_slider,'max',1);
    set(handles.LED2_slider,'max',1);
    set(handles.LED3_slider,'max',1);
    set(handles.LED4_slider,'max',1);
    set(handles.LED5_slider,'max',1);

else
    set(handles.range2,'Value',1);
    set(handles.LED1_slider,'max',100);
    set(handles.LED2_slider,'max',100);
    set(handles.LED3_slider,'max',100);
    set(handles.LED4_slider,'max',100);
    set(handles.LED5_slider,'max',100);    
end

handles.max_alpha=1;
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);
end

% --- Executes on button press in range2.
function range2_Callback(hObject, eventdata, handles)
% hObject    handle to range2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')==1
    set(handles.range1,'Value',0);
    set(handles.LED1_slider,'max',100);
    set(handles.LED2_slider,'max',100);
    set(handles.LED3_slider,'max',100);
    set(handles.LED4_slider,'max',100);
    set(handles.LED5_slider,'max',100);
else
    set(handles.range1,'Value',1);
    set(handles.LED1_slider,'max',1);
    set(handles.LED2_slider,'max',1);
    set(handles.LED3_slider,'max',1);
    set(handles.LED4_slider,'max',1);
    set(handles.LED5_slider,'max',1);    
end

handles.max_alpha=100; %actually no limit

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of range2
end

% --- Executes on selection change in CIE_popup.
function CIE_popup_Callback(hObject, eventdata, handles)
% hObject    handle to CIE_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CIE_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CIE_popup

contents = cellstr(get(hObject,'String'));
handles.CIE_space=contents{get(hObject,'Value')};

handles=refresh_color_space(hObject,eventdata,handles);
handles=replot_color_space(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function CIE_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CIE_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in reference_illuminant_popup.
function reference_illuminant_popup_Callback(hObject, eventdata, handles)
% hObject    handle to reference_illuminant_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns reference_illuminant_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from reference_illuminant_popup
contents = cellstr(get(hObject,'String'));
handles.standard_illuminant=handles.illuminant_data_xy_2deg(strcmp(handles.illuminant_names,contents{get(hObject,'Value')})==1,:);

index=find(strcmp(handles.illuminant_names,contents{get(hObject,'Value')}));
set(handles.reference_illuminant_popup,'Value', index)

handles=refresh(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function reference_illuminant_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reference_illuminant_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in units_popup.
function units_popup_Callback(hObject, eventdata, handles)
% hObject    handle to units_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns units_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from units_popup
contents = cellstr(get(hObject,'String'));
handles.unit_type=contents{get(hObject,'Value')};

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function units_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to units_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on key press with focus on import_LED_pushbutton and none of its controls.
function import_LED_pushbutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to import_LED_pushbutton (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on selection change in unit_conversion_popup.
function unit_conversion_popup_Callback(hObject, eventdata, handles)
% hObject    handle to unit_conversion_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns unit_conversion_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unit_conversion_popup
end

% --- Executes during object creation, after setting all properties.
function unit_conversion_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unit_conversion_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function ideal_lux_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ideal_lux_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ideal_lux_edit as text
%        str2double(get(hObject,'String')) returns contents of ideal_lux_edit as a double
handles.Ideal_lux(:,handles.match_active==1)=str2double(get(hObject,'String'));

%normalize data
maximum=max(handles.match_data(:,handles.match_active==1));
minimum=min(handles.match_data(:,handles.match_active==1));

handles.match_data(:,handles.match_active==1)=(handles.match_data(:,handles.match_active==1)-minimum) ./ (maximum-minimum);
k=683;

%correct normalization based on lux values
coeff=handles.Ideal_lux(:,handles.match_active==1)/(k*sum(handles.match_data(:,handles.match_active==1)'.*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
handles.match_data(:,handles.match_active==1)=coeff*handles.match_data(:,handles.match_active==1);

% val=str2double(get(hObject,'String'));
% if isnan(val)==1
%     val=1;
% else    
%     if val <= 0
%        val=1; 
%     end
% end
% 
% handles.match_data(:,handles.match_active==1)=handles.match_data(:,handles.match_active==1)/handles.Ideal_lux(handles.match_active==1);
% handles.Ideal_lux(handles.match_active==1)=val;
% handles.match_data(:,handles.match_active==1)=handles.match_data(:,handles.match_active==1)*handles.Ideal_lux(handles.match_active==1);
% 
% set(handles.ideal_lux_edit,'Value', handles.Ideal_lux(:,handles.match_active==1))

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function ideal_lux_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ideal_lux_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function CRI_goal_edit_Callback(hObject, eventdata, handles)
% hObject    handle to CRI_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CRI_goal_edit as text
%        str2double(get(hObject,'String')) returns contents of CRI_goal_edit as a double
val=str2double(get(hObject,'String'));

if isnan(val)==1
    handles.CRI_optimizer_states{2}='Off';
    handles.CRI_goal=1;
else
    handles.CRI_optimizer_states{2}='On';
    if val > 100
       val=100; 
    end
    handles.CRI_goal=val;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end
% --- Executes during object creation, after setting all properties.
function CRI_goal_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CRI_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function power_goal_edit_Callback(hObject, eventdata, handles)
% hObject    handle to power_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power_goal_edit as text
%        str2double(get(hObject,'String')) returns contents of power_goal_edit as a double
val=str2double(get(hObject,'String'));

if isnan(val)==1
    handles.power_optimizer_states{2}='Off';
    handles.power_goal=1;
else
    handles.power_optimizer_states{2}='On';
    if val < 0
        val=1;
    end 
    handles.power_goal=val;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end
% --- Executes during object creation, after setting all properties.
function power_goal_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function power_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to power_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power_goal_edit as text
%        str2double(get(hObject,'String')) returns contents of power_goal_edit as a double
val=str2double(get(hObject,'String'));
if isnan(val)==1
    handles.power_optimizer_states{1}='Off';
    handles.power_weight=1;
else
    handles.power_optimizer_states{1}='On';
    handles.power_weight=val;
end
handles.power_weight=val;

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end
% --- Executes during object creation, after setting all properties.
function power_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%LED=handles.alpha(handles.LED_state >= 1);
LED=handles.alpha(1:5);

LED=LED';
LED=repmat(LED,10,1);
%disp(ones(50,1).*LED)
dim(30000*ones(50,1).*LED)
end


% --- Executes on button press in plot_toggle.
function plot_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to plot_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.plot_color_toggle==0
    handles.plot_color_toggle=1;
else
    handles.plot_color_toggle=0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end


% --- Executes on selection change in optimize_capabilities_options.
function optimize_capabilities_options_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_capabilities_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns optimize_capabilities_options contents as cell array
%        contents{get(hObject,'Value')} returns selected item from optimize_capabilities_options
contents = cellstr(get(hObject,'String'));
handles.optimize_capabilities_type=contents{get(hObject,'Value')};
    
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function optimize_capabilities_options_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optimize_capabilities_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in optimize_capabilities.
function optimize_capabilities_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_capabilities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    R=[];
    for n=1:size(handles.LED_data,2)
        if handles.LED_state(n)>=1
            R=[R handles.LED_data(:,n)];
        end
    end

    lb=zeros(1,size(handles.LED_state(handles.LED_state >= 1),2));
    ub=ones(1,size(handles.LED_state(handles.LED_state >= 1),2));
    ub=ub.*handles.max_alpha;

    Aeq=zeros(size(handles.LED_state(handles.LED_state >= 1),2),size(handles.LED_state(handles.LED_state >= 1),2));
    beq=zeros(size(handles.LED_state(handles.LED_state >= 1),2),1);
    for i=1:size(handles.LED_state(handles.LED_state >= 1),2)
        if handles.LED_state(i)==2
           beq(i)=handles.alpha(i); 
           Aeq(i,i)=1;   
        end
    end

    if strcmp(handles.optimize_capabilities_type,'Maximized CRI with JND constraint, Full CCT Range')==1
        ideal_xy=[handles.x(1) handles.y(1)];
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
        [CRI_results,CCT_range]=generate_optimization_summary(R,Aeq,beq,ub,lb,handles.CIETCS1nm,handles.DSPD,handles.Wavelength,ideal_xy,cmf);  

        figure()
        plot(CCT_range,CRI_results,'Marker','o')
        xlabel('CCT')
        ylabel('Max CRI attained')
        title('Maximizing CRI, constrained such that <1 JND of color difference between generated spectrum and ideal blackbody/daylight spd')
    end
    if strcmp(handles.optimize_capabilities_type,'Plot Efficiency Vector')==1
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
        
        standard_xy=[handles.standard_illuminant(1) handles.standard_illuminant(2)];
        
        ideal_xy=[handles.x(1) handles.y(1)];
        ideal_LUV=[handles.LUV_L(1) handles.LUV_u(1) handles.LUV_v(1)];
        ideal_Lab=[handles.Lab_L(1) handles.a(1) handles.b(1)];
        
        LED_xy=[handles.LED_x' handles.LED_y'];
        % {CRI_weight power_weight dE_weight; CRI_constraint power_constraint dE_constraint}
        xy_results=generate_efficiency_vector(R,Aeq,beq,ub,lb,LED_xy,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,handles.Wavelength,handles.g11,handles.g22,handles.g12,handles.CIETCS1nm,handles.DSPD,handles.LED_power,handles.LED_N,handles.LED_lux);

%         figure()
%         plot(CCT_range,CRI_results,'Marker','o')
%         xlabel('CCT')
%         ylabel('Max CRI attained')
%         title('Maximizing CRI, constrained such that <1 JND of color difference between generated spectrum and ideal blackbody/daylight spd')
    end
    if strcmp(handles.optimize_capabilities_type,'Max CRI With Constraints')==1
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
                
        standard_xy=[handles.standard_illuminant(1) handles.standard_illuminant(2)];
        
        ideal_xy=[handles.x(1) handles.y(1)];
        ideal_LUV=[handles.LUV_L(1) handles.LUV_u(1) handles.LUV_v(1)];
        ideal_Lab=[handles.Lab_L(1) handles.a(1) handles.b(1)];
        
        LED_xy=[handles.LED_x' handles.LED_y'];
        % {CRI_weight power_weight dE_weight; CRI_constraint power_constraint dE_constraint}
        CRI_results=max_CRI_with_constraints(R,Aeq,beq,ub,lb,LED_xy,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,handles.Wavelength,handles.g11,handles.g22,handles.g12,handles.CIETCS1nm,handles.DSPD,handles.LED_power,handles.LED_N,handles.LED_lux);

%         figure()
%         plot(CCT_range,CRI_results,'Marker','o')
%         xlabel('CCT')
%         ylabel('Max CRI attained')
%         title('Maximizing CRI, constrained such that <1 JND of color difference between generated spectrum and ideal blackbody/daylight spd')
    end    

    if strcmp(handles.optimize_capabilities_type,'CRI with Increasing Power Weight')==1
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
                
        standard_xy=[handles.standard_illuminant(1) handles.standard_illuminant(2)];
        
        ideal_xy=[handles.x(1) handles.y(1)];
        ideal_LUV=[handles.LUV_L(1) handles.LUV_u(1) handles.LUV_v(1)];
        ideal_Lab=[handles.Lab_L(1) handles.a(1) handles.b(1)];
        
        LED_xy=[handles.LED_x' handles.LED_y'];
        % {CRI_weight power_weight dE_weight; CRI_constraint power_constraint dE_constraint}
        results=increasing_power_weight(R,Aeq,beq,ub,lb,LED_xy,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,handles.Wavelength,handles.g11,handles.g22,handles.g12,handles.CIETCS1nm,handles.DSPD,handles.LED_power(handles.LED_state >= 1),handles.LED_N(handles.LED_state >= 1),handles.LED_lux(handles.LED_state >= 1));

%         figure()
%         plot(CCT_range,CRI_results,'Marker','o')
%         xlabel('CCT')
%         ylabel('Max CRI attained')
%         title('Maximizing CRI, constrained such that <1 JND of color difference between generated spectrum and ideal blackbody/daylight spd')
    end
    if strcmp(handles.optimize_capabilities_type,'JND with Increasing Power Weight')==1
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
                
        standard_xy=[handles.standard_illuminant(1) handles.standard_illuminant(2)];
        
        ideal_xy=[handles.x(1) handles.y(1)];
        ideal_LUV=[handles.LUV_L(1) handles.LUV_u(1) handles.LUV_v(1)];
        ideal_Lab=[handles.Lab_L(1) handles.a(1) handles.b(1)];
        
        LED_xy=[handles.LED_x' handles.LED_y'];
        % {CRI_weight power_weight dE_weight; CRI_constraint power_constraint dE_constraint}
        results=increasing_power_weight_withJND(R,Aeq,beq,ub,lb,LED_xy,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,handles.Wavelength,handles.g11,handles.g22,handles.g12,handles.CIETCS1nm,handles.DSPD,handles.LED_power(handles.LED_state >= 1),handles.LED_N(handles.LED_state >= 1),handles.LED_lux(handles.LED_state >= 1));

%         figure()
%         plot(CCT_range,CRI_results,'Marker','o')
%         xlabel('CCT')
%         ylabel('Max CRI attained')
%         title('Maximizing CRI, constrained such that <1 JND of color difference between generated spectrum and ideal blackbody/daylight spd')
    end    

    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    guidata(hObject, handles);

end

% --- Executes on button press in optimizer_CRI_label.
function optimizer_CRI_label_Callback(hObject, eventdata, handles)
% hObject    handle to optimizer_CRI_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.optimize_CRI_type,'CRI') == 1
    handles.optimize_CRI_type='CQS';
elseif strcmp(handles.optimize_CRI_type,'CQS') == 1
    handles.optimize_CRI_type='GAI';
else
    handles.optimize_CRI_type='CRI';
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);


end

% --- Executes on button press in optimizer_dE_label.
function optimizer_dE_label_Callback(hObject, eventdata, handles)
% hObject    handle to optimizer_dE_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.optimize_dE_type,'LUV') == 1
    handles.optimize_dE_type='Lab';
elseif strcmp(handles.optimize_dE_type,'Lab') == 1
    handles.optimize_dE_type='JND';
elseif strcmp(handles.optimize_dE_type,'JND') == 1
    handles.optimize_dE_type='LUV';    
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on selection change in optimize_weighted_options.
function optimize_complex_options_Callback(hObject, eventdata, handles)

contents = cellstr(get(hObject,'String'));
handles.optimize_complex_type=contents{get(hObject,'Value')};

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function optimize_complex_options_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optimize_weighted_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in optimize_weighted.
function optimize_complex_Callback(hObject, eventdata, handles)

    L0_norm_state=0;
    if handles.minimize_NLEDs==1
        L0_norm_state=1;
    elseif handles.choose_NLEDs==1
        L0_norm_state=[1 handles.choose_NLEDs_value];
    end
    
    R=ones(size(handles.LED_data,1),size(handles.LED_state(handles.LED_state >=1),2));
    LED_N=ones(size(handles.LED_state(handles.LED_state >=1)));
    LED_lux=ones(size(handles.LED_state(handles.LED_state >=1)));
    LED_power=ones(size(handles.LED_state(handles.LED_state >=1)));
    i=1;
    for n=1:size(handles.LED_data,2)
        if handles.LED_state(n)>=1
            R(:,i)=handles.LED_data(:,n);
            LED_N(i)=handles.LED_N(n);
            LED_lux(i)=handles.LED_lux(n);
            LED_power(i)=handles.LED_power(n);
            i=i+1;
        end
    end

    lb=zeros(1,size(handles.LED_state(handles.LED_state >= 1),2));
    ub=ones(1,size(handles.LED_state(handles.LED_state >= 1),2));
    ub=ub.*handles.max_alpha;

    cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
    %ideal_uprime_vprime=[handles.LUV_u_prime(1) handles.LUV_v_prime(1)];
    %constraint_goals=[handles.CRI_goal 1];

    Aeq=zeros(size(handles.LED_state(handles.LED_state >= 1),2),size(handles.LED_state(handles.LED_state >= 1),2));
    beq=zeros(size(handles.LED_state(handles.LED_state >= 1),2),1);

    for i=1:size(handles.LED_state(handles.LED_state >= 1),2)
        if handles.LED_state(i)==2
           beq(i)=handles.alpha(i); 
           Aeq(i,i)=1;   
        end
    end

    weights=[handles.CRI_weight handles.power_weight handles.dE_weight handles.lux_weight];
    constraints=[handles.CRI_goal handles.power_goal handles.dE_goal handles.lux_goal];
    standard_xy=[handles.standard_illuminant(1) handles.standard_illuminant(2)];
    ideal_xy=[handles.x(1) handles.y(1)];
    ideal_LUV=[handles.LUV_L(1) handles.LUV_u(1) handles.LUV_v(1)];
    ideal_Lab=[handles.Lab_L(1) handles.a(1) handles.b(1)]; 

    simulation_trials_attempts=[handles.simulation_trials handles.simulation_attempts]; 

    [x,LED_N,optimization_finished,LED_state,~]=optimize_combined(R,handles.CRI_minmax,handles.power_minmax,handles.dE_minmax,handles.lux_minmax,Aeq,beq,ub,lb,handles.CRI_optimizer_states,handles.power_optimizer_states,handles.dE_optimizer_states,handles.lux_optimizer_states,weights,constraints,handles.optimize_power_type,handles.optimize_dE_type,handles.optimize_CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,handles.Wavelength,handles.g11,handles.g22,handles.g12,handles.vl1924e1nm,handles.CIETCS1nm,handles.DSPD,LED_power,LED_N,LED_lux,L0_norm_state,handles.simulation_activated,simulation_trials_attempts,handles.simulation_CRI_states,handles.simulation_power_states,handles.simulation_dE_states,handles.simulation_lux_states,handles.simulation_CRI_increments,handles.simulation_power_increments,handles.simulation_dE_increments,handles.simulation_lux_increments,handles.simulation_CRI_direction,handles.simulation_power_direction,handles.simulation_dE_direction,handles.simulation_lux_direction);
    %[x,LED_N,optimization_finished]=optimize_monte_carlo(R,handles.CRI_minmax,handles.power_minmax,handles.dE_minmax,handles.lux_minmax,Aeq,beq,ub,lb,handles.CRI_optimizer_states,handles.power_optimizer_states,handles.dE_optimizer_states,handles.lux_optimizer_states,weights,constraints,handles.optimize_dE_type,handles.optimize_CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,handles.Wavelength,handles.g11,handles.g22,handles.g12,handles.CIETCS1nm,handles.DSPD,LED_power,LED_N,LED_lux,L0_norm_state,handles.simulation_activated,simulation_trials_attempts,handles.simulation_CRI_states,handles.simulation_power_states,handles.simulation_dE_states,handles.simulation_lux_states,handles.simulation_CRI_increments,handles.simulation_power_increments,handles.simulation_dE_increments,handles.simulation_lux_increments,handles.simulation_CRI_direction,handles.simulation_power_direction,handles.simulation_dE_direction,handles.simulation_lux_direction);

    if length(L0_norm_state) == 2
       handles.LED_state(handles.LED_state>=1)=LED_state; 
    end
    
%     if optimization_finished==1
%        handles.optimize_x=[handles.optimize_x;x]; 
%        x_values=handles.optimize_x;
%        save('validation_results.mat','x_values')
%     end
    i=1;
    for n=1:size(handles.LED_state,2)
        if optimization_finished==1
            if handles.LED_state(n) >= 1
                handles.LED_N(n)=LED_N(i);
                handles.alpha(n)=x(i);
                i=i+1;
            end
        else %if optimization_finished==2
            if handles.LED_state(n) == 1
                handles.LED_N(n)=LED_N(i);
                handles.alpha(n)=x(i);
                i=i+1;
            end
        end
    end

    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    guidata(hObject, handles);
end


function CRI_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to CRI_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CRI_weight_edit as text
%        str2double(get(hObject,'String')) returns contents of CRI_weight_edit as a double
val=str2double(get(hObject,'String'));
if isnan(val)==1
    handles.CRI_optimizer_states{1}='Off';
    handles.CRI_weight=1;
else
    handles.CRI_optimizer_states{1}='On';
    handles.CRI_weight=val;
end
%handles.optimizer_states={'On' 'On' 'On'; 'On' 'On' 'On'};

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function CRI_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CRI_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function dE_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dE_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dE_weight_edit as text
%        str2double(get(hObject,'String')) returns contents of dE_weight_edit as a double
val=str2double(get(hObject,'String'));
if isnan(val)==1
    handles.dE_optimizer_states{1}='Off';
    handles.dE_weight=1;
else
    handles.dE_optimizer_states{1}='On';
    handles.dE_weight=val;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function dE_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dE_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in optimize_simple_options.
function optimize_simple_options_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_simple_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns optimize_simple_options contents as cell array
%        contents{get(hObject,'Value')} returns selected item from optimize_simple_options
contents = cellstr(get(hObject,'String'));
handles.optimize_simple_type=contents{get(hObject,'Value')};

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function optimize_simple_options_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optimize_simple_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in optimize_simple.
function optimize_simple_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_simple (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    R=[];
    for n=1:size(handles.LED_data,2)
        if handles.LED_state(n)>=1
            R=[R handles.LED_data(:,n)];
        end
    end

    lb=zeros(1,size(handles.LED_state(handles.LED_state >= 1),2));
    ub=ones(1,size(handles.LED_state(handles.LED_state >= 1),2));
    ub=ub.*handles.max_alpha;

    cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];

    Aeq=zeros(size(handles.LED_state(handles.LED_state >= 1),2),size(handles.LED_state(handles.LED_state >= 1),2));
    beq=zeros(size(handles.LED_state(handles.LED_state >= 1),2),1);
    
    for i=1:size(handles.LED_state(handles.LED_state >= 1),2)
        if handles.LED_state(i)==2
           beq(i)=handles.alpha(i); 
           Aeq(i,i)=1;   
        end
    end

    if strcmp(handles.optimize_simple_type,'Least-Squares Spectrum Match')==1
        options_lsqlin = optimoptions('lsqlin','Display','off','Algorithm','active-set');
        s=handles.match_data(:,handles.match_active==1);
        alpha_temp=lsqlin(R,s,[],[],Aeq,beq,lb,ub,[],options_lsqlin);

        i=1;
        for n=1:size(handles.LED_state,2)
            if handles.LED_state(n) >= 1
                handles.alpha(n)=alpha_temp(i);
                i=i+1;
            end
        end
    end

    if strcmp(handles.optimize_simple_type,'Least-Squares RGB Match')==1
        ideal_RGB=[handles.R(1);handles.G(1);handles.B(1)]/handles.RGB_brightness_mod(1);
        x=optimize_RGB(R,Aeq,beq,lb,ub,cmf,handles.Wavelength,ideal_RGB,handles.RGB_mat);

        i=1;
        for n=1:size(handles.LED_state,2)
            if handles.LED_state(n) >= 1
                handles.alpha(n)=x(i);
                i=i+1;
            end
        end
    end
    
    handles=refresh(hObject,eventdata,handles);
    handles=replot(hObject,eventdata,handles);
    guidata(hObject, handles);
end


function dE_goal_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dE_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dE_goal_edit as text
%        str2double(get(hObject,'String')) returns contents of dE_goal_edit as a double
val=str2double(get(hObject,'String'));
if isnan(val)==1
    handles.dE_optimizer_states{2}='Off';
    handles.dE_goal=1;
else
    handles.dE_optimizer_states{2}='On';
    if val < 0
        val=1;
    end 
    handles.dE_goal=val;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function dE_goal_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dE_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function lux5_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lux5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lux5_edit as text
%        str2double(get(hObject,'String')) returns contents of lux5_edit as a double
i=5+handles.LED_pagenum*5;

handles.LED_lux(i)=str2double(get(hObject,'String'));

%normalize data
handles.LED_data(:,i)=(handles.LED_data(:,i)-min(handles.LED_data(:,i))) ./ (max(handles.LED_data(:,i))-min(handles.LED_data(:,i)));
k=683;

%correct normalization based on lux values
coeff=handles.LED_lux(i)/(k*sum(handles.LED_data(:,i)'.*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
handles.LED_data(:,i)=coeff*handles.LED_data(:,i);

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function lux5_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lux5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function lux4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lux4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lux4_edit as text
%        str2double(get(hObject,'String')) returns contents of lux4_edit as a double
i=4+handles.LED_pagenum*5;

handles.LED_lux(i)=str2double(get(hObject,'String'));

%normalize data
handles.LED_data(:,i)=(handles.LED_data(:,i)-min(handles.LED_data(:,i))) ./ (max(handles.LED_data(:,i))-min(handles.LED_data(:,i)));
k=683;

%correct normalization based on lux values
coeff=handles.LED_lux(i)/(k*sum(handles.LED_data(:,i)'.*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
handles.LED_data(:,i)=coeff*handles.LED_data(:,i);

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function lux4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lux4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function lux3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lux3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lux3_edit as text
%        str2double(get(hObject,'String')) returns contents of lux3_edit as a double
i=3+handles.LED_pagenum*5;

handles.LED_lux(i)=str2double(get(hObject,'String'));

%normalize data
handles.LED_data(:,i)=(handles.LED_data(:,i)-min(handles.LED_data(:,i))) ./ (max(handles.LED_data(:,i))-min(handles.LED_data(:,i)));
k=683;

%correct normalization based on lux values
coeff=handles.LED_lux(i)/(k*sum(handles.LED_data(:,i)'.*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
handles.LED_data(:,i)=coeff*handles.LED_data(:,i);

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function lux3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lux3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function lux2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lux2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lux2_edit as text
%        str2double(get(hObject,'String')) returns contents of lux2_edit as a double
i=2+handles.LED_pagenum*5;

handles.LED_lux(i)=str2double(get(hObject,'String'));

%normalize data
handles.LED_data(:,i)=(handles.LED_data(:,i)-min(handles.LED_data(:,i))) ./ (max(handles.LED_data(:,i))-min(handles.LED_data(:,i)));
k=683;

%correct normalization based on lux values
coeff=handles.LED_lux(i)/(k*sum(handles.LED_data(:,i)'.*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
handles.LED_data(:,i)=coeff*handles.LED_data(:,i);

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function lux2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lux2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function lux1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lux1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lux1_edit as text
%        str2double(get(hObject,'String')) returns contents of lux1_edit as a double
i=1+handles.LED_pagenum*5;

handles.LED_lux(i)=str2double(get(hObject,'String'));

%normalize data
handles.LED_data(:,i)=(handles.LED_data(:,i)-min(handles.LED_data(:,i))) ./ (max(handles.LED_data(:,i))-min(handles.LED_data(:,i)));
k=683;

%correct normalization based on lux values
coeff=handles.LED_lux(i)/(k*sum(handles.LED_data(:,i)'.*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
handles.LED_data(:,i)=coeff*handles.LED_data(:,i);

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function lux1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lux1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function N5_edit_Callback(hObject, eventdata, handles)
% hObject    handle to N5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N5_edit as text
%        str2double(get(hObject,'String')) returns contents of N5_edit as a double
i=5+handles.LED_pagenum*5;

handles.LED_N(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_N(i))==1 || handles.LED_N(i) < 1
    handles.LED_N(i)=1;
else    
    handles.LED_N(i)=round(handles.LED_N(i));
    
end
set(handles.N5_edit,'String',handles.LED_N(i))

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function N5_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function N4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to N4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N4_edit as text
%        str2double(get(hObject,'String')) returns contents of N4_edit as a double

i=4+handles.LED_pagenum*5;

handles.LED_N(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_N(i))==1 || handles.LED_N(i) < 1
    handles.LED_N(i)=1;
else    
    handles.LED_N(i)=round(handles.LED_N(i));
    
end
set(handles.N4_edit,'String',handles.LED_N(i))

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function N4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function N3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to N3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N3_edit as text
%        str2double(get(hObject,'String')) returns contents of N3_edit as a double
i=3+handles.LED_pagenum*5;

handles.LED_N(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_N(i))==1 || handles.LED_N(i) < 1
    handles.LED_N(i)=1;
else    
    handles.LED_N(i)=round(handles.LED_N(i));
    
end
set(handles.N3_edit,'String',handles.LED_N(i))

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function N3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function N2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to N2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N2_edit as text
%        str2double(get(hObject,'String')) returns contents of N2_edit as a double
i=2+handles.LED_pagenum*5;

handles.LED_N(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_N(i))==1 || handles.LED_N(i) < 1
    handles.LED_N(i)=1;
else    
    handles.LED_N(i)=round(handles.LED_N(i));
    
end
set(handles.N2_edit,'String',handles.LED_N(i))

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function N2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function N1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to N1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N1_edit as text
%        str2double(get(hObject,'String')) returns contents of N1_edit as a double
i=1+handles.LED_pagenum*5;

handles.LED_N(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_N(i))==1 || handles.LED_N(i) < 1
    handles.LED_N(i)=1;
else    
    handles.LED_N(i)=round(handles.LED_N(i));
    
end
set(handles.N1_edit,'String',handles.LED_N(i))

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function N1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function power5_edit_Callback(hObject, eventdata, handles)
% hObject    handle to power5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power5_edit as text
%        str2double(get(hObject,'String')) returns contents of power5_edit as a double
i=5+handles.LED_pagenum*5;

handles.LED_power(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_power(i))==1
    handles.LED_power(i)=1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function power5_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function power4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to power4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power4_edit as text
%        str2double(get(hObject,'String')) returns contents of power4_edit as a double
i=4+handles.LED_pagenum*5;

handles.LED_power(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_power(i))==1
    handles.LED_power(i)=1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function power4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function power3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to power3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power3_edit as text
%        str2double(get(hObject,'String')) returns contents of power3_edit as a double
i=3+handles.LED_pagenum*5;

handles.LED_power(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_power(i))==1
    handles.LED_power(i)=1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function power3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function power2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to power2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power2_edit as text
%        str2double(get(hObject,'String')) returns contents of power2_edit as a double
i=2+handles.LED_pagenum*5;

handles.LED_power(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_power(i))==1
    handles.LED_power(i)=1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function power2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function power1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to power1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power1_edit as text
%        str2double(get(hObject,'String')) returns contents of power1_edit as a double
i=1+handles.LED_pagenum*5;

handles.LED_power(i)=str2double(get(hObject,'String'));
if isnan(handles.LED_power(i))==1
    handles.LED_power(i)=1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function power1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in optimizer_lux_label.
function optimizer_lux_label_Callback(hObject, eventdata, handles)
% hObject    handle to optimizer_lux_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


function lux_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lux_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lux_weight_edit as text
%        str2double(get(hObject,'String')) returns contents of lux_weight_edit as a double
val=str2double(get(hObject,'String'));
if isnan(val)==1
    handles.lux_optimizer_states{1}='Off';
    handles.lux_weight=1;
else
    handles.lux_optimizer_states{1}='On';
    handles.lux_weight=val;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function lux_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lux_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function lux_goal_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lux_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lux_goal_edit as text
%        str2double(get(hObject,'String')) returns contents of lux_goal_edit as a double
val=str2double(get(hObject,'String'));
if isnan(val)==1
    handles.lux_optimizer_states{2}='Off';
    handles.lux_goal=1;
else
    handles.lux_optimizer_states{2}='On';
    if val < 0
        val=1;
    end 
    handles.lux_goal=val;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function lux_goal_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lux_goal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in tab2_button.
function tab2_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.tab2Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

set(handles.tab2_button,'BackgroundColor',[.8 .88 .97])
set(handles.tab1_button,'BackgroundColor',[.94 .94 .94])

handles=refresh(hObject,eventdata,handles);
handles=refresh_color_space(hObject,eventdata,handles);
handles=replot_color_space(hObject,eventdata,handles);
guidata(hObject, handles);
end


% --- Executes on button press in tab1_button.
function tab1_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.tab1Panel,'Visible','on')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

set(handles.tab1_button,'BackgroundColor',[.8 .88 .97])
set(handles.tab2_button,'BackgroundColor',[.94 .94 .94])

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end


% --- Executes on selection change in spectrum_plot_dropdown.
function spectrum_plot_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to spectrum_plot_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spectrum_plot_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectrum_plot_dropdown
contents = cellstr(get(hObject,'String'));
handles.spectrum_plot_type=contents{get(hObject,'Value')};

handles=refresh_color_space(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function spectrum_plot_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrum_plot_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in CRI_weight_minmax_toggle.
function CRI_weight_minmax_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to CRI_weight_minmax_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.CRI_minmax(1) == 0
    handles.CRI_minmax(1) = 1;
else
    handles.CRI_minmax(1) = 0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes on button press in power_weight_minmax_toggle.
function power_weight_minmax_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to power_weight_minmax_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.power_minmax(1) == 0
    handles.power_minmax(1) = 1;
else
    handles.power_minmax(1) = 0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes on button press in dE_weight_minmax_toggle.
function dE_weight_minmax_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to dE_weight_minmax_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.dE_minmax(1) == 0
    handles.dE_minmax(1) = 1;
else
    handles.dE_minmax(1) = 0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes on button press in CRI_constraint_minmax_toggle.
function CRI_constraint_minmax_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to CRI_constraint_minmax_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.CRI_minmax(2) == 0
    handles.CRI_minmax(2) = 1;
else
    handles.CRI_minmax(2) = 0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes on button press in power_constraint_minmax_toggle.
function power_constraint_minmax_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to power_constraint_minmax_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.power_minmax(2) == 0
    handles.power_minmax(2) = 1;
else
    handles.power_minmax(2) = 0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end



% --- Executes on button press in dE_constraint_minmax_toggle.
function dE_constraint_minmax_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to dE_constraint_minmax_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.dE_minmax(2) == 0
    handles.dE_minmax(2) = 1;
else
    handles.dE_minmax(2) = 0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes on button press in lux_constraint_minmax_toggle.
function lux_constraint_minmax_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to lux_constraint_minmax_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.lux_minmax(2) == 0
    handles.lux_minmax(2) = 1;
else
    handles.lux_minmax(2) = 0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);


end


% --- Executes on button press in choose_NLEDs_checkbox.
function choose_NLEDs_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to choose_NLEDs_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of choose_NLEDs_checkbox
handles.choose_NLEDs=get(hObject,'Value');
if handles.choose_NLEDs == 1
   set(handles.minimize_NLEDs_checkbox,'Value',0)
   handles.minimize_NLEDs=0;
%    handles.simulation_activated=0;
%    set(handles.activate_simulation_checkbox,'Value',0)
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end


function choose_NLEDs_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to choose_NLEDs_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of choose_NLEDs_editbox as text
%        str2double(get(hObject,'String')) returns contents of choose_NLEDs_editbox as a double

handles.choose_NLEDs_value=str2double(get(hObject,'String'));
if isnan(handles.choose_NLEDs_value)==1
    handles.choose_NLEDs_value=size(handles.LED_data,2);
else    
    handles.choose_NLEDs_value=round(handles.choose_NLEDs_value);
end
set(handles.choose_NLEDs_editbox,'String',handles.choose_NLEDs_value)

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function choose_NLEDs_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to choose_NLEDs_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in minimize_NLEDs_checkbox.
function minimize_NLEDs_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to minimize_NLEDs_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of minimize_NLEDs_checkbox
handles.minimize_NLEDs=get(hObject,'Value');
if handles.minimize_NLEDs == 1
   set(handles.choose_NLEDs_checkbox,'Value',0)
   handles.choose_NLEDs=0;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end


% --- Executes on selection change in simulation_ideal_dropdown.
function simulation_ideal_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_ideal_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns simulation_ideal_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from simulation_ideal_dropdown
contents = cellstr(get(hObject,'String'));
handles.simulation_ideal_type=contents{get(hObject,'Value')};

handles=refresh_color_space(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function simulation_ideal_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_ideal_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in run_simulation.
function run_simulation_Callback(hObject, eventdata, handles)
% hObject    handle to run_simulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


function simulation_CRI_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_CRI_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_CRI_weight_edit as text
%        str2double(get(hObject,'String')) returns contents of simulation_CRI_weight_edit as a double
handles.simulation_CRI_increments(1)=str2double(get(hObject,'String'));
if isnan(handles.simulation_CRI_increments(1))==1
    handles.simulation_CRI_increments(1)=1;
    handles.simulation_CRI_states{1}='Off';
else    
    if handles.simulation_CRI_increments(1) < 0
        handles.simulation_CRI_increments(1)=1;
    end
    %handles.simulation_CRI_increments(1)=round(handles.simulation_CRI_increments(1));
    handles.simulation_CRI_states{1}='On';
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function simulation_CRI_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_CRI_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function simulation_power_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_power_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_power_weight_edit as text
%        str2double(get(hObject,'String')) returns contents of simulation_power_weight_edit as a double
handles.simulation_power_increments(1)=str2double(get(hObject,'String'));
if isnan(handles.simulation_power_increments(1))==1
    handles.simulation_power_increments(1)=1;
    handles.simulation_power_states{1}='Off';
else
    if handles.simulation_power_increments(1) < 0
        handles.simulation_power_increments(1)=1;
    end
    %handles.simulation_power_increments(1)=round(handles.simulation_power_increments(1));
    handles.simulation_power_states{1}='On';
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function simulation_power_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_power_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function simulation_dE_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_dE_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_dE_weight_edit as text
%        str2double(get(hObject,'String')) returns contents of simulation_dE_weight_edit as a double
handles.simulation_dE_increments(1)=str2double(get(hObject,'String'));
if isnan(handles.simulation_dE_increments(1))==1
    handles.simulation_dE_increments(1)=1;
    handles.simulation_dE_states{1}='Off';
else    
    if handles.simulation_dE_increments(1) < 0
        handles.simulation_dE_increments(1)=1;
    end
    %handles.simulation_dE_increments(1)=round(handles.simulation_dE_increments(1));
    handles.simulation_dE_states{1}='On';
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function simulation_dE_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_dE_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function simulation_CRI_constraint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_CRI_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_CRI_constraint_edit as text
%        str2double(get(hObject,'String')) returns contents of simulation_CRI_constraint_edit as a double
handles.simulation_CRI_increments(2)=str2double(get(hObject,'String'));
if isnan(handles.simulation_CRI_increments(2))==1
    handles.simulation_CRI_states{2}='Off';
    handles.simulation_CRI_increments(2)=1;
else
    if handles.simulation_CRI_increments(2) < 0
        handles.simulation_CRI_increments(2)=1;
    end
    handles.simulation_CRI_states{2}='On';
    %handles.simulation_CRI_increments(2)=round(handles.simulation_CRI_increments(2));
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function simulation_CRI_constraint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_CRI_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function simulation_power_constraint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_power_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_power_constraint_edit as text
%        str2double(get(hObject,'String')) returns contents of simulation_power_constraint_edit as a double
handles.simulation_power_increments(2)=str2double(get(hObject,'String'));
if isnan(handles.simulation_power_increments(2))==1
    handles.simulation_power_increments(2)=1;
    handles.simulation_power_states{2}='Off';
else
    if handles.simulation_power_increments(2) < 0
        handles.simulation_power_increments(2)=1;
    end
    %handles.simulation_power_increments(2)=round(handles.simulation_power_increments(2));
    handles.simulation_power_states{2}='On';
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function simulation_power_constraint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_power_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function simulation_dE_constraint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_dE_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_dE_constraint_edit as text
%        str2double(get(hObject,'String')) returns contents of simulation_dE_constraint_edit as a double
handles.simulation_dE_increments(2)=str2double(get(hObject,'String'));
if isnan(handles.simulation_dE_increments(2))==1
    handles.simulation_dE_increments(2)=1;
    handles.simulation_dE_states{2}='Off';
else    
    if handles.simulation_dE_increments(2) < 0
        handles.simulation_dE_increments(2)=1;
    end
    %handles.simulation_dE_increments(2)=round(handles.simulation_dE_increments(2));
    handles.simulation_dE_states{2}='On';
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function simulation_dE_constraint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_dE_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function simulation_lux_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_lux_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function simulation_lux_constraint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_lux_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_lux_constraint_edit as text
%        str2double(get(hObject,'String')) returns contents of simulation_lux_constraint_edit as a double
handles.simulation_lux_increments(2)=str2double(get(hObject,'String'));
if isnan(handles.simulation_lux_increments(2))==1
    handles.simulation_lux_increments(2)=1;
    handles.simulation_lux_states{2}='Off';
else
    if handles.simulation_lux_increments(2) < 0
        handles.simulation_lux_increments(2)=1;
    end
    %handles.simulation_lux_increments(2)=round(handles.simulation_lux_increments(2));
    handles.simulation_lux_states{2}='On';
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function simulation_lux_constraint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_lux_constraint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in simulation_CRI_weight_toggle.
function simulation_CRI_weight_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_CRI_weight_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.simulation_CRI_direction(1) == -1
    handles.simulation_CRI_direction(1) = 1;
else
    handles.simulation_CRI_direction(1) = -1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on button press in simulation_power_weight_toggle.
function simulation_power_weight_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_power_weight_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.simulation_power_direction(1) == -1
    handles.simulation_power_direction(1) = 1;
else
    handles.simulation_power_direction(1) = -1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on button press in simulation_dE_weight_toggle.
function simulation_dE_weight_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_dE_weight_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.simulation_dE_direction(1) == -1
    handles.simulation_dE_direction(1) = 1;
else
    handles.simulation_dE_direction(1) = -1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on button press in simulation_CRI_constraint_toggle.
function simulation_CRI_constraint_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_CRI_constraint_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.simulation_CRI_direction(2) == -1
    handles.simulation_CRI_direction(2) = 1;
else
    handles.simulation_CRI_direction(2) = -1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes on button press in simulation_power_constraint_toggle.
function simulation_power_constraint_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_power_constraint_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.simulation_power_direction(2) == -1
    handles.simulation_power_direction(2) = 1;
else
    handles.simulation_power_direction(2) = -1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on button press in simulation_dE_constraint_toggle.
function simulation_dE_constraint_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_dE_constraint_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.simulation_dE_direction(2) == -1
    handles.simulation_dE_direction(2) = 1;
else
    handles.simulation_dE_direction(2) = -1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end

% --- Executes on button press in simulation_lux_constraint_toggle.
function simulation_lux_constraint_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_lux_constraint_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.simulation_lux_direction(2) == -1
    handles.simulation_lux_direction(2) = 1;
else
    handles.simulation_lux_direction(2) = -1;
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end


function simulation_trials_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_trials_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_trials_editbox as text
%        str2double(get(hObject,'String')) returns contents of simulation_trials_editbox as a double
handles.simulation_trials=str2double(get(hObject,'String'));
if isnan(handles.simulation_trials)==1 || handles.simulation_trials < 1
    handles.simulation_trials=1;
else    
    handles.simulation_trials=round(handles.simulation_trials);
end
set(handles.simulation_trials_editbox,'String',handles.simulation_trials)

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function simulation_trials_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_trials_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function simulation_attempts_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_attempts_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulation_attempts_editbox as text
%        str2double(get(hObject,'String')) returns contents of simulation_attempts_editbox as a double
handles.simulation_attempts=str2double(get(hObject,'String'));
if isnan(handles.simulation_attempts)==1 || handles.simulation_attempts < 1
    handles.simulation_attempts=1;
else    
    handles.simulation_attempts=round(handles.simulation_attempts);
end
set(handles.simulation_attempts_editbox,'String',handles.simulation_attempts)

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);


end

% --- Executes during object creation, after setting all properties.
function simulation_attempts_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulation_attempts_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in activate_simulation_checkbox.
function activate_simulation_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to activate_simulation_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of activate_simulation_checkbox
handles.simulation_activated=get(hObject,'Value');

% if handles.simulation_activated == 1
%    handles.choose_NLEDs=0;
%    set(handles.choose_NLEDs_checkbox,'Value',0)
% end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);



end


% --- Executes on button press in daylight_checkbox.
function daylight_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to daylight_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of daylight_checkbox
handles.daylight_toggle=get(hObject,'Value');

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
end




% --- Executes on button press in optimizer_power_label.
function optimizer_power_label_Callback(hObject, eventdata, handles)
% hObject    handle to optimizer_power_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.optimize_power_type,'Power') == 1
    handles.optimize_power_type='LER';
elseif strcmp(handles.optimize_power_type,'LER') == 1
    handles.optimize_power_type='Power';   
end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

end
