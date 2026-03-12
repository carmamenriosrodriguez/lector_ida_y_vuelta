USE reading;

SELECT *
FROM books;

SELECT * 
FROM design; 

SELECT * 
FROM reviews;

/* 1era impresión */

-- ¿Qué color predomina en los libros?
SELECT 
color,
COUNT(isbn) as total_libros
FROM design
GROUP BY 
color
ORDER BY total_libros DESC;

-- ¿Qué color está mejor valorado? 
SELECT 
d.color, 
ROUND(AVG(r.`review/score`), 2) as nota, 
COUNT(r.isbn) AS total_libros
FROM design as d
JOIN reviews as r 
ON d.isbn = r.isbn
GROUP BY d.color
ORDER BY nota DESC; 

-- ¿Qué color por cada género? *** PREGUNTAR ALEJANDRO
WITH cada_color as 
(SELECT 
d.color,
b.genre, 
COUNT(r.isbn) AS total_libros
FROM design as d
JOIN reviews as r 
ON d.isbn = r.isbn
JOIN books as b 
ON d.isbn = b.isbn
GROUP BY b.genre, d.color
)
SELECT 
	* 
FROM (
	SELECT 
		color,
		genre,
		total_libros,
		row_number() OVER (PARTITION BY genre ORDER BY total_libros DESC) AS row_num
	FROM cada_color
) subq
WHERE row_num = 1; 



-- ¿Qué género está mejor valorado?
SELECT 
b.genre, 
ROUND(AVG(r.`review/score`), 2) as nota, 
COUNT(r.isbn) AS total_libros
FROM books as b
JOIN reviews as r 
ON b.isbn = r.isbn
GROUP BY b.genre
ORDER BY nota DESC; 


-- ¿Qué editoriales lideran la publicación? 
SELECT 
publisher,
COUNT(published_date) as conteo
FROM books
GROUP BY publisher
ORDER BY conteo DESC; 

-- ¿Cuál es el precio medio del libro? 
SELECT
ROUND(AVG(price), 2) as precio_medio,
genre
FROM books
GROUP BY genre
ORDER BY precio_medio DESC;

-- Editorial x precio 
SELECT 
publisher, 
ROUND(AVG(price), 2) as precio_medio
FROM books
GROUP BY publisher
ORDER BY precio_medio DESC; 

-- Sinopsis subjetiva = + caro el libro
SELECT 
    ROUND(book_subjectivity, 2) as nota_subjetividad, 
    ROUND(AVG(price), 2) as precio_medio, 
    COUNT(isbn) as conteo 
FROM books 
GROUP BY ROUND(book_subjectivity, 2) 
ORDER BY nota_subjetividad DESC 
LIMIT 1000;

-- ¿Cuándo se ha publicado más? 
SELECT 
    year_published, 
    COUNT(isbn) as total_libros
FROM books
GROUP BY year_published
ORDER BY total_libros DESC
LIMIT 20; 

-- ¿Cuánto ocupa la novedad? 
SELECT 
    FLOOR(year_published / 10) * 10 AS decada, 
    COUNT(isbn) as total_libros
FROM books
GROUP BY decada
ORDER BY total_libros DESC;

-- ¿A qué libros les ponen más nota: antiguos vs nuevos?
SELECT 
    CASE 
        WHEN b.year_published < 1990 THEN 'Antiguos (Pre-1990)'
        ELSE 'Nuevos (1990-Actualidad)'
    END AS epoca,
    SUM(r.ratings_count) AS total_votos,
    COUNT(r.ratings_count) AS cantidad_libros,
    ROUND(SUM(r.ratings_count)/COUNT(r.ratings_count),2) AS porcentaje
FROM books as b
JOIN reviews as r
ON b.isbn = r.isbn
GROUP BY epoca;


-- ¿En qué año se hicieron más ratings? 
SELECT 
    b.year_published, 
    SUM(r.ratings_count) AS total_ratings,
    COUNT(b.isbn) AS cantidad_libros
FROM books b
JOIN reviews as r
ON b.isbn = r.isbn
GROUP BY year_published
ORDER BY total_ratings DESC
LIMIT 10;

/* 2. La expectativa */
-- Subjetividad media de sinopsis por género
SELECT 
    genre,
    ROUND(AVG(book_subjectivity),2)  AS subj_sinopsis
FROM books
GROUP BY genre
ORDER BY subj_sinopsis DESC; 

-- Subjetividad media de sinopsis por año 
SELECT 
    year_published,
    ROUND(AVG(book_subjectivity),2)  AS subj_sinopsis
