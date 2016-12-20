# blink-finder
A semi-automated pipeline for extraction of blinks from emotiv EEG data, based on MATLAB, EEGLAB and Corrmap.


This tool performs blink extraction and counting in 3 steps, given user input: 
1. Read file and separate into different trials
2. Run ICA, given a list of bad segments to cut out
3. Blink count and timings, given a blink example template
