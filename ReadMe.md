# Agilent B0 data

*Authors: Brendan, Shanshan*

This folder contains various data regarding the B0 distribution from of the MRI-Linac magnet, as well as code to read it. In the wiki of this repository there is some analysis of the various data we have available.
At the time of writing it is not known how well this correlates with the current state of the magnet!! 

![](C:\Users\Brendan\Dropbox (Sydney Uni)\abstracts,presentations etc\MATLAB\Agilent_B0_Analysis\_resources\5thOrder_3D.png)



## Usage

This repository just has a few basic scripts. To repeat the analysis presented in the wiki you need access to Brendans spherical harmonics code

### Simulation data

The simulation data is at data/Agilent_Naked_150.table and is from an OPERA simulation of the coil fields as provided by Agilent. In general, magnets as designed do not perfectly match magnets as built. Nevertheless, this gives a good indication of the theoretical B0. In particular the higher order harmonics are fairly inherent to the design, and represent an upper limit on the achievable homogeneity.

This data can be read and analyzed using AnalyseSimulationData.m.

### Shimming data

The pdf data/field_record_mri-linac contains data measured by Agilent at initial magnet commissioning. Each page of this pdf contains one shimming iteration. The last page therefore indicates the most recent state of the magnet that we know about. To interpret the data in the PDF: each of the top rows has real field values in z. Then the rest of the data is written relative to this. so do:

	RealValue = TopRowValue + (RestOfValues * 1e-6)

Unfortunately this factor doesn't appear consistent. On some sheets it's 1e-6, on others 1-7. So you have to be careful. I have carried out the above process for the last shimming iteration, 15. This is stored in data/main_field15_BW.csv. The coordinate system for this data is constructed based on information and code provided by Feng Liu and Shanshan.

This data can be read in using ReadAgilentData.m. This will also output an opera style *.table file, which can be read using AnalyseAgilentData.m. The latter again requires a copy of Brendans spherical harmonics code

## Directory Structure

- data: contains the raw data files
- _resources: contains pretty pictures ;-)

