function dim(u)

global light1 light2 light3 light4 light5 light6 light7 light8 light9 light10;

for i=1:length(u)
    if mod(i,5)==1
        u(i,1)=0.71*u(i,1)^3-0.54*u(i,1)^2+0.81*u(i,1);
    end
end
u=40000*u;

light1.SetLight(uint16(u(1,1)),uint16(u(2,1)),uint16(u(3,1)),uint16(u(4,1)),uint16(u(5,1)));
light2.SetLight(uint16(u(6,1)),uint16(u(7,1)),uint16(u(8,1)),uint16(u(9,1)),uint16(u(10,1)));
light3.SetLight(uint16(u(11,1)),uint16(u(12,1)),uint16(u(13,1)),uint16(u(14,1)),uint16(u(15,1)));
light4.SetLight(uint16(u(16,1)),uint16(u(17,1)),uint16(u(18,1)),uint16(u(19,1)),uint16(u(20,1)));
light5.SetLight(uint16(u(21,1)),uint16(u(22,1)),uint16(u(23,1)),uint16(u(24,1)),uint16(u(25,1)));
light6.SetLight(uint16(u(26,1)),uint16(u(27,1)),uint16(u(28,1)),uint16(u(29,1)),uint16(u(30,1)));
light7.SetLight(uint16(u(31,1)),uint16(u(32,1)),uint16(u(33,1)),uint16(u(34,1)),uint16(u(35,1)));
light8.SetLight(uint16(u(36,1)),uint16(u(37,1)),uint16(u(38,1)),uint16(u(39,1)),uint16(u(40,1)));
light9.SetLight(uint16(u(41,1)),uint16(u(42,1)),uint16(u(43,1)),uint16(u(44,1)),uint16(u(45,1)));
light10.SetLight(uint16(u(46,1)),uint16(u(47,1)),uint16(u(48,1)),uint16(u(49,1)),uint16(u(50,1)));