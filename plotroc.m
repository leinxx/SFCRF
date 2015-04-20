%plot roc curve

datadir = 'data_croped/';
date = '20110811';
niter = 6;
fn_xt = [datadir date '-xt.tif'];
fn_hh = [datadir date '-HH-8by8-mat.tif'];
fn_ic = [datadir date 'f0.mat'];
xt = imread(fn_xt); xt = 2-xt;
load(fn_ic);ic(ic>1)=1;ic(ic<0)=0;
hh = imread(fn_hh);
%figure;imshow(ic,[]);colormap jet
im = imread(fn_xt);
%figure;imshow(im,[]);colormap jet
load([datadir date '-x' num2str(niter)]); x = 2-x;
%figure;imshow(x,[]);colormap jet

[prec0,tpr0,fpr0,thresh,acc0] = prec_rec(ic(:),double(xt(:)));
[prec0,tpr1,fpr1,thresh,acc1] = prec_rec(x(:),double(xt(:)));
figure;hold on
plot(acc0,'g')
plot(acc1,'r')

figure;
plot(fpr0,tpr0,'--k','LineWidth',2);
hold on
plot(fpr1,tpr1,'k','LineWidth',2);
set(gcf,'Color','w');
hxlabel = xlabel('FPR');
hylabel = ylabel('TPR');
hlegend = legend('CNN','CNN_ {SFCRF}');
%set(hlegend,'Location','northwest','Box','off');
set(gca,'FontName','Helvetica');
set([hlegend,gca],'FontSize',18);
set([hxlabel,hylabel],'FontSize',18);
set(gca,...
    'Box'         ,'off',...
    'TickDir'     ,'out',...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , 0:0.2:1, ...
    'LineWidth'   , 1         );
export_fig roc_curve.pdf
copyfile('roc_curve.pdf', '~/Dropbox/WorkSVN/2015-03-FCNN-SFCRF-ice-cvpr2015-workshop/figures/');