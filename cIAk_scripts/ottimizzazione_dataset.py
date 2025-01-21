import pandas as pd

file_path = '../../../Downloads/imdb-movies-dataset.csv'
df = pd.read_csv(file_path)
selected_columns = ['Title', 'Duration (min)', 'Genre', 'Rating', 'Director',
                    'Cast', 'Certificate']
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
df_selected['film_id'] = range(1, len(df_selected) + 1)
output_file_path = 'dataset_ottimizzato.csv'
df_selected.to_csv(output_file_path, index=False)
