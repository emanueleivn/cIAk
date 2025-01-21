import pandas as pd

file_path = '../../../Downloads/imdb-movies-dataset.csv'
df = pd.read_csv(file_path)
selected_columns = ['Title', 'Duration (min)', 'Genre', 'Rating',
                    'Director','Cast', 'Certificate']
df_selected = df[selected_columns]
df_selected.rename(columns={
    'Title': 'titolo',
    'Duration (min)': 'durata',
    'Genre': 'genere',
    'Rating': 'rating',
    'Director': 'regista',
    'Cast': 'cast',
    'Certificate': 'classificazione'
}, inplace=True)

df_selected.drop_duplicates(inplace=True)
df_selected.dropna(inplace=True)
classification_mapping = {
    'G': 'T',
    'PG': 'T',
    'PG-13': 'VM14',
    'R': 'VM18',
    'NC-17': 'VM18'
}
df_selected['classificazione'] = df_selected['classificazione'].map(classification_mapping)
genre_mapping = {
    'Action': 'Azione','Adventure': 'Avventura',
    'Animation': 'Animazione','Biography': 'Biografia',
    'Comedy': 'Commedia','Crime': 'Crime',
    'Documentary': 'Documentario','Drama': 'Dramma',
    'Family': 'Per famiglie','Fantasy': 'Fantasy',
    'History': 'Storico','Horror': 'Horror',
    'Music': 'Musica','Musical': 'Musical',
    'Mystery': 'Mistero','Romance': 'Romantico',
    'Sci-Fi': 'Fantascienza','Sport': 'Sport',
    'Thriller': 'Thriller','War': 'Guerra',
    'Western': 'Western'
}
def convert_genre(genre_list):
    genres = genre_list.split(', ')
    genres_italian = [genre_mapping.get(g, g) for g in genres]
    return ', '.join(genres_italian)
df_selected['genere'] = df_selected['genere'].apply(convert_genre)
df_selected['film_id'] = range(1, len(df_selected) + 1)
output_file_path = '../dataset_imdb/dataset_ottimizzato.csv'
df_selected.to_csv(output_file_path, index=False)
