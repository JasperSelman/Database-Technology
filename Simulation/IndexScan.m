classdef IndexScan < Scan & handle
    properties (Constant)
        Ks = 4; %32 pointer in bytes
    end   
    
    properties (Access = private)
        Ps = 0;
        Ntuples = 0;    
        fanout = 0;     
        Nleaves = 0;    
        height = 0;     
    end      

    methods
        %constructor 
        function obj = IndexScan(Data)
            obj@Scan(Data);
            
            obj.Ps = size(obj.Data,1);
            obj.Ntuples = size(obj.Data,1) * size(obj.Data,2);
            obj.fanout = floor(obj.Ps / (1.2 * obj.Ks));
            obj.Nleaves = ceil(obj.Ntuples/obj.fanout);
            obj.height = ceil(log(obj.Nleaves)/log(obj.fanout))+1;
        end
        
        %scan function
        function scan(obj)
            %Calculate penalty for tree
        end
    end
end