###################################################
### chunk number 1: setup
###################################################
options(prompt = "R> ", continue = "+  ", width = 64,
        digits = 4, show.signif.stars = FALSE, useFancyQuotes = FALSE)

options(SweaveHooks = list(onefig =   function() {par(mfrow = c(1,1))},
                           twofig =   function() {par(mfrow = c(1,2))},
                           threefig = function() {par(mfrow = c(1,3))},
                           fourfig =  function() {par(mfrow = c(2,2))},
                           sixfig =   function() {par(mfrow = c(3,2))}))

library("AER")

suppressWarnings(RNGversion("3.5.0"))
set.seed(1071)


###################################################
### chunk number 2: data-journals
###################################################
data("Journals")
journals <- Journals[, c("subs", "price")]
journals$citeprice <- Journals$price/Journals$citations
summary(journals)


###################################################
### chunk number 3: linreg-plot eval=FALSE
###################################################
plot(log(subs) ~ log(citeprice), data = journals)
jour_lm <- lm(log(subs) ~ log(citeprice), data = journals)
abline(jour_lm)


###################################################
### chunk number 4: linreg-plot1
###################################################
plot(log(subs) ~ log(citeprice), data = journals)
jour_lm <- lm(log(subs) ~ log(citeprice), data = journals)
abline(jour_lm)


###################################################
### chunk number 5: linreg-class
###################################################
class(jour_lm)


###################################################
### chunk number 6: linreg-names
###################################################
names(jour_lm)


###################################################
### chunk number 7: linreg-summary
###################################################
summary(jour_lm)


###################################################
### chunk number 8: linreg-summary
###################################################
jour_slm <- summary(jour_lm)
class(jour_slm)
names(jour_slm)


###################################################
### chunk number 9: linreg-coef
###################################################
jour_slm$coefficients


###################################################
### chunk number 10: linreg-anova
###################################################
anova(jour_lm)


###################################################
### chunk number 11: journals-coef
###################################################
coef(jour_lm)


###################################################
### chunk number 12: journals-confint
###################################################
confint(jour_lm, level = 0.95)


###################################################
### chunk number 13: journals-predict
###################################################
predict(jour_lm, newdata = data.frame(citeprice = 2.11),
        interval = "confidence")
predict(jour_lm, newdata = data.frame(citeprice = 2.11),
        interval = "prediction")


###################################################
### chunk number 14: predict-plot eval=FALSE
###################################################
## lciteprice <- seq(from = -6, to = 4, by = 0.25)
## jour_pred <- predict(jour_lm, interval = "prediction",
##   newdata = data.frame(citeprice = exp(lciteprice)))
## plot(log(subs) ~ log(citeprice), data = journals)
## lines(jour_pred[, 1] ~ lciteprice, col = 1)
## lines(jour_pred[, 2] ~ lciteprice, col = 1, lty = 2)
## lines(jour_pred[, 3] ~ lciteprice, col = 1, lty = 2)


###################################################
### chunk number 15: predict-plot1
###################################################
lciteprice <- seq(from = -6, to = 4, by = 0.25)
jour_pred <- predict(jour_lm, interval = "prediction",
                     newdata = data.frame(citeprice = exp(lciteprice)))
plot(log(subs) ~ log(citeprice), data = journals)
lines(jour_pred[, 1] ~ lciteprice, col = 1)
lines(jour_pred[, 2] ~ lciteprice, col = 1, lty = 2)
lines(jour_pred[, 3] ~ lciteprice, col = 1, lty = 2)


###################################################
### chunk number 16: journals-plot eval=FALSE
###################################################
## par(mfrow = c(2, 2))
## plot(jour_lm)
## par(mfrow = c(1, 1))


###################################################
### chunk number 17: journals-plot1
###################################################
par(mfrow = c(2, 2))
plot(jour_lm)
par(mfrow = c(1, 1))


###################################################
### chunk number 18: journal-lht
###################################################
linearHypothesis(jour_lm, "log(citeprice) = -0.5")


