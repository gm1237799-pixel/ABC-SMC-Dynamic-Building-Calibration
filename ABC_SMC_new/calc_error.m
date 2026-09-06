% T = 10;
% T1 = T/2;
% N = 200;
% M = 213;
% day1 = 74;
% day2 = 166;
clear;
load('10-100-0.005.mat');
sumx = zeros(M,5);
numx = zeros(M,5);
indexs = zeros(N,T);
indexw = zeros(N,T);
calix = zeros(M,5);
for t = T1+1 : T
    t
    parfor parj = 1 : N
        dis = zeros(12,1);
        parsumx = zeros(N,M,5);
        parnumx = zeros(N,M,5);
        for j = 1 : day1
            scaledpara = mapminmax('apply', xw(:,parj,t), trainedinputs{j});
            scaledenergy = sim(trainedNetworks{j}, scaledpara);
            Y = mapminmax('reverse', scaledenergy, trainedoutputs{j});
            for i = 1 : 12
                dis(i) = abs((Y(i) - Y_target(i,j)) / Y_target(i,j));
            end
            if max(dis) < e(t)
                indexw(parj,t) = j;
            end   
        end

        for j = day1 + 1 : day2
            scaledpara = mapminmax('apply', xs(:,parj,t), trainedinputs{j});
            scaledenergy = sim(trainedNetworks{j}, scaledpara);
            Y = mapminmax('reverse', scaledenergy, trainedoutputs{j});
            for i = 1 : 12
                dis(i) = abs((Y(i) - Y_target(i,j)) / Y_target(i,j));
            end
            if max(dis) < e(t)
                indexs(parj,t) = j;
            end   
        end

        for j = day2 + 1 : M
            scaledpara = mapminmax('apply', xw(:,parj,t), trainedinputs{j});
            scaledenergy = sim(trainedNetworks{j}, scaledpara);
            Y = mapminmax('reverse', scaledenergy, trainedoutputs{j});
            for i = 1 : 12
                dis(i) = abs((Y(i) - Y_target(i,j)) / Y_target(i,j));
            end
            if max(dis) < e(t)
                indexw(parj,t) = j;
            end   
        end
    end
end

for t = T1+1 : T
    for i = 1 : N
        for k = 1 : 3
            sumx(indexs(i,t),k) = sumx(indexs(i,t),k) + xs(k,i,t);
            numx(indexs(i,t),k) = numx(indexs(i,t),k) + 1;
            sumx(indexw(i,t),k) = sumx(indexw(i,t),k) + xw(k,i,t);
            numx(indexw(i,t),k) = numx(indexw(i,t),k) + 1;
        end
        sumx(indexs(i,t),5) = sumx(indexs(i,t),5) + xs(4,i,t);
        numx(indexs(i,t),5) = numx(indexs(i,t),5) + 1;
        sumx(indexw(i,t),4) = sumx(indexw(i,t),4) + xw(4,i,t);
        numx(indexw(i,t),4) = numx(indexw(i,t),4) + 1;
    end
end

for j = 1 : M
    for k = 1 : 5
        if numx(j,k) > 0
            calix(j,k) = sumx(j,k) / numx(j,k);
        end
    end
end

%% 算参数的误差
RMSE = zeros(k,1);
NMBE = zeros(k,1);
for k = 1 : 5
    nn = 0;
    numerator1 = 0;
    numerator2 = 0;
    denominator = 0;
    for j = 1 : M
        if numx(j,k) > 0 
            nn = nn + 1;
            numerator1 = numerator1 + (x_target(k,j) - calix(j,k))^2;
            numerator2 = numerator2 + (x_target(k,j) - calix(j,k));
            denominator = denominator + x_target(k,j);
        end
    end
    RMSE(k) = (numerator1/(nn-1))^0.5 / (denominator/nn);
    NMBE(k) = (numerator2/(nn-1)) / (denominator/nn);
end

%% 算冬天的能耗误差
nn = 0;
numerator1 = 0;
numerator2 = 0;
denominator = 0;
calibratex = zeros(4,1);
for j = 1 : day1
    if numx(j,1) > 0 
        nn = nn + 1;
        calibratex(1,1) = calix(j,1);
        calibratex(2,1) = calix(j,2);
        calibratex(3,1) = calix(j,3);
        calibratex(4,1) = calix(j,4);
        scaledpara = mapminmax('apply', calibratex, trainedinputs{j});
        scaledenergy = sim(trainedNetworks{j}, scaledpara);
        Y = mapminmax('reverse', scaledenergy, trainedoutputs{j});
        for i = 1 : 12
            numerator1 = numerator1 + (Y(i) - Y_target(i,j))^2;
        end
        for i = 1 : 12
            numerator2 = numerator2 + (Y(i) - Y_target(i,j));
        end
        for i = 1 : 12
            denominator = denominator + Y_target(i,j);
        end
    end
end
for j = day2 + 1 : M
    if numx(j,1) > 0 
        nn = nn + 1;
        calibratex(1,1) = calix(j,1);
        calibratex(2,1) = calix(j,2);
        calibratex(3,1) = calix(j,3);
        calibratex(4,1) = calix(j,4);
        scaledpara = mapminmax('apply', calibratex, trainedinputs{j});
        scaledenergy = sim(trainedNetworks{j}, scaledpara);
        Y = mapminmax('reverse', scaledenergy, trainedoutputs{j});
        for i = 1 : 12
            numerator1 = numerator1 + (Y(i) - Y_target(i,j))^2;
        end
        for i = 1 : 12
            numerator2 = numerator2 + (Y(i) - Y_target(i,j));
        end
        for i = 1 : 12
            denominator = denominator + Y_target(i,j);
        end
    end
end

RMSEW = (numerator1/(nn*12-1))^0.5 / (denominator/nn/12);
NMBEW = (numerator2/(nn*12-1)) / (denominator/nn/12);

%% 算夏天的能耗误差
nn = 0;
numerator1 = 0;
numerator2 = 0;
denominator = 0;
for j = day1 + 1 : day2
    if numx(j,1) > 0 
        nn = nn + 1;
        calibratex(1,1) = calix(j,1);
        calibratex(2,1) = calix(j,2);
        calibratex(3,1) = calix(j,3);
        calibratex(4,1) = calix(j,5);
        scaledpara = mapminmax('apply', calibratex, trainedinputs{j});
        scaledenergy = sim(trainedNetworks{j}, scaledpara);
        Y = mapminmax('reverse', scaledenergy, trainedoutputs{j});
        for i = 1 : 12
            numerator1 = numerator1 + (Y(i) - Y_target(i,j))^2;
        end
        for i = 1 : 12
            numerator2 = numerator2 + (Y(i) - Y_target(i,j));
        end
        for i = 1 : 12
            denominator = denominator + Y_target(i,j);
        end
    end
end

RMSES = (numerator1/(nn*12-1))^0.5 / (denominator/nn/12);
NMBES = (numerator2/(nn*12-1)) / (denominator/nn/12);