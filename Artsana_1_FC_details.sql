USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1_FC_Details]    Script Date: 14-11-2022 13:59:43 ******/
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



----* for Avg_6M_forecast Start
DROP TABLE IF EXISTS #AVG_6M_Forecast
SELECT  DFU AS [Key],(M1_QTY_3SC+M2_QTY_3SC+M3_QTY_3SC+M4_QTY_3SC+M5_QTY_3SC+M6_QTY_3SC)/6 as AVG_6M_Forecast 
into #AVG_6M_Forecast  FROM Dbo.FinalForecast

----* for Avg_6M_forecast END

DROP TABLE IF EXISTS #Subcate_line
SELECT DISTINCT [Key],FIRST_VALUE([SFA Category]) OVER (Partition by  [key] ORDER BY  [key]) as [SFA Category],
FIRST_VALUE([Line1]) OVER (Partition by  [key] ORDER BY  [key]) as Line1,
FIRST_VALUE([Line2]) OVER (Partition by  [key] ORDER BY  [key]) as Line2,
FIRST_VALUE([Line3]) OVER (Partition by  [key] ORDER BY  [key]) as Line3,
FIRST_VALUE([Line4]) OVER (Partition by  [key] ORDER BY  [key]) as Line4 
INTO #Subcate_line FROM Artsana.Test.Distributor_SKU_Wise_Data

----Artsana - DATA Detail/ FCDetail Start


DROP TABLE IF EXISTS Artsana.Test.Data_detail
SELECT A.[key],A.[Forecast Number],a.[FC Month],a.[FC Year],a.Region,a.Channel,a.Mapping_Code as [Material_Code],a.[Material Description], A.Category,
(CASE WHEN E.ABC is null THEN 'CZ' ELSE E.ABC END) as [ASM_Class],(case WHEN F.ASP is Null then 0 ELSE F.ASP END) AS ASP,a.[RSM ID],c.RSM,A.[Material Status],
a.YTD_AVG_SALES_Q,a.Avg_12M_Sales_Q,a.Avg_6M_Sales_Q,a.Avg_3M_Sales_Q,a.LM_SALES_Q,a.LYSM1_Q,a.LYSM2_Q,a.LYSM3_Q,
IsNull(G.M1_QTY_3SC,0) AS M1_QTY_3SC , IsNull(G.M2_QTY_3SC,0) AS M2_QTY_3SC , IsNull(g.M3_QTY_3SC,0) AS M3_QTY_3SC , IsNull(g.M4_QTY_3SC,0) AS M4_QTY_3SC , 
IsNull(g.M5_QTY_3SC,0) AS M5_QTY_3SC , IsNull(g.M6_QTY_3SC,0) AS M6_QTY_3SC , IsNull(g.M7_QTY_3SC,0) AS M7_QTY_3SC , IsNull(g.M8_QTY_3SC,0) AS M8_QTY_3SC , 
IsNull(g.M9_QTY_3SC,0) AS M9_QTY_3SC , IsNull(g.M10_QTY_3SC,0) AS M10_QTY_3SC , IsNull(g.M11_QTY_3SC,0) AS M11_QTY_3SC , IsNull(g.M12_QTY_3SC,0) AS M12_QTY_3SC,
0 as M1_Qty,0 as M2_Qty,0 as M3_Qty,0 as M4_Qty,0 as M5_Qty,0 as M6_Qty,0 as M7_Qty,0 as M8_Qty,0 as M9_Qty,0 as M10_Qty,0 as M11_Qty,0 as M12_Qty,a.L12_Min_Q,a.L12_Max_Q,
QM36 AS 'M-1',QM35 AS 'M-2', QM34 AS 'M-3', 1 AS Status, a.[Domestic/Import],a.[ABC (Qty)],IsNull(H.AVG_6M_Forecast,0) As AVG_6M_Forecast,'x' as Stock_Till,
i.[SFA Category] as Sub_Group,I.Line1,i.Line2,i.Line3,i.Line4,
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36,
a.YTD_AVG_SALES_V,a.Avg_12M_Sales_V,a.Avg_6M_Sales_V,a.Avg_3M_Sales_V,a.LM_SALES_V,a.LYSM1_V,a.LYSM2_V,a.LYSM3_V,a.LYSM4_V,a.LYSM5_V,a.LYSM6_V,
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36,
A.Category1,0 as East_Cont, 0 as North_Cont,0 as South_Cont,0 as West_Cont,(CASE WHEN j.ABC is null then'CZ' ELSE j.abc end) as NSM_class,
(case when k.ABC is null then 'CZ' else k.abc end) as ZSM_class,(CASE WHEN d.ABC is null THEN 'CZ' ELSE d.ABC END) as [National_level_class],c.[ZSM UserLoginID],l.[Sequence],
a.Mapping_Code+'_'+c.[ZSM UserLoginID] as [key1], 325 As Active_code_count
INTO Artsana.Test.Data_detail
FROM Artsana.Test.Data_detail_base A
INNER JOIN Artsana.test.DOA_Final C ON A.[Forecast Number] = c.[Forecast Number]
LEFT JOIN  Artsana.test.Planner_level_Class D ON A.Mapping_Code = D.[Material Code]
LEFT JOIN  Artsana.test.ASM_level_Class E ON A.Mapping_Code+A.[RSM ID] = E.[Material Code]+E.[RSM ID]
LEFT JOIN Artsana.Test.ASP_long F ON A.Mapping_Code+(case when A.Channel = 'HO' OR A.Channel = 'EX'  Then 'EX' ELSE A.Channel end) = 
										F.[Material Code]+(case when F.Channel = 'HO & EX'  Then 'EX' ELSE F.Channel end)
LEFT JOIN Artsana.dbo.FinalForecast G ON A.[key] = G.DFU
LEFT JOIN #AVG_6M_Forecast H ON a.[key] = h.[Key]
LEFT JOIN #Subcate_line I ON A.[key] =I.[Key]
LEFT JOIN Artsana.test.NSM_level_Class J ON A.Mapping_Code+a.Channel = J.[Material Code]+j.Channel
LEFT JOIN Artsana.test.ZSM_level_Class K ON A.Mapping_Code+[ZSM UserLoginID] = k.[Material Code]+k.ZSM_ID
LEFT JOIN Artsana.TEST.active_list_Sequence L ON a.Mapping_Code = l.[Material Code]

----Artsana - DATA Detail/ FCDetail END

----remaining calculations
	--1. Stock_Till
	--2. 0 as East_Cont, 0 as North_Cont,0 as South_Cont,0 as West_Cont

END

