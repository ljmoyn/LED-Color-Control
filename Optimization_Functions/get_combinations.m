function result=get_combinations(sofar,rest,n,result)
    if n == 0
        result=[result;sofar];
    else
        for i=1:length(rest)
            j=i+1;
            result=get_combinations([sofar rest(i)], rest(j:end), n-1,result);
        end
    end
end