classdef childs < handle 
    properties
        parent
        name
        data
        countries_obj
        states_obj
        cases_cumu
        deaths_cumu
        cases_daily
        deaths_daily
        date
    end 
    methods
        function child=childs(pname,nname,t_data,states)
            if nargin==4
                child.parent=pname;
                child.name=nname;
                child.data=t_data;
                child.states_obj=horzcat(child.states_obj,states);
                child.cumulative(child.data)
                child.daily(child.cases_cumu,child.deaths_cumu)
                
                
            elseif nargin==0
                load 'covid_data.mat' covid_data 
                child.parent=[];
                child.name="Global";
                child.data=covid_data(2:end,3:end);
                child.states_obj=child.countries_obj;
                child.date=datetime(covid_data(1,3:end),'InputFormat','MM/dd/yy');
            end 
        end
        
        function cumulative(child,datas)
            aa=[];
            bb=[];
            if child.name~="Global"
                dat=cell2mat(datas);
                child.cases_cumu=dat(1:2:end);
                child.deaths_cumu=dat(2:2:end);
                
            else
                for ii=1:length(child.countries_obj)
                    aa=vertcat(aa,child.countries_obj(1,ii).cases_cumu);
                    bb=vertcat(bb,child.countries_obj(1,ii).deaths_cumu);
                end
                child.cases_cumu=sum(aa);
                child.deaths_cumu=sum(bb);
            end
        end
        function daily(child,data1,data2)
            initc=data1(1:1);
            initd=data2(1:1);
            for ii=1:length(data1)
                if ii==1
                    child.cases_daily=initc;
                    child.deaths_daily=initd;
                else
                    child.cases_daily=horzcat(child.cases_daily,data1(ii)-data1(ii-1));
                    child.deaths_daily=horzcat(child.deaths_daily,data2(ii)-data2(ii-1));
                end
            end
        end
            
            
        
        function main(child)
            load 'covid_data.mat' covid_data
            child.countries_obj=[];
            child.states_obj=[];
            j=0;
            for ii=2:length(covid_data(1:end,1))
                if string(covid_data(ii,2))==""
                    child.countries_obj=horzcat(child.countries_obj,childs(child,covid_data(ii,1),covid_data(ii,3:end),[]));
                    j=j+1;
                else
                    child.states_obj=horzcat(child.states_obj,childs(child.countries_obj(1,j),covid_data(ii,2),covid_data(ii,3:end),[]));
                    child.countries_obj(1,j).states_obj=horzcat(child.countries_obj(1,j).states_obj,child.states_obj(end,end));
                end
            end
            child.cumulative(child.data)
            child.daily(child.cases_cumu,child.deaths_cumu)
        end
    end
end
