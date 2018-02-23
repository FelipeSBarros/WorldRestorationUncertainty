# setwd("./GEE/")
rm(list=ls())
gc()

library(raster)
library(gdalUtils)
library(rgdal)

### 3
#g1
gdalwarp("./1KMGlobalForestG1_5kmFocal.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./1KMGlobalForestG1_5kmFocal_aligned.tif", overwrite = TRUE)
g1 <- raster("./1KMGlobalForestG1_5kmFocal_aligned.tif") 
plot(g1)

#g2
gdalwarp("./1KMGlobalForestG2_5kmFocal.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./1KMGlobalForestG2_5kmFocal_aligned.tif", overwrite = TRUE)
g2 <- raster("./1KMGlobalForestG2_5kmFocal_aligned.tif")
plot(g2)

#g3
gdalwarp("./1KMGlobalForestG3_5kmFocal.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./1KMGlobalForestG3_5kmFocal_aligned.tif", overwrite = TRUE)
g3 <- raster("./1KMGlobalForestG3_5kmFocal_aligned.tif")
plot(g3)

## merging
merged <- g1+g2+g3
plot(merged)
writeRaster(merged, "./1KMGlobalForest_5kmFocal_alignedMerged.tif", overwrite = TRUE)
dev.off()

# Organinzing ESA img
gdalwarp("./ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./ESACCI_alignedResampled.tif", overwrite = TRUE)

## 3 applying the equetion
library(raster)
result <- raster("./1KMGlobalForest_5kmFocal_alignedMerged.tif")
gdalwarp("./1KMGlobalForest_5kmFocal_alignedMerged.tif", dstnodata = 0, dstfile = "./1KMGlobalForest_5kmFocal_alignedMergedNA.tif", overwrite = TRUE)
result <- raster("./1KMGlobalForest_5kmFocal_alignedMergedNA.tif")
#plot(result)

calc(result, function(x){(1.37595 - 0.23498 * log(x + 1))}, filename = "./1KMGlobalForest_5kmFocal_Equation.tif", overwrite = TRUE)
eq <- raster("./1KMGlobalForest_5kmFocal_Equation.tif")
#plot(eq)

##Normalizing equetaion
calc(eq, function(x){(x - 0.291489) / 1.084461}, filename = "./1KMGlobalForest_5kmFocal_EquationNorm.tif", overwrite = TRUE)
eq <- raster("./1KMGlobalForest_5kmFocal_EquationNorm.tif")

##Masking to forest biomes
forestBiomes <- readOGR("../Ecoregions2017/", "ForestBiomes")
mask(x = eq, mask = forestBiomes, filename = "./1KMGlobalForest_5kmFocal_EquationNormMaskedForestBiomes.tif", overwrite = TRUE)
eq <- raster("./1KMGlobalForest_5kmFocal_EquationNormMaskedForestBiomes.tif")
plot(eq)

####### Hansen analysis
### 3
#g1
gdalwarp("./1KMGlobalForestG1_RestAmount.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./1KMGlobalForestG1_RestAmount_aligned.tif", overwrite = TRUE)
g1 <- raster("./1KMGlobalForestG1_5kmFocal_aligned.tif") 
plot(g1)

#g2
gdalwarp("./1KMGlobalForestG2_RestAmount.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./1KMGlobalForestG2_RestAmount_aligned.tif", overwrite = TRUE)
g2 <- raster("./1KMGlobalForestG2_5kmFocal_aligned.tif")
plot(g2)

#g3
gdalwarp("./1KMGlobalForestG3_RestAmount.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./1KMGlobalForestG3_RestAmount_aligned.tif", overwrite = TRUE)
g3 <- raster("./1KMGlobalForestG3_5kmFocal_aligned.tif")
plot(g3)

## merging
## BASH GDAL:
#gdal_calc.py -A "./GEE/1KMGlobalForestG1_RestAmount_aligned.tif" -B "./GEE/1KMGlobalForestG2_RestAmount_aligned.tif" -C "./GEE/1KMGlobalForestG3_RestAmount_aligned.tif" --outfile="./GEE/1KMGlobalForestG1_RestAmount_alignedMerged.tif" --calc="A+B+C"
merged <- raster("./1KMGlobalForestG1_RestAmount_alignedMerged.tif")
plot(merged)
dev.off()
# Removing 0
gdalwarp("./1KMGlobalForestG1_RestAmount_alignedMerged.tif", dstnodata = 0, dstfile = "./1KMGlobalForest_RestAmount_alignedMergedNA.tif", overwrite = TRUE)

RestorableAmount <- raster("./1KMGlobalForest_RestAmount_alignedMergedNA.tif")
plot(RestorableAmount)
dev.off()

##Masking to forest biomes
forestBiomes <- readOGR("../Ecoregions2017/", "ForestBiomes")
mask(x = RestorableAmount, mask = forestBiomes, filename = "./1KMGlobalForest_RestAmount_alignedMergedNAMaskedForesBiomes.tif", overwrite = TRUE)
result <- raster("./1KMGlobalForest_RestAmount_alignedMergedNAMaskedForesBiomes.tif")
plot(result)
