global light1 light2 light3 light4 light5 light6 light7 light8 light9 light10;

% if(strcmp(light1.status,'closed'))
%     fopen(light1);
% end
% if(strcmp(light2.status,'closed'))
%     fopen(light2);
% end
% if(strcmp(light3.status,'closed'))
%     fopen(light3);
% end
% if(strcmp(light4.status,'closed'))
%     fopen(light4);
% end
% if(strcmp(light5.status,'closed'))
%     fopen(light5);
% end
% if(strcmp(light6.status,'closed'))
%     fopen(light6);
% end
% if(strcmp(light7.status,'closed'))
%     fopen(light7);
% end
% if(strcmp(light8.status,'closed'))
%     fopen(light8);
% end
% if(strcmp(light9.status,'closed'))
%     fopen(light9);
% end
% if(strcmp(light10.status,'closed'))
%     fopen(light10);
% end

light1=tcpip('192.168.0.111',57007);
light2=tcpip('192.168.0.112',57007);
light3=tcpip('192.168.0.113',57007);
light4=tcpip('192.168.0.114',57007);
light5=tcpip('192.168.0.115',57007);
light6=tcpip('192.168.0.116',57007);
light7=tcpip('192.168.0.117',57007);
light8=tcpip('192.168.0.118',57007);
light9=tcpip('192.168.0.119',57007);
light10=tcpip('192.168.0.120',57007);

fopen(light1);
fopen(light2);
fopen(light3);
fopen(light4);
fopen(light5);
fopen(light6);
fopen(light7);
fopen(light8);
fopen(light9);
fopen(light10);
