% rpm = textscan(fileread('reported-paralytic-polio-cases-per-1-million-people.csv'),'%s %s %d16 %f', 'delimiter', ',', 'HeaderLines', 1);
% vpo = textscan(fileread('polio-vaccine-coverage-of-one-year-olds.csv'),'%s %s %d16 %d32', 'delimiter', ',', 'HeaderLines', 1);
% % rpm = {region, code, year, cases} of reported paralytic polio cases per 1 million people
% % vpo = {region, code, year, coverage percentage} of polio vaccine coverage of one year olds
% % rpm and vpo have equal sets of regions
% % union(setdiff(rpm{1},vpo{1}), setdiff(vpo{1},rpm{1})) is empty
% 
% %%
% data = containers.Map();
% for i = 1:length(rpm{1})
%     if ~any(strcmp(data.keys,rpm{1}{i}))
%         data(rpm{1}{i}) = timeseries(rpm{4}(i),rpm{3}(i));
%     else
%         data(rpm{1}{i}) = addsample(data(rpm{1}{i}),'Data',rpm{4}(i),'Time',rpm{3}(i));
%     end
% 
% end
% 
% regions = data.keys;
% for i = 1:length(vpo{1})
%     if length(data(vpo{1}{i})) == 1
%         dum = cell(2,1);
%         dum{1} = data(vpo{1}{i});
%         dum{2} = timeseries(vpo{4}(i),vpo{3}(i));
%         data(vpo{1}{i}) = dum;
%     else
%         dum = data(vpo{1}{i});
%         dum{2} = addsample(dum{2},'Data',vpo{4}(i),'Time',vpo{3}(i));
%         data(vpo{1}{i}) = dum;
%     end
%     
% end
% 
% %%
% vacRep = containers.Map('KeyType','int32','ValueType','any');
% % observation of polio reports/ mil. ppl for a given vaccination percentage of 1 y.o. over all regions, years
% for i = 1:length(regions)
%     region = regions{i};
%     dum = data(region);
%     localRpm = dum{1};
%     localVpo = dum{2};
%     for j = 1:length(localVpo.Time)
%         ind = find(localRpm.Time == localVpo.Time(j));
%         if ~isempty(ind)
%             keys = vacRep.keys;
%             if ~any([keys{:}] == localVpo.Data(j))
%                 vacRep(localVpo.Data(j)) = localRpm.Data(ind);
%             else
%                 vacRep(localVpo.Data(j)) = [vacRep(localVpo.Data(j)); localRpm.Data(ind)];
%             end
%         
%         end
%         
%     end
%     
% end

%%
keys = vacRep.keys;
l = length(keys);
dist = containers.Map('KeyType','int32','ValueType','double');
% exponential distribution fit to histogram of polio reports/ mil. ppl. vs vaccination percentage of 1 y.o.
for i = 1:l
    key = keys(i);
    fit = fitdist(vacRep(key{1}),'Exponential');
    dist(key{1}) = fit.mu;
end

%%
v = values(dist,dist.keys);
v = [v{:}];
k = dist.keys;
k = [k{:}];
f = fit(k,v,'exp1');