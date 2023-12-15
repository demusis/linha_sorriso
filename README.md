# Introdução
Este repositório GitHub apresenta um código na linguagem R desenvolvido com base na metodologia do artigo "Smile photograph analysis and its connection with focal length as one of identification methods in forensic anthropology and odontology". O código foca na análise de fotografias de sorrisos para identificação forense e visa automatizar e facilitar a aplicação prática desses métodos.

# Metodologia
O script foi projetado para analisar linhas de sorriso em fotografias, uma técnica relevante em antropologia e odontologia forense. Ele realiza os seguintes passos:

1. **Rotaciona e Normaliza Dados**: Processa um conjunto de pontos (representando linhas de sorriso) para rotacioná-los a partir dos seus eixos de gravidade e normalizá-los, facilitando comparações posteriores.
2. **Estimativas da aderência**: Realiza operações adicionais, como combinar pontos de diferentes curvas e calcular a medidas de aderência (distância euclidiana) entre os pontos de referência.
3. **Bootstrap e Análise Estatística**: Aplica o método bootstrap para obtenção do intervalo de confiança para a estatística de aderência e gera visualizações correspondentes.

### Como Rodar o Script em R
Para utilizar este script em R:
1. Clone o repositório para seu ambiente local.
2. Instale as bibliotecas R necessárias.
3. Carregue o script no seu ambiente R e execute. O código está preparado para processar imagens e realizar comparações detalhadas das características dos sorrisos.

### Link para o Artigo Científico
O artigo pode ser acessado através deste [link](https://www.sciencedirect.com/science/article/pii/S0379073822001153). Recomendamos a leitura do artigo para um entendimento completo da metodologia e dos fundamentos teóricos que embasam este código.

### Autoria
Este trabalho foi desenvolvido em conjunto por Carlo Ralph De Musis e Gabriel Chaves, da POLITEC/MT.
