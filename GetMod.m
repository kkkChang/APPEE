function [x, y, PE1_1to256, PE2_1to256] = GetMod(PE1, PE2, i, j, M, W)

PE1_1to256 = abs(PE1(i,j) + 0.5) + 0.5;
PE2_1to256 = abs(PE2(i,j) + 0.5) + 0.5;
output = zeros(1,4);
output_num = 0;
for k = 1:4
    if M(PE1_1to256,PE2_1to256,k) == 1
        output_num = output_num + 1;
        output(output_num) = k;
    end
end
s1 = [0 0 1 1];
s2 = [0 1 1 0];
t = mod(W(i,j),output_num)+1;
x = s1(output(t));
y = s2(output(t));