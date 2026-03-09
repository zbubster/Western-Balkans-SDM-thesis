# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Create raster stacks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script is not as universal as it should be. During its execution,
# it creates stacks from the supplied rasters. These are divided into two parts:
# 1. those in the root directory,
# 2. those in the folder with CHELSA climate data.
# 
# For all grain levels, both raster sources are first loaded,
# named according to the file name, and sorted according to the selected order.
# A stack is then created and written to disk.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# dir with rasters ready to stack
stack_dir <- here::here("data", "__COMPATIBILITY__", "STACKS")
# where should be stacs svaed
stack_out <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS__")
if(!dir.exists(stack_out)){dir.create(stack_out)}

#wopt <- 

# layer order
pred_order <- c("glim", "aspect", "slope", "hli", "roughness", "TPI", "TRI", "TRIriley", "TRIrmsd", "twi")
clim_order <- c(base::sprintf("bio%02d", 1:19), "scd")


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 1000m

files_static_1000 <- base::list.files(
  path = stack_dir,
  pattern = "^(aspect|glim|hli|roughness|slope|TPI|TRI|TRIriley|TRIrmsd|twi)_1000\\.(tif|tiff)$",
  full.names = TRUE
)
names_static_1000 <- base::sub("_1000\\.(tif|tiff)$", "", base::basename(files_static_1000))
files_static_1000 <- files_static_1000[base::order(base::match(names_static_1000, pred_order))]

files_clim_1000 <- base::list.files(
  path = base::file.path(stack_dir, "RECENT", "1000_1981-2010"),
  pattern = "^CHELSA_(bio[0-9]{2}|scd)_1981-2010_AOI\\.tif$",
  full.names = TRUE
)
names_clim_1000 <- base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_1000))
files_clim_1000 <- files_clim_1000[base::order(base::match(names_clim_1000, clim_order))]

stack_1000 <- terra::rast(base::c(files_static_1000, files_clim_1000))
names(stack_1000) <- base::c(
  base::sub("_1000\\.(tif|tiff)$", "", base::basename(files_static_1000)),
  base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_1000))
)

terra::writeRaster(stack_1000, filename = file.path(stack_out, "stack_1000.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 500m

files_static_500 <- base::list.files(
  path = stack_dir,
  pattern = "^(aspect|glim|hli|roughness|slope|TPI|TRI|TRIriley|TRIrmsd|twi)_500\\.(tif|tiff)$",
  full.names = TRUE
)
names_static_500 <- base::sub("_500\\.(tif|tiff)$", "", base::basename(files_static_500))
files_static_500 <- files_static_500[base::order(base::match(names_static_500, pred_order))]

files_clim_500 <- base::list.files(
  path = base::file.path(stack_dir, "RECENT", "500_1981-2010"),
  pattern = "^CHELSA_(bio[0-9]{2}|scd)_1981-2010_AOI\\.tif$",
  full.names = TRUE
)
names_clim_500 <- base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_500))
files_clim_500 <- files_clim_500[base::order(base::match(names_clim_500, clim_order))]

stack_500 <- terra::rast(base::c(files_static_500, files_clim_500))
names(stack_500) <- base::c(
  base::sub("_500\\.(tif|tiff)$", "", base::basename(files_static_500)),
  base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_500))
)

terra::writeRaster(stack_500, filename = file.path(stack_out, "stack_500.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 200m

files_static_200 <- base::list.files(
  path = stack_dir,
  pattern = "^(aspect|glim|hli|roughness|slope|TPI|TRI|TRIriley|TRIrmsd|twi)_200\\.(tif|tiff)$",
  full.names = TRUE
)
names_static_200 <- base::sub("_200\\.(tif|tiff)$", "", base::basename(files_static_200))
files_static_200 <- files_static_200[base::order(base::match(names_static_200, pred_order))]

files_clim_200 <- base::list.files(
  path = base::file.path(stack_dir, "RECENT", "200_1981-2010"),
  pattern = "^CHELSA_(bio[0-9]{2}|scd)_1981-2010_AOI\\.tif$",
  full.names = TRUE
)
names_clim_200 <- base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_200))
files_clim_200 <- files_clim_200[base::order(base::match(names_clim_200, clim_order))]

stack_200 <- terra::rast(base::c(files_static_200, files_clim_200))
names(stack_200) <- base::c(
  base::sub("_200\\.(tif|tiff)$", "", base::basename(files_static_200)),
  base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_200))
)

terra::writeRaster(stack_200, filename = file.path(stack_out, "stack_200.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 100m

files_static_100 <- base::list.files(
  path = stack_dir,
  pattern = "^(aspect|glim|hli|roughness|slope|TPI|TRI|TRIriley|TRIrmsd|twi)_100\\.(tif|tiff)$",
  full.names = TRUE
)
names_static_100 <- base::sub("_100\\.(tif|tiff)$", "", base::basename(files_static_100))
files_static_100 <- files_static_100[base::order(base::match(names_static_100, pred_order))]

files_clim_100 <- base::list.files(
  path = base::file.path(stack_dir, "RECENT", "100_1981-2010"),
  pattern = "^CHELSA_(bio[0-9]{2}|scd)_1981-2010_AOI\\.tif$",
  full.names = TRUE
)
names_clim_100 <- base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_100))
files_clim_100 <- files_clim_100[base::order(base::match(names_clim_100, clim_order))]

stack_100 <- terra::rast(base::c(files_static_100, files_clim_100))
names(stack_100) <- base::c(
  base::sub("_100\\.(tif|tiff)$", "", base::basename(files_static_100)),
  base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_100))
)

terra::writeRaster(stack_100, filename = file.path(stack_out, "stack_100.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 20m

files_static_20 <- base::list.files(
  path = stack_dir,
  pattern = "^(aspect|glim|hli|roughness|slope|TPI|TRI|TRIriley|TRIrmsd|twi)_20\\.(tif|tiff)$",
  full.names = TRUE
)
names_static_20 <- base::sub("_20\\.(tif|tiff)$", "", base::basename(files_static_20))
files_static_20 <- files_static_20[base::order(base::match(names_static_20, pred_order))]

files_clim_20 <- base::list.files(
  path = base::file.path(stack_dir, "RECENT", "20_1981-2010"),
  pattern = "^CHELSA_(bio[0-9]{2}|scd)_1981-2010_AOI\\.tif$",
  full.names = TRUE
)
names_clim_20 <- base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_20))
files_clim_20 <- files_clim_20[base::order(base::match(names_clim_20, clim_order))]

stack_20 <- terra::rast(base::c(files_static_20, files_clim_20))
names(stack_20) <- base::c(
  base::sub("_20\\.(tif|tiff)$", "", base::basename(files_static_20)),
  base::sub("^CHELSA_(.+)_1981-2010_AOI\\.tif$", "\\1", base::basename(files_clim_20))
)

terra::writeRaster(stack_20, filename = file.path(stack_out, "stack_20.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #