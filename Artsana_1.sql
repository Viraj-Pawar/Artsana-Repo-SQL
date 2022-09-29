USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1]    Script Date: 20-09-2022 17:26:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [Test].[Artsana_1]
----EXEC  [Test].[Artsana_1]
AS
BEGIN

----* for Artsana.test.active_list_Sequence START----
	DROP TABLE IF EXISTS Artsana.test.active_list_Sequence
	SELECT 
		*, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS [Sequence] 
		INTO Artsana.test.active_list_Sequence
	FROM Artsana.test.active_list AS t

----* for test.active_list_Sequence END----

----* for #active START----

	DROP TABLE IF EXISTS #active
	SELECT *INTO   #active FROM   
	(
              SELECT [Material Code]+'_'+bt AS [Key1],[Material Code],bt AS channel FROM   Artsana.test.active_list
              WHERE  bt IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+[GT+MT] AS [Key1],[Material Code],[GT+MT] AS channel FROM   Artsana.test.active_list
              WHERE  [GT+MT] IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+[HOS] AS [Key],[Material Code],hos AS channel FROM   Artsana.test.active_list
              WHERE  hos IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ka AS [Key1],[Material Code],ka AS channel FROM   Artsana.test.active_list
              WHERE  ka IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ebo AS [Key1],[Material Code],ebo AS channel FROM   Artsana.test.active_list
              WHERE  ebo IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+rest AS [Key1],[Material Code],rest AS channel FROM   Artsana.test.active_list
              WHERE  rest IS NOT NULL
              UNION
              SELECT [Material Code]+'_'+ecom AS [Key1],[Material Code],ecom AS channel FROM   Artsana.test.active_list
              WHERE  ecom IS NOT NULL 
	)x

----* for #active END----

----* for Test.Distributor_SKU_Wise_Data Start----

	DROP TABLE IF EXISTS Artsana.Test.Distributor_SKU_Wise_Data
	SELECT * INTO Artsana.Test.Distributor_SKU_Wise_Data FROM
	(
		SELECT Y.*,C.channel AS [Channel Active List],'RSM'+CAST([RSM ID] AS Varchar) +(CASE WHEN Y.Channel = 'KA' THEN '' ELSE LEFT(Zone,1) END)
		+Cast([FC Month] AS varchar)+cast([FC Year] as varchar)+Y.Channel AS [Forecast Number],
		'RSM'+CAST([RSM ID] AS varchar)+LEFT(Zone,1)+cast([FC Month]as varchar)+ cast([FC Year]AS varchar)+Y.Channel+'_'+cast([Mapped Code] as varchar) AS [Key] FROM 
		(
			SELECT T.*,P.[RSM ID],Month(GETDATE()) AS [FC Month],Year(GETDATE()) AS [FC Year],([Mapped Code]+'_'+T.Channel) AS [Active Key]  FROM
			(
				SELECT a.*,(CASE WHEN b.[Mapped Code] is null THEN a.[Mat Code] ELSE b.[Mapped Code] END) AS [Mapped Code], dbo.CapitalizeFirstLetter(a.ASM2) AS X,
				(CASE WHEN [Channel Name L1] = 'BRAND-E-COM' THEN 'EC'
				WHEN [Channel Name L1] = 'BT' THEN 'SBT' WHEN [Channel Name L1] = 'EBO' THEN 'EBO' WHEN [Channel Name L1] = 'GT+MT' THEN 'SD'
				WHEN [Channel Name L1] = 'KA' THEN 'KA' WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ANKUSH KUMAR' THEN 'EX'
				WHEN [Channel Name L1] = 'Export + Others' AND ASM2 = 'ASM-EXPORT/INTI' THEN 'EX' WHEN [Channel Name L1] = 'Export + Others'
				AND ASM2 = 'ASM-HOSPITAL' THEN 'HO' END) AS Channel FROM Artsana.Test.Sales_Data A
				LEFT JOIN Artsana.test.[Mapping File] b ON a. [Mat Code] = b. [Material Code]
			)T
			LEFT JOIN (SELECT DISTINCT [ASM AREA],[RSM ID]  FROM Artsana.Test.[RSM_ID] ) P ON P.[ASM AREA] = T.[USER ID]
		)Y
		LEFT JOIN #active c ON Y.[Active Key] = c.Key1
	)Z

