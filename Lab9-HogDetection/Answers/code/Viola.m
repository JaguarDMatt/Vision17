clc;
clear all;

if(exist('faces.mat','file')==0)
    run('prepro.m');
end
load('faces.mat');
%%
%Negatives
neg = imageDatastore(fullfile('data','Negatives'),'IncludeSubfolders',true);

%%
%Positives

if(exist('JonesPos.mat','file')==0)
    [m,n]=size(traincrop);
    imageFilename=cell(n,m);
    faces=cell(n,m);
    for i=1:numel(traincrop)
        crop=imread(traincrop{i});
        [x,y,z]=size(crop);
        imageFilename{i}=traincrop{i};
        faces{i}=[2 2 y-2 x-2];
    end
    save('JonesPos.mat','imageFilename','faces');
else
    load('JonesPos.mat');
end
positiveInstances=table(imageFilename(1:1000),faces(1:1000));

display('Positives: Done');

%%

%Training

trainCascadeObjectDetector('faceDetector1010.xml',positiveInstances,neg,'FalseAlarmRate',0.1,'NumCascadeStages',10, 'FeatureType','Haar');
display('Training: Done');

%%

%Detection
detector = vision.CascadeObjectDetector('faceDetector1010.xml');

detecttest=cell(size(test));
for i=1:numel(test)
    im = imread(test{i}) ;
    detecttest{i}=step(detector,im);
    display(num2str(100*i/numel(test),'%.2f'));
end
save('detJones.mat','detecttest','-v7.3');

display('Detection: Done');

%%

%Save preditions

if(exist('Jonespred','dir')==0)
    mkdir('Jonespred');
end

gau=@(x,u,std) exp(-(x-u)^2/(2*std^2));

for i=1:numel(test)
    name=textscan(test{i},'%s', 'delimiter', '\');
    event=name{1}{3};
    name=name{1}{4};
    name=name(1:end-4);
    if(exist(fullfile('Jonespred',event),'dir')==0)
        mkdir(fullfile('Jonespred',event));
    end
    fid = fopen( strcat('Jonespred\',event,'\',name,'.txt'), 'wt' );
    fprintf( fid, '%s\n', name);
    
    detections=detecttest{i};
    nbox=size(detections,1);
    fprintf( fid, '%i\n', nbox);
    
    for j=1:nbox
        detj=round(detections(j,:));
        w=detj(3);
        h=detj(4);
        scorej=gau((w+h)/2,80,40);
        
        fprintf( fid, '%i %i %i %i%6.2f\n', detj(1),detj(2),w,h,scorej);
    end
    display(strcat(num2str(100*i/numel(test),'%6.2f\n'),'%'));
    fclose(fid);
end

display('Save Preditions: Done');

%%

%Show images

img = imread(test{2});
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox2,'face');
imshow(detectedImg);