
function [puntos] =tabto2dcord(T)
% in te 

%% this program is use to pass of a table of data to a array of nx2 % n rows and 2 columns
size(T,1)
clear U
% U(size(T,1),size(T,2))=1
% U(1:size(T,1),:)=T(1:size(T,1),:)
U=table2array(T);

%% Once you have in hte variable U your set of point you have to pasit tho a listr of 2 x n weher you will be able to plot the point y ordenar.
% enlistar(U)
for l=1:size(T,2)/2
for k=1:size(T,1)
    puntos((l-1)*size(T,1)+k,:)=[U(k,2*l-1),U(k,2*l)]; % puntos es la varible lista de los puntos
end
end
end