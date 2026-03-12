import pandas as pd
import requests
import re
import time
import numpy as np
from sklearn.model_selection import train_test_split
from PIL import Image
from io import BytesIO
from colorthief import ColorThief
from textblob import TextBlob
import nltk
from nltk.corpus import stopwords
from collections import Counter
import re
import ast


def explorar_df(df):
    print(df.info())

    print('Primeras filas')
    print(df.head())

    print('Describe()')
    print(df.describe(include='all').T)

    print('Nulos')
    nulos = df.isnull().sum()
    print(nulos[nulos > 0] if nulos.any() else 'Notnnull')

    print('Duplicados')
    print(df.duplicated().sum())
    
    print('Tamaño')
    print(f"Filas: {df.shape[0]} | Columnas: {df.shape[1]}")

def limpiar_dataset(df):
    df_clean = df.copy()
    df_clean.columns = (df_clean.columns
                        .str.lower()
                        .str.replace(' ', '_')
                        .str.replace('.', '', regex=False))
    df_clean.duplicated().sum()
    df_clean = df_clean.drop_duplicates()
    df_clean = df_clean.dropna() 
    return df_clean

def categorico(df,col):
    """Realiza un análisis descriptivo de una columna categórica."""
    print(df[col].value_counts())
    print(df[col].unique())
    print(df[col].nunique())
    

def numerico(df,col):
    """Realiza un análisis descriptivo de una columna numérica."""
    print(df[col].describe())
    print(df[col].isnull().sum())
    print(df[col].nunique())
    

def filtrar_fila(df,col,lista):
    return df[df[col].isin(lista)]

def completar_nulos(df,col,valor):
    df[col] = df[col].fillna(valor)
    return df

def estadisticos(df):
    print(df.describe())
    print(df.select_dtypes(include=["number"]).describe())
    

def ver_nulos(df):
    df_con_nulos = df[df.isnull().any(axis=1)]
    display(df_con_nulos)


def ver_duplicados(df):
    df_duplicados = df[df.duplicated()]
    display(df_duplicados)
    return df_duplicados

def obtener_color_dominante(url):
    if pd.isna(url) or not isinstance(url, str):
        return None
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            img_file = BytesIO(response.content)
            color_thief = ColorThief(img_file)
            return color_thief.get_color(quality=20)
    except Exception as e:
        print(f"Error en link: {url} -> {e}")
        return None
    return None



def preparar_datos(df, target_col='target', test_size=0.2, random_state=0):
        X = df.drop(columns=[target_col])
        y = df[target_col]
        return train_test_split(X, y, test_size=test_size, random_state=random_state)


def clasificar_color(rgb_tupla, colores):
    color_v = np.array(rgb_tupla)
    mas_cercano = None
    distancia_minima = float('inf')
    
    for nombre, rgb_base in colores.items():
        base_v = np.array(rgb_base)
        distancia = np.linalg.norm(color_v - base_v)
        
        if distancia < distancia_minima:
            distancia_minima = distancia
            mas_cercano = nombre
            
    return mas_cercano


def subjectivity(text):
    return TextBlob(text).sentiment.subjectivity


def polarity(text):
    return TextBlob(text).sentiment.polarity


def top_words(series, stop_words, n=20):
    words_list = []
    for text in series:
        # esto es regex
        clean_text = re.sub(r'[^a-zA-Z\s]', '', text.lower())
        words = [w for w in clean_text.split() if w not in stop_words and len(w) > 3]
        words_list.extend(words)
    
    return Counter(words_list).most_common(n)

def tema(topic_id):
    if topic_id == -1:
        return "Desconocido"
    words = [word for word, weight in model.get_topic(topic_id)[:3]]
    return " / ".join(words)