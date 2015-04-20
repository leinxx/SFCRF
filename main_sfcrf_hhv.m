function [] = main_sfcrf_hhv(imgName1,imgName2,icName)
%close all;
%clc
                  
%% parameter setting
Ns = 101; %search window size, 
Nr = 3; %1 % data similarity patch size
%Unary weight
alpha = 0.5; 
%Pairwise weight
beta = 1-alpha; 
%std. of pixel values, used for scaling Euclidean distance
% sigma = 0.10; % smaller sigma, bigger data similarity, means easier to be accepted for performing weighted average
sel_sigma=25; % this is acutally used for distance weights scaling, select connections
%number of iterations
iter = 10;
prob = 10; % sampling density 
L = 21;
thrd2 = 1;
sigma = 0.5; % gamma for Pij, 
         
%%
close all;
z = double(imread(imgName1));
z2 = double(imread(imgName2));
ic = double(imread(icName));
ic = ic/255;
ic_t = 2-ic;
%h = fspecial('gaussian',7,4);
%ic = imfilter(ic,h);
ic = 2-ic;


[m,n] = size(z);
%% enhancement
% normalization 
z = z-min(z(:));
z = z./max(z(:));
% z = histeq(z);
z = z+1;
z2 = z2-min(z2(:));
z2 = z2./max(z2(:));
z2 = z2+1;
%% initial condition 
x_0 =ic; 
LD = zeros(m,n);
x = ic;
for k = 1:iter
    tic
    v = pairwise_FSRF(x,sigma,prob,Ns,Nr,sel_sigma,z,z2); % v: the weighted (binary weights) majority voting of labels among sampled pixles
    toc
    %df = L*(z./(x.^2)-1./x);
    df = (x_0-x);
    df2 = v - x;
    grad = alpha*df + beta*df2; % grad is a balanced measurement between the resiual and the update
    %figure;imagesc(df2);colorbar
    x = x + (grad); 
    save(['x',num2str(k)],'x')
    %%
    I=v;
    mu_img = mean(I(:));
    sigma_img = std(I(:));
    thrd = mu_img - thrd2*sigma_img;
    thrd = 1.5;
    I(I<thrd) = 1; 
    I(I>=thrd) = 2;
    %             figure;imagesc(I);colormap gray;
    %%
    figure(1)
    subplot(321),imshow(I,[]);
    title(['itr:  ' ,num2str(k)])
    subplot(322),imshow(v,[]); colormap jet
    title('v')
    subplot(323),imshow(x,[]); colormap jet
    title('x');
    subplot(324),plot(ic(:),df2(:),'.');hold on; plot(1:2,zeros(1,2));hold off
    subplot(325),plot(alpha*df(:),beta*df2(:),'.');
    subplot(326),imshow(x-x_0,[]);colorbar
    title('x-x_0')
    pause(0.5)
end;

%% output to disk
imwrite(2-x,['sfcrf_',icName]);