%% integration paths
function [list2] = intpath(z,cota)
%% Notes
%z shuld have the info of the ideal points for the reconsturccion in the
%order of the all points list, cota is the main iformation for the space
%betwen point this min h value
%% General info

zW205c=4.1;
focal=zW205c;%%% distancia focal milimetros
lenspitch=0.150;
psx=0.005; pnx=1440;xss=pnx*psx;    % pixel size x mm pnx= Numero de pixeles en x
psy=0.005; pny=1080;yss=pny*psy;    % pn pixel number  


% plot(z(:,1),z(:,2),'ro')
% 
% sum(z(:,5)+z(:,6))/length(z(:,1));%% cheking rms

%% time to do paths of integration.

%% Distancias
L=length(z(:,1));
for i=1:length(z(:,1))
    for j=1:length(z(:,2))
        d(i,j)=dista(z(i,1),z(i,2),z(j,1),z(j,2));
    end
end
%% Vecinos

for i=1:L
    ll=0;
    for j=1:L
        if(d(i,j) < cota & d(i,j) >0)
            ll=ll+1;
            u(i,ll) = j;
            
        end
    end
end
% this plot its perfect and chec the 100 point neigborns
%  plot(z(nonzeros(u(100,1:5)),3),z(nonzeros(u(100,1:5)),4),'g*')
%% cambiado ceros de puntos adiacentes por puntos lejanos
for i=1:length(u(:,1))
    for j=1:length(u(1,:));
       if u(i,j)==0; 
          u(i,j)=length(u(:,1)+1);%% numero de lista mas lejano del punto inicial
       end
    end
end
%%  Caminos de integracion
%lista(i,j) guarda el camino para llegar al numero de lista i, en englon se
%encuentra la serie de numeros de lista para llegar al punto i
j=0;
jj=0;
for i=1:L
%     if(abs(z(i,2)/z(i,1))>1 & z(i,2)<0)% esto era para seccionar
        dis=10;
        j=1;
       [da6a, ii]=min(z(:,1).^2+z(:,2).^2);   %definiendo punto inicial
     
        jj=jj+1;
        list(jj,j)=ii;
        while(dis>cota)
            j=j+1;
            [dis,ind]=min(d(u(ii,:),i));
            list(jj,j)=u(ii,ind);
            ii=u(ii,ind);
        end
        j=j+1;
        list(jj,j)=i ;  %definiendo punto final
%     end
    
end

%% eliminar repetidos
list1=list;
jjj=1;
for i=1:length(list(:,1))
    T=nonzeros(list(i,:));
    T = transpose(T);
    for j=1:length(list(:,1))
        if(ne(j,i) && length(T)<length(nonzeros(list(j,:))))% si j dif i y tamaño de T menor que el numero de lista dif zero
            if (T == list(j,1:length(T)))
%             if( length(find(list(j,:)==T(length(T)))>0))
                list1(i,:)=list1(i,:)*0;
            end
        end
    end
end
II=1;
for i=1:length(list1(:,1))
    if list1(i,1)==0
    else
        list2(II,:)=list1(i,:);
        II=II+1;
    end
end
%% if the u(i,:) of the row have a 493 elimine that ptah
% j=1;
% for i=1:length(list2(:,1))
%     if length(find(u(nonzeros(list2(j,:)),:)==length(u(:,1))))==0
%         list2(j,:)=[];
%     else
%         j=j+1;
%     end
% end
end
