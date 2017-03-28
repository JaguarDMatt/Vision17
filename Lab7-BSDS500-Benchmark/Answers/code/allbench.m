% Adiciono funciones del benchmarks
addpath benchmarks
clear all;
close all;
clc;

%%

%Evaluacion Metodo Completo

%Extaer nombres directorios de imagenes
addpath(genpath('images'));
direct=dir('images');
namesdir=extractfield(direct,'name');
namesdir=namesdir(3:end);

%Evaluo cada carpeta
for i=1:numel(namesdir)
imgDir = fullfile('images',namesdir{i});
gtDir =fullfile('groundTruth',namesdir{i});
inDir=fullfile('segs',namesdir{i});
outDir = strcat('eval/',namesdir{i},'_all_fast');
mkdir(outDir);
nthresh = 99;
thinpb = 1; 
maxDist = 0.0075;
tic;
allBench(imgDir, gtDir, inDir, outDir, nthresh,maxDist,thinpb);
toc;
end