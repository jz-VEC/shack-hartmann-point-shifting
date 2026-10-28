function [centroids_x, centroids_y, lens_x, lens_y] = recenter(centroids_x, centroids_y, lens_x, lens_y, sensor_size_x_mm, sensor_size_y_mm)
%% withdraw half size of the sensor size
centroids_x = centroids_x - sensor_size_x_mm / 2;
centroids_y = centroids_y - sensor_size_y_mm / 2;
lens_x = lens_x - sensor_size_x_mm / 2;
lens_y = lens_y - sensor_size_y_mm / 2;
%% center to the closeest point in the center.
% a is the min number and b is the index
[a,b]=min(sqrt(lens_x.^2 + lens_y.^2));
centroids_x = centroids_x - lens_x(b);
centroids_y = centroids_y - lens_y(b);
lens_x = lens_x - lens_x(b);
lens_y = lens_y - lens_y(b);
end