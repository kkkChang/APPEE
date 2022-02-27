function [inv,inv_num] = getInvDir(M,i,j)

inv_num = 0;
if M(i,j,1) == 1
    inv = 1;
    inv_num = inv_num+1;
end
if j > 1
    if M(i,j-1,2) == 1
        inv = 2;
        inv_num = inv_num+1;
    end
end
if i > 1 && j > 1
    if M(i-1,j-1,3) == 1
        inv = 3;
        inv_num = inv_num+1;
    end
end
if i > 1
    if M(i-1,j,4) == 1
        inv = 4;
        inv_num = inv_num+1;
    end
end