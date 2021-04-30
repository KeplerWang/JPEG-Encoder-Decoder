function ycbcr = rgb_to_ycbcr(rgb)
[x, y, ~] = size(rgb);
ycbcr = zeros(x, y, 3);
R = rgb(:, :, 1);
G = rgb(:, :, 2);
B = rgb(:, :, 3);
ycbcr(:, :, 1) = 0.299 * R + 0.587 * G + 0.114 * B;
ycbcr(:, :, 2) = 128 - 0.168736 * R - 0.331264 * G + 0.5 * B;
ycbcr(:, :, 3) = 128 + 0.5 * R - 0.418688 * G - 0.081312 * B;
end

