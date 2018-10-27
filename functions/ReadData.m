function [data map] = ReadData(data_name)
%READDATA Summary of this function goes here
%   Detailed explanation goes here

switch lower(data_name)
    case '1'
    load('./data/San_Diego');
    case '2'
    load('./data/Airport'); 
    case '3'
    load('./data/Beach');
    case '4'
    load('./data/Urban');
    case '5'
    load('./data/HYDICE_urban');
end
end

