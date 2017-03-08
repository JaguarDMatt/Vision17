%Generacion matrices de confusion de arboles

%Cargo resultados clasificacion
load('datapred.mat');

%Creo matrices de verdad y prediccion
target=zeros(25,250);
output1=zeros(25,250);
output2=zeros(25,250);

%Las lleno con las predicciones por categoria
for i=1:250
 pos=anott(i);  
 target(pos,i)=1;
 pos2=pred1(i);
 output1(pos2,i)=1;
 pos3=str2num(pred2{i});
 output2(pos3,i)=1;
end

%%
%Genero matrix visual del primer clasificador
plotconfusion(target,output1);

%%
%Genero matrix visual del segundo clasificador
plotconfusion(target,output2);