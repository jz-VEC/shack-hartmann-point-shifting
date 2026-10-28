function [lens_m_x, lens_m_y] = get_lens_centers_mm(lens_pitch_x, lens_pitch_y, adj_x, adj_y)
%% Generating Lens point lx,ly
% To help generatin the microlens position array we used the plane mirrior
% to get the best adjustmen of the microlenses to the matematical
% generation givin as a resulta de position of the center of the matrix in
% the pixel space

x=1:47;
[X,Y] = meshgrid(x,x);
lens_m_x = X(1:35,:) * lens_pitch_x + adj_x; %% helper matix Cuts the patrix to be the right size started been 47 by 47 the goes into 35 by 47
lens_m_y = Y(1:35,:) * lens_pitch_y + adj_y; %% helper matix Cuts the patrix to be the right size started been 47 by 47 the goes into 35 by 47
end