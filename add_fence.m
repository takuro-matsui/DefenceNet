function [J, P_n] = add_fence(img, theta, scale, color_num, noise, real)
% ************************************
% theta（フェンス角度） = 0, 15, 30, 45
% scale(フェンス太さ） = 1, 1.4
% color_num（フェンス色） 5種類
% fence_size（フェンス範囲） = 320で固定
% ************************************

if nargin <1
    img = im2single(imread('dataset/evaluation/color/lena.png'));
    theta = 10;
    scale = 1.5;
    color_num = 5;
    noise = false;
    real = true;
end

fence_mask = zeros(size(img));


if real
    
    flist = dir('matsui_dataset/train/label/*.png');
    fence = im2single(imread(['matsui_dataset/train/label/' flist(randi(numel(flist))).name]));
else
    fence = im2single(imread('dataset/fence2.png'));
    
end
fence = padarray(fence, [size(fence,1)/8, size(fence,1)/8], 'symmetric');



fence = imrotate(fence, theta, 'bilinear');
fence = imresize(fence, scale, 'bilinear');

color = [84, 94, 109; % 暗いグレー
            200, 200, 210; % 明るいグレー
            60, 100, 60; % 深緑
            120, 185, 160; % 明るい緑
            110, 85, 100; % 茶色
            255, 255, 255]/255;


P = fence(max(0, floor( (size(fence, 1) - size(img, 1)) / 2 )) + (1 : size(img, 1)), ...
          max(0, floor( (size(fence, 2) - size(img, 2)) / 2 )) + (1 : size(img, 2)),...
          1);

P = min(P * 1.5, 1);
%P = P > 0.2;

for i = 1:3

    fence_mask(:, :, i) = color(color_num, i);
end

P = repmat(single(P), 1, 1, 3);

if noise
    J = imnoise(fence_mask .* P, 'gaussian', 0, 0.001).*P ...
            + img .* (1-P); % アルファ合成
else
    J = fence_mask .* P + img .* (1 - P);
end
%J = 1-(1 - img).*(1-fence_mask); % ブレンド合成
%J = img + fence_mask; % 加算合成

P_n = single(P > 0.2);
if nargin <1
    figure(100); imshow([J, P_n]);
end
end