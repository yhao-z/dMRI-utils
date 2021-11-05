function [range,opt_para,paras_all,metrics_all] = auto_para(f,param,varargin)
% 简单函数测试
% d = 100000; u = [1000 1000];
% z.a = 1;
% z.b = 1;
% 
% f = @(z) -norm([z.a,z.b]-u)^2;
% f(z)
% para_range = auto_para(f,z);
%
% 记录问题
% 1. step必须等于1
% 2. paras_all 应该是把X1,X2.....这些输出出来才行，否则不大好用，最好弄成varargout
% 3. para和param乱用，应该把名称统一
%

disp('[start auto_para ... ]')

% 解析输入
expectedTypes = {'log','normal'};

p = inputParser;
addParameter(p,'type','log',@(x) any(validatestring(x,expectedTypes)));
addParameter(p,'step',1,@(x) validateattributes(x,{'numeric'},{'nonempty','integer','positive'}));
parse(p,varargin{:});

% 根据输入看是否在log维度上分析
if strcmp(p.Results.type,'log')
    log_or_normal = @(x) log10(x);
    I_log_or_normal = @(x) 10.^x;
else
    log_or_normal = @(x) x;
    I_log_or_normal = @(x) x;
end
% 返回的区间范围是step那么大，例如step=1； range=[0,1]  %% 这个地方可能有问题，现在最好还是只取1，否则可能出错
step = p.Results.step;

% inital
param_fields = fieldnames(param);
param_cell = struct2cell(param);
len_param = length(param_fields); 
range = zeros(len_param,2); 
opt_para = zeros(len_param,1);

% 定义一些之后能用到的字符串，后面用eval让其变成代码
str1 = [];
str2 = [];
str3 = [];
str4 = [];
str_sub = ['1',repmat(',1',1,len_param-1)];
for ii = 1:len_param
    str1 = [str1,',','length(Min(',num2str(ii),'):Max(',num2str(ii),'))'];
    str_temp = str_sub;
    str_temp(2*ii-1) = ':';
    str2 = [str2,',','X',num2str(ii),'(',str_temp,')','-Min(',num2str(ii),')+1']; %X1(:,1)-Min(1)+1,X2(1,:)-Min(2)+1,X3(1,:)-Min(3)+1
    str3 = [str3,',','Min(',num2str(ii),'):Max(',num2str(ii),')'];
    str4 = [str4,',','X',num2str(ii)];
end
str1(1) = [];
str2(1) = [];
str3(1) = [];
str4(1) = [];

% 开始一维一维的搜索
iter = 0; % 记录迭代多少次
i = 1; % 当前搜索的维度
maxi = i; % 记录当前已经搜索到的最大维数
axises = [];
metrics_all = []; % 记录目标的值
param_fix = log_or_normal([param_cell{1:len_param}]); % 查找一个维度时，其它维度固定，固定的值记录在此处
while(1)
    iter = iter +1;
    j = 1:len_param;
    j(i) = [];

    param_cell = struct2cell(param);
    param_fix(j) = log_or_normal([param_cell{j}]); % 更新固定值，上次迭代可能改变了某个维度的参数
    
    [range(i,:),opt_para(i),paras_all1,metrics_all1] = auto_param_1d(f,param,param_fields,i,log_or_normal,I_log_or_normal,step); % 搜索某一维度
    [~,ind] = max(metrics_all1); % 当前搜索的最大值
    param.(param_fields{i}) = I_log_or_normal(paras_all1(ind)); % 将最大值赋给参数结构体，更新它

    axises1 = zeros(length(paras_all1),len_param); % 本次搜索已经搜索的参数组合，其它固定，只有一个改变
    axises1(:,i) = paras_all1.';
    axises1(:,j) = repmat(param_fix(j),length(paras_all1),1);
    axises = [axises;axises1]; % 将新搜索的合并到总的搜索结果中
    paras_all = axises;

    Max = max(axises); % 搜索结果的最大最小值，用于生成《搜索记录张量》以及《搜索记录坐标张量》
    Min = min(axises);

    if iter ~= 1 % 生成新的较大的《搜索记录张量》，并将之前的搜索结果填充进去
        eval(['temp = NaN(',str1,');'])
        eval(['temp(',str2,') = metrics_all;'])
        metrics_all = temp;
    end
    
    eval(['[',str4,'] = ndgrid(',str3,');']); % 生成《搜索记录坐标张量》

    eval_str = [];
    for ii = 1:len_param
        if ii == i
            eval_str = [eval_str, ',axises1(:,',num2str(ii),')-Min(',num2str(ii),')+1'];
        else
            eval_str = [eval_str, ',axises1(1,',num2str(ii),')-Min(',num2str(ii),')+1'];
        end
    end
    eval_str(1) = [];
    eval(['metrics_all(',eval_str,') = metrics_all1;']) % 将新的搜索结果填充到《搜索记录张量》中

    if len_param == 1 % 如果只有一个参数，那搜索一次就够了
        break;
    end

    [~,ind_max] = max(metrics_all(:)); % 找到表现最好
    if iter == 1 % 第一次迭代不考虑，直接开始第二次
        i = i+1;
        maxi = max(maxi,i);
    elseif eval(['X',num2str(i),'(ind_max)']) == param_fix(i) % 当前迭代维得到的表现最好的参数与之前搜索其它维度时使用的该维度的固定参数一致
        if i == maxi % 是当前搜索的最高维，证明之前的搜索的都满足了，考虑下一维
            i = i+1; maxi = max(maxi,i);
            if i > len_param % 全部搜索完了就停止
                break;
            end
        else % 不是最高维
            for ii = i+1:maxi % 看之前的每一维在这个最大值点处是否都已经考虑过了（可能没考虑过，那就重新考虑）
                if eval(['isnan(metrics_all','(ind_max+prod(size(metrics_all,1:',num2str(ii),'-1))))'])
                    ii = ii-1; break;
                else % 考虑过了，但是在那个维度上这个点竟然又不是最大值了，按理说之前要满足最大值才能找下个维度，那么这个问题比较奇怪，程序报错
                    if ~(eval(['X',num2str(ii),'(ind_max)']) == param_fix(ii))
                        error('strange: NOT monotone, metrics up and down')
                    end
                end
            end
            i = ii +1; maxi = max(maxi,i);
            if i > len_param
                break;
            end
        end
    else % 当前迭代维得到的表现最好的参数与之前搜索其它维度时使用的该维度的固定参数不一致（直接返回第一维重新找）
        if i ==1
            i = 2;
        else
            i = 1;
        end
    end
