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

% https://blog.x5ff.xyz/blog/ai-rust-javascript-pmx/