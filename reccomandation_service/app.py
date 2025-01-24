from flask import Flask, request, jsonify, abort
from flask_sqlalchemy import SQLAlchemy
import pandas as pd
import joblib
from collections import Counter
from config import Config
from flask_cors import CORS

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
db = SQLAlchemy(app)

# Definizione del modello del database per la tabella 'film'
class Film(db.Model):
    __tablename__ = 'film'
    id = db.Column(db.Integer, primary_key=True)
    titolo = db.Column(db.String(255), nullable=False)
    genere = db.Column(db.String(255), nullable=False)
    classificazione = db.Column(db.String(50), nullable=False)
    durata = db.Column(db.Integer, nullable=False)
    locandina = db.Column(db.LargeBinary)
    descrizione = db.Column(db.Text, nullable=False)
    cast = db.Column(db.String(255), nullable=False)
    regista = db.Column(db.String(255), nullable=False)
    is_proiettato = db.Column(db.Boolean, default=False)

def estrai_generi(genere_str):
    if pd.isna(genere_str):
        return []
    return [g.strip() for g in genere_str.split(',') if g.strip()]

def estrai_cast(cast_str):
    return [c.strip() for c in cast_str.split(',')]

def calcola_similarita(row, preferenze):
    generi = estrai_generi(row.genere)
    cast = estrai_cast(row.cast)
    regista = row.regista
    punteggio = 0
    punteggio += sum([preferenze['generi'].get(genere, 0) for genere in generi])
    punteggio += preferenze['registi'].get(regista, 0)
    punteggio += sum([preferenze['cast'].get(attore, 0) for attore in cast])
    return punteggio

MODEL_FILENAME = 'model/modello_raccomandazione.pkl'
model = joblib.load(MODEL_FILENAME)

@app.route('/recommend', methods=['POST'])
def recommend():
    api_key = request.headers.get('Authorization')
    if api_key != f'Bearer {app.config["API_KEY"]}':
        abort(401, description="Unauthorized")

    data = request.json

    # Stampo il payload ricevuto
    print("[DEBUG] Dati ricevuti (request.json):")
    print(data)

    film_prenotati = pd.DataFrame(data['film_prenotati'])
    print("\n[DEBUG] Film prenotati (DataFrame):")
    print(film_prenotati)

    generi_prenotati = film_prenotati['genere'].apply(estrai_generi).explode()
    registi_prenotati = film_prenotati['regista']
    cast_prenotati = film_prenotati['cast'].apply(estrai_cast).explode()

    contatore_generi = Counter(generi_prenotati)
    contatore_registi = Counter(registi_prenotati)
    contatore_cast = Counter(cast_prenotati)

    # Stampo i contatori
    print("\n[DEBUG] Contatore generi:")
    print(contatore_generi)
    print("[DEBUG] Contatore registi:")
    print(contatore_registi)
    print("[DEBUG] Contatore cast:")
    print(contatore_cast)

    preferenze = {
        'generi': contatore_generi,
        'registi': contatore_registi,
        'cast': contatore_cast
    }

    # Recupero dei film dal DB
    nuovi_film = Film.query.filter_by(is_proiettato=True).all()

    # Stampo i film recuperati (solo alcuni campi per leggibilità)
    print("\n[DEBUG] Film recuperati dal DB (is_proiettato=True):")
    for f in nuovi_film:
        print(f"id={f.id}, titolo={f.titolo}, genere={f.genere}, regista={f.regista}")

    # Creazione DataFrame per i film candidati
    nuovi_film_df = pd.DataFrame([{
        'id': film.id,
        'titolo': film.titolo,  # aggiunto anche 'titolo' per debug
        'genere': film.genere,
        'cast': film.cast,
        'regista': film.regista,
        'durata': film.durata
    } for film in nuovi_film])

    print("\n[DEBUG] DataFrame iniziale (nuovi_film_df):")
    print(nuovi_film_df)

    # Calcolo similarità
    nuovi_film_df['similarita'] = nuovi_film_df.apply(lambda row: calcola_similarita(row, preferenze), axis=1)

    # Predizione con il modello
    previsioni = model.predict(nuovi_film_df[['genere', 'cast', 'regista', 'durata']])
    nuovi_film_df['consigliato'] = previsioni
    probabilita = model.predict_proba(nuovi_film_df[['genere', 'cast', 'regista', 'durata']])[:, 1]
    nuovi_film_df['probabilita_consigliato'] = probabilita

    print("\n[DEBUG] Previsioni (model.predict):")
    print(previsioni)
    print("[DEBUG] Probabilità (model.predict_proba):")
    print(probabilita)

    # Normalizzazioni
    prob_min = nuovi_film_df['probabilita_consigliato'].min()
    prob_max = nuovi_film_df['probabilita_consigliato'].max()
    if prob_max != prob_min:
        nuovi_film_df['probabilita_normalizzata'] = (nuovi_film_df['probabilita_consigliato'] - prob_min) / (prob_max - prob_min)
    else:
        nuovi_film_df['probabilita_normalizzata'] = 0.0

    sim_min = nuovi_film_df['similarita'].min()
    sim_max = nuovi_film_df['similarita'].max()
    if sim_max != sim_min:
        nuovi_film_df['similarita_normalizzata'] = (nuovi_film_df['similarita'] - sim_min) / (sim_max - sim_min)
    else:
        nuovi_film_df['similarita_normalizzata'] = 0.0

    peso_prob = 0.3
    peso_sim = 0.7
    nuovi_film_df['punteggio_combinato'] = (
            peso_prob * nuovi_film_df['probabilita_normalizzata'] +
            peso_sim * nuovi_film_df['similarita_normalizzata']
    )

    print("\n[DEBUG] DataFrame dopo i calcoli di similarità e probabilità (nuovi_film_df):")
    print(nuovi_film_df[[
        'id', 'titolo', 'genere', 'cast', 'regista', 'similarita',
        'probabilita_consigliato', 'probabilita_normalizzata',
        'similarita_normalizzata', 'punteggio_combinato'
    ]])

    top_n = data.get('top_n', 3)
    film_consigliati_df = nuovi_film_df.sort_values(by='punteggio_combinato', ascending=False).head(top_n)
    consigliati = film_consigliati_df.to_dict(orient='records')

    print("\n[DEBUG] Film consigliati (film_consigliati_df):")
    print(film_consigliati_df)
    print("[DEBUG] Oggetto finale (consigliati) che verrà restituito in JSON:")
    print(consigliati)

    return jsonify(consigliati)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
