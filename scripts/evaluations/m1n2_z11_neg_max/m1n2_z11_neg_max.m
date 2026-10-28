%% EVALUACION Z11 negativa maxima, (m,n) = (1,2), epsilon = 5
% Pipeline completo: carga, densificacion, integracion, remocion TTP,
% comparacion con la reconstruccion de ThorLabs y exportacion de figuras.

%% General Data & Settings
close all; clear all; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), "..", "..", "config"));
p = paths_config();
addpath(p.functions);
if ~isfolder(p.output), mkdir(p.output); end

focal = 4.1;          %%% distancia focal milimetros zW205c=4.1;
lenspitch = 0.150;    %%% lens pitch in millimeters
psx = 0.005; pnx = 1440; xss = pnx*psx; % pixel size x mm, pixel number x, sensor size x
psy = 0.005; pny = 1080; yss = pny*psy; % pixel size y mm, pixel number y, sensor size y
sensor_size_x = psx * pnx;
sensor_size_y = psy * pny;

% Direccion de barrido.
m = 1; n = 2;

% Cota de vecindad para la malla densificada.
cota = 1/sqrt(n^2+m^2)*lenspitch*sqrt(2) - 0.0001; % Integration path threshold

radiolens = 11 + 1.5; % Number of lenslets radius + margin
Radio = lenspitch * radiolens + .075; % Physical radius for selection

%% Loading and processing files
% Define base path from the public project configuration.
base_path = string(p.datasets.z11_m1n2) + filesep;

% Desplazamientos experimentales.
d5 = +.1342;
d4 = +0.0671;
d3 = +.0000;
d2 = -.0671;
d1 = -.1342;

% Carga de los cinco archivos de centroides.
disp('Loading data files using get_data_list_from...');
% Assuming get_data_list_from returns data compatible with movmn
z5 = get_data_list_from(base_path + "cent d+2 +1342.csv", sensor_size_x, sensor_size_y);
z4 = get_data_list_from(base_path + "cent d+1 +0671.csv", sensor_size_x, sensor_size_y);
z3 = get_data_list_from(base_path + "cent d+0 +0000.csv", sensor_size_x, sensor_size_y);
z2 = get_data_list_from(base_path + "cent d-1 -0671.csv", sensor_size_x, sensor_size_y);
z1 = get_data_list_from(base_path + "cent d-2 -1342.csv", sensor_size_x, sensor_size_y);
disp('Data loading complete.');

%% Snapshot of d=0 centroids (ThorLabs reference at sigma=0) before movmn
z3_base = z3;

%% Apply shifts to the coordinates (modal displacement)
disp('Applying modal shifts...');
z5 = movmn(z5, d5, m, n);
z4 = movmn(z4, d4, m, n);
z3 = movmn(z3, d3, m, n);
z2 = movmn(z2, d2, m, n);
z1 = movmn(z1, d1, m, n);
disp('Shifts applied.');

%% --- Cap 5, Figura 5.1: base ThorLabs (sigma=0) vs lista densificada por corrimiento ---
fig51 = figure('Name', 'Cap5 Fig5.1 - base ThorLabs vs corridos', 'Position', [100 100 1100 480]);

