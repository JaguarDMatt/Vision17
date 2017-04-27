clc;
clear all;

%%

%Cargo nombres de eventos
dirtrain=dir(fullfile('data','TrainImages'));
dirtcrop=dir(fullfile('data','TrainCrops'));
dirtest=dir(fullfile('data','TestImages'));
dirneg=dir(fullfile('data','Negatives'));

namesdirtrain= extractfield(dirtrain,'name');
namesdirtcrop = extractfield(dirtcrop,'name');
namesdirtest = extractfield(dirtest,'name');
namesdirneg = extractfield(dirneg,'name');

namesdirtrain=namesdirtrain(3:end);
namesdirtcrop=namesdirtcrop(3:end);
namesdirtest=namesdirtest(3:end);
namesdirneg=namesdirneg(3:end);
%%

%Cargo nombres imagenes de entrenamiento y su nombre para busqueda
train=[];
trainsearch=[];

for i=1:numel(namesdirtrain)
    traindi=dir(fullfile('data','TrainImages',namesdirtrain{i}));
    ntraindi=extractfield(traindi,'name');
    ntraindi=ntraindi(3:end);
    for j=1:numel(ntraindi)
        if(strcmpi(ntraindi{j}(end-3:end),'.jpg')==1)
            train{end+1}=fullfile('data','TrainImages',namesdirtrain{i},ntraindi{j});
            trainsearch{end+1}=strcat(namesdirtrain{i},'/',ntraindi{j});
        end
    end
end

%Cargo nombre de imagenes de test

test=[];

for i=1:numel(namesdirtest)
    testdi=dir(fullfile('data','TestImages',namesdirtest{i}));
    ntestdi=extractfield(testdi,'name');
    ntestdi=ntestdi(3:end);
    for j=1:numel(ntestdi)
        if(strcmpi(ntestdi{j}(end-3:end),'.jpg')==1)
            test{end+1}=fullfile('data','TestImages',namesdirtest{i},ntestdi{j});
        end
    end
end

traincrop=[];

for i=1:numel(namesdirtcrop)
    tcropdi=dir(fullfile('data','TrainCrops',namesdirtcrop{i}));
    ntcropdi=extractfield(tcropdi,'name');
    ntcropdi=ntcropdi(3:end);
    for j=1:numel(ntcropdi)
        if(strcmpi(ntcropdi{j}(end-3:end),'.jpg')==1)
            traincrop{end+1}=fullfile('data','TrainCrops',namesdirtcrop{i},ntcropdi{j});
        end
    end
end


negatives=[];
for i=1:numel(namesdirneg)
    if(strcmpi(namesdirneg{i}(end-3:end),'.jpg')==1)
        negatives{end+1}=fullfile('data','Negatives',namesdirneg{i});
    end
end

%%
% Leo anotaciones
fid = fopen(fullfile('data','wider_face_train_bbx_gt.txt'), 'rt');
s = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

%Busco caja mayor de 80x80 para cada imagen

boxes={};
for i=1:numel(trainsearch)
    %         t = imread(train{i}) ;
    %         t = im2single(t) ;
    
    idx = find(strcmp(s{1}, trainsearch{i}), 1, 'first');
    numbox=str2double(s{1}{idx+1});
    for j=1:numbox
        ln=s{1}{idx+1+j};
        if(ischar(ln))
            ln=textscan(ln,'%d %d %d %d %d %d %d %d %d %d');
            ln=cell2mat(ln);
        end
        if(ln(3)<80 || ln(4)<80)
            continue;
        else
            %                 tmp = imcrop(t, [ln(1) ln(2) ln(3) ln(4)]) ;
            %                 tmp = imresize(tmp, [80 80]) ;
            %                 patches{i}=tmp;
            boxes{i}=[ln(1) ln(2) ln(1)+ln(3) ln(4)+ln(2)];
        end
    end
end


%Guardo los nombres y las cajas

save('faces.mat','train','test','negatives','traincrop','boxes','-v7.3');
