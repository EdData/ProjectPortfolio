-- Reed DataCleaning in MySQL.

-- I used webscraped data for this project, from over 10,000 job posts on Reed.co.uk.
-- These posts had the keyword 'Data' and the location as London.


-- ---------------------------------------------------------------------------------------------------------


-- To start with this project I will load all the data to see what I am required to do.


USE Project1;

SELECT *
FROM ReedJobs;


-- The best thing to do first would be to parse the string values into new columns.
-- So I will start by making a new column and then parse the necessary text into these columns.


ALTER TABLE ReedJobs
ADD COLUMN Job_Title VARCHAR(250) AFTER title;

ALTER TABLE ReedJobs
ADD COLUMN Post_Date VARCHAR(250) AFTER Job_Title;

ALTER TABLE ReedJobs
ADD COLUMN Company_Name VARCHAR(250) AFTER Post_Date;


-- Starting with the title column from the initial CSV, I will use SUBSTRING_INDEX
-- to parse the string values into the newly created columns.


SELECT
	SUBSTRING_INDEX(title, "by", -1) AS Company
FROM
	ReedJobs;

SELECT
	SUBSTRING_INDEX(SUBSTRING_INDEX(title, "             ", 2), "  ", -1) AS Role
FROM
	ReedJobs;

SELECT
	SUBSTRING_INDEX(SUBSTRING_INDEX(title, "             ", -1), "by", 1) AS Post_time
FROM
	ReedJobs;


-- Before I Insert the parsed strings into the new columns, I will create an index so it is easier
-- to differentiate the individual posts.


ALTER TABLE ReedJobs
ADD COLUMN Index_Num INT NOT NULL PRIMARY KEY AUTO_INCREMENT FIRST;


-- Next I update the table with the parsed columns from the original title column.
-- Categorising the data allows for easier analysis later.


UPDATE ReedJobs
SET Job_Title = SUBSTRING_INDEX(SUBSTRING_INDEX(title, "             ", 2), "  ", -1);

UPDATE ReedJobs
SET Company_Name = SUBSTRING_INDEX(title, "by", -1);

UPDATE ReedJobs
SET Post_Date = SUBSTRING_INDEX(SUBSTRING_INDEX(title, "             ", -1), "by", 1);


-- Next I check the distict values to see if any columns are different from what is expected.


SELECT
	DISTINCT(Job_Title)
FROM
	ReedJobs;

SELECT
	DISTINCT(Company_Name)
FROM
	ReedJobs;

SELECT
	DISTINCT(Post_Date)
FROM
	ReedJobs;


-- Next I will drop the original 'title', column as all the required information
-- has been parsed into seperate columns


ALTER TABLE ReedJobs 
DROP COLUMN title;


-- I commit my work to save my changes after checking.


COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Now I will repeat this with the locationSalary column,
-- this column holds information about the salary, location,
-- and wether the job is full-time part time etc.


SELECT *
FROM ReedJobs;


-- I am repeating the process of finding the substrings, which I will use
-- to seperate the data into different categories.


SELECT
	locationSalary
FROM
	ReedJobs;


SELECT
	SUBSTRING_INDEX(SUBSTRING_INDEX(locationSalary, "£", -3), "              ", 2) AS salary
FROM ReedJobs;

SELECT
	SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(locationSalary, "£", -3), "              ", 4), " ", -3) AS location
FROM ReedJobs;

SELECT
	SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(locationSalary, "£", -3), "               ", -6), "                ", -4) AS wfm_contract
FROM ReedJobs;


-- I had some trouble with the 'work from home' string,
-- as it was not alligned with the rest of the results.
-- So I decided to pull the contract type and 'work from home' string as one substring.

-- Next I alter the table to add four new columns.


ALTER TABLE ReedJobs
ADD COLUMN Job_Salary VARCHAR(250) AFTER locationSalary;

ALTER TABLE ReedJobs
ADD COLUMN Job_Location VARCHAR(250) AFTER Job_Salary;

ALTER TABLE ReedJobs
ADD COLUMN Contract_Type VARCHAR(250) AFTER Job_Location;

