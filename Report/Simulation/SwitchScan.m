classdef SwitchScan < IndexScan & handle
    properties
        threshold = 0.01;
    end      

    methods
        function obj = SwitchScan(Data)
            obj@IndexScan(Data);
        end
        
        function switchscan(obj, card)
            exp_selectivity = card / numel(obj.Data);
            Switch = false;
            
            if(exp_selectivity <= obj.threshold )
                curr_card = 0;
                cnt = 0;

                %We assume range queries, hence we go trough the tree only once
                obj.randomPagePenalty = obj.height;

                for i = 1 : numel(obj.Data)
                    if(curr_card > card)
                        Switch = true;
                        break;
                    end
                    %We assume non clustered data, hence a random access for
                    %each tuple
                    if(obj.Data(i) == 1)
                        curr_card = curr_card + 1;
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
                
                if(Switch)
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
                
              
            else
                non_card = 0;
                %Full Scan         
                obj.sequentialPagePenalty = obj.sequentialPagePenalty - 1;
                obj.randomPagePenalty = obj.randomPagePenalty + 1;
         
                for i = 1 : size(obj.Data,2)
                    if(non_card > numel(obj.Data)- card)
                        Switch = true;
                        break;
                    end
                    obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                    column = obj.Data(:,i);
                    %For each tuple in page
                    for j = 1 : size(column,1)
                       if(column(j) == 1)
                          obj.returnPenalty = obj.returnPenalty + 1; 
                       else
                          non_card = non_card + 1;
                       end
                    end               
                end
                
                %Index Scan
                if(Switch)
                        cnt = 0;
            
            %We assume range queries, hence we go trough the tree only once
            obj.randomPagePenalty = obj.randomPagePenalty + obj.height;
            
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
        
    end
end