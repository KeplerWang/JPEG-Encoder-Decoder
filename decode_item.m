function decode = decode_item(DC_code, AC_code, AC_tag, code, m, AC_16zero_code, AC_allzero_code)
decode = zeros(m, 64);
countinue_count = 0;    % 保存连续0的个数，当遍历decode表时，用来控制continue
code_j = 1;             % 用来遍历code表的index
pre_dc = 0;
for i = 1 : m
    for j = 1 : 64
        item = code{i, code_j};
        if strcmp(item, AC_allzero_code) && j ~= 1
            % 先将取出的码和AC的EOB对比，如果相同，不用继续解码了，都是0；
            % 但是要注意 j~=1也是条件，因为色度的EOB是00，而亮度和色度的DC表第一项就是00。
            countinue_count = 0;
            code_j = 1;
            break;
        elseif countinue_count ~= 0
            countinue_count = countinue_count - 1;
            continue;
        end
        len = size(item, 2);
        for k = 2 : len
            % 由于Huffman码是即时码，即任意一个Huffman码不是其他Huffman码的前缀。
            % 所以可以从头截取k、k+1位...的码，查询码表该码是否出现了。
            if code_j == 1
                % 同样地，code表的第一位是DC部分。
                if strcmp(item(1 : k), '00')
                    % 同样地，'00'是特殊情况，表示当前DC值与上一个DC值相同，即delta=0。
                    decode(i, 1) = decode(i - 1, 1);
                    code_j = code_j + 1;
                    break;
                end
                % 这一行就是在开始讲的，"截取k、k+1位...的码，查询码表该码是否出现了。"
                index = find((ismember(DC_code, item(1 : k)) == 1) == 1, 1);
                if ~isempty(index) 
                    tmp_code = item(k + 1 : k + index - 1);
                    pos_neg = 1;
                    if tmp_code(1) == '0'
                        % 通过判断首位是否是0，来判断正负。
                        tmp_code = Not(tmp_code);
                        pos_neg = -1;
                    end
                    decode(i, 1) = bin2dec(tmp_code) * pos_neg + pre_dc;
                    pre_dc = decode(i, 1);
                    code_j = code_j + 1;
                    break;
                end
            else
                % code_j ~= 1，即AC部分
                index = find((ismember(AC_code, item(1 : k)) == 1) == 1, 1);
                if index == 152
                    % index=152意味着出现了连续16个0（注意这也意味着，16个0后面有非0），不然直接用EOB编码了
                    % 记录一下需要continue j的次数
                    countinue_count = 15;
                    code_j = code_j + 1;
                    break;
                end
                if ~isempty(index)
                    % 查tag表，获取前0的个数、数值表示的bit数
                    tmp_tag = AC_tag{index, 1};
                    % 通过查找'/'的位置，来截断
                    half_index = find(tmp_tag == '/');
                    zero_num = str2double(tmp_tag(1 : half_index - 1));
                    code_len = str2double(tmp_tag(half_index + 1 : end));
                    countinue_count = zero_num;
                    tmp_code = item(k + 1 : k + code_len);
                    pos_neg = 1;
                    if tmp_code(1) == '0'
                        tmp_code = Not(tmp_code);
                        pos_neg = -1;
                    end
                    decode(i, j + zero_num) = bin2dec(tmp_code) * pos_neg;
                    code_j = code_j + 1;
                    break;
                end
            end
        end
    end
    % 注意：每次j一个循环后，需要将code_j置1，进行下一行的解码。
    code_j = 1;
end
end