end
% 作图，但是也只能画1 2 3维，再高画不了了
if len_param == 1
    figure;
    plot(X1,metrics_all); xlabel('param'); ylabel('metric');
elseif len_param == 2
    figure;
    mesh(X1,X2,metrics_all);
    xlabel('param1');ylabel('param2');zlabel('metric')
elseif len_param == 3
    figure;
    ind = find(~isnan(metrics_all));
    scatter3(X1(ind),X2(ind),X3(ind),abs(1000.^( abs(metrics_all(ind)-min(metrics_all(ind))+1)./abs(max(metrics_all(ind))-min(metrics_all(ind))+1) )));
    xlabel('param1');ylabel('param2');zlabel('param3')
end

disp('[End auto_para]')

%% 1d
function [range,opt_para,paras_all,metrics_all] = auto_param_1d(f,param,param_fields,param_order,log_or_normal,I_log_or_normal,step)
a(1) = log_or_normal( param.(param_fields{param_order}) ); % initial
i = 0; % 迭代次数
while(1)
    i = i+1;
    param.(param_fields{param_order}) = I_log_or_normal(a(i)); % 给一个初值
    metric(i) = f(param);
    % 打印日志
    fprintf('param = ');
    fprintf('%10d',log_or_normal(cell2mat(struct2cell(param))));
    fprintf('----> metric = %.4f \n',metric(i));
    if ismember(i, [1 2]) % 第一次第二次不好比较，不知道应该往前还是往后，因此默认往前（+）
        a(i+1) = a(i)+step;
    else % 不是前两次
        [a,I] = sort(a); % 拍下序
        metric = metric(I);
        [~,index] = max(metric);% 表现最好
        metric_nomax = metric([1:index-1 index+1:i]);% 去掉表现最好，为了找表现次好
        if index == i % 表现最好的在两个端点，那需要继续找
            a(i+1) = a(i)+step;
        elseif index == 1
            a(i+1) = a(1)-step;
        else % 不在端点，看看能不能停止
            [~,second_index] = max(metric_nomax); % 表现次好也不能在端点，为了保险
            if second_index == i
                a(i+1) = a(i)+step;
            elseif second_index == 1
                a(i+1) = a(1)-step;
            else % 次好也不在端点
                opt_para = a(index); % 最优解出来
                if abs(metric(index-1)-metric(index))>abs(metric(index+1)-metric(index)) % 看看输出哪个区间比较合适
                    range = [a(index) a(index+1)];
                    paras_all = a;
                    metrics_all = metric;
%                     figure;plot(a,metric);
                    break;
                else 
                    range = [a(index-1) a(index)];
                    paras_all = a;
                    metrics_all = metric;
%                     figure;plot(a,metric);
                    break;
                end
            end
        end
    end
end
disp('[searching one parameter done]')
%% 2d
% function [range,paras_all,metrics_all] = auto_para(f,param,type)
% 
% 
% param_fields = fieldnames(param);
% len_param = length(param_fields);  %% 2 d
% range = zeros(len_param,2);  %% 2*2
% 
% iter = 0;
% i = 1;
% axises = [];
% metrics_all = [];
% while(1)
%     iter = iter +1;
%     j = 1:len_param;
%     j(i) = [];
% 
%     param_fix(j) = log10(getfield(param,param_fields{j}));
%     [range(i,:),paras_all1,metrics_all1] = auto_param_1d(f,param,param_fields,i,type);
%     [~,ind] = max(metrics_all1);
%     param = setfield(param,param_fields{i},10^paras_all1(ind));
% 
%     axises1 = zeros(length(paras_all1),len_param);
%     axises1(:,i) = paras_all1.';
%     axises1(:,j) = repmat(param_fix(j),length(paras_all1),1);
%     axises = [axises;axises1];
%     paras_all = axises;
% 
%     Max = max(axises);
%     Min = min(axises);
%     if iter ~= 1
%         temp = NaN(length(Min(2):Max(2)),length(Min(1):Max(1)));  %不大对
%         temp(X1(:,1)-Min(1)+1,X2(1,:)-Min(2)+1) = metrics_all;
%         metrics_all = temp;
%     end
%     
%     [X2,X1] = meshgrid(Min(2):Max(2),Min(1):Max(1));
%     if i == 1
%         metrics_all(axises1(:,i)-Min(1)+1,axises1(1,j)-Min(2)+1) = metrics_all1;
%     elseif i == 2
%         metrics_all(axises1(1,j)-Min(2)+1,axises1(:,i)-Min(1)+1) = metrics_all1;
%     end
% 
%     
%     [~,ind_max] = max(metrics_all(:));
%     if ~(eval(['X',num2str(i),'(ind_max)']) == param_fix(i)) || iter == 1
%         i = ~mod(i+1,2)+1;
%     else
%         break;
%     end
% end
% 
% mesh(X1,X2,metrics_all);


