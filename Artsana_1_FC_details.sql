USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1_FC_Details]    Script Date: 23-11-2022 12:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----RAW FILES USED
--1) [Artsana].[dbo].[ASM_Level_Classification]
--2) [Artsana].[dbo].[NSM_Level_Classification]
--3) [Artsana].[dbo].[Planner_Level_Classification]
--4) [Artsana].[dbo].[ZSM_Level_Classification]
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


DROP TABLE IF EXISTS #Data_detail_pre
SELECT A.[key],A.[Forecast Number],a.[FC Month],a.[FC Year],a.Region,a.Channel,a.Mapping_Code as [Material_Code],a.[Material Description], A.Category,
(CASE WHEN E.ABC is null THEN 'CZ' ELSE E.ABC END) as [ASM_Class],(case WHEN F.ASP is Null then 0 ELSE F.ASP END) AS ASP,a.[RSM ID],c.RSM,A.[Material Status],
a.YTD_AVG_SALES_Q,a.Avg_12M_Sales_Q,a.Avg_6M_Sales_Q,a.Avg_3M_Sales_Q,a.LM_SALES_Q,a.LYSM1_Q,a.LYSM2_Q,a.LYSM3_Q,
IsNull(G.M1_QTY_3SC,0) AS M1_QTY_3SC , IsNull(G.M2_QTY_3SC,0) AS M2_QTY_3SC , IsNull(g.M3_QTY_3SC,0) AS M3_QTY_3SC , IsNull(g.M4_QTY_3SC,0) AS M4_QTY_3SC , 
IsNull(g.M5_QTY_3SC,0) AS M5_QTY_3SC , IsNull(g.M6_QTY_3SC,0) AS M6_QTY_3SC , IsNull(g.M7_QTY_3SC,0) AS M7_QTY_3SC , IsNull(g.M8_QTY_3SC,0) AS M8_QTY_3SC , 
IsNull(g.M9_QTY_3SC,0) AS M9_QTY_3SC , IsNull(g.M10_QTY_3SC,0) AS M10_QTY_3SC , IsNull(g.M11_QTY_3SC,0) AS M11_QTY_3SC , IsNull(g.M12_QTY_3SC,0) AS M12_QTY_3SC,
0 as M1_Qty,0 as M2_Qty,0 as M3_Qty,0 as M4_Qty,0 as M5_Qty,0 as M6_Qty,0 as M7_Qty,0 as M8_Qty,0 as M9_Qty,0 as M10_Qty,0 as M11_Qty,0 as M12_Qty,a.L12_Min_Q,a.L12_Max_Q,
LM_SALES_Q AS 'M-1',a.[M-2] AS 'M-2', a.[M-3] AS 'M-3',a.LYSM4_Q,a.LYSM5_Q,a.LYSM6_Q, 1 AS Status, a.[Domestic/Import],a.[ABC (Qty)],IsNull(H.AVG_6M_Forecast,0) As AVG_6M_Forecast,a.[Stock Till],
i.[SFA Category] as Sub_Group,I.Line1,i.Line2,i.Line3,i.Line4,
a.[Year-1] as [Year-1_Q],QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,
a.[Year-2]as [Year-2_Q],QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,
a.[Year-3]as [Year-3_Q],QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36,
a.YTD_AVG_SALES_V,a.Avg_12M_Sales_V,a.L12_Max_V,a.L12_Min_V,a.Avg_6M_Sales_V,a.Avg_3M_Sales_V,a.LM_SALES_V,a.LYSM1_V,a.LYSM2_V,a.LYSM3_V,a.LYSM4_V,a.LYSM5_V,a.LYSM6_V,
a.[Year-1]as [Year-1_V],VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,
a.[Year-2]as [Year-2_V],VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,
a.[Year-3]as [Year-3_V],VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36,
A.Category1,ISNULL(East_Cont,0) as East_Cont, ISNULL(North_Cont,0) as North_Cont,ISNULL(South_Cont,0) as South_Cont,
ISNULL(West_Cont,0) as West_Cont ,(CASE WHEN j.ABC is null then'CZ' ELSE j.abc end) as NSM_class,
(case when k.ABC is null then 'CZ' else k.abc end) as ZSM_class,(CASE WHEN d.ABC is null THEN 'CZ' ELSE d.ABC END) as [National_level_class],c.[ZSM UserLoginID],l.[Sequence],
a.Mapping_Code+'_'+c.[ZSM UserLoginID] as [key1]
INTO #Data_detail_pre
FROM Artsana.Test.Data_detail_base A
INNER JOIN Artsana.test.DOA_Final C ON A.[Forecast Number] = c.[Forecast Number]
LEFT JOIN  [Artsana].[dbo].[Planner_Level_Classification] D ON A.Mapping_Code = D.[Material Code]
LEFT JOIN  [Artsana].[dbo].[ASM_Level_Classification] E ON A.Mapping_Code+A.[RSM ID] = E.[Material Code]+E.[RSM ID]
LEFT JOIN Artsana.Test.ASP_long F ON A.Mapping_Code+(case when A.Channel = 'HO' OR A.Channel = 'EX'  Then 'EX' ELSE A.Channel end) = 
										F.[Material Code]+(case when F.Channel = 'HO & EX'  Then 'EX' ELSE F.Channel end)