ALTER TABLE ReedJobs
ADD COLUMN Work_Home VARCHAR(250) AFTER Contract_Type;


-- I Update the first two (Job_Salary, Job_Location) normally 
-- The contract type column will include 'work from home' for now
-- and also some location values as the string values were not aligned.


UPDATE ReedJobs
SET Job_Salary = SUBSTRING_INDEX(SUBSTRING_INDEX(locationSalary, "£", -3), "              ", 2);

UPDATE ReedJobs
SET Job_Location = SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(locationSalary, "£", -3), "              ", 4), " ", -3);

UPDATE ReedJobs
SET Contract_Type = SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(locationSalary, "£", -3), "               ", -6), "     
           ", -4);

          
-- A case statement is used so that if the 'work from home' string was visible in the Contract_Type
-- column it would say 'Yes'.
          

SELECT
	Contract_Type,
	CASE
		WHEN Contract_Type LIKE "%Work from home%" THEN "Yes"
		ELSE "No"
	END
FROM ReedJobs;
	

UPDATE ReedJobs
SET Work_Home = CASE
	WHEN Contract_Type LIKE "%Work from home%" THEN "Yes"
		ELSE "No"
	END;

COMMIT;


-- Now I will extract the contract type without the work from home string.


SELECT
	DISTINCT(Contract_Type)
FROM
	ReedJobs;


-- Since there are only 3 contract types I decided to use a case statement here aswell.
-- I thought this to be easier than using substrings as the strings are not all aligned,
-- as seen with the previous work from home issue.


SELECT
	Contract_Type,
	CASE
		WHEN Contract_Type LIKE "%Permanent%" THEN "Permanent, full-time"
		WHEN Contract_Type LIKE "%Contract%" THEN "Contract, full-time"
		WHEN Contract_Type LIKE "%Temporary%" THEN "Temporary, full-time"
		ELSE Contract_Type
	END
FROM ReedJobs;


-- Implement this case statement with an update.


UPDATE ReedJobs
SET Contract_Type = CASE
	WHEN Contract_Type LIKE "%Permanent%" THEN "Permanent, full-time"
		WHEN Contract_Type LIKE "%Contract%" THEN "Contract, full-time"
		WHEN Contract_Type LIKE "%Temporary%" THEN "Temporary, full-time"
		ELSE Contract_Type
END;


-- Check for errors.


SELECT
	*
FROM
	ReedJobs;


-- Finally I am dropping the original column which I parsed the data from.
-- Then commiting my changes.


ALTER TABLE ReedJobs
DROP locationSalary;


COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Now I have been working with the ꟼ values in my table for some time 
-- and will need to remove these values to make my data look a lot neater.


SELECT 
	*
FROM
	ReedJobs;


SELECT
	REPLACE(Job_Title, '\n', ''),
	REPLACE(Company_Name, '\n', ''),
	REPLACE(Job_Salary, '\n', ''),
	REPLACE(Job_Location, '\n', ''),
	REPLACE(description, '\n', '')
FROM
	ReedJobs;


-- Implement the changes to my table with an update statement.


UPDATE ReedJobs 
	SET Job_Title = REPLACE(Job_Title, '\n', ''),
	Company_Name = REPLACE(Company_Name, '\n', ''),
	Job_Salary = REPLACE(Job_Salary, '\n', ''),
	Job_Location = REPLACE(Job_Location, '\n', ''),
	description = REPLACE(description, '\n', '');


-- Then I check before I commit my changes.


SELECT
	*
FROM
	ReedJobs;

COMMIT;


-- Now these ꟼ values have been removed I will remove any white spacing within these
-- recently updated columns.


UPDATE ReedJobs 
	SET Job_Title = TRIM(Job_Title),
	Company_Name = TRIM(Company_Name),
	Job_Salary = TRIM(Job_Salary),
	Job_Location = TRIM(Job_Location),
	description = TRIM(description),
	Post_Date = TRIM(Post_Date);


-- Check again and commit.


SELECT
	*
FROM
	ReedJobs;

COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Now to make sure all the dates are in the correct format,
-- I will create a new column and alter the values according
-- to the current date.

