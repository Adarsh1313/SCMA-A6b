# R package dependencies for the GARCH + VECM analysis
# Run once: Rscript packages.R
packages <- c(
  "quantmod",   # getSymbols() for Yahoo Finance pull
  "tseries",    # Box.test (Ljung-Box) for ARCH-effects diagnostic
  "rugarch",    # GARCH(1,1) specification, fit, and forecast
  "ggplot2",    # plotting
  "readxl",     # World Bank commodity .xlsx
  "dplyr",      # data manipulation
  "janitor",    # clean_names() for the commodity columns
  "urca",       # ur.df (ADF) and ca.jo (Johansen cointegration)
  "vars"        # VARselect, vec2var, and forecast helpers
)
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}
