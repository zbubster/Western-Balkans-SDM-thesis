# Habitat suitability modelling of the alpine plants in the western Balkans

This repository contains the working code and analytical workflow for my master thesis focused on habitat suitability modelling (SDM) of alpine plants in the western Balkans.

## Contents summary

- preparation and cleaning of **species occurrence data**
- processing of **environmental predictors for SDM**
  - using climate, topo, geo, pedo and landcover predictors (their combinations should reflect modelling taget)
  - big rasters handling alowed by *terra* <3
- raster aggregation across **multiple spatial grains**
  - all processes are carried out in 4 grain levels:
    - 1000, 500, 200 & 100 m
- terrain-derived variables from DEM data
  - including multicell indices created with **moving window** (TPI, TRI, etc) and singlecell indices based on **finner scale cells aggregation** (elvation range within cell, SD, etc)
- **predictor collinearity**
  - supervised predictor selection based on mulitcollienarity, using package *collinear*
- **spatial autocorrelation** in occurrence data
  - dividing data into spatial folds for later crossvalidation, fold spatial size is derived from spatialautocorellation range, using package *blockCV* 
- model preparation, calibration, and evaluation in R
  - *biomod2*, extrapolation evaluation using Shape method (included in *flexsdm* package)
- thesis itself will be written using *typst* (i hope so)

## Purpose

- development space for functions and analytical workflows
- storage place for intermediate scripts and results (but most of the data are too big to be stored on Github)
- a reproducible background for the final master thesis text buliding