% Função de seleção de torneio (seleciona o indivíduo com maior aptidão)
function selecionado = selecaoTorneio(populacao, aptidao)
    n_populacao = size(populacao, 1);
    % Selecionar aleatoriamente 5 indivíduos da população
    indices = randperm(n_populacao, 5);
    % Escolher o indivíduo com menor aptidão
    [~, indice_selecionado] = min(aptidao(indices));
    selecionado = populacao(indices(indice_selecionado), :);
end
