% 電力系統モデルの定義
mynet = power_network();

% 送電線①②の定義と電力系統モデルへの導入
branch12 = branch_pi(1,2,[0.015,0.077],0);
mynet.add_branch(branch12);
branch23 = branch_pi(2,3,[0.024,0.116],0);
mynet.add_branch(branch23);

% 母線①②③の定義と電力系統モデルへの導入
shunt = [0,0];
bus1 = bus_slack(2.5,0,shunt);
mynet.add_bus(bus1);
bus2 = bus_PV(0.75,2.5,shunt);
mynet.add_bus(bus2);
bus3 = bus_PQ(-4,0,shunt);
mynet.add_bus(bus3);

%系統周波数の定義
omega0 = 60*2*pi;

% 発電機①②と負荷①の定義と電力系統モデルへの導入
Xd = 1.6; Xd_prime = 0.96; Xq = 0.96; T = 4.12; M = 150; D = 12;
mac_data = table(Xd,Xd_prime,Xq,T,M,D);
generator1 = generator_1axis(omega0, mac_data);
mynet.a_bus{1}.set_component(generator1);
Xd = 1.16; Xd_prime = 0.77; Xq = 0.77; T = 9.83; M = 17; D = 9;
mac_data = table(Xd,Xd_prime,Xq,T,M,D);
generator2 = generator_1axis(omega0, mac_data);
mynet.a_bus{2}.set_component(generator2);
load1 = load_impedance();
mynet.a_bus{3}.set_component(load1);
