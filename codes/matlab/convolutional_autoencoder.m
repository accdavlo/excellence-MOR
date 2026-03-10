clc; clear all; close all;
xx = linspace(0,1,500);
mus = linspace(1,3,200);
[XX, MM] = meshgrid(xx,mus);
%y_exact = @(x,mu) sin(2*pi*x.^exp(mu));
y_exact = @(x,mu) (1+log(mu)).*(x<(mu/4)); %exp(-(100*(x-mu/4)).^2);
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


%% Autoencoder
Nx = size(yy,2);
latent_dim = 5;

layers = [

    imageInputLayer([Nx 1 1],"Normalization","none","Name","input")

    convolution2dLayer([5 1],16,"Padding","same","Name","conv1")
    tanhLayer

    convolution2dLayer([5 1],32,"Padding","same","Name","conv2")
    tanhLayer

    fullyConnectedLayer(latent_dim,"Name","latent")

    fullyConnectedLayer(Nx*32,"Name","fc_decoder")

    functionLayer(@(X) reshape(X,[Nx 1 32 size(X,4)]),...
                  "Formattable",true,"Name","reshape")

    transposedConv2dLayer([5 1],16,"Cropping","same","Name","deconv1")
    tanhLayer

    transposedConv2dLayer([5 1],1,"Cropping","same","Name","output")
];

options = trainingOptions("adam", ...
    MaxEpochs=5000, ...
    MiniBatchSize=32, ...
    InitialLearnRate=1e-3, ...
    Shuffle="every-epoch", ...
    Verbose=true);

[autoenc,info] = trainnet(yy, yy, layers, "mse", options);


history = info.TrainingHistory;

figure()
semilogy(history.Epoch, history.Loss,'LineWidth',0.2)
xlabel('Epoch')
ylabel('Autoencoder reconstruction loss')
grid on



% Evaluating only the encoder

mu_test = linspace(1.1,2.9,10);

[XX_test, MM_test] = meshgrid(xx,mu_test);
yy_test = y_exact(XX_test,MM_test);
Z_test = predict(autoenc, yy_test, Outputs="latent");

figure();
plot(mu_test,Z_test)

%% Extracting the decoder
decoder_layers = [

    featureInputLayer(latent_dim,"Name","latent")

    fullyConnectedLayer(Nx*32,"Name","fc_decoder")

    functionLayer(@(X) reshape(X,[Nx 1 32 size(X,4)]),...
                  "Formattable",true,"Name","reshape")

    transposedConv2dLayer([5 1],16,"Cropping","same","Name","deconv1")
    tanhLayer

    transposedConv2dLayer([5 1],1,"Cropping","same","Name","output")

];

decoder = dlnetwork(decoder_layers);

idx = contains(autoenc.Learnables.Layer,"dec_") | ...
      autoenc.Learnables.Layer == "output";

decoder.Learnables.Value = autoenc.Learnables.Value(idx);

u_rec = predict(decoder,Z_test);

figure()
plot(xx,u_rec,'b-');
hold on
plot(xx,yy_test,'r--');