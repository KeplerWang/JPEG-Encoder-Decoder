function rgb = ycbcr_to_rgb(ycbcr)
[x, y, ~] = size(ycbcr);
rgb = zeros(x, y, 3);
y = ycbcr(:, :, 1);
cb = ycbcr(:, :, 2);
cr = ycbcr(:, :, 3);
rgb(:, :, 1) = y + 1.402 * (cr - 128);
rgb(:, :, 2) = y - 0.344136 * (cb - 128) - 0.714136 * (cr - 128);
rgb(:, :, 3) = y + 1.772 * (cb - 128);
end     
            