-- The current date of writing this code, is 1 day later than when I
-- did the webscraping (1 day out of date).
-- Therefore this is considered when altering the date values.


ALTER TABLE ReedJobs
ADD COLUMN Date_Posted DATE AFTER Post_Date;


SELECT DISTINCT(Post_date)
FROM
	ReedJobs;


-- By using a case statement and the SYSDATE function i am able to subtract
-- days from the current date when the string reads a specific value.
-- Since we are 1 day later than the webscraping date I will minus an extra day.


SELECT
CASE 
	WHEN Post_Date LIKE "%6 days%" THEN SYSDATE() - INTERVAL 7 DAY
	WHEN Post_Date LIKE "%5 days%" THEN SYSDATE() - INTERVAL 6 DAY
	WHEN Post_Date LIKE "%1 week%" THEN SYSDATE() - INTERVAL 8 DAY
	WHEN Post_Date LIKE "%4 days%" THEN SYSDATE() - INTERVAL 5 DAY
	WHEN Post_Date LIKE "%Yesterday%" THEN SYSDATE() - INTERVAL 2 DAY
	ELSE NULL
END
FROM
	ReedJobs;


-- Updating this statement into the new column.


UPDATE ReedJobs
SET Date_Posted = CASE 
	WHEN Post_Date LIKE "6 days%" THEN SYSDATE() - INTERVAL 7 DAY
	WHEN Post_Date LIKE "5 days%" THEN SYSDATE() - INTERVAL 6 DAY
	WHEN Post_Date LIKE "1 week%" THEN SYSDATE() - INTERVAL 8 DAY
	WHEN Post_Date LIKE "4 days%" THEN SYSDATE() - INTERVAL 5 DAY
	WHEN Post_Date LIKE "Yesterday%" THEN SYSDATE() - INTERVAL 2 DAY
	ELSE NULL
END;


-- Checking my work before I commit.


SELECT
	*
FROM
	ReedJobs;

COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- As we are only working with November/December then we can make a CASE for these months.
-- I start by adding a new column for the months, day and year.


ALTER TABLE ReedJobs
ADD COLUMN
	Date_Month VARCHAR(250) AFTER Post_Date;

ALTER TABLE ReedJobs
ADD COLUMN 
	Date_Day VARCHAR(250) AFTER Post_Date;

ALTER TABLE ReedJobs
ADD COLUMN 
	Date_Year VARCHAR(250) AFTER Date_Month;


-- I decide to commit here so I can use rollback incase I make any errors.


COMMIT;


-- This case statement reads that if the string says november then it will
-- return 11. Since we are working with only the month of November
-- we do not have to write out each month.


SELECT
CASE
	WHEN Post_Date LIKE "%November%" THEN 11
	ELSE NULL
END
FROM ReedJobs;


-- I am using ELSE NULL as I have done a different method for those days which can be calculated
-- from the current date. 12th December.


UPDATE ReedJobs
SET Date_Month = CASE
	WHEN Post_Date LIKE "%November%" THEN 11
	ELSE NULL
END;


-- Checking again before I commit.


SELECT
	*
FROM 
	ReedJobs


COMMIT;


-- Case statement used to input the years for fields we will use.
-- Data has only been taken from the current year (2022).


SELECT 
	CASE WHEN Date_Month IS NOT NULL THEN '2022'
	ELSE NULL
	END
FROM ReedJobs;

UPDATE ReedJobs
SET Date_Year = CASE WHEN Date_Month IS NOT NULL THEN '2022'
	ELSE NULL
	END
	

SELECT
	*
FROM 
	ReedJobs		
	
COMMIT;


-- Now I am extracting the first 2 letters of the string from the original date column
-- This is because the first 2 string values contain the date.


-- I then place it where the Date_Month column is NOT NULL.
-- I.E keeping Columns of the same format together.


-- Trim is used here because some date values are only 1 character long.
-- This is to avoid trailing spaces.


SELECT
	LEFT(TRIM(Post_Date), 2)
FROM
	ReedJobs;

