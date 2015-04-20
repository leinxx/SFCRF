%refine all images in the data folder
%evaluation and run on all images with alpha = 0.5
% the alpha = 0.5 is selected by testing on 20101006. 0.5 produces slightly
% better results than 0.1 and 0.8
function plot_roc_train_test_valid()
fn_list = dir('data_croped/*xt.tif');
niter = 6;
datadir = 'data_croped/';
disp('train');
prec_rec_set(fn_list(1:9)) % train
export_fig train_roc.pdf
disp('valid');
prec_rec_set(fn_list(10:12)) % valid
export_fig valid_roc.pdf
disp('test');
prec_rec_set(fn_list(13:15)) % test
export_fig test_roc.pdf
end

function prec_rec_set(fns)

niter = 6;
datadir = 'data_croped/';

a_x = [];
a_xt = []; 
a_ic = [];

for i = 1:numel(fns)
    date = fns(i).name(1:8);
    fn_xt = [datadir date '-xt.tif'];
    fn_ic = [datadir date 'f0.mat'];
    
    xt = imread(fn_xt); xt = 2-xt;
    load(fn_ic);ic(ic>1)=1;ic(ic<0)=0;
    load([datadir date '-x' num2str(niter)]); x = 2-x;
    a_x = [a_x;x(:)];
    a_xt = [a_xt;xt(:)];
    a_ic = [a_ic;ic(:)];
end
[prec0,tpr0,fpr0,thresh0,acc0] = prec_rec(a_ic(:),double(a_xt(:)));
[prec1,tpr1,fpr1,thresh1,acc1] = prec_rec(a_x(:),double(a_xt(:)));
area_0 = trapz(fpr0,tpr0);
area_1 = trapz(fpr1,tpr1);
plot_roc(fpr0,tpr0,fpr1,tpr1);
disp(['max acc0: ' num2str(max(acc0))])
disp(['max acc1: ' num2str(max(acc1))])
disp(['area0 : ' num2str(area_0)])
disp(['area1: ' num2str(area_1)])
end


function plot_roc(fpr0,tpr0,fpr1,tpr1)
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

end