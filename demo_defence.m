% =======================================================================
% ======================== 'demo_defence.m'===============================
% This script is for implementation of DefenceNet proposed in the paper
% whose title is "GAN-Based Rain Noise Removal From Single-Image 
%                                   Considering Rain Composite Models".
% You can test on both synthetic and real-world images.
%   Input        : Fence image
%   Medium output: Estimated mask
%   Final output : De-fenced image
% =======================================================================
%% Parameters
patch_size = 128;
rot = true;
synthe = false;
gpu = true;
%%
if synthe
    img_dir = 'dataset/test/';
else
    img_dir = 'dataset/evaluation/';
end

img_list = dir([img_dir '*.jpg']);


idx = 4;

img_name = img_list(idx).name;
 
if synthe
    img = im2single(imread([img_dir img_name]));
    [J, P_n] = add_fence(img, 20, 1, randi(5), true, true);
else
    J = im2single(imread([img_dir img_name]));
end

if gpu
    caffe.reset_all();
    caffe.set_mode_gpu();
    caffe.set_device(0);
end

%% Detect phase
prototxt_file_detect = './validation/eval_DetectUnet_xavier.prototxt';
weight_h5_detect = './weight/DetectUnet_xavier_0721realrot_iter_50000.caffemodel.h5';
net_detect = caffe.Net(prototxt_file_detect, weight_h5_detect, 'test');
if rot
    tmp_mask = {1,2,3,4};
    for r = 1:4
        tmp_mask{r} = rot90(patch_processing(net_detect, {rot90(J,r)}, patch_size, floor(patch_size*0.85), 0.3), 4-r);
    end
    estimated_mask = ones(size(J), 'like', J) .* ((tmp_mask{1}+tmp_mask{2}+tmp_mask{3}+tmp_mask{4})>0);
else
    estimated_mask = patch_processing(net_detect, {J}, patch_size, floor(patch_size*0.85), 0.2);
end
em = estimated_mask;

se = strel('disk',2,8);
BW2 = em(:,:,1);
BW2 = imerode(BW2,se);
BW2 = bwareaopen(BW2,800);

estimated_mask = ones(size(estimated_mask), 'like', estimated_mask) .*repmat(BW2,1,1,3);

%% Remove phase
prototxt_file_remove = './validation/eval_RemoveResNet3.prototxt';
weight_h5_remove = './weight/RemoveResNet3_0719synthe_iter_50000.caffemodel.h5';
net_remove = caffe.Net(prototxt_file_remove, weight_h5_remove, 'test');
estimated_img = apply_gauss_fence(J, estimated_mask, 11, 'gauss', false);
defenced_img = patch_processing(net_remove, {estimated_img, estimated_mask}, patch_size, floor(patch_size*0.85), 0.2);

%% Show results
color_mat = cat(3,0.99*ones(size(J,1),size(J,2)), 0.49*ones(size(J,1),size(J,2)), 0*ones(size(J,1),size(J,2)));
colored_img = J .* ~estimated_mask(:,:,1) + color_mat.*estimated_mask;
figure(idx);
subplot(2,3,1); imshow(J); title(['[' num2str(idx) '] ' strrep(img_name, '_', '\_')]);
subplot(2,3,2); imshow(em); title('Estimated mask');
subplot(2,3,3); imshow(estimated_mask); title('After mask enhancement');
subplot(2,3,4); imshow(colored_img); title('Fence and mask');
subplot(2,3,5); imshow(estimated_img); title('After gauss filter');
subplot(2,3,6);   imshow(defenced_img); title('Removed image');


%% Patch processing
% Crop an image to size of 128*128 so as not to exceed maximum memory
function final_output = patch_processing(net, input_list, patch_size, patch_shift, thre)
    input_image = input_list{1};
    final_output = zeros( size(input_image), 'like', input_image );
    overlap_count_output = final_output(:, :, 1);

    for patch_x = 1 : patch_shift : size(input_image, 2)
        for patch_y = 1 : patch_shift : size(input_image, 1)
            % y coordinate
            y_input = ( 1 : patch_size ) + patch_y - 1;
            y_output = (1 : patch_size ) + patch_y - 1;
            if y_input(end) > size(input_image, 1)
                y_input  = ( - patch_size + 1 : 0 ) + size(input_image, 1);
                y_output = ( - patch_size + 1 : 0 ) + size(input_image, 1);
            end
            % x cordinate
            x_input  = ( 1 : patch_size ) + patch_x - 1;
            x_output = ( 1 : patch_size ) + patch_x - 1;
            if x_input(end) > size(input_image, 2)
                x_input  = ( - patch_size + 1 : 0 ) + size(input_image, 2);
                x_output = ( - patch_size + 1 : 0 ) + size(input_image, 2);
            end
 
            for l = 1:length(input_list)
                net.blobs(net.inputs{l}).reshape([patch_size patch_size 3 1]); % reshape blob 'data'
            end
            net.reshape();
            
            input = cell(1,length(input_list));
            for lis = 1:length(input_list)
                input{lis} = input_list{lis}(y_input, x_input, :);
            end
            net.forward(input);

            
            final_output(y_output, x_output, :) =  final_output(y_output, x_output, :) + net.blobs('output').get_data();
           
             
            overlap_count_output(y_output, x_output) = overlap_count_output(y_output, x_output) + 1;
        end
    end

    final_output = final_output ./ overlap_count_output;
    
    if nargin >4
        final_output = ones(size(final_output), 'like', final_output) .* (final_output(:,:,1)>thre);
    end
end
