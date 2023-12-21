getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}

getOrUpdatePkg("Require", "0.3.1.15")
getOrUpdatePkg("SpaDES.project", "0.0.8.9027")
# getOrUpdatePkg("reproducible", "2.0.9")
# getOrUpdatePkg("SpaDES.core", "2.0.3")

################### RUNAME

if (SpaDES.project::user("tmichele")) setwd("~/projects/Edehzhie/")
if (SpaDES.project::user("emcintir")) {
#   SpaDES.project::pkgload2("~/GitHub/SpaDES.project")
  setwd("~/GitHub")
  .fast <- T
}
################ SPADES CALL
library(SpaDES.project)
out <- SpaDES.project::setupProject(
  runName = "Edehzhie",
  updateRprofile = TRUE,
#  Restart = TRUE,
  paths = list(projectPath = runName,
               scratchPath = "~/scratch"),
  modules =
    file.path("PredictiveEcology",
              c("canClimateData@usePrepInputs",
                paste0(# development
                  c("Biomass_borealDataPrep",
                    "Biomass_core",
                    "Biomass_speciesData",
                    "Biomass_speciesFactorial",
                    "Biomass_speciesParameters",
                    "fireSense_IgnitionFit",
                    "fireSense_EscapeFit",
                    "fireSense_SpreadFit",
                    "fireSense_dataPrepFit",
                    "fireSense_dataPrepPredict",
                    "fireSense_IgnitionPredict",
                    "fireSense_EscapePredict",
                    "fireSense_SpreadPredict"),
                  "@development")
              )),
  functions = "tati-micheletti/Edehzhie@master/inputs/outterFuns.R",
  options = list(spades.allowInitDuringSimInit = TRUE,
                 reproducible.showSimilar = TRUE,
                 reproducible.cacheSaveFormat = "rds",
                 reproducible.inputPaths = "~/data",
                 reproducible.showSimilarDepth = 7,
                 gargle_oauth_cache = if (machine("W-VIC-A127585")) "~/.secret" else NULL,
                 gargle_oauth_email =
                   if (user("emcintir")) "eliotmcintire@gmail.com" else if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 SpaDES.project.fast = isTRUE(.fast) # This sets many
  ),
  times = list(start = 2011,
               end = 2025),
  params = list(
    fireSense_IgnitionFit = list(.plots = "screen"),
    .globals = list(#.plots = NA,
                                .plotInitialTime = NA,
                                sppEquivCol = 'Boreal',
                                cores = 9,
                                .useCache = c(".inputObjects", "init", "prepIgnitionFitData", "prepSpreadFitData", "prepEscapeFitData"))),
  studyArea = list(level = 2, NAME_2 = "Fort Smith", epsg = 3580), # NWT Conic Conformal
  studyAreaLarge = studyArea,
  require = c("reproducible", "SpaDES.core", "PredictiveEcology/LandR@development (>= 1.1.0.9073"),
  packages = c("googledrive", 'RCurl', 'XML',
               "PredictiveEcology/SpaDES.core@sequentialCaching (>= 2.0.3.9004)",
               "PredictiveEcology/reproducible@modsForLargeArchives (>= 2.0.10.9013)"),
useGit = "sub"
)

if (SpaDES.project::user("emcintir"))
 SpaDES.project::pkgload2(
   list(file.path("~/GitHub", c("reproducible", "SpaDES.core", "SpaDES.tools", "LandR", "climateData", "fireSenseUtils",
                                "PSPclean")),
        "~/GitHub/SpaDES.project"))
unlink(dir(tempdir(), recursive = TRUE, full.names = TRUE))
# undebug(reproducible:::.callArchiveExtractFn)
snippsim <- do.call(SpaDES.core::simInitAndSpades, out)

