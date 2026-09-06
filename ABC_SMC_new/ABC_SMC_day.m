clc;
clear;
T = 10;
T1 = T/2;
N = 200;
Ncore = 94;
M = 213;
xs = zeros(4 ,N, T);
xw = zeros(4 ,N, T);
e = zeros(T,1);
ws = zeros(N, T);
ww = zeros(N, T);
bws = zeros(N, T);
bww = zeros(N, T);
bsw = zeros(M, T);
bss = zeros(M, T);
sigmaw = zeros(4,1);
sigmas = zeros(4,1);
day1 = 74;
day2 = 166;
load("input.mat");
load("net.mat");
load("output.mat");
Y_target = zeros(12,213);
rej = 0;


%% ------------------算Y_target---------------
load('x_target.mat');
x_targetw = x_target(1:4, :);
x_targets = x_target([1:3,5:5], :);
for i = 1 : day1
    scaledpara = mapminmax('apply', x_targetw(:,i), trainedinputs{i});
    scaledenergy = sim(trainedNetworks{i}, scaledpara);
    Y_target(:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
end
for i = day1 + 1 : day2
    scaledpara = mapminmax('apply', x_targets(:,i), trainedinputs{i});
    scaledenergy = sim(trainedNetworks{i}, scaledpara);
    Y_target(:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
end
for i = day2 + 1 : 213
    scaledpara = mapminmax('apply', x_targetw(:,i), trainedinputs{i});
    scaledenergy = sim(trainedNetworks{i}, scaledpara);
    Y_target(:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
end


%% --------初始参数抽样，初始化--------------
pimuw    = [0.6; 0.18;    7;   21];
pisigmaw = [0.2; 0.06;  1.5;  1.5];
pimus    = [0.6; 0.18;    7;   26];
pisigmas = [0.2; 0.06;  1.5; 1.02];
target_p = 0.01;
lowerw = [0;  0;  0; 14];
upperw = [1;  1; 15; 26];
lowers = [0;  0;  0; 18];
uppers = [1;  1; 15; 30];

traw = [0.3; 0.7; 3; 20];
tras = [0.3; 0.7; 3; 22];

for k = 1 : 4

    % % 正态分布
    % p = max( target_p, normcdf(0, pimuw(k), pisigmaw(k)));
    % xw(k, : , 1) = LHSsampling(p, pimuw(k), pisigmaw(k), N);
    % p = max( target_p, normcdf(0, pimus(k), pisigmas(k)));
    % xs(k, : , 1) = LHSsampling(p, pimus(k), pisigmas(k), N);

    % % 均匀分布
    % xw(k, : , 1) = linspace(pimuw(k)-3*pisigmaw(k), pimuw(k)+3*pisigmaw(k), N);
    % xs(k, : , 1) = linspace(pimus(k)-3*pisigmas(k), pimus(k)+3*pisigmas(k), N);
    
    % % 三角分布
    % pd = makedist("Triangular","a",lowerw(k),"b",traw(k),"c",upperw(k));
    % xw(k, : , 1) = random(pd, 1, N);
    % pd = makedist("Triangular","a",lowers(k),"b",tras(k),"c",uppers(k));
    % xs(k, : , 1) = random(pd, 1, N);

    % Beta分布
    pd = makedist('Beta','a',0.6,'b',0.6);
    xw(k, : , 1) = random(pd, 1, N) * (upperw(k)-lowerw(k)) + lowerw(k);
    xs(k, : , 1) = random(pd, 1, N) * (uppers(k)-lowers(k)) + lowers(k);

end


ww(: , : , 1) = 1 / N;
ws(: , : , 1) = 1 / N;

%% ------------设置e(t)----------------

d = 0.01;
for t = 1 : T1
    e(t) = 0.4 * (d/0.4)^((t-1)/(T1-1));
end
for t = T1 + 1 : T
    e(t) = e(T1);
end

%% ------------正式计算--------------
Ncalcw = 0;
Ncalcs = 0;
for t = 2 : T
    %% ------------算冬天------------
    for k = 1 : 4
        sigmaw(k) = (var(xw(k,:,t-1)))^0.5;
    end
    bbw = zeros(N, M);
    parx = xw( :, :, t-1);
    parw = ww(:, t-1);

    calcedw = 0;
    while calcedw < N

        %采集并行计算结果
        flag = zeros(Ncore,1);     
        parxx = zeros(4,Ncore);
        pbb = zeros(Ncore,M);
    %% ---------------并行计算-------------------
        parfor i = 1 : Ncore
            parbb = zeros(1, M);
            xstar = zeros(4,1);
            dis = zeros(12,1);
            pflag = 0;
            while pflag == 0
                pflag = 1;
                sa = sampling(parw(:), N);
                xstar = parx(:,sa);
                xstar = xstar + mvnrnd([0;0;0;0],diag(sigmaw),1)';           
                for k = 1 : 4
                    if or(xstar(k) >upperw(k) , xstar(k) < lowerw(k))
                        pflag = 0;
                    end
                end
            end

            pflag = 0;
            %-------------计算距离---------------
            for parj = 1 : day1
                scaledpara = mapminmax('apply', xstar, trainedinputs{parj});
                scaledenergy = sim(trainedNetworks{parj}, scaledpara);
                Y = mapminmax('reverse', scaledenergy, trainedoutputs{parj});
                for idx = 1 : 12
                    dis(idx) = abs((Y(idx) - Y_target(idx,parj)) / Y_target(idx,parj));
                end
                if max(dis) < e(t)
                    parbb(parj) = 1;
                    pflag = 1;
                else
                    parbb(parj) = 0;
                end   
            end

            for parj = day2 + 1 : 213
                scaledpara = mapminmax('apply', xstar, trainedinputs{parj});
                scaledenergy = sim(trainedNetworks{parj}, scaledpara);
                Y = mapminmax('reverse', scaledenergy, trainedoutputs{parj});
                for idx = 1 : 12
                    dis(idx) = abs((Y(idx) - Y_target(idx,parj)) / Y_target(idx,parj));
                end
                if max(dis) < e(t)
                    parbb(parj) = 1;
                    pflag = 1;
                else
                    parbb(parj) = 0;
                end   
            end
            %------------------------------------------
            pbb(i,:) = parbb;    
            parxx(:,i) = xstar;
            flag(i) = pflag;   
        end

    %% --------------并行结束，处理结果--------------------- 
        for ii = 1 : Ncore
            if and(flag(ii) == 1, calcedw < N)
                calcedw = calcedw + 1;
                xw( :, calcedw, t) = parxx(:,ii);
                bbw(calcedw,:) = pbb(ii,:); 
            end
        end
        [t, calcedw, 1]
        Ncalcw = Ncalcw + Ncore;
        rejratew = (Ncalcw - (t-2)*N - calcedw) / Ncalcw
    end

    %% --------算夏天--------------
    for k = 1 : 4
        sigmas(k) = (var(xs(k,:,t-1)))^0.5;
    end
    bbs = zeros(N, M);
    parx = xs( :, :, t-1);
    parw = ws(:, t-1);

    calceds = 0;
    while calceds < N

        %采集并行计算结果
        flag = zeros(Ncore,1);     
        parxx = zeros(4,Ncore);
        pbb = zeros(Ncore,M);
    %% ---------------并行计算-------------------
        parfor i = 1 : Ncore
            parbb = zeros(1, M);
            xstar = zeros(4,1);
            dis = zeros(12,1);
            pflag = 0;
            while pflag == 0
                pflag = 1;
                sa = sampling(parw(:), N);
                xstar = parx(:,sa);
                xstar = xstar + mvnrnd([0;0;0;0],diag(sigmas),1)';           
                for k = 1 : 4
                    if or(xstar(k) > uppers(k) , xstar(k) < lowers(k))
                        pflag = 0;
                    end
                end
            end

            pflag = 0;
            %-------------计算距离---------------
            for parj = day1 + 1 : day2
                scaledpara = mapminmax('apply', xstar, trainedinputs{parj});
                scaledenergy = sim(trainedNetworks{parj}, scaledpara);
                Y = mapminmax('reverse', scaledenergy, trainedoutputs{parj});
                for idx = 1 : 12
                    dis(idx) = abs((Y(idx) - Y_target(idx,parj)) / Y_target(idx,parj));
                end
                if max(dis) < e(t)
                    parbb(parj) = 1;
                    pflag = 1;
                else
                    parbb(parj) = 0;
                end   
            end

            %------------------------------------------
            pbb(i,:) = parbb;    
            parxx(:,i) = xstar;
            flag(i) = pflag;   
        end

    %% --------------并行结束，处理结果--------------------- 
        for ii = 1 : Ncore
            if and(flag(ii) == 1, calceds < N)
                calceds = calceds + 1;
                xs( :, calceds, t) = parxx(:,ii);
                bbs(calceds,:) = pbb(ii,:); 
            end
        end
        [t, calceds, 2]
        Ncalcs = Ncalcs + Ncore;
        rejrates = (Ncalcs - (t-2)*N - calceds) / Ncalcs
    end


    bsw(:,t) = sum(bbw, 1);
    for i = 1 : N
        s = 0;
        for j = 1 : M
            if bsw(j,t) > 0
                bww(i,t) =bww(i,t) + bbw(i,j) / bsw(j,t);
            end
        end
        for k = 1 : N
            s = s + ww(k,t-1) * mvnpdf(xw(:,i,t), xw(:,k,t-1), diag(sigmaw));
        end
        ww(i,t) = bww(i,t) / s;
    end
	sws = sum(ww(:,t));
	ww(:,t) = ww(:,t) ./sws;

    bss(:,t) = sum(bbs, 1);
    for i = 1 : N
        s = 0;
        for j = 1 : M
            if bss(j,t) > 0
                bws(i,t) =bws(i,t) + bbs(i,j) / bss(j,t);
            end
        end
        for k = 1 : N
            s = s + ws(k,t-1) * mvnpdf(xs(:,i,t), xs(:,k,t-1), diag(sigmas));
        end
        ws(i,t) = bws(i,t) / s;
    end
	sws = sum(ws(:,t));
	ws(:,t) = ws(:,t) ./sws;

end
post;
save('10-200-0.01-beta分布.mat');
