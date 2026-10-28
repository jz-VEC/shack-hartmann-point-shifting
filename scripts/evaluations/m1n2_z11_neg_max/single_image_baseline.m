%% SINGLE-IMAGE BASELINE - m1n2_z11_neg_max
% Aplica el mismo procedimiento de reconstruccion que m1n2_z11_neg_max.m,
% pero sobre UNA sola toma (imagen central sigma=0), sin densificacion por
% corrimiento de puntos. El objetivo es obtener un RMS comparativo que
% permita cuantificar numericamente el aporte del metodo de corrimiento.
%
% Diferencias respecto al script principal de 5 imagenes:
%   - Carga SOLO cent d+0 +0000.csv (no movmn, no vertcat).
%   - La cota de vecindad de intpath se recalcula para la malla regular:
%     paso = lenspitch (no lenspitch/sqrt(m^2+n^2)), vecino diagonal =
%     sqrt(2)*lenspitch. Sin este ajuste, intpath no encontraria vecinos.
%   - Mismo Radio de selectcirc para que la region geometrica sea comparable.
%   - Misma comparacion contra el mesh ThorLabs (mesh d+0 +0000.csv).

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

% Mismo Radio que el script de 5 imagenes (region geometrica comparable)
radiolens = 11 + 1.5;
Radio     = lenspitch * radiolens + .075;

% Cota AJUSTADA para malla regular (sin densificacion).
% Original (5 imagenes): cota = 1/sqrt(m^2+n^2) * lenspitch * sqrt(2) - eps
%   asumia paso = lenspitch/sqrt(m^2+n^2).
% Aqui paso = lenspitch, vecino diagonal = sqrt(2)*lenspitch.
cota = lenspitch * sqrt(2) - 0.0001;

%% Carga de UNA sola imagen (toma central sigma = 0)
base_path = string(p.datasets.z11_m1n2) + filesep;
disp('Loading single image (sigma = 0) ...');
z = get_data_list_from(base_path + "cent d+0 +0000.csv", sensor_size_x, sensor_size_y);
fprintf('Loaded %d microlenses from single image.\n', size(z,1));

%% Seleccion de la region util (mismo criterio circular)
disp('Selecting circular region...');
n_before = size(z,1);
z = selectcirc(z, Radio);
fprintf('Selected %d / %d rows within radius %.3f mm.\n', size(z,1), n_before, Radio);

%% Generacion de caminos e integracion
disp('Generating integration paths...');
list2 = intpath([z(:,3), z(:,4)], cota);
fprintf('Generated %d depurated integration paths.\n', size(list2,1));

disp('Integrating wavefront (trapezoidal rule along paths)...');
WF = intpaths(list2, z);
fprintf('Wavefront reconstructed at %d points.\n', numel(WF));

RMS_raw = sqrt(mean(WF.^2));
fprintf('RMS_raw (1 imagen): %f mm\n', RMS_raw);

%% Eliminar tip y tilt por ajuste de plano
disp('Removing tilt by plane fit...');
X_coords = z(:,3);
Y_coords = z(:,4);
A_tilt   = [X_coords, Y_coords, ones(size(X_coords))];
coef_tilt = A_tilt \ WF;
fitted_plane = A_tilt * coef_tilt;
WF_sin_tilt  = WF - fitted_plane;

RMS_sin_tilt = sqrt(mean(WF_sin_tilt.^2));
fprintf('RMS_sin_tilt (1 imagen): %f mm\n', RMS_sin_tilt);

%% Comparacion contra ThorLabs (mesh d+0 +0000.csv, misma toma sigma=0)
disp('Loading ThorLabs reference...');
thorlabs_file = p.datasets.thorlabs_ref_z11_m1n2;
if ~isfile(thorlabs_file)
    error('ThorLabs reference not found: %s', thorlabs_file);
end
[Xtl, Ytl, Ztl] = recuperarFrenteDeOndaTL(thorlabs_file);

% Conversion de unidades: el script principal asume um -> mm (ver comentario
% original en m1n2_z11_neg_max.m linea 300). Esta conversion NO esta
% validada experimentalmente todavia; verificar contra hoja de datos del WFS.
Ztl = Ztl / 1000;
fprintf('ThorLabs loaded: %d points, max |Z| = %.4f mm (asume um -> mm).\n', ...
    numel(Ztl), max(abs(Ztl)));

% Quitar tilt al ThorLabs (mismo procedimiento)
A_tl     = [Xtl, Ytl, ones(size(Xtl))];
coef_tl  = A_tl \ Ztl;
plano_tl = A_tl * coef_tl;
Ztl_sin_tilt = Ztl - plano_tl;
RMS_tl_sin_tilt = sqrt(mean(Ztl_sin_tilt.^2));
fprintf('RMS_sin_tilt (ThorLabs): %f mm\n', RMS_tl_sin_tilt);

% Emparejar cada punto de ThorLabs con el mas cercano de nuestra reconstruccion
puntos_buscar_tl    = [Xtl, Ytl];
puntos_totales_mine = [X_coords, Y_coords];
indices_encontrados_tl = knnsearch(puntos_totales_mine, puntos_buscar_tl);

WF_correspondiente_sin_tilt = WF_sin_tilt(indices_encontrados_tl);
diferencias_vs_tl_sin_tilt  = WF_correspondiente_sin_tilt - Ztl_sin_tilt;
rms_diferencia_vs_tl_sin_tilt = sqrt(mean(diferencias_vs_tl_sin_tilt.^2));
fprintf('RMS difference (1 imagen vs ThorLabs, sin tilt): %f mm\n', ...
    rms_diferencia_vs_tl_sin_tilt);

%% Resumen final
fprintf('\n=== RESUMEN: SINGLE-IMAGE BASELINE (m1n2_z11_neg_max) ===\n');
fprintf('  Puntos reconstruidos:               %d\n',     numel(WF));
fprintf('  Caminos depurados:                  %d\n',     size(list2,1));
fprintf('  Cota de vecindad:                   %.6f mm\n', cota);
fprintf('  Radio de seleccion:                 %.4f mm\n', Radio);
fprintf('  RMS_raw:                            %.6f mm\n', RMS_raw);
fprintf('  RMS_sin_tilt:                       %.6f mm\n', RMS_sin_tilt);
fprintf('  RMS_sin_tilt (ThorLabs):            %.6f mm\n', RMS_tl_sin_tilt);
fprintf('  RMS_diferencia_vs_TL_sin_tilt:      %.6f mm\n', rms_diferencia_vs_tl_sin_tilt);
fprintf('==========================================================\n');
