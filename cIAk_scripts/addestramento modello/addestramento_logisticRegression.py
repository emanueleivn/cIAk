import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.linear_model import LogisticRegression
import joblib

#def estrai_generi(genere_str):
#  return [g.strip() for g in genere_str.split(',')]

#def estrai_cast(cast_str):
#   return [c.strip() for c in cast_str.split(',')]

def main():
    file_path = 'C:/Users/emiio/IdeaProjects/cIAk/dataset_imdb/dataset_ottimizzato.csv'
    df = pd.read_csv(file_path)
    df['consigliato'] = df['rating'].apply(lambda x: 1 if x >= 7 else 0)

    x1 = df[['genere', 'cast', 'regista', 'durata']]
    y = df['consigliato']
    x1_train, x1_test, y_train, y_test = train_test_split(x1, y, test_size=0.2, random_state=42, stratify=y)
    categorical_features = ['genere', 'cast', 'regista']
    numeric_features = ['durata']
    preprocessor = ColumnTransformer([
        ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features),
        ('num', StandardScaler(), numeric_features)
    ])

    model = Pipeline([
        ('preprocessor', preprocessor),
        ('classifier', LogisticRegression(max_iter=1000, class_weight='balanced'))
    ])

    model.fit(x1_train, y_train)
    model_filename = 'modello_raccomandazione.pkl'
    joblib.dump(model, model_filename)

if __name__ == "__main__":
    main()
