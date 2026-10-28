function [lens_x, lens_y, Z] = recuperarFrenteDeOndaTL(rutaArchivo)

    % Funci�n para recuperar las posiciones Z de un frente de onda desde un archivo CSV
    % y asociarlas con posiciones de microlentes
    %
    % Entradas:
    %   rutaArchivo - Ruta completa y nombre del archivo CSV
    %
    % Salidas:
    %   lens_x - Vector de coordenadas X de las microlentes
    %   lens_y - Vector de coordenadas Y de las microlentes
    %   Z - Vector de valores Z del frente de onda
    
    % Par�metros para las microlentes
    lens_pitch_x = 0.150; % mm
    lens_pitch_y = 0.150; % mm
    adj_x = -0.02; % Ajuste seg�n tus datos
    adj_y = -0.01; % Ajuste seg�n tus datos
    
    % Generar las coordenadas de las microlentes
    [lens_m_x, lens_m_y] = get_lens_centers_mm(lens_pitch_x, lens_pitch_y, adj_x, adj_y);
    
    % Leer el archivo como texto - m�todo m�s robusto
    fileID = fopen(rutaArchivo, 'r');
    if fileID == -1
        error('No se pudo abrir el archivo: %s', rutaArchivo);
    end
    
    % Leer todo el contenido
    contenido = textscan(fileID, '%s', 'Delimiter', '\n');
    fclose(fileID);
    contenido = contenido{1};
    
    % Extraer las l�neas relevantes (101-135)
    lineasZ = contenido(102:136);
    
    % Procesar cada l�nea para extraer los valores Z
    Z_matrix = zeros(35, 47);
    for i = 1:length(lineasZ)
        lineaActual = strsplit(lineasZ{i}, ',');
        % Tomar desde la columna 2 hasta el final (m�ximo 47 columnas m�s)
        numCols = min(length(lineaActual)-1, 47);
        for j = 1:numCols
            if j+1 <= length(lineaActual)
                try
                    valorZ = str2double(lineaActual{j+1});
                    Z_matrix(i, j) = valorZ;
                catch
                    Z_matrix(i, j) = NaN;
                    fprintf('Error al convertir el valor en fila %d, columna %d\n', i, j+1);
                end
            end
        end
    end
    
    % Get the position of the central lens
    central_y = 18; central_x = 24;
    central_lens_x = lens_m_x(central_y, central_x);
    central_lens_y = lens_m_y(central_y, central_x);
    
    % Centrar matrices de lentes
    lens_m_x = lens_m_x - central_lens_x;
    lens_m_y = lens_m_y - central_lens_y;
    
    % Convertir de matrices a vectores
    lens_x = lens_m_x(:);
    lens_y = lens_m_y(:);
    Z_vector = Z_matrix(:);

% clean 

[lens_x, lens_y, Z_vector] = clean_nan_elements1(lens_x, lens_y, Z_vector);
    
    % Visualizar los resultados
    figure;
    validPoints = ~isnan(Z_vector);
    scatter3(lens_x, lens_y, Z_vector, 'filled');
%     colormap(jet);
%     colorbar;
    title('Frente de onda recuperado');
    xlabel('Posici�n X (mm)');
    ylabel('Posici�n Y (mm)');
    zlabel('Posici�n Z(um)');
    
    % Devolver los vectores
    Z = Z_vector;
end

function [lens_x_clean, lens_y_clean, Z_clean] = clean_nan_elements1(lens_x, lens_y, Z)
    % Funci�n para eliminar elementos NaN de los vectores
    
    % Encontrar los �ndices de elementos v�lidos (donde Z no es NaN)
    indices_validos = ~isnan(Z);
    
    % Filtrar los datos usando los �ndices v�lidos
    lens_x_clean = lens_x(indices_validos);
    lens_y_clean = lens_y(indices_validos);
    Z_clean = Z(indices_validos);
    
    % Mostrar informaci�n sobre el proceso de limpieza
    num_eliminados = sum(~indices_validos);
    num_elementos = length(Z);
    fprintf('Se eliminaron %d elementos NaN de un total de %d (%0.2f%%)\n', ...
        num_eliminados, num_elementos, 100*num_eliminados/num_elementos);
    fprintf('Quedan %d elementos v�lidos\n', length(Z_clean));
end
