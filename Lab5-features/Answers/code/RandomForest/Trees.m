clear all;
clc;
addpath('lib');
addpath(genpath('textures'));

%Lectura archivos de prueba
train=dir('textures/train');
trainname = extractfield(train,'name');
trainname=trainname(3:end-1);

%Comienzo del banco de filtros
[bt] = fbCreate;

%Numero de bins
k = 16*4;

%imagenes por categoria
l=3;

%Llenar celula con nombres de l imagenes por categoria
trainnames=cell(1,25*l);
for i=0:24
    par=(30*i)+1:(30*i)+l;
    j=(i*l)+1:(i+1)*l;
    trainnames(j)=trainname(par);
end

%Respuestas Imagen de entrenamiento
res=cell(size(trainnames));

%Respuestas

for i=1:numel(trainnames)
    imi=imread(fullfile('textures','train',trainnames{i}));
    imi=double(imi)/255;
    res{i}=fbRun(bt,imi);
end

%Concatenacion de Respuestas
filterResponses=cell(size(res{1}));
for i=1:size(filterResponses,1)
    for j=1:size(filterResponses,2)
        texton=res{1}{i,j};
        for h=2:numel(trainnames)
            texton=horzcat(texton,res{h}{i,j});
        end
        filterResponses{i,j}=texton;
    end
end
    
%Computar y guardar textones
[map,textons] = computeTextons(filterResponses,k);

save('bt.mat','bt','map','textons','anot');

%%

%Representacion imagenes de entrenamiento

data=cell(30,1);

for z=0:29;
    trainnamez=trainname((z*25)+1:(z+1)*25);
    dataz=zeros(numel(trainnamez),k);
    for i=1:numel(trainnamez)
        imi=imread(fullfile('textures','train',trainnamez{i}));
        imi=double(imi)/255;
        tmapBase = assignTextons(fbRun(bt,imi),textons');
        baseh=histc(tmapBase(:),1:k)/numel(tmapBase);
        dataz(i,:)=baseh;
    end
    
data{z+1}=dataz;
save('data.mat',data);
end

%Anotaciones
anot=cell(numel(trainname),1);
for i=1:numel(trainname)
 anot{i}=str2num(trainname{i}(2:3));
end

save('data.mat','data','anot');

%Construccion clasificador
dataz=cell2mat(data);
anot=cell2mat(anot);

tree1=fitctree(dataz,anot);
tree2 = TreeBagger(25,dataz,anot);

save('trees.mat','tree1','tree2');