# ------------------------------------------------------------------------------
#                    Concawe Extension 22: general info
# ------------------------------------------------------------------------------

# paths
data.folder <- file.path('data')
results.folder <- file.path('results')

# vehicle type definitions
vehicle_types <- c('C_BUS_<III', 'C_BUS_VI', 'D_BUS_<III', 'D_BUS_IV', 'D_BUS_V', 
                   'D_BUS_VI', 'D_HDV_<III', 'D_HDV_IV', 'D_HDV_V', 'D_HDV_VI', 
                   'D_HDV_VII', 'P_HDV_<III', 'P_TWH_<3', 'D_LDV_<3', 'D_LDV_4', 
                   'D_LDV_5', 'D_LDV_6', 'D_LDV_6DT', 'D_LDV_6D', 'D_LDV_7', 
                   'P_LDV_<3', 'P_LDV_4', 'P_LDV_5', 'P_LDV_6', 'P_LDV_7', 
                   'C_CAR_<3', 'C_CAR_4', 'C_CAR_5', 'C_CAR_6', 'D_CAR_<3', 
                   'D_CAR_4', 'D_CAR_5', 'D_CAR_6', 'D_CAR_6DT', 'D_CAR_6D', 
                   'D_CAR_7', 'P_CAR_<3', 'P_CAR_4', 'P_CAR_5', 'P_CAR_6', 
                   'P_CAR_7', 'E_CAR_ALL')
vehicle_types_short <- gsub('_', '', vehicle_types)
vehicle_types_short <- gsub('<', '', vehicle_types_short)
isEuro7 <- grepl('7', vehicle_types) | grepl('VII', vehicle_types)
Euro7_vehicle_types <- vehicle_types[isEuro7]
Euro7_vehicle_types <- sort(factor(Euro7_vehicle_types, ordered = T,
                                   levels = c('P_CAR_7', 'D_CAR_7', 'P_LDV_7', 'D_LDV_7', 'D_HDV_VII')))
# order the P<D, CAR<LDV<HDV
Euro7_vehicle_types_short <- gsub('_', '', Euro7_vehicle_types)

# Baechlin correlation 
A <- 29; B <- 35; C <- 0.217

# Baechlin: NO2 = f(NOx)
no2.baechlin <- function(nox) {
  no2 <- A * nox / (B + nox) + C * nox
  no2.gt.nox <- no2 > nox
  no2[no2.gt.nox] <- nox[no2.gt.nox]
  return(no2)
}


