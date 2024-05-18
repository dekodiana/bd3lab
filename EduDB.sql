Use master
Go
Drop Database if exists EduDB
Go
Create Database EduDB
Go
Use EduDB
GO

CREATE TABLE Teacher (
    ID INT PRIMARY KEY,
    First_Name NVARCHAR(255),
    Last_Name NVARCHAR(255),
    Degree INT
) as Node ;
GO

CREATE TABLE Course (
    ID INT PRIMARY KEY,
    [Name] NVARCHAR(255),
    [Duration] INT,
    Age INT
) as Node;
GO

CREATE TABLE EduInstitution (
    ID INT PRIMARY KEY,
    [Name] NVARCHAR(255),
    [Address] NVARCHAR(255)
) as Node;
GO

CREATE TABLE Replaces AS EDGE;
GO
ALTER TABLE Replaces ADD CONSTRAINT EC_Replaces CONNECTION (Teacher to Teacher);

CREATE TABLE Teaches AS EDGE;
GO
ALTER TABLE Teaches ADD CONSTRAINT EC_Teaches CONNECTION (Teacher to Course);

CREATE TABLE Works AS EDGE;
GO
ALTER TABLE Works ADD CONSTRAINT EC_Belongs CONNECTION (Teacher To EduInstitution);

-- Заполнение таблицы узлов "Teacher"
INSERT INTO Teacher (ID, First_Name, Last_Name, Degree)
VALUES
    (1, 'Willie', 'Stone', 1), -- Willie Stone
    (2, 'Rachel', 'Knight', 2), -- Rachel Knight
    (3, 'Brian', 'Richards', 3), -- Brian Richards
    (4, 'Katie', 'Stanley', 2), -- Katie Stanley
    (5, 'Crystal', 'Rodriguez', 1), -- Crystal Rodriguez
    (6, 'Arlene', 'Luna', 3), -- Arlene Luna
	(7, 'Joseph', 'Stalin', 4), -- Joseph Stalin
	(8, 'Saul', 'Goodman', 2), -- Saul Goodman
    (9, 'Alfred', 'Scott', 1), -- Alfred Scott
    (10, 'Raymond', 'Carter', 3); -- Raymond Carter
GO

-- Заполнение таблицы "Course"
INSERT INTO Course (ID, [Name], [Duration], Age)
VALUES 
    (1, 'Mathematics', 60, 18),
    (2, 'English', 45, 16),
    (3, 'Physics', 75, 17),
    (4, 'Chemistry', 90, 18),
    (5, 'History', 30, 16),
    (6, 'Biology', 60, 17),
    (7, 'Computer Science', 90, 18),
    (8, 'Geography', 45, 16);

-- Заполнение таблицы "EduInstitution"
INSERT INTO EduInstitution (ID, [Name], [Address])
VALUES 
    (1, 'ABC School', '123 Main St'),
    (2, 'XYZ College', '456 Elm St'),
    (3, 'PQR Academy', '789 Oak St'),
    (4, 'MNO Institute', '321 Pine St'),
    (5, 'UVW University', '654 Cedar St'),
    (6, 'DEF Academy', '987 Maple St');


INSERT INTO Replaces ($from_id, $to_id)
VALUES 
((Select $node_id From Teacher Where id = 1), (Select $node_id From Teacher Where id = 2)),
((Select $node_id From Teacher Where id = 2), (Select $node_id From Teacher Where id = 3)),
((Select $node_id From Teacher Where id = 5), (Select $node_id From Teacher Where id = 3)),
((Select $node_id From Teacher Where id = 3), (Select $node_id From Teacher Where id = 4)),
((Select $node_id From Teacher Where id = 4), (Select $node_id From Teacher Where id = 5)),
((Select $node_id From Teacher Where id = 7), (Select $node_id From Teacher Where id = 4)),
((Select $node_id From Teacher Where id = 6), (Select $node_id From Teacher Where id = 7)),
((Select $node_id From Teacher Where id = 8), (Select $node_id From Teacher Where id = 3)),
((Select $node_id From Teacher Where id = 9), (Select $node_id From Teacher Where id = 8));
go


