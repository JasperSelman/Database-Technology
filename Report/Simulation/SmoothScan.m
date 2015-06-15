classdef SmoothScan < IndexScan & handle
    properties
        thresholdM2 = 0.01;
        thresholdM3 = 0.05;
        thresholdM4_4 = 0.10;
        thresholdM4_8 = 0.15;
        sequentialPagePenalty_2 = 0;
        sequentialPagePenalty_4 = 0;
        sequentialPagePenalty_8 = 0;
    end      

    methods
        function obj = SmoothScan(Data)
            obj@IndexScan(Data);
        end
        
        function smoothscan(obj)
            %Starting mode = 2 (Pessimistic Approach)
            mode = 2;
            cnt = 0;
            
            %Create a non-clustered index
            index = 1 : size(obj.Data,2);
            index(randperm(numel(index))) = index;
            curr_card = 0;
            
            %Change thresholds from selectivity to cardinality
            obj.thresholdM2 = obj.thresholdM2 * numel(obj.Data);
            obj.thresholdM3 = obj.thresholdM3 * numel(obj.Data);
            obj.thresholdM4_4 = obj.thresholdM4_4 * numel(obj.Data);
            obj.thresholdM4_8 = obj.thresholdM4_8 * numel(obj.Data);
                  
            %% MODE 2
            %- Index scan with scanning rest of page
            %- Keep track of scanned page
            
            % Walk the tree
            obj.randomPagePenalty = obj.randomPagePenalty + obj.height;
            cnt = 0;
            
            % For each column in Data (which are the pages)
            for i = index
                %quit this mode if the mode is incremented
                if(curr_card >= obj.thresholdM2)
                	mode = 3;
                	break;
                end
                
                % Select a page according to the index
                obj.randomPagePenalty = obj.randomPagePenalty + 1;
                PAGE = obj.Data(:,i);
                
                % For each tuple 
                %(We run trough the whole page, even if the card is to high)
                for j = 1 : size(PAGE,1)               
                    if(PAGE(j) == 1)                        
                        obj.returnPenalty = obj.returnPenalty + 1; 
                        curr_card = curr_card + 1;
                        cnt = cnt + 1;
                      
                        %For each Ps we have at least 1 sequential access as well
                        if(cnt == obj.Ps)
                            obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                            cnt = 0;
                        end
                     
                   end
                end 
                %Mark page as done
                obj.Data(1,i) = -1;
            end
            
            
            %% MODE 3
            %- Switch to Full scan
            %- Do not fetch pages that are already fetched
            if(mode == 3)
                nextIsRandom = true;
                
                for i = 1 : size(obj.Data,2)
                    %Check if we can go to the next mode
                    if(curr_card >= obj.thresholdM3)
                        mode = 4;
                        break;
                    end
                    
                    %Skip if the page is already fetched before
                    if(obj.Data(1,i) == -1)
                        nextIsRandom = true;
                        continue;
                    end
             
                    %Fetch the page sequentially if possible
                    PAGE = obj.Data(:,i);
                    if(nextIsRandom)
                        nextIsRandom = false;
                        obj.randomPagePenalty = obj.randomPagePenalty + 1;
                    else
                        obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                    end
                    
                    for j = 1 : size(PAGE,1)
                        if(PAGE(j) == 1)                        
                            obj.returnPenalty = obj.returnPenalty + 1; 
                            curr_card = curr_card + 1;
                        end
                    end  
                    obj.Data(1,i) = -1;
                end
                
            end
            
            %% MODE 3+ (4)
            %- Start fetching multiple pages at once
            %- 1, 2, 4 or 8 pages depending on if we find a 
            if(mode == 4)
                pcnt = 0;
                
                %Continue where we left
                for j = i : size(obj.Data,2)
                    %Skip if the page is already fetched before
                    %The next page is fetched random
                    if(obj.Data(1,j) == -1)
                        obj.randomPagePenalty = obj.randomPagePenalty + 1;
                        obj.sequentialPagePenalty = obj.sequentialPagePenalty - 1;
                        continue;
                    end
                    
                    if(pcnt == 0)
                        %Count the number of pages to fetch at once
                        %Maximum 8, stop counting when a fetched page is found
                        for pcnt = j : j+8
                            if(pcnt <= size(obj.Data,2))
                                if(obj.Data(1,pcnt) == -1)
                                    break;
                                end
                            else
                                break;
                            end
                        end
                        pcnt = pcnt - j;

                        %Correct the pcnt and add the burst pentalties
                        if(pcnt == 8 && curr_card >= obj.thresholdM4_8)
                            obj.sequentialPagePenalty_8 = obj.sequentialPagePenalty_8 + 1;
                        elseif(pcnt >= 4 && curr_card >= obj.thresholdM4_4)
                            pcnt = 4;
                            obj.sequentialPagePenalty_4 = obj.sequentialPagePenalty_4 + 1;
                        elseif(pcnt >= 2)
                            pcnt = 2;
                            obj.sequentialPagePenalty_4 = obj.sequentialPagePenalty_4 + 1;
                        else
                            pcnt = 1;
                            obj.sequentialPagePenalty = obj.sequentialPagePenalty + 1;
                        end
                    end
                    
                    %If the pages have been fetched in a burst
                    %We only have to count the 1's
                    if(pcnt >= 1)
                        PAGE = obj.Data(:,j);
                        for k = 1 : size(PAGE,1)
                            if(PAGE(k) == 1)                        
                                obj.returnPenalty = obj.returnPenalty + 1; 
                                curr_card = curr_card + 1;
                            end
                        end 
                        obj.Data(1,j) = -1;
                        pcnt = pcnt - 1;
                    end
                end
            end

        end
    end
end