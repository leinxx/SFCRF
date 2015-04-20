function [] = main_sfcrf(imgName, icName, maskName, alpha, niter)
%close all;
%clc
                  
%% parameter setting
Ns = 101; %search window size, 
Nr = 3; %1 % data similarity patch size
%Unary weight
%alpha = 0.1; 
%Pairwise weight
beta = 1-alpha; 
%std. of pixel values, used for scaling Euclidean distance
% sigma = 0.10; % smaller sigma, bigger data similarity, means easier to be accepted for performing weighted average
sel_sigma=25; % this is acutally used for distance weights scaling, select connections
%number of iterations
%iter = 10;
iter = niter;
prob = 5; % sampling density 
L = 1;
thrd2 = 1;
sigma = 0.5; % gamma for Pij, 
         
%%
close all;
z = double(imread(imgName));

ic = double(imread(icName));
%load(icName,'ic');
%ic = double(ic);
[path,name,ext] = fileparts(imgName);
mask = imread(maskName);
mask = double(mask);
ic = ic.*(mask == 0);
ic(ic>1)=1;
ic(ic<0)=0;
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
%% initial condition 
x_0 =ic; 
LD = zeros(m,n);
x = ic;



%z = z(100:400,400:end);
%mask = mask(100:400,400:end);
%x = x(100:400,400:end);
%x_0 = x_0(100:400,400:end);
for k = 1:iter
    tic
    v = pairwise_FSRF(x,sigma,prob,Ns,Nr,sel_sigma,z,mask,LD); % v: the weighted (binary weights) majority voting of labels among sampled pixles
    toc
    %df = L*(z./(x.^2)-1./x);
    df = (x_0-x);
    df2 = v - x;
    grad = alpha*df + beta*df2; % grad is a balanced measurement between the resiual and the update
    %figure;imagesc(df2);colorbar
    x = x + (grad); 
   % figure;imshow(2-x);colormap jet
    save(['data/' name(1:15) '-x' num2str(k)],'x')
    continue
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
%imwrite(uint8((2-x)*255),['sfcrf_',icName '.tif']);

