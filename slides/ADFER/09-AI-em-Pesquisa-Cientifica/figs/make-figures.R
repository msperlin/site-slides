# make-figures.R
# ------------------------------------------------------------------
# Generates the diagrams used in "Using Agentic AI for Research".
# Reproducible: run `Rscript figs/make-figures.R` to rebuild every
# figure as SVG (crisp, for slides) and PNG (portable, for embedding).
# Requires only base R + grid (no external packages).
# ------------------------------------------------------------------

library(grid)

dir.create("figs", showWarnings = FALSE)

# --- palette (matches theme-msperlin.scss) -------------------------
pal <- list(
  red   = "#FF4242",
  blue  = "#1667C4",
  teal  = "#27A5A2",
  dteal = "#009491",
  green = "#3CBFAE",
  ink   = "#2B2B2B",
  muted = "#64748B",
  line  = "#C3CFDB",
  box   = "#F4F7FA",
  blue2 = "#E7F1FC",
  teal2 = "#E4F5F4",
  red2  = "#FDE9E9",
  green2= "#E7F7F3"
)
FONT <- "Ubuntu"

Y <- function(y) 1 - y  # top-left origin helper

box <- function(x, y, w, h, label, fill = pal$box, border = pal$line,
                col = pal$ink, fs = 12, face = "bold", r = 0.05, lwd = 1.3) {
  grid.roundrect(x = unit(x, "npc"), y = unit(Y(y), "npc"),
                 width = unit(w, "npc"), height = unit(h, "npc"),
                 r = unit(r, "npc"),
                 gp = gpar(fill = fill, col = border, lwd = lwd))
  grid.text(label, x = unit(x, "npc"), y = unit(Y(y), "npc"),
            gp = gpar(col = col, fontsize = fs, fontface = face,
                      fontfamily = FONT, lineheight = 1.05))
}

arr <- function(x0, y0, x1, y1, col = pal$muted, lwd = 2.2, len = 0.11) {
  grid.lines(unit(c(x0, x1), "npc"), unit(Y(c(y0, y1)), "npc"),
             arrow = arrow(type = "closed", length = unit(len, "inches")),
             gp = gpar(col = col, lwd = lwd, fill = col, lineend = "round"))
}

seg <- function(x, y, col = pal$muted, lwd = 2.2, lty = 1) {
  grid.lines(unit(x, "npc"), unit(Y(y), "npc"),
             gp = gpar(col = col, lwd = lwd, lty = lty, lineend = "round"))
}

txt <- function(x, y, label, col = pal$ink, fs = 11, face = "plain",
                just = "centre", rot = 0) {
  grid.text(label, x = unit(x, "npc"), y = unit(Y(y), "npc"),
            gp = gpar(col = col, fontsize = fs, fontface = face,
                      fontfamily = FONT, lineheight = 1.05),
            just = just, rot = rot)
}

dot <- function(x, y, r = 0.013, fill = pal$blue) {
  grid.circle(x = unit(x, "npc"), y = unit(Y(y), "npc"),
              r = unit(r, "npc"), gp = gpar(fill = fill, col = "white", lwd = 1.5))
}

make_fig <- function(name, w = 10, h = 5.6, draw) {
  svg(file.path("figs", paste0(name, ".svg")), width = w, height = h, bg = "white")
  draw()
  dev.off()
  png(file.path("figs", paste0(name, ".png")), width = w, height = h,
      units = "in", res = 200, bg = "white")
  draw()
  dev.off()
  cat("wrote figs/", name, ".{svg,png}\n", sep = "")
}

# ==================================================================
# 1. The agent loop
# ==================================================================
draw_agent_loop <- function() {
  cx <- 0.5; cy <- 0.53; rx <- 0.335; ry <- 0.335
  a <- -90 + 72 * (0:4)
  px <- cx + rx * cos(a * pi / 180)
  py <- cy + ry * sin(a * pi / 180)
  labs <- c("1. GOAL\n(you set it)", "2. PLAN", "3. ACT\n(run tools)",
            "4. OBSERVE\n(results / errors)", "5. REFLECT\n(adjust)")
  fills <- c(pal$blue2, pal$box, pal$teal2, pal$box, pal$box)
  for (i in 1:5) box(px[i], py[i], 0.30, 0.125, labs[i], fill = fills[i], fs = 11.5)
  for (i in 1:5) {
    j <- i %% 5 + 1
    arr(px[i] + 0.44 * (px[j] - px[i]), py[i] + 0.44 * (py[j] - py[i]),
        px[i] + 0.82 * (px[j] - px[i]), py[i] + 0.82 * (py[j] - py[i]),
        col = pal$teal, lwd = 2.6)
  }
  txt(cx, cy, "AGENT\nLOOP", col = pal$red, fs = 16, face = "bold")
  txt(cx, 0.075, "An LLM + tools + a feedback loop", fs = 14, face = "bold")
  txt(cx, 0.945, "Human in the loop: review, approve, commit",
      fs = 11, face = "italic", col = pal$muted)
}

