function solveDifferentialEquations()
    D1 = 10;
    D2 = 10;
    M1 = 100;
    M2 = 12;
    V1 = 2;
    V2 = 2;
    G = -0.003399828308670;
    B = -0.583070554936976;
    w0 = 2*pi*60;
    Pmech1 = 0;
    Pmech2 = 0;

    d1 = -0.116052802946039;
    w1 = 9.815106504289172e-05;
    d2 = 0.094836307919911;
    w2 = 1.146376953764478e-05;

    x0 = [d1; w1; d2; w2];
    tspan = 0:0.01:30;

    [t, x] = ode45(@odeModel, tspan, x0);

    figure;
    plot(t, x(:,2), 'LineWidth',2);
    hold on
    plot(t, x(:,4), 'LineWidth',2);
    xlabel('Time');
    ylabel('Frequency Deviation');
    legend('omega 1', 'omega2');

    
    function dxdt = odeModel(t, x)
        dxdt = zeros(4, 1);
        dxdt(1) = x(2);
        dxdt(2) = (-D1*x(2) + w0*V1*V2*B*sin(x(1)-x(3)) - w0*V1*V2*G*cos(x(1)-x(3)) + w0*Pmech1)/M1;
        dxdt(3) = x(4);
        dxdt(4) = (-D2*x(4) + w0*V1*V2*B*sin(x(3)-x(1)) - w0*V1*V2*G*cos(x(3)-x(1)) + w0*Pmech2)/M2;
    end
end