###################################################
### chunk number 19: CPS-data
###################################################
data("CPS1988")
summary(CPS1988)


###################################################
### chunk number 20: CPS-base
###################################################
cps_lm <- lm(log(wage) ~ experience + I(experience^2) +
                   education + ethnicity, data = CPS1988)


###################################################
### chunk number 21: CPS-visualization-unused eval=FALSE
###################################################
## ex <- 0:56
## ed <- with(CPS1988, tapply(education,
##   list(ethnicity, experience), mean))[, as.character(ex)]
## fm <- cps_lm
## wago <- predict(fm, newdata = data.frame(experience = ex,
##   ethnicity = "cauc", education = as.numeric(ed["cauc",])))
## wagb <- predict(fm, newdata = data.frame(experience = ex,
##   ethnicity = "afam", education = as.numeric(ed["afam",])))
## plot(log(wage) ~ experience, data = CPS1988, pch = ".",
##   col = as.numeric(ethnicity))
## lines(ex, wago)
## lines(ex, wagb, col = 2)


###################################################
### chunk number 22: CPS-summary
###################################################
summary(cps_lm)


###################################################
### chunk number 23: CPS-noeth
###################################################
cps_noeth <- lm(log(wage) ~ experience + I(experience^2) +
                      education, data = CPS1988)
anova(cps_noeth, cps_lm)


###################################################
### chunk number 24: CPS-anova
###################################################
anova(cps_lm)


###################################################
### chunk number 25: CPS-noeth2 eval=FALSE
###################################################
## cps_noeth <- update(cps_lm, formula = . ~ . - ethnicity)


###################################################
### chunk number 26: CPS-waldtest
###################################################
waldtest(cps_lm, . ~ . - ethnicity)


###################################################
### chunk number 27: CPS-spline
###################################################
library("splines")
cps_plm <- lm(log(wage) ~ bs(experience, df = 5) +
                    education + ethnicity, data = CPS1988)


###################################################
### chunk number 28: CPS-spline-summary eval=FALSE
###################################################
## summary(cps_plm)


###################################################
### chunk number 29: CPS-BIC
###################################################
cps_bs <- lapply(3:10, function(i) lm(log(wage) ~
                                            bs(experience, df = i) + education + ethnicity,
                                      data = CPS1988))
structure(sapply(cps_bs, AIC, k = log(nrow(CPS1988))),
          .Names = 3:10)


###################################################
### chunk number 30: plm-plot eval=FALSE
###################################################
## cps <- data.frame(experience = -2:60, education =
##   with(CPS1988, mean(education[ethnicity == "cauc"])),
##   ethnicity = "cauc")
## cps$yhat1 <- predict(cps_lm, newdata = cps)
## cps$yhat2 <- predict(cps_plm, newdata = cps)
##
## plot(log(wage) ~ jitter(experience, factor = 3), pch = 19,
##   col = rgb(0.5, 0.5, 0.5, alpha = 0.02), data = CPS1988)
## lines(yhat1 ~ experience, data = cps, lty = 2)
## lines(yhat2 ~ experience, data = cps)
## legend("topleft", c("quadratic", "spline"), lty = c(2,1),
##   bty = "n")


###################################################
### chunk number 31: plm-plot1
###################################################
cps <- data.frame(experience = -2:60, education =
                        with(CPS1988, mean(education[ethnicity == "cauc"])),
                  ethnicity = "cauc")
cps$yhat1 <- predict(cps_lm, newdata = cps)
cps$yhat2 <- predict(cps_plm, newdata = cps)

plot(log(wage) ~ jitter(experience, factor = 3), pch = 19,
     col = rgb(0.5, 0.5, 0.5, alpha = 0.02), data = CPS1988)
lines(yhat1 ~ experience, data = cps, lty = 2)
lines(yhat2 ~ experience, data = cps)
legend("topleft", c("quadratic", "spline"), lty = c(2,1),
       bty = "n")


###################################################
### chunk number 32: CPS-int
###################################################
cps_int <- lm(log(wage) ~ experience + I(experience^2) +
                    education * ethnicity, data = CPS1988)
