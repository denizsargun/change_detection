classdef klM < handle
    % Kullback Leibler distance test
    properties
        delayT
        eps
        ex
        iProj
        iProjSet
        it
        klMean
        klMeanRange
        klRadius
        klRadiusRange
        methodName
        mtbfT
        numberOfSettings
        pdT
        pfaT
        utility
    end
    
    methods
        function obj = klM(experiment)
            obj.ex = experiment;
            % eps = min abs difference among alphabet letters/1e5
            obj.eps = min(abs(obj.ex.alphabet- ...
                circshift(obj.ex.alphabet,1)))/1e5;
            obj.klMeanRange = obj.ex.klMeanRange;
            obj.klMean = obj.klMeanRange(1);
            obj.klRadiusRange = obj.ex.klRadiusRange;
            obj.klRadius = obj.klRadiusRange(1);
            obj.methodName = 'klM';
            obj.numberOfSettings = length(klMeanRange) ...
                *length(klRadiusRange);
            obj.utility = obj.ex.utility;
            % cell of i projections, one per kl mean
            obj.iProjSet = obj.utility.i_proj(obj.ex.unchangedDist, ...
                obj.klMeanRange,obj.eps);
            obj.iProj = obj.iProjSet(1);
            % tests need ex and utility objects
            obj.delayT = delayT(obj);
            obj.mtbfT = mtbfT(obj);
            obj.pdT = pdT(obj);
            obj.pfaT = pfaT(obj);
        end
        
        function isChange = is_change(obj,dist)
            % decide change if mean and kl distance is above threshold
            % 0/1 output
            meanChange = obj.mean_change(dist);
            klChange = obj.kl_change(dist);
            isChange = and(meanChange,klChange);
        end
        
        function meanChange = mean_change(obj,dist)
            % decide whether the change in mean is above threshold
            % 0/1 output
            meanChange = obj.utility.mean(dist) >= obj.klMean;
        end
        
        function klChange = kl_change(obj,dist)
            % decide whether kl distance is above threshold, 0/1 output
            klChange = obj.utility.kl_distance(dist,obj.iProj) ...
                >= obj.klRadius;
        end
        
        function update(obj)
            if obj.klRadius ~= obj.klRadiusRange(end)
                klRadiusIndex = find(obj.klRadius == obj.klRadiusRange);
                obj.klRadius = obj.klRadiusRange(klRadiusIndex+1);
            else
                klMeanIndex = find(obj.klMean == obj.klMeanRange);
                obj.klRadius = obj.klRadiusRange(1);
                obj.klMean = obj.klMeanRange(klMeanIndex+1);
                obj.iProj = obj.iProjSet(klMeanIndex+1);
            end
            
        end
        
    end
    
end