function result = LHSsampling(p, mu, sigma, N)
    result = zeros(N,1);
    x = zeros(N+1,1); 
    delta = (1 - 2*p) / N;
    for i = 1 : N+1
        x(i) = norminv(p + delta*(i-1), mu, sigma);
    end
    dx = lhsdesign(N, 1);
    j = randperm(N);
    for i = 1 : N
        result(j(i)) = x(i) + (x(i+1) - x(i)) * dx(i);
    end
end