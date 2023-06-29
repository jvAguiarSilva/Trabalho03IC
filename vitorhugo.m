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

% Criar o grafo a partir da matriz de adjacência
grafo = graph(distancias);

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
    elite = populacao(1:round(0.1*tamanho_populacao), :);
    
    % Reprodução e crossover (utilizando operador PMX)
    nova_populacao = elite;
    for i = 1:(tamanho_populacao - size(elite, 1))
        pai1 = selecaoTorneio(populacao, aptidao, 5);
        pai2 = selecaoTorneio(populacao, aptidao, 5);
        filho = crossoverPMX(pai1, pai2);
        nova_populacao = [nova_populacao; filho];
    end
    
    % Aplicar mutação em cada indivíduo da nova população
    for i = 1:size(nova_populacao, 1)
        if rand() < taxa_mutacao
            nova_populacao(i, :) = mutacaoSwap(nova_populacao(i, :));
        end
    end
    
    % Atualizar a população para a próxima geração
    populacao = nova_populacao;
    
    % Melhor caminho da geração atual
    melhor_caminho = populacao(1, :);
    
    % Plotar o grafo correspondente ao caminho de menor custo
    figure;
    custos_caminhos = zeros(length(melhor_caminho), 1);
    for i = 1:size(grafo.Edges, 1)
        caminho = melhor_caminho;
        custo = 0;
        for j = 1:(length(caminho)-1)
            cidade_origem = caminho(j);
            cidade_destino = caminho(j+1);
            custo = custo + distancias(cidade_origem, cidade_destino);
        end
        custos_caminhos(i) = custo;
    end
    grafo.Edges.Weight = custos_caminhos';
    
    p = plot(grafo, 'Layout', 'force');
    highlight(p, melhor_caminho, 'EdgeColor', 'r', 'LineWidth', 2);
    title('Grafo do caminho de menor custo com os custos dos caminhos');
end

% Função para calcular a aptidão de um indivíduo (caminho)
function aptidao = calcularAptidao(caminho, distancias)
    aptidao = 0;
    n_cidades = length(caminho);
    for i = 1:n_cidades-1
        aptidao = aptidao + distancias(caminho(i), caminho(i+1));
    end
    aptidao = aptidao + distancias(caminho(n_cidades), caminho(1));
end

% Função de seleção por torneio
function selecionado = selecaoTorneio(populacao, aptidao, k)
    indices = randperm(size(populacao, 1), k);
    [~, indice_vencedor] = min(aptidao(indices));
    selecionado = populacao(indices(indice_vencedor), :);
end

% Operador de crossover PMX (Partially-Mapped Crossover)
function filho = crossoverPMX(pai1, pai2)
    n = length(pai1);
    pontos_corte = sort(randperm(n, 2));
    ponto_corte1 = pontos_corte(1);
    ponto_corte2 = pontos_corte(2);
    intervalo = ponto_corte1:ponto_corte2;
    filho = pai1;
    filho(intervalo) = pai2(intervalo);
    mapeamento = containers.Map('KeyType', 'double', 'ValueType', 'double');
    for i = intervalo
        mapeamento(pai1(i)) = pai2(i);
    end
    for i = 1:n
        if isKey(mapeamento, filho(i))
            valor_atual = filho(i);
            while isKey(mapeamento, valor_atual)
                valor_atual = mapeamento(valor_atual);
            end
            filho(i) = valor_atual;
        end
    end
end

% Operador de mutação Swap
function mutado = mutacaoSwap(individuo)
    n = length(individuo);
    pontos_mutacao = sort(randperm(n, 2));
    ponto_mutacao1 = pontos_mutacao(1);
    ponto_mutacao2 = pontos_mutacao(2);
    mutado = individuo;
    mutado(ponto_mutacao1) = individuo(ponto_mutacao2);
    mutado(ponto_mutacao2) = individuo(ponto_mutacao1);
end
