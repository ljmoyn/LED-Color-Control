function dim_Std(u)

global light1 light2 light3 light4 light5 light6 light7 light8 light9 light10;
% 
fprintf(light1,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(3,1)),uint16(u(2,1)),uint16(u(4,1)),uint16(u(1,1)),uint16(u(5,1))));
fprintf(light2,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(8,1)),uint16(u(7,1)),uint16(u(9,1)),uint16(u(6,1)),uint16(u(10,1))));
fprintf(light3,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(13,1)),uint16(u(12,1)),uint16(u(14,1)),uint16(u(11,1)),uint16(u(15,1))));
fprintf(light4,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(18,1)),uint16(u(17,1)),uint16(u(19,1)),uint16(u(16,1)),uint16(u(20,1))));
fprintf(light5,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(23,1)),uint16(u(22,1)),uint16(u(24,1)),uint16(u(21,1)),uint16(u(25,1))));
fprintf(light6,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(28,1)),uint16(u(27,1)),uint16(u(29,1)),uint16(u(26,1)),uint16(u(30,1))));
fprintf(light7,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(33,1)),uint16(u(32,1)),uint16(u(34,1)),uint16(u(31,1)),uint16(u(35,1))));
fprintf(light8,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(38,1)),uint16(u(37,1)),uint16(u(39,1)),uint16(u(36,1)),uint16(u(40,1))));
fprintf(light9,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(43,1)),uint16(u(42,1)),uint16(u(44,1)),uint16(u(41,1)),uint16(u(45,1))));
fprintf(light10,sprintf('PS%.4x%.4x%.4x%.4x%.4x',uint16(u(48,1)),uint16(u(47,1)),uint16(u(49,1)),uint16(u(46,1)),uint16(u(50,1))));

a1=fread(light1,7);
a2=fread(light2,7);
a3=fread(light3,7);
a4=fread(light4,7);
a5=fread(light5,7);
a6=fread(light6,7);
a7=fread(light7,7);
a8=fread(light8,7);
a9=fread(light9,7);
a10=fread(light10,7);