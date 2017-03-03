clc;
addpath('lib');
addpath(genpath('textures'));


%Lectura archivos de prueba
test=dir('textures/test');
testname = extractfield(test,'name');
testname=testname(3:end-1);

%Numero de  clasificadores
a=30;

%Numero de grupos
b=10;
%Imagenes por grupo
c=25;

%Numero de bins
k = 16*4;

%almaceno clasificacion de cada imagen por clasificadores
clasifyz=cell(a,1);
%Almaceno anotaciones de prueba
anote=zeros(1,numel(testname));
        
for z=1:a
    
    %Cargo el clasificador y banco de filtros
    load(strcat('class',num2str(z),'.mat'));
    %Almaceno clasificacion de este clasificador
    clasifyy=cell(1,b);
    for y=0:b-1
        %Particion de imagnes
        part=(y*c)+1:(y+1)*c;
        testnamey=testname(part);
        anotp=cell(numel(testnamey),1);
        anotpr=zeros(size(testnamey));
        
        for i=1:numel(testnamey)
            imi=imread(fullfile('textures','test',testnamey{i}));
            imi=double(imi)/255;
            anote((y*25)+i)=str2num(testnamey{i}(2:3));
            tmapTest = assignTextons(fbRun(bt,imi),textons');
            testh=histc(tmapTest(:),1:k)/numel(tmapTest);
            %almaceno histograma
            anotp{i}=testh';
        end
        
        %matriz de histogramas
        pred=cell2mat(anotp);
        %Predigo clasificacion
        gpreg=predict(knd,pred);
        
        %Paso de texto a numero la clasificacion
        for i=1:numel(gpreg)
            anotpr(i)= str2num(gpreg{i}(2:3));
        end
        %almaceno las prediciones de este clasificador
        clasifyy{y+1}=anotpr;
    end
    
    %genero y guardo la matriz de predicciones para este clasificador
    clasifyz{z}=cell2mat(clasifyy);
    save('clasificacion.mat','clasifyz','anote');
    display(z);
end

 %genero y guardo la matriz de predicciones para todos los clasificadores
clasifyf=cell2mat(clasifyz);
save('clasificacionF.mat','clasifyf','anote');
