/*
Вычислить прогресс пользователей по курсу. Прогресс вычисляется как отношение 
верно пройденных шагов к общему количеству шагов в процентах, округленное до целого. 
В нашей базе данные о решениях занесены не для всех шагов, поэтому общее количество
шагов определить как количество различных шагов в таблице step_student.

Тем пользователям, которые прошли все шаги (прогресс = 100%) выдать "Сертификат с отличием". 
Тем, у кого прогресс больше или равен 80% -  "Сертификат". 
Для остальных записей в столбце Результат задать пустую строку ("").

Информацию отсортировать по убыванию прогресса,
затем по имени пользователя в алфавитном порядке.
*/
  WITH get_count_correct(st_n_c, count_correct)
    AS (
        SELECT student_name, COUNT(DISTINCT step_id)
          FROM student
               JOIN step_student USING(student_id)
         WHERE result = 'correct'
         GROUP BY student_name
         ORDER BY 2 DESC
       ),
       get_max_question(max_question)
   AS  (
        SELECT COUNT(DISTINCT step_id)
          FROM step_student
       )   
SELECT st_n_c AS Студент, 
       ROUND(count_correct / max_question * 100) AS Прогресс,
  CASE
       WHEN count_correct / max_question * 100 = 100 THEN 'Сертификат с отличием'
       WHEN count_correct / max_question * 100 >= 80 THEN 'Сертификат'
       ELSE ''
   END AS Результат
  FROM get_count_correct, get_max_question
 ORDER BY Прогресс DESC, Студент



