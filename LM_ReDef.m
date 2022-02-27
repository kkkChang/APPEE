function [I_stego, Aux] = LM_ReDef(I_orig, I_stego, LC, TH, Block_size, half_row, half_col, layer)

LM = zeros(half_row, 2 * half_col);
for i = 1:half_row
    for j = 1:half_col
        if LC(i,j) <= TH
            if layer == 1 % First layer, (2*i,2*j) and (2*i+1,2*j+1)
                if I_orig(2*i,2*j) == 0
                    I_stego(2*i,2*j) = 1;
                    LM(i,2*j-1) = 1;
                end
                if I_orig(2*i,2*j) == 255
                    I_stego(2*i,2*j) = 254;
                    LM(i,2*j-1) = 1;
                end
                if I_orig(2*i+1,2*j+1) == 0
                    I_stego(2*i+1,2*j+1) = 1;
                    LM(i,2*j) = 1;
                end
                if I_orig(2*i+1,2*j+1) == 255
                    I_stego(2*i+1,2*j+1) = 254;
                    LM(i,2*j) = 1;
                end
            elseif layer == 2 % Second layer, (2*i,2*j+1) and (2*i+1,2*j)
                if I_orig(2*i,2*j+1) == 0
                    I_stego(2*i,2*j+1) = 1;
                    LM(i,2*j-1) = 1;
                end
                if I_orig(2*i,2*j+1) == 255
                    I_stego(2*i,2*j+1) = 254;
                    LM(i,2*j-1) = 1;
                end
                if I_orig(2*i+1,2*j) == 0
                    I_stego(2*i+1,2*j) = 1;
                    LM(i,2*j) = 1;
                end
                if I_orig(2*i+1,2*j) == 255
                    I_stego(2*i+1,2*j) = 254;
                    LM(i,2*j) = 1;
                end
            end
        end
    end
end
Aux = ComAux(LM, Block_size);