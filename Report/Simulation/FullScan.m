classdef FullScan < Scan & handle
    properties

    end      

    methods
        function obj = FullScan(Data)
            obj@Scan(Data)
        end
        
        function scan(obj)
            %first access is random
            obj.sequentialPagePenalty = obj.sequentialPagePenalty - 1;
            obj.randomPagePenalty = obj.randomPagePenalty + 1;
            
            %For each column in Data (which are the pages)
            for i = 1 : size(obj.Data,2)
                obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                column = obj.Data(:,i);
                %For each tuple in page
                for j = 1 : size(column,1)
                   if(column(j) == 1)
                      obj.returnPenalty = obj.returnPenalty + 1; 
                   end
                end               
            end
        end
    end
end