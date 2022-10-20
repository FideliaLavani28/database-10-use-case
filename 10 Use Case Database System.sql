--2401954905 - FIDELIA LAVANI

USE ABlockBuster

--1.	Display MovieTitle and MovieSummary from Movies Table for every movie which its director is Hayao Miyazaki.
--(like)
SELECT MovieTitle, MovieSummary
FROM Movies
WHERE MovieDirector LIKE 'Hayao Miyazaki'

--2.	Display RentalID, RentalDate, and UserName for every rent that happened on Sunday.
--(datename, join)
SELECT RentalID, RentalDate, UserName
FROM RentalHeader rh JOIN Users u ON rh.UserID=u.UserID
WHERE DATENAME(WEEKDAY,RentalDate)='Sunday'

--3.	Display RentalID, Rental Date in (dd Mon yyyy) format, and Movie Count (obtained from the numbers of movie rented) for every rent that happened on November.
--(convert, count, month, join)
SELECT rd.RentalID, [Rental Date]=CONVERT(varchar, RentalDate,106), [Movie Count]=COUNT(rd.MovieID)
FROM RentalHeader rh JOIN RentalDetail rd ON rh.RentalID=rd.RentalID JOIN Movies m ON m.MovieID=rd.MovieID
WHERE MONTH(RentalDate)=11
GROUP BY rd.RentalID, RentalDate

--4.	Display Month (obtained from the month name in uppercase letter), Number of rents (obtained from the total amount of rent duration of that month), and Avg Duration (obtained from the Average duration of rent in that month) for every rent in October. Then, combine it with Month (obtained from the month name in uppercase letter), Number of rents (obtained from the total amount of rent duration of that month), and Avg Duration (obtained from the Average duration of rent in that month) for every rent in November. 
--(upper, datename, sum, avg, union)
SELECT [Month]=UPPER(DATENAME(MONTH,RentalDate)), [Number of rents]=SUM(Duration), [Avg Duration]=AVG(Duration)
FROM RentalDetail rd JOIN RentalHeader rh ON rd.RentalID=rh.RentalID
WHERE DATENAME(MONTH,RentalDate)='October'
GROUP BY DATENAME(MONTH,RentalDate)

UNION

SELECT [Month]=UPPER(DATENAME(MONTH,RentalDate)), [Number of rents]=SUM(Duration), [Avg Duration]=AVG(Duration)
FROM RentalDetail rd JOIN RentalHeader rh ON rd.RentalID=rh.RentalID
WHERE DATENAME(MONTH,RentalDate)='November'
GROUP BY DATENAME(MONTH,RentalDate)

--5.	Display unique MovieID (obtained by separating the MovieID’s letters and numbers with a whitespace), and the MovieTitle for every movie which genres are either Action or Adventure.
--(distinct, stuff, in)
SELECT DISTINCT [MovieID]=STUFF(mg.MovieID,3,0,' '), MovieTitle
FROM Movies m JOIN MovieGenre mg ON m.MovieID=mg.MovieID JOIN Genres g ON g.GenreID=mg.GenreID
WHERE GenreName IN (
	SELECT GenreName 
	FROM Genres 
	WHERE GenreName IN ('Action','Adventure')
)

--6.	Display UserID and UserName (in capital letters) for every user which average rental duration is above all user’s average rental duration. Make sure that the data shown is not redundant.
--(alias subquery, distinct, upper, having, avg)
SELECT DISTINCT rh.UserID, [UserName]=UPPER(UserName), Duration
FROM Users u JOIN RentalHeader rh ON u.UserID=rh.UserID JOIN RentalDetail rd ON rd.RentalID=rh.RentalID,(
	SELECT [AvgDuration]=AVG(Duration)
	FROM RentalDetail
)x
WHERE x.AvgDuration<Duration

--7.	Create a view named ‘Two Words Titled Movie’ that displays all MovieID, MovieTitle, and MovieSummary for every movie which title contains min 2 words and director is unknown(null).
--(create view, charindex, is null)
CREATE VIEW [Two Words Titled Movie]
AS
SELECT MovieID, MovieTitle, MovieSummary
FROM Movies
WHERE MovieDirector IS NULL AND CHARINDEX(' ',MovieTitle)>1

--8.	Create a view named ‘Not Returned Movie Count’ that displays MovieTitle and Rented Out Count (obtained from the total of movie rented and not yet returned) for every show which is rented out count more than 1. 
--(create view, count, like, having)
CREATE VIEW [Not Returned Movie Count]
AS
SELECT MovieTitle, [Rented Out Count]=COUNT([Status])
FROM RentalDetail rd JOIN Movies m ON m.MovieID=rd.MovieID
WHERE Status LIKE 'Not Returned'
GROUP BY MovieTitle
HAVING COUNT([Status])>1

--9.	Add a column to Movie table named ‘MovieRating’ with data type of VARCHAR (10). After that, add a constraint to check that MovieRating can only be filled with ‘R’ or ‘PG’ or ‘Not Rated’.
--(add, add constraint, in)
ALTER TABLE Movie
ADD MovieRating varchar(10)

ALTER TABLE Movie
ADD CONSTRAINT CheckMovieRating CHECK(MovieRating IN ('R','PG','Not Rated'))

--10.	Update User’s status to ‘Banned’ if the user has a rental that is not yet returned, and the expected return date is before November 15th, 2021.
--(update, dateadd, like)
--BEGIN TRAN
UPDATE Users
SET UserStatus='Banned'
FROM Users u JOIN RentalHeader rh ON u.UserID=rh.UserID JOIN RentalDetail rd ON rd.RentalID=rh.RentalID
WHERE [Status] LIKE 'Not Returned' AND DATEADD(DAYOFYEAR,Duration,RentalDate)<'2021-11-15'
--ROLLBACK