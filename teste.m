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
n_cidades = size(distancias, 1);

% Número de indivíduos na população
tamanho_populacao = 100;

% Número máximo de gerações
num_geracoes = 100;

% Taxa de mutação
taxa_mutacao = 0.5;

% Inicializar população aleatoriamente
populacao = zeros(tamanho_populacao, n_cidades);
for i = 1:tamanho_populacao
    populacao(i, :) = randperm(n_cidades);
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
% ----------------------------------------------------------------------


fprintf("Melhor caminho encontrado:\n");
n_cidades = length(melhor_caminho);
for i = 1:n_cidades
    cidade_atual = melhor_caminho(i);
    if i < n_cidades
        proxima_cidade = melhor_caminho(i+1);
    else
        proxima_cidade = melhor_caminho(1);
    end
    custo = distancias(cidade_atual, proxima_cidade);
    fprintf("Cidade %d -> Cidade %d (Custo: %d)\n", cidade_atual, proxima_cidade, custo);
end



% Criar a matriz de adjacência com o melhor caminho destacado
adjacencia = distancias;
n_cidades = size(adjacencia, 1);

% Incluir o melhor caminho na matriz de adjacência
melhor_caminho = [melhor_caminho, melhor_caminho(1)]; % Adicionar o primeiro nó ao final para formar um ciclo
for i = 1:n_cidades
    cidade_atual = melhor_caminho(i);
    proxima_cidade = melhor_caminho(i+1);
    adjacencia(cidade_atual, proxima_cidade) = adjacencia(cidade_atual, proxima_cidade) + 100; % Aumentar o peso da aresta do melhor caminho
end

% Tornar a matriz de adjacência simétrica
adjacencia = triu(adjacencia) + triu(adjacencia, 1)';

% Criar o gráfico do grafo não direcionado das cidades com o melhor caminho destacado
g = graph(adjacencia);

% Obter as coordenadas das cidades para o posicionamento do gráfico
xy = rand(n_cidades, 2);  % Usando coordenadas aleatórias para fins de exemplo

% Plotar o grafo das cidades com o melhor caminho destacado
figure;
p = plot(g, 'XData', xy(:, 1), 'YData', xy(:, 2), 'NodeColor', 'blue', 'EdgeAlpha', 0.5);
title('Grafo das Cidades com o Melhor Caminho');

% Destacar o melhor caminho com cor vermelha
highlight(p, melhor_caminho, 'EdgeColor', 'red', 'LineWidth', 2);

% Adicionar layout e force ao plot
layout(p, 'force', 'Iterations', 1000);



% ----------------------------------------------------------------------
% Função para calcular a aptidão de um indivíduo (caminho)
function aptidao = calcularAptidao(caminho, distancias)
    aptidao = 0;
    n_cidades = length(caminho);
    for i = 1:n_cidades-1
        aptidao = aptidao + distancias(caminho(i), caminho(i+1));
    end
    aptidao = aptidao + distancias(caminho(n_cidades), caminho(1));
end

% Função de seleção de torneio (seleciona o indivíduo com maior aptidão)
function selecionado = selecaoTorneio(populacao, aptidao)
    n_populacao = size(populacao, 1);
    % Selecionar aleatoriamente 5 indivíduos da população
    indices = randperm(n_populacao, 5);
    % Escolher o indivíduo com menor aptidão
    [~, indice_selecionado] = min(aptidao(indices));
    selecionado = populacao(indices(indice_selecionado), :);
end

% Operador de cruzamento PMX (Partially-Mapped Crossover)
function [filho1, filho2] = cruzamentoPMX(pai1, pai2)
    n_cidades = length(pai1);
    
    % Escolher dois pontos de corte aleatórios
    pontos_corte = sort(randperm(n_cidades, 2));
    ponto_corte1 = pontos_corte(1);
    ponto_corte2 = pontos_corte(2);
    
    % Criar os filhos inicialmente copiando os segmentos dos pais
    filho1 = zeros(1, n_cidades);
    filho2 = zeros(1, n_cidades);
    
    filho1(ponto_corte1:ponto_corte2) = pai1(ponto_corte1:ponto_corte2);
    filho2(ponto_corte1:ponto_corte2) = pai2(ponto_corte1:ponto_corte2);
    
    % Mapear as cidades entre os pontos de corte
    mapeamento1 = pai1(ponto_corte1:ponto_corte2);
    mapeamento2 = pai2(ponto_corte1:ponto_corte2);
    
    for i = ponto_corte1:ponto_corte2
        % Mapear as cidades repetidas do filho1
        if ~ismember(filho1(i), mapeamento2)
            cidade = filho1(i);
            while true
                indice_cidade_pai2 = find(pai2 == cidade);
                if ~ismember(pai1(indice_cidade_pai2), mapeamento1)
                    cidade = pai1(indice_cidade_pai2);
                    break;
                else
                    cidade = pai1(indice_cidade_pai2);
                end
            end
            filho1(i) = cidade;
        end
        
        % Mapear as cidades repetidas do filho2
        if ~ismember(filho2(i), mapeamento1)
            cidade = filho2(i);
            while true
                indice_cidade_pai1 = find(pai1 == cidade);
                if ~ismember(pai2(indice_cidade_pai1), mapeamento2)
                    cidade = pai2(indice_cidade_pai1);
                    break;
                else
                    cidade = pai2(indice_cidade_pai1);
                end
            end
            filho2(i) = cidade;
        end
    end
    
    % Preencher o restante das cidades nos filhos
    indices_vazios_filho1 = find(filho1 == 0);
    indices_vazios_filho2 = find(filho2 == 0);
    
    for i = 1:n_cidades
        if ismember(pai2(i), filho1) && isempty(find(filho1 == pai2(i), 1))
            indice_vazio = find(filho1 == 0, 1);
            filho1(indice_vazio) = pai2(i);
        end
        
        if ismember(pai1(i), filho2) && isempty(find(filho2 == pai1(i), 1))
            indice_vazio = find(filho2 == 0, 1);
            filho2(indice_vazio) = pai1(i);
        end
    end
    
    % Preencher os índices vazios com as cidades restantes
    cidade_restante_filho1 = setdiff(pai2, filho1);
    cidade_restante_filho2 = setdiff(pai1, filho2);
    
    for i = 1:length(indices_vazios_filho1)
        filho1(indices_vazios_filho1(i)) = cidade_restante_filho1(i);
    end
    
    for i = 1:length(indices_vazios_filho2)
        filho2(indices_vazios_filho2(i)) = cidade_restante_filho2(i);
    end
end

% Função de mutação (troca duas cidades de posição)
function individuo_mutado = mutacao(individuo, taxa_mutacao)
    individuo_mutado = individuo;
    
    % Verificar se a mutação ocorre com base na taxa de mutação
    if rand() < taxa_mutacao
        % Escolher duas posições aleatórias para a mutação
        posicoes_mutacao = randperm(length(individuo), 2);
        posicao1 = posicoes_mutacao(1);
        posicao2 = posicoes_mutacao(2);
        
        % Realizar a mutação trocando as cidades de posição
        cidade_temporaria = individuo_mutado(posicao1);
        individuo_mutado(posicao1) = individuo_mutado(posicao2);
        individuo_mutado(posicao2) = cidade_temporaria;
    end
end
