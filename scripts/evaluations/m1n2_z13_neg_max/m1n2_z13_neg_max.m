%% EVALUACION 2: (m,n) = (1,2), aberracion Z13 negativa maxima
% Version condensada: solo las figuras y metricas que iran a la tesis.
% Plantilla derivada de m1n2_z11_neg_max.m, simplificada.
%
% Figuras que genera el script:
%   Fig.2: seleccion de puntos (izq) + reconstruccion con tilt cenital (der)
%   Fig.3: scatter3 sin TTP (TL vs nuestro) - de aqui Carlos saca vistas
%   Fig.4: trisurf sin TTP (TL vs nuestro) - superficies trianguladas
%
% Figura 1 (setup ThorLabs en vivo) NO se genera aqui; se copia manualmente
% desde data/m1n2_z13_neg_max/inicio setup 0.png a thesis/assets/images/.
%
% Datos reportados en RESUMEN:
%   - Radio del area seleccionada
%   - Coeficientes de los planos quitados (nuestro y TL)
%   - RMS diferencia con tilt
%   - RMS diferencia sin tilt

%% General data & settings
close all; clear all; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), "..", "..", "config"));
p = paths_config();
addpath(p.functions);
if ~isfolder(p.output), mkdir(p.output); end

focal       = 4.1;          % mm (zW205c)
lenspitch   = 0.150;        % mm
psx = 0.005; pnx = 1440; sensor_size_x = psx * pnx;
psy = 0.005; pny = 1080; sensor_size_y = psy * pny;

% Direccion de barrido (m,n) y parametros derivados (mismos que eval 1)
m = 1; n = 2;
cota = 1/sqrt(n^2+m^2)*lenspitch*sqrt(2) - 0.0001;

radiolens = 12 + 1.5;
Radio     = lenspitch * radiolens + .075;

%% Loading and processing files
% Naming en este dataset: 'cent d+N XXXX.csv' (sin '+' antes del numero).
base_path = string(p.datasets.z13_m1n2_neg) + filesep;

d5 = +.1342;
d4 = +0.0671;
d3 = +.0000;
d2 = -.0671;
d1 = -.1342;

disp('Loading data files using get_data_list_from...');
z5 = get_data_list_from(base_path + "cent d+2 1342.csv",  sensor_size_x, sensor_size_y);
z4 = get_data_list_from(base_path + "cent d+1 0671.csv",  sensor_size_x, sensor_size_y);
z3 = get_data_list_from(base_path + "cent d+0 0.00.csv",  sensor_size_x, sensor_size_y);
z2 = get_data_list_from(base_path + "cent d-1 -0671.csv", sensor_size_x, sensor_size_y);
z1 = get_data_list_from(base_path + "cent d-2 -1342.csv", sensor_size_x, sensor_size_y);
disp('Data loading complete.');

%% Apply modal shifts
disp('Applying modal shifts...');
z5 = movmn(z5, d5, m, n);
z4 = movmn(z4, d4, m, n);
z3 = movmn(z3, d3, m, n);
z2 = movmn(z2, d2, m, n);
z1 = movmn(z1, d1, m, n);

%% Tag column + vertcat
% Col 7: source set (1..5). Permite extraer el subset sigma=0 si hace falta
% un analisis manzana-con-manzana mas adelante. movmn / selectcirc / intpath
% no leen col >= 7, por lo que viaja intacta.
z1 = [z1, 1*ones(size(z1,1),1)];
z2 = [z2, 2*ones(size(z2,1),1)];
z3 = [z3, 3*ones(size(z3,1),1)];   % sigma=0
z4 = [z4, 4*ones(size(z4,1),1)];
z5 = [z5, 5*ones(size(z5,1),1)];
z = vertcat(z1, z2, z3, z4, z5);

%% Selectcirc + integration
% Snapshot pre-selectcirc para poder mostrar la lista densificada COMPLETA
% en la figura 2 (panel izq), antes de recortar al area circular.
z_pre_sel = z;
disp('Selecting circular region...');
n_before = size(z,1);
z = selectcirc(z, Radio);
fprintf('Selected %d / %d rows within radius %.3f mm.\n', size(z,1), n_before, Radio);