LEFT JOIN Artsana.dbo.FinalForecast G ON A.[key] = G.DFU
LEFT JOIN #AVG_6M_Forecast H ON a.[key] = h.[Key]
LEFT JOIN #Subcate_line I ON A.[key] =I.[Key]
LEFT JOIN [Artsana].[dbo].[NSM_Level_Classification] J ON A.Mapping_Code+a.Channel = J.[Material Code]+j.Channel
LEFT JOIN [Artsana].[dbo].[ZSM_Level_Classification] K ON A.Mapping_Code+[ZSM UserLoginID] = k.[Material Code]+k.ZSM_ID
LEFT JOIN Artsana.TEST.active_list_Sequence L ON a.Mapping_Code = l.[Material Code]

----Artsana - DATA Detail/ FCDetail END

----Artsana - For Finding SKU with Null value and qty and append below data detail START

DROP TABLE IF EXISTS #Active_MAT_NULL

SELECT [Forecast Number]+'_'+[Material Code] as [key],* INTO #Active_MAT_NULL FROM
(SELECT [Forecast Number],[FC Month],[FC Year],Region,[Material Code],Channel
,[Material Description],[Material Status],Category,Category1,[Domestic/Import]
, ASM_Class = 'CZ',RSM,b.[RSM ID], NSM_class = 'CZ',ZSM_class = 'CZ',[ABC (Qty)], Status = 1,
National_level_class = 'CZ'  FROM (
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 3101 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 3101) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'KA' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 3102 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 3102) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'KA' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 3103 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 3103) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'KA' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 3104 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 3104) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'KA' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 8001 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 8001) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'EBO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 8003 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 8003) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'EBO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 8004 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 8004) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'EBO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 8005 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 8005) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'EBO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 4101 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 4101) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'EC' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 9001 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 9001) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'HO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 9003 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 9003) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'HO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 9004 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 9004) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'HO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 9005 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 9005) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'HO' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 9002 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 9002) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'EX' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 5101 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 5101) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SBT' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 5301 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 5301) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SBT' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 5302 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 5302) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SBT' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 5303 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 5303) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SBT' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 5401 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 5401) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SBT' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 5402 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 5402) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SBT' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 5501 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 5501) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SBT' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6304 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6304) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6401 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6401) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
--SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6307 FROM Artsana.Test.Active_Long a
--LEFT JOIN (
--SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6307) b ON
--a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6501 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6501) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6104 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6104) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
--SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6504 FROM Artsana.Test.Active_Long a
--LEFT JOIN (
--SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6504) b ON
--a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6402 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6402) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6403 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6403) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6101 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6101) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6502 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6502) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6303 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6303) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6305 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6305) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6302 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6302) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6306 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6306) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6301 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6301) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
SELECT a.key1, a.[Material Code],a.channel,a.[Material Description],a.[Material Status],a.Category,a.Category1,a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6503 FROM Artsana.Test.Active_Long a
LEFT JOIN (
SELECT * FROM Artsana.Test.ALL_WORKING_QTY WHERE [RSM ID] = 6503) b ON
a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' 
)t
inner JOIN (
SELECT DISTINCT [Forecast Number],[FC Month],[FC Year],Region,RSM,[RSM ID],[ABC (Qty)] FROM Artsana.Test.ALL_WORKING_QTY) b 
ON t.[RSM ID] = b.[RSM ID] )g

