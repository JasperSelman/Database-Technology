%% RESET
clear all;
close all;

%% INIT
PAGECNT = 100; %Totale aantal pagina's
TUPLECNT = 10; %Aantal tuples per pagina
SELECTIVITY = .2; %Percentage (tussen 0...1) van de tuples die aan de query zouden voldoen 

%# Fill the array with 0 and 1 and reorder
Data = [ones(TUPLECNT,(SELECTIVITY*PAGECNT)) zeros(TUPLECNT,((1-SELECTIVITY)*PAGECNT))];        
Data(randperm(numel(Data))) = Data;

%% RUN a full scan on the data above
fs = FullScan(Data);
fs.scan();
fs