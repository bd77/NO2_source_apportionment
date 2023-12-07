# ------------------------------------------------------------------------------
#                       NO2 at air quality stations
# ------------------------------------------------------------------------------
"
This code calculates the NO2 concentration at 3136 air quality stations in the EU28.
A scenario consists of:
- A 2nd Clean Air Outlook scenario and year ('year' and 'cao2_scenario' in config yaml)
- Definition of a new Euro7/VII emission standard. This is a list of emission factor 
  reductions with respect to Euro6/VI emission factors.
  (PCAR7: Euro 7 petrol cars, DCAR7: Euro 7 diesel cars, 
  PLDV7: Euro 7 petrol vans, DLDV7: Euro 7 diesel vans, 
  DHDVVII: Euro VII diesel trucks)
- GNFR sector reductions

A scenario is defined with a YAML file. This is the structure:
________________________________________________________________________________
Baseline_2035:
    year: 2035
    cao2_scenario: Baseline
    euro7_reduction_pct: 
        PCAR7: 0
        DCAR7: 0
        PLDV7: 0
        DLDV7: 0
        DHDVVII: 0
    sectors_list:
        A_PublicPower: 1
        B_Industry: 1
        C_OtherStationaryComb: 1
        F_RoadTransport: 1
        G_Shipping: 1
        H_Aviation: 1
        I_Offroad: 1
        J_Waste: 1
        K_AgriLivestock: 1
        L_AgriOther: 1
________________________________________________________________________________
"

rm(list = ls())

# load necessary packages
library(plyr)
library(yaml)

# setwd("//fs.marvin.vito.local/storage/projects/concawe/Extension22/src/example_code_VITObelgium")
source('auxiliary_functions.R')


# read the input data
#-------------------
station.compliance.df <- read.table(file.path(data.folder, 'station_compliance_data.txt'),
                                    sep = ';', header = TRUE)
NOx_CAO2_kton_2018 <- station.compliance.df[station.compliance.df$year == 2018, 
                                            c("station_code", "NOx_CAO2_kton")]
station.compliance.df <- base::merge(station.compliance.df,
                                     NOx_CAO2_kton_2018,
                                     by = c("station_code"),
                                     suffixes = c('', '_2018'))

# Read scenario configurations from the yaml file
args = commandArgs(trailingOnly=TRUE)
runs_config <- read_yaml(args[1])
# runs_config <- read_yaml('data/stations_Euro7_proposal.yaml')
run_names <- names(runs_config)

# results of all the runs in the configuration file
station.tab.results.df <- data.frame()

# run_name <- "Baseline_2035"
# loop over scenario runs
for (run_name in run_names){
  print(run_name)
  cf <- runs_config[[run_name]]
  euro7_reduction_pct <- cf$euro7_reduction_pct
  sectors_list <- cf$sectors_list
  
  # filter data on Year, cao2_scenario,
  filter <- station.compliance.df$year == cf$year & station.compliance.df$cao2_scenario == cf$cao2_scenario
  stations.run.df <- station.compliance.df[filter,]
  
  # non-traffic contribution
  NOx_NonTraffic <- 0
  non.traffic.sectors <- names(sectors_list)[names(sectors_list) != 'F_RoadTransport']
  for (sector in non.traffic.sectors) {
    NOx_NonTraffic <- NOx_NonTraffic + stations.run.df[,paste0('NOx_', sector)] * sectors_list[[sector]]
  }
  
  # low-resolution traffic contribution
  # sum_euro7_fractions is a misleading name, better traffic_emissions_relative_to_noEuro7
  sum_euro7_fractions <- stations.run.df$fNOx_NotEuro7
  for (Euro7_type in Euro7_vehicle_types_short) {
    sum_euro7_fractions <- sum_euro7_fractions + 
      stations.run.df[,paste0('fNOx_', Euro7_type)] * (1 - euro7_reduction_pct[[Euro7_type]]/100)
  }
  stations.run.df$sum_euro7_fractions <- sum_euro7_fractions * sectors_list[['F_RoadTransport']]
  NOx_Traffic_LR <- stations.run.df$NOx_F_RoadTransport *
    sectors_list[['F_RoadTransport']] * sum_euro7_fractions
  
  # high-resolution traffic contribution
  NOx_Traffic_HR <- with(stations.run.df, NOx_NONEURO7_2cc * fNOx_NotEuro7 / fNOx_2030_NotEuro7)
  for  (Euro7_type in Euro7_vehicle_types_short) {
    NOx_Traffic_HR <- NOx_Traffic_HR + 
      stations.run.df[, paste0('NOx_', Euro7_type, '_2cc')] * 
      stations.run.df[, paste0('fNOx_', Euro7_type)] /
      stations.run.df[, paste0('fNOx_2030_', Euro7_type)] *
      (1 - euro7_reduction_pct[[Euro7_type]]/100)
  }
  NOx_Traffic_HR <- NOx_Traffic_HR * stations.run.df$NOx_CAO2_kton / stations.run.df$NOx_2030_kton                                
  
  # traffic contribution
  NOx_Traffic <- NOx_Traffic_LR + NOx_Traffic_HR
  NOx.traf.neg <- NOx_Traffic < 0
  print(paste0("Negative traffic contribution in ", sum(NOx.traf.neg, na.rm=T), 
               " cases of ", NROW(NOx.traf.neg)))
  n.stat.neg.traff <- length(unique(stations.run.df$station_code[NOx.traf.neg]))
  print(paste0("Negative traffic contribution in ", n.stat.neg.traff, " different stations"))
  # "Negative traffic contribution in 42 different stations"
  # negative contributions to 0
  NOx_Traffic[NOx.traf.neg] <- 0
  
  # sum non-traffic and traffic contributions
  stations.run.df$NOx_NonTraffic <- NOx_NonTraffic
  stations.run.df$NOx_Traffic <- NOx_Traffic
  stations.run.df$NOx_run <- NOx_NonTraffic + NOx_Traffic
  
  # NOx to NO2 (without bias correction)
  stations.run.df$NO2_wo_corr <- no2.baechlin(stations.run.df$NOx_run)
  
  # apply relative bias
  stations.run.df$NO2_corr_rel <- with(stations.run.df, NO2_wo_corr / rel_bias_2018)
  
  # write results
  station.results.file <- file.path(results.folder, paste0('Results_', run_name, '.txt'))
  if (!file.exists(station.results.file)) {
    write.table(data.frame(run_name = run_name, stations.run.df),
                station.results.file, sep = ";", row.names = F)
    print(paste('Results were written to', station.results.file))
  } else {
    print(paste(station.results.file, 'already exists. No results were stored.'))
  }
}

