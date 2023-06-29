% Função para calcular a aptidão de um indivíduo (caminho)
function aptidao = calcularAptidao(caminho, distancias)
    aptidao = 0;
    n_cidades = length(caminho);
    for i = 1:n_cidades-1
        aptidao = aptidao + distancias(caminho(i), caminho(i+1));
    end
    aptidao = aptidao + distancias(caminho(n_cidades), caminho(1));
end