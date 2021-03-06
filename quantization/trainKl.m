classdef trainKl < handle
    % train klM parameters
    properties
        best % best klMean and klRadius parameters
        ex
        klM
        metric
        tradeoff
    end
    
    methods
        function obj = train(experiment)
            obj.ex = experiment;
            obj.klM = obj.ex.klM;
            obj.metric = 'roc'; % 'roc' or 'mtbf-delay'
            % minimize pfa+(-1)*tradeoff*pd OR (-1)*mtbf+tradeoff*delay
            obj.tradeoff = 1;
        end
        
        function initialize(obj)
            if strcmp(obj.metric,'roc')
                obj.ex.it = [1e2 1e2 0 0 0;
                    0 0 0 0 0; ...
                    0 0 0 0 0; ...
                    0 0 0 0 0];
            elseif strcmp(obj.metric,'mtbf-delay')
                obj.ex.it = [0 0 1e2 1e2 0;
                    0 0 0 0 0; ...
                    0 0 0 0 0; ...
                    0 0 0 0 0];
            end
            
            obj.ex.klMeanRange = obj.ex.beta;
            obj.ex.klRadiusRange = 2^-5;
            obj.best = [obj.ex.klMeanRange; obj.ex.klRadiusRange];
            % CHECK IF ANY KLM OBJECT EXISTS AT THIS STAGE, THERE SHOULDN'T
            % BE ANY
            obj.klM = klM(obj.ex); %#ok<CPROP> % create a klM object
        end
        
        function output = run(obj)
            if strcmp(obj.metric,'roc')
                pfa = obj.runTest('pfaT');
                pd = obj.runTest('pdT');
                output = pfa+(-1)*obj.tradeoff*pd;
            elseif strcmp(obj.metric,'mtbf-delay')
                mtbf = obj.runTest('mtbfT');
                delay = obj.runTest('delayT');
                output = (-1)*mtbf+obj.tradeoff*delay;
            end
            
        end
        
        function output = runTest(obj,testName)
            testString = strcat('obj.klM.',testName,'.test');
            output = eval(testString);
            clear(testString)
        end
        
        function randomSearch(obj)
            bestCost = obj.run;
            for i = 1:it
                obj.update;
                cost = obj.run;
                if cost <= bestCost
                    obj.best = [obj.klM.klMean; obj.klM.klRadius];
                    bestCost = cost;
                end
                
            end
            
        end
        
        function update(obj)
            obj.klM.klMean = ...
                (obj.ex.alphabet(end)-obj.ex.alphabet(1))*rand ...
                +obj.ex.alphabet(1);
            obj.klM.klRadius = 2^(10*rand-9);
        end
        
    end
    
end