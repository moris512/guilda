%Neural ODE - Example
addpath('C:\Users\LEGION\Documents\GitHub\guilda');
addpath('C:\Users\LEGION\Documents\MATLAB\Examples\R2022a\nnet\TrainNeuralODENetworkWithRungeKuttaODESolverExample');

%%Generating Ground Truth Data.
x0 = [2; 0]; %Initial point
A = [-0.1 -1; 1 -0.1]; %Real Dynamics
trueModel = @(t,y) A*y; %True Model

numTimeSteps = 2000; %Time steps
T = 15; % Final Time
odeOptions = odeset(RelTol=1.e-7); %Tolerance of the ODE
t = linspace(0, T, numTimeSteps); %Time interval
[~, xTrain] = ode45(trueModel, t, x0, odeOptions);
%[t,y] = ode45()
xTrain = xTrain';
figure
plot(xTrain(1,:),xTrain(2,:))
title("Ground Truth Dynamics") 
xlabel("x(1)") 
ylabel("x(2)")
grid on

%%Model Parameters
neuralOdeTimesteps = 40; %compared to the 2000
dt = t(2); %the delta of time
timesteps = (0:neuralOdeTimesteps)*dt; %make 40 time steps separated by dt.

neuralOdeParameters= struct;
stateSize = size(xTrain,1); %The size of the first dimension (rows)
hiddenSize = 20; %The hidden layers.

%Fully Connected Layer 1 (From 2 states to 20 hidden states)
neuralOdeParameters.fc1 = struct; %Learnable parameter.
sz = [hiddenSize stateSize]; %Size of the learnable parameter
neuralOdeParameters.fc1.Weights = initializeGlorot(sz, hiddenSize, stateSize);
%Glorot = Xavier (uniform distribution with bounds)
neuralOdeParameters.fc1.Bias = initializeZeros([hiddenSize 1]); %20 rows 1 column zeros

%Fully Connected Layer 2 (From 20 hidden states to 2 states)
neuralOdeParameters.fc2 = struct;
sz = [stateSize hiddenSize];
neuralOdeParameters.fc2.Weights = initializeGlorot(sz, stateSize, hiddenSize);
neuralOdeParameters.fc2.Bias = initializeZeros([stateSize 1]);

%Display the learnable parameters of the model
neuralOdeParameters.fc1
neuralOdeParameters.fc2

%% Neural ODE
%Training option
gradDecay = 0.9;
sqGradDecay = 0.999;
learnRate = 0.002;

numIter = 1200; %iterations number
miniBatchSize = 200;
plotFrequency = 50; %Show the training path

%Initialize Adam Solver Parameters
averageGrad = [];
averageSqGrad = [];
%Training progress monitor
monitor = trainingProgressMonitor(Metrics="Loss",Info=["Iteration","LearnRate"],XLabel="Iteration");

%Training using a custom loop:
    %1. Create mini-batch of the synthesized data.
    %2. Evaluate the model loss and gradients.
    %3. Update model parameters (adamupdate).
    %4. Update training progress plot.

numTrainingTimesteps = numTimeSteps; %Total number of time steps
trainingTimesteps = 1:numTrainingTimesteps;
plottingTimesteps = 2:numTimeSteps;

iteration = 0;

while iteration < numIter && ~monitor.Stop
    iteration = iteration + 1;

    %Create batch
    [X, targets] = createMiniBatch(numTrainingTimesteps, neuralOdeTimesteps, miniBatchSize,xTrain);

    %Evaluate network and compute loss and gradients
    [loss, gradients] = dlfeval(@modelLoss, timesteps, X, neuralOdeParameters, targets);

    %Update network
    [neuralOdeParameters, averageGrad, averageSqGrad] = adamupdate(neuralOdeParameters, gradients, averageGrad, averageSqGrad, iteration, learnRate, gradDecay,sqGradDecay);

    %Plot loss
    recordMetrics(monitor, iteration, Loss = loss);

    % Plot predicted vs. real dynamics
    if mod(iteration,plotFrequency) == 0  || iteration == 1

        % Use ode45 to compute the solution 
        y = dlode45(@odeModel,t,dlarray(x0),neuralOdeParameters,DataFormat="CB");

        plot(xTrain(1,plottingTimesteps),xTrain(2,plottingTimesteps),"r--")

        hold on
        plot(y(1,:),y(2,:),"b-")
        hold off

        xlabel("x(1)")
        ylabel("x(2)")
        title("Predicted vs. Real Dynamics")
        legend("Training Ground Truth", "Predicted")

        drawnow
    end
    updateInfo(monitor,Iteration=iteration,LearnRate=learnRate);
    monitor.Progress = 100*iteration/numIter;
end

%% Evaluate model
tPred = t;

x0Pred1 = sqrt([2;2]);
x0Pred2 = [-1;-1.5];
x0Pred3 = [0;2];
x0Pred4 = [-2;0];

[~, xTrue1] = ode45(trueModel, tPred, x0Pred1, odeOptions);
[~, xTrue2] = ode45(trueModel, tPred, x0Pred2, odeOptions);
[~, xTrue3] = ode45(trueModel, tPred, x0Pred3, odeOptions);
[~, xTrue4] = ode45(trueModel, tPred, x0Pred4, odeOptions);

xPred1 = dlode45(@odeModel,tPred,dlarray(x0Pred1),neuralOdeParameters,DataFormat="CB");
xPred2 = dlode45(@odeModel,tPred,dlarray(x0Pred2),neuralOdeParameters,DataFormat="CB");
xPred3 = dlode45(@odeModel,tPred,dlarray(x0Pred3),neuralOdeParameters,DataFormat="CB");
xPred4 = dlode45(@odeModel,tPred,dlarray(x0Pred4),neuralOdeParameters,DataFormat="CB");

figure
subplot(2,2,1)
plotTrueAndPredictedSolutions(xTrue1, xPred1);
subplot(2,2,2)
plotTrueAndPredictedSolutions(xTrue2, xPred2);
subplot(2,2,3)
plotTrueAndPredictedSolutions(xTrue3, xPred3);
subplot(2,2,4)
plotTrueAndPredictedSolutions(xTrue4, xPred4);



