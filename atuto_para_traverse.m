function [metrics,varargout] = atuto_para_traverse(f,param,range,step,varargin)
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

disp('[start auto_para_traverse ... ]')

expectedTypes = {'log','normal'};

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
for i = 1:len_para
    str1 = [str1, ' ','p',num2str(i),'_range = I_log_or_normal(range(',num2str(i),',1)).*(1:step(',num2str(i),'):10);'];
    str2 = [str2,',','X',num2str(i)];
    str3 = [str3,',','p',num2str(i),'_range'];
    str4 = [str4,newline,'for p',num2str(i),' = p',num2str(i),'_range'];
    str5 = [str5,' ','param.(param_fields{',num2str(i),'}) = p',num2str(i),';'];
    str7 = [str7,',','p',num2str(i),'_range == p',num2str(i),''];
    str8 = [str8,newline,'end'];
    str9 = [str9,',','X',num2str(i),'(max_ind)'];
end
str2(1) = [];
str3(1) = [];
str7(1) = [];
str9(1) = [];

str6 = 'metric = f(param);fprintf(''param = '');fprintf(''%15.1e'',cell2mat(struct2cell(param)));fprintf(''----> metric = %.4f \n'',metric);';

eval(str1);
eval(['[',str2,'] = ndgrid(',str3,');'])
metrics = NaN(size(X1));

eval([str4,str5,str6,'metrics(',str7,') = metric;',str8])

disp('--------------------------------------------------------------------------')
[max_metric,max_ind] = max(metrics(:));
fprintf('OPT.param = ');fprintf('%15.1e',eval(['[',str9,']']));fprintf('----> MAX_metric = %.4f \n',max_metric);
disp('--------------------------------------------------------------------------')

varargout = eval(['{',str2,'}']);


disp('[End auto_para_traverse]')
