classdef utility < handle
    
    % utility toolbox
    
    % dictionary
    % dist      = distribution
    % emp       = empirical
    % ex        = experiment
    % glr       = generalized likelihood ratio
    % i proj    = information projection
    % kl        = Kullback Leibler
    % mtbf      = mean time between failures
    % m proj    = moment projection
    % wcdd      = worst case detection delay
    
    properties
        ex
    end
    
    methods
        function obj = utility(experiment)
            obj.ex = experiment;
        end
        
        % initialize
        function setup(obj)
            % alphabet
            % alphabet is a sorted column vector
            obj.ex.alphabet = sort(obj.ex.alphabet(:));
            obj.ex.alpha = obj.mean(obj.ex.unchangedDist);
            obj.ex.alphabetSize = length(obj.ex.alphabet);
            
            % excel file
            date = clock;
            date(6) = round(date(6));
            lessThan = date<10;
            dateName = string(date);
            for i = 1:6
                if lessThan(i) == 1
                    dateName(i) = strcat("0",dateName(i));
                end
            end
            dateName = strjoin(dateName,'_');
            % try .xls or .xlsx
            obj.ex.storageFile = ...
                char(strcat('experiment','_',dateName,'.xls'));
            % add POI library to java path to use xlwrite
            javaaddpath('poi_library/poi-3.8-20120326.jar');
            javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
            javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
            javaaddpath('poi_library/xmlbeans-2.3.0.jar');
            javaaddpath('poi_library/dom4j-1.6.1.jar');
            % create excel file
            % use xlwrite insted of xlswrite
            xlwrite(obj.ex.storageFile,{'create excel file'});
            xlwrite(obj.ex.storageFile,{'alphabet'},1,'B1');
            xlwrite(obj.ex.storageFile,obj.ex.alphabet,1,'B2');
            xlwrite(obj.ex.storageFile,{'beta'},1,'C1');
            xlwrite(obj.ex.storageFile,obj.ex.beta,1,'C2');
            xlwrite(obj.ex.storageFile,{'glrThrRange'},1,'D1');
            xlwrite(obj.ex.storageFile,obj.ex.glrThrRange,1,'D2');
            xlwrite(obj.ex.storageFile,{'klMeanRange'},1,'E1');
            xlwrite(obj.ex.storageFile,obj.ex.klMeanRange,1,'E2');
            xlwrite(obj.ex.storageFile,{'klRadiusRange'},1,'F1');
            xlwrite(obj.ex.storageFile,obj.ex.klRadiusRange,1,'F2');
            xlwrite(obj.ex.storageFile,{'meanMeanRange'},1,'G1');
            xlwrite(obj.ex.storageFile,obj.ex.meanMeanRange,1,'G2');
            xlwrite(obj.ex.storageFile,{'it'},1,'H1');
            xlwrite(obj.ex.storageFile,obj.ex.it(:),1,'H2');
            xlwrite(obj.ex.storageFile,{'sampleSize'},1,'I1');
            xlwrite(obj.ex.storageFile,obj.ex.sampleSize,1,'I2');
            xlwrite(obj.ex.storageFile,{'unchangedDist'},1,'J1');
            xlwrite(obj.ex.storageFile,obj.ex.unchangedDist,1,'J2');
            
            % unchanged dist
            % column vector of dist
            obj.ex.unchangedDist = obj.ex.unchangedDist(:);
        end
        
        % utilities
        function d = mean(obj,dist)
            d = obj.ex.alphabet'*dist;
        end
        
        function iProjCell = i_proj(obj,dist,meanRange,eps)
            iProjCell = cell(length(meanRange),1);
            for i = 1:length(meanRange)
                mean = meanRange(i);
                % I-project dist to the convex set {mean(dist)>=mean}
                iProjCell{i} = dist;
                if obj.mean(iProjCell{i}) >= mean
                    continue % pass to nex next iteration of the for loop
                end
                
                % since the set is convex and alphabet is finite
                % the projection is the minimum tilt tilted distribution
                % tilt dist iteratively until error is small
                err = inf;
                while abs(err)>eps
                    iProjCell{i} = iProjCell{i}.*exp(sign(err) ...
                        *eps*obj.ex.alphabet);
                    iProjCell{i} = iProjCell{i}/sum(iProjCell{i});
                    err = mean-obj.mean(iProjCell{i});
                end
                
            end
        end
        
        function mProj = m_proj_NEW(obj,dist,mean)
            % find M-projection of dist over set
            % of distributions with mean(dist)>= mean
            % binary search over Lagrangian multipliers
            if obj.mean(dist) >= mean
                mProj = dist;
            else
                epsilon = 1E-3;
                lambdaLim = [0; max(obj.ex.alphabet)/epsilon^2];
                error = inf;
                while abs(error)>epsilon && lambdaLim(2)-lambdaLim(1)>epsilon
                    lambda = (lambdaLim(1)+lambdaLim(2))/2;
                    nuHigh = min(-lambda*obj.ex.alphabet(dist~=0));
                    nuLim = [-obj.ex.alphabetSize-lambda*obj.ex.alphabet(end); nuHigh];
                    error2 = inf;
                    while abs(error2)>epsilon
                        nu = (nuLim(1)+nuLim(2))/2;
                        mProj = dist./(-lambda*obj.ex.alphabet-nu);
                        error2 = sum(mProj)-1;
                        if error2>0
                            nuLim(2) = nu;
                        else
                            nuLim(1) = nu;
                        end
                        
                    end
                    
                    error = obj.mean(mProj)-mean;
                    if error>0
                        lambdaLim(2) = lambda;
                    else
                        lambdaLim(1) = lambda;
                    end
                    
                end
                
            end
            
        end
        
        function p = emp_prob_calc(obj,dist,emp_dist)
            % calculate the probability of observing emp_dist from dist in
            % sampleSize trials
            d2 = zeros(obj.ex.sampleSize,1);
            d3 = tril(ones(obj.ex.alphabetSize),-1) ...
                *obj.ex.sampleSize*emp_dist;
            d3(obj.ex.alphabetSize+1) = obj.ex.sampleSize;
            for i = 1:obj.ex.alphabetSize
                % debugging rounding error by round()
                d2(round(d3(i))+1:round(d3(i+1))) = ...
                    1:round(obj.ex.sampleSize*emp_dist(i));
            end
            
            % multinomial coefficient
            p = prod((1:obj.ex.sampleSize)'./d2);
            p = p*prod(dist.^(obj.ex.sampleSize*emp_dist));
        end
        
        % DO NOT USE THIS FUNCTION: DESCRIPTION IS INCORRECT!!!
        function dist = uniformly_random_dist(obj)
            % select a distribution at uniformly random realizable with
            % sampleSize samples
            uniDist = 1/obj.ex.alphabetSize*ones(obj.ex.alphabetSize,1);
            dist = obj.realize(uniDist);
        end
        
        % DO NOT USE THIS FUNCTION: DESCRIPTION IS INCORRECT!!!
        function [dist,numberOfTrials] = random_dist_mean(obj,mean)
            % select a distribution with mean >= beta at uniformly random
            % realizable with sampleSize samples
            numberOfTrials = 0;
            err = inf;
            while 0 < err
                dist = obj.uniformly_random_dist();
                err = mean-obj.mean(dist);
                numberOfTrials = numberOfTrials+1;
            end
            
        end
        
        function dist = uniformly_random_dist_NEW(obj)
            % select a distribution at uniformly random
            l = obj.ex.alphabetSize-1;
            seed = rand(l,1);
            sorted = [0; sort(seed); 1];
            preDist = sorted-circshift(sorted,1);
            dist = preDist(2:end);
        end
        
        function [dist,numberOfTrials] = random_dist_mean_NEW(obj,mean)
            % select a distribution with mean ~ beta at uniformly random
            numberOfTrials = 0;
            eps = 1e-3;
            err = inf;
            while eps < err
                dist = obj.uniformly_random_dist_NEW();
                err = abs(mean-obj.mean(dist));
                numberOfTrials = numberOfTrials+1;
            end
            
        end
        
        function realEmpDist = realize(obj,dist)
            % realize dist sampleSize times and output the empirical dist
            randomSeed = rand(obj.ex.sampleSize,1);
            % concatenated matrix
            seedInMatrix = ones(obj.ex.alphabetSize,1)*randomSeed';
            strLowerTri = tril(ones(obj.ex.alphabetSize),-1);
            checkDist = strLowerTri*dist*ones(1,obj.ex.sampleSize);
            % realIndex = sum(seedInMatrix >= checkDist);
            % sequence of realizations
            % realSeq = obj.ex.alphabet(realIndex);
            % like ccdf
            emp_ccdf = sum(seedInMatrix >= checkDist,2)/obj.ex.sampleSize;
            % realized empirical distribution
            realEmpDist = emp_ccdf-[emp_ccdf(2:end); 0];
        end
        
        function [realEmpDist,numberOfTrials] = realize_mean(obj,dist,mean)
            % realize dist sampleSize times and output the empirical dist
            % if mean(dist) >= mean
            numberOfTrials = 0;
            err = inf;
            while 0 < err
                realEmpDist = obj.realize(dist);
                err = mean-obj.mean(realEmpDist);
                numberOfTrials = numberOfTrials+1;
            end
            
        end
        
    end
    
    methods (Static)
        function d = kl_distance(p,q)
            % base e logarithm
            nonzeroIndex = (p~=0);
            p = p(nonzeroIndex);
            q = q(nonzeroIndex);
            d = p'*log(p./q);
        end
        
    end
    
end
