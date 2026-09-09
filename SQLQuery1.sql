USE LibraryDB
Go

Create Table Readers (
	ReaderID INT IDENTITY(1, 1) PRIMARY KEY,
	LastName NVARCHAR(50) NOT NULL,
	FerstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50) NOT NULL,
	BirdDate DATE NOT NULL,
	Address NVARCHAR(200) NOT NULL,
	Phone NVARCHAR(20) NOT NULL,
	Email NVARCHAR(100) UNIQUE,
	RegistrationDate DATE NOT NULL DEFAULT GETDATE()
);
GO

Create Table Books (
	BookID INT IDENTITY(1, 1) PRIMARY KEY,
	Title NVARCHAR(200) NOT NULL,
	Author NVARCHAR(100) NOT NULL,
	Genre NVARCHAR(50) NOT NULL,
	YerPublished INT NOT NULL CHECK (YerPublished > 1800),
	Publisher NVARCHAR(100) NOT NULL,
	TotalCopies INT NOT NULL CHECK (TotalCopies > 0),
	AvailableCopies INT NOT NULL CHECK (AvailableCopies >= 0)
);
GO

Create Table BookLoans (
	LoanID INT IDENTITY(1, 1) PRIMARY KEY,
	ReaderID INT NOT NULL,
	BookID INT NOT NULL,
	LoanDate DATE NOT NULL,
	DueDate DATE NOT NULL,
	ReturnDate DATE NULL,
	Status NVARCHAR(20) NOT NULL DEFAULT 'Active',
	CONSTRAINT FK_BookLoans_Readers FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
	CONSTRAINT FK_BookLoans_Books FOREIGN KEY (BookID) REFERENCES Books(BookID),
	CONSTRAINT CHK_DueDate CHECK (DueDate >= LoanDate),
	CONSTRAINT CHK_Status CHECK (Status IN ('Active', 'Overdue', 'Returned'))
);
GO

Create Table Genres (
	GenresID INT IDENTITY(1, 1) PRIMARY KEY,
	GenreName NVARCHAR(50) NOT NULL UNIQUE,
	Description NVARCHAR(200) NULL
);
GO

-- 2 часть --
INSERT INTO Readers (LastName, FerstName, MiddleName, BirdDate, Address, Phone, Email)
VALUES
	(N'Иванов', N'Сергей', N'Александрович', '1990-05-15', N'Ул. Ленина, д. 10, кв. 5', '+7-900-111-1111', 'ivanov_s@mail.ru'),
	(N'Петрова', N'Анна', N'Михайловна', '1988-08-22', N'Ул. Пушкина, д. 25, кв. 12', '+7-900-222-2222', 'petrova_s@mail.ru'),
	(N'Сидоров', N'Дмитрий', N'Игоровеч', '1995-11-03', N'Ул. Совецкая, д. 3, кв. 8', '+7-900-333-3333', 'sidorov_s@mail.ru'),
	(N'Козлова', N'Екатерина', N'Андреевна', '1992-02-18', N'Ул. Мира, д. 15, кв. 45', '+7-900-444-4444', 'kozlova_s@mail.ru'),
	(N'Смирнов', N'Алексей', N'Николаевич', '1985-09-10', N'Ул. Гагарина, д. 7, кв. 3', '+7-900-555-5555', 'smirnov_s@mail.ru');
GO

INSERT INTO Books (Title, Author, Genre, YerPublished, Publisher, TotalCopies, AvailableCopies)
VALUES
	(N'Война и мир', N'Лев Толстой', N'Роман', 1869, N'Русский вестник', 5, 3),
	(N'Преступлени и наказание', N'Федор Достоевский', N'Роман', 1866, N'Русский вестник', 4, 2),
	(N'Мастер и Маргарита', N'Михаил Булгаков', N'Роман', 1967, N'Художественая литература', 3, 1),
	(N'Гари Потер и филосовский камень', N'Джоан Роулинг', N'Фентази', 1997, N'Росмэн', 7, 5),
	(N'Властелин колец', N'Джон Рональд Руэл Толкин', N'Фентази', 1954, N'АСТ', 4, 2),
	(N'Идиот', N'Федор Достоевский', N'Роман', 1869, N'Русский вестник', 3, 1);
GO

