encoding <- getOption("shiny.site.encoding", default = "UTF-8")

inclRmd <- function(path, r_env = parent.frame()) {
  paste(
    readLines(path, warn = FALSE, encoding = encoding),
    collapse = '\n'
  ) %>%
    knitr::knit2html(
      text = .,
      fragment.only = TRUE,
      envir = r_env,
      options = "",
      stylesheet = "",
      encoding = encoding
    ) %>%
    gsub("&lt;!--/html_preserve--&gt;","",.) %>%  ## knitr adds this
    gsub("&lt;!--html_preserve--&gt;","",.) %>%   ## knitr adds this
    HTML
}

#From https://github.com/vnijs/shiny-site