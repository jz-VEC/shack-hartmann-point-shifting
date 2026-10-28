# Manifiesto de datos

Los directorios de `rawData/` conservan los nombres históricos de adquisición. No fueron renombrados ni modificados. Las carpetas normalizadas de `data/` son las copias de trabajo completas utilizadas durante el análisis.

Los archivos CSV incluyen los identificadores de instrumento presentes en la exportación original. Se conservaron para mantener la integridad de los datos crudos.

## Correspondencia de datasets

| Evaluación | Adquisición original | Copia de trabajo | Archivo de setup incluido |
|---|---|---|---|
| Z11, $(m,n)=(1,2)$, ε=5 | `rawData/T-1.2-5i/z11 neg max/` | `data/m1n2_z11_neg_max/` | `alineado al cero.png` |
| Z13, $(m,n)=(1,2)$, ε=5 | `rawData/T-1.2-5i/frente de onda -13 negativo max/` | `data/m1n2_z13_neg_max/` | `inicio setup 0.png` |
| Z13, $(m,n)=(1,3)$, ε=10 | `rawData/T-1.3-10i/z13 max/` | `data/m1n3_z13_max/` | `I2.png` y `posicon cero z13 negativo.png` |

Las adquisiciones contienen 90 archivos originales: 21 para Z11 con ε=5, 27 para Z13 con ε=5 y 42 para Z13 con ε=10. Las copias de trabajo contienen 94 archivos porque añaden tres README y una figura comparativa.

En Z11, `rawData/T-1.2-5i/z11 neg max/cent d-1 - 0671.csv` se copió en `data/m1n2_z11_neg_max/cent d-1 -0671.csv` normalizando únicamente el espacio del nombre. Los contenidos son idénticos y comparten el hash `69e32bd9f61ce1bace48b6f9ae488f5de4dd2e7f39d19ad5afa0148b5309a059`.

## Archivos consumidos directamente por los scripts

### `m1n2_z11_neg_max.m`

```text
data/m1n2_z11_neg_max/cent d-2 -1342.csv
data/m1n2_z11_neg_max/cent d-1 -0671.csv
data/m1n2_z11_neg_max/cent d+0 +0000.csv
data/m1n2_z11_neg_max/cent d+1 +0671.csv
data/m1n2_z11_neg_max/cent d+2 +1342.csv
data/m1n2_z11_neg_max/mesh d+0 +0000.csv
```

### `m1n2_z13_neg_max.m`

```text
data/m1n2_z13_neg_max/cent d-2 -1342.csv
data/m1n2_z13_neg_max/cent d-1 -0671.csv
data/m1n2_z13_neg_max/cent d+0 0.00.csv
data/m1n2_z13_neg_max/cent d+1 0671.csv
data/m1n2_z13_neg_max/cent d+2 1342.csv
data/m1n2_z13_neg_max/d0 Mesh .csv
```

### `m1n3_z13_max.m`

```text
data/m1n3_z13_max/cent d-4 -1897.csv
data/m1n3_z13_max/cent d-3 -1423.csv
data/m1n3_z13_max/cent d-2 -0949.csv
data/m1n3_z13_max/cent d-1 -0474.csv
data/m1n3_z13_max/cent d+0 +0000.csv
data/m1n3_z13_max/cent d+1 +0474.csv
data/m1n3_z13_max/cent d+2 +949.csv
data/m1n3_z13_max/cent d+3 +1423.csv
data/m1n3_z13_max/cent d+4 +1897.csv
data/m1n3_z13_max/cent d+5 +2371.csv
data/m1n3_z13_max/mesh d+0 +0000.csv
```

Los restantes archivos `mesh`, `pow`, BMP, PNG y notas se incluyen como parte del registro experimental y de la documentación visual del setup, aunque los scripts principales no los lean directamente.

## Integridad

`SHA256SUMS` contiene un hash SHA-256 para cada archivo de la publicación. Los datos crudos y sus copias de trabajo pueden compararse mediante esos valores sin depender de los nombres normalizados.
