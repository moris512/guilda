x1 = 0.963;
x2 = 0.667;
G = 1.365187713;
B = -11.60409556;

xi = [x1 0; 0 x2];
%Y = [G - B*i, -G + B*i; -G + B*i, G - B*i];
Ycon = conj(Y);

Gamma = xi - i*xi*Ycon*xi;
Gammainv = inv(Gamma)