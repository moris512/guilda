function solveDifferentialEquations()
    D1 = 10;
    D2 = 10;
    M1 = 100;
    M2 = 12;
    V1 = 2;
    V2 = 1.999884106216756;
    G = -0.003399828308670; %Im(gammainv_ij)
    B = -0.583070554936976; %-Re(gammainv_ij)
    w0 = 2*pi*60;
    %Pmech1 = -0.505492867074437;
    %Pmech2 = 0.478908425516122;
    Pmech1 = -0.505492867074437;
    Pmech2 = 0.478908425516122;

    d1 = 0.405679140272358;
    w1 = 0;
    d2 = 0.094729837775605;
    w2 = 0;

    x0 = [d1; w1; d2; w2];
    tspan = 0:0.01:30;

    [t, x] = ode45(@odeModel, tspan, x0);

    figure;
    plot(t, x(:,2)/w0, 'LineWidth',2);
    hold on
    plot(t, x(:,4)/w0, 'LineWidth',2);
    xlabel('Time');
    ylabel('Frequency Deviation');
    legend('omega 1', 'omega2');

    
    function dxdt = odeModel(~, x)
        dxdt = zeros(4, 1);
        dxdt(1) = x(2);
        dxdt(2) = (-D1*x(2)/w0 + V1*V2*B*sin(x(1)-x(3)) - V1*V2*G*cos(x(1)-x(3)) + Pmech1)*w0/M1;
        dxdt(3) = x(4);
        dxdt(4) = (-D2*x(4)/w0 + V1*V2*B*sin(x(3)-x(1)) - V1*V2*G*cos(x(3)-x(1)) + Pmech2)*w0/M2;
    end
end
