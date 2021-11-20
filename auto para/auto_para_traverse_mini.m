function opt_para_out = auto_para_traverse_mini(f,param,range,opt_para_in,varargin)

disp('[start auto_para_traverse_mini ... ]')

expectedTypes = {'log','normal','dichotomy'};

p = inputParser;
addParameter(p,'type','dichotomy',@(x) any(validatestring(x,expectedTypes)));
parse(p,varargin{:});

% 根据输入看是否在log维度上分析
if strcmp(p.Results.type,'log')
    I_log_or_normal = @(x) 10.^x;
else
    I_log_or_normal = @(x) x;
end

len_para = size(range,1);
param_fields = fieldnames(param);

for i = 1:len_para
    param.(param_fields{i}) = I_log_or_normal(opt_para_in(i));
end

str1 = [];
str2 = [];
for i = 1:len_para
    str1 = [str1, ' ','p_range{',num2str(i),'} = dichotomy_range(range(',num2str(i),',:));'];
    str2 = [str2, ' ','metric{',num2str(i),'} = zeros([1,length(p_range{',num2str(i),'})]);'];
end
eval(str1);
metric = cell(2,1);
eval(str2);

for i = 1:len_para
    for ii = 1:length(p_range{i})
        param.(param_fields{i}) = I_log_or_normal(p_range{i}(ii));
        metric{i}(ii) = f(param);
        fprintf('param = ');
        fprintf('%10.0e',cell2mat(struct2cell(param)));
        fprintf('----> metric = %.4f \n',metric{i}(ii));
    
        [~,ind_max] = max(metric{i});
        param.(param_fields{i}) = I_log_or_normal(p_range{i}(ind_max));
    end
    disp('[traverse one parameter done]')
end
opt_para_out = cell2mat(struct2cell(param));
disp('--------------------------------------------------------------------------')
max_metric = max(metric{len_para});
fprintf('OPT.param = ');fprintf('%10.0e',opt_para_out');fprintf('----> MAX_metric = %.4f \n',max_metric);
disp('--------------------------------------------------------------------------')

end


function range_out = dichotomy_range(range_in)
log_range = floor(log10(range_in));
prefix_num = range_in./(10.^log_range);
if prefix_num(1) ==1 && prefix_num(2) == 1
    range_out = range_in(1);
elseif log_range(1) == log_range(2)
    range_out = 10^log_range(1).*(prefix_num(1):prefix_num(2));
else
    range_out = [10^log_range(1).*(prefix_num(1):9) 10^log_range(2).*(1:prefix_num(2))];
end
end


    
