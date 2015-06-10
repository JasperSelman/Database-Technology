%% RESET
clear all;
close all;

%% INIT
PAGECNT = 100000; %Totale aantal pagina's
TUPLECNT = 10; %Aantal tuples per pagina
SELECTIVITIES = [.02 .015 .01 .009 .008 .007 .006 .005 .004 .003 .002 .001 .0005 .0001 .000001];%Percentage (tussen 0...1) van de tuples die aan de query zouden voldoen 
randomfactor = 20; %Penalty Random vs Sequential is 20:1
randomfactor2 = 1/10000; %Penalty Return vs Sequential is 1:10000
fsPenaltySeq = zeros(1,length(SELECTIVITIES));
isPenaltySeq = zeros(1,length(SELECTIVITIES));
fs.randomPagePenalty = zeros(1,length(SELECTIVITIES));
is.randomPagePenalty = zeros(1,length(SELECTIVITIES));

%0.005*PAGECNT*TUPLECNT; %for random factor 20 from selectivity > 0.005 full scan performs better

for i=1:length(SELECTIVITIES)
    i
    SELECTIVITY = SELECTIVITIES(i);
    %# Fill the array with 0 and 1 and reorder]
    cardinality = 49*SELECTIVITY;
    size = int64((1-SELECTIVITY)*PAGECNT);
    Data = [zeros(TUPLECNT,size) ones(TUPLECNT,((SELECTIVITY+1/PAGECNT)*PAGECNT))  ];
    %memory
    %Data(randperm(numel(Data))) = Data;

    %% RUN a full scan on the data above
    fs = FullScan(Data);
    fs.scan();
    fs;
    fsPenaltyRand(i)= fs.randomPagePenalty;
    fsPenaltySeq(i)= fs.sequentialPagePenalty;
    fsPenaltyReturn(i)= fs.returnPenalty;
    clear fs;

    %% RUN an index scan on the data above
    is = IndexScan(Data);
    is.indexscan();
    is;
    isPenaltyRand(i)= is.randomPagePenalty;
    isPenaltySeq(i)= is.sequentialPagePenalty;
    isPenaltyReturn(i)= is.returnPenalty;
    clear is;

    %% RUN a switch scan on the data above
    ss = SwitchScan(Data);
    ss.switchscan(cardinality);
    ss
    ssPenaltyRand(i) = ss.randomPagePenalty;
    ssPenaltySeq(i)= ss.sequentialPagePenalty;
    ssPenaltyReturn(i)= ss.returnPenalty;
    clear ss;

end
%% TOTAL penalties
fsPenalty=fsPenaltyRand*randomfactor+fsPenaltySeq+randomfactor2*fsPenaltyReturn; 
isPenalty=isPenaltyRand*randomfactor+isPenaltySeq+randomfactor2*isPenaltyReturn; 
ssPenalty=ssPenaltyRand*randomfactor+ssPenaltySeq+randomfactor2*ssPenaltyReturn;

%% FIGURE for random penalty
semilogy( SELECTIVITIES,fsPenalty,'x-', SELECTIVITIES,isPenalty,'x-', SELECTIVITIES,ssPenalty,'x-');
title('Penalties for Range query on non-clustered data')
xlabel('Selectivity')
ylabel('Penalty')
legend('Full Scan','Index Scan', 'Switch Scan')

%%
