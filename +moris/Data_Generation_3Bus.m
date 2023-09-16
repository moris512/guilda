%Data Generation 3Bus
%% Define Network
net = power_network;
numGenerators = 2;
%Branch Definition
branch12 = branch_pi(1,2,[0.010,0.085],0);
net.add_branch(branch12);
branch23 = branch_pi(2,3,[0.017,0.092],0);
net.add_branch(branch23);
%Definition of busbar (bus)
shunt = [0,0];
%Definition of busbar 1
bus_1 = bus_slack(2,0,shunt);
net.add_bus(bus_1);
%Definition of busbar 2
bus_2 = bus_PV(0.5,2,shunt);
net.add_bus(bus_2);
%Definition of busbar 3
bus_3 = bus_PQ(-3,0,shunt);
net.add_bus(bus_3);
%Definition of grid frequency
omega0 = 60*2*pi;
%1-axis model of synchronous generator added to bus-bar 1
Xd = 1.569;
Xd_prime = 0.963;
Xq = 0.963;
Tdo = 5.14;
M = 100;
D = 10;
mac_data = table(Xd,Xd_prime,Xq,Tdo,M,D);
component1 = generator_1axis(omega0, mac_data);
net.a_bus{1}.set_component(component1);
%A single axis model of a synchronous generator is also added to busbar 2.
Xd = 1.220; 
Xd_prime = 0.667; 
Xq = 0.667; 
Tdo = 8.97; 
M = 12; 
D = 10;
mac_data = table(Xd,Xd_prime,Xq,Tdo,M,D);
comp2 = generator_1axis(omega0, mac_data);
net.a_bus{2}.set_component(comp2);
%A constant impedance model is added to bus-bar 3
comp3 = load_impedance();
net.a_bus{3}.set_component(comp3);
%Running tidal current calculations
net.initialize
%Aside ~Derivation of admittance matrix~.
full(net.get_admittance_matrix)

%% Simulation run (without controller)
%Condition Setting
time = [0,10,20,60];
u_idx = 3;
u = [0, 0.05, 0.1, 0.1;...
 0,    0,   0,   0];

%Input signal waveform plot
% figure; hold on;
% u_percent = u*100;
% stairs(time,u_percent(1,:),'LineWidth',2)
% stairs(time,u_percent(2,:),'--','LineWidth',2)
% xlabel('Time (s)','FontSize',15);
% ylabel('Percentage change from steady-state value(%)','FontSize',15);
% ylim([-20,20])
% legend({'Real part of impedance','Imaginary part of impedance'},'Location','southeast')
% title('Change in the value of the impedance of bus-bar 3','FontSize',20)
% hold off;

%Analysis Execution
out1 = net.simulate(time,u, u_idx);

%Plot Results
figure;
hold on;
arrayfun(@(idx) plot(out1.t,out1.X{idx}(:,2), 'LineWidth',1.5),1:numGenerators);
xlabel('Time [s]','FontSize',10);
ylabel('Frequency Deviation','FontSize',10);
legendEntries = cell(1, numGenerators);
for i = 1:numGenerators
    legendEntries{i} = sprintf('Generator %d', i);
end
legend(legendEntries)
title('Frequency deviation of each synchronous generator','FontSize',15)
hold off

%% Adding a controller to the power system
%Define AGC controller
controller = controller_broadcast_PI_AGC(net,1:2,1:2,-10,-500);
%Assign controller class to power system
net.add_controller_global(controller);

%Analysis Execution
out2 = net.simulate(time,u,u_idx);

%Plot Results
figure;
hold on;
arrayfun(@(idx) plot(out2.t,out2.X{idx}(:,2), 'LineWidth',1.5),1:numGenerators);
xlabel('Time [s]','FontSize',10);
ylabel('Frequency Deviation','FontSize',10);
legendEntries = cell(1, numGenerators);
for i = 1:numGenerators
    legendEntries{i} = sprintf('Generator %d', i);
end
legend(legendEntries)
title('Frequency deviation of each synchronous generator','FontSize',15)
hold off
%% Comparison plots before and after adding the controller
figure; hold on;
plot(out1.t, out1.X{2}(:,2),'Color','#A2142F','LineWidth',1.5)
plot(out1.t, out1.X{1}(:,2),'Color','#EDB120','LineWidth',1.5)
plot(out2.t, out2.X{2}(:,2),'Color','#0072BD','LineWidth',1.5)
plot(out2.t, out2.X{1}(:,2),'Color','#77AC30','LineWidth',1.5)
xlabel('Time [s]','FontSize',15);
ylabel('Frequency Deviation','FontSize',15);
legend({'Frequency deviation of Generator 2 (without AGC)','Frequency deviation of Generator 1 (without AGC)',...
        'Frequency deviation of Generator 2 (with AGC)','Frequency deviation of Generator 1 (with AGC)'},...
        'Location','east')
title('Frequency Deviation Synchronous Generator','FontSize',20)
hold off
%% Obtain the Graph of the Network
branch_num = numel(net.a_branch);
bus_num    = numel(net.a_bus);
adjacency_matrix = zeros(bus_num,bus_num);
for idx = 1:branch_num
    from = net.a_branch{idx}.from;
    to   = net.a_branch{idx}.to;
    adjacency_matrix(from,to)=1;
    adjacency_matrix(to,from)=1;
end
plot(graph(adjacency_matrix))
%% Obtain the Component Listing
bus_num = numel(net.a_bus);
component_list = arrayfun(@(idx) {['bus',num2str(idx)] , class(net.a_bus{idx}.component)},(1:bus_num)','UniformOutput',false);
cell2table(vertcat(component_list{:}) ,"VariableNames",["idx" "component"])
%% Determine Bus Types
bus_num = numel(net.a_bus);
bus_idx = zeros(1,bus_num);
for idx = 1:bus_num
    switch class(net.a_bus{idx})
        case 'bus_PV'
            bus_idx(idx) = 1;
        case 'bus_PQ'
            bus_idx(idx) = 2;
        case 'bus_slack'
            bus_idx(idx) = 3;
    end
end
PV_bus_idx = find(bus_idx==1)
PQ_bus_idx = find(bus_idx==2)
slack_bus_idx = find(bus_idx==3)