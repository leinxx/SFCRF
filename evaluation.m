%evaluation and run on all images with alpha = 0.5
% the alpha = 0.5 is selected by testing on 20101006. 0.5 produces slightly
% better results than 0.1 and 0.8

imgName = 'hh_large_sub.tif';
icName = 'ic_large_sub.tif';
xt = imread('xt_large_sub.tif');
all = [];

for i = 1:8
    alpha = double(i)/10.0;
    %main_sfcrf(imgName,icName,alpha);
    outdir = ['alpha' num2str(i)];
    results_folder = [outdir '/'];
    autc = [];% area under the curve
    ic = imread(icName);
    ic = double(ic)/255;
    [prec,tpr,fpr,thresh] = prec_rec(ic(:),double(xt(:)));
    area = trapz(fpr,tpr);
    autc = [];
    autc = [autc;area];
    for i = 1:10
        load([results_folder '/' 'x' num2str(i)]);
        x = 2-x;
        [prec,tpr,fpr,thresh] = prec_rec(x(:),double(xt(:)));
        area = trapz(fpr,tpr);
        autc = [autc;area];
    end
    
    all = [all,autc];
end

figure
hold on 
plot(all)
a = 1:10;
a =num2str(a);
legend(['1','2','3','4','5','6','7','8'])