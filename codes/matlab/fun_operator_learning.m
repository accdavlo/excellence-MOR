function [net,info] = fun_operator_learning(xx,mus,yy)

Nmu = length(mus);
Nx = length(xx); % Determine the number of x values
N_data = Nmu*Nx;

data_input = zeros(N_data,2);
data_target = zeros(N_data,1);
for imu = 1:Nmu
    for ix = 1:Nx
        x = xx(ix);
        mu = mus(imu);
        data_input( (imu-1)*Nx + ix,:) = [x; mu];
        data_target((imu-1)*Nx + ix,1) = yy(ix, imu);
    end
end

% Setup a multi-layer perceptron of neurons (mu,x)-> y(mu,x) [2, 10,20,20,1]
% Define the architecture of the neural network
layers = [
    featureInputLayer(2,"Name","input")

    fullyConnectedLayer(10,"Name","fc1")
    tanhLayer("Name","tanh1")

    fullyConnectedLayer(10,"Name","fc1")
    reluLayer("Name","relu2")

    fullyConnectedLayer(10,"Name","fc2")
    reluLayer("Name","relu3")

    fullyConnectedLayer(1,"Name","output")
];




epochs = 5000;


options = trainingOptions("adam", ...
    MaxEpochs=epochs, ...
    MiniBatchSize=16000, ...
    InitialLearnRate=1e-3, ...
    Shuffle="every-epoch", ...
    Verbose=true);

% Train the neural network with the projected solutions
[net,info] = trainnet(data_input, data_target, layers, "mse", options);
end