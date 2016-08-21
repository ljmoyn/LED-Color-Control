function [x,LED_N,optimization_finished,LED_state,fval]=optimize_combined(R,CRI_minmax,power_minmax,dE_minmax,lux_minmax,Aeq,beq,ub,lb,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,constraints,power_type,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,LED_power,LED_N,LED_lux,L0_norm_state,simulation_activated,simulation_trials_attempts,simulation_CRI_states,simulation_power_states,simulation_dE_states,simulation_lux_states,simulation_CRI_increments,simulation_power_increments,simulation_dE_increments,simulation_lux_increments,simulation_CRI_directions,simulation_power_directions,simulation_dE_directions,simulation_lux_directions) 
%     clc
%      x0=[.9437 .5492 .7284 .5768 .0259];
%      disp(CQS_fun(x0,R,CIETCS1nm,DSPD,cmf,Wavelength,90,'maximize',1))
    %[f,ceq] = LER_fun();

    LED_state=zeros(size(R,2));
    fval=0;
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

    function stop = outfun_alt(x,optimValues,state)
        %stats=['Number of Iterations: ' num2str(optimValues.iteration)];
        %1000=max iterations for interior point
        %waitbar(optimValues.iteration/100,progress,stats)
        %disp(optimValues.iteration)
        stop = false; %getappdata(hObject,'optimstop');
        if getappdata(progress,'canceling')
           stop=true; 
        end
    end

    %no simulation, just a single optimization
    if simulation_activated==0
    
        options = optimoptions('fmincon','Algorithm','interior-point','Display','Off','MaxIter',100,'OutputFcn', @outfun);%,'DerivativeCheck','on');
        
        %choose how to solve the L0 constrain optimization
        %1=pure brute force
        %2=sina's algorithm
        optim_type=1;
        
        %if you aren't using the L0 norm as a constraint
        if length(L0_norm_state)==1
            %0 = not finished, 1=finished success, 2=finished failure
            optimization_finished=0;
            while optimization_finished==0
                      
                x0=rand(1,size(R,2))*mode(ub);        

                progress=waitbar(0,'0','Name','Optimizing LED multipliers...',...  
                'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

                f=@(x)combined_cost_function(x,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,LED_power,LED_N,L0_norm_state);        
                c=@(x)combined_constraint_function(x,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,power_type,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,LED_power,LED_N,LED_lux,cmf,Wavelength,g11,g22,g12,vl1924e1nm,L0_norm_state);

                [x,fval,exitflag]=fmincon(f,x0,[],[],Aeq,beq,lb,ub,c,options);

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
        
        elseif optim_type==1
%             options = optimoptions('fmincon','Algorithm','interior-point','Display','Off','MaxIter',100);            
%             x0=rand(1,size(R,2))*mode(ub);        
%             f=@(keepers)combined_cost_function(keepers,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,CIETCS1nm,DSPD,LED_power,LED_N,L0_norm_state);        
%             c=@(keepers)combined_constraint_function(keepers,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,LED_power,LED_N,LED_lux,cmf,Wavelength,g11,g22,g12,L0_norm_state);
% 
%             [keepers,fval,exitflag]=fmincon(f,x0,[],[],Aeq,beq,lb,ub,c,options);
%             bright_LED=find(keepers==max(keepers));
            options = optimoptions('fmincon','Algorithm','interior-point','Display','Off','MaxIter',100,'OutputFcn', @outfun_alt);            
            
            
            %L0 constraint optimization
            temp=zeros(1,size(R,2));
            temp=find(temp==0);            

            combinations=get_combinations([],temp,L0_norm_state(2),[]);
%             temp_combinations=ones(size(combinations,1),1);
%             for i=1:size(combinations,1)
%                 if isempty(find(combinations(i,:)==bright_LED,1)) == 1
%                    temp_combinations(i)=0; 
%                 end
%             end
%             combinations=combinations(temp_combinations==1,:);
                       
            function_results=[];
            x_results=[];
            LED_state=zeros(1,size(R,2));
            success_counter=0;
            
            progress=waitbar(0,'0','Name','',...  
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)'); 
            setappdata(progress,'canceling',0)
            for i=1:size(combinations,1)

                %waitbar(progress,'','Name',strjoin({'Optimizing combination ' num2str(i) '/' num2str(size(combinations,1))}))
                waitbar(i/size(combinations,1),progress,strjoin({'Optimizing combination' num2str(i) '/' num2str(size(combinations,1))}))
                if getappdata(progress,'canceling')
                    break
                end
                
                LED_state(:)=0;
                for j=1:size(combinations(i,:),2)
                    LED_state(combinations(i,j))=1;
                end

                temp_R=ones(size(R,1),size(LED_state(LED_state >=1),2));
                temp_LED_N=ones(size(LED_state(LED_state >=1)));
                temp_LED_lux=ones(size(LED_state(LED_state >=1)));
                temp_LED_power=ones(size(LED_state(LED_state >=1)));
                k=1;
                for n=1:size(R,2)
                    if LED_state(n)>=1
                        temp_R(:,k)=R(:,n);
                        temp_LED_N(k)=LED_N(n);
                        temp_LED_lux(k)=LED_lux(n);
                        temp_LED_power(k)=LED_power(n);
                        k=k+1;
                    end
                end

                temp_lb=zeros(1,size(LED_state(LED_state >= 1),2));
                temp_ub=ones(1,size(LED_state(LED_state >= 1),2));

                temp_Aeq=zeros(size(LED_state(LED_state >= 1),2),size(LED_state(LED_state >= 1),2));
                temp_beq=zeros(size(LED_state(LED_state >= 1),2),1);

                x0=rand(1,size(temp_R,2))*mode(temp_ub);        

                f=@(x)combined_cost_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,temp_LED_power,temp_LED_N,L0_norm_state);        
                c=@(x)combined_constraint_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,power_type,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,temp_LED_power,temp_LED_N,temp_LED_lux,cmf,Wavelength,g11,g22,g12,vl1924e1nm,L0_norm_state);

                [x,fval,exitflag]=fmincon(f,x0,[],[],temp_Aeq,temp_beq,temp_lb,temp_ub,c,options);
                if exitflag ~= -2 && exitflag ~= 0
                   success_counter=success_counter+1; 
                   cost_function=combined_cost_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,temp_LED_power,temp_LED_N,L0_norm_state);
                else
                   cost_function=1000000;
                end
                function_results=[function_results cost_function];
                x_results=[x_results;x];


            end
            delete(progress)

            if success_counter > 0
                best_choice=min(function_results);
                x=x_results(function_results==best_choice,:);
                LED_state(:)=0;
                for j=1:size(combinations(function_results==best_choice,:),2)
                    LED_state(combinations(function_results==best_choice,j))=1;
                end
            else
                popup=msgbox({'No solutions found, consider adjusting parameters'});
                x=ones(size(LED_state));
                LED_state(:)=1;
            end
            

            optimization_finished=1;

        else
            %%%
