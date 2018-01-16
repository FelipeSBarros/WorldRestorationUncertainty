## 1) Defining forested areas:
# Updating forested areas: 2017
# The 2017 biome data  (https://ecoregions2017.appspot.com/) where subsetted to:
# 'Mangroves'  'Temperate Broadleaf & Mixed Forests'  'Temperate Conifer Forests'  'Tropical & Subtropical Coniferous Forests'  'Tropical & Subtropical Dry Broadleaf Forests'  'Tropical & Subtropical Moist Broadleaf Forests' 
# The KML was sent to GEE and the analysis resultas done there, were clipped to this area;

## 2) Using GEE (https://code.earthengine.google.com/46c209046cecd3349e5b36eed5de67e3) the following analysiswas done:  
* Using Hansen's data v1.4(2000-2016), the forest loss were taken from forest density;  
* Forest remnants were maked to the forest areas defined on step 1;  
* The mean forest density density was estimated using a focal/movingwindow/kernel analysis considering ~5Km circle buffer;  

## 3) On PC (bash/gdal):
* Adequating GEE results, setting the same extent, and pixel alignment;  
# gdal warp para bioclim todo  
```
gdalwarp [--help-general] [--formats]
    [-s_srs srs_def] [-t_srs srs_def] [-to "NAME=VALUE"]* [-novshiftgrid]
    [-order n | -tps | -rpc | -geoloc] [-et err_threshold]
    [-refine_gcps tolerance [minimum_gcps]]
    [-te xmin ymin xmax ymax] [-te_srs srs_def]
    [-tr xres yres] [-tap] [-ts width height]
    [-ovr level|AUTO|AUTO-n|NONE] [-wo "NAME=VALUE"] [-ot Byte/Int16/...] [-wt Byte/Int16]
    [-srcnodata "value [value...]"] [-dstnodata "value [value...]"]
    [-srcalpha|-nosrcalpha] [-dstalpha]
    [-r resampling_method] [-wm memory_in_mb] [-multi] [-q]
    [-cutline datasource] [-cl layer] [-cwhere expression]
    [-csql statement] [-cblend dist_in_pixels] [-crop_to_cutline]
    [-of format] [-co "NAME=VALUE"]* [-overwrite]
    [-nomd] [-cvmd meta_conflict_value] [-setci] [-oo NAME=VALUE]*
    [-doo NAME=VALUE]*
    srcfile* dstfile
    
#g1
gdalwarp "/home/felipe/Repos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG1_5kmFocal.tif" -tr 0.00833333 -0.00833333 -te -180.0000000000000000 -59.9999400000000094 179.9998560000000225 90.0000000000000000 -r near "/home/felipe/Repos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG1_5kmFocal_aligned.tif" -overwrite

#g2
gdalwarp "/home/felipe/Repos//WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG2_5KmFocal.tif" -tr 0.00833333 -0.00833333 -te -180.0000000000000000 -59.9999400000000094 179.9998560000000225 90.0000000000000000 -r near "/home/felipe/Repos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG2_5kmFocal_aligned.tif" -overwrite

#g3
gdalwarp "/home/felipe/Repos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG3_5KmFocal.tif" -tr 0.00833333 -0.00833333 -te -180.0000000000000000 -59.9999400000000094 179.9998560000000225 90.0000000000000000 -r near "/home/felipe/Repos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG3_5kmFocal_aligned.tif" -overwrite
```
  
* Merging (Suming) all raster data aligned in the previous step  
```
gdal_calc.py --calc=expression --outfile=out_filename [-A filename]
             [--A_band=n] [-B...-Z filename] [other_options]

gdal_calc.py  -A  "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG1_5kmFocal_aligned.tif" -B "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG2_5kmFocal_aligned.tif" -C "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForestG3_5kmFocal_aligned.tif" --outfile="/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForest_5kmFocal_alignedMerged.tif" --calc="A+B+C"
```

* Removing 0 from ouside study area:  **NOT NECESSARY ANYMORE AFTER CHANGING THE BIOME TYPO AND USING CLIP FEATURE COLLECTION**

```
gdal_calc.py -A "/home/novaresio/Projetos/World Restoration Uncertainty/Results/GEE/1KMGlobalForest_5kmFocal_alignedMerged.tif" -B "/home/novaresio/Projetos/World Restoration Uncertainty/Biomas/forestAreasNotBin.tif" --outfile="/home/novaresio/Projetos/World Restoration Uncertainty/Results/GEE/1KMGlobalForest_5kmFocal_final.tif" --calc="A*B"
```
* Organinzing land use from ESA CCI to the same extent and the same resolution  

```
gdalwarp "/home/novaresio/Projetos/WorldRestorationUncertainty/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7/product/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif" -tr 0.00833333 -0.00833333 -te -180.0000000000000000 -59.9999400000000094 179.9998560000000225 90.0000000000000000 -r near "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/ESACCI_alignedResampled.tif" -overwrite
```

## 3) On PC (R):
* Applying the equation
```
library(raster)
result <- raster("/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForest_5kmFocal_alignedMerged.tif")

eq <- 1.37595 - 0.23498 * log10(result + 1)
plot(eq)
writeRaster(eq, "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForest_5kmFocal_Equation.tif")
```
* Normalizing equation
```
eq <- eq/maxValue(eq) # check if maxValue(eq) == 1.37595
writeRaster(eq, "./1KMGlobalForest_5kmFocal_EquationNorm.tif")
```
* Removing NON RESTORABLE AREAS
```
library(raster)
lanuse<- raster("/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/ESACCI_alignedResampled.tif")
lanuse2 <- (lanuse %in% c(10, 11, 12, 20, 30, 130, 150, 151, 152, 153))*lanuse
writeRaster(lanuse2, "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/ESAConsideredAreas.tif")

r <- raster ("/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/1KMGlobalForest_5kmFocal_EquationNorm.tif")
final <- r*(lanuse2>0)
writeRaster(final, "/home/novaresio/Projetos/WorldRestorationUncertainty/Results/GEE/finalMasked.tif")
```
