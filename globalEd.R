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
getOrUpdatePkg("SpaDES.project", "0.0.8.9025")

################### RUNAME

if (SpaDES.project::user("tmichele")) setwd("~/projects/Edehzhie/")
if (SpaDES.project::user("emcintir")) {
  SpaDES.project::pkgload2("~/GitHub/SpaDES.project")
  setwd("~/GitHub/")
  .fast <- T
}
################ SPADES CALL
library(SpaDES.project)
# pkgload::load_all("c:/Eliot/GitHub/SpaDES.project")
out <- SpaDES.project::setupProject(
  runName = "Edehzhie",
  Restart = TRUE,
  paths = list(projectPath = runName,
               scratchPath = "~/scratch"),
  modules =
    file.path("PredictiveEcology",
              c("canClimateData@canadianProvs",
                paste0(# terra-migration
                c("Biomass_speciesData",
                  "Biomass_core"),
                "@terra-migration"),
                paste0(# development
                  c("Biomass_borealDataPrep",
                    "Biomass_speciesFactorial",
                    "Biomass_speciesParameters",
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
                 reproducible.memoisePersist = TRUE,
                 reproducible.inputPaths = "~/data",
                 reproducible.showSimilarDepth = 5,
                 gargle_oauth_email = if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 gargle_oauth_email = if (user("emcintir")) "eliotmcintire@gmail.com" else NULL,
                 SpaDES.project.fast = isTRUE(.fast)
  ),
  times = list(start = 2011,
               end = 2025),
  params = list(.globals = list(.plots = NA,
                                .plotInitialTime = NA,
                                sppEquivCol = 'Boreal',
                                .useCache = c(".inputObjects", "init"))),
  require = "PredictiveEcology/reproducible@reproducibleTempCacheDir (>= 2.0.8.9010)", # so can use Cache next
  # studyArea = Cache(studyAreaGenerator()),
  # rasterToMatch = Cache(rtmGenerator(sA = studyArea)),
  # studyAreaLarge = Cache(studyAreaGenerator(large = TRUE, destPath = paths[["inputPath"]])),
  # rasterToMatchLarge = Cache(rtmGenerator(sA = studyAreaLarge, destPath = paths[["inputPath"]])),
  # sppEquiv = sppEquiv_CA(runName),
  # params = list(.globals = list(sppEquivCol = runName,
  #                               dataYear = "2011",
  #                               .plotInitialTime = NA,
  #                               .useCache = c(".inputObjects", "init")),
  #                               #.studyAreaName = "NT"),
  #               fireSense_IgnitionFit = list(lb = list(coef = 0,
  #                                                      #I got this from running only dataPrepFit, then quantile(MDC, probs = 0.05) NOTE: Ian's notes
  #                                                      knots = list(MDC = 100)),
  #                                            ub = list(coef = 20,
  #                                                      #and the upper quantile was 0.9 NOTE: Ian's notes
  #                                                      knots = list(MDC = 156))),
  #               canClimateData = list(.runName = runName,
  #                                     .useCache = ".inputObjects",
  #                                     climateGCM = "CanESM5",
  #                                     climateSSP = "370",
  #                                     historicalFireYears = 1991:2020)#,
  #                                     #studyAreaName = "NT")
  # ),
  studyArea = list(level = 2, NAME_2 = "Fort Smith"),
  studyAreaLarge = studyArea,
  packages = c("googledrive", 'RCurl', 'XML',
               "PredictiveEcology/LandR@development (>= 1.1.0.9073",
               "PredictiveEcology/SpaDES.core@optionsAsArgs (>= 2.0.2.9009)"),
  useGit = "sub"
)

if (SpaDES.project::user("emcintir"))
  SpaDES.project::pkgload2(
    list(file.path("~/GitHub", c("reproducible", "SpaDES.core", "LandR")),
         "~/GitHub/SpaDES.project"))

snippsim <- do.call(SpaDES.core::simInitAndSpades, out)
