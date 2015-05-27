classdef SwitchScan < Scan & IndexScan & FullScan & handle
    properties
        treshold = 30;
    end      

    methods
        function obj = SwitchScan(Data)
            obj@Scan(Data)
        end
        
        function switchscan(obj, card)
            curr_card = 0;
            
            if(card < obj.threshold)
                %Index Scan
                for i = 1 : numel(obj.Data)
                    if(obj.Data(i) == 1)
                        curr_card = curr_card + 1;
                        if(curr_card > obj.treshold)
                            break;
                        end
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
                for i = 1 : size(obj.Data,2)
                    obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                    column = obj.Data(:,i);
                    for j = 1 : size(column,1)
                       if(column(j) == 1)
                          obj.returnPenalty = obj.returnPenalty + 1; 
                       end
                    end               
                end
            else
                %Full scan
                for i = 1 : size(obj.Data,2)
                    obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                    column = obj.Data(:,i);
                    for j = 1 : size(column,1)
                        if(column(j) == 1)
                            curr_card = curr_card + 1;
                            if(curr_card > obj.treshold)
                                break;
                            end
                            obj.returnPenalty = obj.returnPenalty + 1; 
                       end
                    end               
                end
                %Index Scan
                for i = 1 : numel(obj.Data)
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
            end
            
        end
        
    end
end