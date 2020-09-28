
Source code for paper: SIMIT: Subjectively Interesting Motifs in Time Series

This folder contains the source code for Entropy submission:
SIMIT: Subjectively Interesting Motifs in Time Series

=======================
Set up
=======================

- Environment: Matlab R2016b, Python2.7

- Requirement:

    --numpy 1.15.2
    —-ortools 6.10


=======================
Data
=======================
Our paper describes the results on a synthetic and two real-world dataset. All the dataset is put in the folder named ‘data’.

- Synthesized time series:

  This time series is synthesised based on prototypes taken from 2 subsequence instances in the UCR Trace Data.

[1]Chen, Y.; Keogh, E.; Hu, B.; Begum, N.; Bagnall, A.; Mueen, A.; Batista, G. The UCR Time Series Classification Archive, 2015. www.cs.ucr.edu/~eamonn/time_series_data/

  Local directory: ‘data/Trace’   —— the original Trace data
                   ‘data/synthesized_dataset.mat’   —— the synthesized data



- MIT-BIH arrhythmia ECG recording:

  This data set is recording #205 in the MIT-BIH Arrhythmia DataBase.

[2]Moody, G.B.; Mark, R.G. The impact of the MIT-BIH Arrhythmia Database. IEEE Engineering in Medicine and Biology Magazine 2001, 20, 45–50.

  Local directory: ‘data/arrhythmia’



- Belgium Power Load Data:

  This data set is taken from Open Power System Data. The primary source of this data is ENTSO-E Data Portal/Power Statistics.

[3]Open power system data. Data Package Time series. Version 2018-03-13, 2018.
[4]ENTOSO-E. Detailed hourly load data for all countries 2006-2015. https://www.entsoe.eu/data/data- portal/, 2015.

   Local directory: ‘data/BE_load.mat’



=======================
Run
=======================

- Motif discovery using our SI measure:
  run script ‘main.m’ to generate results

- Studying the effects of the pruning factor:
  run script ‘test_prunningFactor.m’

- Creating the synthetic time series—‘synthesized_dataset.mat’:
  run script ’synthesize_TS.m’ to construct the dataset

- Run time:
  the runtime can be measured by putting 'tic' and 'toc' commands in script ‘main.m’ for each setting of l and n.
  only the runtime for identifying the initial motif set on the ECG time series is measured. The function ‘instances_for_initial_template’ implements this step.