INSERT INTO BookLoans (ReaderID, BookID, LoanDate, DueDate, Status)
VALUES
	(1, 1, '2025-09-01', '2025-09-15', 'Returned'),
	(1, 3, '2025-09-10', '2025-09-24', 'Active'),
	(2, 2, '2025-09-05', '2025-09-19', 'Returned'),
	(3, 4, '2025-09-12', '2025-09-26', 'Active'),
	(3, 5, '2025-09-15', '2025-09-29', 'Active'),
	(4, 6, '2025-09-08', '2025-09-22', 'Overdue'),
	(5, 1, '2025-09-14', '2025-09-28', 'Active');
GO

INSERT INTO Genres (GenreName, Description)
VALUES
	(N'Роман', N'Литературный жанр, описывающий жизнь и внутрений мир персонажей'),
	(N'Фентази', N'Жанр, основаный на использовании мифологических и сказочных мотивов'),
	(N'Детектив', N'Жанр, описывающий раследование преступлений'),
	(N'Научная фантастика', N'Жанр, описывающий вымышленые технологии и будущее');
GO

-- 3 часть --
-- проверка количества --
SELECT 'Readers' AS TableName, COUNT(*) AS RowCounts FROM Readers
UNION ALL
SELECT 'Books', COUNT(*) FROM Books
UNION ALL
SELECT 'BookLoans', COUNT(*) FROM BookLoans
UNION ALL
SELECT 'Genres', COUNT(*) FROM Genres;
GO

-- Вывод сводной инфы окнигах --
SELECT
	b.Title AS BookTitle,
	b.Author AS Author,
	b.Genre,
	b.TotalCopies AS [Total Copies],
	b.AvailableCopies AS [Available Copies],
	COUNT(bl.LoanID) AS [Available Loans]
FROM Books b
LEFT JOIN BookLoans bl ON b.BookID = bl.BookID AND bl.Status IN ('Active', 'Overdue')
GROUP BY b.BookID, b.Title, b.Author, b.Genre, b.TotalCopies, b.AvailableCopies
ORDER BY b.Title;
GO

-- Инфа по долгам --
SELECT
	r.LastName + ' ' + r.FerstName AS ReaderName,
	b.Title AS BookTitle,
	bl.LoanDate,
	bl.DueDate,
	bl.Status
FROM BookLoans bl
JOIN Readers r ON bl.ReaderID = r.ReaderID
JOIN Books b ON bl.BookID = b.BookID
WHERE bl.Status IN ('Active', 'Overdue')
ORDER BY bl.DueDate;
GO

ALTER DATABASE [LibraryDB] SET RECOVERY FULL;
GO

SELECT name, recovery_model_desc FROM sys.databases WHERE name = '[LibraryDB]';
GO

USE LibraryDB;
GO

CREATE USER LibratianUser FOR LOGIN LibratianUser;
GO

ALTER ROLE db_datareader ADD MEMBER LibratianUser;
GO

GRANT INSERT, UPDATE ON books TO LibratianUser;
GRANT INSERT, UPDATE ON BookLoans TO LibratianUser;
GO

DENY DELETE ON Readers TO LibratianUser;
DENY DELETE ON Books TO LibratianUser;
DENY DELETE ON BookLoans TO LibratianUser;
GO

EXEC sp_helpuser 'LibratianUser';
GO

INSERT INTO BookLoans (ReaderID, BookID, LoanDate, DueDate, Status)
VALUES (2, 3, '2025-09-16', '2025-09-30', 'Active');
GO

BACKUP LOG [LibraryDB]
TO DISK = N'C:\Users\STUDENT\Documents\03-1ИСП24\Backup\LibraryDB_Log.trn'
WITH NAME = N'LibraryDB-Log Backup', STATS = 10;
GO

BACKUP DATABASE [LibraryDB]
TO DISK = N'C:\Users\STUDENT\Documents\03-1ИСП24\Backup\LibraryDB_Diff.bak'
WITH DIFFERENTIAL, NAME = N'LibraryDB-Diff Backup', STATS = 10;


SELECT 
	database_name,
	CASE b.type
		WHEN 'D' THEN 'Full'
		WHEN 'I' THEN 'Differential'
		WHEN 'L' THEN 'Transaction Log'
		ELSE b.type
	END AS BackupType,
	backup_start_date,
	backup_finish_date,
	physical_device_name
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily f ON b.media_set_id = f.media_set_id
WHERE database_name = 'LibraryDB'
ORDER BY backup_start_date DESC;
GO

USE master;
GO

SELECT
	name AS DatabaseName,
	recovery_model_desc AS RecoveryModel,
	state_desc AS