# ==================================================================
# 2. Chatbot vs. agent
# ==================================================================
draw_chat_vs_agent <- function() {
  seg(c(0.5, 0.5), c(0.06, 0.94), col = pal$line, lwd = 1, lty = 2)

  # --- left: chatbot ---
  txt(0.25, 0.055, "CHATBOT  \u2014  you are the glue", col = pal$red,
      fs = 13, face = "bold")
  box(0.25, 0.20, 0.34, 0.12, "You", fill = pal$blue2, border = pal$blue, fs = 12)
  box(0.25, 0.49, 0.34, 0.14, "Chat window\n(LLM)", fill = pal$box, fs = 12)
  box(0.25, 0.78, 0.34, 0.12, "Text answer", fill = pal$box, fs = 12)
  arr(0.25, 0.265, 0.25, 0.415, col = pal$muted)
  txt(0.28, 0.34, "paste code", fs = 10, col = pal$muted, just = "left")
  arr(0.145, 0.55, 0.145, 0.71, col = pal$muted)
  txt(0.12, 0.63, "copy answer", fs = 10, col = pal$muted, just = "right")

  # --- right: agent ---
  txt(0.75, 0.055, "AGENT  \u2014  it works in your project", col = pal$green,
      fs = 13, face = "bold")
  box(0.75, 0.17, 0.38, 0.11, "You (supervise)", fill = pal$green2,
      border = pal$green, fs = 12)
  box(0.75, 0.47, 0.40, 0.18, "Agent  (opencode)\nreads \u00b7 writes \u00b7 runs commands",
      fill = pal$teal2, border = pal$dteal, fs = 11.5)
  box(0.75, 0.81, 0.40, 0.14, "Your repository\ncode + data + git history",
      fill = pal$blue2, border = pal$blue, fs = 11.5)
  # left side (down): instruct, acts
  arr(0.64, 0.23, 0.64, 0.375, col = pal$green)
  txt(0.615, 0.30, "instruct", fs = 10, col = pal$green, just = "right")
  arr(0.64, 0.565, 0.64, 0.735, col = pal$dteal)
  txt(0.615, 0.65, "acts", fs = 10, col = pal$dteal, just = "right")
  # right side (up): results, review
  arr(0.86, 0.735, 0.86, 0.565, col = pal$dteal)
  txt(0.885, 0.65, "results", fs = 10, col = pal$dteal, just = "left")
  arr(0.86, 0.375, 0.86, 0.23, col = pal$green)
  txt(0.885, 0.30, "review", fs = 10, col = pal$green, just = "left")
}

# ==================================================================
# 3. Levels of autonomy
# ==================================================================
draw_autonomy <- function() {
  txt(0.5, 0.06, "Levels of autonomy", fs = 15, face = "bold")
  txt(0.10, 0.93, "Human control", fs = 10.5, face = "italic", col = pal$blue,
      just = "left")
  txt(0.90, 0.93, "Agent autonomy", fs = 10.5, face = "italic", col = pal$red,
      just = "right")
  rows <- data.frame(
    y    = c(0.19, 0.345, 0.50, 0.655, 0.81),
    w    = c(0.30, 0.44, 0.58, 0.72, 0.86),
    lab  = c("Suggest", "Chat", "Tool use", "Supervised autonomy", "Full autonomy"),
    desc = c("autocomplete hints", "answers your questions",
             "calls files / code / search", "multi-step, you approve each step",
             "end-to-end in a sandbox"),
    fill = c("#DCEBFB", "#CFE6F7", "#BFEDE8", "#FBD9D9", "#F6BFBF"),
    stringsAsFactors = FALSE
  )
  for (i in seq_len(nrow(rows))) {
    r <- rows[i, ]
    grid.roundrect(x = unit(0.10 + r$w / 2, "npc"), y = unit(Y(r$y), "npc"),
                   width = unit(r$w, "npc"), height = unit(0.135, "npc"),
                   r = unit(0.05, "npc"),
                   gp = gpar(fill = r$fill, col = "white", lwd = 0))
    txt(0.135, r$y - 0.024, r$lab, fs = 11.5, face = "bold", just = "left")
    txt(0.135, r$y + 0.030, r$desc, fs = 9.5, col = pal$muted, just = "left")
  }
}

