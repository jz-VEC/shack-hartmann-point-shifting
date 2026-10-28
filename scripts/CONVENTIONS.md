# Convenciones del código MATLAB

> **Documento público de referencia para cualquier persona que vaya a consultar o ejecutar los scripts.** Resume la terminología, las columnas de las matrices `z`, las constantes físicas y los detalles de las funciones core que hay que respetar para no romper la matemática del pipeline.

---

## 1. Centroides vs. centros de microlente — distinción crítica

Dos conceptos que la literatura suele mezclar y que **acá siempre se distinguen**:

| Concepto | Notación en código | Notación en tesis | Significado físico |
|---|---|---|---|
| **Centroide** | `centroids_x`, `centroids_y` | $(x_c, y_c)$ | Posición medida de la mancha de luz que cada microlente forma sobre la cámara. **Dato físico medido.** |
| **Centro de microlente** | `lens_x`, `lens_y` | $(x_l, y_l)$ | Vértice matemático del arreglo de microlentes. **Geometría conocida del sensor.** |

La diferencia por celda $\Delta = (x_l - x_c,\; y_l - y_c)$ codifica la pendiente local del frente de onda incidente y es la cantidad sobre la que opera el integrador.

**No confundir.** "Centroide" = mancha medida; "centro" = vértice teórico.

---

## 2. Convención de columnas en la matriz `z`

Las funciones del pipeline operan sobre matrices con esta estructura:

```matlab
z = [centroids_x, centroids_y, lens_x, lens_y, w_x, w_y]
%        col 1        col 2     col 3   col 4   col 5  col 6
```

| Col | Contenido | Notación tesis |
|---|---|---|
| 1, 2 | Centroides medidos | $(x_c, y_c)$ |
| 3, 4 | Centros de microlente | $(x_l, y_l)$ |
| 5, 6 | Aberración transversal | $(W_x, W_y)$ |
| **7** (opcional) | **Tag de origen** $(1..\varepsilon)$ | añadido en scripts de evaluación para identificar de qué corrimiento $\sigma_i$ viene cada fila |

La columna 7 se agrega entre `movmn` y el `vertcat`. Las funciones core (`movmn`, `selectcirc`, `intpath`, `intpaths`) **no leen** columnas $\ge 7$ — viaja intacta.

---

## 3. Funciones core — qué leen y qué modifican

Verificado contra el código fuente en `scripts/functions/`:

| Función | Lee | Modifica | Comentario |
|---|---|---|---|
| `get_data_list_from(path, sx, sy)` | CSV ThorLabs | Devuelve matriz de 6 columnas | Llama internamente a `get_all_data_listed_from` + `clean_nan_elements`. El paso `recenter` está comentado dentro. |
| `movmn(z, dist, m, n)` | cols 1-4 | Suma $(\cos\theta\cdot\text{dist}, \sin\theta\cdot\text{dist})$ con $\theta = \arctan(m/n)$ | Cols 5+ intactas. Imprime `angulo` (falta `;` cosmético). |
| `selectcirc(z, R)` | cols 3-4 | Elimina filas con $x_l^2 + y_l^2 > R^2$ | Conserva todas las columnas. Tiene un `plot` interno que se cuela en la figura activa. |
| `intpath(zin, cota)` | primeras 2 cols del input | — | Devuelve `list2`: índices de los caminos voraces no redundantes. Se llama con `intpath([z(:,3), z(:,4)], cota)`, por lo que opera sobre los **centros de microlente**. |
| `intpaths(list2, z)` | cols 3, 4, 5, 6 | Devuelve vector `WF` | Aplica regla del trapecio sobre los caminos. Usa focal $f = 4.1$ mm hardcoded internamente. |
| `recuperarFrenteDeOndaTL(path)` | CSV `mesh d+0 ...` de ThorLabs | Devuelve `lens_x, lens_y, Z` | `Z` viene en **µm** (dividir por 1000 para mm). |

---

## 4. Constantes físicas — no cambian entre evaluaciones

Hardcoded en varias funciones (`get_all_data_listed_from`, `intpath`, `recuperarFrenteDeOndaTL`):

