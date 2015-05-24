%% RESET
clear all;
close all;

%% INIT
PAGECNT = 100; %Totale aantal pagina's
TUPLECNT = 10; %Aantal tuples per pagina
SELECTIVITIES = [.01 .02 .05 .1 .2 .4 .6 .8 1];%Percentage (tussen 0...1) van de tuples die aan de query zouden voldoen 
fsPenalty = zeros(1,length(SELECTIVITIES));
isPenalty = zeros(1,length(SELECTIVITIES));

for i=1:length(SELECTIVITIES)
    SELECTIVITY = SELECTIVITIES(i);
    %# Fill the array with 0 and 1 and reorder
    Data = [ones(TUPLECNT,(SELECTIVITY*PAGECNT)) zeros(TUPLECNT,((1-SELECTIVITY)*PAGECNT))];        
    Data(randperm(numel(Data))) = Data;

    %% RUN a full scan on the data above
    fs = FullScan(Data);
    fs.scan();
    fs
    fsPenalty(i)= fs.returnPenalty;
    clear fs;

    %% RUN an index scan on the data above
    is = IndexScan(Data);
    is.scan();
    is
    isPenalty(i)= is.returnPenalty;
    clear is;

end

fsPenalty
isPenalty