FROM books
GROUP BY year_published
ORDER BY subj_sinopsis DESC; 

-- Subjetividad media de reviews por género
SELECT 
    b.genre,
    ROUND(AVG(r.`review/subjectivity`),2)  AS subj_review
FROM books b
JOIN reviews r
    ON b.isbn = r.isbn
GROUP BY genre
ORDER BY subj_review DESC; 

-- Subjetividad media de reviews por año
SELECT 
    b.year_published,
    ROUND(AVG(r.`review/subjectivity`),2)  AS subj_review
FROM books b
JOIN reviews r
    ON b.isbn = r.isbn
GROUP BY b.year_published
ORDER BY subj_review DESC; 

-- Polaridad media de sinopsis por género
SELECT 
    genre,
    ROUND(AVG(book_polarity),2)  AS pol_sinopsis
FROM books
GROUP BY genre
ORDER BY pol_sinopsis DESC; 

-- Polaridad media de sinopsis por año 
SELECT 
    year_published,
    ROUND(AVG(book_polarity),2)  AS pol_sinopsis
FROM books
GROUP BY year_published
ORDER BY pol_sinopsis DESC; 

-- Polaridad media de reviews por género
SELECT 
    b.genre,
    ROUND(AVG(r.`review/polarity`),2)  AS pol_review
FROM books b
JOIN reviews r
    ON b.isbn = r.isbn
GROUP BY genre
ORDER BY pol_review DESC; 

-- Polaridad media de reviews por año
SELECT 
    b.year_published,
    ROUND(AVG(r.`review/polarity`),2)  AS pol_review
FROM books b
JOIN reviews r
    ON b.isbn = r.isbn
GROUP BY b.year_published
ORDER BY pol_review DESC; 




/* 3. La experiencia */
-- DIFERENCIAS: Diferencia entre la subjetividad de las notas y la subjetividad de las reviews
-- x género
SELECT 
    b.genre,
    ROUND(AVG(b.book_subjectivity),2)  AS subj_sinopsis,
    ROUND(AVG(r.`review/subjectivity`),2)  AS subj_review, 
    ROUND(AVG(b.book_subjectivity) - AVG(r.`review/subjectivity`),2) AS diferencia
FROM books b
JOIN reviews AS r
    ON b.isbn = r.isbn
GROUP BY b.genre 
ORDER BY diferencia DESC;
-- x color
SELECT 
    d.color,
    ROUND(AVG(b.book_subjectivity),2)  AS subj_sinopsis,
    ROUND(AVG(r.`review/subjectivity`),2)  AS subj_review, 
    ROUND(AVG(b.book_subjectivity) - AVG(r.`review/subjectivity`),2) AS diferencia
FROM design d
JOIN books b
	ON d.isbn = b.isbn
JOIN reviews r
    ON d.isbn = r.isbn
GROUP BY d.color
ORDER BY diferencia DESC;
-- x precio
SELECT 
	b.genre,
    ROUND(AVG(b.price), 2) AS precio_medio,
    ROUND(AVG(book_subjectivity),2)  AS subj_sinopsis,
    ROUND(AVG(r.`review/subjectivity`),2)  AS subj_review, 
    ROUND(AVG(b.book_subjectivity) - AVG(r.`review/subjectivity`), 2) AS diferencia
FROM books b
JOIN reviews r
    ON b.isbn = r.isbn
GROUP BY b.genre
ORDER BY diferencia DESC;

-- Diferencia entre la polaridad de las notas y la polaridad de las reviews
-- x género
SELECT 
    b.genre,
    ROUND(AVG(b.book_polarity),2)  AS pol_sinopsis,
    ROUND(AVG(r.`review/polarity`),2)  AS pol_review, 
    ROUND(AVG(b.book_polarity) - AVG(r.`review/polarity`),2) AS diferencia
FROM books b
JOIN reviews AS r
    ON b.isbn = r.isbn
GROUP BY b.genre 
ORDER BY diferencia DESC;

-- x color
SELECT 
    d.color,
    ROUND(AVG(b.book_polarity),2)  AS pol_sinopsis,
    ROUND(AVG(r.`review/polarity`),2)  AS pol_review, 
    ROUND(AVG(b.book_polarity) - AVG(r.`review/polarity`),2) AS diferencia
FROM design d
JOIN books b
	ON d.isbn = b.isbn
JOIN reviews r
    ON d.isbn = r.isbn