----* for Test.Distributor_SKU_Wise_Data END----	

----* for Base File Start----	
	DROP TABLE IF EXISTS Test.Base_File
	SELECT  [key]+'_'+Cast([Month] as varchar)+'_'+cast([Year] as varchar) AS [Key2],[Year],[Month],
			[Cust Code],[Customer Name],[Mat Code],Qty,[Value(in Lakhs)],[Mapped Code] AS [mapping Code],X,Channel,
			[RSM ID],[FC Month],[FC Year],[Forecast Number],[Key],[Channel Active List] AS [Active list] 
		INTO Artsana.Test.Base_File
	FROM [Artsana].[Test].[Distributor_SKU_Wise_Data]
	WHERE [Year] >= 2018

----* for Base File END----	

----* for mapping file_extracolumn START----	

------DROP TABLE IF EXISTS test.[mapping file_extracolumn]
------SELECT a.*,b.[sfa category] AS Subgroup,line1,line2,line3,line4
------INTO   Artsana.test.[mapping file_extracolumn]
------FROM   Artsana.test.[mapping file] a
------       LEFT JOIN (SELECT DISTINCT [Mapped Code],[sfa category],line1,line2,line3,line4
------                  FROM   Artsana.test.distributor_sku_wise_data) b
------              ON a.[Mapped Code] = b.[Mapped Code]

DROP TABLE IF EXISTS test.[mapping file_extracolumn]
	select *  into test.[mapping file_extracolumn] from 
		(SELECT * ,ROW_NUMBER() OVER(partition by [Mapped Code] order by [Mapped Code]) AS RN from 
			(SELECT a.*,b.[sfa category] AS Subgroup,line1,line2,line3,line4
			FROM   Artsana.test.[mapping file] a
				LEFT JOIN (SELECT DISTINCT [Mapped Code],[sfa category],line1,line2,line3,line4
							FROM   Artsana.test.distributor_sku_wise_data) b
			ON a.[Mapped Code] = b.[Mapped Code]) t1) t
		WHERE  RN = 1

----* for mapping file_extracolumn END----	

----* for Artsana_Data details_base file-all channels-Sep START

DROP TABLE IF EXISTS Artsana.Test.Artsana_Data_details_base_file_all_channels
SELECT * into Artsana.Test.Artsana_Data_details_base_file_all_channels FROM
--SELECT COUNT(*) FROM
(
SELECT [Key],[Year],[Month],A.[Mapped Code],
(CASE WHEN B.[Material Description] is null THEN A.[Material Description] ELSE B.[Material Description] END) AS Description,
(CASE WHEN B.[Category1] is null THEN A.Category ELSE B.Category1 END) AS Category,
(CASE WHEN B.[Category] is null THEN A.Category1 ELSE B.Category END) AS Category1,
(CASE WHEN B.[Material Status] is null THEN 'Inactive' ELSE B.[Material Status] END) AS [Material Status],
(CASE WHEN B.[Purchasing Source (Imported/ Domestic)] is null THEN 'Inactive' ELSE B.[Purchasing Source (Imported/ Domestic)] END) AS [Domestic/Import],
Channel,[RSM ID],[FC Month],[FC Year],[Forecast Number],Zone AS Region,A.[NSM ],[RSM/ZSM ],A.[USER ID] AS [ABC (Qty)],
(CASE WHEN Channel = 'KA' THEN [USER ID] ELSE ASM2 END) AS [RSM],Qty,[Value(in Lakhs)],
(CASE WHEN C.Subgroup  is null OR C.Subgroup  = '0' THEN A.[SFA Category] ELSE C.Subgroup  END) AS Subgroup,
(CASE WHEN C.line1 is null OR C.line1 = '0' THEN A.Line1 ELSE C.line1 END) AS Line1,
(CASE WHEN C.line2 is null OR C.line2 = '0' THEN A.Line2 ELSE C.line2 END) AS Line2,
(CASE WHEN C.line3 is null OR C.line3 = '0' THEN A.Line3 ELSE C.line3 END) AS Line3,
(CASE WHEN C.line4 is null OR C.line4 = '0' THEN A.Line4 ELSE C.line4 END) AS Line4,
([Value(in Lakhs)]/100000) AS [Value],[Channel Active List] as [Active Channel],[Active Key],ShPt,City,State
FROM Artsana.Test.Distributor_SKU_Wise_Data A
LEFT JOIN Artsana.Test.active_list_Sequence B ON A.[Mapped Code] = B.[Material Code]
LEFT JOIN Artsana.Test.[mapping file_extracolumn] C ON A.[Mapped Code] = C.[Mapped Code]
) T 

