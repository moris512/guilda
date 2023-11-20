function [loss,gradients] = modelLoss(tspan,X0,neuralOdeParameters,targets)
%Compute predictions
X = model(tspan,X0,neuralOdeParameters);
%Compute L1 loss
loss = l1loss(X,targets,NormalizationFactor='all-elements',DataFormat='CBT');
%Compute gradients
gradients = dlgradients(loss,neuralOdeParameters);
end