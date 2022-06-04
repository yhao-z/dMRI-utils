function para_range = auto_para_main(alg, param, b,sampling_mask,x, varargin)
p = inputParser;
addParameter(p,'mini',false,@islogical);
parse(p,varargin{:});

eval(['f = @(param) ', alg, '(b,sampling_mask,x,param,"para_adjust",true);']);
if p.Results.mini
    para_range = auto_para_all_mini(f,param);
else
    para_range = auto_para_all(f,param);
end