% Algorithm for L0
%Start with sets of 1LED, find the LED that fits cost function the best
%then use optimize with that LED and each of the remaining. Pick the best
%set of two
%Optimize those two LEDs with the remaining LEDS, pick the best 3 etc etc
%introduce constraints near the final round
            options = optimoptions('fmincon','Algorithm','interior-point','Display','Off','MaxIter',100,'OutputFcn', @outfun_alt);        
            
            x_confirmed=[];
            x=[];
            LED_state=[];           
            while length(x_confirmed)<L0_norm_state(2) 
                temp=zeros(1,size(R,2));
                temp=find(temp==0);            

                combinations=get_combinations([],temp,length(x_confirmed)+1,[]);
                temp_combinations=ones(size(combinations,1),1);
                for i=1:size(combinations,1)
                    for j=1:length(x_confirmed)
                        if isempty(find(combinations(i,:)==x_confirmed(j),1)) == 1
                           temp_combinations(i)=0; 
                        end
                    end
                end
                combinations=combinations(temp_combinations==1,:);                
                
                function_results=[];
                x_results=[];
                LED_state=zeros(1,size(R,2));
                success_counter=0;

                progress=waitbar(0,'0','Name','',...  
                'CreateCancelBtn','setappdata(gcbf,''canceling'',1)'); 
                setappdata(progress,'canceling',0)
                for i=1:size(combinations,1)

                    %waitbar(progress,'','Name',strjoin({'Optimizing combination ' num2str(i) '/' num2str(size(combinations,1))}))
                    waitbar(i/size(combinations,1),progress,strjoin({'Optimizing combination' num2str(i) '/' num2str(size(combinations,1))}))
                    if getappdata(progress,'canceling')
                        break
                    end

                    LED_state(:)=0;
                    for j=1:size(combinations(i,:),2)
                        LED_state(combinations(i,j))=1;
                    end

                    temp_R=ones(size(R,1),size(LED_state(LED_state >=1),2));
                    temp_LED_N=ones(size(LED_state(LED_state >=1)));
                    temp_LED_lux=ones(size(LED_state(LED_state >=1)));
                    temp_LED_power=ones(size(LED_state(LED_state >=1)));
                    k=1;
                    for n=1:size(R,2)
                        if LED_state(n)>=1
                            temp_R(:,k)=R(:,n);
                            temp_LED_N(k)=LED_N(n);
                            temp_LED_lux(k)=LED_lux(n);
                            temp_LED_power(k)=LED_power(n);
                            k=k+1;
                        end
                    end

                    temp_lb=zeros(1,size(LED_state(LED_state >= 1),2));
                    temp_ub=ones(1,size(LED_state(LED_state >= 1),2));

                    temp_Aeq=zeros(size(LED_state(LED_state >= 1),2),size(LED_state(LED_state >= 1),2));
                    temp_beq=zeros(size(LED_state(LED_state >= 1),2),1);

                    x0=rand(1,size(temp_R,2))*mode(temp_ub);        

                    f=@(x)combined_cost_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,temp_LED_power,temp_LED_N,L0_norm_state);        
                    
                    if length(x_confirmed)==L0_norm_state(2)-1
                        c=@(x)combined_constraint_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,power_type,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,temp_LED_power,temp_LED_N,temp_LED_lux,cmf,Wavelength,g11,g22,g12,vl1924e1nm,L0_norm_state);
                    else
                        c=[];
                    end
                    [x,fval,exitflag]=fmincon(f,x0,[],[],temp_Aeq,temp_beq,temp_lb,temp_ub,c,options);
                    if exitflag ~= -2 && exitflag ~= 0
                       success_counter=success_counter+1; 
                       cost_function=combined_cost_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,ideal_xy,ideal_LUV,ideal_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,temp_LED_power,temp_LED_N,L0_norm_state);
                    else
                       cost_function=1000000;
                    end
                    function_results=[function_results cost_function];
                    x_results=[x_results;x];


                end
                delete(progress)            
                best_choice=min(function_results);
                x_confirmed=combinations(function_results==best_choice,:);
                if length(x_confirmed)==L0_norm_state(2)
                   x=x_results(function_results==best_choice,:);
                   LED_state(:)=0;
                   LED_state(x_confirmed)=1;
                else
                   x=[]; 
                end
            end
            
            optimization_finished=1;
            
        end
    
    else
        
        if length(L0_norm_state)==1
            optimization_finished=2;

            CRI_final=[];
            dE_final=[];
            power_final=[];
            CCT_final=[];
            x_final=[];
            constraints_orig=constraints;
            weights_orig=weights;

            options = optimoptions('fmincon','Algorithm','interior-point','MaxIter',100,'Display','Off');
            trials=0;
            while trials < simulation_trials_attempts(1)

                if trials~=0
                    if strcmp(simulation_CRI_states(2),'On')==1
                        constraints(1)=constraints(1)+simulation_CRI_directions(2)*simulation_CRI_increments(2);
                    end
                    if strcmp(simulation_CRI_states(1),'On')==1
                        weights(1)=weights(1)+simulation_CRI_directions(1)*simulation_CRI_increments(1);
                    end

                    if strcmp(simulation_power_states(2),'On')==1
                        constraints(2)=constraints(2)+simulation_power_directions(2)*simulation_power_increments(2);
                    end
                    if strcmp(simulation_power_states(1),'On')==1
                        weights(2)=weights(2)+simulation_power_directions(1)*simulation_power_increments(1);
                    end

                    if strcmp(simulation_dE_states(2),'On')==1
                        constraints(3)=constraints(3)+simulation_dE_directions(2)*simulation_dE_increments(2);
                    end
                    if strcmp(simulation_dE_states(1),'On')==1
                        weights(3)=weights(3)+simulation_dE_directions(1)*simulation_dE_increments(1);
                    end

                    if strcmp(simulation_lux_states(2),'On')==1
                        constraints(4)=constraints(4)+simulation_lux_directions(2)*simulation_lux_increments(2);
                    end
                    if strcmp(simulation_lux_states(1),'On')==1
                        weights(4)=weights(4)+simulation_lux_directions(1)*simulation_lux_increments(1);
                    end

                    weights_orig=[weights_orig;weights];
                    constraints_orig=[constraints_orig;constraints];

                end            

                CRI_results=[];
                dE_results=[];
                power_results=[];
                CCT_range=[];
                x_results=[];

                progress=waitbar(0,'','Name',strcat('Optimizing trial',' ',num2str(trials+1)));
                for CCT=3000:100:7000

                    nrefspd = get_nrefspd(CCT,DSPD,Wavelength,560);
                    CCTspd=nrefspd(:,2)/100;
                    [bbX,bbY,bbZ,bbx,bby,~]...
                        =getXYZxyz(CCTspd,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength); 
                    blackbody_xy=[bbx bby];

                    [bb_LUV_L,bb_LUV_u,bb_LUV_v,bb_LUV_u_prime,bb_LUV_v_prime]...
                        =getLUV_uprime_vprime(bbX,bbY,bbZ,standard_xy(1),standard_xy(2));
                    blackbody_LUV=[bb_LUV_L bb_LUV_u bb_LUV_v];

                    [bb_Lab_L,bba,bbb]...
                        =getLab(bbX,bbY,bbZ,standard_xy(1),standard_xy(2));
                    blackbody_Lab=[bb_Lab_L bba bbb];
                    if ~ishandle(progress)
                        break
                    else
                        if CCT < 5000 
                            waitbar(CCT/7000,progress,strjoin({'Matching color of' num2str(CCT) 'k ideal blackbody'}))
                        else
                            waitbar(CCT/7000,progress,strjoin({'Matching color of' num2str(CCT) 'k daylight spd'}))
                        end
                    end

                    f=[];
                    xtotal=[];

                    for count=1:simulation_trials_attempts(2)
                        x0=rand(1,size(R,2))*mode(ub);
                        %disp([weights;constraints])

                        cost=@(x)combined_cost_function(x,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,blackbody_xy,blackbody_LUV,blackbody_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,LED_power,LED_N,L0_norm_state);
                        constr=@(x)combined_constraint_function(x,R.*repmat(LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,power_type,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,blackbody_xy,blackbody_LUV,blackbody_Lab,LED_power,LED_N,LED_lux,cmf,Wavelength,g11,g22,g12,vl1924e1nm,L0_norm_state);

                        [x,fval,exitflag]=fmincon(cost,x0,[],[],Aeq,beq,lb,ub,constr,options);

                        if exitflag ~= -2
                            f=[f fval];
                            xtotal=[xtotal x'];
                        else
                            f=[f 10000];
                            xtotal=[xtotal 2*ones(length(x),1)];
                        end
                    end

                    xmin=xtotal(:,f==min(f));
    %                 if CCT >= 3300 && CCT <=4000
    %                    disp(CCT)
    %                    disp(xmin)
    %                 end
                    if size(xmin,2) > 1
                       xmin=xmin(:,1); 
                    end

                    if mode(xmin)==2
                        CCT_range=[CCT_range -1];
                    else    
                        CCT_range=[CCT_range CCT];
                    end
                        testSPD=R*xmin;

                        [X,Y,Z,xluv,yluv,~]...
                            =getXYZxyz(testSPD,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength);               

                        [LUV_L,LUV_u,LUV_v,LUV_u_prime,LUV_v_prime]...
                            =getLUV_uprime_vprime(X,Y,Z,standard_xy(1),standard_xy(2));

                        tempCCT=getCCT(xluv,yluv);
                        %disp([xluv yluv tempCCT])

                        nrefspd = get_nrefspd(tempCCT,DSPD,Wavelength,560);

                        [Ra,~] = get_cri1995(testSPD,nrefspd(:,2),cmf,CIETCS1nm,Wavelength);

                        [CQS] = get_CQS(testSPD,nrefspd(:,2),cmf,CIETCS1nm,Wavelength,tempCCT);

                        [Lab_L,a,b]...
                            =getLab(X,Y,Z,standard_xy(1),standard_xy(2));               

                        power=LED_power*xmin;
                        LER=get_LER(testSPD,vl1924e1nm,Wavelength);
                        GAI=get_GAI(testSPD,cmf,CIETCS1nm,Wavelength);      


                        LUV_dE=getdE_LUV(bb_LUV_L,LUV_L,bb_LUV_u,LUV_u,bb_LUV_v,LUV_v);
                        [dE76,~,~]=...
                            getdE_Lab(bb_Lab_L,Lab_L,bba,a,bbb,b);
                        JND=getJNDs(testSPD,bbx,bby,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength,g11,g22,g12);

                        if strcmp(CRI_type,'CRI') == 1
                            CRI_results=[CRI_results Ra];
                        elseif strcmp(CRI_type,'CQS') == 1
                            CRI_results=[CRI_results CQS];
                        elseif strcmp(CRI_type,'GAI') == 1
                            CRI_results=[CRI_results GAI];                        
                        end
                        if strcmp(dE_type,'JND') == 1
                            dE_results=[dE_results JND];
                        elseif strcmp(dE_type,'LUV') == 1
                            dE_results=[dE_results LUV_dE];
                        elseif strcmp(dE_type,'Lab') == 1
                            dE_results=[dE_results dE76];                    
                        end
                        if strcmp(power_type,'Power')==1
                            power_results=[power_results power];
                        elseif strcmp(power_type,'LER')==1
                            power_results=[power_results LER];                        
                        end
                        x_results=[x_results xmin];

                end

                if ishandle(progress)
                    delete(progress)    
                end

                CRI_final=[CRI_final; CRI_results];
                power_final=[power_final; power_results];  
                dE_final=[dE_final; dE_results];
                CCT_final=[CCT_final; CCT_range];
                x_final=[x_final; x_results];

                trials=trials+1;
            end

            figure()
            hold on
            color_index=1;
            for i=1:size(CRI_final,1)
                colors='rgbcymk';
                CCT_temp=CCT_final(i,:);
                CRI_temp=CRI_final(i,:);

                CRI_temp(CCT_temp==-1)=[];
                CCT_temp(CCT_temp==-1)=[];

                plot(CCT_temp,CRI_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
                color_index=color_index+1;
            end
            xlabel('CCT (k)')

            if strcmp(CRI_type,'CRI')==1
                title('CRI Results')
                ylabel('CRI')
            elseif strcmp(CRI_type,'CQS')==1
                title('CQS Results')
                ylabel('CQS')
            elseif strcmp(CRI_type,'GAI')==1
                title('GAI Results')
                ylabel('GAI')            
            end

            legend_entries=repmat({''},1,simulation_trials_attempts(1));

            for i=1:simulation_trials_attempts(1)
                if strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'On')
                    CRI_entry=strcat(CRI_type,'[',num2str(weights_orig(i,1)),',',num2str(constraints_orig(i,1)),']');
                elseif strcmp(CRI_optimizer_states(1),'Off')==1 && strcmp(CRI_optimizer_states(2),'On')
                    CRI_entry=strcat(CRI_type,'[Off,',num2str(constraints_orig(i,1)),']');
                elseif strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'Off')    
                    CRI_entry=strcat(CRI_type,'[',num2str(weights_orig(i,1)),',Off]');
                else
                    CRI_entry='';
                end
                if strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'On')
                    power_entry=strcat(power_type,'[',num2str(weights_orig(i,2)),',',num2str(constraints_orig(i,2)),']');
                elseif strcmp(power_optimizer_states(1),'Off')==1 && strcmp(power_optimizer_states(2),'On')
                    power_entry=strcat(power_type,'[Off,',num2str(constraints_orig(i,2)),']');
                elseif strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'Off')    
                    power_entry=strcat(power_type,'[',num2str(weights_orig(i,2)),',Off]');
                else
                    power_entry='';
                end

                if strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'On')
                    dE_entry=strcat('  dE[',num2str(weights_orig(i,3)),',',num2str(constraints_orig(i,3)),']');
                elseif strcmp(dE_optimizer_states(1),'Off')==1 && strcmp(dE_optimizer_states(2),'On')
                    dE_entry=strcat('  dE[Off,',num2str(constraints_orig(i,3)),']');
                elseif strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'Off')    
                    dE_entry=strcat('  dE[',num2str(weights_orig(i,3)),',Off]');
                else
                    dE_entry='';
                end              

                if strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'On')
                    lux_entry=strcat('  Lux[',num2str(weights_orig(i,4)),',',num2str(constraints_orig(i,4)),']');
                elseif strcmp(lux_optimizer_states(1),'Off')==1 && strcmp(lux_optimizer_states(2),'On')
                    lux_entry=strcat('  Lux[Off,',num2str(constraints_orig(i,4)),']');
                elseif strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'Off')    
                    lux_entry=strcat('  Lux[',num2str(weights_orig(i,4)),',Off]');
                else
                    lux_entry='';
                end            

                legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);
            end
            legend(legend_entries)

            figure()
            hold on
            color_index=1;
            for i=1:size(power_final,1)
                colors='rgbcymk';
                CCT_temp=CCT_final(i,:);
                power_temp=power_final(i,:);

                power_temp(CCT_temp==-1)=[];
                CCT_temp(CCT_temp==-1)=[];

                plot(CCT_temp,power_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
                color_index=color_index+1;
            end
            title('Power Results')
            xlabel('CCT (k)')
            if strcmp(power_type,'Power')==1
                title('Power Results')
                ylabel('Power (W)')
            elseif strcmp(power_type,'LER')==1
                title('LER Results')
                ylabel('LER')         
            end                
            legend(legend_entries)        

            figure()
            hold on
            color_index=1;
            for i=1:size(CRI_final,1)
                colors='rgbcymk';

                CCT_temp=CCT_final(i,:);
                dE_temp=dE_final(i,:);

                dE_temp(CCT_temp==-1)=[];
                CCT_temp(CCT_temp==-1)=[];            

                plot(CCT_temp,dE_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
                color_index=color_index+1;
            end
            xlabel('CCT (k)')
            if strcmp(dE_type,'JND')==1
                title('JND Results')
                ylabel('JNDs')
            elseif strcmp(dE_type,'LUV')==1
                title('LUV dE Results')
                ylabel('LUV Color Difference')
            elseif strcmp(dE_type,'Lab')==1
                title('Lab dE Results')
                ylabel('Lab Color Difference')
            end

            legend(legend_entries)

            trials=simulation_trials_attempts(1);
            attempts=simulation_trials_attempts(2);

            weights=weights_orig;
            constraints=constraints_orig;

            save('data.mat','CCT_final','CRI_final','power_final','dE_final','weights','constraints','trials','attempts','x_final')

    %         figure()
    %         hold on
    %         color_index=1;
    %         for i=1:size(power_final,1)
    % 
    %             colors='rgbcymk';
    %             plot(CCT_range,power_final(i,:),'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
    %             color_index=color_index+1;
    %         end
    %         title('Power Results (rgbw)')
    %         xlabel('CCT (k)')
    %         ylabel('Power (W)')
    %         legend('power weight: 0','power weight: 2','power weight: 4','power weight: 6','power weight: 8','power weight: 10','power weight: 100')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            optimization_finished=2;

            CRI_final=[];
            dE_final=[];
            power_final=[];
            CCT_final=[];
            x_final=[];
            constraints_orig=constraints;
            weights_orig=weights;

            options = optimoptions('fmincon','Algorithm','interior-point','MaxIter',100,'Display','Off');
            trials=0;
            while trials < simulation_trials_attempts(1)

                if trials~=0
                    if strcmp(simulation_CRI_states(2),'On')==1
                        constraints(1)=constraints(1)+simulation_CRI_directions(2)*simulation_CRI_increments(2);
                    end
                    if strcmp(simulation_CRI_states(1),'On')==1
                        weights(1)=weights(1)+simulation_CRI_directions(1)*simulation_CRI_increments(1);
                    end

                    if strcmp(simulation_power_states(2),'On')==1
                        constraints(2)=constraints(2)+simulation_power_directions(2)*simulation_power_increments(2);
                    end
                    if strcmp(simulation_power_states(1),'On')==1
                        weights(2)=weights(2)+simulation_power_directions(1)*simulation_power_increments(1);
                    end

                    if strcmp(simulation_dE_states(2),'On')==1
                        constraints(3)=constraints(3)+simulation_dE_directions(2)*simulation_dE_increments(2);
                    end
                    if strcmp(simulation_dE_states(1),'On')==1
                        weights(3)=weights(3)+simulation_dE_directions(1)*simulation_dE_increments(1);
                    end

                    if strcmp(simulation_lux_states(2),'On')==1
                        constraints(4)=constraints(4)+simulation_lux_directions(2)*simulation_lux_increments(2);
                    end
                    if strcmp(simulation_lux_states(1),'On')==1
                        weights(4)=weights(4)+simulation_lux_directions(1)*simulation_lux_increments(1);
                    end

                    weights_orig=[weights_orig;weights];
                    constraints_orig=[constraints_orig;constraints];

                end            

                CRI_results=[];
                dE_results=[];
                power_results=[];
                CCT_range=[];
                x_results=[];

                progress=waitbar(0,'','Name',strcat('Optimizing trial',' ',num2str(trials+1)));
                for CCT=3000:100:7000

                    nrefspd = get_nrefspd(CCT,DSPD,Wavelength,560);
                    CCTspd=nrefspd(:,2)/100;
                    [bbX,bbY,bbZ,bbx,bby,~]...
                        =getXYZxyz(CCTspd,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength); 
                    blackbody_xy=[bbx bby];

                    [bb_LUV_L,bb_LUV_u,bb_LUV_v,bb_LUV_u_prime,bb_LUV_v_prime]...
                        =getLUV_uprime_vprime(bbX,bbY,bbZ,standard_xy(1),standard_xy(2));
                    blackbody_LUV=[bb_LUV_L bb_LUV_u bb_LUV_v];

                    [bb_Lab_L,bba,bbb]...
                        =getLab(bbX,bbY,bbZ,standard_xy(1),standard_xy(2));
                    blackbody_Lab=[bb_Lab_L bba bbb];
                    if ~ishandle(progress)
                        break
                    else
                        if CCT < 5000 
                            waitbar(CCT/7000,progress,strjoin({'Matching color of' num2str(CCT) 'k ideal blackbody'}))
                        else
                            waitbar(CCT/7000,progress,strjoin({'Matching color of' num2str(CCT) 'k daylight spd'}))
                        end
                    end

                    f=[];
                    xtotal=[];

                    for count=1:simulation_trials_attempts(2)
                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        x_confirmed=[];
                        x=[];
                        LED_state=[];           
                        while length(x_confirmed)<L0_norm_state(2) 
                            temp=zeros(1,size(R,2));
                            temp=find(temp==0);            

                            combinations=get_combinations([],temp,length(x_confirmed)+1,[]);
                            temp_combinations=ones(size(combinations,1),1);
                            for i=1:size(combinations,1)
                                for j=1:length(x_confirmed)
                                    if isempty(find(combinations(i,:)==x_confirmed(j),1)) == 1
                                       temp_combinations(i)=0; 
                                    end
                                end
                            end
                            combinations=combinations(temp_combinations==1,:);                

                            function_results=[];
                            x_output=[];
                            LED_state=zeros(1,size(R,2));
                            success_counter=0;

                            for i=1:size(combinations,1)

                                LED_state(:)=0;
                                for j=1:size(combinations(i,:),2)
                                    LED_state(combinations(i,j))=1;
                                end

                                temp_R=ones(size(R,1),size(LED_state(LED_state >=1),2));
                                temp_LED_N=ones(size(LED_state(LED_state >=1)));
                                temp_LED_lux=ones(size(LED_state(LED_state >=1)));
                                temp_LED_power=ones(size(LED_state(LED_state >=1)));
                                k=1;
                                for n=1:size(R,2)
                                    if LED_state(n)>=1
                                        temp_R(:,k)=R(:,n);
                                        temp_LED_N(k)=LED_N(n);
                                        temp_LED_lux(k)=LED_lux(n);
                                        temp_LED_power(k)=LED_power(n);
                                        k=k+1;
                                    end
                                end

                                temp_lb=zeros(1,size(LED_state(LED_state >= 1),2));
                                temp_ub=ones(1,size(LED_state(LED_state >= 1),2));

                                temp_Aeq=zeros(size(LED_state(LED_state >= 1),2),size(LED_state(LED_state >= 1),2));
                                temp_beq=zeros(size(LED_state(LED_state >= 1),2),1);

                                x0=rand(1,size(temp_R,2))*mode(temp_ub);        

                                cost=@(x)combined_cost_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,blackbody_xy,blackbody_LUV,blackbody_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,temp_LED_power,temp_LED_N,L0_norm_state);        

                                if length(x_confirmed)==L0_norm_state(2)-1
                                    constraint=@(x)combined_constraint_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,constraints,power_type,dE_type,CRI_type,CIETCS1nm,DSPD,standard_xy,blackbody_xy,blackbody_LUV,blackbody_Lab,temp_LED_power,temp_LED_N,temp_LED_lux,cmf,Wavelength,g11,g22,g12,vl1924e1nm,L0_norm_state);
                                else
                                    constraint=[];
                                end
                                [x,fval,exitflag]=fmincon(cost,x0,[],[],temp_Aeq,temp_beq,temp_lb,temp_ub,constraint,options);
                                if exitflag ~= -2 && exitflag ~= 0
                                   success_counter=success_counter+1; 
                                   cost_function=combined_cost_function(x,temp_R.*repmat(temp_LED_N,max(size(Wavelength)),1),CRI_minmax,power_minmax,dE_minmax,lux_minmax,CRI_optimizer_states,power_optimizer_states,dE_optimizer_states,lux_optimizer_states,weights,power_type,dE_type,CRI_type,standard_xy,blackbody_xy,blackbody_LUV,blackbody_Lab,cmf,Wavelength,g11,g22,g12,vl1924e1nm,CIETCS1nm,DSPD,temp_LED_power,temp_LED_N,L0_norm_state);
                                else
                                   cost_function=10000;
                                end
                                function_results=[function_results cost_function];
                                x_output=[x_output;x];


                            end
                            best_choice=min(function_results);
                            x_confirmed=combinations(function_results==best_choice,:);
                            if best_choice==10000
                               x_confirmed=x_confirmed(1,:); 
                            end
                            if length(x_confirmed)==L0_norm_state(2)
                               x=x_output(function_results==best_choice,:);
                               LED_state(:)=0;
                               LED_state(x_confirmed)=1;
                            else
                               x=[];
                            end
                        end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
                        if best_choice < 10000
                            f=[f function_results(function_results==best_choice)];
                            xtotal=[xtotal x'];
                        else
                            f=[f 10000];
                            xtotal=[xtotal 2*ones(L0_norm_state(2),1)];
                        end
                    end

                    xmin=xtotal(:,f==min(f));

                    if size(xmin,2) > 1
                       xmin=xmin(:,1); 
                    end

                    if mode(xmin)==2
                        CCT_range=[CCT_range -1];
                    else    
                        CCT_range=[CCT_range CCT];
                    end
                    
                        testSPD=R(:,LED_state>=1)*xmin;

                        [X,Y,Z,xluv,yluv,~]...
                            =getXYZxyz(testSPD,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength);               

                        [LUV_L,LUV_u,LUV_v,LUV_u_prime,LUV_v_prime]...
                            =getLUV_uprime_vprime(X,Y,Z,standard_xy(1),standard_xy(2));

                        tempCCT=getCCT(xluv,yluv);
                        %disp([xluv yluv tempCCT])

                        nrefspd = get_nrefspd(tempCCT,DSPD,Wavelength,560);

                        [Ra,~] = get_cri1995(testSPD,nrefspd(:,2),cmf,CIETCS1nm,Wavelength);

                        [CQS] = get_CQS(testSPD,nrefspd(:,2),cmf,CIETCS1nm,Wavelength,tempCCT);

                        [Lab_L,a,b]...
                            =getLab(X,Y,Z,standard_xy(1),standard_xy(2));               

                        power=LED_power(LED_state>=1)*xmin;
                        LER=get_LER(testSPD,vl1924e1nm,Wavelength);
                        GAI=get_GAI(testSPD,cmf,CIETCS1nm,Wavelength);      


                        LUV_dE=getdE_LUV(bb_LUV_L,LUV_L,bb_LUV_u,LUV_u,bb_LUV_v,LUV_v);
                        [dE76,~,~]=...
                            getdE_Lab(bb_Lab_L,Lab_L,bba,a,bbb,b);
                        JND=getJNDs(testSPD,bbx,bby,cmf(:,1),cmf(:,2),cmf(:,3),Wavelength,g11,g22,g12);

                        if strcmp(CRI_type,'CRI') == 1
                            CRI_results=[CRI_results Ra];
                        elseif strcmp(CRI_type,'CQS') == 1
                            CRI_results=[CRI_results CQS];
                        elseif strcmp(CRI_type,'GAI') == 1
                            CRI_results=[CRI_results GAI];                        
                        end
                        if strcmp(dE_type,'JND') == 1
                            dE_results=[dE_results JND];
                        elseif strcmp(dE_type,'LUV') == 1
                            dE_results=[dE_results LUV_dE];
                        elseif strcmp(dE_type,'Lab') == 1
                            dE_results=[dE_results dE76];                    
                        end
                        if strcmp(power_type,'Power')==1
                            power_results=[power_results power];
                        elseif strcmp(power_type,'LER')==1
                            power_results=[power_results LER];                        
                        end
                        x_results=[x_results xmin];

                end

                if ishandle(progress)
                    delete(progress)    
                end

                CRI_final=[CRI_final; CRI_results];
                power_final=[power_final; power_results];  
                dE_final=[dE_final; dE_results];
                CCT_final=[CCT_final; CCT_range];
                x_final=[x_final; x_results];

                trials=trials+1;
            end

            figure()
            hold on
            color_index=1;
            for i=1:size(CRI_final,1)
                colors='rgbcymk';
                CCT_temp=CCT_final(i,:);
                CRI_temp=CRI_final(i,:);

                CRI_temp(CCT_temp==-1)=[];
                CCT_temp(CCT_temp==-1)=[];

                plot(CCT_temp,CRI_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
                color_index=color_index+1;
            end
            xlabel('CCT (k)')

            if strcmp(CRI_type,'CRI')==1
                title('CRI Results')
                ylabel('CRI')
            elseif strcmp(CRI_type,'CQS')==1
                title('CQS Results')
                ylabel('CQS')
            elseif strcmp(CRI_type,'GAI')==1
                title('GAI Results')
                ylabel('GAI')            
            end

            legend_entries=repmat({''},1,simulation_trials_attempts(1));

            for i=1:simulation_trials_attempts(1)
                if strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'On')
                    CRI_entry=strcat(CRI_type,'[',num2str(weights_orig(i,1)),',',num2str(constraints_orig(i,1)),']');
                elseif strcmp(CRI_optimizer_states(1),'Off')==1 && strcmp(CRI_optimizer_states(2),'On')
                    CRI_entry=strcat(CRI_type,'[Off,',num2str(constraints_orig(i,1)),']');
                elseif strcmp(CRI_optimizer_states(1),'On')==1 && strcmp(CRI_optimizer_states(2),'Off')    
                    CRI_entry=strcat(CRI_type,'[',num2str(weights_orig(i,1)),',Off]');
                else
                    CRI_entry='';
                end
                if strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'On')
                    power_entry=strcat(power_type,'[',num2str(weights_orig(i,2)),',',num2str(constraints_orig(i,2)),']');
                elseif strcmp(power_optimizer_states(1),'Off')==1 && strcmp(power_optimizer_states(2),'On')
                    power_entry=strcat(power_type,'[Off,',num2str(constraints_orig(i,2)),']');
                elseif strcmp(power_optimizer_states(1),'On')==1 && strcmp(power_optimizer_states(2),'Off')    
                    power_entry=strcat(power_type,'[',num2str(weights_orig(i,2)),',Off]');
                else
                    power_entry='';
                end

                if strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'On')
                    dE_entry=strcat('  dE[',num2str(weights_orig(i,3)),',',num2str(constraints_orig(i,3)),']');
                elseif strcmp(dE_optimizer_states(1),'Off')==1 && strcmp(dE_optimizer_states(2),'On')
                    dE_entry=strcat('  dE[Off,',num2str(constraints_orig(i,3)),']');
                elseif strcmp(dE_optimizer_states(1),'On')==1 && strcmp(dE_optimizer_states(2),'Off')    
                    dE_entry=strcat('  dE[',num2str(weights_orig(i,3)),',Off]');
                else
                    dE_entry='';
                end              

                if strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'On')
                    lux_entry=strcat('  Lux[',num2str(weights_orig(i,4)),',',num2str(constraints_orig(i,4)),']');
                elseif strcmp(lux_optimizer_states(1),'Off')==1 && strcmp(lux_optimizer_states(2),'On')
                    lux_entry=strcat('  Lux[Off,',num2str(constraints_orig(i,4)),']');
                elseif strcmp(lux_optimizer_states(1),'On')==1 && strcmp(lux_optimizer_states(2),'Off')    
                    lux_entry=strcat('  Lux[',num2str(weights_orig(i,4)),',Off]');
                else
                    lux_entry='';
                end            

                legend_entries{i}=strcat(CRI_entry,power_entry,dE_entry,lux_entry);
            end
            legend(legend_entries)

            figure()
            hold on
            color_index=1;
            for i=1:size(power_final,1)
                colors='rgbcymk';
                CCT_temp=CCT_final(i,:);
                power_temp=power_final(i,:);

                power_temp(CCT_temp==-1)=[];
                CCT_temp(CCT_temp==-1)=[];

                plot(CCT_temp,power_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
                color_index=color_index+1;
            end
            title('Power Results')
            xlabel('CCT (k)')
            if strcmp(power_type,'Power')==1
                title('Power Results')
                ylabel('Power (W)')
            elseif strcmp(power_type,'LER')==1
                title('LER Results')
                ylabel('LER')         
            end                
            legend(legend_entries)        

            figure()
            hold on
            color_index=1;
            for i=1:size(CRI_final,1)
                colors='rgbcymk';

                CCT_temp=CCT_final(i,:);
                dE_temp=dE_final(i,:);

                dE_temp(CCT_temp==-1)=[];
                CCT_temp(CCT_temp==-1)=[];            

                plot(CCT_temp,dE_temp,'Marker','o','MarkerEdgeColor',colors(color_index),'MarkerFaceColor',colors(color_index),'LineWidth',2,'Color',colors(color_index))
                color_index=color_index+1;
            end
            xlabel('CCT (k)')
            if strcmp(dE_type,'JND')==1
                title('JND Results')
                ylabel('JNDs')
            elseif strcmp(dE_type,'LUV')==1
                title('LUV dE Results')
                ylabel('LUV Color Difference')
            elseif strcmp(dE_type,'Lab')==1
                title('Lab dE Results')
                ylabel('Lab Color Difference')
            end

            legend(legend_entries)

            trials=simulation_trials_attempts(1);
            attempts=simulation_trials_attempts(2);

            weights=weights_orig;
            constraints=constraints_orig;

            save('data.mat','CCT_final','CRI_final','power_final','dE_final','weights','constraints','trials','attempts','x_final')
    
    
        end
        
        
    end
    
end