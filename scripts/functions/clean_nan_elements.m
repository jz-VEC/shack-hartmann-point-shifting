function [centroids_x, centroids_y, lens_x, lens_y, w_x, w_y] = clean_nan_elements(centroids_x, centroids_y, lens_x, lens_y, w_x, w_y)
zz = [centroids_x, centroids_y, lens_x, lens_y, w_x, w_y];
num1=length(lens_x) ;
u=1;
for i=1 :num1 
    if (isnan(zz(u,1))==1 & isnan(zz(u,2)) == 1);
        zz(u,:)=[];
    else
        u=u+1;
    end     
end
clear [centroids_x, centroids_y, lens_x, lens_y, w_x, w_y];
centroids_x=zz(:,1); centroids_y=zz(:,2);
lens_x=zz(:,3); lens_y=zz(:,4); 
w_x =zz(:,5); w_y=zz(:,6);
end