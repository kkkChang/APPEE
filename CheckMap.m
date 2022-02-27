function [] = CheckMap(M)
invH = zeros(255,255);
invnumH = zeros(255,255);
for i = 1:255
    for j = 1:255
        [inv,inv_num] = getInvDir(M,i,j);
        invH(i,j) = inv;
        invnumH(i,j) = inv_num;
    end
end
for i = 1:255
    for j = 1:255
        if invnumH(i,j) ~= 1 || sum(M(i,j,:)) == 0
            error('Error! The optimal mapping is wrong');
        end
    end
end