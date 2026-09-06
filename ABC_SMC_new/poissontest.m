N = 200;   
upperw = 26;
lowerw = 18;
pdw = makedist('Beta','a',0.6,'b',0.6);
sample = random(pdw, 1, N) * (upperw-lowerw) + lowerw; 

histogram(sample)