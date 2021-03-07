/*
Заполнить таблицу step_keyword следующим образом: 
если ключевое слово есть в названии шага, 
то включить в step_keyword строку с id шага и id ключевого слова. 
*/
INSERT INTO step_keyword
SELECT step_id, keyword_id
  FROM keyword, step
 WHERE step_name REGEXP CONCAT('\\b', keyword_name, '\\b')
 ORDER BY keyword_id;

SELECT * FROM step_keyword