% Left panel: ThorLabs reference (single shot, sigma = 0)
subplot(1,2,1);
plot(z3_base(:,3), z3_base(:,4), 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k');
title(sprintf('Referencia ThorLabs (\\sigma=0): %d centroides', size(z3_base,1)));
xlabel('X (mm)'); ylabel('Y (mm)'); axis equal; grid on;

% Right panel: 5 shifted centroid sets
subplot(1,2,2);
plot(z1(:,3), z1(:,4), 'r.', 'MarkerSize', 4, 'DisplayName', sprintf('\\sigma=%.4f', d1)), hold on;
plot(z2(:,3), z2(:,4), 'g.', 'MarkerSize', 4, 'DisplayName', sprintf('\\sigma=%.4f', d2));
plot(z3(:,3), z3(:,4), 'b.', 'MarkerSize', 4, 'DisplayName', sprintf('\\sigma=%.4f', d3));
plot(z4(:,3), z4(:,4), 'k.', 'MarkerSize', 4, 'DisplayName', sprintf('\\sigma=%.4f', d4));
plot(z5(:,3), z5(:,4), 'm.', 'MarkerSize', 4, 'DisplayName', sprintf('\\sigma=%.4f', d5));
n_total = size(z1,1)+size(z2,1)+size(z3,1)+size(z4,1)+size(z5,1);
title(sprintf('Lista densificada (\\epsilon=%d, %d centroides)', m^2+n^2, n_total));
xlabel('X (mm)'); ylabel('Y (mm)'); legend('Location','best'); axis equal; grid on;

% Sync axis limits across panels for fair visual comparison
ax_all = findobj(fig51, 'Type', 'axes');
xlims = cell2mat(get(ax_all, 'XLim'));
ylims = cell2mat(get(ax_all, 'YLim'));
xlim_common = [min(xlims(:,1)) max(xlims(:,2))];
ylim_common = [min(ylims(:,1)) max(ylims(:,2))];
set(ax_all, 'XLim', xlim_common, 'YLim', ylim_common);

% Export to thesis assets
fig_dir = fullfile(p.root, 'thesis', 'assets', 'images');
if ~isfolder(fig_dir), mkdir(fig_dir); end
exportgraphics(fig51, fullfile(fig_dir, 'cap5-centroides-corrimiento-vs-base.png'), 'Resolution', 200);
fprintf('Figura 5.1 guardada en: %s\n', fullfile(fig_dir, 'cap5-centroides-corrimiento-vs-base.png'));

%% Combine all data points
% Tag column 7 marks the source set (1..5) so each row keeps memory of which
% sigma_i it came from. This survives selectcirc (row-wise filter) and is
% ignored by movmn/intpath/intpaths (they only read cols 1..6). Used later
% to extract the subset that comes from sigma=0 (set 3), which lies on the
% canonical microlens grid and matches ThorLabs points one-to-one.
disp('Combining data...');
z1 = [z1, 1*ones(size(z1,1),1)];
z2 = [z2, 2*ones(size(z2,1),1)];
z3 = [z3, 3*ones(size(z3,1),1)];   % sigma=0, canonical microlens grid
z4 = [z4, 4*ones(size(z4,1),1)];
z5 = [z5, 5*ones(size(z5,1),1)];
z = vertcat(z1, z2, z3, z4, z5);
% clear z1 z2 z3 z4 z5; % Optional: clear individual datasets

%% --- Cap 5, Figura 5.3: seleccion de la region util ---
n_before = size(z, 1);
fig_sel = figure('Name', 'Cap5 Fig5.3 - seleccion region util', 'Position', [100 100 1100 480]);

% Left: all microlens centers from the densified list + selection circle
subplot(1, 2, 1);
plot(z(:,1), z(:,2), 'b.'); hold on;
theta_circ = linspace(0, 2*pi, 200);
plot(Radio*cos(theta_circ), Radio*sin(theta_circ), 'k-', 'LineWidth', 1.2);
title(sprintf('Centros de microlente (lista densificada, %d filas)', n_before));
xlabel('X (mm)'); ylabel('Y (mm)');
axis equal; grid on;

disp('Selecting circular region...');
z = selectcirc(z, Radio); % Select rows whose centroid falls inside the circle
disp(['Selected ', num2str(size(z, 1)), ' rows within radius ', num2str(Radio), ' mm.']);

% Right: only the selected microlens centers
subplot(1, 2, 2);
plot(z(:,1), z(:,2), 'b.');
title(sprintf('Centros seleccionados (R=%.3f mm, %d filas)', Radio, size(z,1)));
xlabel('X (mm)'); ylabel('Y (mm)');
axis equal; grid on;

% Export to thesis assets
exportgraphics(fig_sel, fullfile(fig_dir, 'cap5-seleccion-region.png'), 'Resolution', 200);
fprintf('Figura 5.3 guardada en: %s\n', fullfile(fig_dir, 'cap5-seleccion-region.png'));

%% Generate integration paths and calculate wavefront
disp('Generating integration paths...');
list2 = intpath([z(:,3), z(:,4)], cota); % Use shifted centroid positions

%% --- Cap 5, Figura 5.4: centros vs centroides | caminos de integracion ---
fig54 = figure('Name', 'Cap5 Fig5.4 - centros vs centroides y caminos de integracion', ...
    'Position', [100 100 1100 480]);

% Left panel: centros de microlente (z(:,3:4)) y centroides (z(:,1:2))
subplot(1,2,1);
plot(z(:,3), z(:,4), 'b.', 'MarkerSize', 4, 'LineWidth', 0.6, ...
    'DisplayName', 'Centros lentes'); hold on;
plot(z(:,1), z(:,2), 'r.', 'MarkerSize', 4, ...
    'DisplayName', 'Centroides');
title('a) Centros vs centroides');
xlabel('X (mm)'); ylabel('Y (mm)');
axis equal; grid on; legend('Location', 'best');

% Right panel: caminos de integracion (depurados) sobre los centros, un color por camino.
% list2 ya es la version depurada (intpath.m elimina caminos prefijo de otros).
% Para no llamar plot 2638 veces, agrupamos los caminos en n_colors grupos ciclicos
% y usamos NaN como separador dentro de cada grupo -> n_colors llamadas a plot.
subplot(1,2,2);
n_paths_total = size(list2, 1);
path_len = size(list2, 2);
path_stride = 3;                             % 1=todos, 2=uno si uno no, 3=uno si dos no
sample_idx = 1:path_stride:n_paths_total;
n_paths = numel(sample_idx);
n_colors = 7;
cmap = lines(n_colors);

hold on;
for c = 1:n_colors
    paths_c = sample_idx(c:n_colors:end);
    xs = nan(numel(paths_c) * (path_len + 1), 1);
    ys = nan(numel(paths_c) * (path_len + 1), 1);
    ptr = 0;
    for kk = paths_c
        idx = nonzeros(list2(kk,:));
        nk = numel(idx);
        xs(ptr+1:ptr+nk) = z(idx, 3);
        ys(ptr+1:ptr+nk) = z(idx, 4);
        ptr = ptr + nk + 1;
    end
    plot(xs, ys, '-', 'Color', cmap(c,:), 'LineWidth', 0.5, 'HandleVisibility', 'off');
end
plot(z(:,3), z(:,4), 'k.', 'MarkerSize', 4, ...
    'DisplayName', 'Centros de microlente');
title('b) Caminos de integracion');
xlabel('X (mm)'); ylabel('Y (mm)');
axis equal; grid on; legend('Location', 'best');

% Sync axis limits across panels
ax_all = findobj(fig54, 'Type', 'axes');
xlims = cell2mat(get(ax_all, 'XLim'));
ylims = cell2mat(get(ax_all, 'YLim'));
xlim_common = [min(xlims(:,1)) max(xlims(:,2))];
ylim_common = [min(ylims(:,1)) max(ylims(:,2))];
set(ax_all, 'XLim', xlim_common, 'YLim', ylim_common);

exportgraphics(fig54, fullfile(fig_dir, 'cap5-centros-centroides-caminos.png'), 'Resolution', 200);
fprintf('Figura 5.4 guardada en: %s\n', fullfile(fig_dir, 'cap5-centros-centroides-caminos.png'));

disp('Integrating wavefront...');
WF = intpaths(list2, z);
disp('Wavefront calculation complete.');

% Calculate initial RMS of the reconstructed wavefront
RMS_raw = sqrt(mean(WF.^2));
fprintf('RMS of raw reconstructed wavefront: %f mm\n', RMS_raw);

%% Plot reconstructed wavefront
figure('Name', 'Raw Reconstructed Wavefront');
plot3(z(:,3), z(:,4), WF, '.r')
title('Raw Reconstructed Wavefront (Before Tilt Removal)');
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Wavefront (mm)');
axis equal; grid on; colorbar; colormap('jet');

%% Guardar el frente reconstruido directo
disp('Saving raw wavefront data...');
Z11neg5S_raw = [z(:,3), z(:,4), WF]; % Create matrix to save
save(fullfile(p.output, 'Z11neg5S_raw.mat'), 'Z11neg5S_raw', '-v7.3', '-nocompression');
disp('Raw wavefront data saved to Z11neg5S_raw.mat');

%% Triangulacion para visualizacion
disp('Creating triangulation...');
try
    DT = delaunay(z(:,3), z(:,4));
    figure('Name', 'Triangulated Raw Wavefront');
    trisurf(DT, z(:,3), z(:,4), WF);
    shading interp; % Smoother shading
    colormap('jet'); colorbar;
    title('Triangulated Raw Wavefront Surface');
    xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Wavefront (mm)');
    axis equal; grid on;
catch ME
    warning('Could not create triangulation. Skipping trisurf plot. Error: %s', ME.message);
end

%% Remocion explicita de tilt y piston
disp('Removing tilt using plane fitting...');
X_coords = z(:,3); % coordenadas x for fitting
Y_coords = z(:,4); % coordenadas y for fitting

A_tilt = [X_coords, Y_coords, ones(size(X_coords))];
coeficientes_tilt = A_tilt \ WF;

a_tilt = coeficientes_tilt(1);
b_tilt = coeficientes_tilt(2);
c_tilt = coeficientes_tilt(3);

fprintf('Fitted Plane (nuestro): Z = (%.6e)*X + (%.6e)*Y + (%.6e) [mm]\n', a_tilt, b_tilt, c_tilt);

fitted_plane = A_tilt * coeficientes_tilt;
WF_sin_tilt = WF - fitted_plane;
disp('Tilt removed.');

RMS_sin_tilt = sqrt(mean(WF_sin_tilt.^2));
fprintf('RMS of wavefront after tilt removal: %f mm\n', RMS_sin_tilt);

figure('Name', 'Tilt-Removed Wavefront');
plot3(X_coords, Y_coords, WF_sin_tilt, '.g')
title('Reconstructed Wavefront (Tilt Removed by Plane Subtraction)');
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Wavefront (mm)');
axis equal; grid on; colorbar; colormap('jet');

% Optional: Plot the fitted plane
% figure('Name', 'Fitted Tilt Plane');
% plot3(X_coords, Y_coords, fitted_plane, 'b.')
% title('Fitted Tilt Plane (ax + by + c)');
% xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Wavefront Component (mm)');
% axis equal; grid on; colorbar; colormap('jet');

disp('Saving tilt-removed wavefront data...');
Z11neg5S_sin_tilt = [X_coords, Y_coords, WF_sin_tilt];
save(fullfile(p.output, 'Z11neg5S_sin_tilt.mat'), 'Z11neg5S_sin_tilt', '-v7.3', '-nocompression');
disp('Tilt-removed wavefront data saved to Z11neg5S_sin_tilt.mat');

%% Zernike Fitting (using the tilt-removed wavefront WF_sin_tilt)
disp('Performing Zernike polynomial fitting on tilt-removed wavefront...');
[theta, rho] = cart2pol(X_coords, Y_coords);
rhon = rho / max(abs(rho));

n_zern = [0, 1,  1, 2,  2, 2, 3,  3, 3,  3, 4,  4, 4,  4, 4];
m_zern = [0, -1, 1, -2, 0, 2, -3, -1, 1, 3, -4, -2, 0, 2, 4];
num_zernike = length(n_zern);

disp('Calculating Zernike polynomials...');
fz = zernfun(n_zern, m_zern, rhon, theta, 'norm'); % Use standard zernfun
disp('Zernike polynomials calculated.');

% --- Plotting Zernike Basis Functions ---
% figure('Name', 'Zernike Basis Functions (Orthonormal)');
% sgtitle('First 15 Orthonormal Zernike Basis Functions (Noll)');
% for k = 1:num_zernike
%     subplot(3, 5, k);
%     plot3(X_coords, Y_coords, fz(:, k), '.'); shading interp;
%     set(gca, 'XTick', [], 'YTick', []);
%     axis equal;
%     title(sprintf('Z_{%d}^{%d}', n_zern(k), m_zern(k)));
% end

disp('Calculating Zernike coefficients...');
Z_coeffs = fz \ WF_sin_tilt; % Fit using backslash operator
% Z_coeffs = fz' * WF_sin_tilt; % Alternative for orthonormal basis
disp('Zernike coefficients calculated.');

figure('Name', 'Zernike Coefficients');
bar(Z_coeffs);
title('Zernike Coefficients (Fit to Tilt-Removed Wavefront)');
xlabel('ANSI Zernike Index (j)');
ylabel('Coefficient Value (mm)');
grid on;
xticks(1:num_zernike);
xticklabels_zern = arrayfun(@(n, m) sprintf('Z_{%d}^{%d}', n, m), n_zern, m_zern, 'UniformOutput', false);
xticklabels(xticklabels_zern);
xtickangle(45);

fprintf('\nZernike Coefficients (mm):\n');
for k = 1:num_zernike
    fprintf('  Z_{%d}^{%d} (j=%d): %f\n', n_zern(k), m_zern(k), k, Z_coeffs(k));
end

disp('Saving Zernike coefficients...');
save(fullfile(p.output, 'Z11neg_ZernikeCoeffs.mat'), 'Z_coeffs', 'n_zern', 'm_zern', '-v7.3', '-nocompression');
disp('Zernike coefficients saved to Z11neg_ZernikeCoeffs.mat');

Fit_WF_Zernike = fz * Z_coeffs;
RMS_error_Zernike = sqrt(mean((WF_sin_tilt - Fit_WF_Zernike).^2));
fprintf('\nRMS error of Zernike fit (to tilt-removed WF): %f mm\n', RMS_error_Zernike);

figure('Name', 'Zernike Fit Comparison');
subplot(1, 2, 1);
plot3(X_coords, Y_coords, Fit_WF_Zernike, '.b');
title('Wavefront Reconstructed from Zernike Fit');
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Wavefront (mm)');
axis equal; grid on; colorbar; colormap('jet');
zlim_val = max(abs(WF_sin_tilt(:))); if zlim_val==0; zlim_val=1; end
zlim([-zlim_val, zlim_val]);

subplot(1, 2, 2);
plot3(X_coords, Y_coords, WF_sin_tilt - Fit_WF_Zernike, '.k');
title('Difference (Data - Zernike Fit)');
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Difference (mm)');
axis equal; grid on; colorbar; colormap('jet');
zlim_val_diff = max(abs(WF_sin_tilt(:) - Fit_WF_Zernike(:)));
if zlim_val_diff == 0; zlim_val_diff = 1e-9; end
zlim([-zlim_val_diff, zlim_val_diff]);

sgtitle(sprintf('Zernike Fit (RMS Error: %.4f mm)', RMS_error_Zernike));

%% --- Comparacion contra ThorLabs (mesh d+0 +0000.csv, misma toma sigma=0) ---
% Misma logica que single_image_baseline.m, ahora sobre la reconstruccion
% densificada de 5 imagenes. Ver scripts/CONVENTIONS.md sobre
% la conversion um -> mm.
disp('Loading ThorLabs reference...');
thorlabs_file = p.datasets.thorlabs_ref_z11_m1n2;
if ~isfile(thorlabs_file)
    error('ThorLabs reference not found: %s', thorlabs_file);
end
[Xtl, Ytl, Ztl] = recuperarFrenteDeOndaTL(thorlabs_file);

% Conversion de unidades: el archivo entrega en um (validado empiricamente
% en single_image_baseline.m, 2026-05-03). Ver scripts/CONVENTIONS.md.
Ztl = Ztl / 1000;
fprintf('ThorLabs loaded: %d points, max |Z| = %.4f mm.\n', numel(Ztl), max(abs(Ztl)));

% Quitar tilt al ThorLabs (mismo procedimiento que para WF)
disp('Removing tilt from ThorLabs data...');
X_tl_col = Xtl(:);
Y_tl_col = Ytl(:);
Z_tl_col = Ztl(:);

A_tl     = [X_tl_col, Y_tl_col, ones(size(X_tl_col))];
coef_tl  = A_tl \ Z_tl_col;
a_tl = coef_tl(1); b_tl = coef_tl(2); c_tl = coef_tl(3);
fprintf('Fitted Plane (TL): Z = (%.6e)*X + (%.6e)*Y + (%.6e) [mm]\n', a_tl, b_tl, c_tl);
plano_tl = A_tl * coef_tl;
Ztl_sin_tilt = Z_tl_col - plano_tl;
RMS_tl_sin_tilt = sqrt(mean(Ztl_sin_tilt.^2));
fprintf('RMS_sin_tilt (ThorLabs): %f mm\n', RMS_tl_sin_tilt);

% Emparejar cada punto de ThorLabs con el mas cercano de nuestra reconstruccion
disp('Finding corresponding points using knnsearch...');
puntos_buscar_tl    = [X_tl_col, Y_tl_col];
puntos_totales_mine = [X_coords, Y_coords];
indices_encontrados_tl = knnsearch(puntos_totales_mine, puntos_buscar_tl);

% Diferencia ANTES de quitar tilt (raw vs raw). Justifica visualmente por
% que se necesita remover TTP antes de comparar: ambas reconstrucciones
% tienen tilt residual del montaje y la diferencia raw incluye ese sesgo.
WF_correspondiente_raw = WF(indices_encontrados_tl);
diferencias_raw_vs_tl  = WF_correspondiente_raw - Z_tl_col;
rms_diferencia_raw_vs_tl = sqrt(mean(diferencias_raw_vs_tl.^2));
fprintf('RMS difference (5 imagenes vs ThorLabs, RAW antes de TTP): %f mm\n', rms_diferencia_raw_vs_tl);

WF_correspondiente_sin_tilt = WF_sin_tilt(indices_encontrados_tl);
diferencias_vs_tl_sin_tilt  = WF_correspondiente_sin_tilt - Ztl_sin_tilt;
rms_diferencia_vs_tl_sin_tilt = sqrt(mean(diferencias_vs_tl_sin_tilt.^2));
fprintf('RMS difference (5 imagenes vs ThorLabs, sin tilt): %f mm\n', rms_diferencia_vs_tl_sin_tilt);

%% Diferencias en cuatro etapas: directa, post-TTP, segundo tratamiento, via alternativa
% Replicado de eval 2/3 para verificar si en eval 1 (Z11) la metrica tambien
% mejora al aplicar el segundo tratamiento o la via alternativa.
% Convencion de variables homologa a eval 2/3:
%   dif_raw  <-> diferencias_raw_vs_tl
%   dif_sttp <-> diferencias_vs_tl_sin_tilt
dif_raw  = diferencias_raw_vs_tl;
dif_sttp = diferencias_vs_tl_sin_tilt;

% Segundo tratamiento: plano ajustado a la diferencia POST-TTP
A_dif    = [X_tl_col, Y_tl_col, ones(size(X_tl_col))];
coef_dif = A_dif \ dif_sttp;
a_dif = coef_dif(1); b_dif = coef_dif(2); c_dif = coef_dif(3);
plano_dif = A_dif * coef_dif;
dif_residual = dif_sttp - plano_dif;
rms_dif_residual = sqrt(mean(dif_residual.^2));

% Via alternativa: plano ajustado DIRECTAMENTE a la diferencia raw
A_dif_dir    = [X_tl_col, Y_tl_col, ones(size(X_tl_col))];
coef_dif_dir = A_dif_dir \ dif_raw;
a_dif_dir = coef_dif_dir(1); b_dif_dir = coef_dif_dir(2); c_dif_dir = coef_dif_dir(3);
plano_dif_dir = A_dif_dir * coef_dif_dir;
dif_residual_dir = dif_raw - plano_dif_dir;
rms_dif_residual_dir = sqrt(mean(dif_residual_dir.^2));

dif_raw_um           = dif_raw          * 1000;
dif_sttp_um          = dif_sttp         * 1000;
dif_residual_um      = dif_residual     * 1000;
dif_residual_dir_um  = dif_residual_dir * 1000;

% Path de salida (fig_dir esta definido mas arriba en este script)
fig_dif_map = figure('Name', 'Cap5 Eval1 - diferencias: directa, post-TTP, post-segundo, via alternativa', ...
    'Position', [50 100 2000 500]);

ax_d_a = subplot(1,4,1);
scatter3(X_tl_col, Y_tl_col, dif_raw_um, 30, dif_raw_um, 'filled');
title(sprintf('a) Directa (RMS = %.4f \\mum)', rms_diferencia_raw_vs_tl*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_a = max(abs(dif_raw_um)); caxis([-clim_a, clim_a]);
colormap(ax_d_a, 'jet'); cb_a = colorbar; ylabel(cb_a, '\Delta (\mum)');

ax_d_b = subplot(1,4,2);
scatter3(X_tl_col, Y_tl_col, dif_sttp_um, 30, dif_sttp_um, 'filled');
title(sprintf('b) Tras TTP indep. (RMS = %.4f \\mum)', rms_diferencia_vs_tl_sin_tilt*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_b = max(abs(dif_sttp_um)); caxis([-clim_b, clim_b]);
colormap(ax_d_b, 'jet'); cb_b = colorbar; ylabel(cb_b, '\Delta (\mum)');

ax_d_c = subplot(1,4,3);
scatter3(X_tl_col, Y_tl_col, dif_residual_um, 30, dif_residual_um, 'filled');
title(sprintf('c) Tras segundo tratam. (RMS = %.4f \\mum)', rms_dif_residual*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_c = max(abs(dif_residual_um)); caxis([-clim_c, clim_c]);
colormap(ax_d_c, 'jet'); cb_c = colorbar; ylabel(cb_c, '\Delta (\mum)');

ax_d_d = subplot(1,4,4);
scatter3(X_tl_col, Y_tl_col, dif_residual_dir_um, 30, dif_residual_dir_um, 'filled');
title(sprintf('d) Plano sobre Delta directa (RMS = %.4f \\mum)', rms_dif_residual_dir*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_d = max(abs(dif_residual_dir_um)); caxis([-clim_d, clim_d]);
colormap(ax_d_d, 'jet'); cb_d = colorbar; ylabel(cb_d, '\Delta (\mum)');

fprintf('\n=== Analisis de diferencias en cuatro etapas (eval 1) ===\n');
fprintf('  Plano de Delta (post-TTP): a=%+.4e mm/mm, b=%+.4e mm/mm, c=%+.4e mm\n', a_dif, b_dif, c_dif);
fprintf('  Plano de Delta (directo):  a=%+.4e mm/mm, b=%+.4e mm/mm, c=%+.4e mm\n', a_dif_dir, b_dif_dir, c_dif_dir);
fprintf('  RMS dif. directa:           %.6f mm  (%.4f um)\n', rms_diferencia_raw_vs_tl,        rms_diferencia_raw_vs_tl*1000);
fprintf('  RMS dif. post-TTP:          %.6f mm  (%.4f um)\n', rms_diferencia_vs_tl_sin_tilt,   rms_diferencia_vs_tl_sin_tilt*1000);
fprintf('  RMS dif. segundo tratam:    %.6f mm  (%.4f um)\n', rms_dif_residual,                rms_dif_residual*1000);
fprintf('  RMS dif. via alternativa:   %.6f mm  (%.4f um)\n', rms_dif_residual_dir,            rms_dif_residual_dir*1000);
fprintf('===============================================\n\n');

exportgraphics(fig_dif_map, fullfile(fig_dir, 'cap5-eval1-diferencias-cuatro-etapas.png'), ...
    'Resolution', 200);
fprintf('Figura diferencias en cuatro etapas guardada en: %s\n', ...
    fullfile(fig_dir, 'cap5-eval1-diferencias-cuatro-etapas.png'));

%% --- Diferencia directa: subset sigma=0 (malla canonica) vs ThorLabs ---
% Extraemos los puntos que provienen de la toma central (tag=3): estos
% ocupan la malla canonica de microlentes y son los analogos uno-a-uno de
% los puntos que entrega ThorLabs. La diferencia aqui se calcula sobre los
% MISMOS puntos fisicos (no sobre vecinos cercanos), por lo que es la
% comparacion manzana-con-manzana contra el baseline de 1 imagen.
disp('Diferencia directa sobre subset sigma=0...');
mask_z3   = (z(:,7) == 3);
X_z3      = X_coords(mask_z3);
Y_z3      = Y_coords(mask_z3);
WF_z3_sin_tilt = WF_sin_tilt(mask_z3);
fprintf('Subset sigma=0 dentro de la lista densificada: %d puntos.\n', numel(WF_z3_sin_tilt));

% Para cada punto de ThorLabs, su mas cercano dentro del subset z3.
% Si todo esta bien, las distancias deben ser ~0 (malla canonica compartida).
[idx_z3, dist_match] = knnsearch([X_z3, Y_z3], [X_tl_col, Y_tl_col]);
fprintf('Distancia media de emparejamiento (TL -> subset z3): %.6f mm (max %.6f mm)\n', ...
    mean(dist_match), max(dist_match));

WF_z3_correspondiente = WF_z3_sin_tilt(idx_z3);
diferencias_directas_z3 = WF_z3_correspondiente - Ztl_sin_tilt;
rms_diferencia_directa_z3 = sqrt(mean(diferencias_directas_z3.^2));
fprintf('RMS_diferencia DIRECTA (5 img, subset sigma=0 vs TL): %f mm\n', ...
    rms_diferencia_directa_z3);

% Comparacion visual (dos nubes 3D, sin trisurf por ahora)
figure('Name', 'Comparison with ThorLabs (Tilt Removed)');
plot3(X_coords, Y_coords, WF_sin_tilt, '.g', 'DisplayName', 'WF nuestro (sin tilt)');
hold on;
plot3(X_tl_col, Y_tl_col, Ztl_sin_tilt, '.m', 'DisplayName', 'WF ThorLabs (sin tilt)');
title(sprintf('Wavefront Comparison (RMS Diff: %.4f mm)', rms_diferencia_vs_tl_sin_tilt));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Wavefront (mm)');
axis equal; grid on; colorbar; colormap('jet'); legend show;

%% --- Cap 5, Figura 5.5: reconstruccion inicial (nubes 3D, antes de quitar tilt) ---
% Comparacion lado a lado de las dos reconstrucciones tal como las entrega
% cada metodo: ThorLabs (Ztl, raw) y la nuestra (WF, raw). Ambas ANTES del
% ajuste de plano, en um para mejor lectura de magnitudes pequenas.
fig55 = figure('Name', 'Cap5 Fig5.5 - reconstruccion inicial (nubes 3D)', ...
    'Position', [100 100 1200 500]);

WF_um  = WF  * 1000;          % mm -> um para el plot
Ztl_um = Ztl * 1000;

% Panel a) ThorLabs raw
ax1 = subplot(1,2,1);
scatter3(X_tl_col, Y_tl_col, Ztl_um, 12, Ztl_um, 'filled');
title(sprintf('a) Reconstruccion ThorLabs (%d puntos, raw)', numel(Ztl_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; colormap(ax1, 'jet'); colorbar;
view(35, 25);

% Panel b) Nuestra reconstruccion raw
ax2 = subplot(1,2,2);
scatter3(X_coords, Y_coords, WF_um, 12, WF_um, 'filled');
title(sprintf('b) Reconstruccion corrimiento de puntos (%d puntos, raw)', numel(WF_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; colormap(ax2, 'jet'); colorbar;
view(35, 25);

% Sincronizar zlim para comparacion justa
zlim_common = [min(min(Ztl_um), min(WF_um)), max(max(Ztl_um), max(WF_um))];
set([ax1 ax2], 'ZLim', zlim_common);
% Sincronizar limites X, Y
xlim_common = [min(min(X_tl_col), min(X_coords)), max(max(X_tl_col), max(X_coords))];
ylim_common = [min(min(Y_tl_col), min(Y_coords)), max(max(Y_tl_col), max(Y_coords))];
set([ax1 ax2], 'XLim', xlim_common, 'YLim', ylim_common);

exportgraphics(fig55, fullfile(fig_dir, 'cap5-reconstruccion-inicial-nubes.png'), 'Resolution', 200);
fprintf('Figura 5.5 guardada en: %s\n', fullfile(fig_dir, 'cap5-reconstruccion-inicial-nubes.png'));

%% --- Cap 5, Figura 5.6: reconstruccion despues de remover TTP (nubes 3D) ---
% Misma comparacion que la figura previa, pero con tip, tilt y piston
% removidos en ambas reconstrucciones (ajuste de plano por minimos cuadrados
% aplicado a cada frente independientemente, ver Seccion sec:tip-tilt).
fig56 = figure('Name', 'Cap5 Fig5.6 - reconstruccion sin TTP (nubes 3D)', ...
    'Position', [100 100 1200 500]);

WF_sin_tilt_um  = WF_sin_tilt  * 1000;          % mm -> um
Ztl_sin_tilt_um = Ztl_sin_tilt * 1000;

% Panel a) ThorLabs sin TTP
ax1b = subplot(1,2,1);
scatter3(X_tl_col, Y_tl_col, Ztl_sin_tilt_um, 12, Ztl_sin_tilt_um, 'filled');
title(sprintf('a) Reconstruccion ThorLabs (%d puntos, sin TTP)', numel(Ztl_sin_tilt_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; colormap(ax1b, 'jet'); colorbar;
view(35, 25);

% Panel b) Nuestra reconstruccion sin TTP
ax2b = subplot(1,2,2);
scatter3(X_coords, Y_coords, WF_sin_tilt_um, 12, WF_sin_tilt_um, 'filled');
title(sprintf('b) Reconstruccion corrimiento de puntos (%d puntos, sin TTP)', numel(WF_sin_tilt_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; colormap(ax2b, 'jet'); colorbar;
view(35, 25);

% Sincronizar zlim, xlim, ylim para comparacion justa
zlim_common_b = [min(min(Ztl_sin_tilt_um), min(WF_sin_tilt_um)), ...
                 max(max(Ztl_sin_tilt_um), max(WF_sin_tilt_um))];
set([ax1b ax2b], 'ZLim', zlim_common_b);
xlim_common_b = [min(min(X_tl_col), min(X_coords)), max(max(X_tl_col), max(X_coords))];
ylim_common_b = [min(min(Y_tl_col), min(Y_coords)), max(max(Y_tl_col), max(Y_coords))];
set([ax1b ax2b], 'XLim', xlim_common_b, 'YLim', ylim_common_b);

exportgraphics(fig56, fullfile(fig_dir, 'cap5-reconstruccion-sin-ttp-nubes.png'), 'Resolution', 200);
fprintf('Figura 5.6 guardada en: %s\n', fullfile(fig_dir, 'cap5-reconstruccion-sin-ttp-nubes.png'));

%% --- Cap 5, Figura 5.7: trisurf sin TTP (superficies, sin mapa de profundidad) ---
% Misma comparacion 3D pero ahora como superficie triangulada (mallado por
% triangulacion de Delaunay) en lugar de nubes de puntos. Color SOLIDO,
% sin colormap por altura — la idea es ver la forma del frente como
% superficie continua, no la magnitud.
fig57 = figure('Name', 'Cap5 Fig5.7 - trisurf sin TTP', 'Position', [100 100 1200 500]);

DT_tl   = delaunay(X_tl_col, Y_tl_col);
DT_mine = delaunay(X_coords, Y_coords);

color_tl   = [0.45 0.65 0.85];   % azul claro
color_mine = [0.85 0.55 0.45];   % naranja claro

% Panel a) ThorLabs sin TTP, trisurf
ax1c = subplot(1,2,1);
trisurf(DT_tl, X_tl_col, Y_tl_col, Ztl_sin_tilt_um, ...
    'FaceColor', color_tl, 'EdgeColor', 'none', 'FaceAlpha', 1);
shading interp;
camlight('headlight'); lighting gouraud; material dull;
title(sprintf('a) ThorLabs (sin TTP), %d puntos', numel(Ztl_sin_tilt_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; view(35, 25);

% Panel b) Nuestra sin TTP, trisurf
ax2c = subplot(1,2,2);
trisurf(DT_mine, X_coords, Y_coords, WF_sin_tilt_um, ...
    'FaceColor', color_mine, 'EdgeColor', 'none', 'FaceAlpha', 1);
shading interp;
camlight('headlight'); lighting gouraud; material dull;
title(sprintf('b) Corrimiento de puntos (sin TTP), %d puntos', numel(WF_sin_tilt_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; view(35, 25);

% Sincronizar limites
zlim_common_c = [min(min(Ztl_sin_tilt_um), min(WF_sin_tilt_um)), ...
                 max(max(Ztl_sin_tilt_um), max(WF_sin_tilt_um))];
set([ax1c ax2c], 'ZLim', zlim_common_c);
set([ax1c ax2c], 'XLim', xlim_common_b, 'YLim', ylim_common_b);

exportgraphics(fig57, fullfile(fig_dir, 'cap5-reconstruccion-sin-ttp-trisurf.png'), 'Resolution', 200);
fprintf('Figura 5.7 guardada en: %s\n', fullfile(fig_dir, 'cap5-reconstruccion-sin-ttp-trisurf.png'));

%% --- Cap 5, Figura 5.8: mapa de la diferencia punto a punto, antes y despues de TTP ---
% Visualiza COMO se distribuye espacialmente el error (no su magnitud sola).
% Las diferencias se calculan sobre los puntos de ThorLabs (501) tras el
% knnsearch. La escala de color de cada panel es simetrica alrededor de 0
% para que se distingan signo y magnitud del residuo.
fig58 = figure('Name', 'Cap5 Fig5.8 - diferencias antes/despues TTP', ...
    'Position', [100 100 1200 500]);

dif_raw_um  = diferencias_raw_vs_tl       * 1000;   % mm -> um
dif_sttp_um = diferencias_vs_tl_sin_tilt  * 1000;

% Panel a) Diferencia ANTES de quitar TTP
ax1d = subplot(1,2,1);
scatter(X_tl_col, Y_tl_col, 30, dif_raw_um, 'filled');
title(sprintf('a) WF - Z_{TL} con tilt (RMS = %.4f \\mum)', rms_diferencia_raw_vs_tl*1000));
xlabel('X (mm)'); ylabel('Y (mm)');
axis equal tight; grid on; colormap(ax1d, 'jet'); cb1 = colorbar; ylabel(cb1, '\Delta (\mum)');
clim_a = max(abs(dif_raw_um));
caxis([-clim_a, clim_a]);

% Panel b) Diferencia DESPUES de quitar TTP
ax2d = subplot(1,2,2);
scatter(X_tl_col, Y_tl_col, 30, dif_sttp_um, 'filled');
title(sprintf('b) WF - Z_{TL} sin TTP (RMS = %.4f \\mum)', rms_diferencia_vs_tl_sin_tilt*1000));
xlabel('X (mm)'); ylabel('Y (mm)');
axis equal tight; grid on; colormap(ax2d, 'jet'); cb2 = colorbar; ylabel(cb2, '\Delta (\mum)');
clim_b = max(abs(dif_sttp_um));
caxis([-clim_b, clim_b]);

exportgraphics(fig58, fullfile(fig_dir, 'cap5-diferencias-antes-despues-ttp.png'), 'Resolution', 200);
fprintf('Figura 5.8 guardada en: %s\n', fullfile(fig_dir, 'cap5-diferencias-antes-despues-ttp.png'));

%% Resumen final
fprintf('\n=== RESUMEN: 5 IMAGENES (m1n2_z11_neg_max) ===\n');
fprintf('  Puntos reconstruidos:               %d\n',     numel(WF));
fprintf('  Caminos depurados:                  %d\n',     size(list2,1));
fprintf('  Cota de vecindad:                   %.6f mm\n', cota);
fprintf('  Radio de seleccion:                 %.4f mm\n', Radio);
fprintf('  Plano quitado (nuestro):  a=%.4e mm/mm, b=%.4e mm/mm, c=%.4e mm\n', a_tilt, b_tilt, c_tilt);
fprintf('  Plano quitado (ThorLabs): a=%.4e mm/mm, b=%.4e mm/mm, c=%.4e mm\n', a_tl, b_tl, c_tl);
fprintf('  RMS diferencia (con tilt):  %.6f mm   (WF - Ztl, ambos antes de TTP)\n', rms_diferencia_raw_vs_tl);
fprintf('  RMS diferencia (sin tilt):  %.6f mm   (WF_sin_tilt - Ztl_sin_tilt)\n', rms_diferencia_vs_tl_sin_tilt);
fprintf('================================================\n');

disp('Processing complete.');
