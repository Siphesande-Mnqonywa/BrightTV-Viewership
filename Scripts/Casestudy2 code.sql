--creating a temp table , cleaning and joining the tables ( never work on the original)
create or replace Temporary table viewers_temp_tbl as (

SELECT  
    A.UserID,
    A.Name,
    A.Surname,
    A.Email,
    CASE 
        WHEN A.Gender IS NULL OR A.Gender = 'None' THEN 'other'
        ELSE A.Gender
    END AS Gender,
    CASE 
        WHEN A.Race IS NULL OR A.Race = 'None' THEN 'other'
        ELSE A.Race
    END AS Race,
    A.Age,
    CASE 
        WHEN A.Province IS NULL OR A.Province = 'None' THEN 'other'
        ELSE A.Province
    END AS Province,
    B.Channel2 AS Channel,
    B.RecordDate2 AS Date,
    B.DURATION_2 AS Duration
    
FROM 
    viewers_tbl AS A
INNER JOIN viewership_tbl AS B
    on A.USERID = B."UserID"
)
-- converting UTC to african time
UPDATE viewers_temp_tbl
SET Date = CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(Date, 'MM/DD/YYYY HH24:MI'));

--Adding Column table

ALTER TABLE viewers_temp_tbl 
ADD COLUMN Time TIME;

-- Timestamp to time
UPDATE viewers_temp_tbl
SET Time = TO_CHAR(TO_TIMESTAMP(Date, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'HH24:MI');

ALTER TABLE viewers_temp_tbl 
ADD COLUMN The_date DATE;

-- Timestapp to Date
UPDATE viewers_temp_tbl
SET The_date = TO_CHAR(TO_TIMESTAMP(Date, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'YYYY-MM-DD');

select userid,name,Surname,Email,gender,race,age,province, channel,the_date,time,
    duration,

    -- case to classify the age
    case
        when age = 0 then 'Age_Not_Specified'
        when age between 1 and 12 then 'Children'
        when age between 13 and 17 then 'Teenagers'
        when age between 18 and 24 then 'Young_Adults'
        when age between 25 and 59 then 'Adults'
        else 'Seniors'
    End as Age_groups,
    -- to classify the shows per channel
    CASE 
    WHEN Time::TIME BETWEEN '05:00' AND '11:59' THEN 'Morning_Shows'
    WHEN Time::TIME BETWEEN '12:00' AND '19:59' THEN 'Afternoon_Shows'
    WHEN Time::TIME BETWEEN '20:00' AND '22:59' THEN 'Primetime_Shows'
    ELSE 'Midnight_Shows'
    END AS Shows,
    
    -- to catagorize the
  CASE 
    WHEN DATE_PART('HOUR', Duration::TIME) = 0 AND DATE_PART('MINUTE', Duration::TIME) < 30 THEN '< 30 M'
    WHEN DATE_PART('HOUR', Duration::TIME) < 1 THEN '< 1H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 2 THEN '< 2H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 3 THEN '< 3H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 4 THEN '< 4H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 5 THEN '< 5H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 6 THEN '< 6H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 7 THEN '< 7H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 8 THEN '< 8H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 9 THEN '< 9H'
    WHEN DATE_PART('HOUR', Duration::TIME) < 10 THEN '< 10H'
    ELSE '> 10H'
END AS Watch_duration

       

from viewers_temp_tbl