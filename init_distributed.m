clc; N_LED=10; N_Sensor=53;

try
    close_port;
catch
    fprintf('Light Ports Already Closed\n');
end
open_port;