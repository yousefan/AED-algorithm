function [ d ] = morph_detect( f0,para,type)
%PREDETECTION Summary of this function goes here
%   Detailed explanation goes here
bands_number=size(f0,3);
switch lower(type)
    case 'a'
x=EMAP_xdk(f0,'',false, '', 'a', para);
[d_feature b_feature] = dirfea(x,bands_number);
% d = mat2gray(d_feature+b_feature);
d=b_feature;
    case 'd'
x=EMAP_xdk(f0,'',false, '', 'd', para);
d_feature=(abs(x(:,:,1)-x(:,:,2)));
b_feature=(abs(x(:,:,3)-x(:,:,2)));
d = mat2gray(d_feature+b_feature);
    case 'i'
x=EMAP_xdk(f0,'',false, '', 'i', para);
d_feature=(abs(x(:,:,1)-x(:,:,2)));
b_feature=(abs(x(:,:,3)-x(:,:,2)));
d = mat2gray(d_feature+b_feature);
    case 's'
x=EMAP_xdk(f0,'',false, '', 's', para);
d_feature=(abs(x(:,:,1)-x(:,:,2)));
b_feature=(abs(x(:,:,3)-x(:,:,2)));
d = mat2gray(d_feature+b_feature); 
end
end
function [spectral_feature spatial_feature] = dirfea(x,bands_number)

for i=1:bands_number
    spatial_feature(:,:,i)=x(:,:,i*3-2)-x(:,:,i*3);
    if i==1
    spectral_feature(:,:,i)=zeros(size(x,1),size(x,2));
    else
    spectral_feature(:,:,i)=abs(x(:,:,i*3-1)-x(:,:,(i-1)*3-1));
    end
end
spectral_feature=double(mat2gray(spectral_feature));
spatial_feature=double(mat2gray(spatial_feature));
end



