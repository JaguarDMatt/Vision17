%Imagen Hibrida

clear all;
clc;

%Lectura imagenes
pop=imread('Face2.jpg');
matt=imread('Face1.jpg');

%Preprocesamiento
siz=[1100 850];
matt=imresize(matt,siz);
pop=imresize(pop,siz);

%Transformacion de Fourier
mf1=fft2(matt(:,:,1));
mf2=fft2(matt(:,:,2));
mf3=fft2(matt(:,:,3));
pf1=fft2(pop(:,:,1));
pf2=fft2(pop(:,:,2));
pf3=fft2(pop(:,:,3));


%Generacion filtro pasa bajas y pasa altas
circulo=ones(siz);
centrox=siz(1)/2;
centroy=siz(2)/2;
for i=1:siz(1)
    for j=1:siz(2)
        if((i-centrox)^2+(j-centroy)^2<=72)
            circulo(i,j)=0;
        end
    end
end
circulo2=ones(size(circulo))-circulo;

%Shift para filtrado
mf1=fftshift(mf1);
pf1=fftshift(pf1);
mf2=fftshift(mf2);
pf2=fftshift(pf2);
mf3=fftshift(mf3);
pf3=fftshift(pf3);

%Filtrado de cada canal
mff1=times(circulo2,mf1);
pff1=times(circulo,pf1);
mff2=times(circulo2,mf2);
pff2=times(circulo,pf2);
mff3=times(circulo2,mf3);
pff3=times(circulo,pf3);

%Suma para generar imagenes hibridas
hf1=mff1+pff1;
hf2=mff2+pff2;
hf3=mff3+pff3;

%Shift inverso de los canales de la imagen hibrida
hff1=ifftshift(hf1);
hff2=ifftshift(hf2);
hff3=ifftshift(hf3);

%Transformacion inversa de cada canal
hyb1=uint8(real(ifft2(hff1)));
hyb2=uint8(real(ifft2(hff2)));
hyb3=uint8(real(ifft2(hff3)));

%Generacion imagen RGB
hyb=cat(3,hyb1,hyb2,hyb3);

%Visualizacion
imshow(hyb);

%Guardar imagen
imwrite(hyb,'hyb.jpg');

%Generacion Piramide Gaussiana primer imagen
figure;

%Numero de imagenes en la piramide
n=7;

%Piramide
pir=cell(n,1);

%Piramide a la misma escala
pir2=cell(n,1);

%Guardo original
pir{1}=hyb;
pir2{1}=hyb;
h=subplot(1,n,1);
imshow(hyb);

for i=2:n
    %Generacion del siguiente elemento de la piramide
   pir{i}=impyramid(pir{i-1},'reduce'); 
   hi=subplot(1,n,i);
   %Almaceno el handle
   h=[h hi];
   pir2{i}=imresize(pir{i},siz);
   imshow(pir{i});
end

%Observar a sus respectivas escalas la piramide
linkaxes(h,'x');

%Guardo piramide a la misma escala
Pir2=cell2mat(pir2);
imwrite(Pir2,'pyr2.jpg');