%Network Definition
net = network_IEEE68bus();
%Define options for simulation
option          = struct();
option.x0_sys   = net.x_equilibrium;
option.x0_sys(16)= option.x0_sys(16) + 0.2;
%Running the simulation
out = net.simulate([0 20], option);
figure;
hold on
arrayfun(@(idx) plot(out.t,out.X{idx}(:,2)),1:16);
xlabel('Time [s]','FontSize',15);
ylabel('Frequency Deviation','FontSize',15);
legend()
title('Frequency deviation of each synchronous generator','FontSize',20)
hold off