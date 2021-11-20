function [metrics,varargout] = auto_para_traverse(f,param,range,step,varargin)
% 能够根据range的范围遍历所有param结构体内参数的所有可能，并将得到的metric赋值给metrics张量
% [metrics,X1,X2,X3] = atuto_para_traverse(f,z,para_range,[1 1 1]); %例子
% 
% 2d的情况，该程序是n d的 
% len_para = size(range,1);
% param_fields = fieldnames(param);
% p1_range = 10^range(1,1).*(1:step(1):10); 
% p2_range = 10^range(2,1).*(1:step(2):10);
% [X1,X2] = ndgrid(p1_range,p2_range);
% metrics = NaN(size(X1));
% for p1 = p1_range
%     for p2 = p2_range 
%         param.(param_fields{1}) = p1; 
%         param.(param_fields{2}) = p2;
%         metric = f(param);fprintf('param = ');
%         fprintf('%15.1e',cell2mat(struct2cell(param)));
%         fprintf('----> metric = %.4f \n',metric);
%         metrics(p1_range == p1,p2_range == p2) = metric;
%     end
% end
% varargout = {X1,X2};
% 
% 简单函数测试
% d = 100000; u = [1000 1000];
% z.a = 1;
% z.b = 1;
% 
% f = @(z) -norm([z.a,z.b]-u)^2;
% f(z)
% para_range = auto_para(f,z);
% [metrics,X1,X2] = atuto_para_traverse(f,z,para_range,[1 1]);

disp('[start auto_para_traverse ... ]')

expectedTypes = {'log','normal','dichotomy'};

p = inputParser;
addParameter(p,'type','log',@(x) any(validatestring(x,expectedTypes)));
parse(p,varargin{:});

% 根据输入看是否在log维度上分析
if strcmp(p.Results.type,'log')
    I_log_or_normal = @(x) 10.^x;
else
    I_log_or_normal = @(x) x;
end

len_para = size(range,1);
param_fields = fieldnames(param);

str1 = [];
str2 = [];
str3 = [];
str4 = [];
str5 = [];
str7 = [];
str8 = [];
str9 = [];
str10 = [];
for i = 1:len_para
    str1 = [str1, ' ','p',num2str(i),'_range = I_log_or_normal(range(',num2str(i),',1)).*(1:step(',num2str(i),'):10);'];
    str2 = [str2,',','X',num2str(i)];
    str3 = [str3,',','p',num2str(i),'_range'];
    str4 = [str4,newline,'for p',num2str(i),' = p',num2str(i),'_range'];
    str5 = [str5,' ','param.(param_fields{',num2str(i),'}) = p',num2str(i),';'];
    str7 = [str7,',','p',num2str(i),'_range == p',num2str(i),''];
    str8 = [str8,newline,'end'];
    str9 = [str9,',','X',num2str(i),'(max_ind)'];
    str10 = [str10, ' ','p',num2str(i),'_range = dichotomy_range(range(',num2str(i),',:));'];
end
str2(1) = [];
str3(1) = [];
str7(1) = [];
str9(1) = [];

str6 = 'metric = f(param);fprintf(''param = '');fprintf(''%15.1e'',cell2mat(struct2cell(param)));fprintf(''----> metric = %.4f \n'',metric);';

if strcmp(p.Results.type,'dichotomy')
    eval(str10);
else
    eval(str1);
end
eval(['[',str2,'] = ndgrid(',str3,');'])
metrics = NaN(size(X1));

eval([str4,str5,str6,'metrics(',str7,') = metric;',str8])

disp('--------------------------------------------------------------------------')
[max_metric,max_ind] = max(metrics(:));
fprintf('OPT.param = ');fprintf('%15.1e',eval(['[',str9,']']));fprintf('----> MAX_metric = %.4f \n',max_metric);
disp('--------------------------------------------------------------------------')

varargout = eval(['{',str2,'}']);

str_sub = ['1',repmat(',1',1,len_para-1)];
str_sub(end) = ':';
for i = 1:len_para
    if i == 1
        dim_sort = [2:len_para, i];
    elseif i == len_para
        dim_sort = 1:len_para;
    else
        dim_sort = [1:i-1,i+1:len_para,i];
    end

    if length(dim_sort) == 1
        dim_sort = [2 1];
    end
    plot_matrix = reshape(permute(metrics,dim_sort),[prod(size(metrics,dim_sort(1:end-1))),size(metrics,dim_sort(end))]);

    Xi_sort = permute(eval(['X',num2str(i)]),dim_sort);
    disp_matrix = NaN(size(plot_matrix,1)+2,size(plot_matrix,2));
    disp_matrix(1,:) = eval(['(squeeze(Xi_sort(',str_sub,')))']);
    disp_matrix(3:end,:) = plot_matrix;
    disp(['=====param *',num2str(i),'*: the metric trend====='])
    disp(disp_matrix)

    figure('Name',['[auto_para_tranverse]the parameter ',num2str(i)]);hold on;
    set(gca,'xtick',[]);
    xlabel(['range:   ', eval(['num2str(convert2row(squeeze(Xi_sort(',str_sub,'))))'])])
    for ii = 1:size(plot_matrix,1)
        plot(plot_matrix(ii,:));
    end
end

disp('[End auto_para_traverse]')
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

function v2 = convert2row(v)
if isrow(v)
    v2 = v;
else 
    v2 = v.';
end
end


    
