%Cargar 

%Cargo resultados clasificacion
matrix=cell(3,1);
load('clasificacionF.mat');
matrix{1}=clasifyf;
load('clasificacionF2.mat');
matrix{2}=clasifyf;
load('clasificacionF3.mat');
matrix{3}=clasifyf;


%Uno clasificaciones
matf=cell2mat(matrix);
%Me guiare para la etiqueta como la moda de los resultados de prediccion de
%los 30 clasificadores para cada una de las 250 imagenes
out=mode(matf);

%Creo matrices de verdad y prediccion
target=zeros(25,250);
output=zeros(25,250);

%Las lleno
for i=1:250
 pos=anote(i);  
 target(pos,i)=1;
 pos2=out(i);
 output(pos2,i)=1;
end

%Genero matrix visual
plotconfusion(target,output);

%Genero matriz de confusion
matriz=confusionmat(anote,out);
