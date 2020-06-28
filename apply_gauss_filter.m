function restored_img = apply_gauss_fence(noisy, mask, filt_size, filt_type, gpu)
% ------------------------------------------------------------------
%  noisy     : Fence image
%  mask      : Fence mask
%  filt_size : Filter size
%  filt_type : Gaussian filter ("gauss") or average filter ("average") 
%  gpu       : Use gpu or not
% -------------------------------------------------------------------

    if nargin < 3
        filt_size = 11;
        filt_type = 'gauss';
        gpu = false;
    end
    sigma_value = 2;
    %%
    
    h = make_filter(filt_size, sigma_value);

    % padding
    edge = floor(filt_size/2);
    noisy_pad = padarray(noisy, [floor(filt_size/2) floor(filt_size/2)], 0);
    mask_pad = padarray(mask, [floor(filt_size/2) floor(filt_size/2)], 1);

    restored_img = zeros(size(noisy, 1), size(noisy, 2), size(noisy, 3));    mask_col = rgb2col_abk(mask_pad(:,:,1), filt_size, 1);
    switch filt_type
        case 'gauss'
            gfilter = repmat(h(:) ,1,  size(mask_col, 2));
            g = ~mask_col .* gfilter;
    end
    for i = 1:3
        noisy_col = rgb2col_abk(noisy_pad(:,:,i), filt_size, 1);

        switch filt_type
            case 'average'
                ave = (sum(noisy_col .* ~mask_col)) ./ sum(~mask_col);
            case 'gauss'
                ave = sum(noisy_col .* g ./ sum(g));
        end

        % restored
        one_channel = reshape(ave, size(noisy_pad,1)-filt_size+1, size(noisy_pad,2)-filt_size+1);

        restored_img(:,:,i) = one_channel .* mask(:,:,i)...
                              + noisy_pad(edge+1:end-edge, edge+1:end-edge, i) .* ~mask(:,:,i);

    end   
    
    
    %%
  
    t=0;
    while sum(mask(:)) > 0 && t<10
        sigma_value = floor(filt_size/2);
        t=t+1;
        h = make_filter(filt_size, sigma_value);
        eps = 0.0001;

        % padding
        edge = floor(filt_size/2);
        
        noisy_pad = padarray(noisy, [floor(filt_size/2) floor(filt_size/2)], 0);
        mask_pad = padarray(mask, [floor(filt_size/2) floor(filt_size/2)], 1);

        if gpu
            restored_img = gpuArray(zeros(size(noisy, 1), size(noisy, 2), size(noisy, 3), 'single'));
        else
            restored_img = zeros(size(noisy, 1), size(noisy, 2), size(noisy, 3), 'single');
        end

            mask_col = rgb2col_abk(mask_pad(:,:,1), filt_size, 1);
        switch filt_type
            case 'gauss'
                g = ~mask_col .* h(:);%gfilter;
        end
        for i = 1:3

            noisy_col = rgb2col_abk(noisy_pad(:,:,i), filt_size, 1);
           switch filt_type
                case 'average'
                    ave = (sum(noisy_col .* ~mask_col)) ./ sum(~mask_col);
                case 'gauss'
                    ave = sum(noisy_col .* g ./ (sum(g) + eps));
                    nan_position = ismissing(ave);
                    ave(nan_position) = 0;
            end


            % restored
            one_channel = reshape(ave, size(noisy_pad,1)-filt_size+1, size(noisy_pad,2)-filt_size+1);

            restored_img(:,:,i) = one_channel .* mask(:,:,i)...
                                  + noisy_pad(edge+1:end-edge, edge+1:end-edge, i) .* ~mask(:,:,i);

        end  
        mask = mask .* (restored_img(:,:,1)==0).* (restored_img(:,:,2)==0).* (restored_img(:,:,3)==0);
        noisy = restored_img;

    end


end