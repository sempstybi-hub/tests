USE LibraryDB
GO

CREATE TABLE BookReservations ( 
	ReservationID INT IDENTITY(1,1) PRIMARY KEY, 
	BookID INT NOT NULL, 
	ReaderID INT NOT NULL, 
	ReservationDate DATE NOT NULL DEFAULT GETDATE(), 
	Status NVARCHAR(20) NOT NULL DEFAULT 'Active', 
	CONSTRAINT FK_Reservations_Books FOREIGN KEY (BookID) 
	REFERENCES Books(BookID), 
	CONSTRAINT FK_Reservations_Readers FOREIGN KEY (ReaderID) 
	REFERENCES Readers(ReaderID) 
);
GO

INSERT INTO BookReservations ( BookID, ReaderID, ReservationDate, Status)
VALUES
	(1, 1, '2025-09-14', 'Returned'),
	(2, 2, '2024-12-25', 'Active'),
	(3, 3, '2026-05-22', 'Active');
GO

INSERT INTO BookReservations ( BookID, ReaderID, ReservationDate, Status)
VALUES
	(2, 3, '2021-02-23', 'Active'),
	(3, 2, '2024-10-01', 'Active'),
	(1, 3, '2026-04-08', 'Returned');
GO

BACKUP DATABASE [LibraryDB]
TO DISK = N'C:\Verb\Backup\BackupLibraryDB_Diff.bak'
WITH DIFFERENTIAL, NAME = N'LibraryDB-Diff Backup', STATS = 10;
GO

DROP TABLE BookReservations
GO

BACKUP LOG [LibraryDB]
TO DISK = N'C:\Verb\Backup\LibraryDB_Log.trn'
WITH NAME = N'LibraryDB-Log Backup', STATS = 10;
GO



USE master;
GO

ALTER DATABASE [LibraryDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

BACKUP LOG [LibraryDB]
TO DISK = N'C:\Verb\Backup\LibraryDB_TailLog.trn'
WITH NORECOVERY, NAME = N'LibraryDB-Tail Log Backup';
GO

RESTORE DATABASE [LibraryDB]
FROM DISK = N'C:\Verb\Backup\LibraryDB_Full.bak'
WITH REPLACE, NORECOVERY;
GO

RESTORE DATABASE [LibraryDB]
FROM DISK = N'C:\Verb\Backup\BackupLibraryDB_Diff.bak'
WITH NORECOVERY;
GO

RESTORE LOG [LibraryDB]
FROM DISK = N'C:\Verb\Backup\LibraryDB_Log.trn'
WITH RECOVERY;
GO

USE LibraryDB;
GO

SELECT COUNT(*) AS ReservationCount FROM BookReservations;
GO