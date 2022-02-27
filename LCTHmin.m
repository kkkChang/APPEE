function [TH_min,Vog] = LCTHmin(PE1, PE2, LC, half_row, half_col, half_capacity)

Vog = 0;
% Initial conventional 2D mapping
M_conv = zeros(20,20,4);
M_conv(1,1,:) = [1 1 1 1]; % (0,0)
for i = 2:20
    M_conv(1,i,:) = [0 1 1 0]; % (0,i-1)
    M_conv(i,1,:) = [0 0 1 1]; % (i-1,0)
end
for i = 2:20
    for j = 2:20
        M_conv(i,j,:) = [0 0 1 0];
    end
end


for TH_index = 1:1024
    count = 0;
    H = zeros(256,256);
    for i = 1:half_row
        for j = 1:half_col
            if LC(i,j) <= TH_index
                t1 = abs(PE1(i,j)+0.5)+0.5; 
                t2 = abs(PE2(i,j)+0.5)+0.5; 
                H(t1,t2) = H(t1,t2)+1;
                count = count + 1;
            end
        end
    end
    
    Hbis = zeros(20,20);
    Hbis(1:19,1:19) = H(1:19,1:19);
    for i = 1:19
        Hbis(i,20) = sum(H(i,20:end));
        Hbis(20,i) = sum(H(20:end,i));
    end
    Hbis(20,20) = sum(sum(H(20:end,20:end)));
    H = Hbis;
    
    % estimate EC
    EC = 0;
    for i = 1:20
        for j = 1:20
            EC = EC + H(i,j) * log2(sum(M_conv(i,j,:)));
        end
    end
    
    if count ~= 0 && EC >= half_capacity
        TH_min = TH_index;
        return
    end
    
    if TH_index == 1024
        disp('Capacity is too large to embed. Threshold is already 1024.');
        TH_min = 1024;
        Vog = 1;
        return
    end
end