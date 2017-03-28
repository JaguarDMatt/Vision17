function [segmentation] = segmentByClustering( rgbImage, featureSpace, clusteringMethod, numberOfClusters)
% Segmentacion por Clustering con diferentes metodos y espacios de color

%Determino si son mas de dos clusters
if(numberOfClusters<3)
    error('Number of clusters must be larger that two')
end

%Convierto la imagen al espacio de color que entra por parametro
switch featureSpace
    case  'lab'
        image=rgb2lab(rgbImage);
        usexy=false;
    case  'hsv'
        image=rgb2hsv(rgbImage);
        usexy=false;
    case  'rgb+xy'
        image=rgbImage;
        usexy=true;
    case  'lab+xy'
        image=rgb2lab(rgbImage);
        usexy=true;
    case  'hsv+xy'
        image=rgb2hsv(rgbImage);
        usexy=true;
    case 'rgb'
        image=rgbImage;
        usexy=false;
    otherwise
        error('Feature space not recognized');
end

%Tamaño de un canal de la imagen
m=size(image,1);
n=size(image,2);

%Si tengo que usar las coordenadas, las agrego a la imagen
if(usexy)
    imaget=zeros(m,n,5,'double');
    imaget(:,:,1:3)=image;
    [xs,ys]=meshgrid(1:n,1:m);
    imaget(:,:,4)=xs;
    imaget(:,:,5)=ys;
    image=imaget;
end

%Dimensiones de la imagen
z=size(image,3);

%Numero de clusters
k=numberOfClusters;

% Segmento dependiendo del metodo elegido
switch clusteringMethod
    case 'k-means'
        vectors=reshape(image,m*n,z);
        [id,C]=kmeans(double(vectors),k,'distance','sqEuclidean','Replicates',z);
        segmentation = reshape(id,m,n);
    case 'gmm'
        vectors=reshape(image,m*n,z);
        GMModel = fitgmdist(double(vectors),k,'SharedCovariance',true);
        idx=cluster(GMModel,double(vectors));
        segmentation = reshape(idx,m,n);
    case 'hierarchical'
        imager=imresize(image(:,:,1:3),1/2);
        [m2,n2,z]=size(imager);
        new=reshape(imager,m2*n2,z);
        dist= linkage(double(new),'centroid','euclidean','savememory','on');
        t=cluster(dist,'maxclust',k);
        nums=unique(t);
        if(numel(nums)<k)
            t=cluster(dist,'maxclust',k+1);
        end
        segmentation1 = reshape(t,m2,n2);
        segmentation=round(imresize(segmentation1,[m n]));
    case 'watershed'
        imagegray=zeros(m,n);
        if(z==5)
            we=[0.8/3 0.8/3 0.8/3 0.1 0.1];
        else
            we=ones(z,1)*1/z;
        end
        
        for i=1:m
            for j=1:n
                sum=0;
                for o=1:z
                    if(o<4 && strcmp(featureSpace,'hsv+xy')==1)
                        val= image(i,j,o)*255;
                    elseif(strcmp(featureSpace,'hsv')==1)
                        val= image(i,j,o)*255;
                    else
                        val=image(i,j,o);
                    end
                    sum=sum+(we(o)*val);
                end
                imagegray(i,j)=sum/z;
            end
        end
        Gmag=imgradient(imagegray);
        BW = imextendedmin(imagegray,1);
        Gmagi=imimposemin(Gmag,BW);
        L= watershed(Gmagi);
        
        for i=2:100
            Lviejo=L;
            BW = imextendedmin(imagegray,i);
            Gmagi=imimposemin(Gmag,BW);
            L= watershed(Gmagi);
            u=unique(L);
            if(numel(u)==k)
                break;
            elseif(k>numel(u))
                L= Lviejo;
                break;
            end
        end
        segmentation=L;
    otherwise
        error('Clustering method not recognized');
end

end