UPDATE	ReedJobs 
SET Date_Day = LEFT(TRIM(Post_Date), 2)
WHERE Date_Month IS NOT NULL;


-- Checking before I commit.


SELECT
	*
FROM
	ReedJobs;


COMMIT;

	
-- Now the day, month and year all have a number and their own column I can join them into one.


ALTER TABLE ReedJobs
ADD COLUMN Date_Join VARCHAR(250) AFTER Date_Year;

SELECT
	Date_Day,
	Date_Month,
	Date_Year,
	Date_Join
FROM
	ReedJobs;


-- I will use the CONCAT function to join these values together
-- Seperating the different values with '-'.


SELECT
	CONCAT(Date_Year, '-', Date_Month, '-', Date_Day)
FROM
	ReedJobs;

UPDATE ReedJobs
SET Date_Join = CONCAT(Date_Year, '-', Date_Month, '-', Date_Day);

-- Checking before I commit.


SELECT
	*
FROM
	ReedJobs;

COMMIT;


-- Now I will alter the string values in the 'Date_Join' table to DATE values
-- and update the Date_Posted column (The column with the finalised values).

-- Ensuring that the format is the same as the previously extracted DATE values.
-- Which were extracted using the SYSDATE function.


ALTER TABLE ReedJobs
MODIFY Date_Join DATE;

UPDATE ReedJobs
SET Date_Posted = Date_Join
WHERE Date_Posted IS NULL;


-- Check and then drop the columns. Followed by a commit.


SELECT 
	*
FROM
	ReedJobs;

ALTER TABLE ReedJobs
DROP Date_Day,
DROP Date_Month,
DROP Date_Year,
DROP Date_Join;

ALTER TABLE ReedJobs
DROP Post_Date;

COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Now I will need to fix the salary column as some companies pay by day,
-- some by year and some say competitive salary.


SELECT
	DISTINCT(Job_Salary)
FROM
	ReedJobs;



-- By looking at the distinct values I can see that some of the values are
-- within a range (lowest-highest) and some are not.


-- I decided to seperate the values by from lowest to highest
-- using the SUBSTRING_INDEX function again.


SELECT
	SUBSTRING_INDEX(Job_Salary , " ", 1) AS Salary_Lowest
FROM
	ReedJobs;

SELECT
	SUBSTRING_INDEX(SUBSTRING_INDEX(Job_Salary, " ", 3), " ", -1) AS Salary_Highest
FROM
	ReedJobs;


-- Now the salaries are seperated from lowest to highest
-- I will make new columns for each lowest and highest.

-- Making 2 columns for daily salary (per day).


ALTER TABLE ReedJobs
ADD COLUMN daily_lowest VARCHAR(250),
ADD COLUMN daily_highest VARCHAR(250);


-- Then updating these columns with the substring.
-- Where the word day is present in the original column.


UPDATE ReedJobs
SET daily_lowest = SUBSTRING_INDEX(Job_Salary , " ", 1)
WHERE Job_Salary LIKE '%day%';

UPDATE ReedJobs
SET daily_highest = SUBSTRING_INDEX(SUBSTRING_INDEX(Job_Salary, " ", 3), " ", -1) 
WHERE Job_Salary LIKE '%day%';


-- Check to see if correct, then COMMIT.


SELECT
	Job_Salary,
	daily_lowest,
	daily_highest
FROM
	ReedJobs;

COMMIT;


-- The values which don't have a range have now made it so
-- daily highest sometimes reads day.
-- I will set these values to NULL 


UPDATE ReedJobs
SET daily_highest = NULL
WHERE daily_highest = 'day';


-- Now some of the daily_highest values are null,
-- I will use the IFNULL function to fill these with the lowest values.


SELECT
	IFNULL(daily_highest, daily_lowest),
	daily_lowest,
	daily_highest
FROM
	ReedJobs;


-- This will become the new daily_highest value.


UPDATE ReedJobs
SET daily_highest = IFNULL(daily_highest, daily_lowest);


-- Checking this and commit.

SELECT
	daily_lowest,
	daily_highest,
	Job_Salary
FROM
	ReedJobs;

COMMIT;


