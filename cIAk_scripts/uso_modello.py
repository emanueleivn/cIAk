# simulazione uso modello

import pandas as pd
from collections import Counter
import joblib

def estrai_generi(genere_str):
    return [g.strip() for g in genere_str.split(',')]

def estrai_cast(cast_str):
    return [c.strip() for c in cast_str.split(',')]

# Similarità con preferenze utente
def calcola_similarita(row, preferenze):
    generi = estrai_generi(row['genere'])
    cast = estrai_cast(row['cast'])
    regista = row['regista']
    punteggio = 0
    punteggio += sum([preferenze['generi'].get(genere, 0) for genere in generi])
    punteggio += preferenze['registi'].get(regista, 0)
    punteggio += sum([preferenze['cast'].get(attore, 0) for attore in cast])
    return punteggio


def main():
    model_filename = 'addestramento modello/modello_raccomandazione.pkl'
    model = joblib.load(model_filename)
    #Simulazione prenotazioni utente
    film_prenotati = pd.DataFrame({
        'genere': [
            'Thriller, Azione',
            'Animazione, Avventura, Famiglia, Horror',
            'Thriller, Drammatico, Horror'
        ],
        'cast': [
            'Donald Glover, Beyoncé, Seth Rogen',
            'Josh Gad, Anya Taylor-Joy, Elizabeth Banks',
            'Colin Farrell, Eva Green, Michael Keaton'
        ],
        'regista': [
            'Jon Favreau',
            'David Lowery',
            'Tim Burton'
        ],
        'durata': [118, 140, 112]
    })

    generi_prenotati = film_prenotati['genere'].apply(estrai_generi).explode()
    registi_prenotati = film_prenotati['regista']
    cast_prenotati = film_prenotati['cast'].apply(estrai_cast).explode()

    contatore_generi = Counter(generi_prenotati)
    contatore_registi = Counter(registi_prenotati)
    contatore_cast = Counter(cast_prenotati)
    preferenze = {
        'generi': contatore_generi,
        'registi': contatore_registi,
        'cast': contatore_cast
    }
    print("\nFrequenza delle Preferenze dell'Utente:")
    print("Generi:", preferenze['generi'])
    print("Registi:", preferenze['registi'])
    print("Cast:", preferenze['cast'])

    # Caricamento dei film attualmente al cinema
    nuovi_film = pd.DataFrame({
        'genere': [
            'Animazione, Avventura, Drammatico',
            'Horror, Thriller',
            'Azione, Avventura, Thriller'
        ],
        'cast': [
            'Chiwetel Ejiofor, Shahadi Wright Joseph, Jason Mantzoukas',
            'Willem Dafoe, Elle Fanning, Bill Skarsgård',
            'Chris Evans, Ana de Armas, Jamie Foxx'
        ],
        'regista': [
            'Barry Jenkins',
            'Robert Eggers',
            'Chad Stahelski'
        ],
        'durata': [99, 108, 116]
    })

    nuovi_film['similarita'] = nuovi_film.apply(lambda row: calcola_similarita(row, preferenze), axis=1)

    previsioni = model.predict(nuovi_film[['genere', 'cast', 'regista', 'durata']])
    nuovi_film['consigliato'] = previsioni
    probabilita = model.predict_proba(nuovi_film[['genere', 'cast', 'regista', 'durata']])[:, 1]
    nuovi_film['probabilita_consigliato'] = probabilita

    print("\nPrevisioni sui Film Disponibili:")
    print(nuovi_film[['regista', 'durata', 'consigliato', 'probabilita_consigliato', 'similarita']])

    # Normalizziazione per ottenere lo stesso peso
    prob_min = nuovi_film['probabilita_consigliato'].min()
    prob_max = nuovi_film['probabilita_consigliato'].max()
    nuovi_film['probabilita_normalizzata'] = (nuovi_film['probabilita_consigliato'] - prob_min) / (
                prob_max - prob_min) if prob_max != prob_min else 0.0

    sim_min = nuovi_film['similarita'].min()
    sim_max = nuovi_film['similarita'].max()
    nuovi_film['similarita_normalizzata'] = (nuovi_film['similarita'] - sim_min) / (
                sim_max - sim_min) if sim_max != sim_min else 0.0

    peso_prob = 0.3
    peso_sim = 0.7

    nuovi_film['punteggio_combinato'] = peso_prob * nuovi_film['probabilita_normalizzata'] + peso_sim * nuovi_film[
        'similarita_normalizzata']

    print("\n===== Normalizzazione =====")
    print(nuovi_film[['probabilita_consigliato', 'probabilita_normalizzata', 'similarita', 'similarita_normalizzata']])
    print("\n===== Punteggio Combinato =====")
    print(nuovi_film[['regista', 'probabilita_normalizzata', 'similarita_normalizzata', 'punteggio_combinato']])
    n = 3
    film_consigliati = nuovi_film.sort_values(by='punteggio_combinato', ascending=False).head(n)

    print("\n===== Film Consigliati Personalizzati =====")
    for index, row in film_consigliati.iterrows():
        print(
            f"- {row['regista']} ({row['durata']} minuti) - Probabilità: {row['probabilita_consigliato']:.2f} - Similarità: {row['similarita']} - Punteggio Combinato: {row['punteggio_combinato']:.2f}")

if __name__ == "__main__":
    main()
