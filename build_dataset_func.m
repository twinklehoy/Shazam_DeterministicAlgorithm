function [] = build_dataset_func(afe_settings)
"Building Dataset"

pitch = afe_settings(1);
zcr = afe_settings(2);
mfcc = afe_settings(3);
mfccd = afe_settings(4);
sc = afe_settings(5);
sk = afe_settings(6);
ste = afe_settings(7);
ss = afe_settings(8);
ssk = afe_settings(9);
srp = afe_settings(10);
sf = afe_settings(11);
hr = afe_settings(12);

%Leggo le tracce nella cartella train
wavs =  dir('train/*.wav');

%Inizializzo il mio dataset
dataset = {};
mean_feats = {};

%Specifico il numero di campioni da prendere per ogni traccia
N_samples_per_song = 1;

%Inizializzo l'array vuoto che conterrà le tracce che andrò a salvare
wavs_to_save = [];
ids = [];

%Itero tra le tracce della cartella train
for i=1:length(wavs)

    %Estraggo più campioni da ogni traccia
    for j=1:N_samples_per_song
        ids = [ids, i];
        
        %wavs(i).name
        [y,Fs]=audioread(strcat(wavs(i).folder,'/',wavs(i).name));

        %Prendo il primo canale del mio segnale audio
        %y = y(20*Fs:Fs*40,1);
        y = y(:,1);

        %Aggiungo il rumore Gaussiano
        noise = imnoise(y,'Gaussian', 0.00, 0.00005*(i-1));
        y_noised = y+noise;

        %Estraggo le feature audio dal segnale
        aFE = audioFeatureExtractor( "SampleRate", Fs, "Window",  ones(1000,1), "OverlapLength", 10, ...
                "SpectralDescriptorInput", "melSpectrum",  "pitch", pitch, "zerocrossrate", zcr, ...
                "mfcc", mfcc, "mfccDelta", mfccd, "spectralCentroid", sc, "spectralKurtosis", sk, "shortTimeEnergy", ste, "harmonicRatio", hr, ...
                "spectralSlope", ss, "spectralSkewness", ssk, "spectralRolloffPoint", srp, "spectralFlux", sf);
    
        %Normalizzo le feature
        f = extract(aFE, y_noised);
        f = (f - mean(f,1))./(std(f,[],1));

        %Se nella matrice di feature ci sono dei NaN li metto a 0 e
        %aggiungo la matrice di feature al dataset
        f(isnan(f)) = 0;
        wavs_to_save = [wavs_to_save, wavs(i)];
        dataset{end+1} = f;

        %Faccio la media delle feature per ogni campione
        mean_feats{end+1} = mean(f, 1);
    end
end

%Salvo il dataset in un file matlab
wavs = wavs_to_save;
save dataset.mat dataset wavs ids;

mean_feats = cell2mat(mean_feats');
std(normalize(mean_feats, 'range'));
