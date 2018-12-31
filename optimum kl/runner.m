classdef runner < handle
    properties
        ex
        writer
    end
    
    methods
        function obj = runner(experiment)
            obj.ex = experiment;
        end
        
        function runEx(obj)
            for methodName = obj.ex.methodNames
                methodString = strcat(methodName,'(obj.ex)');
                method = eval(methodString);
                clear(methodString)
                obj.runMethod(method)
            end
            
        end
        
        function runMethod(obj,method)
            for i = 1:method.numberOfSettings
                for testName = obj.ex.testNames
                    testString = strcat('method.',testName,'.test');
                    output = eval(testString);
                    clear(testString)
                    obj.ex.writer.write(output,method,testName,i)
                end
                
                if i ~= method.numberOfSettings
                   method.update
                end
                
            end
            
        end
        
    end
    
end