function [d] = RRX_detect(f0,d0,data,sigma_s,sigma_r,r,lamda)
%RRX_DETECT Summary of this function goes here
%   Detailed explanation goes here
% level = graythresh(d0);
% d0 = im2bw(d0,level);
for i=1:size(d0,3)
se = strel('square',r);
di = d0(:,:,i);
d1 = imdilate(di,se);
% d1=di;
% d2 = imerode(d0,se);
level = graythresh(d1);
d1 = im2bw(d1,level);
% surround measure
% [idx,idy]=find_bond(d1);
% d1 =~(imfill(~d1,[idx,idy]));
d1 = bwareafilt(d1,[1 size(d0,1)*size(d0,2)/lamda]);
di(d1==0)=0;
% d(:,:,i) = RF(double(di), 100, 0.2, 3, f0);
% end
% d=sum(d,3);
d(:,:,i) =di;
end
d=sum(d,3);
d=mat2gray(d);
d = RF(double(d), sigma_s,sigma_r, 3, f0);
% d = guidedfilter(f0,double(d),10,0.1^4);
% for i=1:size(d,3)
% se = strel('square',1);
% di = d(:,:,i);
% d1 = imdilate(di,se);
% % d2 = imerode(d0,se);
% level = graythresh(d1);
% d1 = im2bw(d1,level);
% % surround measure
% % [idx,idy]=find_bond(d1);
% % d1 =~(imfill(~d1,[idx,idy]));
% d1 = bwareafilt(d1,[1 size(d0,1)*size(d0,2)/100]);
% di(d1==0)=0;
% % d(:,:,i) = RF(double(di), 100, 0.2, 3, f0);
% % end
% % d=sum(d,3);
% d(:,:,i) =di;
% end
% d=sum(d,3);
% d = RF(double(d), 100, 0.2, 3, f0);
% d1 = im2bw(d1,0.6);
% RX measure
% r0 = RRX(d1,data);


end
function result=RRX(d1,data)
cc=bwlabel(d1);
se2 = strel('square',4);
ww=imdilate(cc,se2);
ss=(ww-cc);
result=zeros(size(d1,1),size(d1,2));
% r0 = RRX(d1,data);
for i=1:max(cc(:))
    [object_x,object_y]=find(cc==i);
    X=data(object_x,object_y,:);
    [backgrd_x,backgrd_y]=find(ss==i);
    Y=data(backgrd_x,backgrd_y,:);
    result(object_x,object_y)=RX_xy(X,Y);
end

end
function [idx,idy]=find_bond(d)
[r,c]=size(d);
idx0=zeros(r,c);
idx0(:,1)=1;
idx0(:,r)=1;
idx0(1,:)=1;
idx0(c,:)=1;
[idx,idy]=find(idx0==1);
end

function D=RX_xy(X,Y)
[rows_x,columns_x bands]=size(X);    
[rows_y,columns_y bands]=size(Y);    
X=reshape(X, rows_x*columns_x, bands);
Y=reshape(Y, rows_y*columns_y, bands);
% RX detection
X=X';
Y=Y';
[N M] = size(X);

Y_mean = mean(Y.').';

X = abs(X - repmat(Y_mean, [1 M]));

Sigma = (X * X')/M;

Sigma_inv = inv(Sigma);
for m = 1:M
 D(m) = X(:, m)' * Sigma_inv * X(:, m);
end
% map reshape
D = reshape(D,[rows_x columns_x]);
end

