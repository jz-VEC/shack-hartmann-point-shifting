%% Main Fuction to recover points from SH details
% it does include to recenter and realign to de closest lens center
function step_data = get_data_list_from(path, sensor_size_x_mm, sensor_size_y_mm)
[c_x, c_y, l_x, l_y, w_x, w_y] = get_all_data_listed_from(path);
[centroids_x, centroids_y, lens_x, lens_y, w_x, w_y] = clean_nan_elements(c_x, c_y, l_x, l_y, w_x, w_y);
clear [c_x, c_y, l_x, l_y, w_x, w_y]
%[centroids_x, centroids_y, lens_x, lens_y] = recenter(centroids_x, centroids_y, lens_x, lens_y, sensor_size_x_mm, sensor_size_y_mm);
step_data = [centroids_x, centroids_y, lens_x, lens_y, w_x, w_y];
end