----Artsana - For Finding SKU with Null value and qty and append below data detail END Part - 1

----Artsana - For Finding SKU with Null value and qty and append below data detail START Part - 2

DECLARE @ET AS Date
SELECT @ET = (DATEADD(Month,0,(SELECT TOP 1 CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) FROM Artsana.Test.Sales_Data
									ORDER BY CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)DESC)))

DROP TABLE IF EXISTS #Data_detail_Null
SELECT [key],[Forecast Number],[FC Month],[FC Year],Region,channel,[Material Code] as Material_Code, [Material Description],
Category,ASM_Class,ASP,[RSM ID],RSM,[Material Status],
YTD_AVG_SALES_Q = 0,Avg_12M_Sales_Q = 0,Avg_6M_Sales_Q = 0,Avg_3M_Sales_Q = 0,LM_SALES_Q = 0,LYSM1_Q = 0,LYSM2_Q = 0,LYSM3_Q = 0,
0 AS M1_QTY_3SC , 0 AS M2_QTY_3SC , 0 AS M3_QTY_3SC , 0 AS M4_QTY_3SC , 
0 AS M5_QTY_3SC , 0 AS M6_QTY_3SC , 0 AS M7_QTY_3SC , 0 AS M8_QTY_3SC , 
0 AS M9_QTY_3SC , 0 AS M10_QTY_3SC , 0 AS M11_QTY_3SC , 0 AS M12_QTY_3SC,
0 as M1_Qty,0 as M2_Qty,0 as M3_Qty,0 as M4_Qty,0 as M5_Qty,0 as M6_Qty,0 as M7_Qty,0 as M8_Qty,0 as M9_Qty,0 as M10_Qty,0 as M11_Qty,0 as M12_Qty,
L12_Min_Q = 0,L12_Max_Q = 0,
0 AS 'M-1',0 AS 'M-2', 0 AS 'M-3',LYSM4_Q = 0,LYSM5_Q = 0,LYSM6_Q = 0, [Status],[Domestic/Import],[ABC (Qty)],
0 As AVG_6M_Forecast,0 as [Stock Till], Sub_Group,Line1,Line2,Line3,Line4,
YEAR(DATEADD(Year,-2, @ET)) as [Year-1_Q],QM1= 0,QM2= 0,QM3= 0,QM4= 0,QM5= 0,QM6= 0,QM7= 0,QM8= 0,QM9= 0,QM10= 0,QM11= 0,QM12= 0,
YEAR(DATEADD(Year,-1, @ET)) as [Year-2_Q],QM13= 0,QM14= 0,QM15= 0,QM16= 0,QM17= 0,QM18= 0,QM19= 0,QM20= 0,QM21= 0,QM22= 0,QM23= 0,QM24= 0,
YEAR(DATEADD(Year,0, @ET)) as[Year-3_Q],QM25= 0,QM26= 0,QM27= 0,QM28= 0,QM29= 0,QM30= 0,QM31= 0,QM32= 0,QM33= 0,QM34= 0,QM35= 0,QM36= 0,
YTD_AVG_SALES_V= 0,Avg_12M_Sales_V= 0,L12_Max_V= 0,L12_Min_V= 0,Avg_6M_Sales_V= 0,Avg_3M_Sales_V= 0,LM_SALES_V= 0,LYSM1_V= 0,LYSM2_V= 0,LYSM3_V= 0,LYSM4_V= 0,LYSM5_V= 0,LYSM6_V= 0,
YEAR(DATEADD(Year,-2, @ET)) as [Year-1_V],VM1= 0,VM2= 0,VM3= 0,VM4= 0,VM5= 0,VM6= 0,VM7= 0,VM8= 0,VM9= 0,VM10= 0,VM11= 0,VM12= 0,
YEAR(DATEADD(Year,-1, @ET)) as [Year-2_V],VM13= 0,VM14= 0,VM15= 0,VM16= 0,VM17= 0,VM18= 0,VM19= 0,VM20= 0,VM21= 0,VM22= 0,VM23= 0,VM24= 0,
YEAR(DATEADD(Year,0, @ET)) as [Year-3_V],VM25= 0,VM26= 0,VM27= 0,VM28= 0,VM29= 0,VM30= 0,VM31= 0,VM32= 0,VM33= 0,VM34= 0,VM35= 0,VM36= 0,
Category1,0 as East_Cont, 0 as North_Cont,0 as South_Cont,0 as West_Cont, NSM_class,ZSM_class,National_level_class,
[ZSM UserLoginID],Sequence,key1  
	INTO #Data_detail_Null FROM (
