function save_log(log_sufix)
% it must have the directory ./logs/
% if there is not, make it

p = inputParser;
addRequired(p,'log_sufix',@ischar);
parse(p,log_sufix);
log_dir = ['./logs/[',p.Results.log_sufix,']',datestr(datetime('now'),'yyyy-mm-dd_HH-MM'),'.txt'];
fclose(fopen(log_dir,"a+"));
diary(log_dir);
diary on