# cIAk - Sistema di Raccomandazione di Film
<img src="https://github.com/emanueleivn/cIAk/blob/main/ciak_logo.png" alt="Logo progetto" width="250"/>

Repository ufficiale del progetto **cIAk**, sviluppato per il corso di Fondamenti di Intelligenza Artificiale presso l'Università degli Studi di Salerno (AA 2024/2025).

## Introduzione

**cIAk** è un sistema di raccomandazione progettato per migliorare l’esperienza utente nel contesto della prenotazione di posti al cinema. Il sistema analizza le preferenze passate degli utenti e utilizza modelli di machine learning per suggerire film personalizzati. Questo progetto è integrato con **CineNow**, un’applicazione web per la prenotazione di biglietti per la catena di cinema Movieplex.

---

## Struttura della Repository

La repository è organizzata come segue:

- **`dataset_imdb/`**: Contiene il dataset ottimizzato utilizzato per l'addestramento del modello.
  - [`dataset_ottimizzato.csv`](https://github.com/emanueleivn/cIAk/blob/main/dataset_imdb/dataset_ottimizzato.csv): Dataset preprocessato.
  
- **`cIAk_scripts/`**: Contiene gli Script di: implementazione , valutazione degli algoritmi e ottimizzazione del dataset.
  - [`uso_modello.py`](https://github.com/emanueleivn/cIAk/blob/main/cIAk_scripts/uso_modello.py): Script per testare il modello con le preferenze simulate di un utente.
  
- **`model/`**: File del modello addestrato.
  - `modello_raccomandazione.pkl`: Modello di raccomandazione serializzato.

- **`app/`**: Codice del server Flask utilizzato per comunicare con **CineNow**.
  - `app.py`: Server REST per gestire richieste di raccomandazioni.
  - `config.py`: File di configurazione per il server.

---

## Avvio del Progetto

Per eseguire il progetto, segui questi passaggi:

### Prerequisiti

- Python 3.8 o superiore
- Librerie Python richieste (installabili tramite `requirements.txt`):
  ```
  pip install -r requirements.txt
  ```
- [Flask](https://flask.palletsprojects.com/): Framework utilizzato per il server REST.

### Istruzioni di Avvio

1. **Clonare la Repository:**
   ```bash
   git clone https://github.com/emanueleivn/cIAk.git
   cd cIAk
   ```

2. **Avviare il Server Flask:**
   ```bash
   cd app
   python app.py
   ```
   Il server sarà disponibile all’indirizzo `http://127.0.0.1:5000/recommend`.

3. **Testare il Modello:**
   Esegui lo script di test:
   ```bash
   cd ../cIAk_scripts
   python uso_modello.py
   ```
4. **Avviare script SQL**
  - [`CineNowScript`]([https://github.com/emanueleivn/cIAk/blob/main/dataset_imdb/dataset_ottimizzato.csv](https://github.com/emanueleivn/cIAk/blob/main/CineNow/CineNowScript.sql)): Script creazione e popolamento database.
5. **Integrazione con CineNow:**
   - Integra il server Flask con il sistema **CineNow** utilizzando l'endpoint REST `/recommend`.
   - Consulta la documentazione su [CineNow](https://github.com/emanueleivn/CineNow) per ulteriori dettagli sul sistema.

---

## Contatti

Per ulteriori informazioni o segnalazioni di problemi, contattare:

- **Emanuele Iovane** - [emiiovane@email.com](mailto:emiiovane@email.com)

---

## Copia della Repository

Puoi clonare la repository con il seguente comando:
```bash
git clone https://github.com/emanueleivn/cIAk.git
```

