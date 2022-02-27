%% demo of one-dimensional PEH£¬MatLab+C
%% APPEE£¬2D mapping adaptive selection
clear; clc;

% Parameters
Block_size = 8;
K = 2;
THR = 21;

img_path = 'D:\ImageDatabase\Classic_gray\';
img_list = dir(strcat(img_path,'*.bmp'));
img_num = length(img_list);

for i_img = 1:img_num
    img_name = img_list(i_img).name;
    I = double(imread(strcat(img_path, img_name)));
    
    I_orig = I;  % I_orig: cover image
    I_stego = I; % I_stego: stego image
    [row_img, col_img] = size(I);
    half_row = floor(row_img/2) - 1;
    half_col = floor(col_img/2) - 1;
    
    THdata = []; perf = []; RunTime = [];
    cnt = 0;
    img_end_capacity = [93000 21000 50000 38000 34000 35000 64000 39000];
    for Capacity = 5000:1000:img_end_capacity(i_img) % target capacity
        tic
        I = I_orig;
        I_stego = I_orig;
        cnt = cnt + 1;
        
        %% First layer, (2*i,2*j) and (2*i+1,2*j+1)
        PE1 = zeros(half_row, half_col);
        PE2 = zeros(half_row, half_col);
        LC = zeros(half_row, half_col);
        % Location map
        layer = 1; % layer=1: the first layer; layer=2: the second layer
        [I, Aux] = LM_Def(I, I_orig, Block_size, half_row, half_col, layer);
        
        % Compute prediction-error and local complexity
        for i = 1:half_row
            for j = 1:half_col
                p1 = I(2*i-1,2*j-1);  p2 = I(2*i-1,2*j);  p3 = I(2*i-1,2*j+1);  p4 = I(2*i-1,2*j+2);
                p5 = I(2*i  ,2*j-1);  x  = I(2*i  ,2*j);  p6 = I(2*i  ,2*j+1);  p7 = I(2*i  ,2*j+2);
                p8 = I(2*i+1,2*j-1);  p9 = I(2*i+1,2*j);  y  = I(2*i+1,2*j+1);  p10= I(2*i+1,2*j+2);
                p11= I(2*i+2,2*j-1);  p12= I(2*i+2,2*j);  p13= I(2*i+2,2*j+1);  p14= I(2*i+2,2*j+2);
                PE1(i,j) = x - ceil((p2+p5+p9+p6)/4);
                PE2(i,j) = y - ceil((p6+p9+p13+p10)/4);
                LC(i,j) = abs(p2-p5)+abs(p5-p9)+abs(p9-p6)+abs(p6-p2)+...
                    abs(p9-p13)+abs(p13-p10)+abs(p10-p6)+...
                    abs(p6-p4)+abs(p9-p11)+...
                    abs(p7-p4)+abs(p7-p6)+abs(p7-p10)+...
                    abs(p12-p11)+abs(p12-p9)+abs(p12-p13)+...
                    abs(p14-p10)+abs(p14-p13);
            end
        end
        
        %% optimal map and threshold of LC determination
        % find a optimal map for every threshold of LC, find a best threshold of LC among them
        vog = 1; % vog = 0/1: embedding succeed/failed
        Cost_current = 10^5;
        half_capacity = Capacity * 0.5 + Aux; % estimated target capacity
        % Pre-estimate the minimum value of the threshold of LC
        [TH_min,Vog] = LCTHmin(PE1, PE2, LC, half_row, half_col, half_capacity);
        if Vog == 1
            disp('1. Capacity is too large to embed.');
            Capacity
            break
        end
        
        count = 0;
        for TH_index = TH_min:1024 % TH_index: threshold of LC
            if count == THR
                break
            end
            [CostCD, vog, H, M] = GetMap(PE1, PE2, LC, half_capacity, TH_index, Block_size, K, half_row, half_col);
            if vog == 0 % embedding succeed
                count = count + 1;
                % [TH_index CostCD]
                if count == 1
                    rho_min = TH_index;
                end
                if Cost_current > CostCD
                    Cost_current = CostCD;
                    Mfinal = M;
                    Hfinal = H;
                    TH = TH_index;
                end
            end
        end
        if TH_index == 1024 && count == 0
            disp('1. Capacity is too large to embed.');
            Capacity
            break
        end
        
        M = TransMap(Mfinal, Block_size);
        CheckMap(M);
        
        % re-define the location map
        layer = 1;
        [I_stego, Aux] = LM_ReDef(I_orig, I_stego, LC, TH, Block_size, half_row, half_col, layer);
        
        %% True embedding
        W = randperm(half_row * half_col);
        W = reshape(W', half_row, half_col);
        for i = 1:half_row
            for j = 1:half_col
                if LC(i,j) <= TH && half_capacity > 0
                    [x,y,t1,t2] = GetMod(PE1, PE2, i, j, M, W);
                    I_stego(2*i,2*j) = I_stego(2*i,2*j) + x * sign(PE1(i,j) + 0.5);
                    I_stego(2*i+1,2*j+1) = I_stego(2*i+1,2*j+1) + y * sign(PE2(i,j) + 0.5);
                    half_capacity = half_capacity - log2(sum(M(t1,t2,:)));
                end
            end
        end
        % compute true EC
        EC = -Aux;
        ED = 0;
        for i = 1:20
            for j = 1:20
                EC = EC + Hfinal(i,j) * log2(sum(M(i,j,:)));
                ED = ED + Hfinal(i,j) * (M(i,j,2) + 2*M(i,j,3) + M(i,j,4))/sum(M(i,j,:)); % estimated MSE
            end
        end
        
        THdata(1,cnt) = TH_min;
        THdata(2,cnt) = rho_min;
        THdata(3,cnt) = TH;
        %     EC
        %     [TH Cost ED/(EC+Aux) Aux]
        %     rho_min
        
        % ------------------------------------------------------------------------------------------------------
        %% Second layer, (2*i,2*j+1) and (2*i+1,2*j)
        I = I_stego;
        PE1 = zeros(half_row,half_col);
        PE2 = zeros(half_row,half_col);
        LC = zeros(half_row,half_col);
        % Location map
        layer = 2; % the second layer
        [I, Aux] = LM_Def(I, I_orig, Block_size, half_row, half_col, layer);
        
        % Compute prediction-error and local complexity
        for i = 1:half_row
            for j = 1:half_col
                p1 = I(2*i-1,2*j-1);  p2 = I(2*i-1,2*j);  p3 = I(2*i-1,2*j+1);  p4 = I(2*i-1,2*j+2);
                p5 = I(2*i  ,2*j-1);  p6 = I(2*i  ,2*j);  x  = I(2*i  ,2*j+1);  p7 = I(2*i  ,2*j+2);
                p8 = I(2*i+1,2*j-1);  y  = I(2*i+1,2*j);  p9 = I(2*i+1,2*j+1);  p10= I(2*i+1,2*j+2);
                p11= I(2*i+2,2*j-1);  p12= I(2*i+2,2*j);  p13= I(2*i+2,2*j+1);  p14= I(2*i+2,2*j+2);
                PE1(i,j) = x - ceil((p3+p6+p7+p9)/4);
                PE2(i,j) = y - ceil((p6+p8+p9+p12)/4);
                LC(i,j) = abs(p6-p3)+abs(p3-p7)+abs(p7-p9)+abs(p9-p6)+...
                    abs(p8-p6)+abs(p9-p12)+abs(p12-p8)+...
                    abs(p1-p6)+abs(p9-p14)+...
                    abs(p10-p7)+abs(p10-p9)+abs(p10-p14)+...
                    abs(p13-p14)+abs(p13-p9)+abs(p13-p12)+...
                    abs(p11-p8)+abs(p11-p12);
            end
        end
        
        %% optimal map and threshold of LC determination
        % find a optimal map for every threshold of LC, find a best threshold of LC among them
        vog = 1;
        Cost_current = 10^5;
        half_capacity = Capacity * 0.5 + Aux;
        
        % Pre-estimate the minimum value of the threshold of LC
        [TH_min,Vog] = LCTHmin(PE1, PE2, LC, half_row, half_col, half_capacity);
        if Vog == 1
            disp('2. Capacity is too large to embed.');
            Capacity
            break
        end
        
        count = 0;
        for TH_index = TH_min:1024
            if count == THR
                break
            end
            [CostCD, vog, H, M] = GetMap(PE1, PE2, LC, half_capacity, TH_index, Block_size, K, half_row, half_col);
            if vog == 0 % embedding succeed
                count = count + 1;
                % [TH_index CostCD]
                if count == 1
                    rho_min = TH_index;
                end
                if Cost_current > CostCD
                    Cost_current = CostCD;
                    Mfinal = M;
                    Hfinal = H;
                    TH = TH_index;
                end
            end
        end
        if TH_index == 1024 && count == 0
            disp('2. Capacity is too large to embed.');
            Capacity
            break
        end
        
        M = TransMap(Mfinal,Block_size);
        CheckMap(M);
        
        layer = 2;
        [I_stego, Aux] = LM_ReDef(I_orig, I_stego, LC, TH, Block_size, half_row, half_col, layer);
        
        
        %% True embedding
        for i = 1:half_row
            for j = 1:half_col
                if LC(i,j) <= TH && half_capacity > 0
                    [x, y, t1, t2] = GetMod(PE1, PE2, i, j, M, W);
                    I_stego(2*i,2*j+1) = I_stego(2*i,2*j+1) + x * sign(PE1(i,j)+0.5);
                    I_stego(2*i+1,2*j) = I_stego(2*i+1,2*j) + y * sign(PE2(i,j)+0.5);
                    half_capacity = half_capacity - log2(sum(M(t1,t2,:)));
                end
            end
        end
        
        toc
        THdata(4,cnt) = TH_min;
        THdata(5,cnt) = rho_min;
        THdata(6,cnt) = TH;
        %     EC
        %     [TH Cost ED/(EC+Aux) Aux]
        %     rho_min
        
        % compute PSNR
        if half_capacity <= 0
            PSNR = 10*log10(row_img*col_img*255^2/sum(sum(abs(I_stego-I_orig))))
        else
            error('Error');
        end
        % PSNR = 10*log10(row_img*col_img*255^2/sum(sum(abs(I_stego-I_orig))))
        
        perf(1,cnt) = Capacity;
        perf(2,cnt) = PSNR;
        RunTime(1,cnt) = Capacity;
        RunTime(2,cnt) = toc;
    end
end