# ==================================================================
# 4. Git branching
# ==================================================================
draw_git_branch <- function() {
  txt(0.5, 0.06, "Git: branching = safe experiments", fs = 15, face = "bold")
  ym <- 0.66; yb <- 0.34
  xm <- c(0.10, 0.28, 0.46, 0.74, 0.90)
  ml <- c("init", "add data", "baseline", "merge", "results")
  seg(c(0.10, 0.90), c(ym, ym), col = pal$ink, lwd = 2.6)
  arr(0.46, ym, 0.56, yb, col = pal$ink, lwd = 2.6)
  seg(c(0.56, 0.66), c(yb, yb), col = pal$ink, lwd = 2.6)
  arr(0.66, yb, 0.74, ym, col = pal$ink, lwd = 2.6)
  for (x in xm) dot(x, ym)
  dot(0.56, yb); dot(0.66, yb)
  txt(0.10, 0.575, "main", fs = 11, face = "bold", col = pal$blue, just = "left")
  txt(0.61, 0.235, "experiment-01", fs = 11, face = "bold", col = pal$teal)
  for (i in seq_along(xm)) txt(xm[i], ym + 0.12, ml[i], fs = 9.5, col = pal$muted)
  txt(0.56, yb + 0.10, "try model B", fs = 9.5, col = pal$muted, just = "right")
  txt(0.66, yb + 0.10, "fix bug", fs = 9.5, col = pal$muted, just = "left")
  txt(0.5, 0.93, "Commit before every experiment \u2014 you can always undo or abandon a branch",
      fs = 10.5, face = "italic", col = pal$muted)
}

# ==================================================================
# 5. AGENTS.md scope
# ==================================================================
draw_agents_md <- function() {
  txt(0.5, 0.06, "AGENTS.md: persistent instructions for the agent",
      fs = 14.5, face = "bold")
  ys <- c(0.28, 0.50, 0.72)
  labs <- c("GLOBAL\n~/.config/opencode/AGENTS.md",
            "PROJECT\n./AGENTS.md",
            "NESTED\nsubfolder/AGENTS.md")
  fills <- c(pal$box, pal$blue2, pal$box)
  bords <- c(pal$line, pal$blue, pal$line)
  for (i in 1:3) {
    box(0.19, ys[i], 0.30, 0.145, labs[i], fill = fills[i],
        border = bords[i], fs = 10.5)
    arr(0.35, ys[i], 0.44, 0.50, col = pal$muted, len = 0.10)
  }
  box(0.55, 0.50, 0.20, 0.16, "Agent\n(opencode)", fill = pal$teal2,
      border = pal$dteal, fs = 12)
  box(0.84, 0.50, 0.24, 0.16, "Your repository\ncode \u00b7 data \u00b7 history",
      fill = pal$green2, border = pal$green, fs = 11)
  arr(0.65, 0.46, 0.72, 0.46, col = pal$dteal)
  arr(0.72, 0.54, 0.65, 0.54, col = pal$green)
  txt(0.5, 0.90, "The most specific file wins \u2014 keep every one short and current",
      fs = 10.5, face = "italic", col = pal$muted)
}

# ==================================================================
# 6. Agentic research workflow
# ==================================================================
draw_workflow <- function() {
  txt(0.5, 0.06, "The agentic research workflow", fs = 15, face = "bold")
  steps <- c("1. Create\nrepository", "2. Write\nAGENTS.md", "3. Commit\nbaseline",
             "4. Ask for\na plan", "5. Implement\nin small steps", "6. Review\nthe diff",
             "7. Run &\nverify", "8. Commit\n+ log prompt")
  fills <- c(pal$blue2, pal$teal2, pal$box, pal$box,
             pal$box, pal$box, pal$green2, pal$blue2)
  bords <- c(pal$blue, pal$dteal, pal$line, pal$line,
             pal$line, pal$line, pal$green, pal$blue)
  xs <- c(0.16, 0.38, 0.60, 0.82)
  y1 <- 0.27; y2 <- 0.66
  for (i in 1:4) {
    box(xs[i], y1, 0.185, 0.155, steps[i], fill = fills[i], border = bords[i], fs = 11)
    box(rev(xs)[i], y2, 0.185, 0.155, steps[4 + i], fill = fills[4 + i],
        border = bords[4 + i], fs = 11)
  }
  for (i in 1:3) arr(xs[i] + 0.10, y1, xs[i + 1] - 0.10, y1, col = pal$muted, len = 0.09)
  # row 2 runs right-to-left (snake); arrows point leftwards
  xr <- rev(xs)
  for (i in 1:3) arr(xr[i] - 0.10, y2, xr[i + 1] + 0.10, y2, col = pal$muted, len = 0.09)
  # connector from step 4 (row 1) down to step 5 (row 2, directly below)
  arr(0.82, 0.355, 0.82, 0.58, col = pal$muted, len = 0.09)
  txt(0.5, 0.90, "You stay in control: approve each step and keep every change in Git",
      fs = 10.5, face = "italic", col = pal$muted)
}

# --- build all -----------------------------------------------------
make_fig("fig_agent_loop",      w = 10, h = 5.6, draw_agent_loop)
make_fig("fig_chat_vs_agent",   w = 10, h = 5.2, draw_chat_vs_agent)
make_fig("fig_autonomy",        w = 10, h = 5.0, draw_autonomy)
make_fig("fig_git_branch",      w = 10, h = 4.6, draw_git_branch)
make_fig("fig_agents_md",       w = 10, h = 4.6, draw_agents_md)
make_fig("fig_workflow",        w = 10, h = 5.2, draw_workflow)
