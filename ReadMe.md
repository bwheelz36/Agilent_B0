# Agilent B0 data

*Authors: Brendan, Shanshan*

This folder contains data taken from the initial B0 shimming of the magnet, performed by Agilent, as well as code to read it.
The raw data is contained in field_record_mri-linac. Each page of this pdf contains one shimming iteration. The last page therefore indicates the most recent state of the magnet, that we know about. At the time of writing it is not known how well this correlates with the current state of the magnet!! 

## Interpreting the data in the pdf

To interpret the data in the PDF: each of the top rows has real field values in z. Then the rest of the data is written relative to this. so do:
	
	RealValue = TopRowValue + (RestOfValues * 1e-6)
	
Unfortunately this factor doesn't appear consistent. On some sheets it's 1e-6, on others 1-7. So you have to be careful

## the data in main_field15_BW.csv

I have carried out the above process for the last shimming iteration, 15. This is stored in main_field15_BW.csv

## Coordinate system and reading the data

Each of the data points has an associated [x,y,z] coordinate. This coordinate system is constructed based on information Feng Liu provided, which is hopefully correct! See ReadAgilentData.m for details

## What the data tells us