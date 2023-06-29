clear;
clc;

% Definir a matriz de adjacência
distancias = [
    0 1 2 4 6 2 2 3 3 5 6 1 4 5;
    1 0 3 2 1 3 6 3 4 4 2 4 4 4;
    2 3 0 1 3 3 2 3 4 1 3 5 5 6;
    4 2 1 0 5 1 4 2 3 4 4 8 2 2;
    6 1 3 5 0 2 1 6 5 2 3 4 2 2;
    2 3 3 1 2 0 3 1 2 3 5 7 3 4;
    2 6 2 4 1 3 0 2 1 2 5 2 4 3;
    3 3 3 2 6 1 2 0 5 5 1 5 3 6;
    3 4 4 3 5 2 1 5 0 1 4 4 5 3;
    5 4 1 4 2 3 2 5 1 0 5 4 4 2;
    6 2 3 4 3 5 5 1 4 5 0 4 2 1;
    1 4 5 8 4 7 2 5 4 4 4 0 1 3;
    4 4 5 2 2 3 4 3 5 4 2 1 0 1;
    5 4 6 2 2 4 3 6 3 2 1 3 1 0;
];

% Número de cidades
num_cidades = size(distancias, 1);

% Número de indivíduos na população
tamanho_populacao = 100;

% Número máximo de gerações
num_geracoes = 100;

% Taxa de mutação
taxa_mutacao = 0.5;

% Inicializar população aleatoriamente
populacao = zeros(tamanho_populacao, num_cidades);
for i = 1:tamanho_populacao
    populacao(i, :) = randperm(num_cidades);
end

% Loop principal do algoritmo genético
for geracao = 1:num_geracoes
    % Avaliar a aptidão de cada indivíduo na população
    aptidao = zeros(tamanho_populacao, 1);
    for i = 1:tamanho_populacao
        aptidao(i) = calcularAptidao(populacao(i, :), distancias);
    end
    
    % Ordenar a população com base na aptidão (menor caminho = maior aptidão)
    [aptidao, ordem] = sort(aptidao);
    populacao = populacao(ordem, :);
    
    % Selecionar os melhores indivíduos para a próxima geração (elitismo)
    elite = populacao(1:ceil(tamanho_populacao/5), :);
    
    % Criar a nova geração usando cruzamento e mutação
    nova_geracao = elite;
    while size(nova_geracao, 1) < tamanho_populacao
        % Selecionar dois pais aleatórios da população atual
        pai1 = selecaoTorneio(populacao, aptidao);
        pai2 = selecaoTorneio(populacao, aptidao);
        
        % Realizar cruzamento entre os pais para criar dois filhos
        [filho1, filho2] = cruzamentoPMX(pai1, pai2);
        
        % Realizar mutação nos filhos
        filho1 = mutacao(filho1, taxa_mutacao);
        filho2 = mutacao(filho2, taxa_mutacao);
        
        % Adicionar os filhos à nova geração
        nova_geracao = [nova_geracao; filho1; filho2];
    end
    
    % Atualizar a população para a próxima geração
    populacao = nova_geracao;
    
    % Encontrar o melhor indivíduo na geração atual
    melhor_individuo = populacao(1, :);
    melhor_aptidao = aptidao(1);
    fprintf("Geração #%d - Melhor aptidão: %d\n", geracao, melhor_aptidao);
end

% Melhor caminho encontrado
melhor_caminho = populacao(1, :);
melhor_aptidao = aptidao(1);

% Mostrar o resultado
disp('Melhor caminho encontrado:');
disp(melhor_caminho);
disp('Distância do melhor caminho:');
disp(melhor_aptidao);

% Imprimir o melhor caminho encontrado
fprintf("Melhor caminho encontrado:\n");
n_cidades = length(melhor_caminho);
for i = 1:n_cidades
    cidade_atual = melhor_caminho(i);
    if i < n_cidades
        proxima_cidade = melhor_caminho(i+1);
        custo = distancias(cidade_atual, proxima_cidade);
        fprintf("<strong> Cidade %02d </strong> -(Custo: %d)-> ", cidade_atual, custo);
    else
        proxima_cidade = melhor_caminho(1);
        custo = distancias(cidade_atual, proxima_cidade);
        fprintf("<strong> Cidade %02d </strong> -(Custo: %d)-> <strong> Cidade %02d </strong>\n", cidade_atual, custo, proxima_cidade);
    end
end

% Criar a matriz de adjacência com o melhor caminho destacado
adjacencia = distancias;
num_cidades = size(adjacencia, 1);

% Incluir o melhor caminho na matriz de adjacência
melhor_caminho = [melhor_caminho, melhor_caminho(1)]; % Adicionar o primeiro nó ao final para formar um ciclo
for i = 1:num_cidades
    cidade_atual = melhor_caminho(i);
    proxima_cidade = melhor_caminho(i+1);
    adjacencia(cidade_atual, proxima_cidade) = adjacencia(cidade_atual, proxima_cidade) + 100; % Aumentar o peso da aresta do melhor caminho
end

% Tornar a matriz de adjacência simétrica
adjacencia = triu(adjacencia) + triu(adjacencia, 1)';

% Criar o gráfico do grafo não direcionado das cidades com o melhor caminho destacado
g = graph(adjacencia);

% Obter as coordenadas das cidades para o posicionamento do gráfico
xy = rand(num_cidades, 2);  % Usando coordenadas aleatórias para fins de exemplo

% Plotar o grafo das cidades com o melhor caminho destacado
figure;
p = plot(g, 'XData', xy(:, 1), 'YData', xy(:, 2), 'NodeColor', 'blue', 'EdgeAlpha', 0.5);
title('Grafo das Cidades com o Melhor Caminho');

% Destacar o melhor caminho com cor vermelha
highlight(p, melhor_caminho, 'EdgeColor', 'red', 'LineWidth', 2);

% Adicionar layout e force ao plot
layout(p, 'force', 'Iterations', 1000);