-- Now I want to convert these values to integers in order
-- to perform calculations with them.
-- Firstly I will remove the pound signs and trim trailing spaces.


UPDATE ReedJobs
SET daily_lowest = TRIM(REPLACE(daily_lowest,'£',' ')),
daily_highest = TRIM(REPLACE(daily_highest, '£',' '));


-- Then I alter the columns to turn them into INTEGERs.


ALTER TABLE ReedJobs
MODIFY daily_lowest INT;

ALTER TABLE ReedJobs
MODIFY daily_highest INT;

COMMIT;


-- If we estimate that there are 260 work days in a year we can calulcate the per annum.


SELECT
	(daily_lowest * 260) AS Lowest_Annum,
	(daily_highest * 260) AS Highest_Annum
FROM
	ReedJobs;


-- I create 2 new columns for our calculated values to go into.


ALTER TABLE ReedJobs 
ADD COLUMN Highest_Annum INT AFTER Job_Salary,
ADD COLUMN Lowest_Annum INT AFTER Job_Salary;

COMMIT;


-- Update these values into the new columns.


UPDATE ReedJobs
SET Lowest_Annum = (daily_lowest * 260);

UPDATE ReedJobs
SET Highest_Annum = (daily_highest * 260);

COMMIT;


-- Check to see if it is correct. Then commit


SELECT
	*
FROM
	ReedJobs;


-- Drop the columns used in the calculations and commit.


ALTER TABLE ReedJobs
DROP daily_lowest,
DROP daily_highest;

COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Now I will do the same for yearly salary using substrings.


ALTER TABLE ReedJobs
ADD COLUMN yearly_lowest VARCHAR(250),
ADD COLUMN yearly_highest VARCHAR(250);


UPDATE ReedJobs
SET yearly_lowest = SUBSTRING_INDEX(Job_Salary , " ", 1)
WHERE Job_Salary LIKE '%annum%';

UPDATE ReedJobs
SET yearly_highest = SUBSTRING_INDEX(SUBSTRING_INDEX(Job_Salary, " ", 3), " ", -1) 
WHERE Job_Salary LIKE '%annum%';


COMMIT;


-- This was done quickly by copying my previous code and changing daily -> yearly
-- and day -> annum.

-- Check to see if correct and commit.

SELECT
	*
FROM
	ReedJobs;

COMMIT;


-- Now to remove the characters again and then modify to INT.
-- Again copy and pasting saves a lot of time.


UPDATE ReedJobs
SET yearly_lowest = TRIM(REPLACE(yearly_lowest,'£',' ')),
yearly_highest = TRIM(REPLACE(yearly_highest, '£',' '));


-- Here I had to remove the commas in order to change the data type
-- to and Integer.


UPDATE ReedJobs
SET yearly_lowest = TRIM(REPLACE(yearly_lowest,',','')),
yearly_highest = TRIM(REPLACE(yearly_highest, ',',''));


ALTER TABLE ReedJobs
MODIFY yearly_lowest INT;

ALTER TABLE ReedJobs
MODIFY yearly_highest INT;


-- Checking if correct and commit.


SELECT *
FROM
	ReedJobs;

COMMIT;


-- Now finally to update lowest/highest_annum columns
-- where the columns have NULL values.
-- In order to not lose our previously inserted values.


UPDATE ReedJobs
SET Lowest_Annum = yearly_lowest
WHERE Lowest_Annum IS NULL;

UPDATE ReedJobs
SET Highest_Annum = yearly_highest
WHERE Highest_Annum IS NULL;


-- Now drop the old columns used, check and commit.

ALTER TABLE ReedJobs
DROP yearly_lowest;

ALTER TABLE ReedJobs
DROP yearly_highest;

SELECT
	*
FROM 
	ReedJobs

COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Checking to see what else is included in the salary columns.


SELECT
	DISTINCT(Job_Salary)
FROM
	ReedJobs;


-- There are strings containgin the words 'benefits', 'salary negotiable' and 'competitive salary'.
-- Starting with negotiable and competitive salary.

-- In order to include string values I need to
-- modify the 2 columns again to a VARCHAR.


