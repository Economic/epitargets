library(hexSticker)
library(ggplot2)
library(ggraph)
library(igraph)
library(showtext)

font_add_google("Cormorant Garamond", "CormorantGaramond")
showtext_auto()
showtext_opts(dpi = 600)

# Fake pipeline: 4 columns, 3 rows
# Col A: A2, A3, A4 (rows 2-4)
# Col B: B1, B2, B3 (rows 1-3)
# Col C: C1, C2, C3 (rows 1-3)
# Col D: D2, D3 (rows 2-3)
edges <- data.frame(
  from = c("A2", "A2", "A3", "B1", "B2", "B2", "B3", "C1", "C2", "C3", "C3"),
  to = c("B1", "B2", "B3", "C1", "C2", "C3", "C3", "D2", "D2", "D2", "D3")
)

g <- graph_from_data_frame(edges, directed = TRUE)

# DAG colors: highlight certain nodes/edges
highlight_nodes <- c("A3", "B3", "C3", "D3", "D2")
highlight_edges <- c("A3|B3", "B3|C3", "C3|D3", "C3|D2")

V(g)$node_col <- ifelse(V(g)$name %in% highlight_nodes, "#fed6c2", "#f1897c")

edge_keys <- paste(ends(g, E(g))[, 1], ends(g, E(g))[, 2], sep = "|")
E(g)$edge_col <- ifelse(edge_keys %in% highlight_edges, "#fed6c2", "#f1897c")

# Use sugiyama for column (layer) assignment, but set rows from node names
layout <- create_layout(g, layout = "sugiyama")
orig_y <- layout$y # layer = column
row_num <- as.numeric(gsub("[A-Z]", "", layout$name))
layout$x <- -orig_y # columns flow left-to-right
layout$y <- -row_num * 0.75 # compress rows vertically

subplot <- ggraph(layout) +
  geom_edge_link(
    aes(edge_colour = .data$edge_col),
    arrow = arrow(length = unit(1, "mm"), type = "open"),
    end_cap = circle(2, "mm"),
    start_cap = circle(2, "mm"),
    edge_width = 0.3,
  ) +
  scale_edge_colour_identity() +
  geom_node_point(aes(color = .data$node_col), size = 2, shape = 16) +
  scale_color_identity() +
  annotate(
    "text",
    x = mean(range(layout$x)),
    y = min(layout$y) - 0.85,
    label = "EPITARGETS",
    size = 6.5,
    family = "CormorantGaramond",
    fontface = "bold",
    color = "white",
    hjust = 0.5,
    vjust = 0.5
  ) +
  scale_x_continuous(expand = expansion(mult = 0.25)) +
  scale_y_continuous(expand = expansion(mult = c(0.5, 0.35))) +
  coord_cartesian(clip = "off") +
  theme_void() +
  theme_transparent()

sticker(
  subplot,
  package = "",
  p_x = 1,
  p_y = 1,
  p_size = 0,
  p_color = "white",
  p_family = "CormorantGaramond",
  p_fontface = "bold",
  s_x = 1.0,
  s_y = 1.1,
  s_width = 1.6,
  s_height = 1.5,
  h_fill = "#c1183e",
  h_color = "#82112c",
  h_size = 1.4,
  url = "",
  filename = here::here("man", "figures", "logo.png"),
  dpi = 600
)
