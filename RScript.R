# setwd("D://Repos/WorldRestorationUncertainty/GEE/")
rm(list=ls())

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
# DONE WITH QGIS
merged <- raster("./1KMGlobalForest_5kmFocal_alignedMerged.tif")
dev.off()

# Organinzing ESA img
gdalwarp("./ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif",tr = c(0.0083333, -0.00833333), te = c(-180.0000000000000000, -59.9999400000000094, 179.9998560000000225, 90.0000000000000000), r = "near", dstfile = "./ESACCI_alignedResampled.tif", overwrite = TRUE)

## 3 applying the equetion
library(raster)
result <- raster("./1KMGlobalForest_5kmFocal_alignedMergedMergeQGIS.tif")
#plot(result)

eq <- (1.37595 - 0.23498 * log10(result + 1))
#plot(eq)
writeRaster(eq, "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForest_5kmFocal_Equation.tif")

##Normalizing equetaion
eq <- eq/maxValue(eq) # check if maxValue(eq) == 1.37595
writeRaster(eq, "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForest_5kmFocal_EquationNorm.tif")


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

RestorableAmount <- raster("./1KMGlobalForest_ForestAmount_alignedMergedMergeQGIS.tif")
#area(RestorableAmount, filename = "./pixelArea.tif", na.rm = TRUE)
# If x is a Raster* object: RasterLayer or RasterBrick. Cell values represent the size of the cell in km2, or the relative size if weights=TRUE
#area <- raster("./pixelArea.tif")
#area <- area/10000 #Area em ha
#writeRaster(area, "./AreaHa.tif")

area <- raster("./AreaHa.tif")
ESA <- raster("./ESACCI_alignedResampled.tif")
# writeRaster(ESA, "./ESA_Mod.tif")
#value = (RestorableAmount*area)/100
#writeRaster(value, "./RestoableAmount_m2.tif")
value <- raster("./RestoableAmount_m2.tif")

#Analaysis by biome
ESAsd <- zonal(value, ESA, "sd", na.rm=TRUE, progress="text")
ESAmean <- zonal(value, ESA, "mean", na.rm=TRUE, progress="text")
ESAsum <- zonal(value, ESA, "sum", na.rm=TRUE, progress="text")
write.csv(ESAsd, "./ESAsd.csv", row.names = FALSE)
write.csv(ESAmean, "./ESAmean.csv", row.names = FALSE)
write.csv(ESAsum, "./ESAsum.csv", row.names = FALSE)


## tryied but didn't work
#Analysis by country
counytry <- readOGR(".", "gadm28_adm0")
head(counytry[,c(2,4)])
counytry <- counytry[,c(2,4)]
CTRYsd <- extract(value, counytry, fun=function(x)sd(x, na.rm=TRUE), df=TRUE)
CTRYmean <- extract(value, counytry, fun="mean", na.rm=TRUE)
CTRYsum <- extract(value, counytry, "sum", na.rm=TRUE, progress="text")
write.csv(CTRYsd, "./ESAsd.csv", row.names = FALSE)
write.csv(CTRYmean, "./ESAmean.csv", row.names = FALSE)
write.csv(CTRYsum, "./ESAsum.csv", row.names = FALSE)