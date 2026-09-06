function sa = sampling(w, N)
    sumw = zeros(1, N);
    sumw(1) = w(1);
    for i = 2 : N
        sumw(i) = sumw(i-1) + w(i);
    end
	r = rand;
	max = N;
	min = 1;
	while max - min > 1
        average = int32( round((max+min)/2) );
        if sumw(average) > r 
            max = average;
        else
            min = average;
        end
	end
	sa = max;
end