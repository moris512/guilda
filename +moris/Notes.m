x1 = 0.963;
x2 = 0.667;
%G = 1.365187713310580;
%B = -11.604095563139930;


%Y = [G - B*i, -G + B*i; -G + B*i, G - B*i];
Ycon = conj(Y);

Gamma = xi - 1i*xi*Ycon*xi;
Gammainv = inv(Gamma);
Bred = -real(Gammainv(1,2));
Gred = imag(Gammainv(1,2));
v1star = 2;
v2star = 1.999884106216756;
delta1star = -0.117919635325941;
omega1star = 0;
delta2star = 0.094729837775605;
omega2star = 0;
Pmech1star = -v1star*v2star*Bred*sin(delta1star-delta2star)+v1star*v2star*Gred*cos(delta1star-delta2star);
Pmech2star = -v1star*v2star*Bred*sin(delta2star-delta1star)+v1star*v2star*Gred*cos(delta2star-delta1star);
