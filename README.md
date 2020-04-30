# DefenceNet
## Single-Image Fence Removal Using Deep Convolutional Neural Network (IEEE Access)
[[Paper Link (IEEE Access)](https://ieeexplore.ieee.org/document/8933392)] 
[[Paper Link (EI 2020)](http://docserver.ingentaconnect.com/deliver/fasttrack/ist/24701173/3279490-ipas_1580149687080.pdf?expires=1585644939&id=guest&checksum=DCC4B48B6E63DFAC6EC5921A2BDE3557)] 


In public spaces such as zoos and sports facilities, the presence of fences often annoys tourists and professional photographers. There is a demand for a post-processing tool to produce a non-occluded view from an image or video. This “de-fencing” task is divided into two stages: one to detect fence regions and the other to fill the missing part. For over a decade, various methods have been proposed for video-based de-fencing. However, only a few single-image-based methods are proposed. In this paper, we focus on single-image fence removal. Conventional approaches suffer from inaccurate and non-robust fence detection and inpainting due to less content information. To solve these problems, we combine novel methods based on a deep convolutional neural network (CNN) and classical domain knowledge in image processing. In the training process, we are required to obtain both fence images and corresponding non-fence ground truth images. Therefore, we synthesize natural fence images from real images. Moreover, spacial filtering processing (e.g. a Laplacian filter and a Gaussian filter) improves the performance of the CNN for detection and inpainting. Our proposed method can automatically detect a fence and generate a clean image without any user input. Experimental results demonstrate that our method is effective for a broad range of fence images.

![framework2.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/238733/92ce763c-4042-6817-df9b-908ad042635b.png)

## Citation

Please cite this paper if you use this code.

```
@ARTICLE{8933392, 
author={T. {Matsui} and M. {Ikehara}}, 
journal={IEEE Access}, 
title={Single-Image Fence Removal Using Deep Convolutional Neural Network}, 
year={2020}, 
volume={8}, 
number={}, 
pages={38846-38854},}
```



## Demo
Run `demo_defence.m`

## Installation
-  [MATLAB R2019a](https://ww2.mathworks.cn/en/products/new_products/release2019a.html)
- [caffe version 1.0.0-rc3](http://caffe.berkeleyvision.org/)
- CPU or NVIDIA GPU + CUDA CuDNN

## Summary of conventional de-fencing methods and our proposed method
<table>
<tr>
  <th></th>
  <th>Video-based</th>
  <th>Multiple image-based</th>
  <th colspan=4>Single mage-based</th>
</tr>

<tr>
  <th></th>
  <td><a href= "https://ieeexplore.ieee.org/document/6738278" >[3]</a><a href= "https://ieeexplore.ieee.org/document/7486506" >[4]</a></a><a href= "https://arxiv.org/abs/1609.07727" >[5]<a href= "https://arxiv.org/abs/1612.03273" >[6]</a><a href= "https://ieeexplore.ieee.org/document/7780452" >[7]</a></td>

  <td><a href= "https://www.semanticscholar.org/paper/A-multimodal-approach-for-image-de-fencing-and-Jonna-Voleti/09df6016705d6085904bd0a9cab90f5a2e05440f" >[10]</a><a href= "https://ieeexplore.ieee.org/document/6224549" >[11]</a></td>

  <td><a href= "https://ieeexplore.ieee.org/document/4587493" >[1]</a></td>
  <td><a href= "https://pennstate.pure.elsevier.com/en/publications/image-de-fencing-revisited" >[13]</a></td>
  <td><a href= "https://link.springer.com/article/10.1007/s11760-016-0876-7" >[14]</a></td>
  <td><font color="red"><b>Ours</b></font></td>
</tr>

<tr>
  <th></th>
  <td>Synthesize multifocused images</td>
  <td>Use temporal information</td>
  <td>Key point detection and K-means clustering</td>
  <td>Online learning</th>
  <td>Use color similarity based on user input</td>
  <td>CNN and image filtering</td>
</tr>

<tr>
  <th>Pros</th>
  <td>(+)Relatively high performance in static scene</td>

  <td>(+)Applicable to other objective removal tasks</td>

  <td>(+)End-to-end algorithm for regular fences</td>

  <td>(+)End-to-end algorithm for regular and near-regular fences</td>

  <td>(+)Able to detect even irregular fences</td>

  <td>(+)End-to-end algorithm regardless of fence colors and shapes<br><br>(+)Natural appearance</td>
</tr>

<tr>
  <th>Cons</th>
  <td>(-)Only for videos<br><br>(-)High computational cost  </td>

  <td>(-)Need to prepare for taking photos</td>

  <td>(-)Not able to detect near-regular and irregular fences<br><br>(-)High computational cost  </td>

  <td>(-)Not able to detect irregular fences<br><br>(-)High computational cost  </td>

  <td>(-)Need skilled-user intervention<br><br>(-)Not able to distinguish fences and background that have similar color</td>

<td>(-)Week to fence orientation and certain angle</td>
</tr>
</table>

## Dataset
### DetectNet
To train U-Net, we collect 545 real-world fence images and binary masks created by [Du et al.](https://github.com/chen-du/De-fencing/tree/master/dataset). From these images, we cropped 128 × 128 × 3 patches. In order to increase the amount of data for training improvement, the cropped patches are randomly flipped, rotated, zoomed and brightened.


### RemoveNet
Fence images are created by combining fence masks with the clean outdoor images from UCID dataset and from the BSD dataset. Training dataset was created by running fllowing: 
```
[fence_image, fence_mask] = add_fence(img, theta, scale, color_num, noise, real).
```


## Author

[takuro-matsui](https://ieeexplore.ieee.org/author/37086527658)

If you have any questions, please feel free to send us an e-mail matsui@tkhm.elec.keio.ac.jp.
