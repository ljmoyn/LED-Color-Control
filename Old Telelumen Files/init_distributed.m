clc;
load('Data');

N_LED=10;
N_Sensor=53;

WP=[1;1;1];
T=[-0.14282 1.54924 -0.95641 ; -0.32466 1.57837 -0.73191 ; -0.68202 0.77073 0.56332];
T_bl=T;
for q=1:(N_LED)-1
    T_bl=blkdiag(T_bl,T);
end
% 
TLH1=RobotRaconteur.Connect('tcp://192.168.0.118:3443/{0}/TelelumenHost');
TLH2=RobotRaconteur.Connect('tcp://192.168.0.119:3443/{0}/TelelumenHost');
TLH3=RobotRaconteur.Connect('tcp://192.168.0.120:3443/{0}/TelelumenHost');
TLH4=RobotRaconteur.Connect('tcp://192.168.0.121:3443/{0}/TelelumenHost');
TLH5=RobotRaconteur.Connect('tcp://192.168.0.122:3443/{0}/TelelumenHost');
TLH6=RobotRaconteur.Connect('tcp://192.168.0.123:3443/{0}/TelelumenHost');
TLH7=RobotRaconteur.Connect('tcp://192.168.0.124:3443/{0}/TelelumenHost');
TLH8=RobotRaconteur.Connect('tcp://192.168.0.125:3443/{0}/TelelumenHost');
TLH9=RobotRaconteur.Connect('tcp://192.168.0.126:3443/{0}/TelelumenHost');
TLH10=RobotRaconteur.Connect('tcp://192.168.0.127:3443/{0}/TelelumenHost');

global light1 light2 light3 light4 light5 light6 light7 light8 light9 light10;
light1=TLH1.get_Lights('192.168.2.2');
light2=TLH2.get_Lights('192.168.2.2');
light3=TLH3.get_Lights('192.168.2.2');
light4=TLH4.get_Lights('192.168.2.2');
light5=TLH5.get_Lights('192.168.2.2');
light6=TLH6.get_Lights('192.168.2.2');
light7=TLH7.get_Lights('192.168.2.2');
light8=TLH8.get_Lights('192.168.2.2');
light9=TLH9.get_Lights('192.168.2.2');
light10=TLH10.get_Lights('192.168.2.2');