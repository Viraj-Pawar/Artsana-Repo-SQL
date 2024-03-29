USE [Artsana]
GO
/****** Object:  StoredProcedure [FAR].[Artsana_1_FC_Details]    Script Date: 29-03-2023 17:55:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----RAW FILES USED
--1) [Artsana].[dbo].[ASM_Level_Classification]
--2) [Artsana].[dbo].[NSM_Level_Classification]
--3) [Artsana].[dbo].[Planner_Level_Classification]
--4) [Artsana].[dbo].[ZSM_Level_Classification]
--5) [Artsana].[dbo].FinalForecast

ALTER PROCEDURE [FAR].[Artsana_1_FC_Details]
----EXEC  [FAR].[Artsana_1_FC_Details]
AS
BEGIN



    ----* for Avg_6M_forecast Start
    DROP TABLE IF EXISTS #AVG_6M_Forecast
    SELECT DFU AS [Key], (M1_QTY_3SC+M2_QTY_3SC+M3_QTY_3SC+M4_QTY_3SC+M5_QTY_3SC+M6_QTY_3SC)/6 as AVG_6M_Forecast
    into #AVG_6M_Forecast
    FROM Artsana.Dbo.FinalForecast

    ----* for Avg_6M_forecast END

    DROP TABLE IF EXISTS #Subcate_line
    SELECT DISTINCT [Mat Code], (CASE WHEN [SFA Sub Cat] = '0' THEN '' ELSE [SFA Sub Cat] END) as [SFA Category], (CASE WHEN Line1 = '0' THEN ''ELSE [Line1] END) as Line1,
	(CASE WHEN Line2 = '0' THEN ''ELSE [Line2] END) as Line2,(CASE WHEN Line3 = '0' THEN ''ELSE [Line3] END) as Line3, (CASE WHEN Line4 = '0' THEN ''ELSE [Line4] END) as Line4, Category,[Category 1], [Material Description]
    INTO #Subcate_line
    FROM Artsana.FAR.SKU_Artsana


    ----Artsana - DATA Detail/ FCDetail Start


    DROP TABLE IF EXISTS #Data_detail_pre
    SELECT A.[key], A.[Forecast Number], a.[FC Month], a.[FC Year], a.Region, a.Channel, a.Mapping_Code as [Material_Code], i.[Material Description],
		(CASE WHEN L.[Category ] is null THEN i.Category ELSE L.[Category ] END) As Category,
        (CASE WHEN D.ABC ='NP' AND E.ABC is null THEN 'NP' WHEN E.ABC is null THEN 'CZ' ELSE E.ABC END) as [ASM_Class]
		, (case WHEN F.ASP is Null then 0 ELSE F.ASP END) AS ASP, a.[RSM ID], c.RSM, A.[Material Status],
        a.YTD_AVG_SALES_Q, a.Avg_12M_Sales_Q, a.Avg_6M_Sales_Q, a.Avg_3M_Sales_Q, a.LM_SALES_Q, a.LYSM1_Q, a.LYSM2_Q, a.LYSM3_Q,
        IsNull(G.M1_QTY_3SC,0) AS M1_QTY_3SC , IsNull(G.M2_QTY_3SC,0) AS M2_QTY_3SC , IsNull(g.M3_QTY_3SC,0) AS M3_QTY_3SC , IsNull(g.M4_QTY_3SC,0) AS M4_QTY_3SC ,
        IsNull(g.M5_QTY_3SC,0) AS M5_QTY_3SC , IsNull(g.M6_QTY_3SC,0) AS M6_QTY_3SC , IsNull(g.M7_QTY_3SC,0) AS M7_QTY_3SC , IsNull(g.M8_QTY_3SC,0) AS M8_QTY_3SC ,
        IsNull(g.M9_QTY_3SC,0) AS M9_QTY_3SC , IsNull(g.M10_QTY_3SC,0) AS M10_QTY_3SC , IsNull(g.M11_QTY_3SC,0) AS M11_QTY_3SC , IsNull(g.M12_QTY_3SC,0) AS M12_QTY_3SC,
        0 as M1_Qty, 0 as M2_Qty, 0 as M3_Qty, 0 as M4_Qty, 0 as M5_Qty, 0 as M6_Qty, 0 as M7_Qty, 0 as M8_Qty, 0 as M9_Qty, 0 as M10_Qty, 0 as M11_Qty, 0 as M12_Qty, a.L12_Min_Q, a.L12_Max_Q,
        LM_SALES_Q AS 'M-1', a.[M-2] AS 'M-2', a.[M-3] AS 'M-3', a.LYSM4_Q, a.LYSM5_Q, a.LYSM6_Q, (CASE WHEN l.[Sequence] is not null then 1 else 0 end) AS Status, a.[Domestic/Import], a.[ABC (Qty)], IsNull(H.AVG_6M_Forecast,0) As AVG_6M_Forecast, 
		COALESCE(CONCAT(DATENAME(MONTH, a.[stock till]),' ' , YEAR(a.[stock till])), '') AS [Stock Till],
        i.[SFA Category] as Sub_Group, I.Line1, i.Line2, i.Line3, i.Line4,
        a.[Year-1] as [Year-1_Q], QM1, QM2, QM3, QM4, QM5, QM6, QM7, QM8, QM9, QM10, QM11, QM12,
        a.[Year-2]as [Year-2_Q], QM13, QM14, QM15, QM16, QM17, QM18, QM19, QM20, QM21, QM22, QM23, QM24,
        a.[Year-3]as [Year-3_Q], QM25, QM26, QM27, QM28, QM29, QM30, QM31, QM32, QM33, QM34, QM35, QM36,
        a.YTD_AVG_SALES_V, a.Avg_12M_Sales_V, a.L12_Max_V, a.L12_Min_V, a.Avg_6M_Sales_V, a.Avg_3M_Sales_V, a.LM_SALES_V, a.LYSM1_V, a.LYSM2_V, a.LYSM3_V, a.LYSM4_V, a.LYSM5_V, a.LYSM6_V,
        a.[Year-1]as [Year-1_V], VM1, VM2, VM3, VM4, VM5, VM6, VM7, VM8, VM9, VM10, VM11, VM12,
        a.[Year-2]as [Year-2_V], VM13, VM14, VM15, VM16, VM17, VM18, VM19, VM20, VM21, VM22, VM23, VM24,
        a.[Year-3]as [Year-3_V], VM25, VM26, VM27, VM28, VM29, VM30, VM31, VM32, VM33, VM34, VM35, VM36,
        (CASE WHEN I.[Category 1] is NULL  THEN A.[Category 1] ELSE I.[Category 1] END) as [Category 1],
        ISNULL(East_Cont,0) as East_Cont, ISNULL(North_Cont,0) as North_Cont, ISNULL(South_Cont,0) as South_Cont,
        ISNULL(West_Cont,0) as West_Cont , (CASE WHEN D.ABC ='NP' AND j.ABC is null then'NP' WHEN j.ABC is null then'CZ' ELSE j.abc end) as NSM_class,
        (case when D.ABC ='NP' AND k.ABC is null then 'NP' WHEN k.ABC is null then 'CZ' else k.abc end) as ZSM_class, (CASE WHEN d.ABC is null THEN 'CZ' ELSE d.ABC END) as [National_level_class], c.[ZSM UserLoginID], l.[Sequence],
        a.Mapping_Code+'_'+c.[ZSM UserLoginID] as [key1]
    INTO #Data_detail_pre
    FROM Artsana.FAR.Data_detail_base A
        INNER JOIN Artsana.FAR.DOA_Final C ON A.[Forecast Number] = c.[Forecast Number]
        LEFT JOIN [Artsana].[dbo].[Planner_Level_Classification] D ON A.Mapping_Code = D.[Material Code]
        LEFT JOIN [Artsana].[dbo].[ASM_Level_Classification] E ON A.Mapping_Code+A.[RSM ID] = E.[Material Code]+E.[RSM ID]
        LEFT JOIN Artsana.FAR.ASP_long F ON A.Mapping_Code+(case when A.Channel = 'HO' OR A.Channel = 'EX'  Then 'EX' ELSE A.Channel end) = 
										F.[Material Code]+(case when F.Channel = 'HO & EX'  Then 'EX' ELSE F.Channel end)
        LEFT JOIN Artsana.dbo.FinalForecast G ON A.[key] = G.DFU
        LEFT JOIN #AVG_6M_Forecast H ON a.[key] = h.[Key]
        LEFT JOIN #Subcate_line I ON A.Mapping_Code =I.[Mat Code]
        LEFT JOIN [Artsana].[dbo].[NSM_Level_Classification] J ON A.Mapping_Code+a.Channel = J.[Material Code]+j.Channel
        LEFT JOIN [Artsana].[dbo].[ZSM_Level_Classification] K ON A.Mapping_Code+[ZSM UserLoginID] = k.[Material Code]+k.ZSM_ID
        LEFT JOIN Artsana.FAR.active_long L ON a.Mapping_Code+'_'+a.Channel = l.[Key1]


    ----Artsana - DATA Detail/ FCDetail END

    ----Artsana - For Finding SKU with Null value and qty and append below data detail START

    DROP TABLE IF EXISTS #Active_MAT_NULL

    SELECT [Forecast Number]+'_'+[Material Code] as [key], *
    INTO #Active_MAT_NULL
    FROM
        (SELECT [Forecast Number], [FC Month], [FC Year], Region, [Material Code], Channel, [Material Status], [Domestic/Import],
            b.[RSM ID], [ABC (Qty)], Status = 1
        FROM (
                                                                                                                                                                                                                                                                                                                                                                                                                            SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 3101
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 3101) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'KA'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 3102
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 3102) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'KA'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 3103
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 3103) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'KA'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 3104
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 3104) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'KA'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 8001
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT *  FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 8001) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'EBO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 8003
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT *  FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 8003) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'EBO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 8004
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 8004) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'EBO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 8005
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 8005) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'EBO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 4101
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 4101) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'EC'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 9001
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 9001) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'HO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 9003
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 9003) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'HO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 9004
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 9004) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'HO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 9005
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 9005) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'HO'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 9002
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 9002) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'EX'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 5101
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 5101) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SBT'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 5301
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 5301) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SBT'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 5302
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 5302) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SBT'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 5303
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 5303) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SBT'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 5401
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 5401) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SBT'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 5402
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 5402) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SBT'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 5501
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 5501) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SBT'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6304
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6304) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6401
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6401) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                --SELECT a.key1, a.[Material Code],a.channel,a.[Material Status],a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6307 FROM Artsana.FAR.Active_Long a
                --LEFT JOIN (
                --SELECT * FROM Artsana.FAR.ALL_WORKING_QTY WHERE [RSM ID] = 6307) b ON
                --a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6501
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6501) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6104
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6104) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                --SELECT a.key1, a.[Material Code],a.channel,a.[Material Status],a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import],[RSM ID] = 6504 FROM Artsana.FAR.Active_Long a
                --LEFT JOIN (
                --SELECT * FROM Artsana.FAR.ALL_WORKING_QTY WHERE [RSM ID] = 6504) b ON
                --a.[Material Code] = b.Mapping_Code where [Mapping_Code] is  null and a.channel = 'SD' UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6402
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6402) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6403
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6403) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6101
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6101) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6502
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6502) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6303
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6303) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6305
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6305) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6302
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6302) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6306
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6306) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6301
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6301) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD'
            UNION ALL
                SELECT a.key1, a.[Material Code], a.channel, a.[Material Status], a.[Purchasing Source (Imported/ Domestic)] as [Domestic/Import], [RSM ID] = 6503
                FROM Artsana.FAR.Active_Long a
                    LEFT JOIN (
SELECT * FROM Artsana.FAR.ALL_WORKING_QTY
                    WHERE [RSM ID] = 6503) b ON
a.[Material Code] = b.Mapping_Code
                where [Mapping_Code] is  null and a.channel = 'SD' 
)t
            inner JOIN (
SELECT DISTINCT [Forecast Number], [FC Month], [FC Year], Region, [RSM ID], [ABC (Qty)]
            FROM Artsana.FAR.ALL_WORKING_QTY) b
            ON t.[RSM ID] = b.[RSM ID] )g

    ----Artsana - For Finding SKU with Null value and qty and append below data detail END Part - 1

    ----Artsana - For Finding SKU with Null value and qty and append below data detail START Part - 2

    DECLARE @ET AS Date
    SELECT @ET = (DATEADD(Month,0,(SELECT TOP 1
            CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)
        FROM Artsana.FAR.Sales_Data
        ORDER BY CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)DESC)))

    DROP TABLE IF EXISTS #Data_detail_Null
    SELECT [key], [Forecast Number], [FC Month], [FC Year], Region, p.channel, p.[Material Code] as Material_Code, p.[Material Description], p.Category,
        (CASE WHEN d.ABC = 'NP' AND E.ABC is null then'NP' WHEN E.ABC is null then'CZ' ELSE E.ABC END) as [ASM_Class],COALESCE( ASP,0) as ASP, p.[RSM ID], RSM, [Material Status],
        YTD_AVG_SALES_Q = 0, Avg_12M_Sales_Q = 0, Avg_6M_Sales_Q = 0, Avg_3M_Sales_Q = 0, LM_SALES_Q = 0, LYSM1_Q = 0, LYSM2_Q = 0, LYSM3_Q = 0,
        0 AS M1_QTY_3SC , 0 AS M2_QTY_3SC , 0 AS M3_QTY_3SC , 0 AS M4_QTY_3SC ,
        0 AS M5_QTY_3SC , 0 AS M6_QTY_3SC , 0 AS M7_QTY_3SC , 0 AS M8_QTY_3SC ,
        0 AS M9_QTY_3SC , 0 AS M10_QTY_3SC , 0 AS M11_QTY_3SC , 0 AS M12_QTY_3SC,
        0 as M1_Qty, 0 as M2_Qty, 0 as M3_Qty, 0 as M4_Qty, 0 as M5_Qty, 0 as M6_Qty, 0 as M7_Qty, 0 as M8_Qty, 0 as M9_Qty, 0 as M10_Qty, 0 as M11_Qty, 0 as M12_Qty,
        L12_Min_Q = 0, L12_Max_Q = 0,
        0 AS 'M-1', 0 AS 'M-2', 0 AS 'M-3', LYSM4_Q = 0, LYSM5_Q = 0, LYSM6_Q = 0, [Status], [Domestic/Import], [ABC (Qty)],
        0 As AVG_6M_Forecast, '' as [Stock Till], Sub_Group, Line1, Line2, Line3, Line4,
        YEAR(DATEADD(Year,-2, @ET)) as [Year-1_Q], QM1= 0, QM2= 0, QM3= 0, QM4= 0, QM5= 0, QM6= 0, QM7= 0, QM8= 0, QM9= 0, QM10= 0, QM11= 0, QM12= 0,
        YEAR(DATEADD(Year,-1, @ET)) as [Year-2_Q], QM13= 0, QM14= 0, QM15= 0, QM16= 0, QM17= 0, QM18= 0, QM19= 0, QM20= 0, QM21= 0, QM22= 0, QM23= 0, QM24= 0,
        YEAR(DATEADD(Year,0, @ET)) as[Year-3_Q], QM25= 0, QM26= 0, QM27= 0, QM28= 0, QM29= 0, QM30= 0, QM31= 0, QM32= 0, QM33= 0, QM34= 0, QM35= 0, QM36= 0,
        YTD_AVG_SALES_V= 0, Avg_12M_Sales_V= 0, L12_Max_V= 0, L12_Min_V= 0, Avg_6M_Sales_V= 0, Avg_3M_Sales_V= 0, LM_SALES_V= 0, LYSM1_V= 0, LYSM2_V= 0, LYSM3_V= 0, LYSM4_V= 0, LYSM5_V= 0, LYSM6_V= 0,
        YEAR(DATEADD(Year,-2, @ET)) as [Year-1_V], VM1= 0, VM2= 0, VM3= 0, VM4= 0, VM5= 0, VM6= 0, VM7= 0, VM8= 0, VM9= 0, VM10= 0, VM11= 0, VM12= 0,
        YEAR(DATEADD(Year,-1, @ET)) as [Year-2_V], VM13= 0, VM14= 0, VM15= 0, VM16= 0, VM17= 0, VM18= 0, VM19= 0, VM20= 0, VM21= 0, VM22= 0, VM23= 0, VM24= 0,
        YEAR(DATEADD(Year,0, @ET)) as [Year-3_V], VM25= 0, VM26= 0, VM27= 0, VM28= 0, VM29= 0, VM30= 0, VM31= 0, VM32= 0, VM33= 0, VM34= 0, VM35= 0, VM36= 0,
        (CASE WHEN [Category 1] = '0' OR  [Category 1] is NULL  THEN p.Category ELSE [Category 1] END) as [Category 1] , 0 as East_Cont, 0 as North_Cont, 0 as South_Cont, 0 as West_Cont,
        (CASE WHEN d.ABC = 'NP' AND j.ABC is null then'NP' WHEN j.ABC is null then'CZ' ELSE j.abc end) as NSM_class,
        (case when d.ABC = 'NP' AND k.ABC is null then'NP' WHEN k.ABC is null then'CZ' else k.abc end) as ZSM_class,
        (CASE WHEN d.ABC is null THEN 'CZ' ELSE d.ABC END) as [National_level_class], [ZSM UserLoginID], Sequence, key1
    INTO #Data_detail_Null
    FROM (
	SELECT t.*, c.[SFA Category] as Sub_Group, c.Line1, c.Line2, c.Line3, c.Line4, c.[Material Description], COALESCE( y.ASP,0) as ASP, x.[ZSM UserLoginID], l.Sequence,
            cast(l.[Category ] as varchar) as [Category], CAST(c.[Category 1] as varchar) as [Category 1], o.[RSM], t.[Material Code]+'_'+x.[ZSM UserLoginID] as [key1]
        FROM #Active_MAT_NULL t
            INNER JOIN Artsana.FAR.DOA_Final x ON T.[Forecast Number] = x.[Forecast Number]
            LEFT JOIN #Subcate_line C ON t.[Material Code] = c.[Mat Code]
            LEFT JOIN (SELECT DISTINCT Material_Code, [Category 1]
            FROM #Data_detail_pre)r ON t.[Material Code] = r.Material_Code
            LEFT JOIN (SELECT DISTINCT [RSM ID], RSM
            FROM #Data_detail_pre)o ON t.[RSM ID] = o.[RSM ID]
            LEFT JOIN Artsana.FAR.ASP_long y ON t.[Material Code]+(case when t.Channel = 'HO' OR t.Channel = 'EX'  Then 'EX' ELSE t.Channel end) = 
										y.[Material Code]+(case when y.Channel = 'HO & EX'  Then 'EX' ELSE y.Channel end)
            LEFT JOIN Artsana.FAR.active_long L ON t.[Material Code]+'_'+t.[Channel] =  l.[Key1]
	)p
        LEFT JOIN [Artsana].[dbo].[Planner_Level_Classification] D ON p.[Material Code] = D.[Material Code]
        LEFT JOIN [Artsana].[dbo].[ASM_Level_Classification] E ON p.[Material Code] +p.[RSM ID] = E.[Material Code]+E.[RSM ID]
        LEFT JOIN [Artsana].[dbo].[NSM_Level_Classification] J ON p.[Material Code]+p.Channel = J.[Material Code]+j.Channel
        LEFT JOIN [Artsana].[dbo].[ZSM_Level_Classification] K ON p.[Material Code]+ p.[ZSM UserLoginID] = k.[Material Code]+k.ZSM_ID


    ----Artsana - For Finding SKU with Null value and qty and append below data detail END Part - 2

    ----Artsana.FAR.Data_detail START

    DROP TABLE IF EXISTS Artsana.FAR.Data_detail

    SELECT *
    INTO Artsana.FAR.Data_detail
    FROM (
            SELECT *
            FROM #Data_detail_pre
        UNION ALL
            SELECT *
            FROM #Data_detail_Null ) a


    ----Artsana.FAR.Data_detail END

    ----*Artsana - SKU Master START

    DROP TABLE IF EXISTS #SKU_Master_pre
    SELECT DISTINCT a.Material_Code, a.[Material Description] as [Material Description],
        a.[Category 1]  as [Category 1],
        a.Channel,  a.Category  as Category, IsNull(d.ASP,0) as ASP, (CASE WHEN a.[Sequence] is not null then 1 else 0 end) as Status
    INTO #SKU_Master_pre
    FROM Artsana.FAR.Data_detail a
        LEFT JOIN Artsana.FAR.ASP_long D ON a.[Material_Code]+(case when a.Channel = 'HO' OR a.Channel = 'EX'  Then 'EX' ELSE a.Channel end) = 
										D.[Material Code]+(case when D.Channel = 'HO & EX'  Then 'EX' ELSE D.Channel end)

    DROP TABLE IF EXISTS  Artsana.FAR.SKU_Master
    SELECT *
    INTO Artsana.FAR.SKU_Master
    FROM #SKU_Master_pre

    ----*Artsana - SKU Master START

    ------For Distrbutor Matrix* START
    -----For Custmer Matric Start

    DROP TABLE IF EXISTS #Customer_Matrix
    SELECT DISTINCT [Cust Code],
        FIRST_VALUE([Customer Name]) OVER (Partition by  [Cust Code] ORDER BY  [Cust Code]) as [Customer Name],
        City, State
    INTO #Customer_Matrix
    FROM Artsana.FAR.Distributor_SKU_Wise_Data

    -----For Custmer Matric  END
    -----For BDO Start START

    DROP TABLE IF EXISTS #BDO
    SELECT Distinct [RSM ID],
        FIRST_VALUE([BDO]) OVER (Partition by [RSM ID]  ORDER BY  [RSM ID]) as BDO
    INTO #BDO
    FROM Artsana.FAR.Distributor_SKU_Wise_Data
    WHERE BDO IS NOT NULL
    order by [RSM ID]

    -----For BDO END
    -----For RSM Matrix Start

    DROP TABLE IF EXISTS #RSM_Matrix
    SELECT DISTINCT a.[RSM ID], (CASE WHEN Channel = 'KA' THEN 'KA' ELSE New_Zone END) as Region,
        (CASE WHEN [RSM/ZSM ] like '%ZSM-KA%' THEN 'ZSM-KA' ELSE [RSM/ZSM ] END) as [RSM/ZSM ], [USER ID] as ASM, [NSM ],
        FIRST_VALUE([X]) OVER (Partition by a.[RSM ID] ORDER BY a. [RSM ID]) as RSM
, Channel, b.BDO, [Forecast Number]
    INTO #RSM_Matrix
    FROM Artsana.FAR.Distributor_SKU_Wise_Data   a
        LEFT JOIN #BDO b ON a.[RSM ID] = b.[RSM ID]
    order by a.[RSM ID]

    -----For RSM Matrix END
    -----For Distrubutor Master Base START


    DROP TABLE IF EXISTS  #Distributor_SKU_Wise_Data_L12_M
    SELECT ShPt, [Year], [Month], [Cust Code], [Mat Code], [RSM ID], ROUND(Qty,0) as Qty, [Value(in Lakhs)]*100000 as [Value],
        CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) as [Date]
    INTO #Distributor_SKU_Wise_Data_L12_M
    FROM Artsana.FAR.Distributor_SKU_Wise_Data
    WHERE CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(YEAR,-1, @ET)

    --DROP TABLE IF EXISTS  Distrubutor_Master START

    DROP TABLE IF EXISTS Artsana.FAR.Distributor_Master
    SELECT a.[Cust Code], a.[Customer Name], 'IN0A' AS ShPt, b.Category, b.[Category 1], b.Sub_Group as SFA_Category, Line1, Line2, Line3, Line4, City, State, Region, [NSM ], [RSM/ZSM ], ASM as [ASM_AREA], RSM, BDO, Channel, [Mat Code], Mapping_Code,
        [RSM ID], [Forecast Number], [Material Description], QM1, VM1, QM2, VM2, QM3, VM3, QM4, VM4, QM5, VM5, QM6, VM6, QM7, VM7, QM8, VM8, QM9, VM9, QM10, VM10, QM11, VM11, QM12, VM12,
        ROUND((QM1+QM2+QM3+QM4+QM6+QM7+QM8+QM9+QM10+QM11+QM12)/12,0) AS Avg_12M_Sales_Q, ROUND((VM1+VM2+VM3+VM4+VM6+VM7+VM8+VM9+VM10+VM11+VM12)/12,2) as Avg_12M_Sales_V,
        ROUND((QM7+QM8+QM9+QM10+QM11+QM12)/6,0) AS Avg_6M_Sales_Q, ROUND((VM7+VM8+VM9+VM10+VM11+VM12)/6,2) as Avg_6M_Sales_V, ROUND((QM10+QM11+QM12)/3,0) AS Avg_3M_Sales_Q,
        ROUND((VM10+VM11+VM12)/3,2) as Avg_3M_Sales_V , InvoiceQuantity = 0, InvoiceValue = 0, b.Status, [FC Month], [FC Year]
    INTO Artsana.FAR.Distributor_Master
    FROM
        (SELECT a.[Cust Code], a.[Mat Code], a.[RSM ID], b.[Customer Name], b.City, b.State, c.ASM, c.BDO, c.Channel, c.[Forecast Number], c.[NSM ], c.Region, c.RSM, c.[RSM/ZSM ], d.Mapping_Code, d.[FC Month], d.[FC Year],
            ISNULL(SUM(QM1),0) AS QM1 , ISNULL(SUM(QM2),0) AS QM2, ISNULL(SUM(QM3),0) AS QM3, ISNULL(SUM(QM4),0) AS QM4, ISNULL(SUM(QM5),0) AS QM5, ISNULL(SUM(QM6),0) AS QM6,
            ISNULL(SUM(QM7),0) AS QM7, ISNULL(SUM(QM8),0) AS QM8, ISNULL(SUM(QM9),0) AS QM9, ISNULL(SUM(QM10),0) AS QM10, ISNULL(SUM(QM11),0) AS QM11, ISNULL(SUM(QM12),0) AS QM12,
            ISNULL(SUM(VM1),0) AS VM1 , ISNULL(SUM(VM2),0) AS VM2, ISNULL(SUM(VM3),0) AS VM3, ISNULL(SUM(VM4),0) AS VM4, ISNULL(SUM(VM5),0) AS VM5, ISNULL(SUM(VM6),0) AS VM6,
            ISNULL(SUM(VM7),0) AS VM7, ISNULL(SUM(VM8),0) AS VM8, ISNULL(SUM(VM9),0) AS VM9, ISNULL(SUM(VM10),0) AS VM10, ISNULL(SUM(VM11),0) AS VM11, ISNULL(SUM(VM12),0) AS VM12
        FROM (
SELECT DISTINCT [Cust Code], [Mat Code], [RSM ID],
                (CASE WHEN [Date] = DATEADD(MONTH,-11,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM1, (CASE WHEN [Date] = DATEADD(MONTH,-10,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM2,
                (CASE WHEN [Date] = DATEADD(MONTH,-9,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM3, (CASE WHEN [Date] = DATEADD(MONTH,-8,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM4,
                (CASE WHEN [Date] = DATEADD(MONTH,-7,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM5, (CASE WHEN [Date] = DATEADD(MONTH,-6,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM6,
                (CASE WHEN [Date] = DATEADD(MONTH,-5,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM7, (CASE WHEN [Date] = DATEADD(MONTH,-4,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM8,
                (CASE WHEN [Date] = DATEADD(MONTH,-3,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM9, (CASE WHEN [Date] = DATEADD(MONTH,-2,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM10,
                (CASE WHEN [Date] = DATEADD(MONTH,-1,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM11, (CASE WHEN [Date] = DATEADD(MONTH,0,@ET) THEN ISNULL(SUM(Qty),0) END) AS QM12,
                (CASE WHEN [Date] = DATEADD(MONTH,-11,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM1, (CASE WHEN [Date] = DATEADD(MONTH,-10,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM2,
                (CASE WHEN [Date] = DATEADD(MONTH,-9,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM3, (CASE WHEN [Date] = DATEADD(MONTH,-8,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM4,
                (CASE WHEN [Date] = DATEADD(MONTH,-7,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM5, (CASE WHEN [Date] = DATEADD(MONTH,-6,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM6,
                (CASE WHEN [Date] = DATEADD(MONTH,-5,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM7, (CASE WHEN [Date] = DATEADD(MONTH,-4,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM8,
                (CASE WHEN [Date] = DATEADD(MONTH,-3,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM9, (CASE WHEN [Date] = DATEADD(MONTH,-2,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM10,
                (CASE WHEN [Date] = DATEADD(MONTH,-1,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM11, (CASE WHEN [Date] = DATEADD(MONTH,0,@ET) THEN ISNULL(SUM([Value]),0) END) AS VM12
            FROM #Distributor_SKU_Wise_Data_L12_M
            GROUP BY [Cust Code],[Mat Code],[RSM ID],Date) a
            LEFT JOIN #Customer_Matrix b ON a.[Cust Code] = b.[Cust Code]
            LEFT JOIN #RSM_Matrix c ON a.[RSM ID] = c.[RSM ID]
            LEFT JOIN (SELECT Distinct [Mat Code], Mapping_Code, [FC Month], [FC Year]
            FROM Artsana.FAR.Distributor_SKU_Wise_Data) d ON a.[Mat Code] = d.[Mat Code]
        GROUP BY a.[Cust Code],a.[Mat Code],a.[RSM ID],b.[Customer Name],b.City,b.State,c.ASM,c.BDO,c.Channel,c.[Forecast Number],c.[NSM ],c.Region,c.RSM,c.[RSM/ZSM ],d.Mapping_Code,d.[FC Month],d.[FC Year])a
        LEFT JOIN
        (SELECT DISTINCT Material_Code, Status,
            FIRST_VALUE([Material Description]) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as [Material Description],
            FIRST_VALUE(Line1) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as Line1,
            FIRST_VALUE(Line2) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as Line2,
            FIRST_VALUE(Line3) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as Line3,
            FIRST_VALUE(Line4) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as Line4,
            FIRST_VALUE(Sub_Group) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as Sub_Group,
            FIRST_VALUE(Category) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as Category,
            FIRST_VALUE([Category 1]) OVER (Partition by Material_Code ORDER BY cast(Material_Code as varchar(30))) as [Category 1]
        FROM Artsana.FAR.Data_detail) b ON a.Mapping_Code = b.Material_Code

--DROP TABLE IF EXISTS  Distrubutor_Master END


END


