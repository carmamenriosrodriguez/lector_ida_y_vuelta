import pandas as pd
from sklearn.neighbors import NearestNeighbors
from sklearn.preprocessing import MinMaxScaler

def aplicar_modelo():
    
    df = pd.read_csv('final.csv')
    
    df_ml = df.groupby('title').agg({
        'book_subjectivity': 'first',
        'book_polarity': 'first',
        'year_published': 'first',
        'publisher': 'first',
        'genre': 'first',
        'review/subjectivity': 'mean', 
        'review/polarity': 'mean',
        'ratings_count': 'max'
    }).reset_index()

    lista_generos = sorted(df_ml['genre'].unique().tolist())
    lista_editoriales = sorted(df_ml['publisher'].unique().tolist())

    df_ml = pd.get_dummies(df_ml, columns=['genre'], prefix='genre')
    
    features_columns = [
        'book_subjectivity', 'book_polarity', 'year_published', 
        'review/subjectivity', 'review/polarity', 'ratings_count'
    ]
    features_columns.extend([col for col in df_ml.columns if col.startswith('genre_')])

    scaler = MinMaxScaler()
    df_scaled = scaler.fit_transform(df_ml[features_columns])
    
    model_knn = NearestNeighbors(n_neighbors=10, metric='cosine')
    model_knn.fit(df_scaled)
    
    return df_ml, model_knn, features_columns, scaler, lista_generos, lista_editoriales 