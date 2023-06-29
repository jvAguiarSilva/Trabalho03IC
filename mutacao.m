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