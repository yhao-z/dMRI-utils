function sampling_mask = generate_samplingmask(res,uds_ratio_or_lines,type)

n1 = res(1);n2 = res(2);n3 = res(3);
% variable density random 2d sampling
if strcmp(type,'vds')
    sampling_mask = genrate_binary_sampling_map(n1,n2,uds_ratio_or_lines,n3); 
    sampling_mask = double(sampling_mask);

% variable density randome y sampling
elseif strcmp(type,'vds_y')
    sampling_mask = genrate_ylines_sampling_map(n1,n2,uds_ratio_or_lines,n3); 
    sampling_mask = double(sampling_mask);

% uniform density random 2d sampling
elseif strcmp(type,'uds')
    omega = find(rand(n1*n2*n3,1)<uds_ratio_or_lines);
    sampling_mask = zeros(n1,n2,n3);
    sampling_mask(omega) = 1;

% uniform density randome x sampling
elseif strcmp(type,'uds_y')
    raws = round(n1*uds_ratio_or_lines);
    ind_sample = randi(n1,raws,n3);
    sampling_mask = zeros(n1,n2,n3);
    for i = 1:n3
        sampling_mask(ind_sample(:,i),:,i) = 1;
    end

% radio sampling
elseif strcmp(type,'radial')
    line = uds_ratio_or_lines;
    [T3D] = strucrand(n1,n2,n3,line);
    sampling_mask = T3D;
else 
    error(sprintf(['type needs to be','\n',...
        'vds   ----> variable density random 2d sampling','\n', ...
        'vds_y ----> variable density randome y sampling','\n', ...
        'uds   ----> uniform density random 2d sampling','\n', ...
        'uds_y ----> uniform density random y sampling','\n', ...
        'radial----> radial sampling']));
end