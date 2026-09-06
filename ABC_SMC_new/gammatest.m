pd = makedist('Gamma','a',0.6^2/0.2^2,'b',0.2^2/0.6); % 创建一个gamma分布对象
sample = zeros(1,213);
i = 1;
while i <=213
  sample(i) = random(pd, 1, 1);  % 从该分布中抽样
  if sample(i)<1
      i = i+1;
  end
end
mean(sample)
histogram(sample)