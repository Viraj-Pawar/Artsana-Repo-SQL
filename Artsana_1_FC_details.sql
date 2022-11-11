USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1_Model_Input]    Script Date: 09-11-2022 10:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----RAW FILES USED
--1) Artsana.test.DOA_RAW
--2) 
--3) 
--4) 
--5) 

ALTER PROCEDURE [Test].[Artsana_1_FC_Details]
----EXEC  [Test].[Artsana_1_FC_Details]
AS
BEGIN

SELECT A.Category,a.Channel,a.Mapping_Code as [Material_Code],a.[RSM ID]
QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36 
FROM Artsana.Test.ALL_WORKING_QTY A
INNER JOIN Artsana.Test.ALL_WORKING_Value B ON A.[key] = b.[key]



END

