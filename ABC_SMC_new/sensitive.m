load("input.mat");
load("net.mat");
load("output.mat");
mu    = [0.5; 0.3;   9;  22;  25];
sigma = [0.1; 0.1; 1.2;   1; 0.5];
day1 = 74;
day2 = 166;
M = 213;
target = zeros(12,M);
energy1 = zeros(100,12,M);
energy2 = zeros(100,12,M);
energy3 = zeros(100,12,M);
energy4 = zeros(100,12,M);
energy5 = zeros(100,12,M);
x = zeros(100,5);
for i = 1 : 5
    x(:,i) = linspace(mu(i)-3*sigma(i), mu(i)+3*sigma(i), 100);
end
%% ---------目标能耗-----------
for i = 1 : day1
    scaledpara = mapminmax('apply', mu(1:4), trainedinputs{i});
    scaledenergy = sim(trainedNetworks{i}, scaledpara);
    target(:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
end
for i = day1+1 : day2
    scaledpara = mapminmax('apply', mu([1:3,5:5]), trainedinputs{i});
    scaledenergy = sim(trainedNetworks{i}, scaledpara);
    target(:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
end
for i = day2+1 : M
    scaledpara = mapminmax('apply', mu(1:4), trainedinputs{i});
    scaledenergy = sim(trainedNetworks{i}, scaledpara);
    target(:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
end
%% ---------对比能耗计算---------
%--------参数1-------
for j = 1 : 100
    j
    para =  mu(1:4);
    para(1) = x(j,1);
    for i = 1 : day1
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy1(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(5);
    for i = day1+1 : day2
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy1(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(4);
    for i = day2+1 : M
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy1(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
end
%-------参数2----------
for j = 1 : 100
    100+j
    para =  mu(1:4);
    para(2) = x(j,2);
    for i = 1 : day1
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy2(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(5);
    for i = day1+1 : day2
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy2(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(4);
    for i = day2+1 : M
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy2(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
end
%----------参数3-----------------
for j = 1 : 100
    200+j
    para =  mu(1:4);
    para(3) = x(j,3);
    for i = 1 : day1
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy3(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(5);
    for i = day1+1 : day2
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy3(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(4);
    for i = day2+1 : M
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy3(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
end
%--------参数4-----------
for j = 1 : 100
    300+j
    para =  mu(1:4);
    para(4) = x(j,4);
    for i = 1 : day1
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy4(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(5);
    for i = day1+1 : day2
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy4(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = x(j,4);
    for i = day2+1 : M
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy4(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
end
%-----------参数5--------------
for j = 1 : 100
    400+j
    para =  mu(1:4);
    for i = 1 : day1
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy5(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = x(j,5);
    for i = day1+1 : day2
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy5(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
    para(4) = mu(4);
    for i = day2+1 : M
        scaledpara = mapminmax('apply', para, trainedinputs{i});
        scaledenergy = sim(trainedNetworks{i}, scaledpara);
        energy5(j,:,i) = mapminmax('reverse', scaledenergy, trainedoutputs{i});
    end
end

%-----------计算误差-----------