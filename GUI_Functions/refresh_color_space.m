function [handles]=refresh_color_space(hObject,eventdata,handles)
    rowNames={'  CCT  ','  CRI  ','  CQS  ','  LER  ','  GAI  ',''};
    table_data={
      handles.cct(1) handles.cct(2);...
      handles.CRI(1) handles.CRI(2);...
      handles.CQS(1) handles.CQS(2);...
      handles.LER(1) handles.LER(2);...
      handles.GAI(1) handles.GAI(2); [] []};

    set(handles.CIE_table,'Data',table_data)  
    set(handles.CIE_table,'RowName',rowNames)

    rowNames={'X','Y','Z','x','y','z','xy dE'};
    table_data={
    handles.X(1) handles.X(2);...
    handles.Y(1) handles.Y(2);...
    handles.Z(1) handles.Z(2);...
    handles.x(1) handles.x(2);...
    handles.y(1) handles.y(2);...
    handles.z(1) handles.z(2);...
    handles.xy_dE []};

    set(handles.xyY_table,'RowName',rowNames)
    set(handles.xyY_table,'Data',table_data)    
    
    rowNames={'u''','v''','u''v'' dE','u*','v*','L*','dE'};
    table_data={
    handles.LUV_u_prime(1) handles.LUV_u_prime(2);...
    handles.LUV_v_prime(1) handles.LUV_v_prime(2);...
    handles.uvChroma_dE [];...
    handles.LUV_u(1) handles.LUV_u(2);...
    handles.LUV_v(1) handles.LUV_v(2);...
    handles.LUV_L(1) handles.LUV_L(2);...
    handles.LUV_dE []};

    set(handles.LUV_table,'RowName',rowNames)
    set(handles.LUV_table,'Data',table_data)
        
    rowNames={'L*','a*','b*','dE76 ','dE94 ','dE00 '};
    table_data={
    handles.Lab_L(1) handles.Lab_L(2);...
    handles.a(1) handles.a(2);...
    handles.b(1) handles.b(2);...
    handles.dE76 [];handles.dE94 []; handles.dE00 []};

    set(handles.Lab_table,'RowName',rowNames)
    set(handles.Lab_table,'Data',table_data)          

%      if strcmp(handles.CIE_space,'UVW')==1
%         rowNames={'X','Y','Z','CCT','CRI','CQS','CFI','CSI','CDI','','u','v','W'};
%         CIE_table_data={
%         handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
%         handles.Z(1) handles.Z(2);handles.cct(1) handles.cct(2);...
%         handles.CRI(1) handles.CRI(2); handles.CQS(1) handles.CQS(2); [] [];[] []; [] [] ;[] []; handles.UVW_u(1) handles.UVW_u(2);...
%         handles.UVW_v(1) handles.UVW_v(2); handles.W(1) handles.W(2)};
%   
%         set(handles.CIE_table,'RowName',rowNames)
%         set(handles.CIE_table,'Data',CIE_table_data)
%              
%     end    

    rowNames={'R','G','B','Brightness Mod'};
    table_data={
    handles.R(1) handles.R(2);...
    handles.G(1) handles.G(2);...
    handles.B(1) handles.B(2);...
    handles.RGB_brightness_mod(1) handles.RGB_brightness_mod(2)};

    set(handles.RGB_table,'RowName',rowNames)
    set(handles.RGB_table,'Data',table_data)
         