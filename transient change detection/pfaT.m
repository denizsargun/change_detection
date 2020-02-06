classdef pfaT < handle
    properties
        dGau % discrete Gaussian sampler
        dura % duration of the transient change
        faWi % false alarm window
        iter % iteration
        meth % method
        saLe % sample length
        thrs % threshold
        var0 % pre-change variance
        var1 % minimum post-change variance
        wind % window size
    end
    
    methods
        function obj = pfaT()
            obj.dGau = dGau(11,1);
            obj.dura = 75;
            obj.faWi = 380;
            obj.iter = 1e4;
            obj.saLe = obj.faWi;
            obj.var0 = 1;
            obj.var1 = 1.25;
            obj.wind = 38;
%             obj.thrs = 10.^(-3:0.5:2)';
%             obj.meth = fmaM(obj);
%             obj.thrs = (40:10:150)';
%             obj.meth = glrM(obj);
            thr1 = 2.^(-2:1)';
            thr2 = 2.^(-2:1)';
            [thr1,thr2] = meshgrid(thr1,thr2);
            obj.thrs = [thr1(:) thr2(:)];
            obj.meth = inpM(obj);
        end
        
        function timS = geTS(obj)
            timS = obj.dGau.samp(obj.iter,obj.saLe);
        end
        
        function pfaE = repe(obj)
            nThr = size(obj.thrs,1); % number of thresholds
            pfaE = zeros(nThr,1); % pfa estimate
            for i = 1:nThr
%                 thre = obj.thrs(i); % if single parameter
                thre = obj.thrs(i,:); % if multi-parameter
                timS = obj.geTS(); % time series
                pfaE(i) = obj.meth.isAl(thre,timS);
            end
            
        end
        
    end
    
end