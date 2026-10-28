# Shack-Hartmann con corrimiento de puntos

Versión pública de los materiales asociados con la tesis de maestría de Carlos Enrique Valderrama Juárez, desarrollada en el Instituto de Ciencias Aplicadas y Tecnología (ICAT) de la Universidad Nacional Autónoma de México (UNAM), bajo la dirección del Dr. Rufino Díaz-Uribe.

Este es el repositorio citado en el Apéndice A de la tesis. Contiene la fuente LaTeX, las figuras necesarias para compilarla, los datos experimentales originales y el código MATLAB de las tres evaluaciones reportadas en el Capítulo 5.

© 2026 Carlos Enrique Valderrama Juárez. Todos los derechos reservados. Consulte [LICENSE](LICENSE) antes de reutilizar cualquier material.

## Contenido

| Ruta | Contenido |
|---|---|
| `thesis/work/TM.tex` | Fuente LaTeX de la tesis. La versión pública no contiene la firma del director. |
| `thesis/assets/images/` | 52 imágenes utilizadas por `TM.tex`. |
| `scripts/functions/` | Funciones MATLAB reutilizables del pipeline. |
| `scripts/config/paths_config.m` | Rutas relativas de los tres datasets públicos. |
| `scripts/evaluations/` | Scripts de Z11 con ε=5, Z13 con ε=5 y Z13 con ε=10. |
| `rawData/` | Archivos originales de adquisición, con sus nombres históricos intactos. Incluye spotgramas y capturas de setup. |
| `data/` | Copias de trabajo completas utilizadas durante el análisis. |
| `DATA_MANIFEST.md` | Correspondencia entre adquisiciones, datasets normalizados y los 23 CSV consumidos directamente. |
| `SHA256SUMS` | Hash SHA-256 de cada archivo publicado. |

No forman parte de esta publicación la firma del director, las revisiones internas, los documentos de desarrollo, los PDFs de referencias, las evaluaciones de plano ni otros ensayos no reportados.

## Evaluaciones publicadas

| Evaluación | Configuración | Script |
|---|---:|---|
| Z11 negativo máximo | $(m,n)=(1,2)$, ε=5 | `scripts/evaluations/m1n2_z11_neg_max/m1n2_z11_neg_max.m` |
| Z13 negativo máximo | $(m,n)=(1,2)$, ε=5 | `scripts/evaluations/m1n2_z13_neg_max/m1n2_z13_neg_max.m` |
| Z13 negativo máximo | $(m,n)=(1,3)$, ε=10 | `scripts/evaluations/m1n3_z13_max/m1n3_z13_max.m` |

Las instrucciones completas están en [REPRODUCIBILITY.md](REPRODUCIBILITY.md). Las convenciones de matrices, unidades y métricas se documentan en [scripts/CONVENTIONS.md](scripts/CONVENTIONS.md).

## Compilación rápida

```bash
cd thesis/work
pdflatex -interaction=nonstopmode -halt-on-error TM.tex
pdflatex -interaction=nonstopmode -halt-on-error TM.tex
```

El PDF es un producto regenerable y no se conserva en el repositorio.

## Declaración de uso de inteligencia artificial

> Declaración incorporada al repositorio el 23 de octubre de 2026, con intención de reconocer la asistencia recibida. Este repositorio es el referido en el Apéndice A de la tesis.

Durante la preparación de esta tesis se utilizaron herramientas de inteligencia artificial generativa, principalmente Claude mediante Claude Code y Cowork, con los modelos Opus 4.8, Claude Fable 5.1 y Claude Opus 5.5. Estas herramientas se emplearon como apoyo para organizar y reformular la redacción de diferentes apartados a partir de notas, borradores, explicaciones y contenido científico aportados por el autor. Codex, con los modelos GPT-6.1-Sol y GPT-5.6-Sol de OpenAI, se utilizó como apoyo para la revisión del documento y de las referencias bibliográficas, así como para la preparación técnica de esta versión pública, sin generar resultados experimentales ni modificar su interpretación científica.

La asistencia también comprendió mejoras de legibilidad y documentación del código, así como tareas de organización de archivos y configuración de rutas del software desarrollado por el autor. El planteamiento de la investigación, el desarrollo experimental, la formulación de los algoritmos de evaluación y la interpretación científica corresponden al trabajo del autor bajo la dirección de su asesor. Los resultados experimentales no fueron generados por inteligencia artificial.

El autor revisó y editó el material incorporado y asume la responsabilidad por la exactitud, integridad y contenido final de la tesis.

## Material de terceros

Las figuras procedentes de fabricantes y el software visible en algunas capturas pertenecen a sus respectivos titulares. Consulte [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). La licencia del repositorio no concede derechos adicionales sobre esos materiales.

## Contacto

Carlos Enrique Valderrama Juárez — `carlosvalderrama.jz@gmail.com`
