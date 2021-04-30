function Not_bin = Not(bin)
Not_bin = bin;
for i = 1 : size(bin, 2)
    if Not_bin(1, i) == '1'
        Not_bin(1, i) = '0';
    else
        Not_bin(1, i) = '1';
    end
end
end

