%refine all images in the data folder
%evaluation and run on all images with alpha = 0.5
% the alpha = 0.5 is selected by testing on 20101006. 0.5 produces slightly
% better results than 0.1 and 0.8

fn_list = dir('../0/*ic.tif');
icdir = '../0/';
alpha = 0.4;
niter = 1;
datadir = '~/Work/Sea_ice/gsl2014_hhv_ima/';
for i = 1:numel(fn_list)
    date = fn_list(i).name(1:15);
    disp(date)
    fn_mask = [datadir 'mask/' date '-mask.tif'];
    fn_hh = [datadir 'hhv/' date '-HH-8by8-mat.tif'];
    fn_ic = [icdir date '-ic.tif'];
    main_sfcrf(fn_hh,fn_ic, fn_mask, alpha,niter);
end