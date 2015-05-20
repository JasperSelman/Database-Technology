classdef Scan < handle
	properties (Constant)
	   
    end

    properties
        Data;
        treePenalty = 0;
        randomPagePenalty = 0;
        sequentialPagePenalty = 0;
        returnPenalty = 0;
    end      

    methods
        function obj = Scan(Data)
            obj.Data = Data;
        end
    end
end