coeftest(cps_int)


###################################################
### chunk number 33: CPS-int2 eval=FALSE
###################################################
## cps_int <- lm(log(wage) ~ experience + I(experience^2) +
##   education + ethnicity + education:ethnicity,
##   data = CPS1988)


###################################################
### chunk number 34: CPS-sep
###################################################
cps_sep <- lm(log(wage) ~ ethnicity /
                    (experience + I(experience^2) + education) - 1,
              data = CPS1988)


###################################################
### chunk number 35: CPS-sep-coef
###################################################
cps_sep_cf <- matrix(coef(cps_sep), nrow = 2)
rownames(cps_sep_cf) <- levels(CPS1988$ethnicity)
colnames(cps_sep_cf) <- names(coef(cps_lm))[1:4]
cps_sep_cf


###################################################
### chunk number 36: CPS-sep-anova
###################################################
anova(cps_sep, cps_lm)


###################################################
### chunk number 37: CPS-sep-visualization-unused eval=FALSE
###################################################
## ex <- 0:56
## ed <- with(CPS1988, tapply(education, list(ethnicity,
##   experience), mean))[, as.character(ex)]
## fm <- cps_lm
## wago <- predict(fm, newdata = data.frame(experience = ex,
##   ethnicity = "cauc", education = as.numeric(ed["cauc",])))
## wagb <- predict(fm, newdata = data.frame(experience = ex,
##   ethnicity = "afam", education = as.numeric(ed["afam",])))
## plot(log(wage) ~ jitter(experience, factor = 2),
##   data = CPS1988, pch = ".", col = as.numeric(ethnicity))
##
##
## plot(log(wage) ~ as.factor(experience), data = CPS1988,
##   pch = ".")
## lines(ex, wago, lwd = 2)
## lines(ex, wagb, col = 2, lwd = 2)
## fm <- cps_sep
## wago <- predict(fm, newdata = data.frame(experience = ex,
##   ethnicity = "cauc", education = as.numeric(ed["cauc",])))
## wagb <- predict(fm, newdata = data.frame(experience = ex,
##   ethnicity = "afam", education = as.numeric(ed["afam",])))
## lines(ex, wago, lty = 2, lwd = 2)
## lines(ex, wagb, col = 2, lty = 2, lwd = 2)


###################################################
### chunk number 38: CPS-region
###################################################
CPS1988$region <- relevel(CPS1988$region, ref = "south")
cps_region <- lm(log(wage) ~ ethnicity + education +
                       experience + I(experience^2) + region, data = CPS1988)
coef(cps_region)


###################################################
### chunk number 39: wls1
###################################################
jour_wls1 <- lm(log(subs) ~ log(citeprice), data = journals,
                weights = 1/citeprice^2)


###################################################
### chunk number 40: wls2
###################################################
jour_wls2 <- lm(log(subs) ~ log(citeprice), data = journals,
                weights = 1/citeprice)


###################################################
### chunk number 41: journals-wls1 eval=FALSE
###################################################
## plot(log(subs) ~ log(citeprice), data = journals)
## abline(jour_lm)
## abline(jour_wls1, lwd = 2, lty = 2)
## abline(jour_wls2, lwd = 2, lty = 3)
## legend("bottomleft", c("OLS", "WLS1", "WLS2"),
##   lty = 1:3, lwd = 2, bty = "n")


###################################################
### chunk number 42: journals-wls11
###################################################
plot(log(subs) ~ log(citeprice), data = journals)
abline(jour_lm)
abline(jour_wls1, lwd = 2, lty = 2)
abline(jour_wls2, lwd = 2, lty = 3)
legend("bottomleft", c("OLS", "WLS1", "WLS2"),
       lty = 1:3, lwd = 2, bty = "n")


###################################################
### chunk number 43: fgls1
###################################################
auxreg <- lm(log(residuals(jour_lm)^2) ~ log(citeprice),
             data = journals)
jour_fgls1 <- lm(log(subs) ~ log(citeprice),
                 weights = 1/exp(fitted(auxreg)), data = journals)