| Constante | Valor | Significado |
|---|---|---|
| `focal` (`zW205c`) | $4.1$ mm | Distancia focal del WFS20-5C |
| `lens_pitch_x/y` | $0.150$ mm | Pitch del arreglo de microlentes |
| `pixel_size_x/y` | $0.005$ mm | Tamaño de píxel |
| `pnx, pny` | $1440, 1080$ | Resolución del sensor |
| `adj_x, adj_y` | $-0.02, -0.01$ mm | Ajuste empírico de origen |
| Lente central | fila 18, columna 24 | Microlente que se usa como origen $(0,0)$ |

---

## 5. Cota de vecindad en `intpath`

Umbral que decide qué puntos son "vecinos" durante el barrido voraz:

$$
\text{cota} = \frac{1}{\sqrt{m^2 + n^2}} \cdot \sqrt{2} \cdot \text{lenspitch} - \epsilon_{\text{pequeño}}
$$

Para malla **regular sin densificar** (single image baseline):

$$
\text{cota} = \sqrt{2}\cdot\text{lenspitch} - \epsilon_{\text{pequeño}}
$$

---

## 6. ThorLabs mesh — unidades y recorte

1. **`recuperarFrenteDeOndaTL` devuelve `Z` en µm**, no en mm. Dividir por 1000 inmediatamente después de cargarlo:
   ```matlab
   [Xtl, Ytl, Ztl_um] = recuperarFrenteDeOndaTL(path);
   Ztl = Ztl_um / 1000;   % ahora en mm
   ```
2. **Recortar Ztl al mismo radio $R$** que `selectcirc` aplicó a nuestra lista antes del `knnsearch`. Sin esto, el `knnsearch` empareja puntos fuera del área evaluada y el RMS de diferencias se infla artificialmente.

---

## 7. Métricas RMS — terminología en español

Carlos usa estos nombres consistentemente:

- **RMS diferencia directa** (en código: `rms_dif_raw`, `dif_raw`): $\sqrt{\overline{(\Delta)^2}}$ con ambos frentes *con tilt*.
- **RMS diferencia post-TTP**: $\sqrt{\overline{(\Delta_{\text{sttp}})^2}}$ con cada frente restando su propio plano de mejor ajuste.
- **RMS diferencia tras segundo tratamiento** (también: **RMS final**): RMS de $\Delta_{\text{sttp}}$ después de restarle un único plano ajustado a la diferencia.

**Nota:** "raw" en el .tex fue reemplazado por "directa" para evitar spanglish. En el código pueden quedar nombres de variables con `_raw` — déjalos, pero en cualquier `fprintf`/título de figura que vaya a la tesis usa "directa".

En los estados aberrados publicados (Z11 y Z13), el RMS individual post-TTP **no** tiene significado físico; se reporta el RMS de las **diferencias** entre nuestra reconstrucción y la de ThorLabs.

---

## 8. Términos consolidados

| Término | Definición operativa |
|---|---|
| **TTP** | Tip + Tilt + Pistón. Los tres modos lineales de un frente de onda: $aX + bY + c$. |
| **TTP independiente** | Restar a cada frente su propio plano de mejor ajuste por mínimos cuadrados. |
| **Segundo tratamiento** | Ajustar un único plano a la diferencia $\Delta$ y restarlo. Algebraicamente equivalente a corregir uno de los frentes con ese plano. Documentado en Cap 4 §4.5.4 (`sec:segundo-tratamiento`). |
| **Algoritmo voraz** (greedy) | En cada paso elige la opción que mejor optimiza un criterio local sin explorar alternativas. Definido en Cap 4 §sec:caminos-integracion. |
| **Lista densificada** | Concatenación vertical de las matrices `z1, z2, ..., zε` después de aplicar `movmn` a cada una. |
| **Subset $\sigma = 0$** | Filas de la lista densificada que vienen del archivo `cent d+0 +0000.csv` (toma central, sin desplazamiento). Identificable por col 7 = índice del `z_i` central. |

---

## 9. Datasets y nomenclatura de archivos

