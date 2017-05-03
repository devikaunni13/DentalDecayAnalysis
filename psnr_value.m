function psnr_value = psnr_value(I)
if(size(size(I),2)>2)
    I=rgb2gray(I);
end
[rows columns] = size(I);
G = imnoise(I, 'gaussian', 0, 0.003);
%figure, imshow(G);
squaredErrorImage = (double(I) - double(G)) .^ 2;
mse = sum(sum(squaredErrorImage)) / (rows * columns);
%figure, imshow(squaredErrorImage, []);
psnr = 10 * log10( 256^2 / mse);
psnr_value = psnr;