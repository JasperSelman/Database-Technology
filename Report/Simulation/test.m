%% RESET
clear all;
close all;

%% INIT
PAGECNT = 100000; %Totale aantal pagina's
TUPLECNT = 10; %Aantal tuples per pagina
SELECTIVITIES = [.02 .015 .01 .009 .008 .007 .006 .005 .004 .003 .002 .001 .0005 .0001 .000001];%Percentage (tussen 0...1) van de tuples die aan de query zouden voldoen 
randomfactor = 20; %Penalty Random vs Sequential is 10:1
fsPenaltySeq = zeros(1,length(SELECTIVITIES));
isPenaltySeq = zeros(1,length(SELECTIVITIES));
fs.randomPagePenalty = zeros(1,length(SELECTIVITIES));
is.randomPagePenalty = zeros(1,length(SELECTIVITIES));
cardinality = 0.005*PAGECNT*TUPLECNT; %for random factor 20 from selectivity > 0.005 full scan performs better

for i=1:length(SELECTIVITIES)
    i
    SELECTIVITY = SELECTIVITIES(i);
    %# Fill the array with 0 and 1 and reorder
    size = int64((1-SELECTIVITY)*PAGECNT);
    Data = [ones(TUPLECNT,((SELECTIVITY+1/PAGECNT)*PAGECNT)) zeros(TUPLECNT,size) ];
    %memory
    %Data(randperm(numel(Data))) = Data;

    %% RUN a full scan on the data above
    fs = FullScan(Data);
    fs.scan();
    fs;
    fsPenaltyRand(i)= fs.randomPagePenalty;
    fsPenaltySeq(i)= fs.sequentialPagePenalty;
    clear fs;

    %% RUN an index scan on the data above
    is = IndexScan(Data);
    is.indexscan();
    is;
    isPenaltyRand(i)= is.randomPagePenalty;
    isPenaltySeq(i)= is.sequentialPagePenalty;
    clear is;

    %% RUN a switch scan on the data above
    ss = SwitchScan(Data);
    ss.switchscan(cardinality);
    ss
    ssPenaltyRand(i) = ss.randomPagePenalty;
    ssPenaltySeq(i)= ss.sequentialPagePenalty;
    clear ss;

end

fsPenalty=fsPenaltyRand*randomfactor+fsPenaltySeq; 
isPenalty=isPenaltyRand*randomfactor+isPenaltySeq; 
ssPenalty=ssPenaltyRand*randomfactor+ssPenaltySeq;

%% FIGURE for random penalty
semilogy( SELECTIVITIES,fsPenalty,'x-', SELECTIVITIES,isPenalty,'x-', SELECTIVITIES,ssPenalty,'x-');
title('Penalties for Range query on non-clustered data')
xlabel('Selectivity')
ylabel('Penalty')
legend('Full Scan','Index Scan', 'Switch Scan')


%%
