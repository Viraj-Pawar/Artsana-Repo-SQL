USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1_Model_Input]    Script Date: 09-11-2022 10:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----RAW FILES USED
--1) Artsana.test.ASM_level_Class
--2) Artsana.test.NSM_level_Class
--3) Artsana.test.Planner_level_Class
--4) Artsana.test.ZSM_level_Class
--5) 

ALTER PROCEDURE [Test].[Artsana_1_FC_Details]
----EXEC  [Test].[Artsana_1_FC_Details]
AS
BEGIN

----19054
SELECT SUM(Avg_12M_Sales) FROM (
SELECT A.[key],A.[Forecast Number],a.[FC Month],a.[FC Year],a.Region,a.Channel,a.Mapping_Code as [Material_Code],a.[Material Description], A.Category,a.[RSM ID],c.RSM,
(CASE WHEN E.ABC is null THEN 'CZ' ELSE E.ABC END) as [ASM_Class],A.[Material Status],
(CASE WHEN d.ABC is null THEN 'CZ' ELSE d.ABC END) as [Planner_class],(case WHEN F.ASP is Null then 0 ELSE F.ASP END) AS ASP,
AVG (QM27+QM28+QM29+QM30+QM31+QM32+QM33+QM34+QM35+QM36) AS Avg_12M_Sales,
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36,
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36

FROM Artsana.Test.ALL_WORKING_QTY A
INNER JOIN Artsana.Test.ALL_WORKING_Value B ON A.[key] = b.[key]
INNER JOIN Artsana.test.DOA_Final C ON A.[Forecast Number] = c.[Forecast Number]
LEFT JOIN  Artsana.test.Planner_level_Class D ON A.Mapping_Code = D.[Material Code]
LEFT JOIN  Artsana.test.ASM_level_Class E ON A.Mapping_Code+A.[RSM ID] = E.[Material Code]+E.[RSM ID]
LEFT JOIN Artsana.Test.ASP_long F ON A.Mapping_Code+(case when A.Channel = 'HO' OR A.Channel = 'EX'  Then 'EX' ELSE A.Channel end) = 
F.[Material Code]+(case when F.Channel = 'HO & EX'  Then 'EX' ELSE F.Channel end)
GROUP BY
A.[key],A.[Forecast Number],a.[FC Month],a.[FC Year],a.Region,a.Channel,a.Mapping_Code ,a.[Material Description], A.Category,a.[RSM ID],c.RSM,
(CASE WHEN E.ABC is null THEN 'CZ' ELSE E.ABC END) ,A.[Material Status],
(CASE WHEN d.ABC is null THEN 'CZ' ELSE d.ABC END) ,(case WHEN F.ASP is Null then 0 ELSE F.ASP END) ,
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36,
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36)a


SELECT * FROM Artsana.Test.ALL_WORKING_QTY


SELECT* FrOM Artsana.Test.Distributor_SKU_Wise_Data WHERE Channel ='EC'

SELECT * FRoM Artsana.Test.Active_Long where Channel = 'EC'



END

SELECT SUM(LYSM3_Sales) FROM Artsana.dbo.FinalForecast
SeleCT * FROM  Artsana.test.ASM_level_Class
SeleCT * FROM  Artsana.test.NSM_level_Class
SeleCT * FROM  Artsana.test.Planner_level_Class
SeleCT * FROM  Artsana.test.ZSM_level_Class