GROUP BY d.color
ORDER BY diferencia DESC;
-- x precio 
SELECT 
    ROUND(AVG(b.price), 2) AS precio_medio,
    ROUND(AVG(b.book_polarity), 2) AS pol_sinopsis,
    ROUND(AVG(r.`review/polarity`), 2) AS pol_review, 
    ROUND(AVG(b.book_polarity) - AVG(r.`review/polarity`), 2) AS diferencia
FROM books b
JOIN reviews r
    ON b.isbn = r.isbn
GROUP BY b.isbn
ORDER BY diferencia DESC;

/* 4. El intercambio */ 
-- ROI de Satisfacción por rango de precio y género
SELECT 
    b.genre,
    -- Creamos rangos de precio para comparar grupos
    CASE 
        WHEN b.price < 10 THEN 'Bajo (<10)'
        WHEN b.price BETWEEN 10 AND 30 THEN 'Medio (10-30)'
        ELSE 'Alto (>30)' 
    END AS rango_precio,
    COUNT(r.isbn) AS total_reviews,
    ROUND(AVG(b.price), 2) AS precio_promedio,
    -- KPI: ¿Qué tan positiva es la experiencia tras pagar ese precio?
    ROUND(AVG(r.`review/score`), 2) AS score_promedio,
    ROUND(AVG(r.`review/polarity`), 3) AS polaridad_promedio,
    -- Metrica de contraste: Relación Score / Precio
    ROUND(AVG(r.`review/score`) / NULLIF(AVG(b.price), 0), 3) AS roi_satisfaccion
FROM 
    books b
JOIN 
    reviews r ON b.isbn = r.isbn
GROUP BY 
    b.genre, rango_precio
ORDER BY 
    b.genre, precio_promedio ASC;
    
--  ¿Tienen los libros más caros (price) una review/polarity más baja? 
SELECT 
ROUND(AVG (b.price), 2) as precio_medio, 
ROUND(AVG(r.`review/polarity`), 3) AS polaridad_promedio
FROM books b 
JOIN reviews r ON b.isbn = r.isbn
WHERE b.price > (SELECT AVG(price) FROM books);
-- Tienen la misma polaridad los caros que los buenos. 

-- Índice de infuencia real (¿Las reviews más útiles son positivas o negativas? 
SELECT 
    b.genre,
    ROUND(AVG(r.`review/score`), 2) AS score_promedio_total,
    -- Calculamos la media ponderada: (Suma de score * helpfulness) / (Suma total de helpfulness)
    ROUND(SUM(r.`review/score` * r.`review/helpfulness`) / SUM(r.`review/helpfulness`), 2) AS score_influenciado_utilidad,
    -- Calculamos la diferencia entre la media ponderada y la media simple
    ROUND(
        (SUM(r.`review/score` * r.`review/helpfulness`) / SUM(r.`review/helpfulness`)) - AVG(r.`review/score`), 
        2
    ) AS diff_influencia
FROM books b
JOIN reviews r ON b.isbn = r.isbn
WHERE r.`review/helpfulness` > 0
GROUP BY b.genre
ORDER BY diff_influencia DESC;

-- ¿Las reviews que coinciden con la polaridad de la sinopsis son consideradas más útiles?
SELECT 
    CASE 
        WHEN ABS(b.book_polarity - r.`review/polarity`) < 0.2 THEN 'Expectativa cumplida'
        WHEN (b.book_polarity - r.`review/polarity`) > 0.5 THEN 'Decepción'
        ELSE 'Sorpresa'
    END AS tipo_experiencia,
    COUNT(r.isbn) AS total_reviews,
    ROUND(AVG(r.`review/helpfulness`), 2) AS utilidad_media
FROM books b
JOIN reviews r ON b.isbn = r.isbn
GROUP BY tipo_experiencia
ORDER BY utilidad_media DESC;

-- ¿Estamos dispuestos a pagar más por libros donde las reviews útiles dicen que la experiencia es buena?
SELECT 
    b.publisher,
    ROUND(AVG(b.price), 2) AS precio_medio,
    -- Correlación entre utilidad de review positiva y el precio
    ROUND(AVG(CASE WHEN r.`review/score` >= 4 THEN r.`review/helpfulness` ELSE 0 END), 2) AS valor_ayuda_positiva,
    ROUND(AVG(CASE WHEN r.`review/score` <= 2 THEN r.`review/helpfulness`ELSE 0 END), 2) AS valor_ayuda_negativa
FROM books b
JOIN reviews r ON b.isbn = r.isbn
GROUP BY b.publisher
HAVING COUNT(r.isbn) > 10
ORDER BY precio_medio DESC;