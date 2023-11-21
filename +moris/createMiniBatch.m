function [x0,targets] = createMiniBatch(numTimeSteps,numTimesPerObs,miniBatchSize,X)
%Args:
%1.Total number of time steps in the input data.
%2. Number of time steps per observation.
%3. Mini-Batch size to be generated.
%4. Input data.
s = randperm(numTimeSteps - numTimesPerObs, miniBatchSize); %Generates random
%set of indices. The range is limited to the difference to ensure that
%there is enough tie steps for each sequence.
x0 = dlarray(X(:,s)); %Extracts the initial states for each sequence.
targets = zeros([size(X,1) miniBatchSize numTimesPerObs]); %initializes as 0
for i = 1:miniBatchSize
    targets(:,i, 1:numTimesPerObs) = X(:, s(i) + 1:(s(i) + numTimesPerObs));
end
%copies the actual values of the input data and assignes to the minibatch.
end