/*
Посчитать среднее время, за которое пользователи проходят урок по следующему алгоритму:

- для каждого пользователя вычислить время прохождения шага как сумму времени, 
потраченного на каждую попытку (время попытки - это разница между временем отправки задания и временем начала попытки),
при этом попытки, которые длились больше 4 часов не учитывать, так как пользователь мог просто оставить задание открытым в браузере,
а вернуться к нему на следующий день;
- для каждого студента посчитать общее время, которое он затратил на каждый урок;
- вычислить среднее время выполнения урока в часах, результат округлить до 2-х знаков после запятой;
- вывести информацию по возрастанию времени, пронумеровав строки, для каждого урока указать номер модуля и его позицию в нем.
Столбцы результата назвать Номер, Урок, Среднее_время.
*/
  WITH step_time
    AS (
        SELECT student_id, lesson_id, SUM(submission_time - attempt_time) AS sum_step
          FROM step_student
               JOIN step USING(step_id)
         WHERE submission_time - attempt_time < 4 * 3600
         GROUP BY student_id, lesson_id
         ORDER BY student_id
        ), 
       lesson_time
    AS (
        SELECT student_id, 
               CONCAT(module_id, '.', lesson_position, ' ', lesson_name) AS lesson_name,
               SUM(sum_step) AS sum_lesson
          FROM step_time
               JOIN lesson USING(lesson_id)
         GROUP BY student_id, 2
       ),
       lesson_avg
    AS (       
        SELECT lesson_name AS Урок, 
               ROUND(AVG(sum_lesson) / 3600, 2) AS Среднее_время
          FROM lesson_time
         GROUP BY lesson_name
       )
SELECT ROW_NUMBER() OVER (ORDER BY Среднее_время) AS Номер,
       Урок, Среднее_время
  FROM lesson_avg