----* for Artsana_Data details_base file-all channels-Sep END

----* for Tab: All-exclude KA to be pasted ---*[Value(in Lakhs)]* START

	DROP TABLE IF EXISTS #Temp_without_KA,#Temp_with_KA,Artsana.Test.All_exclude_KA_QTY,Artsana.Test.All_exclude_KA_Value,Artsana.Test.All_with_KA_QTY
	SELECT  *,CAST([Month] AS VARCHAR)+CAST([Year] AS VARCHAR) AS [date] into #Temp_without_KA FROM Artsana.Test.Artsana_Data_details_base_file_all_channels where Channel != 'KA'

	DECLARE @ST AS Date
	SELECT @ST = (DATEADD(Month,-2,(SELECT TOP 1 CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) FROM Artsana.Test.Artsana_Data_details_base_file_all_channels
									ORDER BY CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)DESC)))
	DECLARE @ET AS Date
	SELECT @ET = (DATEADD(Month,0,(SELECT TOP 1 CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) FROM Artsana.Test.Artsana_Data_details_base_file_all_channels
									ORDER BY CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)DESC)))
	
	SELECT a.*,CAST(a.[Month] AS VARCHAR)+CAST([Year] AS VARCHAR)+Region AS [date_zone] into #Temp_with_KA
	FROM Artsana.Test.Artsana_Data_details_base_file_all_channels a
	where Channel = 'KA' AND CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) BETWEEN @ST AND @ET


DECLARE @Col VARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)