ALTER TABLE ReedJobs
MODIFY Lowest_Annum VARCHAR(250);

ALTER TABLE ReedJobs
MODIFY Highest_Annum VARCHAR(250);

COMMIT;

-- Sadly, I have now lost my commas, for my salary numbers. 
-- Using the format function I can get them back to make my values look neater.


SELECT
	FORMAT(Lowest_Annum, 0)
FROM
	ReedJobs;


UPDATE ReedJobs
SET Lowest_Annum = FORMAT(Lowest_Annum, 0);

UPDATE ReedJobs
SET Highest_Annum = FORMAT(Highest_Annum, 0);

COMMIT;


-- I will also add back the £ sign using the concat function


SELECT
	CONCAT('£', Lowest_Annum)
FROM
	ReedJobs;


UPDATE ReedJobs
SET Lowest_Annum = CONCAT('£', Lowest_Annum);

UPDATE ReedJobs
SET Highest_Annum = CONCAT('£', Highest_Annum);

COMMIT;


-- Doing this before I extract the strings so they do not contain the same
-- commas and pound signs.







-- ---------------------------------------------------------------------------------------------------------







-- Now I can add in the strings 'Competitive' and 'Negotiable'.
-- Where these strings are seen in the original column.


UPDATE ReedJobs
SET Lowest_Annum = 'Competitive'
WHERE Job_Salary LIKE '%competitive%';

UPDATE ReedJobs
SET Lowest_Annum = 'Negotiable'
WHERE Job_Salary LIKE '%negotiable%';


UPDATE ReedJobs
SET Highest_Annum = 'Competitive'
WHERE Job_Salary LIKE '%competitive%';

UPDATE ReedJobs
SET Highest_Annum = 'Negotiable'
WHERE Job_Salary LIKE '%negotiable%';



-- Checking if correct and commit.


SELECT 
	*
FROM
	ReedJobs;

COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Now some posts say they include benefits, so i will add a seperate column for this.


ALTER TABLE ReedJobs 
ADD COLUMN Inc_Benefits VARCHAR(250) AFTER Highest_Annum;


-- Case statement will be utilised to see if there is the string 'benefit'
-- in the job post or description and will return yes/no accordingly.


SELECT
	CASE
		WHEN Job_Salary LIKE '%benefits%' THEN 'Yes'
		WHEN description LIKE '%benefits%' THEN 'No'
		ELSE 'No'
	END
FROM
	ReedJobs;

	
-- Update the new column.


UPDATE ReedJobs
SET Inc_Benefits = CASE
	WHEN Job_Salary LIKE '%benefits%' THEN 'Yes'
	WHEN description LIKE '%benefits%' THEN 'Yes'
	ELSE 'No'
END;


-- Last checks for the salary column.
-- Then drop the previous columns used for parsing and commit.

SELECT
	*
FROM
	ReedJobs;

ALTER TABLE ReedJobs 
DROP yearly_lowest,
DROP yearly_highest;


-- Dropping the original salary column aswell. 


ALTER TABLE ReedJobs
DROP Job_Salary;


COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- I am going to check for duplicate posts.
-- This can be done by using a window function.


-- I will partition by, the Salary, company name, job title and description.
-- Because if all of these are exactly the same I will consider the post to be 
-- a duplicate.


SELECT *,
ROW_NUMBER() OVER(
		PARTITION BY 
				Job_Title,
				Lowest_Annum,
				Highest_Annum,
				Company_Name,
				description
				ORDER BY
					Index_Num
					)As row_num
FROM ReedJobs;


-- This shows result shows the row number of job posts with the exact same Salary, Company name, job title
-- and description.

-- I will use a CTE to see the posts with row number greater than 1 to see how many duplicates are
-- in this data set.


WITH Row_CTE AS(SELECT *,
ROW_NUMBER() OVER(
		PARTITION BY 
				Job_Title,
				Lowest_Annum,
				Highest_Annum,
				Company_Name,
				description
				ORDER BY
					Index_Num
					)As row_num
FROM ReedJobs)
SELECT COUNT(*)
FROM
	Row_CTE
