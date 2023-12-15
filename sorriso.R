library(boot)
library(ggplot2)
library(dplyr)

# Função para rotacionar e normalizar um dataframe com colunas x e y
rotate_and_normalize_data <- function(df) {
  x <- df$x
  y <- df$y
  
  # Realizar a regressão linear
  model <- lm(y ~ x)
  slope <- coef(model)[2]
  
  # Calcular o ângulo de rotação
  angle <- -atan(slope)
  
  # Função para rotacionar os pontos
  rotate_points <- function(x, y, angle) {
    x_rot <- x * cos(angle) - y * sin(angle)
    y_rot <- x * sin(angle) + y * cos(angle)
    cbind(x_rot, y_rot)
  }
  
  # Aplicar a rotação
  xy_rotated <- t(apply(cbind(x, y), 1, function(row) rotate_points(row[1], row[2], angle)))
  
  # Normalizar os pontos rotacionados
  normalize <- function(v) {
    (v - min(v)) / (max(v) - min(v))
  }
  xy_rotated_normalized <- apply(xy_rotated, 2, normalize)
  
  # Retornar um novo dataframe com os pontos rotacionados e normalizados
  data.frame(x = xy_rotated_normalized[, 1], y = xy_rotated_normalized[, 2])
}

# Dados originais
dados <- data.frame(
  curva = c(rep(1, 11), rep(2, 11)),
  ponto = c(seq(1, 11), seq(1, 11)),
  x = c(75, 107, 173, 208, 238, 282, 311, 342, 444, 467, 522,
        132, 140, 211, 231, 247, 326, 345, 345, 454, 461, 562),
  y = c(306, 242, 247, 293, 247, 238, 243, 193, 175, 218, 182,
        114, 94, 94, 111, 93, 86, 103, 63, 39, 66, 24)
)

# Espelhar os valores de y
ymax <- max(dados$y)
dados$y <- ymax - dados$y

# Aplicar a função de rotação e normalização em 1
dados_rot_norm_1 <- rotate_and_normalize_data(dados[dados$curva==1,])

# Adicionar colunas curva e ponto ao dataframe rotacionado e normalizado
dados_rot_norm_1$curva <- dados[dados$curva==1,]$curva
dados_rot_norm_1$ponto <- dados[dados$curva==1,]$ponto

# Aplicar a função de rotação e normalização em 2
dados_rot_norm_2 <- rotate_and_normalize_data(dados[dados$curva==2,])

# Adicionar colunas curva e ponto ao dataframe rotacionado e normalizado
dados_rot_norm_2$curva <- dados[dados$curva==2,]$curva
dados_rot_norm_2$ponto <- dados[dados$curva==2,]$ponto

dados_rot_norm <- rbind(dados_rot_norm_1, dados_rot_norm_2)

# Criar o gráfico de dispersão com os dados rotacionados e normalizados
ggplot(dados_rot_norm, aes(x = x, y = y, group = curva, color = factor(curva))) +
  geom_line() +
  geom_point() +
  geom_text(aes(label = ponto), nudge_y = 0.05, check_overlap = TRUE) +
  scale_color_manual(values = c("blue", "red")) +
  theme_minimal() +
  labs(color = "Curva")

# Em seguida, realizamos um join para combinar os pontos correspondentes das duas curvas
df_combinado <- inner_join(dados_rot_norm_1, dados_rot_norm_2, by = "ponto", suffix = c("_1", "_2"))

# Função para calcular a distância euclidiana
distancia_euclidiana <- function(x1, y1, x2, y2) {
  sqrt((x2 - x1)^2 + (y2 - y1)^2)
}

# Aplicamos a função para calcular as distâncias
df_distancias <- df_combinado %>%
  mutate(distancia = distancia_euclidiana(x_1, y_1, x_2, y_2)) %>%
  select(ponto, distancia)
df_distancias$distancia <-  -df_distancias$distancia + 1

# Função para calcular a média
media_bootstrap <- function(data, indices) {
  # Amostra bootstrap
  amostra <- data[indices, ]
  # Calcular e retornar a média
  mean(amostra$distancia)
}

# Aplicar o método bootstrap
resultado_bootstrap <- boot(data = df_distancias, statistic = media_bootstrap, R = 10000)

# Calcular a média das médias bootstrap
media_bootstrap <- resultado_bootstrap$t0

# Calcular o intervalo de confiança de 95%
intervalo_confianca <- boot.ci(resultado_bootstrap, type = "perc")

# Extrair os limites do intervalo de confiança
limite_inferior <- intervalo_confianca$percent[4]
limite_superior <- intervalo_confianca$percent[5]

# Criar um dataframe com as médias bootstrap
df_medias_bootstrap <- data.frame(medias = resultado_bootstrap$t)

# Gerar o histograma com ggplot2
p <- ggplot(df_medias_bootstrap, aes(x = medias)) +
  geom_histogram(binwidth = 0.005, fill = "skyblue", color = "black") +
  geom_vline(xintercept = limite_inferior, color = "red", linetype = "dashed") +
  geom_vline(xintercept = limite_superior, color = "red", linetype = "dashed") +
  geom_vline(xintercept = media_bootstrap, color = "blue", linetype = "dashed") +
  labs(title = "Histograma das Médias Bootstrap com Intervalo de Confiança",
       x = "Médias Bootstrap",
       y = "Frequência") +
  annotate("text", x = limite_inferior, y = Inf, label = paste("Lim. Inferior:", round(limite_inferior, 2)), vjust = 2, hjust = 1, color = "red") +
  annotate("text", x = limite_superior, y = Inf, label = paste(" Lim. Superior:", round(limite_superior, 2)), vjust = 2, hjust = 0, color = "red") +
  annotate("text", x = media_bootstrap, y = Inf, label = paste("Média:", round(media_bootstrap, 2)), vjust = 3, hjust = 1, color = "blue")
p