disp('Generating integration paths...');
list2 = intpath([z(:,3), z(:,4)], cota);
disp('Integrating wavefront...');
WF = intpaths(list2, z);

%% Tilt removal (nuestro)
X_coords = z(:,3); Y_coords = z(:,4);
A_tilt    = [X_coords, Y_coords, ones(size(X_coords))];
coef_tilt = A_tilt \ WF;
a_tilt = coef_tilt(1); b_tilt = coef_tilt(2); c_tilt = coef_tilt(3);
fprintf('Fitted Plane (nuestro): Z = (%.6e)*X + (%.6e)*Y + (%.6e) [mm]\n', a_tilt, b_tilt, c_tilt);
WF_sin_tilt = WF - A_tilt * coef_tilt;

%% ThorLabs reference + tilt removal
disp('Loading ThorLabs reference...');
thorlabs_file = p.datasets.thorlabs_ref_z13_m1n2;
if ~isfile(thorlabs_file)
    error('ThorLabs reference not found: %s', thorlabs_file);
end
[Xtl, Ytl, Ztl] = recuperarFrenteDeOndaTL(thorlabs_file);
Ztl = Ztl / 1000;   % um -> mm (ver scripts/CONVENTIONS.md)
fprintf('ThorLabs loaded: %d points, max |Z| = %.4f mm.\n', numel(Ztl), max(abs(Ztl)));

X_tl_col = Xtl(:); Y_tl_col = Ytl(:); Z_tl_col = Ztl(:);

% Path de salida para imagenes (usado por las figuras que siguen)
fig_dir = fullfile(p.root, 'thesis', 'assets', 'images');
if ~isfolder(fig_dir), mkdir(fig_dir); end

%% [DIAG] Puntos TL crudos + circulo R superpuesto (solo inspeccion, no exporta)
fig_tl = figure('Name', '[DIAG] Puntos TL crudos vs circulo R');
plot(X_tl_col, Y_tl_col, 'b.', 'MarkerSize', 6); hold on;
theta_circ = linspace(0, 2*pi, 200);
plot(Radio*cos(theta_circ), Radio*sin(theta_circ), 'r-', 'LineWidth', 1.5);
title(sprintf('Puntos TL (%d) vs circulo R = %.3f mm', numel(X_tl_col), Radio));
xlabel('X (mm)'); ylabel('Y (mm)'); axis equal; grid on;
fprintf('[DIAG] TL X range: [%.3f, %.3f]  Y range: [%.3f, %.3f]\n', ...
    min(X_tl_col), max(X_tl_col), min(Y_tl_col), max(Y_tl_col));
fprintf('[DIAG] R aplicado: %.3f mm.  Puntos TL fuera del circulo: %d.\n', ...
    Radio, sum((X_tl_col.^2 + Y_tl_col.^2) > Radio^2));

%% Figura comparativa: centroides medidos (sigma=0) vs centroides reconstruidos por TL
% Argumento: ThorLabs mide centroides en TODAS las microlentes que detecta
% senal, pero solo entrega un mesh reconstruido para un subconjunto donde su
% algoritmo pudo reconstruir el frente. Esta figura muestra lado a lado los
% dos conjuntos para explicar por que la nube reconstruida puede verse mas
% recortada que los centroides crudos.
fig_cvsm = figure('Name', 'Cap5 Eval2 - centroides crudos vs mesh reconstruido TL', ...
    'Position', [100 100 1200 500]);

% Panel a) Centroides medidos en la toma central sigma=0 + circulo R
ax_cm_a = subplot(1,2,1);
plot(z3(:,1), z3(:,2), 'b.', 'MarkerSize', 5); hold on;
theta_circ = linspace(0, 2*pi, 200);
plot(Radio*cos(theta_circ), Radio*sin(theta_circ), 'r-', 'LineWidth', 1.5);
title(sprintf('a) Centroides medidos (\\sigma=0, %d puntos)', size(z3,1)));
xlabel('X (mm)'); ylabel('Y (mm)'); axis equal; grid on;

