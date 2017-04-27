%Basado en el metodo Object category detection del Oxford Visual Geometry Group 
%Autoria de Andrea Vedaldi y Andrew Zisserman.

clc;
clear all;
setup ;

%%


% Training cofiguration
targetClass = 1 ;
numHardNegativeMiningIterations = 5 ;
schedule = [1 2 5 5 5] ;

% Scale space configuration
hogCellSize = 7 ;
minScale = -1 ;
maxScale = 3 ;
numOctaveSubdivisions = 3 ;
scales = 2.^linspace(...
    minScale,...
    maxScale,...
    numOctaveSubdivisions*(maxScale-minScale+1)) ;

%%

%Cargo Data de Preprocesamiento

if(exist('faces.mat','file')==0)
    run('pre.m');
end

load('faces.mat');
%%

% -------------------------------------------------------------------------
% Step 5.1: Construct custom training data
% -------------------------------------------------------------------------
% if(exist('train.mat','file')==0)
    % Load object examples
    trainImages = negatives ;
    trainBoxes = [] ;
    trainBoxPatches = {} ;
    trainBoxImages = {} ;
    trainBoxLabels = [] ;
    
    % Construct negative data
    for i=1:numel(traincrop)
        t = imread(traincrop{i}) ;
        t = im2single(t) ;
        t = imresize(t, [80 80]) ;
        trainBoxes(:,i) = [0.5 ; 0.5 ; 80.5 ; 80.5] ;
        trainBoxPatches{i} = t ;
        trainBoxImages{i} = traincrop{i} ;
        trainBoxLabels(i) = 1 ;
    end
    
    trainBoxPatches = cat(4, trainBoxPatches{:}) ;
    
    % Compute HOG features of examples (see Step 1.2)
    trainBoxHog = {} ;
    for i = 1:size(trainBoxPatches,4)
        trainBoxHog{i} = vl_hog(trainBoxPatches(:,:,:,i), hogCellSize) ;
    end
    trainBoxHog = cat(4, trainBoxHog{:}) ;
    modelWidth = size(trainBoxHog,2) ;
    modelHeight = size(trainBoxHog,1) ;
    display('Loading data: Done');
    save('train.mat','-v7.3');
    display('Saving data: Done');


%%
% -------------------------------------------------------------------------
% Step 5.3: Train with hard negative mining
% -------------------------------------------------------------------------

if(exist('model.mat','file')==0)
    % Initial positive and negative data
    pos = trainBoxHog(:,:,:,ismember(trainBoxLabels,targetClass)) ;
    neg = zeros(size(pos,1),size(pos,2),size(pos,3),0) ;
    
    for t=1:numHardNegativeMiningIterations
        numPos = size(pos,4) ;
        numNeg = size(neg,4) ;
        C = 1 ;
        lambda = 1 / (C * (numPos + numNeg)) ;
        
        fprintf('Hard negative mining iteration %d: pos %d, neg %d\n', ...
            t, numPos, numNeg) ;
        
        % Train an SVM model (see Step 2.2)
        x = cat(4, pos, neg) ;
        x = reshape(x, [], numPos + numNeg) ;
        y = [ones(1, size(pos,4)) -ones(1, size(neg,4))] ;
        w = vl_svmtrain(x,y,lambda,'epsilon',0.01,'verbose') ;
        w = single(reshape(w, modelHeight, modelWidth, [])) ;
        
        % Plot model
        figure(2) ; clf ;
        imagesc(vl_hog('render', w)) ;
        colormap gray ;
        axis equal ;
        title('SVM HOG model') ;
        
        % Evaluate on training data and mine hard negatives
        figure(3) ;
        [matches, moreNeg] = ...
            evaluateModel(...
            vl_colsubset(trainImages', schedule(t), 'beginning'), ...
            trainBoxes, trainBoxImages, ...
            w, hogCellSize, scales) ;
        
        % Add negatives
        neg = cat(4, neg, moreNeg) ;
        
        % Remove negative duplicates
        z = reshape(neg, [], size(neg,4)) ;
        [~,keep] = unique(z','stable','rows') ;
        neg = neg(:,:,:,keep) ;
    end
    save('model.mat','w','hogCellSize', 'scales')
else
    load('model.mat');
end

%%

% -------------------------------------------------------------------------
% Step 5.3: Evaluate the model on the test data
% -------------------------------------------------------------------------

if(exist('det.mat','file')==0)
    detecttest=cell(size(test));
    scorestest=cell(size(test));
    count=0;
    for i=1:numel(test)
        im = imread(test{i}) ;
        im = im2single(im) ;
        
        % Compute detections
        [detections, scores] = detect(im, w, hogCellSize, scales) ;
        keep = boxsuppress(detections, scores, 0.25) ;
        detections = detections(:, keep(1:10)) ;
        scores = scores(keep(1:10)) ;
        detecttest{i}=detections;
        scorestest{i}=scores;
        display(num2str(100*i/numel(test),'%.2f'));
        count=i;
         save('det.mat','scorestest','detecttest','count','-v7.3');
    end
   
else
    load('det.mat');
    if(count<numel(test))
        i2=count;
        for i=i2:numel(test)
            im = imread(test{i}) ;
            im = im2single(im) ;
            
            % Compute detections
            [detections, scores] = detect(im, w, hogCellSize, scales) ;
            keep = boxsuppress(detections, scores, 0.25) ;
            detections = detections(:, keep(1:10)) ;
            scores = scores(keep(1:10)) ;
            detecttest{i}=detections;
            scorestest{i}=scores;
            display(num2str(100*i/numel(test),'%.2f'));
            count=i;
             save('det.mat','scorestest','detecttest','count','-v7.3');
        end
    end
end

%%

%Guardo Anotaciones en el formato especifico

maxs=max(cell2mat(scorestest));
dirpred='pred400';
if(exist(dirpred,'dir')==0)
mkdir(dirpred);
end
for i=1:numel(test)
    name=textscan(test{i},'%s', 'delimiter', '\');
    event=name{1}{3};
    name=name{1}{4};
    name=name(1:end-4);
    if(exist(fullfile(dirpred,event),'dir')==0)
        mkdir(fullfile(dirpred,event));
    end
    fid = fopen( strcat(dirpred,'\',event,'\',name,'.txt'), 'wt' );
    fprintf( fid, '%s\n', name);
    
    nbox=numel(scorestest{i});
    fprintf( fid, '%i\n', nbox);
    
    detections=detecttest{i};
    for j=1:nbox
        scorej= scorestest{i}(j);
        scorej=scorej/maxs;
        detj=round(detections(:,j)');
        w=detj(3)-detj(1);
        h=detj(4)-detj(2);
        fprintf( fid, '%i %i %i %i%6.2f\n', detj(1),detj(2),w,h,scorej);
    end
    display(strcat(num2str(100*i/numel(test),'%6.2f\n'),'%'));
    fclose(fid);
end

%%

% Plot detection

i=10;
im=imread(test{i});
detections=detecttest{i};
scores=scorestest{i};
figure(3) ; clf ;
imagesc(im) ; axis equal ;
hold on ;
vl_plotbox(detections, 'g', 'linewidth', 2, ...
  'label', arrayfun(@(x)sprintf('%.2f',x),scores,'uniformoutput',0)) ;
title('Multiple detections') ;
