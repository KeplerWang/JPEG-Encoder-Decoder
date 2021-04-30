function code = code_item(DC_code, AC_code, AC_tag, pic_zigzag, m, AC_16zero_code, AC_allzero_code)
pre_dc = 0;
zero_count = 0;
code_count = 1;
code = cell(m, 64);
for i = 1 : m
    for j = 1 : 64
        % 这个变量用来记录已经统计的前导0的个数
        pre_count = zero_count;
        if j == 1
            % 若j=1 编码 DC
            diff = pic_zigzag(i, 1) - pre_dc;
            pre_dc = pic_zigzag(i, 1);
            if diff == 0
                % 如果delta是0, 单独处理。
                tmp_code = '00';
            else
                % 表示abs(diff)需要len bit(s)
                len = floor(log2(abs(diff))) + 1;
                % 根据长度查DC表， 找出区间号SSSS
                SSSS = DC_code{len + 1};
                if diff < 0
                    % 如果diff < 0 需要取反码
                    end_code = Not(dec2bin(abs(diff)));
                else
                    end_code = dec2bin(diff);
                end
                tmp_code = strcat(SSSS, end_code);
            end
        elseif sum(pic_zigzag(i, j : end) == 0) == size(pic_zigzag(i, j : end), 2)
            % 通过算后面pic_zigzag后面0的个数，判断是否后面全0，如果全0就可以加结束EOB了
            % 这一步必须在每次AC编码之前进行，因为AC编码会统计0的个数，再进行编码，但是如果后面全0，就不用继续编码了。
            tmp_code = AC_allzero_code;
            code{i, code_count} = tmp_code;
            code_count = 1;
            break;
        elseif pic_zigzag(i, j) == 0
            % 统计0的个数
            zero_count = zero_count + 1;
            if zero_count == 16
                % 如果连续16个0，需要特殊处理
                tmp_code = AC_16zero_code;
                zero_count = 0;
            end
        else
            % AC编码 
            % 思路与DC类似，先算需要多少bit表示，根据此前统计前面0的个数，查AC表，构造RRRRSSSS码，再把值表示出来。
            len = floor(log2(abs(pic_zigzag(i, j)))) + 1;
            index = ismember(AC_tag, strcat(num2str(zero_count), '/', num2str(len))) == 1;
            RRRRSSSS = AC_code{index};
            if pic_zigzag(i, j) < 0
                end_code = Not(dec2bin(abs(pic_zigzag(i, j)))); 
            else
                end_code = dec2bin(pic_zigzag(i, j));
            end
            tmp_code = strcat(RRRRSSSS, end_code);
            zero_count = 0; % 注意每次编码AC后，需要把统计0的个数归零。
        end
        if pre_count == zero_count || zero_count == 0
            % 如果当前AC值是0, count就会++，可以通过对比一开始记录的值和现在的值来实现。
            % 另外如果zero_count归零了（或本来就是0），肯定有编码（不论DC/AC）。
            % 提示：后面全0的情况，直接编码break了，不会到这一步。
            code{i, code_count} = tmp_code;
            code_count = code_count + 1;
            if j == 64
                % code_count是编码表code的y坐标，为的是提高空间的紧凑性。
                code_count = 1;
            end
        end
    end
end
end

