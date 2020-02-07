classdef pmdT < handle
    properties
        dGau % discrete Gaussian pre-change
        dGPo % discrete Gaussian post-change
        dura % duration of the transient change
        iter % iteration
        itPo % iteration per post change distribution
        meth % method
        saLe % sample length
        thrs % threshold
        var0 % pre-change variance
        var1 % minimum post-change variance
        wind % window size
    end
    
    methods
        function obj = pmdT()
            obj.dura = 80;
            obj.iter = 2e4;
            obj.itPo = 2e1;
            obj.thrs = 10.^(-3:2)';
            obj.var0 = 1;
            obj.var1 = 1.75;
            obj.dGau = dGau(11,obj.var0);
            obj.wind = 20;
%             obj.thrs = 10.^(-3:0.5:2)';
%             obj.meth = fmaM(obj);
            obj.thrs = (20:1:50)';
            obj.meth = glrM(obj);
%             thr1 = 2.^(-2:1)';
%             thr2 = 2.^(-2:1)';
%             [thr1,thr2] = meshgrid(thr1,thr2);
%             obj.thrs = [thr1(:) thr2(:)];
%             obj.meth = inpM(obj);
        end
        
        function timS = geTS(obj,chPo)
            if chPo == 1
                timS = obj.dGau.samp(obj.iter,obj.saLe);
            else
                preC = obj.dGau.samp(obj.iter,chPo-1);
                posC = obj.dGPo.samp(obj.iter,obj.saLe-chPo+1);
                timS = [preC posC];
            end
            
        end
        
        function pmdE = repe(obj)
            nThr = size(obj.thrs,1); % number of thresholds
            pmdE = zeros(nThr,1); % pmd estimate
            for i = 1:nThr
                thre = obj.thrs(i); % if single parameter
%                 thre = obj.thrs(i,:); % if multi-parameter
                pmdE(i) = 0;
                for j = 1:obj.itPo
                    [i,j]
                    para = 1.25+0.75*rand;
                    obj.dGPo = dGau(11,para);
                    for chPo = 1:obj.wind
                        obj.saLe = obj.dura+chPo-1;
                        obj.saLe = obj.saLe-rem(obj.saLe,obj.wind);
                        timS = obj.geTS(chPo); % time series
                        pmdE(i) = max(pmdE(i),1-obj.meth.isAl(thre,timS));
                    end
                    
                end
                
            end
            
        end
        
    end
    
end
