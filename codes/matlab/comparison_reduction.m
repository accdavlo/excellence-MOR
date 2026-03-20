clc; clear all; close all;
Nx = 500;
Nmu = 200;
xx = linspace(0,1,Nx);
mus = linspace(1,3,Nmu);
[MM,XX] = meshgrid(mus,xx);
%y_exact = @(x,mu) sin(2*pi*x.^exp(mu));
y_exact = @(x,mu) (1+log(mu)).*(x<(mu/4)); %exp(-(100*(x-mu/4)).^2);
yy = y_exact(XX,MM);

load_structures = true;

% Plot the solutions for varying mus
figure;
hold on;
for i = 1:length(mus)
    plot(xx, yy(:,i));
end
title("Solution manifold");
xlabel("x");
ylabel("Solutions");

Nmu_test = 10;
mu_test = linspace(1.1,2.9,Nmu_test);
[MM_test,XX_test] = meshgrid(mu_test,xx);
yy_test = y_exact(XX_test,MM_test);

methods = ["POD","convolutional autoencoder","autoencoder","discrete learning","operator learning"];


predicted_test = dictionary();
info_NNs = dictionary();

% POD
n_rom = 50;
[A,B,C]=svd(yy);
V_rom = A(:,1:n_rom);
predicted_test{"POD"} = V_rom*(V_rom'*yy_test);

% convolutional_autoencoder
fprintf("Convolutional Autoencoder\n");
if load_structures && isfile("convolutional_autoencoder.mat")
    tmp = load("convolutional_autoencoder.mat");
    conv_autoenc = tmp.conv_autoenc;
    info_conv_autoenc = tmp.info_conv_autoenc;
else
    [conv_autoenc,info_conv_autoenc] = fun_convolutional_autoencoder_500(xx,mus,yy);
    save("convolutional_autoencoder.mat","conv_autoenc","info_conv_autoenc");
end

info_NNs{"convolutional autoencoder"} = info_conv_autoenc;

% Test data for convolutional autoencoder
test_data = cell(1,Nmu_test);
for i =1:Nmu_test
    test_data{i} = y_exact(xx,mu_test(i))';
end
predicted_test{"convolutional autoencoder"} = reshape(minibatchpredict(conv_autoenc, test_data),Nx,Nmu_test);



% Autoencoder
fprintf("Autoencoder\n")
if load_structures && isfile("autoencoder.mat")
    tmp = load("autoencoder.mat");
    autoenc = tmp.autoenc;
    info_autoencoder = tmp.info_autoencoder;
else
   [autoenc,info_autoencoder] = fun_autoencoder(xx,mus,yy);
    save("autoencoder.mat","autoenc","info_autoencoder");
end
info_NNs{"autoencoder"} = info_autoencoder;
predicted_test{"autoencoder"} = predict(autoenc, yy_test')';

% Discrete learning
fprintf("Discrete learning \n");
if load_structures && isfile("discrete_learning.mat")
    tmp = load("discrete_learning.mat");
    discrete_learning = tmp.discrete_learning;
    info_discrete_learning = tmp.info_discrete_learning;
else
    [discrete_learning,info_discrete_learning] = fun_discrete_learning(xx,mus,yy);
    save("discrete_learning.mat","discrete_learning","info_discrete_learning");
end

info_NNs{"discrete learning"} = info_discrete_learning;

% predict 
predicted_test{"discrete learning"} = zeros(Nx,Nmu_test);
for i =1:Nmu_test
    predicted_test{"discrete learning"}(:,i) = predict(discrete_learning,mu_test(i));
end

% Operator Learning
fprintf("Operator Learning\n");

if load_structures && isfile("operator_learning.mat")
    tmp = load("operator_learning.mat");
    operator_learning = tmp.operator_learning;
    info_operator_learning = tmp.info_operator_learning;
else
    [operator_learning, info_operator_learning] = fun_operator_learning(xx, mus, yy);
    save("operator_learning.mat","operator_learning","info_operator_learning");
end
info_NNs{"operator learning"} = info_operator_learning;

predicted_test{"operator learning"} = zeros(Nx,Nmu_test);
for i =1:Nmu_test
    test_data = zeros(Nx,2);
    test_data(:,1) = xx;
    test_data(:,2) = mu_test(i);
    predicted_test{"operator learning"}(:,i) = predict(operator_learning,test_data)';
end


%% Plot
keysList = keys(predicted_test);

fig=figure();
for i = 1: numel(keysList)
    method = keysList(i);
    all_predictions = predicted_test{method};
    plot(xx, all_predictions(:,1), 'LineWidth',0.2, 'DisplayName', method);
    hold on
end
plot(xx,yy_test(:,1),'LineWidth',0.2,'DisplayName',"exact");
legend show;
hold off;
saveas(fig,"comparison_one_test_param.png")
saveas(fig,"comparison_one_test_param.pdf")


fig=figure();
colors = ['r','b','m','c','g'];
for i = 1: numel(keysList)
    method = keysList(i);
    all_predictions = predicted_test{method};
    for imu = 1:Nmu_test
        if imu==1
            plot(xx, all_predictions(:,imu), 'Color',colors(i), 'LineWidth',0.2, 'DisplayName', method);
        else
            plot(xx, all_predictions(:,imu), 'Color',colors(i), 'LineWidth',0.2, 'HandleVisibility', 'off');
        end
        hold on
    end
end
for imu =1:Nmu_test
    if imu==1
        plot(xx,yy_test(:,imu),'Color','k','LineWidth',0.2,'DisplayName',"exact");
    else
        plot(xx,yy_test(:,imu),'Color','k','LineWidth',0.2, 'HandleVisibility', 'off');
    end
end
legend show;
hold off;
saveas(fig,"comparison_all_test_param.png")
saveas(fig,"comparison_all_test_param.pdf")



% Losses
keysList = keys(info_NNs);

fig = figure();
for i=1:numel(keysList)
    method = keysList(i);
    info = info_NNs{method};
    history = info.TrainingHistory;
    semilogy(history.Epoch,history.Loss,'LineWidth',0.2,'DisplayName',method);
    hold on
end
% Plot losses
xlabel('Epochs');
ylabel('Loss');
title('Training Loss for Different Methods');
legend show;
hold off;
saveas(fig, "loss_comparison.png");
saveas(fig, "loss_comparison.pdf");