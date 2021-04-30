clear;close all;
load encode.mat
load DQT.mat
load DHT.mat

% 查表解码
pic_zigzag_y = decode_item(DC_luminance_code, AC_luminance_code, AC_luminance_tag, code_y, m, '11111111001', '1010');
pic_zigzag_cb = decode_item(DC_chrominance_code, AC_chrominance_code, AC_chrominance_tag, code_cb, m, '1111111010', '00');
pic_zigzag_cr = decode_item(DC_chrominance_code, AC_chrominance_code, AC_chrominance_tag, code_cr, m, '1111111010', '00');

% 逆zigzag变换
count = 1;
pic_y_quant = zeros(row, column);
pic_cb_quant = zeros(row, column);
pic_cr_quant = zeros(row, column);
for r = (0 : row / 8 - 1)
    for c = (0 : column / 8 - 1)
        pic_y_quant(r * 8 + 1 : (r + 1) * 8, c * 8 + 1 : (c + 1) * 8) = re_zigzag(pic_zigzag_y(count, :));
        pic_cb_quant(r * 8 + 1 : (r + 1) * 8, c * 8 + 1 : (c + 1) * 8) = re_zigzag(pic_zigzag_cb(count, :));
        pic_cr_quant(r * 8 + 1 : (r + 1) * 8, c * 8 + 1 : (c + 1) * 8) = re_zigzag(pic_zigzag_cr(count, :));
        count = count + 1;
    end
end

% 量化恢复
pic_y = pic_y_quant .* repmat(DQT_y, row / 8, column / 8);
pic_cb = pic_cb_quant .* repmat(DQT_cbcr, row / 8, column / 8);
pic_cr = pic_cr_quant .* repmat(DQT_cbcr, row / 8, column / 8);

% 逆dct变换
func = @idct2;
pic_ycbcr = zeros(row, column, 3);
pic_ycbcr(:, :, 1) = blkproc(pic_y, [8 8], func);
pic_ycbcr(:, :, 2) = blkproc(pic_cb, [8 8], func);
pic_ycbcr(:, :, 3) = blkproc(pic_cr, [8 8], func);

% ycbcr转位rgb
pic_rgb_normalized = ycbcr_to_rgb(pic_ycbcr);

% 对图片裁剪回原来的大小
pic_rgb_decoded = pic_rgb_normalized(1 : real_row, 1 : real_column, :);
imshow(uint8(pic_rgb_decoded))

