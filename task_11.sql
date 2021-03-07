/*
Для студента с именем student_59 вывести следующую информацию по всем его попыткам:

- информация о шаге: номер модуля, символ '.', позиция урока в модуле, символ '.', позиция шага в модуле;
- порядковый номер попытки для каждого шага - определяется по возрастанию времени отправки попытки;
- результат попытки;
- время попытки (преобразованное к формату времени) - определяется как разность между временем отправки 
попытки и времени ее начала, в случае если попытка длилась более 1 часа, то время попытки заменить 
на среднее время всех попыток пользователя по всем шагам без учета тех, которые длились больше 1 часа;
- относительное время попытки  - определяется как отношение времени попытки (с учетом замены времени попытки)
к суммарному времени всех попыток  шага, округленное до двух знаков после запятой.

Столбцы назвать  Студент,  Шаг, Номер_попытки, Результат, Время_попытки и Относительное_время. 
Информацию отсортировать сначала по возрастанию id шага, а затем по возрастанию номера попытки (определяется по времени отправки попытки).

Важно. Все вычисления производить в секундах, округлять и переводить во временной формат только для вывода результата
*/
-- среднее время всех попыток
   SET @avg_time = 
       (
        SELECT ROUND(AVG(submission_time - attempt_time), 0) AS avg_time
          FROM student
               JOIN step_student USING(student_id)
         WHERE student_name = 'student_59' 
           AND submission_time - attempt_time < 3600
         GROUP BY student_name, student_id
       );
-- таблица для student_59 с колвом попыток и временем по каждому шагу
  WITH temp_table_1
    AS 
       (
        SELECT student_name,
               step_id,
               CONCAT(module_id, '.', lesson_position, '.', step_position) AS Шаг,
               DENSE_RANK() OVER (PARTITION BY step_id ORDER BY submission_time) AS Номер,
               result,
               submission_time - attempt_time AS time_attempt
          FROM student
               JOIN step_student USING(student_id)
               JOIN step USING(step_id)
               JOIN lesson USING(lesson_id)
         WHERE student_name = 'student_59'
         ORDER BY module_id, lesson_position, step_position, submission_time
       ),
-- замена времени попытки, если время больше 3600 сек
       temp_table_2
    AS 
       (
        SELECT student_name AS Студент,
               Шаг,
               Номер,
               result AS Результат,
               IF(time_attempt < 3600, time_attempt, @avg_time) AS Время_попытки,
               step_id
          FROM temp_table_1
       )
-- финальный вывод
SELECT Студент,
       Шаг,
       Номер AS Номер_попытки,
       Результат,
       SEC_TO_TIME(Время_попытки) AS Время_попытки,
       ROUND(Время_попытки / SUM(Время_попытки) OVER (PARTITION BY step_id) * 100, 2) AS Относительное_время
  FROM temp_table_2;