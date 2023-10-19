getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}
#
# devtools::install_github("PredictiveEcology/LandR", ref = "development") # (>= 1.1.0.9069)
# devtools::install_github("PredictiveEcology/SpaDES.core", ref = "optionsAsArgs") # (>= 2.0.2.9007)
# devtools::install_github("PredictiveEcology/reproducible", ref = "reproducibleTempCacheDir") # (>= 2.0.8.9010)

getOrUpdatePkg("Require", "0.3.1.14")
# getOrUpdatePkg("SpaDES.project", "0.0.8.9012")
getOrUpdatePkg("SpaDES.project", "0.0.8.9023")
# getOrUpdatePkg("SpaDES.core", "2.0.2.9006") # development
# devtools::install_github("PredictiveEcology/SpaDES.core", ref = "8ddcbe09550c2a901ab446e92c78ebb9859c97c2") # development #8ddcbe09550c2a901ab446e92c78ebb9859c97c2 optionsAsArgs
# devtools::install_github("PredictiveEcology/SpaDES.core", ref = "development") # development #8ddcbe09550c2a901ab446e92c78ebb9859c97c2

################### RUNAME

if (SpaDES.project::user("tmichele")) setwd("~/projects/Edehzhie/")
if (SpaDES.project::user("emcintir")) setwd("~/GitHub/")
# inputsFolder <- file.path(getwd(), "inputs")

# studyArea <- studyAreaGenerator()
# rasterToMatch <- rtmGenerator(sA = studyArea)
# studyAreaLarge <- studyAreaGenerator(large = TRUE, destPath = inputsFolder)
# rasterToMatchLarge <- rtmGenerator(sA = studyAreaLarge, destPath = inputsFolder)
# sppEquiv <- sppEquiv_CA(runName)
################ SPADES CALL
library(SpaDES.project)
out <- SpaDES.project::setupProject(
  runName = "Edehzhie",
  Restart = TRUE,
  paths = list(projectPath = runName,
               scratchPath = "~/scratch"),
  modules =
    file.path("PredictiveEcology",
              c(paste0(# terra-migration
                c("Biomass_speciesData",
                  "Biomass_borealDataPrep",
                  "Biomass_core"),
                "@terra-migration"),
                paste0(# development
                  c("Biomass_speciesFactorial",
                    "Biomass_speciesParameters",
                    "canClimateData",
                    "fireSense_dataPrepFit",
                    "fireSense_IgnitionFit",
                    "fireSense_EscapeFit",
                    "fireSense_SpreadFit",
                    "fireSense_dataPrepPredict",
                    "fireSense_IgnitionPredict",
                    "fireSense_EscapePredict",
                    "fireSense_SpreadPredict"),
                  "@development")
              )),
  functions = "tati-micheletti/Edehzhie@master/inputs/outterFuns.R",
  options = list(spades.allowInitDuringSimInit = TRUE,
                 reproducible.showSimilar = TRUE,
                 reproducible.inputPaths = "~/data",
                 reproducible.showSimilarDepth = 5,
                 gargle_oauth_email = if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 gargle_oauth_email = if (user("emcintir")) "eliotmcintire@gmail.com" else NULL,
                 SpaDES.project.fast = F
  ),
  times = list(start = 2011,
               end = 2025),
  require = "PredictiveEcology/reproducible@reproducibleTempCacheDir (>= 2.0.8.9010)", # so can use Cache next
  studyArea = Cache(studyAreaGenerator()),
  rasterToMatch = Cache(rtmGenerator(sA = studyArea)),
  studyAreaLarge = Cache(studyAreaGenerator(large = TRUE, destPath = paths[["inputPath"]])),
  rasterToMatchLarge = Cache(rtmGenerator(sA = studyAreaLarge, destPath = paths[["inputPath"]])),
  sppEquiv = sppEquiv_CA(runName),
  params = list(.globals = list(sppEquivCol = runName,
                                dataYear = "2011",
                                .useCache = c(".inputObjects", "init"),
                                .studyAreaName = "NT"),
                fireSense_IgnitionFit = list(lb = list(coef = 0,
                                                       #I got this from running only dataPrepFit, then quantile(MDC, probs = 0.05) NOTE: Ian's notes
                                                       knots = list(MDC = 100)),
                                             ub = list(coef = 20,
                                                       #and the upper quantile was 0.9 NOTE: Ian's notes
                                                       knots = list(MDC = 156))),
                canClimateData = list(.runName = runName,
                                      .useCache = ".inputObjects",
                                      climateGCM = "CanESM5",
                                      climateSSP = "370",
                                      historicalFireYears = 1991:2022,
                                      studyAreaName = "NT")
  ),
  packages = c("googledrive", 'RCurl', 'XML',
               "PredictiveEcology/LandR@development (>= 1.1.0.9069)",
               "PredictiveEcology/SpaDES.core@optionsAsArgs (>= 2.0.2.9008)"),
  useGit = "sub"
)

#pkgload::load_all("c:/Eliot/GitHub/SpaDES.project")
#pkgload::load_all("c:/Eliot/GitHub/reproducible")
#pkgload::load_all("c:/Eliot/GitHub/SpaDES.core")
pkgload::load_all("c:/Eliot/GitHub/LandR")


snippsim <- do.call(SpaDES.core::simInitAndSpades, out)