| Dataset | $(m, n)$ | $\varepsilon$ | Aberración | Evaluación reportada |
|---|---|---|---|---|
| `m1n2_z11_neg_max` | $(1, 2)$ | $5$ | $Z_{11}$ (tetrafoil-y) neg max, slider $-0.99$ | Eval 1 |
| `m1n2_z13_neg_max` | $(1, 2)$ | $5$ | $Z_{13}$ (esférica primaria) neg, slider $-0.97$ | Eval 2 |
| `m1n3_z13_max` | $(1, 3)$ | $10$ | $Z_{13}$ (esférica primaria) neg, slider $-0.92$ según foto `I2.png` | Eval 3 |

> **$Z_{11}$ y $Z_{13}$ son modos del DM** (índices del software del DMP40-FM1, numeración ANSI Z80.28-2010 con pistón=Z1), no coeficientes de Zernike calculados sobre la reconstrucción. **Nombres correctos (verificados 2026-07-07 con fotos de setup + manual): Z11 = TetY = tetrafoil-y (4,−4); Z13 = SAb3 = esférica primaria (4,0).** Los rótulos viejos "esférica" para Z11 y "coma" para Z13 eran incorrectos.

**Caveats de naming en los `data/`** (los CSV originales tienen typos que hay que respetar al hardcodearlos):

- `m1n2_z13_neg_max/cent d+0 0.00.csv` (no `+0000`).
- `m1n2_z13_neg_max/d0 Mesh .csv` (espacio final).
- `m1n3_z13_max/cent d+2 +949.csv` (falta el cero, debería ser `+0949`).

**Regla:** antes de hardcodear nombres en un script nuevo, hacer `ls` del directorio del dataset.

---

## 10. Outputs y nomenclatura de imágenes

### Workflow de figuras hacia la tesis

1. El script MATLAB genera una figura canónica y la exporta a `thesis/assets/images/cap5-<eval>-<descripcion>.png`.
2. La publicación conserva las figuras finales que utiliza la tesis; los archivos de trabajo `.fig` son intermedios regenerables y no se distribuyen.
3. `TM.tex` utiliza los nombres finales exportados en `thesis/assets/images/`.

### Patrón de nombres

- `cap5-fig5_X_Y-descripcion.png` — eval 1 (numeración tipo subsección).
- `cap5-evalN-figM-descripcion.png` — eval 2 y 3 (numeración por figura dentro de la eval).
- `cap5-evalN-<concepto>.png` — auxiliares (p.ej. `cap5-eval2-diferencias-tres-etapas.png`).

### Outputs `.mat` en `scripts/output/`

Los scripts pueden guardar archivos `.mat` con reconstrucciones intermedias. Son resultados regenerables y no forman parte de la publicación.

---

## 11. Reglas que no se deben romper

1. **Usar `paths_config()` siempre.** No hardcodear rutas; referenciar `p.datasets.*`, `p.functions`, `p.output`.
2. **No modificar las funciones core** (`intpath`, `intpaths`, `movmn`, `selectcirc`, `get_data_list_from`, `recuperarFrenteDeOndaTL`) salvo bug fixes muy puntuales y verificados.
3. **ThorLabs `Z` viene en µm**; dividir por 1000 antes de comparar.
4. **Recortar el mesh ThorLabs al mismo radio** que `selectcirc` aplicó al WF nuestro antes del `knnsearch`.

---

## 12. Mapeo de secciones a la tesis

| Sección del pipeline | Capítulo / sección de la tesis |
|---|---|
| Carga de centroides + lentes (`get_data_list_from`) | Cap 4 §4.2.2 |
| Corrimientos (`movmn`, ángulo $\theta = \arctan(m/n)$) | Cap 4 §4.2.3 |
| Recorte circular (`selectcirc`) | Cap 4 §4.2.4 |
| Caminos voraces (`intpath`) | Cap 4 §4.3.2 |
| Integración trapecio (`intpaths`) | Cap 4 §4.3.3 |
| TTP removal (ajuste de plano por mínimos cuadrados) | Cap 4 §4.4 |
| Segundo tratamiento (plano sobre $\Delta$) | Cap 4 §4.5.4 |
| Resultados (3 evaluaciones aberradas) | Cap 5 |

---

## 13. Documentación pública relacionada

- `README.md` — alcance y estructura de la publicación.
- `REPRODUCIBILITY.md` — instrucciones de compilación y ejecución.
- `DATA_MANIFEST.md` — correspondencia entre adquisiciones originales, copias de trabajo y archivos consumidos por cada evaluación.
