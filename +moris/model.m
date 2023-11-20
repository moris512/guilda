function X = model(tspan,X0, neuralOdeParameters)
X = dlode45(@odeModel,tspan,X0,neuralOdeParameters,DataFormat='CB',GradientMode='adjoint');
%For each observation, this function takes a vector of length "state size"
%as initial condition for numerically solving the odeModel function.
end

