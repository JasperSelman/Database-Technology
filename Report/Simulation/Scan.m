classdef Scan < handle
	properties (Constant)
	   
    end

    properties
        Data;
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