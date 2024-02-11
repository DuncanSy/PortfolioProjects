--Download the dictionary as a CSV. A single file with one column called WORDS where all the words in the English language are there.

/*DELIMETER*/

-- Create a temporary table to store the imported data
CREATE TABLE #TempTable (RowData NVARCHAR(MAX));

-- Adjust the file path and name accordingly
DECLARE @filePath NVARCHAR(255) = 'C:\Users\dunca\Documents\SQL Server Management Studio\Dictionary in csv\A.csv';

-- Use BULK INSERT with ROWTERMINATOR to import the data
DECLARE @sql NVARCHAR(MAX) = 
   'BULK INSERT #TempTable
    FROM ''' + @filePath + '''
    WITH (
        ROWTERMINATOR = ''0x0d0a'',  -- Line feed as the row terminator
        FIELDTERMINATOR = '','',
        FIRSTROW = 2  -- Skip the header row if present
    );';
EXEC sp_executesql @sql;

SELECT RowData
FROM #TempTable;

DROP TABLE #TempTable;

/* IMPORT */

--CREATE TABLE dictionary(
--WORDS NVARCHAR(MAX))


DECLARE @FolderPath NVARCHAR(255) = 'C:\Users\dunca\Documents\SQL Server Management Studio\Dictionary in csv\';
DECLARE @Letter CHAR(1) = 'A';
CREATE TABLE #TempTable (RowData NVARCHAR(MAX));

WHILE ASCII(@Letter) <= ASCII('Z')
BEGIN
    DECLARE @FileName NVARCHAR(255) = @FolderPath + @Letter + '.csv';

    IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
        TRUNCATE TABLE #TempTable;

    DECLARE @sql NVARCHAR(MAX) = 
        'BULK INSERT #TempTable
         FROM ''' + @FileName + '''
         WITH (
             ROWTERMINATOR = ''0x0d0a'',  -- Carriage Return and Line Feed
             FIELDTERMINATOR = '','',
             FIRSTROW = 2  
         );';
    EXEC sp_executesql @sql;

    -- Merge data into a permanent table
    INSERT INTO dictionary (WORDS)
    SELECT *
    FROM #TempTable;

    SET @Letter = CHAR(ASCII(@Letter) + 1);
END;

-- Display the merged data
SELECT *
FROM dictionary;

-- Drop the temporary table
DROP TABLE #TempTable;

/* CLEANING */

UPDATE dictionary
SET WORDS = 
    CASE 
        WHEN LEFT(WORDS, 1) = '"' AND RIGHT(WORDS, 1) = '"'
            THEN SUBSTRING(WORDS, 2, LEN(WORDS) - 2)
        ELSE WORDS
    END;

--DELETE FROM dictionary
--WHERE WORDS IS NULL;

DELETE FROM dictionary
WHERE UPPER(LEFT(WORDS, 1)) NOT BETWEEN 'A' AND 'Z';

-- Add new columns to store the parsed data
ALTER TABLE dictionary
ADD word NVARCHAR(MAX),
    partOfSpeech NVARCHAR(MAX),
    definition NVARCHAR(MAX);

-- Update the new columns with parsed data
UPDATE dictionary
SET 
    word = TRIM(SUBSTRING(WORDS, 1, CHARINDEX('(', WORDS) - 1)),
    partOfSpeech = TRIM(SUBSTRING(WORDS, CHARINDEX('(', WORDS) + 1, CHARINDEX(')', WORDS) - CHARINDEX('(', WORDS) - 1)),
    definition = TRIM(SUBSTRING(WORDS, CHARINDEX(')', WORDS) + 1, LEN(WORDS) - CHARINDEX(')', WORDS)));

ALTER TABLE dictionary
DROP COLUMN WORDS

SELECT *
FROM DictionarySQL..dictionary
ORDER BY word

/* Basic Queries */

--How many words start with A, B, etc. How many words are 1 letter long, 2 letters, etc.

SELECT *
FROM dictionary
WHERE LEN(word) = 5
ORDER BY word;

SELECT COUNT(word) AS howMany
FROM dictionary
WHERE word LIKE 'A%'

--What word comes after kayak? What word comes 10 words after kayak? How about two words before it? 

--CREATE TABLE plainEnglish (
--    word NVARCHAR(MAX),
--); 

INSERT INTO plainEnglish(word)
SELECT DISTINCT word
FROM dictionary
WHERE dictionary.word NOT LIKE '% %' AND dictionary.word NOT LIKE '%-%'
ORDER BY word;

SELECT *
FROM plainEnglish

SELECT *
FROM plainEnglish
WHERE word >= 'Kayak'
ORDER BY word
OFFSET 10 ROWS
FETCH NEXT 1 ROW ONLY;

-- The average length of words --> 8

SELECT AVG(LEN(word)) AS avgLength
FROM plainEnglish

-- Word length with the most words possible --> Length of 8

WITH mostLetter AS (
	SELECT word, LEN(word) as wordLength
	FROM plainEnglish
)
SELECT wordLength, COUNT(wordLength) AS Numwords
FROM mostLetter
GROUP BY wordLength
ORDER BY Numwords DESC

-- Median is at the 53200 position

SELECT COUNT(word) AS TOTAL, COUNT(word)/2 AS Position
FROM plainEnglish

WITH median AS (
	SELECT word, LEN(word) as wordLength
	FROM plainEnglish
)
SELECT wordLength, COUNT(wordLength) AS NumWords
FROM median
GROUP BY wordLength
ORDER BY wordLength


/* Find all palindromes in English */

