/*
Проанализировать, в каком порядке и с каким интервалом пользователь отправлял последнее верно выполненное задание каждого урока. 
Учитывать только студентов, прошедших хотя бы один шаг из всех трех уроков. В базе занесены попытки студентов 
для трех уроков курса, поэтому анализ проводить только для этих уроков.

Для студентов прошедших как минимум по одному шагу в каждом уроке, 
найти последний пройденный шаг каждого урока - крайний шаг, и указать:

- имя студента;
- номер урока, состоящий из номера модуля и через точку позиции каждого урока в модуле;
- время отправки  - время подачи решения на проверку;
- разницу во времени отправки между текущим и предыдущим крайним шагом в днях, при этом для первого 
  шага поставить прочерк ("-"), а количество дней округлить до целого в большую сторону.
Столбцы назвать Студент, Урок, Макс_время_отправки и Интервал соответственно. 
Отсортировать результаты по имени студента в алфавитном порядке, а потом по возрастанию времени отправки.
*/

  WITH students_3 -- выбираем студентов, прошедших хотя бы один шаг из всех трех уроков
    AS ( 
        SELECT student_name, student_id
          FROM student
               JOIN step_student USING(student_id)
               JOIN step USING(step_id)
         GROUP BY student_name, student_id
        HAVING COUNT(DISTINCT lesson_id) = 3
       ),
       stud_max_time(student_name, les, max_time)
	   -- выбираем максимальное время сдачи у студентов
    AS (
        SELECT student_name, 
               CONCAT(module_id, '.', lesson_position) AS les,
               MAX(submission_time) AS max_time
          FROM students_3
               JOIN step_student USING(student_id)
               JOIN step USING(step_id)
               JOIN lesson USING(lesson_id)
	     WHERE result = 'correct'
         GROUP BY student_name, lesson_id
         ORDER BY student_name, max_time
       ),
       stud_interval
	   -- разница во времени отправки между текущим и предыдущим крайним шагом
    AS (
        SELECT student_name AS Студент,
               les AS Урок,
               FROM_UNIXTIME(max_time) AS Макс_время_отправки,
               max_time - LAG(max_time) OVER (PARTITION BY student_name ORDER BY max_time) AS Интервал
          FROM stud_max_time
       )
-- финальный вывод
SELECT Студент,
       Урок,
       Макс_время_отправки,
       IFNULL(CEIL(Интервал / 86400), '-') AS Интервал
  FROM stud_interval
 ORDER BY Студент, Макс_время_отправки




