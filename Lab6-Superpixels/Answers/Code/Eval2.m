%Evaluacion
clc;
clear all;
addpath(genpath('Lab5Images'));
dirima=dir('Lab5Images');
names=extractfield(dirima,'name');
names=names(3:end);
mats=cell(numel(names)/2,1);
namei=cell(numel(names)/2,1);
con1=1;
con2=1;

%Extraigo nombres de los .mat
for i=1:numel(names)
    ext=names{i}(end-3:end);
    if(strcmp(ext,'.mat')==1)
        mats{con1}=names{i};
        con1=con1+1;
    else
        namei{con2}=names{i};
        con2=con2+1;
    end
end

%%

space={'rgb','rgb+xy','hsv','hsv+xy','lab','lab+xy'};
segmet={'k-means','watershed','gmm','hierarchical'};
clu=4;
A = exist('jaccard.mat');


if(A==0)
    %Si no existe el .mat, lo comienzo
    res=zeros(numel(mats),6,4);
    
    for s=1:numel(space)
        %Elijo el espacio
        spaces=space{s};
        for se=1:numel(segmet)
            %Elijo el metodo de segmentacion
            segmets=segmet{se};
            for i=1:numel(mats)
                %Cargo las anotaciones
                load(mats{i});
                %Cargo la imagen
                image=imread(namei{i});
                
                %Creo vector de Jaccard por anotacion
                jaccards=zeros(1,numel(groundTruth));
                for j=1:numel(groundTruth)
                    %Cargo anotacion
                    verdad=groundTruth{j};
                    a=double(verdad.Segmentation);
                    
                    %Extraigo los 4 clusters mas grandes de la anotacion
                    numlabels=unique(a);
                    histo=hist(a(:),numel(numlabels));
                    
                    %La segmento
                    seg=segmentByClustering(image,spaces,segmets,numel(numlabels));
                    
                    %Eligo 4 clusters mas grandes de la imagen original
                    numlabelsi=unique(seg);
                    histoi=hist(double(seg(:)),numel(numlabelsi));
                    Counti=[numlabelsi';histoi]';
                    cai=sortrows(Counti,-2);
                    labi=cai(1:clu,1);
                    
                    Count=[numlabels';histo]';
                    ca=sortrows(Count,-2);
                    lab=ca(1:clu,1);
                    jaccard=zeros(size(lab));
                    %Comparo por clusters
                    for k=1:clu
                        bw=a==lab(k);
                        bw2=seg==labi(k);
                        jaccard(k)=sum(bw & bw2)/sum(bw | bw2);
                    end
                    %Almaceno la media de Jaccard
                    jaccards(j)=mean(jaccard);
                end
                %Almaceno jaccard por imagen, metodo y espacio
                res(i,s,se)=mean(jaccards);
                %Guardo la respuesta
                save('jaccard.mat','res','segmets','spaces');
            end
            display(segmets);
        end
        display(spaces);
    end
else
    load('jaccard.mat');
    si=1;
    sei=1;
    
    %Calculo de ultimas posiciones antes de terminar
    for i=1:numel(segmet)
        if(strcmp(segmets,segmet{i})==1)
            sei=i;
            break;
        end
    end
    
    for i=1:numel(space)
        if(strcmp(spaces,space{i})==1)
            si=i;
            break;
        end
    end
    
    for s=si:numel(space)
        %Elijo el espacio
        spaces=space{s};
        for se=sei:numel(segmet)
            %Elijo el metodo de segmentacion
            segmets=segmet{se};
            for i=1:numel(mats)
                %Cargo las anotaciones
                load(mats{i});
                %Cargo la imagen
                image=imread(namei{i});
                
                %Creo vector de Jaccard por anotacion
                jaccards=zeros(1,numel(groundTruth));
                for j=1:numel(groundTruth)
                    %Cargo anotacion
                    verdad=groundTruth{j};
                    a=double(verdad.Segmentation);
                    
                    %Extraigo los 4 clusters mas grandes de la anotacion
                    numlabels=unique(a);
                    histo=hist(a(:),numel(numlabels));
                    
                    %La segmento
                    seg=segmentByClustering(image,spaces,segmets,numel(numlabels));
                    
                    %Eligo 4 clusters mas grandes de la imagen original
                    numlabelsi=unique(seg);
                    histoi=hist(double(seg(:)),numel(numlabelsi));
                    Counti=[numlabelsi';histoi]';
                    cai=sortrows(Counti,-2);
                    labi=cai(1:clu,1);
                    
                    Count=[numlabels';histo]';
                    ca=sortrows(Count,-2);
                    lab=ca(1:clu,1);
                    jaccard=zeros(size(lab));
                    %Comparo por clusters
                    for k=1:clu
                        bw=a==lab(k);
                        bw2=seg==labi(k);
                        jaccard(k)=sum(bw & bw2)/sum(bw | bw2);
                    end
                    %Almaceno la media de Jaccard
                    jaccards(j)=mean(jaccard);
                end
                %Almaceno jaccard por imagen, metodo y espacio
                res(i,s,se)=mean(jaccards);
                %Guardo la respuesta
                save('jaccard.mat','res','segmets','spaces');
            end
            display(segmets);
        end
        display(spaces);
    end
    
end