% Panel b) Centroides reconstruidos del mesh ThorLabs + circulo R
ax_cm_b = subplot(1,2,2);
plot(X_tl_col, Y_tl_col, 'b.', 'MarkerSize', 5); hold on;
plot(Radio*cos(theta_circ), Radio*sin(theta_circ), 'r-', 'LineWidth', 1.5);
title(sprintf('b) Centroides reconstruidos por TL (mesh, %d puntos)', numel(X_tl_col)));
xlabel('X (mm)'); ylabel('Y (mm)'); axis equal; grid on;

% Diagnostico de centrado: si los sistemas de coordenadas difieren los
% paneles tendran offsets distintos. Imprimir medias y rangos.
fprintf('[CMP] z3 centroides: mean=(%.4f, %.4f), X[%.3f,%.3f] Y[%.3f,%.3f]\n', ...
    mean(z3(:,1)), mean(z3(:,2)), min(z3(:,1)), max(z3(:,1)), min(z3(:,2)), max(z3(:,2)));
fprintf('[CMP] TL mesh:       mean=(%.4f, %.4f), X[%.3f,%.3f] Y[%.3f,%.3f]\n', ...
    mean(X_tl_col), mean(Y_tl_col), min(X_tl_col), max(X_tl_col), min(Y_tl_col), max(Y_tl_col));

% Sincronizar ejes para que la comparacion visual sea justa
xlim_cmp = [min(min(z3(:,1)), min(X_tl_col)), max(max(z3(:,1)), max(X_tl_col))];
ylim_cmp = [min(min(z3(:,2)), min(Y_tl_col)), max(max(z3(:,2)), max(Y_tl_col))];
set([ax_cm_a ax_cm_b], 'XLim', xlim_cmp, 'YLim', ylim_cmp);

exportgraphics(fig_cvsm, fullfile(fig_dir, 'cap5-eval2-centroides-vs-mesh-tl.png'), 'Resolution', 200);
fprintf('Figura comparativa centroides vs mesh guardada en: %s\n', ...
    fullfile(fig_dir, 'cap5-eval2-centroides-vs-mesh-tl.png'));

% Recortar TL al mismo radio que selectcirc nos aplico a la lista densificada,
% para que la comparacion se haga solo sobre puntos dentro del area evaluada.
% Si no recortamos aqui, knnsearch emparejaria puntos de TL fuera del circulo
% con su nuestro vecino mas cercano (en el borde), inflando el RMS.
n_tl_pre = numel(Z_tl_col);
mask_tl  = (X_tl_col.^2 + Y_tl_col.^2) <= Radio^2;
X_tl_col = X_tl_col(mask_tl);
Y_tl_col = Y_tl_col(mask_tl);
Z_tl_col = Z_tl_col(mask_tl);
fprintf('TL recortado al radio R: %d / %d puntos.\n', numel(Z_tl_col), n_tl_pre);

A_tl    = [X_tl_col, Y_tl_col, ones(size(X_tl_col))];
coef_tl = A_tl \ Z_tl_col;
a_tl = coef_tl(1); b_tl = coef_tl(2); c_tl = coef_tl(3);
fprintf('Fitted Plane (TL): Z = (%.6e)*X + (%.6e)*Y + (%.6e) [mm]\n', a_tl, b_tl, c_tl);
Ztl_sin_tilt = Z_tl_col - A_tl * coef_tl;

%% Diferencias (con y sin TTP) por knnsearch sobre los puntos de TL
puntos_buscar_tl    = [X_tl_col, Y_tl_col];
puntos_totales_mine = [X_coords, Y_coords];
indices_tl = knnsearch(puntos_totales_mine, puntos_buscar_tl);

dif_raw  = WF(indices_tl)          - Z_tl_col;
dif_sttp = WF_sin_tilt(indices_tl) - Ztl_sin_tilt;
rms_dif_raw  = sqrt(mean(dif_raw.^2));
rms_dif_sttp = sqrt(mean(dif_sttp.^2));

