import pandas as pd
from sklearn.model_selection import train_test_split
from catboost import CatBoostClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

file_path = 'C:/Users/emiio/IdeaProjects/cIAk/dataset_imdb/dataset_ottimizzato.csv'
df = pd.read_csv(file_path)
df['consigliato'] = df['rating'].apply(lambda x: 1 if x >= 7 else 0)
X = df[['genere', 'cast', 'regista', 'durata']]
y = df['consigliato']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
model = CatBoostClassifier(iterations=200, depth=6, learning_rate=0.1,
                           cat_features=['genere', 'cast', 'regista'], verbose=False)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
print("=== CatBoost Performance ===")
print("Accuracy:", accuracy_score(y_test, y_pred))
print("Classification Report:\n", classification_report(y_test, y_pred))
print("Confusion Matrix:\n", confusion_matrix(y_test, y_pred))


