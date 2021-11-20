function [range_dichotomy,varargout] = auto_para_all(f,param)

param_fields = fieldnames(param);
len_param = length(param_fields); 

disp('-----------------------------------------')
disp('the parameter order is:')
disp(param_fields)
disp('-----------------------------------------')

range_dichotomy = auto_para_dichotomy(f,param);
disp('-----------------------------------------')
disp('the dichotomy range is:')
disp(range_dichotomy)
disp('-----------------------------------------')

str1 = [];
for i = 1:len_param
    str1 = [str1,',','X',num2str(i)];
end
str1(1) = [];

eval(['[metrics_traverse,',str1,'] = auto_para_traverse(f,param,range_dichotomy,[1 1],"type","dichotomy");'])
varargout = eval(['{metrics_traverse,',str1,'}']);