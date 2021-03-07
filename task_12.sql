/*
Выделить группы обучающихся по способу прохождения шагов:

- I группа - это те пользователи, которые после верной попытки решения шага делают неверную 
(скорее всего для того, чтобы поэкспериментировать или проверить, как работают примеры);
- II группа - это те пользователи, которые делают больше одной верной попытки для одного шага 
(возможно, улучшают свое решение или пробуют другой вариант);
- III группа - это те пользователи, которые не смогли решить задание какого-то шага 
(у них все попытки по этому шагу - неверные), оставили этот шаг и перешли к следующим.

Вывести группу (I, II, III), имя пользователя, количество шагов, которые пользователь выполнил по соответствующему способу. Столбцы назвать Группа, Студент, Количество_шагов. Отсортировать информацию по возрастанию номеров групп, потом по убыванию количества шагов и, наконец, по имени студента в алфавитном порядке.
*/
-- подготовка данных для первой группы

  WITH first_group_table
    AS (
        SELECT student_name,
               step_id,
               result,
               LAG(result) OVER (PARTITION BY student_name, step_id ORDER BY submission_time) as lag_
          FROM student
               JOIN step_student USING(student_id)
         ORDER BY student_name, step_id, submission_time  
        ),
		
-- подготовка данных для второй группы

		second_group_table
	AS (
		SELECT student_name AS Студент,
			   COUNT(step_id) AS num_correct
		  FROM student
			   JOIN step_student USING(student_id)
		 WHERE result = 'correct'
		 GROUP BY student_name, step_id
		HAVING num_correct > 1
		 ORDER BY num_correct DESC, Студент
		),
		
-- подготовка данных для второй группы

		third_group_table
    AS (
        SELECT student_name AS Студент,
               step_id,
               SUM(CASE
                       WHEN result = 'wrong' THEN 1
                       ELSE 0
                    END
                   ) AS sum_wrong,
               COUNT(step_id) AS all_attempts
                   
		  FROM student
			   JOIN step_student USING(student_id)
         GROUP BY student_name, step_id
        )
SELECT 'I' AS Группа,
       student_name AS Студент,
       COUNT(step_id) AS Количество_шагов
  FROM first_group_table
 WHERE (result, lag_) = ('wrong','correct')
 GROUP BY student_name
 
 UNION

SELECT 'II' AS Группа,
       Студент,
       COUNT(num_correct) AS Количество_шагов
  FROM second_group_table
 GROUP BY Студент
 
 UNION

SELECT 'III' AS Группа,
       Студент,
       COUNT(step_id) AS Количество_шагов
  FROM third_group_table
 WHERE sum_wrong = all_attempts
 GROUP BY Студент
 ORDER BY Группа, Количество_шагов DESC, Студент




