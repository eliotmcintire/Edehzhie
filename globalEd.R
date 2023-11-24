getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}

getOrUpdatePkg("Require", "0.3.1.14")
getOrUpdatePkg("SpaDES.project", "0.0.8.9026")
# getOrUpdatePkg("reproducible", "2.0.9")
# getOrUpdatePkg("SpaDES.core", "2.0.3")

################### RUNAME

if (SpaDES.project::user("tmichele")) setwd("~/projects/Edehzhie/")
if (SpaDES.project::user("emcintir")) {
  SpaDES.project::pkgload2("~/GitHub/SpaDES.project")
  setwd("~/GitHub/")
  .fast <- F
}
################ SPADES CALL
library(SpaDES.project)
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
                 # reproducible.cacheSaveFormat = "qs",
                 reproducible.inputPaths = "~/data",
                 LandR.assertions = FALSE,
                 reproducible.cacheSpeed = "fast",
                 reproducible.gdalwarp = TRUE,
                 reproducible.showSimilarDepth = 7,
                 gargle_oauth_email = if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 gargle_oauth_email = if (user("emcintir")) "eliotmcintire@gmail.com" else NULL,
                 SpaDES.project.fast = isTRUE(.fast),
                 spades.recoveryMode = FALSE
  ),
  times = list(start = 2011,
               end = 2025),
  params = list(.globals = list(.plots = NA,
                                .plotInitialTime = NA,
                                sppEquivCol = 'Boreal',
                                .useCache = c(".inputObjects", "init", "other"))),
  # require = "PredictiveEcology/reproducible@reproducibleTempCacheDir (>= 2.0.8.9010)", # so can use Cache next
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
  studyArea = list(level = 2, NAME_2 = "Fort Smith", epsg = 3580), # NWT Conic Conformal
  studyAreaLarge = studyArea,
  require = c("reproducible", "SpaDES.core", "LandR"),
  packages = c("googledrive", 'RCurl', 'XML',
               "PredictiveEcology/LandR@development (>= 1.1.0.9073",
               "PredictiveEcology/SpaDES.core@optionsAsArgs (>= 2.0.2.9009)"),
  useGit = "sub"
)

if (SpaDES.project::user("emcintir"))
  SpaDES.project::pkgload2(
    list(file.path("~/GitHub", c("reproducible", "SpaDES.core", "SpaDES.tools", "LandR", "climateData", "fireSenseUtils")),
         "~/GitHub/SpaDES.project"))

unlink(dir(tempdir(), recursive = TRUE, full.names = TRUE))
snippsim <- do.call(SpaDES.core::simInitAndSpades, out)
