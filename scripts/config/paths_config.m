function p = paths_config()
% Centralized paths for Shack_Hartman_Con_corrimiento_de_puntos project.
% Project root is 3 levels up from this file (scripts/config/paths_config.m).

project_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));

p.root      = project_root;
p.functions = fullfile(project_root, 'scripts', 'functions');
p.output    = fullfile(project_root, 'scripts', 'output');

% Public datasets — names match what each reported evaluation script uses.
p.datasets.z13_m1n2_neg  = fullfile(project_root, 'data', 'm1n2_z13_neg_max');
p.datasets.z11_m1n2      = fullfile(project_root, 'data', 'm1n2_z11_neg_max');
p.datasets.z13_m1n3      = fullfile(project_root, 'data', 'm1n3_z13_max');

% ThorLabs reference mesh (d=0) per evaluation.
% Naming convention varies across datasets — captured per-eval to avoid hardcoding in scripts.
p.datasets.thorlabs_ref_z11_m1n2   = fullfile(p.datasets.z11_m1n2,     'mesh d+0 +0000.csv');
p.datasets.thorlabs_ref_z13_m1n2   = fullfile(p.datasets.z13_m1n2_neg, 'd0 Mesh .csv');
p.datasets.thorlabs_ref_z13_m1n3   = fullfile(p.datasets.z13_m1n3,     'mesh d+0 +0000.csv');
