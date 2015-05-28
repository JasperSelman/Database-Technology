classdef SwitchScan < Scan & IndexScan & FullScan & handle
    properties
        threshold = 0.01;
    end      

    methods
        function obj = SwitchScan(Data)
            obj@Scan(Data)
        end
        
        function switchscan(obj, card)
            exp_selectivity = floor(numel(obj.Data) / card);
            curr_card = 0;
            
            if(exp_selectivity < obj.threshold)
                %Index Scan 
                for i = 1 : numel(obj.Data)
                    if(curr_card > card)
                        break;
                    end
                    if(obj.Data(i) == 1)
                        curr_card = curr_card + 1;
                        obj.randomPagePenalty = obj.randomPagePenalty + 1;
                        obj.returnPenalty = obj.returnPenalty + 1; 
                        cnt = cnt + 1;
                        if(cnt == obj.Ps)
                            obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                            cnt = 0;
                        end
                    end                
                end

                %Full scan
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
                
            else
                %Full Scan
                
                %Index Scan
                %superclass call
            end
           
            
        end
        
    end
end