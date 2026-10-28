function [] = plotpath(z,list)
% figure
list2=list;
plot(z(:,1),z(:,2),'ro'),hold on
for i=1:length(list2(:,1))
    plot(z(nonzeros(list2(i,:)),1),z(nonzeros(list2(i,:)),2)),hold on
    pause(.02)
end
end

