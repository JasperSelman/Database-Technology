classdef SmoothScan < IndexScan & handle
    properties
        thresholdM23    = 1;
        thresholdM34    = 0.005;
        
        previousPage = -1;
    end      

    methods
        function obj = SmoothScan(Data)
            obj@IndexScan(Data);
        end
        
        function page_card = parsePage(obj, pagenum)
            page_card = 0;
            
            PAGE = obj.Data(:,pagenum);
            
            if(PAGE(1) == -1)
                return;
            end
            
            %Check if sequential or random
            if(pagenum == obj.previousPage + 1)
                obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
            else
                obj.randomPagePenalty = obj.randomPagePenalty + 1;
            end
            obj.previousPage = pagenum;

            %Look for all the 1's in this page
            for j = 1 : size(PAGE,1)               
                if(PAGE(j) == 1)            
                    obj.returnPenalty = obj.returnPenalty + 1; 
                    page_card = page_card + 1;      
               end
            end 

            %Mark the page as done
            obj.Data(1,pagenum) = -1;
            
        end
        
        function smoothscan(obj)
            %Starting mode = 2 (Pessimistic Approach)
            curr_card = 0;
            M4mult = 0.00;

            %Create a non-clustered index
            index = find(obj.Data)';
            index(randperm(numel(index))) = index;
            index = [ index zeros(1,size(obj.Data,1) - ...
                mod(numel(index),size(obj.Data,1)))];
            index = reshape(index,size(obj.Data,1),[]);
                  
            %Change thresholds from selectivity to cardinality
            obj.thresholdM23 = obj.thresholdM23 * numel(obj.Data);
            obj.thresholdM34 = obj.thresholdM34 * numel(obj.Data);
            
            %%
            % Walk the tree
            obj.randomPagePenalty = obj.randomPagePenalty + obj.height;
            
            for LEAF = index               
                %Pay a randompagepenalty for jumping to the next leaf
                obj.randomPagePenalty = obj.randomPagePenalty + 1;
                %obj.previousPage = -1;
                
                for TUPLE = LEAF'
                    %Exit if we find end of valid values (0's)
                    if(TUPLE == 0)
                        break;
                    end
                    %Set the max number of seq fetches based on the mode
                    if(curr_card >= obj.thresholdM34)
                        M4mult = M4mult + 0.6; %We are in MODE 3+ (4)
                        max_seq = 256 * ceil(M4mult);
                    elseif(curr_card >= obj.thresholdM23)
                        max_seq = 200;            %We are in MODE 3
                    else
                        max_seq = 1;            %We are in MODE 2
                    end
                    
                    %find to which page i points
                    pagenum = ceil(TUPLE / size(obj.Data,1));
                    
                    %Find the real max number of seq fetches
                    ubound = pagenum + max_seq - 1;
                    if(ubound > size(obj.Data,2))
                        ubound = size(obj.Data,2); 
                    end
                    for cnt = pagenum : ubound
                        if(obj.Data(1,cnt) == -1)
                            break;
                        end
                    end
                    
                    %Sequential parse cnt number of pages
                    for i = pagenum : cnt
                        curr_card = curr_card + parsePage(obj,i);
                    end              
                end
            end
            
       

        end
    end
end