WHERE
	row_num > 1;


-- As an analyst may want to see which companies post more frequently,
-- I will create a new table to insert my non-duplicate data.
-- So that I can keep my original data with duplicates.


CREATE TABLE ReedJobs_Distinct
(Job_Title VARCHAR(250),
Date_Posted DATE,
Company_Name VARCHAR(250),
Lowest_Annum VARCHAR(250),
Highest_Annum VARCHAR(250),
Inc_Benefits VARCHAR(250),
Job_Location VARCHAR(250),
Contract_Type VARCHAR(250),
Work_Home VARCHAR(250),
description VARCHAR(512));


-- With the same index.


ALTER TABLE ReedJobs_Distinct
ADD COLUMN Index_Num INT NOT NULL PRIMARY KEY AUTO_INCREMENT FIRST;

COMMIT;


-- I then INSERT all the data from this clean table and commit.


INSERT INTO ReedJobs_Distinct
SELECT *
FROM
	ReedJobs;

COMMIT;


-- I DELETE FROM this new table to remove all duplicate values.
-- When the row number is higher than 1 it means this is a duplicate value.
-- As the partitions are the same amongst these rows.


WITH CTE AS(SELECT *,
ROW_NUMBER() OVER(
		PARTITION BY 
				Job_Title,
				Lowest_Annum,
				Highest_Annum,
				Company_Name,
				description
				ORDER BY
					Index_Num
					)As row_num
FROM ReedJobs_Distinct)
DELETE FROM ReedJobs_Distinct USING ReedJobs_Distinct
JOIN CTE 
ON ReedJobs_Distinct.Index_Num = CTE.Index_Num
WHERE CTE.row_num > 1;


-- Final checks of my new table and commit.


SELECT
	*
FROM
	ReedJobs_Distinct;

COMMIT;







-- ---------------------------------------------------------------------------------------------------------







-- Finally I noticed, some of the Job_Titles are not all in Correct Case.
-- So I will update both tables.

-- I start by turning strings to lower case in the Job_Title column.


UPDATE ReedJobs_Distinct
SET Job_Title = LCASE(Job_Title); 

UPDATE ReedJobs
SET Job_Title = LCASE(Job_Title); 


-- Next using CONCAT, UCASE and SUBSTRING. I managed to seperate the 2 words
-- In the job titles by their starting position.
-- Then give the first letter of each word an upper case letter. 
                            
                            
SELECT
CONCAT(UCASE(LEFT(Job_Title, 1)), SUBSTRING(Job_Title, 2, 4)),
CONCAT(UCASE(LEFT(SUBSTRING(Job_Title, 6, 9),1)),SUBSTRING(Job_Title, 7, 9))
FROM
	ReedJobs_Distinct


-- I then join the 2 seperate words with the CONCAT function, with the new correct case.
	
	
SELECT
CONCAT(CONCAT(UCASE(LEFT(Job_Title, 1)), SUBSTRING(Job_Title, 2, 4)),CONCAT(UCASE(LEFT(SUBSTRING(Job_Title, 6, 9),1)),SUBSTRING(Job_Title, 7, 9)))
FROM
	ReedJobs_Distinct
	

-- UPDATE both tables.

	
UPDATE ReedJobs
SET Job_Title = CONCAT(CONCAT(UCASE(LEFT(Job_Title, 1)), SUBSTRING(Job_Title, 2, 4)),CONCAT(UCASE(LEFT(SUBSTRING(Job_Title, 6, 9),1)),SUBSTRING(Job_Title, 7, 9)));

UPDATE ReedJobs_Distinct
SET Job_Title = CONCAT(CONCAT(UCASE(LEFT(Job_Title, 1)), SUBSTRING(Job_Title, 2, 4)),CONCAT(UCASE(LEFT(SUBSTRING(Job_Title, 6, 9),1)),SUBSTRING(Job_Title, 7, 9)));


-- Check and commit.


SELECT
	*
FROM
	ReedJobs;

SELECT
	*
FROM
	ReedJobs_Distinct;

COMMIT;



-- ---------------------------------------------------------------------------------------------------------
-- By Edward Renton










