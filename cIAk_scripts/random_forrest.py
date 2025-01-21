import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

file_path = 'C:/Users/emiio/IdeaProjects/cIAk/dataset_imdb/dataset_ottimizzato.csv'
df = pd.read_csv(file_path)
df['consigliato'] = df['rating'].apply(lambda x: 1 if x >= 7 else 0)
X = df[['genere', 'cast', 'regista', 'durata']]
y = df['consigliato']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
preprocessor = ColumnTransformer([
    ('cat', OneHotEncoder(handle_unknown='ignore'), ['genere', 'cast', 'regista']),
    ('num', StandardScaler(), ['durata'])
])
model = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier(n_estimators=200, random_state=42))
])
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
print("=== Random Forest Performance ===")
print("Accuracy:", accuracy_score(y_test, y_pred))
print("Classification Report:\n", classification_report(y_test, y_pred))
print("Confusion Matrix:\n", confusion_matrix(y_test, y_pred))

