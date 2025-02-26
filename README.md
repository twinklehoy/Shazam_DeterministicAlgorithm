# Descrizione del progetto
Il progetto in esame riguarda il miglioramento dell’applicazione Shazam tramite l’utilizzo di un maggior numero di features, l’introduzione del rumore nel dataset e il riconoscimento di tracce non allineate temporalmente. Nello specifico, il progetto comprende i seguenti files:
- **build_dataset_func.m**: funzione che serve per la costruzione del dataset di canzoni tramite l’estrazione di features dalle tracce audio;
- **evaluate.m**: che presa in input una canzone, ci aggiunge alla traccia rumore bianco per aumentare la difficoltà di riconoscimento, ne estrae le features e determina la canzone più simile a quella in esame;
- **featuredistance.m**: funzione che serve per il calcolo della distanza tra le feature
  
# Costruzione del dataset
La costruzione del dataset procede su tutte le tracce audio presenti in una cartella “train” in formato “.wav”. Per ogni traccia, vengono generati N records ai quali viene aggiunto del rumore gaussiano. Per ognuno di questi record vengono estratte le features tramite la funzione audioFeatureExtractor. Per l’estrazione è possibile scegliere la dimensione delle finestre e la frequenza di campionamento. Più concretamente, per ogni record vengono estratte le seguenti features:
- **Pitch**: Tono della traccia estratto con il metodo NCF nel range di frequenza 40Hz-400Hz.
- **Zero-crossing rate**: Tasso di transizione dell’audio da positivo a negativo.
- **MFCC**: Mel-Frequency Cepstral Coefficients, ovvero 13 coefficienti che descrivono la forma complessiva dello spettro che sono spesso usati per descrivere il timbro. Questa feature viene estratta utilizzando una trasformata di Fourier a breve termine e una scala di frequenza non lineare chiamata scala di Mel.
- **MFCC Delta**: Derivata prima degli MFCC, insieme alla derivata seconda servono per comprendere meglio le dinamiche della traccia. Questa feature viene estratta sottraendo il valore attuale della MFCC al valore precedente in un certo intervallo di tempo.
- **Spectral Centroid**: Rappresenta il centro di massa dello spettro di potenza del segnale audio ed è utilizzato per descrivere la luminosità o la tonalità della canzone.
- **Spectral Kurtosis**: Rappresenta la forma dello spettro di potenza del segnale audio ed è utilizzato per descrivere la nitidezza o la larghezza del suono.
- **Short Time Energy**: misura la quantità di energia in una finestra di tempo di breve durata all'interno di un segnale audio.
- **Harmonic Rate**: misura la quantità di energia presente nelle armoniche fondamentali di un segnale audio.
- **Spectral Flux**: misura la variazione di energia spettrale tra diverse finestre temporali all'interno di un segnale audio.
- **Spectral RolloffPoint**: indica la frequenza al di sotto della quale si concentra la maggior parte dell'energia spettrale di un segnale audio.
- **Spectral Skewness**: misura l'asimmetria della distribuzione spettrale di un segnale audio.
- **Spectral Slope**: è una misura della pendenza dello spettro di potenza di un segnale audio.
Nello specifico, per ogni traccia t-esima vengono ottenute N_t finestre con 36 features in un vettore di dimensione N_i x 36. Le finestre hanno dimensione 1000 e sono generate con uno step di 10.
Le features, dopo essere state estratte, vengono normalizzate per garantire una maggiore stabilità.
Di ogni record viene salvato in un array l’indice della traccia di riferimento e le features estratte. L’array viene salvato sul disco rigido tramite la funzione save di MATLAB.

## Processamento delle features
![image](https://github.com/user-attachments/assets/292ae180-bc7a-4a9e-81f5-324cc6b6163a)


# Riconoscimento delle tracce
Quando si vuole riconoscere una traccia, la si deve codificare numericamente. Vengono quindi estratte le features utilizzando la stessa tecnica della costruzione del dataset. La rappresentazione digitale della traccia viene poi confrontata con i record presenti nel dataset. In particolare, viene estratto il nome della traccia per la quale è minimizzata la distanza euclidea nello spazio delle features.
Considerata quindi una traccia input x rappresentata nello spazio delle features con una matrice n x 36 (dove n sono le windows della traccia), per calcolare la distanza tra x e una generica traccia del dataset t rappresentata dalla matrice f di dimensioni N_t x 36 (con N_t > n), si fa scorrere la matrice x lungo la matrice f e si calcola la distanza euclidea tra le features delle finestre:
![formula](https://github.com/user-attachments/assets/eeaab5a3-19af-4a7c-96f9-d90b70de5ebc)


# Analisi di Importanza delle Features
Per individuare le features più salienti è stata fatta una analisi della variazione della accuratezza a seguito della rimozione delle features su una porzione ridotta del dataset. Dall’analisi si evince che il modello statistico necessita solamente dei valori MFCC e MFCC Delta per poter effettuare una corretta predizione. Tutti gli altri descrittori, se rimossi, non portano a variazioni della performance.
È stato successivamente allenato un modello solo con le due features salienti ed ha riportato una accuratezza del 100%. Si è inoltre studiato se fosse necessario usare entrambe le features e, provando a rimuoverle alternativamente il modello riporta un abbassamento drastico delle performance.
Tutti gli esperimenti sono stati svolti aggiungendo rumore gaussiano con media 0 e deviazione standard 0.001 e considerando una porzione di traccia di 3 secondi in una finestra temporale disallineata da quella del training. Nonostante il rumore, a livello uditivo, altera in modo decisivo la traccia audio, il modello è comunque in grado di classificare correttamente.
Un’ulteriore analisi ha riguardato la necessità di aggiungere rumore alle tracce in fase di generazione del dataset. Per farlo, per ogni traccia vengono generate le features in situazioni di rumore crescente e salvate nel dataset. Questa strategia non ha portato a variazioni delle performance in quanto già con le precedenti strategie si erano ottenuti ottimi risultati.

# Risultati su tracce audio registrate con telefono
È stato infine svolto un esperimento per valutare la performance del modello in situazioni di rumore realistico. I precedenti esperimenti, infatti, prevedevano l’aggiunta di un rumore sintetico. In questo esperimento le tracce sono state registrate mediante l’applicazione Registratore del telefono Oppo Reno8 ed il modello è stato valutato tramite accuratezza. Per questo esperimento è stato aggiunto rumore ambientale durante la registrazione per simulare un disturbo più verosimile.
Il modello raggiunge un’accuratezza del 100%.
![image](https://github.com/user-attachments/assets/2e6f6c72-7ce3-47f2-9e76-a1d4896b71b5)



