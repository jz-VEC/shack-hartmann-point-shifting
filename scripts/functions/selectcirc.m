function [Z] = selectcirc(infoT,Radio)

%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Radio=.15*12+.075;
z = infoT;


Ecirc=((z(:,3).^2+z(:,4).^2)<=Radio^2);
for i=1:length(Ecirc)
    u=length(Ecirc)-i+1;
    if Ecirc(u)==0
        
        z(u,:)=[];
    else
    end     
end
Z=z;
end 