clc, clear
close all
%%%% Load the hyperspectral image and the ground truth
% addpath('./Dataset')
addpath(genpath('.\functions'));

image = 2;
[data, map] = ReadData(num2str(image));
% path = './Dataset/';
% inputs = 'San';
% location = [path, inputs];
% load (location);
%%%% Data normalization 
data2 = NormalizeData(data);
%%%% Reduce the dimension of the data
numb_dimension = 3;
f0 = PCA_img(data, numb_dimension);
f0 = NormalizeData(f0);
g0 = PCA_img(data, numb_dimension);
g0 = NormalizeData(g0);
%%%% Set attribute filter optimal parameters
tic
if image == 5 
    para = 5; 
elseif image == 2
    para = 64;
else
    para = 25;
end
type = 'a';
%%%% Attribute filter
d0 = morph_detect(f0, para, type);

%%%% Postprocessing with edge-preserving filtering
if image == 1 || image == 5
    r0 = RRX_detect(g0, d0, data2, 5, 1, 2, 100);
else
    r0 = RRX_detect(g0, d0, data2, 5, 0.5, 2, 100);
end
toc
%%%% Evaluate the results
r0 = mat2gray(r0);
[PD0 PF0] = roc(map(:), r0(:));
area0 = -sum((PF0(1:end-1)-PF0(2:end)).*(PD0(2:end)+PD0(1:end-1))/2);
result_img = ImGray2Pseudocolor(r0, 'hot', 255);
figure, imshow(r0);

