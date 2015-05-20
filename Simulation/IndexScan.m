classdef IndexScan < Scan & handle
    properties (Constant)
        Ks = 4; %32 pointer in bytes
    end   
    
    properties (Access = private)
        Ps = 0;         % Page size (tuples per page)
        Ntuples = 0;    % Total number of tuples
        fanout = 0;     % fanout
        Nleaves = 0;    % Number of leaves
        height = 0;     % Height of the tree
    end      

    methods
        %constructor 
        function obj = IndexScan(Data)
            obj@Scan(Data);
            
            %see paper for formulas
            obj.Ps = size(obj.Data,1);
            obj.Ntuples = numel(obj.Data);
            obj.fanout = floor(obj.Ps / (1.2 * obj.Ks));
            obj.Nleaves = ceil(obj.Ntuples/obj.fanout);
            obj.height = ceil(log(obj.Nleaves)/log(obj.fanout))+1;
        end
        
        %scan function
        function scan(obj) 
            cnt = 0;
            
            %We assume range queries, hence we go trough the tree only once
            obj.randomPagePenalty = obj.height;
            
            for i = 1 : numel(obj.Data)
                %We assume non clustered data, hence a random access for
                %each tuple
                if(obj.Data(i) == 1)
                	obj.randomPagePenalty = obj.randomPagePenalty + 1;
                    obj.returnPenalty = obj.returnPenalty + 1; 
                    cnt = cnt + 1;
                    %For each Ps we have at least 1 sequential access as
                    %well
                    if(cnt == obj.Ps)
                        obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                        cnt = 0;
                    end
                end
                
            end
            
        end
    end
end