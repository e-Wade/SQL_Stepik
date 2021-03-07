/*
Реализовать поиск по ключевым словам. Вывести шаги, 
с которыми связаны ключевые слова MIN и AVG одновременно. 
Для шагов указать номер модуля, номер урока, номер шага через точку, 
после номера шага перед заголовком - пробел. Столбец назвать Шаг. 
Информацию отсортировать по возрастанию сначала по порядковому номеру модуля,
 затем по порядковым номерам урока и шага соответственно. 
*/

SELECT CONCAT(module_id, '.', 
              lesson_position, '.', 
              step_position, ' ', 
              step_name) AS Шаг
  FROM step AS s
       JOIN lesson AS l USING(lesson_id)
       JOIN module AS m USING(module_id)
 WHERE step_id = 
       (
        SELECT step_id
          FROM step_keyword
               JOIN keyword USING(keyword_id)
         WHERE keyword_name IN ('AVG', 'MAX')
         GROUP BY step_id
        HAVING COUNT(keyword_name) = 2
       );