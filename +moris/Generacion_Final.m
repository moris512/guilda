%% Data Generation
% 2 Synchronous Generatos - classical cylindrical generator (xd = xq, xd_prime = xq)
net = power_network;
numGenerators = 2;
branch12 = branch_pi(1,2,[0.010,0.085],0); %Branch
net.add_branch(branch12);
shunt = [0,0];
bus_1 = bus_slack(2,0,shunt); %Definition of busbar 1
net.add_bus(bus_1);
bus_2 = bus_PV(0.5,2,shunt); %Definition of busbar 2
net.add_bus(bus_2);
omega0 = 60*2*pi;
%Generator 1
Xd = 0.963;
Xq = 0.963;
x1 = 0.963;
M = 100;
M1 = 100;
D = 10;
D1 = 10;
mac_data = table(Xd,Xq,M,D);
component1 = generator_classical(omega0, mac_data);
net.a_bus{1}.set_component(component1);
%Generator 2
Xd = 0.667;
Xq = 0.667; 
x2 = 0.667;
M = 12; 
M2 = 12;
D = 10;
D2 = 10;
mac_data = table(Xd,Xq,M,D);
comp2 = generator_classical(omega0, mac_data);
net.a_bus{2}.set_component(comp2);
net.initialize
net.get_admittance_matrix;
Y = full(net.get_admittance_matrix);
Ycon = conj(Y);
xi = [x1 0; 0 x2];
Gamma = xi - 1i*xi*Ycon*xi;
Gammainv = inv(Gamma);
Bred = -real(Gammainv(1,2)); %-Re(gammainv_ij)
Gred = imag(Gammainv(1,2)); %Im(gammainv_ij)

v1star = abs(component1.V_equilibrium);
v2star = abs(comp2.V_equilibrium);
delta1star = component1.x_equilibrium(1);
omega1star = component1.x_equilibrium(2);
delta2star = comp2.x_equilibrium(1);
omega2star = comp2.x_equilibrium(2);
Pmech1star = -v1star*v2star*Bred*sin(delta1star-delta2star)+v1star*v2star*Gred*cos(delta1star-delta2star);
Pmech2star = -v1star*v2star*Bred*sin(delta2star-delta1star)+v1star*v2star*Gred*cos(delta2star-delta1star);
%% YES
x0 = [delta1star + pi/6; omega1star; delta2star; omega2star];
tspan = 0:0.01:30;
[t, x] = ode45(@(t,x) odemodel(t,x,M1,M2,D1,D2,v1star,v2star,Bred,Gred,Pmech1star,Pmech2star,omega0), tspan, x0);
delta1 = x(:,1);
omega1 = x(:,2)/omega0;
delta2 = x(:,3);
omega2 = x(:,4)/omega0;
figure;
plot(t, omega1, 'LineWidth',2);
hold on
plot(t, omega2, 'LineWidth',2);
xlabel('Time');
ylabel('Frequency Deviation');
legend('omega 1', 'omega2');

%% NO
function [omega1,omega2] = solveDifferentialEquations()
    x0 = [delta1star; omega1star; delta2star; omega2star];
    tspan = 0:0.01:30;
    
    [t, x] = ode45(@odeModel, tspan, x0);
    omega1 = x(:,2)/omega0;
    omega2 = x(:,4)/omega0;
    figure;
    plot(t, omega1, 'LineWidth',2);
    hold on
    plot(t, omega2, 'LineWidth',2);
    xlabel('Time');
    ylabel('Frequency Deviation');
    legend('omega 1', 'omega2');
        
    function dxdt = odeModel(~, x)
        dxdt = zeros(4, 1);
        dxdt(1) = x(2);
        dxdt(2) = (-D1*x(2)/omega0 + v1star*v2star*B*sin(x(1)-x(3)) - v1star*v2star*G*cos(x(1)-x(3)) + Pmech1)*omega0/M1;
        dxdt(3) = x(4);
        dxdt(4) = (-D2*x(4)/omega0 + v1star*v2star*B*sin(x(3)-x(1)) - v1star*v2star*G*cos(x(3)-x(1)) + Pmech2)*omega0/M2;
    end
end