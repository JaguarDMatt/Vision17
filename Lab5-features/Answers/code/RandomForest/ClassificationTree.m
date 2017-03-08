clc;
addpath('lib');
addpath(genpath('textures'));


%Lectura archivos de prueba
test=dir('textures/test');
testname = extractfield(test,'name');
testname=testname(3:end-1);
%%

%Numero bins
k=16*4;

%Carga del banco de filtros y textones
load('bt.mat');

%Creacion vector anotaciones verdaderas y representaciones
datat=cell(numel(testname),1);
anott=zeros(numel(testname),1);

%Generacion de la representacion y extraccion de la anotacion
for i=1:numel(testname)
    imi=imread(fullfile('textures','test',testname{i}));
    imi=double(imi)/255;
    anott(i)=str2num(testname{i}(2:3));
    tmapTest = assignTextons(fbRun(bt,imi),textons');
    testh=histc(tmapTest(:),1:k)/numel(tmapTest);
    datat{i}=testh;
end

%almaceno la informacin
save('datatest.mat','anott','datat');

%%

load('trees.mat');

%Clasificacion con ambos predictores
datag=cell2mat(datat');
pred1=predict(tree1,datag');
pred2=predict(tree2,datag');
save('datapred.mat','anott','pred1','pred2');
