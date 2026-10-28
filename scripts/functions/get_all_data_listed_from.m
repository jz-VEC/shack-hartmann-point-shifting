% Actuall runing program This data is getting back already in mm
% trasnversal aberration w 
function [centroids_x, centroids_y, lens_x,lens_y, w_x, w_y] = get_all_data_listed_from(path)
%% General specifications 
lens_pitch_x = 0.150; lens_pitch_y = 0.150;
pixel_size_x =0.005; pixel_size_y = 0.005; 
%% adjust
adj_x = -0.02; adj_y = -0.01

combined_xy_colums_from_csv = csv_data_extraction(path);
[centroids_m_x_mm, centroids_m_y_mm] = get_centroids_matrixes_from_table(combined_xy_colums_from_csv, pixel_size_x, pixel_size_y);
[lens_m_x, lens_m_y] = get_lens_centers_mm(lens_pitch_x, lens_pitch_y, adj_x, adj_y);
% get transversal aberration w

trasversal_aberration_x = lens_m_x - centroids_m_x_mm;
trasversal_aberration_y = lens_m_y - centroids_m_y_mm;
% making nan in lenses the same as the ones in centroids.

% Get the position of the central lens center (18,24)
central_y = 18; central_x = 24;
central_lens_x = lens_m_x(central_y, central_x);
central_lens_y = lens_m_y(central_y, central_x);

% Centrar matrices de lentes y centroides
lens_m_x = lens_m_x - central_lens_x;
lens_m_y = lens_m_y - central_lens_y;
centroids_m_x_mm = centroids_m_x_mm - central_lens_x;
centroids_m_y_mm = centroids_m_y_mm - central_lens_y;


lens_m_x = lens_m_x + trasversal_aberration_x * 0;
lens_m_y = lens_m_y + trasversal_aberration_y * 0;
% convertion from matrix to lists 
w_x = array2list(trasversal_aberration_x); 
w_y = array2list(trasversal_aberration_y);
lens_x = array2list(lens_m_x);
lens_y = array2list(lens_m_y);
centroids_x = array2list(centroids_m_x_mm);
centroids_y = array2list(centroids_m_y_mm);
end