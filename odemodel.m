function [dxdt] = odemodel(~,x,M1,M2,D1,D2,v1,v2,B,G,Pmech1,Pmech2,omega0)
    dxdt = zeros(4, 1);
    dxdt(1) = x(2);
    dxdt(2) = (-D1*x(2)/omega0 + v1*v2*B*sin(x(1)-x(3)) - v1*v2*G*cos(x(1)-x(3)) + Pmech1)*omega0/M1;
    dxdt(3) = x(4);
    dxdt(4) = (-D2*x(4)/omega0 + v1*v2*B*sin(x(3)-x(1)) - v1*v2*G*cos(x(3)-x(1)) + Pmech2)*omega0/M2;
end