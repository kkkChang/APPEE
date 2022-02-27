function M_256x256x4 = TransMap(M_Blocksize, Block_size)
M_256x256 = zeros(256,256);
for i = 1:256
    for j = 1:256
        if i <= Block_size && j <= Block_size
            M_256x256(i,j) = M_Blocksize(i,j);
        else
            if i == 1
                M_256x256(i,j) = 2;
            else
                if j == 1
                    M_256x256(i,j) = 4;
                else
                    M_256x256(i,j) = 3;
                end
            end
        end
    end
end

M_256x256x4 = zeros(256,256,4);
for i = 1:256
    for j = 1:256
        if M_256x256(i,j) == 1
            M_256x256x4(i,j,1) = 1;
        end
        if M_256x256(i,j) == 2
            M_256x256x4(i,j-1,2) = 1;
        end
        if M_256x256(i,j) == 3
            M_256x256x4(i-1,j-1,3) = 1;
        end
        if M_256x256(i,j) == 4
            M_256x256x4(i-1,j,4) = 1;
        end
    end
end