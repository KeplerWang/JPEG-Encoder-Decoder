function pic_normalized = pic_normalize(pic)
[row, column, ~] = size(pic);
r = ceil(row / 8);
c = ceil(column / 8);
pic_normalized = zeros(8 * r, 8 * c, 3);
pic_normalized(1 : row, 1 : column, :) = pic;
pic_normalized(:, column + 1 : end, 1) = pic(row, column, 1);
pic_normalized(:, column + 1 : end, 2) = pic(row, column, 2);
pic_normalized(:, column + 1 : end, 3) = pic(row, column, 3);

pic_normalized(row + 1 : end, :, 1) = pic(row, column, 1);
pic_normalized(row + 1 : end, :, 2) = pic(row, column, 2);
pic_normalized(row + 1 : end, :, 3) = pic(row, column, 3);
end

