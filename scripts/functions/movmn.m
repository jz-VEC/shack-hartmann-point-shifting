function [z] = movmn(z,dist,m,n)

%% donde m y n es son los numeros enteros de la rotacion
%   Detailed explanation goes here m=0,n=1; dist=0.5
th=atan(m/n);
angulo=th*180/pi
z(:,3)=z(:,3)+cos(th)*dist;
z(:,4)=z(:,4)+sin(th)*dist;
z(:,1)=z(:,1)+cos(th)*dist;
z(:,2)=z(:,2)+sin(th)*dist;

end