%% Segundo tratamiento: plano ajustado a la diferencia (post-TTP)
% El TTP-independiente quita a cada frente SU plano de mejor ajuste, lo que
% NO garantiza que los pistones y tilts residuales sean iguales entre los
% dos frentes. Si la diferencia (WF_sin_tilt - Ztl_sin_tilt) muestra un
% patron lineal residual (offset constante o tilt sistematico), aplicar un
% segundo tratamiento --ajustar UN solo plano a la diferencia y restarlo--
% elimina ese sesgo y devuelve el residuo no-lineal entre formas.
fig_dif_map = figure('Name', 'Cap5 Eval2 - diferencias: directa, post-TTP, post-segundo, via alternativa', ...
    'Position', [50 100 2000 500]);

% Segundo tratamiento: plano ajustado a la diferencia POST-TTP
A_dif    = [X_tl_col, Y_tl_col, ones(size(X_tl_col))];
coef_dif = A_dif \ dif_sttp;
a_dif = coef_dif(1); b_dif = coef_dif(2); c_dif = coef_dif(3);
plano_dif = A_dif * coef_dif;
dif_residual = dif_sttp - plano_dif;
rms_dif_residual = sqrt(mean(dif_residual.^2));

% Via alternativa: plano ajustado DIRECTAMENTE a la diferencia raw (sin TTP-indep.)
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

