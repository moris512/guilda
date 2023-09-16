%Data Generation IEEE9
net = network_IEEE9bus;
numGenerators = 3;
net.initialize;
option = struct();
option.linear = false;
option.x0_sys = net.x_equilibrium;
option.x0_sys(2) = option.x0_sys(2)+0.02;
option.V0 = net.V_equilibrium;
option.I0 = net.I_equilibrium;
%controller = controller_broadcast_PI_AGC(net,1:numGenerators,1:numGenerators,-10,-500);
%net.add_controller_global(controller);
time = [0,60];
%u_idx = 5;
%u = [0, 0.05, 0.1, 0.1; 0, 0, 0, 0];
%out = net.simulate(time,u,u_idx);
out = net.simulate(time,option);

%Plot Results
figure;
hold on;
arrayfun(@(idx) plot(out.t,out.X{idx}(:,2), 'LineWidth',1.3),1:numGenerators);
xlabel('Time [s]','FontSize',10);
ylabel('Frequency Deviation','FontSize',10);
legendEntries = cell(1, numGenerators);
for i = 1:numGenerators
    legendEntries{i} = sprintf('Generator %d', i);
end
legend(legendEntries)
title('Frequency deviation of each synchronous generator','FontSize',15)
hold off
full(net.get_admittance_matrix)
%%
observe = net.a_bus{2}.component;
t = 0;
xeq = observe.x_equilibrium;
Veq = observe.V_equilibrium;
Veq = [real(Veq); imag(Veq)];
Ieq = observe.I_equilibrium;
Ieq = [real(Ieq); imag(Ieq)];
u0 = zeros(observe.get_nu,1);
[dx, con] = observe.get_dx_constraint(t,xeq,Veq,Ieq,u0);
%%
option.x0_sys = net.x_equilibrium;
Time = [0,10];
%u_idx = [2];
out = net.simulate(Time,'fault',{{[1,1.01],2}});
figure;
hold on;
arrayfun(@(idx) plot(out.t,out.X{idx}(:,2)),1:3);
xlabel('Time(s)')
ylabel('Frequency deviation (pu)')
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