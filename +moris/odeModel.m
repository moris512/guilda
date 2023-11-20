function y = odeModel(~,y,theta)
%Takes as input time (ununsed), the real solution (y), and the parameters
y = tanh(theta.fc1.Weights*y + theta.fc1.Bias);
y = theta.fc2.Weights*y + theta.fc2.Bias;
%Fully connected operation
end