SELECT  t.*,Sub_Group,Line1,Line2,Line3,Line4,d.ASP,e.[ZSM UserLoginID],l.Sequence,
t.[Material Code]+'_'+e.[ZSM UserLoginID] as [key1] FROM #Active_MAT_NULL t
LEFT JOIN( 
SELECT DISTINCT Mapping_Code,FIRST_VALUE([SFA Category]) OVER (Partition by  Mapping_Code ORDER BY  Mapping_Code) as [Sub_Group],
FIRST_VALUE([Line1]) OVER (Partition by  Mapping_Code ORDER BY  Mapping_Code) as Line1,
FIRST_VALUE([Line2]) OVER (Partition by  Mapping_Code ORDER BY  Mapping_Code) as Line2,
FIRST_VALUE([Line3]) OVER (Partition by  Mapping_Code ORDER BY  Mapping_Code) as Line3,
FIRST_VALUE([Line4]) OVER (Partition by  Mapping_Code ORDER BY  Mapping_Code) as Line4 
from Artsana.Test.distributor_sku_wise_data ) C ON t.[Material Code] = c.Mapping_Code
LEFT JOIN Artsana.Test.ASP_long D ON t.[Material Code]+(case when t.Channel = 'HO' OR t.Channel = 'EX'  Then 'EX' ELSE t.Channel end) = 
										D.[Material Code]+(case when D.Channel = 'HO & EX'  Then 'EX' ELSE D.Channel end)
INNER JOIN Artsana.test.DOA_Final E ON T.[Forecast Number] = E.[Forecast Number]
LEFT JOIN Artsana.TEST.active_list_Sequence L ON t.[Material Code] = l.[Material Code])p

----Artsana - For Finding SKU with Null value and qty and append below data detail END Part - 2

----Artsana.Test.Data_detail START

DROP TABLE IF EXISTS Artsana.Test.Data_detail

SELECT * INTO Artsana.Test.Data_detail FROM (
SELECT * FROM #Data_detail_pre
UNION ALL
SELECT * FROM #Data_detail_Null ) a

----Artsana.Test.Data_detail END

----*Artsana - SKU Master START
DROP TABLE IF EXISTS Artsana.test.SKU_Master
SELECT DISTINCT a.Material_Code,b.[Material Description],
a.Channel,b.Category,IsNull(d.ASP,0) as ASP, 1 AS [Status] INTO Artsana.test.SKU_Master FROM Artsana.Test.Data_detail a 
LEFT JOIN #Data_detail_pre b ON  a.Material_Code = b.Material_Code
LEFT JOIN Artsana.Test.ASP_long D ON a.[Material_Code]+(case when a.Channel = 'HO' OR a.Channel = 'EX'  Then 'EX' ELSE a.Channel end) = 
										D.[Material Code]+(case when D.Channel = 'HO & EX'  Then 'EX' ELSE D.Channel end)

----*Artsana - SKU Master START

END
