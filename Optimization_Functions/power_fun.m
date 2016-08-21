function [f,ceq] = power_fun(x,LED_power,LED_N,power_goal,mode,minmax)
    if strcmp(mode,'minimize')==1
        if minmax(1)==1
            f=-sum(x.*LED_power.*LED_N);
            ceq=[];            
        else
            f=sum(x.*LED_power.*LED_N);
            ceq=[];
        end
    else
        if minmax(2) ==1
            f=-1*(sum(x.*LED_power.*LED_N)-power_goal);
            ceq=[];
        else
            f=sum(x.*LED_power.*LED_N)-power_goal;
            ceq=[];
        end
    end

end