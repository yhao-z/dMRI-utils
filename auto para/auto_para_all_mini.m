function [range_dichotomy,opt_para] = auto_para_all_mini(f,param)

param_fields = fieldnames(param);
len_param = length(param_fields); 

disp('-----------------------------------------')
disp('the parameter order is:')
disp(param_fields)
disp('-----------------------------------------')

[range_dichotomy, opt_dichotomy] = auto_para_dichotomy(f,param);
disp('-----------------------------------------')
disp('the dichotomy range is:')
disp(range_dichotomy)
disp('the dichotomy opt para is:')
disp(opt_dichotomy)
disp('-----------------------------------------')

opt_para = auto_para_traverse_mini(f,param,range_dichotomy,opt_dichotomy);
