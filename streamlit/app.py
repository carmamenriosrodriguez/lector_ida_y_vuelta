import streamlit as st
import backend
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# (CSS)
st.markdown("""
    <style>
    /* 2. TEXTOS GRANDES Y BLANCOS */
    [data-testid="stWidgetLabel"] p {
        font-size: 20px !important;
        font-weight: bold !important;
        color: #FFFFFF !important;
    }

    /* Texto de los valores y opciones */
    div[data-testid="stThumbValue"], 
    .stSelectbox div[data-baseweb="select"],
    [data-testid="stRadio"] label p {
        font-size: 17px !important;
        color: #FFFFFF !important;
    }
    
    """, unsafe_allow_html=True)


st.set_page_config(page_title="Recomendador de libros", layout="wide")


@st.cache_resource
def iniciar():
    return backend.aplicar_modelo()

df_ml, model_knn, features_columns, scaler, lista_generos, lista_editoriales = iniciar()

titulo, imagen = st.columns([5, 1])

with titulo: 

    st.title("✨¿Buscas libro nuevo?✨")
    st.markdown("Ajusta los parámetros para encontrar tu próxima lectura.")

    with st.form("buscador_libros"):
        f1, f2 = st.columns(2)

        with f1:
            gen_elegido = st.selectbox("¿Qué género buscas?", options=lista_generos)
            pub_elegida = st.selectbox("¿Alguna editorial preferida?", options=["Cualquiera"] + lista_editoriales)
            yr = st.slider("Año de publicación", 1900, 2026, 2020)


        with f2:
            pop_choice = st.radio(
                "¿Qué prefieres descubrir?",
                options=["Bestsellers", "Joyas ocultas"],
                help="Bestsellers: Muchos ratings | Joyas: Pocos ratings pero calidad."
            )
            polaridad_target = st.slider(
                "¿Cuál es tu mood?",
                -1.0, 1.0, 0.0, 0.1,
                help="-1: Triste/Nostálgico, 1: Feliz/Motivado."
            )
            subjetividad_target = st.slider(
                "¿Qué quieres creer?",
                0.0, 1.0, 0.5,
                help="0: Hechos objetivos, 1: Opiniones 100%"
            )
                
        btn = st.form_submit_button("Voy a tener suerte 🔮")

with imagen: 
    st.write("##") 
    st.image("https://i.pinimg.com/736x/06/be/44/06be44422938f4c79c21ba56ce38f066.jpg", width=400)
    st.caption("`Los miércoles usamos el recomendador de libros´ - Regina 😉")


# Lógica de recomendación
if btn:
    user_query = pd.DataFrame(0.0, index=[0], columns=features_columns)
    
    # Asignar valores basados en los sliders
    user_query['year_published'] = yr
    user_query['book_polarity'] = polaridad_target
    user_query['book_subjectivity'] = subjetividad_target
    user_query['review/polarity'] = polaridad_target
    user_query['review/subjectivity'] = subjetividad_target
    
    if pop_choice == "Bestsellers":
        user_query['ratings_count'] = df_ml['ratings_count'].max()
    else:
        user_query['ratings_count'] = df_ml['ratings_count'].min()

    col_genero = f'genre_{gen_elegido}'
    if col_genero in features_columns:
        user_query[col_genero] = 1.0
    else:
        st.warning(f"El género '{gen_elegido}' no se encontró. Mostrando resultados generales.")

    user_query_scaled = scaler.transform(user_query)

    # Buscar los 5 más cercanos
    distancias, indices = model_knn.kneighbors(user_query_scaled, n_neighbors=5)

    
    st.divider()
    st.header(f"📚 Recomendaciones de {gen_elegido}")
        
    cols_res = st.columns(5)
    for i, idx in enumerate(indices[0]):
        libro = df_ml.iloc[idx]
        with cols_res[i]:
            # El match se calcula como (1 - distancia de coseno)
            match_percent = round((1 - distancias[0][i]) * 100, 1)
            st.metric(label="Match 💘 ", value=f"{match_percent}%")
            
            st.markdown(f"### {libro['title']}")
            st.caption(f"📅 {int(libro['year_published'])} | 🏛️ {libro['publisher']}")
            
            with st.expander("Ver detalles 🔎"):
                st.write(f"**Ratings:** {int(libro['ratings_count']):,}")
                
                st.markdown("<h4 style='margin-bottom: 0px;'>Sentimiento de los lectores:</h4>", unsafe_allow_html=True)
                
                # Normalización: transforma el rango [-1, 1] a [0, 1] para la barra
                sentimiento_normalizado = (libro['review/polarity'] + 1) / 2
                st.progress(sentimiento_normalizado)
                
                estilo_texto = "font-size: 1.1rem; font-weight: 500;"

                if libro['review/polarity'] > 0.2:
                    texto = f"<p style='{estilo_texto}'>😊 Críticas mayoritariamente positivas</p>"
                elif libro['review/polarity'] < -0.2:
                    texto = f"<p style='{estilo_texto}'>🎭 Críticas con tono dramático o triste</p>"
                else:
                    texto = f"<p style='{estilo_texto}'>😐 Críticas con tono neutral</p>"
                
                st.markdown(texto, unsafe_allow_html=True)

st.divider()
st.markdown("💡 *Nota: Los resultados se basan en la similitud matemática entre tus preferencias y el promedio de las reseñas de cada libro.*")

if st.button("🔄 Reiniciar parámetros"):
    st.rerun()

