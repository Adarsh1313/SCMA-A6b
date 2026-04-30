# Stock Volatility (GARCH) and Commodity Price Cointegration (VECM)

> Two-part time-series project: a GARCH(1,1) model for forecasting Jupiter Wagons stock-return volatility, and a Johansen cointegration + VECM analysis on World Bank monthly commodity prices to capture long-run equilibrium relationships across markets.

---

## Problem Statement

Two questions, one project. **Part A:** stock returns aren't homoskedastic — periods of calm cluster together and so do periods of turbulence, which is exactly what a GARCH model is designed to capture. The question is how variable Jupiter Wagons' returns will be over the next three months. **Part B:** commodity prices (oil, gold, silver, etc.) move together over the long run because they share macroeconomic drivers, even if they wander apart day-to-day. The question is whether a VECM — which explicitly models that long-run equilibrium and short-run adjustment back to it — fits the data, and what its forecasts look like.

---

## Dataset

| Property | Detail |
|----------|--------|
| Source | **Part A:** Jupiter Wagons Ltd. daily prices via `quantmod::getSymbols` from Yahoo Finance (`JWL.BO`, 2021-04-01 to 2024-03-31). **Part B:** World Bank Pink Sheet commodity prices, monthly, sheet "Monthly Prices" of `CMO-Historical-Data-Monthly.xlsx`. |
| Size | **Part A:** ~3 years of daily closes converted to log-returns. **Part B:** Monthly prices over decades; this analysis uses 5 selected commodities. |
| Key Features | **Part A:** Log returns (× 100). **Part B:** Five commodity price columns (e.g. crude oil, sugar, gold, silver, wheat / soybean). |
| Target Variable | **Part A:** Forecasted volatility (σ) for the next 63 trading days. **Part B:** 24-month-ahead joint forecast of all five commodity prices. |

---

## Methodology

**Part A — Volatility forecasting (GARCH):**

1. Pull daily closes for `JWL.BO` from Yahoo Finance and convert to percentage log returns.
2. **Ljung-Box test on squared returns** (lag = 10) to confirm there are ARCH effects worth modelling — i.e., that volatility is autocorrelated, not random.
3. **Specify a GARCH(1,1)** with mean ARMA(0,0) and a Student-t innovation distribution (heavier tails than normal — a better fit for return data).
4. **Fit and diagnose** the GARCH using `rugarch::ugarchfit`.
5. **Forecast σ** 63 trading days ahead (≈ 3 months) using `ugarchforecast`.

**Part B — Multi-commodity cointegration (VECM):**

1. Load the World Bank Monthly Prices sheet and parse the date column into `Date`.
2. Select 5 commodity columns and clean the names (`janitor::clean_names`).
3. **Run the Augmented Dickey-Fuller test** on each series to confirm non-stationarity (a precondition for cointegration analysis).
4. **Choose the VAR lag length** using `VARselect` with AIC.
5. **Run the Johansen cointegration test** (`urca::ca.jo`, eigenvalue test, transitory specification) and read off the cointegration rank — three cointegrating vectors were found.
6. **Estimate the VECM** (`cajorls`) using the chosen rank.
7. **Convert to a VAR-in-levels representation** with `vec2var` and forecast 24 months ahead.

---

## Results

The Ljung-Box test on squared returns rejects the no-ARCH-effects null, so the GARCH model is the right tool. Three cointegrating relationships were detected among the five commodity series — there is genuine long-run shared structure across these markets, not just spurious correlation.

<!-- Metrics source: notebook outputs / project_report.pdf -->

| Metric | Score | What It Means |
|--------|-------|---------------|
| Ljung-Box (lag 10) on squared returns | Significant — rejects no-ARCH | Volatility is autocorrelated; a constant-variance model is wrong; GARCH is justified. |
| GARCH(1,1) fit (Student-t) | See notebook for full outputs - results are embedded in cell outputs below each code block. | Model passes diagnostic checks and is used for the 63-day σ forecast. |
| Cointegration rank (Johansen, eigenvalue test) | r = 3 | Three independent long-run equilibrium relationships exist among the 5 commodity series — strong evidence for using VECM rather than a plain VAR. |
| 24-month VECM forecast | See notebook | Joint multi-step forecast of all 5 commodity prices, anchored to the estimated long-run equilibria. |

---

## Key Findings

- **Volatility clustering is real and tradable.** The Ljung-Box result on squared returns means a constant-variance assumption (e.g. plain Black-Scholes pricing or unweighted historical VaR) systematically misstates risk for this stock.
- **Student-t innovations matter for return data.** Stock returns have fatter tails than the normal distribution; a GARCH-normal model would understate the probability of large moves.
- **The five commodities share three long-run equilibria.** This is more structure than a casual look at the price charts suggests, and it's what justifies forecasting them jointly with VECM rather than independently.

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| R | Primary analysis language. |
| quantmod | `getSymbols` to pull Jupiter Wagons price history from Yahoo Finance. |
| rugarch | GARCH(1,1) specification, fitting (`ugarchfit`), and forecasting (`ugarchforecast`). |
| tseries | `Box.test` for the Ljung-Box ARCH-effects diagnostic. |
| urca | `ur.df` (Augmented Dickey-Fuller) and `ca.jo` (Johansen cointegration). |
| vars | `VARselect`, `vec2var`, and `predict` for the VECM-as-VAR forecast. |
| readxl, janitor | Loading and cleaning the World Bank commodity sheet. |
| ggplot2 | Plotting returns and forecasted volatility. |
| Python 3.x | Parallel implementation in the `.ipynb` (statsmodels + arch package equivalents). |

---

## How to Run

R version:

```bash
git clone https://github.com/Adarsh1313/SCMA-A6b
cd SCMA-A6b
Rscript packages.R
Rscript garch_vecm_volatility_analysis.R
```

Python version:

```bash
pip install -r requirements.txt
jupyter notebook garch_vecm_volatility_analysis.ipynb
```

---

## Future Scope

- Compare GARCH(1,1) against EGARCH or GJR-GARCH, which model the leverage effect (negative shocks producing more volatility than positive shocks of equal size).
- Backtest the volatility forecast as a Value-at-Risk input — that's where this kind of model actually earns its keep.
- Extend the cointegration analysis to a larger panel of commodities and test for sub-group equilibria (energy vs metals vs grains) instead of treating all five as one system.
- Add impulse-response functions to the VECM so you can read off how a shock to oil propagates through the other commodities over time.
