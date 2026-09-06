mu = [0.5; 0.3; 9; 22; 25];
sigma = [0.1; 0.1; 1.2; 1; 0.5];
L = [0; 0;  0; 17; 22];
H = [1; 0.6; 15; 25; 30];
Nx = [20; 20; 20; 20; 20];
dx = (H - L) ./ Nx;
xn = zeros(5,max(Nx));
xx = zeros(5,max(Nx));
xsum = zeros(5,1);
x = zeros(5,N);
x(1:4,:) = xw(:,:,1);
x(5:5,:) = xs(4:4,:,1);
for k = 1 : 3
    for nx = 1 : Nx(k)
        xx(k,nx) = L(k) + (nx-1/2)*dx(k);
        for i = 1 : N
            for t = T1+1 : T
                if and(xw(k,i,t)>(L(k) +(nx-1) * dx(k)), xw(k,i,t) <=(L(k) +nx * dx(k)))
                    xn(k,nx) = xn(k,nx)+ bww(i,t);
                end
                if and(xs(k,i,t)>(L(k) +(nx-1) * dx(k)), xs(k,i,t) <=(L(k) +nx * dx(k)))
                    xn(k,nx) = xn(k,nx)+ bws(i,t);
                end
            end
        end
    end
end

k = 4;
for nx = 1 : Nx(k)
    xx(k,nx) = L(k) + (nx-1/2)*dx(k);
    for i = 1 : N
        for t = T1+1 : T
            if and(xw(k,i,t)>(L(k) +(nx-1) * dx(k)), xw(k,i,t) <=(L(k) +nx * dx(k)))
                xn(k,nx) = xn(k,nx)+ bww(i,t);
            end
        end
    end
end

k = 5;
for nx = 1 : Nx(k)
    xx(k,nx) = L(k) + (nx-1/2)*dx(k);
    for i = 1 : N
        for t = T1+1 : T
            if and(xs(k-1,i,t)>(L(k) +(nx-1) * dx(k)), xs(k-1,i,t) <=(L(k) +nx * dx(k)))
                xn(k,nx) = xn(k,nx)+ bws(i,t);
            end
        end
    end
end

for k = 1 : 5
    xsum(k) = sum(xn(k,1:Nx(k)));
    xn(k,1:Nx(k)) = xn(k,1:Nx(k)) / xsum(k) * Nx(k) / (H(k) - L(k));
end

figure(5);
% for k = 1 : 5
%     subplot(2,5,k);
%     hold on
%     histogram(x_target(k,:), 'BinEdges',L(k):dx(k):H(k), 'Normalization', 'pdf');
%     histogram(x(k,:,1), 'BinEdges',L(k):dx(k):H(k), 'Normalization', 'pdf');
%     bar(xx(k,1:Nx(k)),xn(k,1:Nx(k)),'FaceColor',[0.9290 0.6940 0.1250]);
% 
%     legend('target','prior','posterior');
%     hold off
% end

for i = 1 : 5
    subplot(1, 5, i);
    hold on
    % 求目标的密度函数
    [ft, xit] = ksdensity(x_target(i,:));
    plot(xit, ft, 'LineWidth',1.5);
    % 求初始迭代的密度函数
    [fs, xis] = ksdensity(x(i,:));
    plot(xis, fs, 'LineWidth',1.5);
    % 最终迭代的密度函数
    plot(xx(i,:), xn(i,:), 'LineWidth',1.5);

    legend('target','prior','posterior');
    hold off
end