function [range_dichotomy, opt_dichotomy] = auto_para_dichotomy(f,param)

param_fields = fieldnames(param);
len_param = length(param_fields); 
range_dichotomy = zeros(len_param,2); 
opt_dichotomy = zeros(len_param,1);


str1 = [];
for i = 1:len_param
    str1 = [str1,',','X',num2str(i)];
end
str1(1) = [];

eval(['[para_range,opt_para,',str1,',metrics_all] = auto_para_range(f,param);'])
disp('[start auto_para_dichotomy ... ]')
for i = 1:len_param

    for ii = 1:len_param
        param.(param_fields{ii}) = 10^(opt_para(ii));
    end
    a = [10^para_range(i,1),10^(para_range(i,1)+1),10^para_range(i,2)]; % 是正常的数了，不再是log域的了
    metric = NaN([1,3]);
    
    str2 = [];
    str_sub = ['1',repmat(',1',1,len_param-1)];
    for ii = 1:len_param
        str_temp = str_sub;
        str_temp(2*ii-1) = ':';
        if ii == i
            str2 = [str2,',','ismember(X',num2str(ii),'(',str_temp,'),log10(a)) == 1'];
        else
            str2 = [str2,',','X',num2str(ii),'(',str_temp,') == opt_para(',num2str(ii),')'];
        end
    end
    str2(1) = [];
    eval(['metric = squeeze(metrics_all(',str2,'));']);

    a = [a(1) 6*a(1) a(2) 6*a(2) a(3)];
    metric = [metric(1) nan metric(2) nan metric(3)];

    for ii = [2 4]
        param.(param_fields{i}) = a(ii);
        metric(ii) = f(param);
        % 打印日志
        fprintf('param = ');
        fprintf('%10.0e',cell2mat(struct2cell(param)));
        fprintf('----> metric = %.4f \n',metric(ii));
    end

    [~,index_max] = max(metric);
    if index_max == 1
        disp(['》》》》》》》》》》》》 [NOTE] the *',num2str(i),'th* param seems to strange, recommand check the strange log'])
        range_dichotomy(i,:) = [a(index_max) a(index_max+2)];
        opt_dichotomy(i) = a(index_max);
        disp('[dichotomy one parameter done]')
        continue;
    elseif index_max == 5
        disp('》》》》》》》》》》》》 [NOTE] the *',num2str(i),'th* param seems to strange, recommand check the strange log')
        range_dichotomy(i,:) = [a(index_max-2) a(index_max)];
        opt_dichotomy(i) = a(index_max);
        disp('[dichotomy one parameter done]')
        continue;
    end

    range_dichotomy(i,:) = [a(index_max-1) a(index_max+1)];
    a = [a(index_max-1) round_35((a(index_max-1)+a(index_max))/2) a(index_max) round_35((a(index_max)+a(index_max+1))/2) a(index_max+1)];
    metric = [metric(index_max-1),nan,metric(index_max),nan,metric(index_max+1)];

    for ii = [2 4]
        param.(param_fields{i}) = a(ii);
        metric(ii) = f(param);
        % 打印日志
        fprintf('param = ');
        fprintf('%10.0e',cell2mat(struct2cell(param)));
        fprintf('----> metric = %.4f \n',metric(ii));
    end

    [~,index_max] = max(metric);
    range_dichotomy(i,:) = [a(index_max-1) a(index_max+1)];
    opt_dichotomy(i) = a(index_max);
    disp('[dichotomy one parameter done]')
end
disp('[End auto_para_dichotomy]')

end

function c = round_35(b)
flag = mod(log10(b/3.5),1);
if flag == 0
    c = 3*(b/3.5);
else
    c = b;
end
end



