%make process demonstraton figures

hh = imread('hh.tif');
load('ic.mat')
%xt = imread('xt.tif');
load x1
x1 = 2-x;
load x2
x2 = 2-x;
load x3
x3 = 2-x;
load x6
x6 = 2-x;

imwrite(x1,'x1.png')
imwrite(x2,'x2.png')
imwrite(x3,'x3.png')
imwrite(x6,'x6.png')
imwrite((x1>0.5)*255,'x1_c.png')
imwrite((x2>0.5)*255,'x2_c.png')
imwrite((x3>0.5)*255,'x3_c.png')
imwrite((x6>0.5)*255,'x6_c.png')

figure;
h = tight_subplot(2,5,[.01 .03],[.1 .01],[.01 .01]);
axes(h(1));imshow(hh,[]);
axes(h(6));imshow(hh,[]);
axes(h(2));imshow(ic,[]);
axes(h(7));imshow(ic>0.5,[]);
axes(h(3));imshow(x1,[]);
axes(h(4));imshow(x2,[]);
axes(h(5));imshow(x3,[]);
axes(h(8));imshow(x1>0.5,[]);
axes(h(9));imshow(x2>0.5,[]);
axes(h(10));imshow(x3>0.5,[]);
set(gcf,'Color','w');