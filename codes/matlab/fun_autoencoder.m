function [net,info] = fun_autoencoder_learning(xx,mus,yy)

Nmu = length(mus);
Nx = length(xx); % Determine the number of x values

latent_dim = 5;

layers = [
    featureInputLayer(Nx,"Name","input")

    fullyConnectedLayer(50,"Name","enc_fc1")
    tanhLayer

    fullyConnectedLayer(20,"Name","enc_fc2")
    tanhLayer

    fullyConnectedLayer(20,"Name","enc_fc3")
    tanhLayer

    fullyConnectedLayer(latent_dim,"Name","latent")

    fullyConnectedLayer(20,"Name","dec_fc1")
    tanhLayer

    fullyConnectedLayer(20,"Name","dec_fc2")
    tanhLayer

    fullyConnectedLayer(50,"Name","dec_fc3")
    tanhLayer

    fullyConnectedLayer(Nx,"Name","output")
];

options = trainingOptions("adam", ...
    MaxEpochs=5000, ...
    MiniBatchSize=32, ...
    InitialLearnRate=1e-3, ...
    Shuffle="every-epoch", ...
    Verbose=true);

[net,info] = trainnet(yy', yy', layers, "mse", options);
end