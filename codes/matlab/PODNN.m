clc; clear all; close all;
xx = linspace(0,1,500);
mus = linspace(1,3,50);
[XX, MM] = meshgrid(xx,mus);
y_exact = @(x,mu) sin(2*pi*x.^exp(mu));
y_exact = @(x,mu) exp(-(100*(x-mu/4)).^2);
yy = y_exact(XX,MM);

% Plot the solutions for varying mus
figure;
hold on;
for i = 1:length(mus)
    plot(xx, yy(i,:));
end
title("Solution manifold");
xlabel("x");
ylabel("Solutions");

[U,S,V] = svd(yy);

figure()
semilogy(diag(S));
title("Singular value decay");


n_rom = 10;
% Select the first n_rom singular values and corresponding vectors
S_rom = S(1:n_rom, 1:n_rom);
U_rom = U(:, 1:n_rom);
V_rom = V(:,1:n_rom);

figure;
hold on;
for i = 1:n_rom
    plot(xx, V_rom(:,i));
end
title("Reduced basis functions");
xlabel("x");
ylabel("Basis");

% Project solutions on the reduced space
projectedSolutions = (V_rom.' * yy.').'; % Project the original solutions onto the reduced space

figure;
plot(mus,projectedSolutions);
xlabel("mu");
ylabel("reduced variables")
title("Reduced variables with respect to parameter")

% Setup a multi-layer perceptron of neurons [1, 10,20,20,n_rom]
% Define the architecture of the neural network
layers = [
    featureInputLayer(1,"Name","input")

    fullyConnectedLayer(10,"Name","fc1")
    tanhLayer("Name","tanh1")

    fullyConnectedLayer(20,"Name","fc2")
    tanhLayer("Name","tanh2")

    fullyConnectedLayer(20,"Name","fc3")
    tanhLayer("Name","tanh3")

    fullyConnectedLayer(n_rom,"Name","output")
];


epochs = 5000;


options = trainingOptions("adam", ...
    MaxEpochs=epochs, ...
    MiniBatchSize=32, ...
    InitialLearnRate=1e-3, ...
    Shuffle="every-epoch", ...
    Verbose=true);

% Train the neural network with the projected solutions
[net,info] = trainnet(mus', projectedSolutions, layers, "mse", options);

history = info.TrainingHistory;

figure()
semilogy(history.Epoch, history.Loss,'LineWidth',0.2)
xlabel('Epoch')
ylabel('MSE Loss')
grid on


%%
mu_test = linspace(1.1,2.9, 5);

figure()
for mu=mu_test
    y_ex = y_exact(xx,mu)';
    y_red = net.forward(mu);
    y_reconstruction = V_rom*y_red';
    % Calculate the error between the exact and reconstructed solutions
    error = norm(y_ex - y_reconstruction)/norm(y_ex);
    fprintf('Error for mu = %.2f: %.3e\n', mu, error);
    plot(xx,y_ex,'r--');
    hold on
    plot(xx,y_reconstruction, 'b-');
end
xlabel("x");
ylabel("Solutions");
title("Test set solutions and approximations");