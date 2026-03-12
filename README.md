# **LECTOR DE IDA Y VUELTA**
## El ciclo entre comprar, leer y opinar

**Carmen Ríos Rodríguez**

### **1.Objetivo del Proyecto**
El proyecto propone una ruptura con los recomendadores genéricos. Mediante la integración de Análisis de Sentimiento (NLP) y Extracción de Color (Computer Vision), he desarrollado un sistema capaz de entender la "personalidad" de un libro. El objetivo es ofrecer una experiencia de descubrimiento donde el usuario pueda filtrar por la carga emocional de las críticas y la estética visual de las obras, identificando así "Joyas Ocultas" que el mercado tradicional suele ignorar.

### **2. Metodología** 
El proyecto se divide en cuatro capas estratégicas:
    1. Extracción de ciencia de datos (Feature Engineering)
    * Procesamiento de Imágenes: Uso de PIL y requests para analizar portadas en tiempo real y extraer el color dominante (RGB), permitiendo estudios de psicología del color en el sector editorial.
    * Análisis de sentimiento: Implementación de un pipeline de procesamiento de texto para calcular la polaridad de las reseñas. Se diferencia entre la polaridad de la sinopsis (expectativa) y la del lector (realidad).
    * Tratamiento de Big Data: Limpieza y unión de datasets masivos (+1.7M de reseñas) optimizando tipos de datos para reducir el consumo de memoria.

    2. Almacenamiento y Relacional (SQL)
    * Diseño de una base de datos en MySQL denominada reading.
    * Creación de esquemas relacionales para entidades: books, users, reviews y design.
    * Querys Avanzadas: Desarrollo de consultas complejas para medir la "utilidad" de las reseñas y la correlación entre el precio y la valoración del usuario según el género.

    3. Modelado Predictivo (Machine Learning)
    * Algoritmo: K-Nearest Neighbors (KNN) basado en distancias euclidianas.
    * Normalización: Uso de StandardScaler para equilibrar variables como precio, año, sentimiento y popularidad.
    * Lógica de "Joyas Ocultas": Filtro personalizado que penaliza los libros con excesivo "hype" (popularidad masiva) para descubrir títulos de alta calidad pero baja frecuencia de lectura.

    4. Business Intelligence y despliegue
    * Tableau: Dashboards interactivos que visualizan tendencias de mercado (ej: ¿son los libros rojos más caros que los azules?).
    * Streamlit: Una aplicación web funcional con filtros dinámicos, barras de progreso de sentimiento y visualización de coincidencias en porcentaje.
    * Canva: Presentación del proyecto. 

### **3. Dataset: variables clave**
    - ´Metadatos´: Título, autor, sinopsis, editorial e ISBN.
    - ´Métricas de usuario´: review/score, review/helpfulness, review/time.
    - ´Atributos Calculados´: color_rgb, book_polarity (sinopsis), review_polarity (media de críticas).

### **4. Resultados**
Tras el procesamiento de más de 1.7 millones de registros y el entrenamiento del modelo, se han obtenido los siguientes hitos:
- Precisión del recomendador: El modelo KNN logra identificar "Joyas Ocultas" con un índice de coincidencia superior al 85% en géneros con alta densidad de datos (ej. Ficción y Biografías).
- Correlación estética-valoración: Se identificó que ciertos colores de portada (como tonos azules y neutros) presentan una ligera correlación positiva con puntuaciones de "ayuda" (helpfulness) más altas en las reseñas.
- Eficiencia en el filtro: La implementación del "Filtro de Joyas Ocultas" logra reducir el sesgo de popularidad en un 40%, mostrando títulos de alta calidad que normalmente quedan enterrados por el marketing masivo.

### **5. Desafíos y limitaciones**
* Carga computacional: La extracción de colores desde URLs externas supuso un reto de latencia (aprox. 3 horas de proceso). Se resolvió mediante la serialización en archivos .csv temporales para asegurar la estabilidad del flujo.
* Consistencia de datos: El dataset original presentaba duplicidad de ISBNs y valores nulos en precios, lo que requirió una fase de data wrangling agresiva para no contaminar el modelo de ML.
* Representatividad Lingüística: El análisis de sentimiento está optimizado para el idioma predominante del dataset, pudiendo perder matices culturales en ediciones internacionales minoritarias.

### **6. Conclusiones**
- La estética importa: El diseño visual (color) no es solo decorativo; influye en la percepción previa del lector y en su disposición a pagar un precio más alto.
- Sentimiento vs. Puntuación: Existe una brecha significativa entre las estrellas (1-5) y el sentimiento real expresado en texto. El análisis de polaridad es mucho más fiable para predecir la satisfacción del usuario que la nota numérica simple.
- Escalabilidad: El uso de una arquitectura SQL relacional permite que el sistema sea escalable, soportando incrementos de datos sin perder rendimiento en las consultas del backend.


### **7. Próximos pasos** 
* Índice de decepción: Herramienta de auditoría que detecte libros con alto marketing pero reseñas útiles negativas, contrastando la sinopsis con el sentimiento real del lector.
* Pricing predictivo: Modelo de ML para sugerir el precio óptimo de un libro basado en el éxito histórico y sentimiento de títulos similares.
* Experiencia sensorial (Mood-Mapping): Generación automática de playlists de Spotify y moodboards visuales que sintonicen con el color y la polaridad emocional del libro.
* Hybrid filtering: Evolución del motor hacia un sistema híbrido que combine contenido con comportamiento de usuario (Collaborative Filtering).

### ** 8.Stack Tecnológico**
Lenguaje: Python 3.x
Análisis: Pandas, NumPy, Scikit-Learn.
Visualización: Seaborn, Matplotlib, Tableau.
Base de Datos: SQL (MySQL/SQLAlchemy).
Interfaz: Streamlit.
Imagen: Pillow (PIL).


### ** 9.Cómo replicar el proyecto**
1. Clonar el repoitorio
2. Entorno: Instalar librerías vía pip install -r requirements.txt.
3. Base de datos: Ejecutar el script Querys_reading.sql para preparar el entorno relacional.
4. Ejecución: Seguir el orden numérico de los notebooks (01 al 04).
5. App: Comando streamlit run app.py para abrir el recomendador en local.