###################################################
### chunk number 44: fgls2
###################################################
gamma2i <- coef(auxreg)[2]
gamma2 <- 0
while(abs((gamma2i - gamma2)/gamma2) > 1e-7) {
      gamma2 <- gamma2i
      fglsi <- lm(log(subs) ~ log(citeprice), data = journals,
                  weights = 1/citeprice^gamma2)
      gamma2i <- coef(lm(log(residuals(fglsi)^2) ~
                               log(citeprice), data = journals))[2]
}
jour_fgls2 <- lm(log(subs) ~ log(citeprice), data = journals,
                 weights = 1/citeprice^gamma2)


###################################################
### chunk number 45: fgls2-coef
###################################################
coef(jour_fgls2)


###################################################
### chunk number 46: journals-fgls
###################################################
plot(log(subs) ~ log(citeprice), data = journals)
abline(jour_lm)
abline(jour_fgls2, lty = 2, lwd = 2)


###################################################
### chunk number 47: usmacro-plot eval=FALSE
###################################################
## data("USMacroG")
## plot(USMacroG[, c("dpi", "consumption")], lty = c(3, 1),
##   plot.type = "single", ylab = "")
## legend("topleft", legend = c("income", "consumption"),
##   lty = c(3, 1), bty = "n")


###################################################
### chunk number 48: usmacro-plot1
###################################################
data("USMacroG")
plot(USMacroG[, c("dpi", "consumption")], lty = c(3, 1),
     plot.type = "single", ylab = "")
legend("topleft", legend = c("income", "consumption"),
       lty = c(3, 1), bty = "n")


###################################################
### chunk number 49: usmacro-fit
###################################################
library("dynlm")
cons_lm1 <- dynlm(consumption ~ dpi + L(dpi), data = USMacroG)
cons_lm2 <- dynlm(consumption ~ dpi + L(consumption),
                  data = USMacroG)


###################################################
### chunk number 50: usmacro-summary1
###################################################
summary(cons_lm1)


###################################################
### chunk number 51: usmacro-summary2
###################################################
summary(cons_lm2)


###################################################
### chunk number 52: dynlm-plot eval=FALSE
###################################################
## plot(merge(as.zoo(USMacroG[,"consumption"]), fitted(cons_lm1),
##   fitted(cons_lm2), 0, residuals(cons_lm1),
##   residuals(cons_lm2)), screens = rep(1:2, c(3, 3)),
##   lty = rep(1:3, 2), ylab = c("Fitted values", "Residuals"),
##   xlab = "Time", main = "")
## legend(0.05, 0.95, c("observed", "cons_lm1", "cons_lm2"),
##   lty = 1:3, bty = "n")


###################################################
### chunk number 53: dynlm-plot1
###################################################
plot(merge(as.zoo(USMacroG[,"consumption"]), fitted(cons_lm1),
           fitted(cons_lm2), 0, residuals(cons_lm1),
           residuals(cons_lm2)), screens = rep(1:2, c(3, 3)),
     lty = rep(1:3, 2), ylab = c("Fitted values", "Residuals"),
     xlab = "Time", main = "")
legend(0.05, 0.95, c("observed", "cons_lm1", "cons_lm2"),
       lty = 1:3, bty = "n")


###################################################
### chunk number 54: encompassing1
###################################################
cons_lmE <- dynlm(consumption ~ dpi + L(dpi) +
                        L(consumption), data = USMacroG)


###################################################
### chunk number 55: encompassing2
###################################################
anova(cons_lm1, cons_lmE, cons_lm2)


###################################################
### chunk number 56: encompassing3
###################################################
encomptest(cons_lm1, cons_lm2)


###################################################
### chunk number 57: pdata.frame
###################################################
data("Grunfeld", package = "AER")
library("plm")
gr <- subset(Grunfeld, firm %in% c("General Electric",
                                   "General Motors", "IBM"))
pgr <- pdata.frame(gr, index = c("firm", "year"))


