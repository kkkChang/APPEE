function [CostCD, vog, H, M] = GetMap(PE1, PE2, LC, half_capacity, TH_index, Block_size, K, half_row, half_col)

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

if count == 0
    vog = 1;
    CostCD = 10^5;
    M = zeros(18,18);
    return
end

Hbis = zeros(20,20);
Hbis(1:19,1:19) = H(1:19,1:19);
for i = 1:19
    Hbis(i,20) = sum(H(i,20:end));
    Hbis(20,i) = sum(H(20:end,i));
end
Hbis(20,20) = sum(sum(H(20:end,20:end)));
H = Hbis;

%% C Program
op = fopen('mo.txt','w');
fprintf(op,'%f %f %f',Block_size, half_capacity, K);
fprintf(op,'\n');
for i = 1:20
    for j = 1:20
        fprintf(op,'%f ',H(i,j));
    end
    fprintf(op,'\n');
end
fclose(op);

% system('APPEE.exe');
system('APPEE_noprint.exe');
oi = fopen('CSRout.txt','r');
CostCD = fscanf(oi,'%f',1);
vog = fscanf(oi,'%f',1);
M = fscanf(oi,'%f',[Block_size, Block_size]);
fclose(oi);