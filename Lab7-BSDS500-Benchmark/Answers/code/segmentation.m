%Segmentation


%Extaer nombres directorios de imagenes

addpath(genpath('images'));

direct=dir('images');

namesdir=extractfield(direct,'name');

namesdir=namesdir(3:end);


%creo directorio de segmentaciones

if( exist('segs','dir')==0)
    
mkdir('segs');

end


%Espacios, metodos y numeros de clusters a usar

ks=5:10;

methods={'k-means','gmm'};

colorspace={'hsv','rgb+xy'};



%Cargo los nombres de las imagenes

for i=1:numel(namesdir)
    
diri=dir(fullfile('images',namesdir{i}));

namesdiri=extractfield(diri,'name');
    
namesdiri=namesdiri(3:end-1);
    
mkdir(fullfile('segs',namesdir{i}));
    
for j=1:numel(namesdiri);
        
names=namesdiri{j};
        
namesf=fullfile('images',namesdir{i},namesdiri{j});
        
im=imread(namesf);
        
nameim=names(1:end-4);
        
        
if( exist(fullfile('segs',namesdir{i},strcat(nameim,'.mat')),'file')==0)
            
%Creo cell array de segmentaciones
            
segs=cell(1,12);
            
con=1;
            
for g=1:numel(methods)
                
for k=1:numel(ks)
                    
segs{con}=uint8(segmentByClustering(im,colorspace{g},methods{g},ks(k)));
                    
con=con+1;
                
end
            
end
            
%Almaceno de cell array con segmentaciones
            
save(strcat(nameim,'.mat'),'segs');
            
%Lo muevo a la carpeta segs
            
movefile(strcat(nameim,'.mat'),fullfile('segs',namesdir{i}));
        
else
            
continue;
        
end
        
    
end

end
