getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}

getOrUpdatePkg("Require", "0.3.1.9015")
getOrUpdatePkg("SpaDES.project", "0.0.8.9028")
# getOrUpdatePkg("reproducible", "2.0.10.9018") # not merged into development yet; set below
# getOrUpdatePkg("SpaDES.core", "2.0.3.9006") # not merged into development yet; set below

################### setwd to location where project should be located
if (SpaDES.project::user("emcintir")) {
  setwd("~/GitHub")

  # This will set several options that make SpaDES.core run faster;
  # don't use yet unless you are aware of the things that are being set
  .fast <- TRUE
}
################ SPADES CALL
library(SpaDES.project)
out <- SpaDES.project::setupProject(
  runName = "Edehzhie",
  updateRprofile = TRUE,
  Restart = FALSE,
  paths = list(projectPath = runName,
               scratchPath = "~/scratch"),
  modules =
    file.path("PredictiveEcology",
              c("canClimateData@usePrepInputs",
                "fireSense_IgnitionFit@glmmTMB",
                paste0(# development
                  c("Biomass_borealDataPrep",
                    "Biomass_core",
                    "Biomass_speciesData",
                    "Biomass_speciesFactorial",
                    "Biomass_speciesParameters",
                    "fireSense_EscapeFit",
                    "fireSense_SpreadFit",
                    "fireSense_dataPrepFit",
                    "fireSense_dataPrepPredict",
                    "fireSense_IgnitionPredict",
                    "fireSense_EscapePredict",
                    "fireSense_SpreadPredict"),
                  "@development")
              )),
  options = list(spades.allowInitDuringSimInit = TRUE,
                 spades.allowSequentialCaching = TRUE,
                 reproducible.showSimilar = TRUE,
                 reproducible.useMemoise = TRUE,
                 reproducible.memoisePersist = TRUE,
                 reproducible.cacheSaveFormat = "qs",
                 reproducible.inputPaths = "~/data",
                 LandR.assertions = FALSE,
                 reproducible.cacheSpeed = "fast",
                 reproducible.gdalwarp = TRUE,
                 reproducible.showSimilarDepth = 7,
                 gargle_oauth_cache = if (machine("W-VIC-A127585")) "~/.secret" else NULL,
                 gargle_oauth_email =
                   if (user("emcintir")) "eliotmcintire@gmail.com" else if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 SpaDES.project.fast = isTRUE(.fast),
                 spades.recoveryMode = 1,
                 reproducible.useGdown = TRUE
  ),
  times = list(start = 2011,
               end = 2025),
  params = list(
    fireSense_SpreadFit = list(cores = NA, cacheID_DE = "previous", trace = 1,
                               mode = "fit", SNLL_FS_thresh = 9000),
    fireSense_IgnitionFit = list(.useCache = c("run")),
    .globals = list(.plots = NA,
                    .plotInitialTime = NA,
                    sppEquivCol = 'Boreal',
                    cores = 12,
                    .useCache = c(".inputObjects", "init", "prepIgnitionFitData", "prepSpreadFitData",
                                  "writeFactorialToDisk"))),
  studyArea = list(level = 2, NAME_2 = "Fort Smith", epsg = 3580), # NWT Conic Conformal
  studyAreaLarge = studyArea,
  require = c("reproducible", "SpaDES.core", "PredictiveEcology/LandR@development (>= 1.1.0.9073"),
  packages = c("googledrive", 'RCurl', 'XML',
               "PredictiveEcology/SpaDES.core@sequentialCaching (HEAD)",
               "PredictiveEcology/reproducible@modsForLargeArchives (HEAD)"),
  useGit = "sub"
)

if (SpaDES.project::user("emcintir")) {
  pkgAll <- c("reproducible@modsForLargeArchives", "SpaDES.core@sequentialCaching",
              "SpaDES.tools@development", "LandR@development", "climateData@development",
              "fireSenseUtils@packageCopying")
  pkgs <- gsub("@.+", "", pkgAll)
  if (TRUE) {
    brs <- gsub(".+@", "", pkgAll)
    Map(pkg = pkgs, br = brs, function(pkg, br) {
      theDir <- paste0("~/GitHub/", pkg)
      if (!dir.exists(theDir)) {
        system(paste0("cd ", dirname(theDir), " ; git clone git@github.com:PredictiveEcology/", pkg))
      }

      system(paste0("cd ", theDir, " ; git checkout ", br," ; git pull"))
    })
  }
  SpaDES.project::pkgload2(
    list(file.path("~/GitHub", pkgs))#, "SpaDES.tools", "LandR", "climateData", "fireSenseUtils",
    #                             "PSPclean")),
    #    "~/GitHub/SpaDES.project")
  )
}
unlink(dir(tempdir(), recursive = TRUE, full.names = TRUE))
unlink(dir(out$paths$scratchPath, recursive = TRUE, full.names = TRUE))
# debug(reproducible:::gdalProject)
# undebug(reproducible:::.callArchiveExtractFn)
snippsim <- do.call(SpaDES.core::simInitAndSpades, out)

