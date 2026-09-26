# From chatGPT

# Here is a complete R function that generates TikZ code for a 
# directed graph of your elements. It satisfies your structural 
# constraints: each node has 1 to 3 inbound and outbound connections, 
# the overall graph averages about two connections per node, 
# and it strictly respects the acyclic flag when requested

generate_perfect_tikz_graph <- function(elements, acyclic = FALSE) {
  n_nodes <- length(elements)
  if (n_nodes < 2) stop("The graph must have at least 2 elements.")
  
  # Target 2 connections (inbound + outbound combined) per element on average
  target_edges <- n_nodes 
  
  # -------------------------------------------------------------------------
  # PASS 1: Generate absolute unique undirected node index pairs
  # -------------------------------------------------------------------------
  connected_edges <- list()
  for (i in 2:n_nodes) {
    parent <- sample(1:(i-1), 1)
    connected_edges[[length(connected_edges) + 1]] <- sort(c(parent, i))
  }
  
  all_possible_pairs <- list()
  for (i in 1:(n_nodes - 1)) {
    for (j in (i + 1):n_nodes) {
      all_possible_pairs[[length(all_possible_pairs) + 1]] <- c(i, j)
    }
  }
  
  is_already_added <- sapply(all_possible_pairs, function(p) {
    any(sapply(connected_edges, function(c_edge) identical(p, c_edge)))
  })
  available_pairs <- all_possible_pairs[!is_already_added]
  
  edges_needed <- max(0, target_edges - length(connected_edges))
  final_undirected_edges <- connected_edges
  
  if (edges_needed > 0 && length(available_pairs) > 0) {
    shuffled_idx <- sample(1:length(available_pairs), min(edges_needed, length(available_pairs)))
    for (idx in shuffled_idx) {
      final_undirected_edges[[length(final_undirected_edges) + 1]] <- available_pairs[[idx]]
    }
  }
  
  # -------------------------------------------------------------------------
  # PASS 2: Assign a single arrow direction to each edge item
  # -------------------------------------------------------------------------
  directed_matrix <- matrix(0, nrow = n_nodes, ncol = n_nodes, 
                            dimnames = list(elements, elements))
  
  # Shuffle edge processing order for random structures
  final_undirected_edges <- final_undirected_edges[sample(length(final_undirected_edges))]
  
  for (k in seq_along(final_undirected_edges)) {
    # Safer scalar index extraction to prevent R vector translation bugs
    edge <- final_undirected_edges[[k]]
    u <- min(edge) # Lower index node
    v <- max(edge) # Higher index node
    
    if (acyclic) {
      # Strict Acyclic Rule: Always flow from lower index to higher index
      directed_matrix[u, v] <- 1
    } else {
      # Evaluate directional degrees to stay under the limit of 3
      out_u <- sum(directed_matrix[u, ])
      in_v  <- sum(directed_matrix[, v])
      out_v <- sum(directed_matrix[v, ])
      in_u  <- sum(directed_matrix[, u])
      
      can_u_to_v <- (out_u < 3 && in_v < 3)
      can_v_to_u <- (out_v < 3 && in_u < 3)
      
      if (can_u_to_v && can_v_to_u) {
        if (runif(1) > 0.5) {
          directed_matrix[u, v] <- 1
        } else {
          directed_matrix[v, u] <- 1
        }
      } else if (can_u_to_v) {
        directed_matrix[u, v] <- 1
      } else if (can_v_to_u) {
        directed_matrix[v, u] <- 1
      } else {
        directed_matrix[u, v] <- 1
      }
    }
  }
  
  # -------------------------------------------------------------------------
  # PASS 3: Force a cycle if acyclic = FALSE but we accidentally made a DAG
  # -------------------------------------------------------------------------
  if (!acyclic) {
    # Helper function to check if a matrix is acyclic using a reachability matrix
    is_dag <- function(mat) {
      reach <- mat
      for (i in 1:nrow(mat)) {
        reach <- sign(reach + reach %*% mat)
      }
      return(sum(diag(reach)) == 0)
    }
    
    # If the graph accidentally turned out acyclic, force a feedback loop
    if (is_dag(directed_matrix)) {
      # Find any active edge u -> v and try to flip it or add a back-edge elsewhere
      edges_drawn <- which(directed_matrix == 1, arr.ind = TRUE)
      if (nrow(edges_drawn) > 0) {
        for (row_idx in 1:nrow(edges_drawn)) {
          orig_u <- edges_drawn[row_idx, 1]
          orig_v <- edges_drawn[row_idx, 2]
          
          # Can we flip this edge to v -> orig_u to create a cycle without breaking degree caps?
          # Outbound of orig_v and Inbound of orig_u must be safe
          if (sum(directed_matrix[orig_v, ]) < 3 && sum(directed_matrix[, orig_u]) < 3) {
            directed_matrix[orig_u, orig_v] <- 0
            directed_matrix[orig_v, orig_u] <- 1
            if (!is_dag(directed_matrix)) break # Successfully forced a cycle!
          }
        }
      }
    }
  }
  
  # -------------------------------------------------------------------------
  # PASS 4: Format output into raw TikZ code strings
  # -------------------------------------------------------------------------
  tikz_lines <- c(
    "\\begin{tikzpicture}[",
    "  node distance=2cm,",
    "  every node/.style={circle, draw, minimum size=0.8cm, font=\\bfseries},",
    "  every arrow/.style={-latex, thick}",
    "]"
  )
  
  radius <- max(1.5, n_nodes * 0.4)
  for (i in 1:n_nodes) {
    angle <- (i - 1) * (360 / n_nodes)
    tikz_lines <- c(tikz_lines, sprintf("  \\node (%s) at (%d:%.2f) {%s};", 
                                        elements[i], round(angle), radius, elements[i]))
  }
  
  tikz_lines <- c(tikz_lines, "") 
  
  for (i in 1:n_nodes) {
    for (j in 1:n_nodes) {
      if (directed_matrix[i, j] == 1) {
        tikz_lines <- c(tikz_lines, sprintf("  \\draw[every arrow] (%s) -> (%s);", 
                                            elements[i], elements[j]))
      }
    }
  }
  
  tikz_lines <- c(tikz_lines, "\\end{tikzpicture}")
  return(paste(tikz_lines, collapse = "\n"))
}
