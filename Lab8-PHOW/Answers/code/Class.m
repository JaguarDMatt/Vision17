%Classification

clc,
clear all,

%Categorias
test=dir('data/imageNet200/test');
names=extractfield(test,'name');
names=names(3:end);

%%

%Prediccion de clasificacion y almacenamiento de verdad
if(exist('res.mat','file')==0)
	%Cargo modelo final de clasificacion
	load('data/final/baseline-model.mat');
%Cargo libreria VLfeat
run('vlfeat-0.9.20/toolbox/vl_setup');
    labels={};
    ground={};
    con=1;
    tic;
    for i=1:numel(names)
        diri=dir(fullfile('data','imageNet200','test',names{i}));
        namesi=extractfield(diri,'name');
        namesi=namesi(3:end);
        for j=1:numel(namesi)
            if(strcmp( namesi{j}(end-3:end),'JPEG')==0)
                continue;
            else
                im=imread(fullfile('data','imageNet200','test',names{i},namesi{j}));
                labels{con}= model.classify(model, im);
                ground{con}=names{i};
                con=con+1;
                display(con);
            end
        end
    end
    display(toc);
    save('res.mat','labels','ground','names');
else
    load('res.mat');
end

%%

%Numero de categoria por etiqueta
if(exist('res2.mat','file')==0)
    gi=zeros(size(ground));
    li=zeros(size(labels));
    for i=1:numel(ground)
        gn=ground{i};
        ln=labels{i};
        gii=0;
        lii=0;
        for j=1:numel(names)
            nj=names{j};
            if strcmpi(nj,gn)==1
                gii=j;
            end
            if strcmpi(nj,ln)==1
                lii=j;
            end
            if(gii>0 && lii>0)
                break;
            end
        end
        gi(i)=gii;
        li(i)=lii;
    end
    save('res2.mat','li','gi');
else
    load('res2.mat');
end

%%

%Matriz de confusion
[C,order] = confusionmat(gi,li);
diagonal=diag(C);

C2=C;
%Normalizo columnas
for i=1:numel(diagonal)
   suma=sum( C2(:,i));
   C2(:,i)=C2(:,i)/suma;
end
%Extraigo diagonal
diagonal2=diag(C2);
%Calculo ACA
ACA=mean(diagonal);

%%

%Grafica de la matriz
image(C)
title(strcat('Confusion matrix ACA=',num2str(ACA),'%'));


%%

%Mejores clases y peores

orden=cat(1,diagonal2',1:200);
[Y,I]=sort(orden(1,:),'descend');
B=orden(:,I);
peores=B(2,end-4:end);
mejores=B(2,1:5);

%mejores clases y ACAs
best=names(mejores);
ACAbest=diagonal2(mejores);

%peores clases y ACAs
worst=names(peores);
ACAworst=diagonal2(peores);