INSERT INTO Teaches ($from_id, $to_id)
VALUES 
    ((SELECT $node_id FROM Teacher WHERE ID = 1), (SELECT $node_id FROM Course WHERE ID = 3)),
    ((SELECT $node_id FROM Teacher WHERE ID = 1), (SELECT $node_id FROM Course WHERE ID = 2)),
    ((SELECT $node_id FROM Teacher WHERE ID = 2), (SELECT $node_id FROM Course WHERE ID = 3)),
    ((SELECT $node_id FROM Teacher WHERE ID = 3), (SELECT $node_id FROM Course WHERE ID = 4)),
    ((SELECT $node_id FROM Teacher WHERE ID = 4), (SELECT $node_id FROM Course WHERE ID = 5)),
    ((SELECT $node_id FROM Teacher WHERE ID = 5), (SELECT $node_id FROM Course WHERE ID = 6)),
    ((SELECT $node_id FROM Teacher WHERE ID = 6), (SELECT $node_id FROM Course WHERE ID = 7)),
    ((SELECT $node_id FROM Teacher WHERE ID = 1), (SELECT $node_id FROM Course WHERE ID = 8)),
    ((SELECT $node_id FROM Teacher WHERE ID = 2), (SELECT $node_id FROM Course WHERE ID = 1)),
    ((SELECT $node_id FROM Teacher WHERE ID = 3),(SELECT $node_id FROM Course WHERE ID = 2));


INSERT INTO Works ($from_id, $to_id)
VALUES 
((Select $node_id From Teacher Where id = 1), (Select $node_id From EduInstitution Where id = 6)),
((Select $node_id From Teacher Where id = 2), (Select $node_id From EduInstitution Where id = 4)),
((Select $node_id From Teacher Where id = 3), (Select $node_id From EduInstitution Where id = 5)),
((Select $node_id From Teacher Where id = 4), (Select $node_id From EduInstitution Where id = 3)),
((Select $node_id From Teacher Where id = 5), (Select $node_id From EduInstitution Where id = 5)),
((Select $node_id From Teacher Where id = 6), (Select $node_id From EduInstitution Where id = 2)),
((Select $node_id From Teacher Where id = 7), (Select $node_id From EduInstitution Where id = 6)),
((Select $node_id From Teacher Where id = 8), (Select $node_id From EduInstitution Where id = 3)),
((Select $node_id From Teacher Where id = 9), (Select $node_id From EduInstitution Where id = 6)),
((Select $node_id From Teacher Where id = 10), (Select $node_id From EduInstitution  Where id = 1));
go

-- Найти всех учителей, которых заменял учитель Rachel Knight:
SELECT T1.First_Name AS [Teacher],
       T2.First_Name AS [Replaces]
FROM Teacher AS T1, Replaces as R, Teacher AS T2
WHERE Match(T1-(R)->T2)
	  And T1.First_Name = N'Rachel'
	  and T1.Last_Name = N'Knight'
GO

-- Найти всех учителей учебного заведения DEF Academy:
Select T.First_Name, T.Last_Name
From Teacher as T
	 , Works as W
	 , EduInstitution as EI
Where Match(T-(W)->EI)
	  And EI.[Name] = N'DEF Academy'  
Go

-- Найти всех учителей, преподающих Physics:
Select T.First_Name, T.Last_Name
From Teacher as T
	 , Teaches
	 , Course as C
Where Match(T-(Teaches)->C)
	  And C.[Name] = N'Physics' 
Go


-- Найти все учебные заведения, где работает Joseph Stalin:
SELECT EI.[Name] as [Educational Institution]
FROM Teacher as T
	 , Works as W
	 , EduInstitution as EI
WHERE T.First_Name = N'Joseph'
	  and MATCH(T-(W)->EI)
GO

-- Учебное заведение и курс преподавателя Willie Stone
select  T.First_name, T.Last_name, EI.[Name] as [Educational Institution], C.[Name] as [Course]
from Teacher as T
	 , Works as W
	 , EduInstitution as EI
	 , Teaches
	 , Course as C
where T.First_Name = 'Willie'
and MATCH(T-(Teaches)->C)
and MATCH(T-(W)->EI)

-- Поиск кратчайшего пути замены между двумя учителями (используя "+"):

SELECT T1.First_Name
, STRING_AGG(T2.First_Name, '->') WITHIN GROUP (GRAPH PATH) AS
Replaces
FROM Teacher AS T1
, Replaces FOR PATH AS R
, Teacher FOR PATH AS T2
WHERE MATCH(SHORTEST_PATH(T1(-(R)->T2)+))
AND T1.First_Name = N'Katie';

--Поиск кратчайшего пути между учителями, где количество ребер не превышает 2 (используя "{1,n}"): 

SELECT T1.First_Name
, STRING_AGG(T2.First_Name, '->') WITHIN GROUP (GRAPH PATH) AS
Replaces
FROM Teacher AS T1
, Replaces FOR PATH AS R
, Teacher FOR PATH AS T2
WHERE MATCH(SHORTEST_PATH(T1(-(R)->T2){1,2}))
AND T1.First_Name = N'Katie';
