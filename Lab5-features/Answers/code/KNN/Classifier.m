clear all;
clc;
addpath('lib');
addpath(genpath('textures'));

%Lectura archivos de prueba
train=dir('textures/train');
trainname = extractfield(train,'name');
trainname=trainname(3:end-1);

%%

for z=1:30;
    
    %Nombres imagenes de este grupo
    trainnamez=trainname(z:30:750);
    %Crear el filtro de bancos
    [bt] = fbCreate;
    
    %Numero k de bins
    k = 16*4;
    
    %Imagenes de entrenamiento
    imr=cell(size(trainnamez));
    %Anotaciones
    anotr=cell(numel(trainnamez),1);
    for i=1:numel(trainnamez)
        imi=imread(fullfile('textures','train',trainnamez{i}));
        %almaceno la anotacion
        anotr{i}=trainnamez{i}(1:3);
        imr{i}=double(imi)/255;
    end
    
    h=cell2mat(imr);
    
    filterResponses=fbRun(bt,h);
    
    [map,textons] = computeTextons(filterResponses,k);
    
    %Histogramas de cada observacion
    data=zeros(numel(trainnamez),k);
    
    for i=1:numel(trainnamez)
        %Generacion histograma
        tmapBase = assignTextons(fbRun(bt,imr{i}),textons');
        baseh=histc(tmapBase(:),1:k)/numel(tmapBase);
        %Almaceno histograma
        data(i,:)=baseh;
    end
    
    %Construccion clasificador
    
    knd=fitcknn(data,anotr,'Distance',@(x,Z,wt)sqrt((bsxfun(@minus,x,Z).^2)*(ones(64,1)*(1/64))));
    %Almaceno el clasificador de este grupo
    save(strcat('class',num2str(z),'.mat'),'bt','textons','map','knd');
end
