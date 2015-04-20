%data cropping
close all

fn_list = dir('data/*xt.tif');
datadir = 'data/';
outdir = 'data_croped/'

for i = 1:numel(fn_list)
    date = fn_list(i).name(1:8);
    fn_xt = [datadir date '-xt.tif'];
    fn_hh = [datadir date '-HH-8by8-mat.tif'];
    fn_ic = [datadir date 'f0.tif'];
    xt = imread(fn_xt);
    top = 21;
    
    left = 21;
    bottom = size(xt,1);
    right = size(xt,2)-21;
    xt = xt(top:bottom,left:right);
    figure
    imshow(xt,[]);
    imwrite(xt,[outdir date '-xt.tif'])
    hh = imread(fn_hh);
    hh = hh(top:bottom,left:right);
    imwrite(hh,[outdir date '-HH-8by8-mat.tif'])
    ic = imread(fn_ic);
    ic = ic(top:bottom,left:right);
    save([outdir date 'f0.mat'],'ic');
    
    
end