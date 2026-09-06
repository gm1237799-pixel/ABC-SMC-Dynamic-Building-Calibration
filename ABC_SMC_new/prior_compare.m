clear;
clc;
pimuw    = [0.6; 0.18;    7;   21];
pisigmaw = [0.2; 0.06;  1.5;  1.5];
pimus    = [0.6; 0.18;    7;   26];
pisigmas = [0.2; 0.06;  1.5; 1.02];
lowerw = [0;  0;  0; 14];
upperw = [1;  1; 15; 26];
lowers = [0;  0;  0; 18];
uppers = [1;  1; 15; 30];

x1 = transpose( 0: 0.01:  1);
x2 = transpose( 0: 0.01:  1);
x3 = transpose( 0:  0.1: 15);
x4 = transpose(14:  0.1: 26);
x5 = transpose(18:  0.1: 30);

y1 = zeros(size(x1,1),4);
y2 = zeros(size(x2,1),4);
y3 = zeros(size(x3,1),4);
y4 = zeros(size(x4,1),4);
y5 = zeros(size(x5,1),4);

%% 正态分布
y1(:,1) = normpdf(x1,  0.6,  0.2);
y2(:,1) = normpdf(x2, 0.18, 0.06);
y3(:,1) = normpdf(x3,    7,  1.5);
y4(:,1) = normpdf(x4,   21,  1.5);
y5(:,1) = normpdf(x5,   26, 1.02);

%% 均匀分布
y1(:,2) = 1;
y2(:,2) = 1;
y3(:,2) = 1 / 15;
y4(:,2) = 1 / (26-14);
y5(:,2) = 1 / (30-18);

%% 三角分布
pd1 = makedist("Triangular","a",0,"b",0.3,"c",1);
pd2 = makedist("Triangular","a",0,"b",0.7,"c",1);
pd3 = makedist("Triangular","a",0,"b",3,"c",15);
pd4 = makedist("Triangular","a",14,"b",20,"c",26);
pd5 = makedist("Triangular","a",18,"b",22,"c",30);
y1(:,3) = pdf(pd1, x1);
y2(:,3) = pdf(pd2, x2);
y3(:,3) = pdf(pd3, x3);
y4(:,3) = pdf(pd4, x4);
y5(:,3) = pdf(pd5, x5);



%% beta分布

y1(:,4) = betapdf(x1, 0.6, 0.6);
y2(:,4) = betapdf(x2, 0.6, 0.6);
y3(:,4) = betapdf(x3/15, 0.6, 0.6)/15;
y4(:,4) = betapdf((x4-14)/(26-14), 0.6, 0.6)/(26-14);
y5(:,4) = betapdf((x5-18)/(30-18), 0.6, 0.6)/(30-18);

%% 画图
figure(5);
subplot(1, 5, 1);
hold on
for i = 1 : 4
    plot(x1,y1(:,i),'LineWidth',1.5);
end
hold off

subplot(1, 5, 2);
hold on
for i = 1 : 4
    plot(x2,y2(:,i),'LineWidth',1.5);
end
hold off

subplot(1, 5, 3);
hold on
for i = 1 : 4
    plot(x3,y3(:,i),'LineWidth',1.5);
end
hold off

subplot(1, 5, 4);
hold on
for i = 1 : 4
    plot(x4,y4(:,i),'LineWidth',1.5);
end
hold off

subplot(1, 5, 5);
hold on
for i = 1 : 4
    plot(x5,y5(:,i),'LineWidth',1.5);
end
hold off
