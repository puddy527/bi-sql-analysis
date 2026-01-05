SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;


#prepare backup 
-- Step 1: View original table
SELECT * FROM online_learning_course_consumption_dataset;
CREATE TABLE online2 LIKE online_learning_course_consumption_dataset;
SELECT * FROM online2;
INSERT INTO online2 SELECT * FROM online_learning_course_consumption_dataset;
SELECT * FROM online2;

#max satisfaction score
select min(Satisfaction_Score) from online2;
select max(Satisfaction_Score) from online2;

#max duration
ALTER TABLE online2
Add Column Total_Time int;

UPDATE online2 
SET Total_Time = Hours_SPent_Per_Week*Course_Duration_Weeks;

#dropout reason
select Dropout_Reason,count(Dropout_Reason) from online2 where Dropout_Reason!='No Dropout' group by Dropout_Reason ;

#expeirence level
select Experience_Level,count(Experience_Level) as count from online2 group by Experience_Level; #spread
select Experience_Level, sum(Completion_Percentage)/count(Experience_Level) as avg_comp_percentage from online2 group by Experience_Level;#completion rate
select Experience_Level , sum(Total_Time)/count(Experience_Level) as avg_length from online2 group by Experience_Level; #avg course duration
select Experience_Level, sum(Satisfaction_Score)/count(Experience_Level) as avg_satisfaction from online2 group by Experience_Level; #avg satsifaction score

CREATE TABLE course_summary_exp AS
SELECT 
    Experience_Level,
    COUNT(Experience_Level) AS count,
    AVG(Completion_Percentage) AS avg_comp_percentage,
    AVG(Total_Time) AS avg_length,
    AVG(Satisfaction_Score) AS avg_satisfaction
FROM online2
GROUP BY Experience_Level;


#tech or non tech
select Course_Type,count(Course_Type) as count from online2 group by Course_Type;#more popular
select Course_Type, sum(Completion_Percentage)/count(Course_Type) as avg_comp_percentage from online2 group by Course_Type;#completion rate
select Course_Type, sum(Total_Time)/count(Course_Type) as avg_length from online2 group by Course_Type; #avg course duration
select Course_Type, sum(Satisfaction_Score)/count(Course_Type) as avg_satisfaction from online2 group by Course_Type; #avg satsifaction score

CREATE TABLE course_summary_coursetype AS
SELECT 
    Course_Type,
    COUNT(Course_Type) AS count,
    AVG(Completion_Percentage) AS avg_comp_percentage,
    AVG(Total_Time) AS avg_length,
    AVG(Satisfaction_Score) AS avg_satisfaction
FROM online2
GROUP BY Course_Type;

select * from course_summary_coursetype;


#platform
select Platform,count(Platform) as count from online2 group by Platform;#more popular
select Platform, sum(Completion_Percentage)/count(Platform) as avg_comp_percentage from online2 group by Platform;#completion rate
select Platform, sum(Total_Time)/count(Platform) as avg_length from online2 group by Platform; #avg course duration
select Platform, sum(Satisfaction_Score)/count(Platform) as avg_satisfaction from online2 group by Platform; #avg satsifaction score

CREATE TABLE course_summary_platform AS
SELECT 
    Platform,
    COUNT(Platform) AS count,
    AVG(Completion_Percentage) AS avg_comp_percentage,
    AVG(Total_Time) AS avg_length,
    AVG(Satisfaction_Score) AS avg_satisfaction
FROM online2
GROUP BY Platform;

select * from course_summary_platform;