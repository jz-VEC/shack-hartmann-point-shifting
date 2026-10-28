# Reproducibilidad

## Requisitos

- MATLAB R2025a o una versión compatible.
- Statistics and Machine Learning Toolbox, utilizado por `knnsearch`.
- Una distribución LaTeX con `pdflatex` y los paquetes declarados en `TM.tex`.

No se requiere BibTeX: la bibliografía está escrita manualmente dentro de `TM.tex`.

## Compilar la tesis

Desde la raíz del repositorio:

```bash
cd thesis/work
pdflatex -interaction=nonstopmode -halt-on-error TM.tex
pdflatex -interaction=nonstopmode -halt-on-error TM.tex
```

La compilación pública no carga `thesis/work/private/frontmatter-approval.tex`, que se reserva para la copia administrativa privada. Por ello la portada se genera sin firma.

## Ejecutar las evaluaciones

Abra MATLAB con la raíz de este repositorio como directorio de trabajo y ejecute:

```matlab
run('scripts/evaluations/m1n2_z11_neg_max/m1n2_z11_neg_max.m')
run('scripts/evaluations/m1n2_z13_neg_max/m1n2_z13_neg_max.m')
run('scripts/evaluations/m1n3_z13_max/m1n3_z13_max.m')
```

Los scripts localizan funciones y datasets mediante `scripts/config/paths_config.m`. Las salidas regenerables se escriben en `scripts/output/` y las figuras exportadas en `thesis/assets/images/`.

El script auxiliar `scripts/evaluations/m1n2_z11_neg_max/single_image_baseline.m` ejecuta la comparación de referencia de una sola toma para la evaluación Z11.

## Datos originales y datos de trabajo

- `rawData/` conserva las carpetas originales y todos sus CSV, BMP, PNG y notas, incluidas las capturas de setup.
- `data/` conserva las tres carpetas completas de trabajo.
- Los scripts principales leen 23 CSV: 20 archivos de centroides y una retícula central de referencia por evaluación.

La correspondencia exacta está en [DATA_MANIFEST.md](DATA_MANIFEST.md). Los hashes se encuentran en `SHA256SUMS`.

## Alcance de la publicación

La publicación reproduce las tres evaluaciones del Capítulo 5. No contiene evaluaciones de espejo plano ni el generador `gen_cap4_shg_crudo.m`, porque ese generador depende de datos de plano que no forman parte de este conjunto público. La figura final requerida por la tesis sí está incluida.