###################################################
### chunk number 58: plm-pool
###################################################
gr_pool <- plm(invest ~ value + capital, data = pgr,
               model = "pooling")


###################################################
### chunk number 59: plm-FE
###################################################
gr_fe <- plm(invest ~ value + capital, data = pgr,
             model = "within")
summary(gr_fe)


###################################################
### chunk number 60: plm-pFtest
###################################################
pFtest(gr_fe, gr_pool)


###################################################
### chunk number 61: plm-RE
###################################################
gr_re <- plm(invest ~ value + capital, data = pgr,
             model = "random", random.method = "walhus")
summary(gr_re)


###################################################
### chunk number 62: plm-plmtest
###################################################
plmtest(gr_pool)


###################################################
### chunk number 63: plm-phtest
###################################################
phtest(gr_re, gr_fe)


###################################################
### chunk number 64: EmplUK-data
###################################################
data("EmplUK", package = "plm")


###################################################
### chunk number 65: plm-AB
###################################################
empl_ab <- pgmm(log(emp) ~ lag(log(emp), 1:2) + lag(log(wage), 0:1) +
                      log(capital) + lag(log(output), 0:1) | lag(log(emp), 2:99),
                data = EmplUK, index = c("firm", "year"),
                effect = "twoways", model = "twosteps")


###################################################
### chunk number 66: plm-AB-summary
###################################################
summary(empl_ab)


###################################################
### chunk number 67: systemfit
###################################################
library("systemfit")
gr2 <- subset(Grunfeld, firm %in% c("Chrysler", "IBM"))
pgr2 <- pdata.frame(gr2, c("firm", "year"))


###################################################
### chunk number 68: SUR
###################################################
gr_sur <- systemfit(invest ~ value + capital,
                    method = "SUR", data = pgr2)
summary(gr_sur, residCov = FALSE, equations = FALSE)


###################################################
### chunk number 69: nlme eval=FALSE
###################################################
library("nlme")
g1 <- subset(Grunfeld, firm == "Westinghouse")
gls(invest ~ value + capital, data = g1, correlation = corAR1())



