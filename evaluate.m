%%%%%%%%% Per la Demo va eseguito 'evaluate.m'%%%%%%%%%%%
%%%%% In output si potrà notare l'accuratezza delle predizioni con un
%%%%% dataset costruito togliendo una delle feature, per analizzare un
%%%%% eventuale impatto significativo della stessa sulla predizione.
%%%%% Per vedere invece i risultati delle predizioni sulle tracce
%%%%% registrate con il telefono nella cartella test, decommentare (**) 
%%%%% commentare (*), e sostituire 'train' a 'test' sotto.

clear
close all

%Leggo le tracce nella cartella train
wavs =  dir('train/*.wav');

n_settings = 12;
afe_settings_init = ones(1,n_settings).*true;

%Studio l'importanza delle feature
for setting_to_change=1:12
    afe_settings = afe_settings_init;
    afe_settings(setting_to_change) = false;
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
    build_dataset_func(afe_settings);

    %Indici delle tracce che andrò ad analizzare
    trues = [];
    
    %Indici delle tracce più simili a quelle analizzate
    preds = [];

    dataset = load('dataset.mat');

    dataset_features = dataset.dataset;
    dataset_wavs = dataset.wavs;
    dataset_ids = dataset.ids;

    %Itero tra le tracce della cartella train
    for i=1:length(wavs)
        y_true = i;
        [y,Fs]=audioread(strcat(wavs(i).folder,'/',wavs(i).name));
    
        %Prendo un pezzo del segnale audio
        %y = y(3*Fs:8*Fs,1); %(**)
        y = y(23*Fs-15:28*Fs-25,1);%(*)

        %Aggiungo il rumore Gaussiano
        noise = imnoise(y,'Gaussian', 0.00, 0.001);
        y_noised = y+noise;
    
        %Estraggo le feature audio dal segnale
        aFE = audioFeatureExtractor( "SampleRate", Fs, "Window", ones(1000,1), "OverlapLength", 10, ...
                "SpectralDescriptorInput", "melSpectrum",  "pitch", pitch, "zerocrossrate", zcr, ...
                "mfcc", mfcc, "mfccDelta", mfccd, "spectralCentroid", sc, "spectralKurtosis", sk, "shortTimeEnergy", ste, "harmonicRatio", hr, ...
                "spectralSlope", ss, "spectralSkewness", ssk, "spectralRolloffPoint", srp, "spectralFlux", sf);
        f = extract(aFE, y_noised);

        %Normalizzo le feature
        f = (f - mean(f,1))./(std(f,[],1));
        f(isnan(f)) = 0;
    
        trues = [trues;y_true];
        best_w = 0;
        best_dist = Inf;
        ds = [];

        %Per ogni traccia calcolo feature distance e traccia più simile
        for i=1:length(dataset_features)
            d = dataset_features{i};
            w = dataset_ids(i);
            dist = featuredistance(f', d');
            ds = [ds, dist];
            if dist<best_dist
                best_dist = dist;
                best_w = w;
            end
        end
    
        preds = [preds; best_w];
    
    end
    
    %L'accuratezza con cui il programma riesce a predire le tracce
    accuracy = 100*(1.0*sum(trues==preds))/(1.0*length(preds));

    disp("Accuratezza: ");
    disp(accuracy);

end
