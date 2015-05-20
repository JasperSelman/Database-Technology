%% RESET
clear all;
close all;

%% INIT
PAGECNT = 100;
TUPLECNT = 10;
SELECTIVITY = .2;

%# Fill the array with 0 and 1 and reorder
Data = [ones(TUPLECNT,(SELECTIVITY*PAGECNT)) zeros(TUPLECNT,((1-SELECTIVITY)*PAGECNT))];        
Data(randperm(numel(Data))) = Data;

%% RUN a full scan on the data above
fs = FullScan(Data);
fs.scan();
fs