function [loss,gradients] = modelLoss(tspan,X0,neuralOdeParameters,targets)
%Compute predictions
X = model(tspan,X0,neuralOdeParameters);
%Compute L2 loss
loss = l2loss(X,targets,NormalizationFactor='all-elements',DataFormat='CBT');
%Compute gradients
gradients = dlgradient(loss,neuralOdeParameters);
end