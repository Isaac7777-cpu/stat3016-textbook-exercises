library(ggplot2)

bates_pdf <- function(x, n) {
    if (n == 1) {
        return(rep(1, length(x))) # Uniform(0,1)
    }
    f <- rep(0, length(x))
    for (k in 0:n) {
        term <- (-1)^k * choose(n, k) * pmax(x - k, 0)^(n - 1)
        f <- f + term
    }
    f / factorial(n - 1)
}

x_vals <- seq(0, 1, length.out = 1000)
n_vals <- c(1, 2, 3, 4, 5, 8, 16)

pdf_data <- data.frame()
for (n in n_vals) {
    y_vals <- n * bates_pdf(n * x_vals, n)
    pdf_data <- rbind(pdf_data, data.frame(x = x_vals, y = y_vals, n = factor(n)))
}

# Add the normal approximation for n = 16
normal_approx <- data.frame(
    x = x_vals,
    y = dnorm(x_vals, mean = 0.5, sd = sqrt(1 / (12 * 16))),
    n = "Normal Approx (n=16)"
)

pdf_data <- rbind(pdf_data, normal_approx)

bates_plot <- ggplot(pdf_data, aes(x = x, y = y, color = n)) +
    geom_line(size = 1) +
    labs(
        title = "Bates Distributions vs Normal Approximation",
        x = "x",
        y = "Density",
        color = "n"
    ) +
    theme_minimal()
