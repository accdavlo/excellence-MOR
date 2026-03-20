function [net,info] = fun_convolutional_autoencoder_500(xx,mus,yy)

Nx = length(xx);
Nmu = length(mus);

% Convert data for autoencoder
data = cell(1,Nmu);
for i =1:Nmu
    data{i} = yy(:,i);
end


%% Autoencoder
latent_dim = 3;

layers = [

    % ================= ENCODER =================
    sequenceInputLayer(1,"Name","input","MinLength",Nx)

    convolution1dLayer(4,4,"Stride",2,"Padding",1,"Name","conv1") % 500 -> 250 x4
    reluLayer

    convolution1dLayer(4,8,"Stride",2,"Padding",1,"Name","conv2") % 250 x4 -> 125 x8
    reluLayer

    convolution1dLayer(4,8,"Stride",2,"Padding",1,"Name","conv3") % 125 x8 -> 62 x8
    reluLayer
    
    convolution1dLayer(4,8,"Stride",2,"Padding",1,"Name","conv4") % 62 x8 -> 31 x8
    reluLayer

    convolution1dLayer(4,8,"Stride",2,"Padding",1,"Name","conv5") % 31 x8 -> 15 x8
    reluLayer

    convolution1dLayer(4,8,"Stride",2,"Padding",1,"Name","conv6") % 15 x8 -> 7 x8
    reluLayer

    convolution1dLayer(4,8,"Stride",2,"Padding",1,"Name","conv7") % 7 x8 -> 3 x8
    tanhLayer

    % flatten implicitly happens via FC
    fullyConnectedLayer(latent_dim,"Name","latent") %24 -> latent_dim

    % ================= BOTTLENECK =================
    fullyConnectedLayer(24,"Name","fc_decoder") %latent_dim -> 24

    % % reshape 24 → 3 x 8
    % functionLayer(@(X) dlarray(reshape(extractdata(X),3,8,[]),"CBT"),"Name","reshape")

    % ================= DECODER =================

    transposedConv1dLayer(4,8,"Stride",2,"Cropping",0,"Name","tconv1") % 3 → 8
    tanhLayer

    transposedConv1dLayer(4,8,"Stride",2,"Cropping",1,"Name","tconv2") % 8 → 16
    reluLayer

    transposedConv1dLayer(4,8,"Stride",2,"Cropping",1,"Name","tconv3") % 16 → 32
    reluLayer

    transposedConv1dLayer(4,8,"Stride",2,"Cropping",2,"Name","tconv4") % 32 → 62
    reluLayer

    transposedConv1dLayer(4,8,"Stride",2,"Cropping",1,"Name","tconv5") % 62 → 124
    reluLayer

    transposedConv1dLayer(4,4,"Stride",2,"Cropping",0,"Name","tconv6") % 124 → 250
    reluLayer

    transposedConv1dLayer(4,1,"Stride",2,"Cropping",1,"Name","tconv7") % 250 → 500
];

options = trainingOptions("adam", ...
    MaxEpochs=5000, ...
    MiniBatchSize=64, ...
    InitialLearnRate=1e-3, ...
    Shuffle="every-epoch", ...
    Verbose=true);

[net,info] = trainnet(data,data, layers, "mse", options);

end