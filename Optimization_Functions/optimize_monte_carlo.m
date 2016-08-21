function [x,LED_N,optimization_finished]=optimize_monte_carlo(R,CRI_minmax,power_minmax,dE_minmax,lux_minmax,Aeq,beq,ub,lb,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,constraints,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,CIETCS1nm,DSPD,LED_power,LED_N,LED_lux,L0_norm_state,simulation_activated,simulation_trials_attempts,simulation_CRI_states,simulation_power_states,simulation_dE_states,simulation_lux_states,simulation_CRI_increments,simulation_power_increments,simulation_dE_increments,simulation_lux_increments,simulation_CRI_direction,simulation_power_direction,simulation_dE_direction,simulation_lux_direction)

    fval_results=[];
    x_results=[];
    for count=1:5
        x0=[-1 -1 -1];
        [x,LED_N,~,fval]=optimize_combined(R,x0,CRI_minmax,power_minmax,dE_minmax,lux_minmax,Aeq,beq,ub,lb,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,constraints,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,CIETCS1nm,DSPD,LED_power,LED_N,LED_lux,L0_norm_state,simulation_activated,simulation_trials_attempts,simulation_CRI_states,simulation_power_states,simulation_dE_states,simulation_lux_states,simulation_CRI_increments,simulation_power_increments,simulation_dE_increments,simulation_lux_increments,simulation_CRI_direction,simulation_power_direction,simulation_dE_direction,simulation_lux_direction);
        x_results=[x_results x'];
        fval_results=[fval_results fval];
    end
    best_fval=min(fval_results);
    x0=x_results(:,fval_results==best_fval);
            
    [x,LED_N,optimization_finished,fval]=optimize_combined(R,x0,CRI_minmax,power_minmax,dE_minmax,lux_minmax,Aeq,beq,ub,lb,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,constraints,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,CIETCS1nm,DSPD,LED_power,LED_N,LED_lux,L0_norm_state,simulation_activated,simulation_trials_attempts,simulation_CRI_states,simulation_power_states,simulation_dE_states,simulation_lux_states,simulation_CRI_increments,simulation_power_increments,simulation_dE_increments,simulation_lux_increments,simulation_CRI_direction,simulation_power_direction,simulation_dE_direction,simulation_lux_direction);

    
    
end

function [x,LED_N,optimization_finished,fval]=optimize_combined(R,x0,CRI_minmax,power_minmax,dE_minmax,lux_minmax,Aeq,beq,ub,lb,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,constraints,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,CIETCS1nm,DSPD,LED_power,LED_N,LED_lux,L0_norm_state,simulation_activated,simulation_trials_attempts,simulation_CRI_states,simulation_power_states,simulation_dE_states,simulation_lux_states,simulation_CRI_increments,simulation_power_increments,simulation_dE_increments,simulation_lux_increments,simulation_CRI_directions,simulation_power_directions,simulation_dE_directions,simulation_lux_directions) 

    function stop = outfun(x,optimValues,state)
        stats=['Number of Iterations: ' num2str(optimValues.iteration)];
        %1000=max iterations for interior point
        waitbar(optimValues.iteration/100,progress,stats)
        %disp(optimValues.iteration)
        stop = false; %getappdata(hObject,'optimstop');
        if getappdata(progress,'canceling')
           stop=true; 
        end
    end

    x0_input=x0;
    
    simulation_activated=0;
    %simulation_activated=0;
    if simulation_activated==0
    
        options = optimoptions('fmincon','Algorithm','interior-point','Display','Off','MaxIter',100,'OutputFcn', @outfun);%,'DerivativeCheck','on');
        
        %0 = not finished, 1=finished success, 2=finished failure
        optimization_finished=0;
        while optimization_finished==0
            if x0_input(1)==-1
                x0=rand(1,size(R,2))*mode(ub);
                x0=x0';
            end
            progress=waitbar(0,'0','Name','Optimizing LED multipliers...',...  
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

            f=@(x)combined_cost_function(x,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,CIETCS1nm,DSPD,LED_power,LED_N,L0_norm_state);        
            c=@(x)combined_constraint_function(x,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,LED_power,LED_N,LED_lux,cmf,Wavelength,g11,g22,g12,L0_norm_state);
            
            [x,fval,exitflag]=fmincon(f,x0',[],[],Aeq,beq,lb,ub,c,options);

            delete(progress)

            if exitflag == -2 || exitflag == 0
                choice = questdlg('No feasible solution found. Retry with new guess?', ...
                    'Optimization Failed', ...
                    'Yes','No','No');
                % Handle response
                if strcmp(choice,'No')==1
                    optimization_finished=2;
                end
            elseif max(x) >= .95
                choice = questdlg('Solution found, but one or more of the LEDs is near saturation. Increasing the number (N) of saturated LEDs and rerunning optimization could improve results.', ...
                    '', ...
                    'Increment N and rerun Optimization','Finish','Finish');
                % Handle response
                if strcmp(choice,'Finish')==1
                    optimization_finished=1;
                else
                    for i=1:size(LED_N,2)
                        if x(i) >= .95
                           LED_N(i)=LED_N(i)+1; 
                        end
                    end
                end
            else
                optimization_finished=1;
            end
        end
    

        
    end
    
end