SELECT COUNT(*) AS Palindromes
FROM plainEnglish
WHERE LOWER(word) = REVERSE(LOWER(word));

SELECT COUNT(*)
FROM DictionarySQL..dictionary

SELECT word AS OriginalWord,
       (
         SELECT LOWER(SUBSTRING(word, number, 1)) AS [text()]
         FROM master.dbo.spt_values
         WHERE type = 'P' AND number BETWEEN 1 AND LEN(word)
         ORDER BY SUBSTRING(word, number, 1)
         FOR XML PATH('')
       ) AS AlphabeticalOrder
FROM DictionarySQL..plainEnglish;

/* Find all anagrams in English */

--CREATE TABLE anagramsEnglish (
--    OriginalWord NVARCHAR(MAX),
--    AlphabeticalOrder NVARCHAR(MAX)
--);

INSERT INTO anagramsEnglish(OriginalWord, AlphabeticalOrder)
SELECT word AS OriginalWord,
       (
         SELECT LOWER(SUBSTRING(word, number, 1)) AS [text()]
         FROM master.dbo.spt_values
         WHERE type = 'P' AND number BETWEEN 1 AND LEN(word)
         ORDER BY SUBSTRING(word, number, 1)
         FOR XML PATH('')
       ) AS AlphabeticalOrder
FROM plainEnglish;

SELECT *
FROM anagramsEnglish
ORDER BY OriginalWord

ALTER TABLE anagramsEnglish
ADD isDistinct BIT;

 /* Additional Data Cleaning */
-- DELETE FROM anagramsEnglish
-- WHERE AlphabeticalOrder NOT LIKE '[A-Za-z]%'

SELECT AlphabeticalOrder,
       CASE
                        WHEN (SELECT COUNT(*) FROM anagramsEnglish AS T2 WHERE T2.AlphabeticalOrder = anagramsEnglish.AlphabeticalOrder) = 1
                        THEN 1
                        ELSE 0
                      END
FROM anagramsEnglish;

UPDATE anagramsEnglish
SET isDistinct = CASE
                        WHEN (SELECT COUNT(*) FROM anagramsEnglish AS T2 WHERE T2.AlphabeticalOrder = anagramsEnglish.AlphabeticalOrder) = 1
                        THEN 1
                        ELSE 0
                      END

SELECT OriginalWord AS Anagrams
FROM anagramsEnglish
WHERE isDistinct = 0
ORDER BY Anagrams

-- Total Anagrams is 14784

SELECT COUNT(isDistinct) AS numAnagrams
FROM anagramsEnglish
WHERE isDistinct = 0

/* Bonus: Scrabble Concepts */

-- Let's say you're playing scrabble and you can only pick 7 letters, what 7 letters can you pick to spell the most 7 letter, 6 letter, 5 letter, 4 letter, 3 letter, 2 letter, and 1 letter words in English?
-- You can spell 10 different words with the letters: s, t, e, a, and l.

SELECT AlphabeticalOrder, COUNT(AlphabeticalOrder) AS numWords
FROM anagramsEnglish
WHERE LEN(AlphabeticalOrder) <= 8
GROUP BY AlphabeticalOrder
ORDER BY numWords DESC


SELECT word
FROM scrabble
WHERE word LIKE '%a%' AND
		word LIKE '%s%' AND
		word LIKE '%e%' AND
		word LIKE '%l%' AND
		word LIKE '%t%' AND
		LEN(word) = 5

-- Now in Scrabble the letters you can select are limited to the tiles in the bag... so add that layer of complexity.

-- New table for better readability for the problem
--CREATE TABLE scrabble (
--word NVARCHAR(MAX),
--);

INSERT INTO scrabble (word)
SELECT OriginalWord
FROM anagramsEnglish

-- Tables for reference
SELECT *
FROM scrabblePoints

SELECT *
FROM scrabble
WHERE LEN(word) < 8 

SELECT *
FROM anagramsEnglish
WHERE LEN(OriginalWord) < 8

-- Scrabble is limited to the number of letters in the bag..add that complexity

--CREATE TABLE scrabbleWithCount (
--    word NVARCHAR(MAX),
--);

INSERT INTO scrabbleWithCount (word)
SELECT word
FROM scrabble s
WHERE
    NOT EXISTS (
        SELECT 1
        FROM (
            SELECT
                SUBSTRING(s.word, number, 1) AS Letter,
                COUNT(*) AS LetterCount
            FROM
                master.dbo.spt_values
            WHERE
                type = 'P'
                AND number BETWEEN 1 AND LEN(s.word)
            GROUP BY
                SUBSTRING(s.word, number, 1)
        ) AS LetterCounts
        JOIN scrabblePoints sp ON LetterCounts.Letter = sp.letter
        WHERE
            LetterCounts.LetterCount > sp.count 
    ) AND LEN(s.word) < 8;

-- Calculate the total points for each word. Best 7 Letter word is 'Quartzy' with 28 Points

SELECT
    word,
    SUM(CAST(sp.points AS INT)) AS TotalPoints
FROM
    scrabbleWithCount sc
CROSS APPLY
    master.dbo.spt_values N
JOIN
    scrabblePoints sp ON SUBSTRING(sc.word, N.number, 1) = sp.letter
WHERE
    N.type = 'P' AND N.number BETWEEN 1 AND LEN(sc.word) AND LEN(sc.word) < 8
GROUP BY
    word
ORDER BY TotalPoints DESC


/* Further concepts to look into */

-- In scrabble you must connect your word from another word. If provided a word, what is the best word you can build using one letter from it?
-- Given certain letters, what words can you create?