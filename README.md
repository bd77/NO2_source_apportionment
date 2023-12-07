# NO<sub>x</sub> Source Apportionment for Air Quality Stations

This code calculates the NO<sub>2</sub> concentration at 3136 air quality stations in the EU27+UK for a user-defined scenario. A scenario consists of:
- A 2<sup>nd</sup> Clean Air Outlook scenario and year (**year** and **cao2_scenario** in config yaml)
- Definition of a new Euro7/VII emission standard. This is a list of emission factor 
  reductions with respect to Euro6/VI emission factors.
  (PCAR7: Euro 7 petrol cars, DCAR7: Euro 7 diesel cars, 
  PLDV7: Euro 7 petrol vans, DLDV7: Euro 7 diesel vans, 
  DHDVVII: Euro VII diesel trucks)
- GNFR sector reductions

## Software requirements

The application is written in R (https://cran.r-project.org/bin/windows/base/). The following packages are needed
- library(plyr)
- library(yaml)

## How to run a simulations?

Define a scenario in a YAML file. The structure of the YAML file is as follows:
```
Baseline_2035:
  cao2_scenario: Baseline
  year: 2035
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
```

A scenario is defined as a named list. The name of the scenario is 'Baseline_2035'. The following sub-sections have to be provided:
- **cao2_scenario** is the scenario name of the 2nd Clear Air Outlook. Possible names are: 
	- **Baseline** with available years 2015, 2020, 2025, 2030, 2035, 2040, 2045, and 2050
	- **Baseline+MTFR** with available years 2030 and 2050
	- **NAPCP** with available years 2015, 2020, 2025, 2030, 2035, 2040, 2045, and 2050
	- **1p5LIFE_D+NAPCP** with available years 2035, 2040, 2045, and 2050
	- **1p5TECH+NAPCP** with available years 2035, 2040, 2045, and 2050
	- **1p5LIFE+MTFR** with available year 2050

- **year** is a year for which the CAO2 scenaro is available
- Under **euro7_reduction_pct** a new Euro7/VII emission standard relative to Euro6/VI can be defined. For five vehicle types a reduction percentage has to be defined (10 means that that the emission factor is multiplied by 0.9):
	- **PCAR7**: The reduction percentage for Euro 7 petrol passenger cars with respect to the NO<sub>x</sub> emission factor of Euro 6 petrol cars.
	- **DCAR7**: The reduction percentage for Euro 7 diesel passenger cars with respect to the NO<sub>x</sub> emission factorEuro 6d diesel cars.
	- **PLDV7**: The reduction percentage for Euro 7 petrol vans with respect to the NO<sub>x</sub> emission factor of Euro 6 vans.
	- **DLDV7**: The reduction percentage for Euro 7 diesel vans with respect to the NO<sub>x</sub> emission factor Euro 6d vans.
	- **DHDVVII**: The reduction percentage for Euro VII diesel vans with respect to the NO<sub>x</sub> emission factor Euro 6d vans.
	- **sectors_list**: defines of a GNFR sector has to be included (1) or not (0). Also values between 0 and one are accepted. The value is applied to all the sector's emissions all over the domain.
 
## Run a scenario

From the command line invoke R to run the script 'NO2_at_stations.R' with as command line argument the YAML file defining one or more scenarios:

```
> Rscript NO2_at_stations.R input/Scenario_Euro7_proposals.yaml
```

The script writes the result to a folder called 'results' in the folder where the script NO2_at_stations.R located for each simulation defined in the YAML file. The name of the results file is 'Results_<scenario_name>.txt'. The column 'NO2_corr_rel' contains the annual average NO<sub>2</sub> concentrations in 3136 air quality stations in the EU27+UK. This concentration is the sum of the NO<sub>x</sub> contributions of non-road transport sectors and high-resolution NO<sub>x</sub> contributions from the road transport sector. The total NO<sub>x</sub> concentration was converted to an NO<sub>2</sub> concentration with the Bächlin correlation and corrected with the relative bias between model and observation in 2018. The model does not take into account street canyons.

