% La funzione prende in input FX e FB che sono rispettivamente
% la matrice di feature di una traccia nel dataset e la matrice di feature
% della traccia che sto cercando
function mismatch = featuredistance(FX, FB)
    [~,NTF] = size(FX);
    [~,NTB] = size(FB);
    offset = 1;
    mismatch = Inf;
    % Calcoco il mismatch facendo la media della radice quadrata della somma
    % dele differenze quadrate tra ogni elemento delle due matrici,
    % aggiorno mismatch e incremento l'offset
    while(NTF+offset-1<=NTB) && mismatch>0
        thismismatch = mean(sqrt(sum((FX-FB(:,offset:offset+NTF-1)).^2,1)));
        mismatch = min(thismismatch, mismatch);
        offset = offset+1;
    end

end
