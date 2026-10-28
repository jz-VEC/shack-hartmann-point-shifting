function [centroids_matrix_x,centroids_matrix_y] = get_centroids_matrixes_from_table(cetroids_data_table, pixel_size_x, pixel_size_y)
%% this function will include moving this data to mm magnitude
combined_xy_colums_from_csv = cetroids_data_table;
matrix_x = combined_xy_colums_from_csv(:,1:2:94) ; 
matrix_y = combined_xy_colums_from_csv(:,2:2:94) ;
centroids_matrix_x = table2array(matrix_x) * pixel_size_x;
centroids_matrix_y = table2array(matrix_y) * pixel_size_y;
end