SET @Col = (SELECT STRING_AGG([date],',') FROM
(SELECT DISTINCT [date] FROM #Temp_without_KA )t)


SET @SQL = 
	'SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
	[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
	[Domestic/Import],[ABC (Qty)],Category1,' + @Col + ' 
INTO Artsana.Test.All_exclude_KA_Value
FROM 
	(SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
	[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
	[Domestic/Import],[ABC (Qty)],Category1,[Value(in Lakhs)],[date]
FROM #Temp_without_KA
) as Source_table
	PIVOT
	(SUM([Value(in Lakhs)]) for [date] in (' +@Col +')
) AS Pivot_table'

EXECUTE(@SQL)

----* for Tab: All-exclude KA to be pasted ---*[Value(in Lakhs)]* END

----* for Tab: All-exclude KA to be pasted ---*[Qty]* START

DECLARE @Col1 VARCHAR(MAX)
DECLARE @SQL1 NVARCHAR(MAX)

SET @Col1 = (SELECT STRING_AGG([date],',') FROM
(SELECT DISTINCT [date] FROM #Temp_without_KA )t)


SET @SQL1 = 
	'SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
	[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
	[Domestic/Import],[ABC (Qty)],Category1,' + @Col1 + ' 
INTO Artsana.Test.All_exclude_KA_QTY
FROM 
	(SELECT [Forecast Number],[FC Month],[FC Year],Region,Channel,
	[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
	[Domestic/Import],[ABC (Qty)],Category1,[Qty],[date]
FROM #Temp_without_KA
) as Source_table
PIVOT
	(SUM([Qty]) for [date] in (' +@Col1 +')
) AS Pivot_table'

EXECUTE(@SQL1) 

----* for Tab: All-exclude KA to be pasted ---*[Qty]* END


----* for Tab: All_with_KA_QTY ---*[Qty]* START

DECLARE @Col2 VARCHAR(MAX)
DECLARE @SQL2 NVARCHAR(MAX)

SET
@Col2 = (
SELECT
	STRING_AGG([date_zone],
	',')
FROM
	(
	SELECT
		DISTINCT [date_zone]
	FROM
		#Temp_with_KA )t)
SET
@SQL2 = 
	'SELECT [Forecast Number],[FC Month],[FC Year],Channel, [Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
	[Domestic/Import],' + @Col2 + ' 
INTO Artsana.Test.All_with_KA_QTY 
FROM 
	(SELECT [Forecast Number],[FC Month],[FC Year],Channel,
	[Mapped Code],Description,Category,RSM,[RSM ID],[Material Status],
	[Domestic/Import],[Qty],[date_zone]
FROM #Temp_with_KA
) as Source_table
	PIVOT
	(SUM([Qty]) for [date_zone] in (' + @Col2 + ')
) AS Pivot_table'

EXECUTE(@SQL2)

DECLARE @Col_EAST VARCHAR(MAX),@Col_WEST VARCHAR(MAX),@Col_NORTH VARCHAR(MAX),@Col_SOUTH VARCHAR(MAX),@Script NVARCHAR(MAX)

SET
@Col_EAST = (SELECT STRING_AGG(concat('coalesce(', COLUMN_NAME, ',0.00)'),'+') FROM
			(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
			WHERE COLUMN_NAME LIKE '%East'  AND TABLE_CATALOG = 'Artsana' AND TABLE_SCHEMA = 'Test' AND TABLE_NAME = 'All_with_KA_QTY')t)
SET
@Col_WEST = (SELECT STRING_AGG(concat('coalesce(', COLUMN_NAME, ',0.00)'),'+') FROM
			(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
			WHERE COLUMN_NAME LIKE '%West'  AND TABLE_CATALOG = 'Artsana' AND TABLE_SCHEMA = 'Test' AND TABLE_NAME = 'All_with_KA_QTY')t)
SET
@Col_NORTH =(SELECT STRING_AGG(concat('coalesce(', COLUMN_NAME, ',0.00)'),'+') FROM
			(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
			WHERE COLUMN_NAME LIKE '%North'  AND TABLE_CATALOG = 'Artsana' AND TABLE_SCHEMA = 'Test' AND TABLE_NAME = 'All_with_KA_QTY')t)
SET
@Col_SOUTH =(SELECT STRING_AGG(concat('coalesce(', COLUMN_NAME, ',0.00)'),'+') FROM
			(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
			WHERE COLUMN_NAME LIKE '%South'  AND TABLE_CATALOG = 'Artsana' AND TABLE_SCHEMA = 'Test' AND TABLE_NAME = 'All_with_KA_QTY')t)
SET @Script = 
	'SELECT t.*,ROUND(ISNULL(EAST_TOTAL/NULLIF(EAST_TOTAL+NORTH_TOTAL+WEST_TOTAL+SOUTH_TOTAL,0),0)*100,0) as EAST_Percentage
	,ROUND(ISNULL(WEST_TOTAL/NULLIF(EAST_TOTAL+NORTH_TOTAL+WEST_TOTAL+SOUTH_TOTAL,0),0)*100,0) as WEST_Percentage
	,ROUND(ISNULL(NORTH_TOTAL/NULLIF(EAST_TOTAL+NORTH_TOTAL+WEST_TOTAL+SOUTH_TOTAL,0),0)*100,0) as NORTH_Percentage
	,ROUND(ISNULL(SOUTH_TOTAL/NULLIF(EAST_TOTAL+NORTH_TOTAL+WEST_TOTAL+SOUTH_TOTAL,0),0)*100,0) as SOUTH_Percentage 
INTO Artsana.Test.KA_Contribution_Working  
FROM
	(SELECT *,'+@Col_EAST+' AS EAST_TOTAL,'+@Col_NORTH+' AS NORTH_TOTAL,'+@Col_WEST+' AS WEST_TOTAL,'+@Col_SOUTH+' AS SOUTH_TOTAL,
	[Forecast Number]+''_''+[Mapped Code] AS [Key] FROM Artsana.Test.All_with_KA_QTY)t'
EXEC  ( @Script)

----* for Tab: All_with_KA_QTY ---*[Qty]* END


----* for Tab: Avg_6_Month_Sale-Stock_Till ---*[Qty]* START

	SELECT [Mapped Code] ,M1,M2,M3,M4,M5,M6,[Grand Total], ROUND(([Grand Total]/6),0) AS [Average Sales],[Total Stock] ,
	ROUND(ISNULL([Total Stock]/NULLIF(([Grand Total]/6),0),0),0) AS [Month of Stock], 
	(CASE WHEN ROUND(ISNULL([Total Stock]/NULLIF(([Grand Total]/6),0),0),0) >= 1 THEN DATEADD(Month,ROUND(ISNULL([Total Stock]/NULLIF(([Grand Total]/6),0),0),0), GETDATE()) 
	ELSE NULL END) As [Stock Till]
INTO [Avg_6_Month_Sale-Stock_Till]
 FROM
	(SELECT a.[Mapped Code], ISNULL(SUM(M1),0)AS M1,ISNULL(SUM(M2),0)AS M2,ISNULL(SUM(M3),0)AS M3,ISNULL(SUM(M4),0)AS M4,ISNULL(SUM(M5),0)AS M5,ISNULL(SUM(M6),0) AS M6,
	(ISNULL(SUM(M1),0) + ISNULL(SUM(M2),0)+ ISNULL(SUM(M3),0)+ ISNULL(SUM(M4),0)+ ISNULL(SUM(M5),0)+ ISNULL(SUM(M6),0)) AS [Grand Total],ISNULL((u.Stock),0) as [Total Stock]
	FROM 
		(SELECT [Mapped Code],
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-5, @ET  ) THEN ISNULL([Qty],0)  END) AS 'M1',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-4, @ET  ) THEN ISNULL([Qty],0)  END) AS 'M2',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-3, @ET  ) THEN ISNULL([Qty],0)  END) AS 'M3',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-2, @ET  ) THEN ISNULL([Qty],0)  END) AS 'M4',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-1, @ET  ) THEN ISNULL([Qty],0)  END) AS 'M5',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = @ET THEN [Qty]  END) AS 'M6' 
		FROM Artsana.Test.Artsana_Data_details_base_file_all_channels 
			--where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) BETWEEN @ST AND @ET
		)a 
	 LEFT JOIN 
		(SELECT (CASE WHEN b.[Mapped Code] is null THEN a.Material ELSE b.[Mapped Code] END) AS [Mapped Code], SUM(a.[Total Stock]) As Stock FROM Artsana.Test.Warehouse_Stock_Report a
		LEFT JOIN Artsana.Test.Mapping_File_PBI b ON a.Material = b.[Material Code]
		GROUP BY (CASE WHEN b.[Mapped Code] is null THEN a.Material ELSE b.[Mapped Code] END)) u ON a.[Mapped Code] = u.[Mapped Code]
GROUP BY a.[Mapped Code],u.Stock)t
	
----* for Tab: Avg_6_Month_Sale-Stock_Till ---*[Qty]* END

END









