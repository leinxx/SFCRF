datadir = 'data_croped/';
fn_list = dir('data_croped/*xt.tif');
niter = 6;
outdir = 'figures/'
for i = 1:numel(fn_list)
    date = fn_list(i).name(1:8);
    fn_xt = [datadir date '-xt.tif'];
    fn_hh = [datadir date '-HH-8by8-mat.tif'];
    fn_ic = [datadir date 'f0.mat'];
    hh = imread(fn_hh);
    xt = imread(fn_xt); xt = 2-xt;
    load(fn_ic);ic(ic>1)=1;ic(ic<0)=0;
    load([datadir date '-x' num2str(niter)]); x = 2-x;
    [prec0,tpr0,fpr0,thresh,acc0] = prec_rec(ic(:),double(xt(:)));
    [prec0,tpr1,fpr1,thresh,acc1] = prec_rec(x(:),double(xt(:)));
    [c,i] = max(acc1);
    disp(num2str(thresh(i)));
    
    %figure;imshow(ic,[]);colormap jet;
    %export_fig temp.png
    %movefile('temp.png',[outdir date '_ic.png'])
    %figure;imshow(x,[]);colormap jet;
    %export_fig temp.png
    %movefile('temp.png',[outdir date,'_sfcrf.png'])
    %imwrite(x,[outdir date '_sfcrf_gray.png'])
    %imwrite(ic,[outdir date '_ic_gray.png'])
    %imwrite(xt*255,[outdir date '_xt.png'])
    imwrite(imadjust(hh),[outdir date,'_hh.png'])
    imwrite(255*(ic>thresh(i)), [outdir date '_ic_cls.png'])
    imwrite(255*(x>thresh(i)), [outdir date '_x_cls.png'])
end