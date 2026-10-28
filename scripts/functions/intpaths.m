function [WF] = intpaths(list2,z)
%For the moment the program function whit z value that we been taking form
%the begining but we can remplecethem whit te wx,wy and lx,ly only.
%   Detailed explanation goes here
for j=1:length(list2(:,1))
f=4.1;
integral=0;
for i=1:length(nonzeros(list2(j,:)))-1
    wxi=z(list2(j,i),5);   wyi=z(list2(j,i),6);
    wxi2=z(list2(j,i+1),5);wyi2=z(list2(j,i+1),6);
    hx=z(list2(j,i+1),3)-z(list2(j,i),3);
    hy=z(list2(j,i+1),4)-z(list2(j,i),4);
    fxy=(wxi+wxi2)*hx+(wyi+wyi2)*hy;
    integral=fxy/2/f+integral;
    WF(list2(j,i+1),1)=integral;
end
end
end

