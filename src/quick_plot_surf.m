function quick_plot_surf(faces,coords,weights,cmap)

% figure
% colormap(annotTable.table(:,1:3) ./ 255)

views = [ 90 -90 ] ;

for idx=1:2

    subplot(1,2,idx) 
    tmp = trisurf(faces,...
        coords(:,1),...
        coords(:,2),...
        coords(:,3),...
        weights);
    set(tmp,'EdgeColor','none');
    axis equal; axis off
    view(views(idx),0)
    camlight headlight; material dull; lighting none
    tmp.CDataMapping = 'direct' ;
    colormap(cmap)
end


