clc;
clear all;
setup ;

%Basado en el metodo Object category detection del Oxford Visual Geometry Group 
%Autoria de Andrea Vedaldi y Andrew Zisserman.

% Training cofiguration
targetClass = 1 ;
numHardNegativeMiningIterations = 1 ;
schedule = [1 2 5 5 5] ;

% Scale space configuration
hogCellSize = 8 ;
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


    % Load object examples
    trainImages = {} ;
    trainBoxes = [] ;
    trainBoxPatches = {} ;
    trainBoxImages = {} ;
    trainBoxLabels = [] ;
    
    % Construct negative data
    names = {};
    j=1;
    k=1;
    
    for i=1:numel(train)
        if(isempty(boxes{i}))
            trainImages{k}=train{i};
            k=k+1;
        else
            t = imread(train{i}) ;
            t = im2single(t) ;
            boxi=boxes{i}';
            tmp = imcrop(t, [boxi(1) boxi(2) boxi(3)-boxi(1) boxi(4)-boxi(2)]);
            tmp = imresize(tmp, [80 80]) ;
            trainBoxes(:,j) = boxi ;
            trainBoxPatches{j} = tmp ;
            trainBoxImages{j} = train{i} ;
            trainBoxLabels(j) = 1 ;
            j=j+1;
        end
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
    
    save('train.mat','trainBoxImages','modelWidth','modelHeight','trainBoxHog','trainBoxPatches','trainBoxes','trainBoxLabels','trainImages','-v7.3');

%%

% -------------------------------------------------------------------------
% Step 5.2: Visualize the training images
% -------------------------------------------------------------------------

figure(1) ; clf ;

subplot(1,2,1) ;
imagesc(vl_imarraysc(trainBoxPatches)) ;
axis off ;
title('Training images (positive samples)') ;
axis equal ;

subplot(1,2,2) ;
imagesc(mean(trainBoxPatches,4)) ;
box off ;
title('Average') ;
axis equal ;

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
        display(i/numel(test));
    end
    save('det.mat','scorestest','detecttest','-v7.3');
else
    load('det.mat');
end

%%

%Guardo Anotaciones en el formato especifico

maxs=max(cell2mat(scorestest));
if(exist('pred','dir')==0)
mkdir('pred');
end
for i=1:numel(test)
    name=textscan(test{i},'%s', 'delimiter', '\');
    event=name{1}{3};
    name=name{1}{4};
    name=name(1:end-4);
    if(exist(fullfile('pred',event),'dir')==0)
        mkdir(fullfile('pred',event));
    end
    fid = fopen( strcat('pred\',event,'\',name,'.txt'), 'wt' );
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
    fclose(fid);
end

%%

% Plot detection

i=79;
im=imread(test{i});
detections=detecttest{i};
scores=scorestest{i};
figure(3) ; clf ;
imagesc(im) ; axis equal ;
hold on ;
vl_plotbox(detections, 'g', 'linewidth', 2, ...
  'label', arrayfun(@(x)sprintf('%.2f',x),scores,'uniformoutput',0)) ;
title('Multiple detections') ;