Input = ("
Stream                   Longnose  Acerage  DO2   Maxdepth  NO3   SO4     Temp
BASIN_RUN                  13         2528    9.6  80        2.28  16.75   15.3
BEAR_BR                    12         3333    8.5  83        5.34   7.74   19.4
BEAR_CR                    54        19611    8.3  96        0.99  10.92   19.5
BEAVER_DAM_CR              19         3570    9.2  56        5.44  16.53   17
BEAVER_RUN                 37         1722    8.1  43        5.66   5.91   19.3
BENNETT_CR                  2          583    9.2  51        2.26   8.81   12.9
BIG_BR                     72         4790    9.4  91        4.1    5.65   16.7
BIG_ELK_CR                164        35971   10.2  81        3.2   17.53   13.8
BIG_PIPE_CR                18        25440    7.5  120       3.53   8.2    13.7
BLUE_LICK_RUN               1         2217    8.5  46        1.2   10.85   14.3
BROAD_RUN                  53         1971   11.9  56        3.25  11.12   22.2
BUFFALO_RUN                16        12620    8.3  37        0.61  18.87   16.8
BUSH_CR                    32        19046    8.3  120       2.93  11.31   18
CABIN_JOHN_CR              21         8612    8.2  103       1.57  16.09   15
CARROLL_BR                 23         3896   10.4  105       2.77  12.79   18.4
COLLIER_RUN                18         6298    8.6  42        0.26  17.63   18.2
CONOWINGO_CR              112        27350    8.5  65        6.95  14.94   24.1
DEAD_RUN                   25         4145    8.7  51        0.34  44.93   23
DEEP_RUN                    5         1175    7.7  57        1.3   21.68   21.8
DEER_CR                    26         8297    9.9  60        5.26  6.36    19.1
DORSEY_RUN                  8         7814    6.8  160       0.44  20.24   22.6
FALLS_RUN                  15         1745    9.4  48        2.19  10.27   14.3
FISHING_CR                 11         5046    7.6  109       0.73   7.1    19
FLINTSTONE_CR              11        18943    9.2  50        0.25  14.21   18.5
GREAT_SENECA_CR            87         8624    8.6  78        3.37   7.51   21.3
GREENE_BR                  33         2225    9.1  41        2.3    9.72   20.5
GUNPOWDER_FALLS            22        12659    9.7  65        3.3    5.98   18
HAINES_BR                  98         1967    8.6  50        7.71  26.44   16.8
HAWLINGS_R                  1         1172    8.3  73        2.62   4.64   20.5
HAY_MEADOW_BR               5          639    9.5  26        3.53   4.46   20.1
HERRINGTON_RUN              1         7056    6.4  60        0.25   9.82   24.5
HOLLANDS_BR                38         1934   10.5  85        2.34  11.44   12
ISRAEL_CR                  30         6260    9.5  133       2.41  13.77   21
LIBERTY_RES                12          424    8.3  62        3.49   5.82   20.2
LITTLE_ANTIETAM_CR         24         3488    9.3  44        2.11  13.37   24
LITTLE_BEAR_CR              6         3330    9.1  67        0.81   8.16   14.9
LITTLE_CONOCOCHEAGUE_CR    15         2227    6.8  54        0.33   7.6    24
LITTLE_DEER_CR             38         8115    9.6  110       3.4    9.22   20.5
LITTLE_FALLS               84         1600   10.2  56        3.54   5.69   19.5
LITTLE_GUNPOWDER_R          3        15305    9.7  85        2.6    6.96   17.5
LITTLE_HUNTING_CR          18         7121    9.5  58        0.51   7.41   16
LITTLE_PAINT_BR            63         5794    9.4  34        1.19  12.27   17.5
MAINSTEM_PATUXENT_R       239         8636    8.4  150       3.31   5.95   18.1
MEADOW_BR                 234         4803    8.5  93        5.01  10.98   24.3
MILL_CR                     6         1097    8.3  53        1.71  15.77   13.1
MORGAN_RUN                 76         9765    9.3  130       4.38   5.74   16.9
MUDDY_BR                   25         4266    8.9  68        2.05  12.77   17
MUDLICK_RUN                 8         1507    7.4  51        0.84  16.3    21
NORTH_BR                   23         3836    8.3  121       1.32   7.36   18.5
NORTH_BR_CASSELMAN_R       16        17419    7.4  48        0.29   2.5    18
NORTHWEST_BR                6         8735    8.2  63        1.56  13.22   20.8
NORTHWEST_BR_ANACOSTIA_R  100        22550    8.4  107       1.41  14.45   23
OWENS_CR                   80         9961    8.6  79        1.02   9.07   21.8
PATAPSCO_R                 28         4706    8.9  61        4.06   9.9    19.7
PINEY_BR                   48         4011    8.3  52        4.7    5.38   18.9
PINEY_CR                   18         6949    9.3  100       4.57  17.84   18.6
PINEY_RUN                  36        11405    9.2  70        2.17  10.17   23.6
PRETTYBOY_BR               19          904    9.8  39        6.81   9.2    19.2
RED_RUN                    32         3332    8.4  73        2.09   5.5    17.7
ROCK_CR                     3          575    6.8  33        2.47   7.61   18
SAVAGE_R                  106        29708    7.7  73        0.63  12.28   21.4
SECOND_MINE_BR             62         2511   10.2  60        4.17  10.75   17.7
SENECA_CR                  23        18422    9.9  45        1.58   8.37   20.1
SOUTH_BR_CASSELMAN_R        2         6311    7.6  46        0.64  21.16   18.5
SOUTH_BR_PATAPSCO          26         1450    7.9  60        2.96   8.84   18.6
SOUTH_FORK_LINGANORE_CR    20         4106   10.0  96        2.62   5.45   15.4
TUSCARORA_CR               38        10274    9.3  90        5.45  24.76   15
WATTS_BR                   19          510    6.7  82        5.25  14.19   26.5
")

df = read.table(textConnection(Input),header=TRUE)