% Panel a) Diferencia DIRECTA: WF - Ztl, ambos con tilt
ax_d_a = subplot(1,4,1);
scatter3(X_tl_col, Y_tl_col, dif_raw_um, 30, dif_raw_um, 'filled');
title(sprintf('a) Directa (RMS = %.4f \\mum)', rms_dif_raw*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_a = max(abs(dif_raw_um)); caxis([-clim_a, clim_a]);
colormap(ax_d_a, 'jet'); cb_a = colorbar; ylabel(cb_a, '\Delta (\mum)');

% Panel b) Tras TTP independiente
ax_d_b = subplot(1,4,2);
scatter3(X_tl_col, Y_tl_col, dif_sttp_um, 30, dif_sttp_um, 'filled');
title(sprintf('b) Tras TTP indep. (RMS = %.4f \\mum)', rms_dif_sttp*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_b = max(abs(dif_sttp_um)); caxis([-clim_b, clim_b]);
colormap(ax_d_b, 'jet'); cb_b = colorbar; ylabel(cb_b, '\Delta (\mum)');

% Panel c) Tras segundo tratamiento (plano sobre Delta post-TTP)
ax_d_c = subplot(1,4,3);
scatter3(X_tl_col, Y_tl_col, dif_residual_um, 30, dif_residual_um, 'filled');
title(sprintf('c) Tras segundo tratam. (RMS = %.4f \\mum)', rms_dif_residual*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_c = max(abs(dif_residual_um)); caxis([-clim_c, clim_c]);
colormap(ax_d_c, 'jet'); cb_c = colorbar; ylabel(cb_c, '\Delta (\mum)');

% Panel d) Via alternativa (plano sobre la diferencia DIRECTA, sin TTP previo)
ax_d_d = subplot(1,4,4);
scatter3(X_tl_col, Y_tl_col, dif_residual_dir_um, 30, dif_residual_dir_um, 'filled');
title(sprintf('d) Plano sobre Delta directa (RMS = %.4f \\mum)', rms_dif_residual_dir*1000));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('\Delta (\mum)');
axis tight; grid on; view(35, 25);
clim_d = max(abs(dif_residual_dir_um)); caxis([-clim_d, clim_d]);
colormap(ax_d_d, 'jet'); cb_d = colorbar; ylabel(cb_d, '\Delta (\mum)');

fprintf('\n[DIAG] === Analisis de la diferencia post-TTP ===\n');
fprintf('[DIAG] Plano ajustado a la diferencia: a=%.4e mm/mm, b=%.4e mm/mm, c=%.4e mm\n', ...
    a_dif, b_dif, c_dif);
fprintf('[DIAG] RMS diferencia post-TTP (independiente):   %.6f mm  (%.4f um)\n', ...
    rms_dif_sttp, rms_dif_sttp*1000);
fprintf('[DIAG] RMS diferencia tras quitar plano de Delta: %.6f mm  (%.4f um)\n', ...
    rms_dif_residual, rms_dif_residual*1000);
fprintf('[DIAG] Reduccion: %.1f%%\n', (1 - rms_dif_residual/rms_dif_sttp)*100);

fprintf('\n[DIAG] === Comparativa de planos ===\n');
fprintf('                     a (mm/mm)     b (mm/mm)     c (mm)\n');
fprintf('  Plano nuestro:    %+.4e   %+.4e   %+.4e\n', a_tilt, b_tilt, c_tilt);
fprintf('  Plano TL:         %+.4e   %+.4e   %+.4e\n', a_tl,    b_tl,    c_tl);
fprintf('  Nuestro - TL:     %+.4e   %+.4e   %+.4e\n', ...
    a_tilt-a_tl, b_tilt-b_tl, c_tilt-c_tl);
fprintf('  Plano de Delta (post-TTP): %+.4e   %+.4e   %+.4e\n', a_dif, b_dif, c_dif);
fprintf('  Plano de Delta (directo):  %+.4e   %+.4e   %+.4e\n', a_dif_dir, b_dif_dir, c_dif_dir);
fprintf('===============================================\n');

fprintf('\n[VIA ALT] === Plano sobre la diferencia DIRECTA (sin TTP previo) ===\n');
fprintf('[VIA ALT] Plano: a=%.4e mm/mm, b=%.4e mm/mm, c=%.4e mm\n', ...
    a_dif_dir, b_dif_dir, c_dif_dir);
fprintf('[VIA ALT] RMS diferencia directa:                  %.6f mm  (%.4f um)\n', ...
    rms_dif_raw, rms_dif_raw*1000);
fprintf('[VIA ALT] RMS tras restar plano sobre Delta dir.:  %.6f mm  (%.4f um)\n', ...
    rms_dif_residual_dir, rms_dif_residual_dir*1000);
fprintf('[VIA ALT] Reduccion: %.1f%%\n\n', (1 - rms_dif_residual_dir/rms_dif_raw)*100);

exportgraphics(fig_dif_map, fullfile(fig_dir, 'cap5-eval2-diferencias-cuatro-etapas.png'), ...
    'Resolution', 200);
fprintf('Figura diferencias en cuatro etapas guardada en: %s\n', ...
    fullfile(fig_dir, 'cap5-eval2-diferencias-cuatro-etapas.png'));

%% Reconstruccion comparativa post-segundo-tratamiento (WF alineado con TL)
% Aplica el plano de Delta a NUESTROS puntos (no solo a la diferencia) para
% obtener un WF "alineado con TL". RMS resultante = rms_dif_residual.
% De esta figura se exportaran manualmente vistas trisurf para la tesis.
plano_dif_en_nuestros = [X_coords, Y_coords, ones(size(X_coords))] * coef_dif;
WF_doble_ajustado     = WF_sin_tilt - plano_dif_en_nuestros;
WF_doble_um           = WF_doble_ajustado * 1000;
Ztl_sttp_um           = Ztl_sin_tilt * 1000;   % usado tambien por las figs 3 y 4

fig_doble = figure('Name', 'Cap5 Eval2 - reconstruccion post-segundo-tratamiento (TL vs nuestro alineado)', ...
    'Position', [100 100 1300 500]);

DT_tl   = delaunay(X_tl_col, Y_tl_col);
DT_mine = delaunay(X_coords, Y_coords);
color_tl   = [0.45 0.65 0.85];
color_mine = [0.85 0.55 0.45];

ax_doble_a = subplot(1,2,1);
trisurf(DT_tl, X_tl_col, Y_tl_col, Ztl_sttp_um, ...
    'FaceColor', color_tl, 'EdgeColor', 'none', 'FaceAlpha', 1);
shading interp; camlight('headlight'); lighting gouraud; material dull;
title(sprintf('a) ThorLabs (sin TTP), %d puntos', numel(Ztl_sttp_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; view(35, 25);

ax_doble_b = subplot(1,2,2);
trisurf(DT_mine, X_coords, Y_coords, WF_doble_um, ...
    'FaceColor', color_mine, 'EdgeColor', 'none', 'FaceAlpha', 1);
shading interp; camlight('headlight'); lighting gouraud; material dull;
title(sprintf('b) Corrimiento de puntos tras 2do tratam. (%d puntos)', numel(WF_doble_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; view(35, 25);

% Sincronizar limites
zlim_doble = [min(min(Ztl_sttp_um), min(WF_doble_um)), max(max(Ztl_sttp_um), max(WF_doble_um))];
xlim_doble = [min(min(X_tl_col), min(X_coords)), max(max(X_tl_col), max(X_coords))];
ylim_doble = [min(min(Y_tl_col), min(Y_coords)), max(max(Y_tl_col), max(Y_coords))];
set([ax_doble_a ax_doble_b], 'ZLim', zlim_doble, 'XLim', xlim_doble, 'YLim', ylim_doble);

exportgraphics(fig_doble, fullfile(fig_dir, 'cap5-eval2-trisurf-post-segundo-tratamiento.png'), 'Resolution', 200);
fprintf('Figura trisurf post-segundo-tratamiento guardada en: %s\n', ...
    fullfile(fig_dir, 'cap5-eval2-trisurf-post-segundo-tratamiento.png'));

%% Figura 2: seleccion (izq) + reconstruccion con tilt cenital (der)
fig2 = figure('Name', 'Cap5 Eval2 Fig2 - seleccion + reconstruccion con tilt', ...
    'Position', [100 100 1200 500]);

% Panel a) lista densificada COMPLETA (pre-selectcirc) + frontera circular
ax2a = subplot(1,2,1);
plot(z_pre_sel(:,3), z_pre_sel(:,4), 'b.', 'MarkerSize', 4); hold on;
theta_circ = linspace(0, 2*pi, 200);
plot(Radio*cos(theta_circ), Radio*sin(theta_circ), 'k-', 'LineWidth', 1.2);
title(sprintf('a) Lista densificada y region seleccionada (R=%.3f mm)', Radio));
xlabel('X (mm)'); ylabel('Y (mm)'); axis equal tight; grid on;

% Panel b) reconstruccion con tilt, vista cenital coloreada por altura
ax2b = subplot(1,2,2);
WF_um = WF * 1000;
scatter(X_coords, Y_coords, 12, WF_um, 'filled');
title('b) Reconstruccion con tilt');
xlabel('X (mm)'); ylabel('Y (mm)'); axis equal tight; grid on;
colormap(ax2b, 'jet'); cb = colorbar; ylabel(cb, 'WF (\mum)');

exportgraphics(fig2, fullfile(fig_dir, 'cap5-eval2-seleccion-recon-tilt.png'), 'Resolution', 200);
fprintf('Figura 2 guardada en: %s\n', fullfile(fig_dir, 'cap5-eval2-seleccion-recon-tilt.png'));

%% Figura 3: scatter3 sin TTP (TL vs nuestro)
fig3 = figure('Name', 'Cap5 Eval2 Fig3 - scatter3 sin TTP', ...
    'Position', [100 100 1200 500]);

WF_sttp_um  = WF_sin_tilt   * 1000;
Ztl_sttp_um = Ztl_sin_tilt  * 1000;

ax3a = subplot(1,2,1);
scatter3(X_tl_col, Y_tl_col, Ztl_sttp_um, 12, Ztl_sttp_um, 'filled');
title(sprintf('a) Reconstruccion ThorLabs (%d puntos, sin TTP)', numel(Ztl_sttp_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; colormap(ax3a, 'jet'); colorbar; view(35, 25);

ax3b = subplot(1,2,2);
scatter3(X_coords, Y_coords, WF_sttp_um, 12, WF_sttp_um, 'filled');
title(sprintf('b) Reconstruccion corrimiento de puntos (%d puntos, sin TTP)', numel(WF_sttp_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; colormap(ax3b, 'jet'); colorbar; view(35, 25);

% Sincronizar limites entre paneles
zlim_c = [min(min(Ztl_sttp_um), min(WF_sttp_um)), max(max(Ztl_sttp_um), max(WF_sttp_um))];
xlim_c = [min(min(X_tl_col), min(X_coords)), max(max(X_tl_col), max(X_coords))];
ylim_c = [min(min(Y_tl_col), min(Y_coords)), max(max(Y_tl_col), max(Y_coords))];
set([ax3a ax3b], 'ZLim', zlim_c, 'XLim', xlim_c, 'YLim', ylim_c);

exportgraphics(fig3, fullfile(fig_dir, 'cap5-eval2-scatter3-sin-ttp.png'), 'Resolution', 200);
fprintf('Figura 3 guardada en: %s\n', fullfile(fig_dir, 'cap5-eval2-scatter3-sin-ttp.png'));

%% Figura 4: trisurf sin TTP (TL vs nuestro)
fig4 = figure('Name', 'Cap5 Eval2 Fig4 - trisurf sin TTP', ...
    'Position', [100 100 1200 500]);

DT_tl   = delaunay(X_tl_col, Y_tl_col);
DT_mine = delaunay(X_coords, Y_coords);
color_tl   = [0.45 0.65 0.85];
color_mine = [0.85 0.55 0.45];

ax4a = subplot(1,2,1);
trisurf(DT_tl, X_tl_col, Y_tl_col, Ztl_sttp_um, ...
    'FaceColor', color_tl, 'EdgeColor', 'none', 'FaceAlpha', 1);
shading interp; camlight('headlight'); lighting gouraud; material dull;
title(sprintf('a) ThorLabs (sin TTP), %d puntos', numel(Ztl_sttp_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; view(35, 25);

ax4b = subplot(1,2,2);
trisurf(DT_mine, X_coords, Y_coords, WF_sttp_um, ...
    'FaceColor', color_mine, 'EdgeColor', 'none', 'FaceAlpha', 1);
shading interp; camlight('headlight'); lighting gouraud; material dull;
title(sprintf('b) Corrimiento de puntos (sin TTP), %d puntos', numel(WF_sttp_um)));
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('WF (\mum)');
axis tight; grid on; view(35, 25);

set([ax4a ax4b], 'ZLim', zlim_c, 'XLim', xlim_c, 'YLim', ylim_c);

exportgraphics(fig4, fullfile(fig_dir, 'cap5-eval2-trisurf-sin-ttp.png'), 'Resolution', 200);
fprintf('Figura 4 guardada en: %s\n', fullfile(fig_dir, 'cap5-eval2-trisurf-sin-ttp.png'));

%% Resumen final
fprintf('\n=== RESUMEN: EVAL 2 - m1n2_z13_neg_max ===\n');
fprintf('  Puntos reconstruidos:               %d\n',     numel(WF));
fprintf('  Puntos canonicos (TL):              %d\n',     numel(Ztl));
fprintf('  Caminos depurados:                  %d\n',     size(list2,1));
fprintf('  Cota de vecindad:                   %.6f mm\n', cota);
fprintf('  Radio de seleccion:                 %.4f mm\n', Radio);
fprintf('  Plano quitado (nuestro):  a=%.4e mm/mm, b=%.4e mm/mm, c=%.4e mm\n', a_tilt, b_tilt, c_tilt);
fprintf('  Plano quitado (ThorLabs): a=%.4e mm/mm, b=%.4e mm/mm, c=%.4e mm\n', a_tl, b_tl, c_tl);
fprintf('  RMS diferencia (con tilt):       %.6f mm   (WF - Ztl, ambos antes de TTP)\n', rms_dif_raw);
fprintf('  RMS diferencia (sin tilt):       %.6f mm   (WF_sin_tilt - Ztl_sin_tilt)\n', rms_dif_sttp);
fprintf('  Plano de Delta (post-TTP):  a=%+.4e mm/mm, b=%+.4e mm/mm, c=%+.4e mm\n', a_dif, b_dif, c_dif);
fprintf('  RMS diferencia (segundo tratam): %.6f mm   (Delta - plano de Delta)\n', rms_dif_residual);
fprintf('  Plano de Delta (directo):   a=%+.4e mm/mm, b=%+.4e mm/mm, c=%+.4e mm\n', a_dif_dir, b_dif_dir, c_dif_dir);
fprintf('  RMS diferencia (via alternativa):%.6f mm   (Delta directa - plano de Delta directa)\n', rms_dif_residual_dir);
fprintf('==========================================================\n');
