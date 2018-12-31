classdef experiment < handle
    % hold utility object and variables
    properties
        alpha
        alphabet
        alphabetSize
        beta
        glrThrRange
        it
        klMeanRange
        klRadiusRange
        lmpThrRange
        maxFunEvals
        maxIter
        meanMeanRange
        methodNames
        runner
        sampleSize
        storageFile
        testNames
        unchangedDist
        utility % utility toolbox
        writer
    end
    
    methods
        function obj = experiment()
            % save current folder name
            fid = fopen('directory.txt','w');
            fprintf(fid,pwd);
            fclose(fid);
            
            obj.alphabet = [-2 -1 0 1 2];
            obj.beta = .5;
            obj.glrThrRange = 2.^(0:999.25:10)';
            obj.it = [1 1 1 1 1; ... % klM pfa, pd, mtbf, delay, time
                1 1 1 1 1; ... % meanM pfa, pd, mtbf, delay, time
                1 1 1 1 1; ... % lmpM pfa, pd, mtbf, delay, time
                1 1 1 1 1];    % glrM pfa, pd, mtbf, delay, time
            obj.klMeanRange = (0:999.05:0.5)';
            obj.klRadiusRange = 2.^(-9:9991:-1)';
            obj.lmpThrRange = -2.^(0:.2:2.4)';
            % default MaxFunEvals is 100*numberOfVariables = 500
            obj.maxFunEvals = 500;
            % default MaxIter is 400
            obj.maxIter = 400;
            obj.meanMeanRange = (-1:.05:1)';
            obj.methodNames = {'klM', 'meanM', 'lmpM', 'glrM'};
            obj.sampleSize = 20;
            obj.testNames = {'pfaT','pdT','mtbfT','delayT','timeT'};
            obj.unchangedDist = 1/5*ones(5,1);
            obj.utility = utility(obj);
            obj.utility.setup()
            obj.writer = writer(obj);
            % runner is the last obj to be defined
            obj.runner = runner(obj);
            obj.runner.runEx(obj)
        end
        
    end
    
end
