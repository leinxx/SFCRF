function [x_prime,A5] = pairwise_FSRF(x,sigma,percent,Ns,Nr,sel_sigma,x_0,mask,LD)

pad = floor(Ns/2)+1+floor(Nr/2)+1;
x = padarray(x,[pad*2 pad*2],'symmetric');
x_0 = padarray(x_0,[pad*2 pad*2],'symmetric');
mask = padarray(mask,[pad*2 pad*2],'symmetric');
[x_prime,~,~,~,~,A5] = pairwise_FSRFp(x, x_0 , LD, mask, [Ns Nr sigma percent 1 sel_sigma]);
%x_prime = pairwise_FSRFm(x, x_0, mask, [Ns Nr sigma percent 1 sel_sigma]);
x_prime = x_prime(1+pad*2:end-pad*2,1+pad*2:end-pad*2);
