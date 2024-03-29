USE [Artsana]
GO
/****** Object:  StoredProcedure [FAR].[Artsana_1_FC_Details_Base]    Script Date: 20-03-2023 16:44:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----RAW FILES USED
--1) Artsana.FAR.DOA_RAW
--2) Artsana.FAR.SKU_Artsana
--3) Artsana.FAR.Warehouse_Stock_Report
--4) 
--5) 

ALTER PROCEDURE [FAR].[Artsana_1_FC_Details_Base]
----EXEC  [FAR].[Artsana_1_FC_Details_Base]
AS
BEGIN

----* for mapping file_extracolumn START----	

	DROP TABLE IF EXISTS Artsana.FAR.[mapping file_extracolumn]
		select *  into Artsana.FAR.[mapping file_extracolumn] from 
			(SELECT * ,ROW_NUMBER() OVER(partition by [Mapped Code] order by [Mapped Code]) AS RN from 
				(SELECT a.*,b.[sfa category] AS Subgroup,line1,line2,line3,line4
					FROM   Artsana.FAR.[mapping file] a
				LEFT JOIN (SELECT DISTINCT  [Mat Code] AS [Mapping_Code], [SFA Sub Cat] AS [sfa category],line1,line2,line3,line4
							FROM   Artsana.FAR.SKU_Artsana) b
			ON a.[Mapped Code] = b.[Mapping_Code]) t1) t
		WHERE  RN = 1

----* for mapping file_extracolumn END----

----* for Artsana_Data details_base file-all channels-Sep START

DECLARE @ET AS Date
SELECT @ET = (DATEADD(Month,0,(SELECT TOP 1 CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) FROM Artsana.FAR.Sales_Data
									ORDER BY CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)DESC)))

DROP TABLE IF EXISTS Artsana.FAR.Artsana_Data_details_base_file_all_channels 
SELECT * into Artsana.FAR.Artsana_Data_details_base_file_all_channels 
FROM
(
SELECT [Key],[Year],[Month],A.[Mapping_Code],
(CASE WHEN B.[Category ] is null THEN FIRST_VALUE(A.Category) OVER (Partition by  a.Mapping_Code ORDER BY  a.Mapping_Code desc)
ELSE B.[Category ] END) AS [Category],
(CASE WHEN C.[Category 1] is null THEN FIRST_VALUE(A.Category1) OVER (Partition by  a.Mapping_Code ORDER BY  a.Mapping_Code desc)
ELSE C.[Category 1] END) AS [Category 1],
(CASE WHEN B.[Material Status] is null THEN 'Inactive' ELSE B.[Material Status] END) AS [Material Status],
(CASE WHEN B.[Purchasing Source (Imported/ Domestic)] is null THEN 'Inactive' ELSE B.[Purchasing Source (Imported/ Domestic)] END) AS [Domestic/Import],
a.Channel,[RSM ID],[FC Month],[FC Year],[Forecast Number],(CASE WHEN a.Channel = 'EX' THEN 'EXPORT' ELSE Zone END) AS Region,A.[NSM ],[RSM/ZSM ],A.[USER ID] AS [ABC (Qty)],
(CASE WHEN a.Channel = 'KA' 
THEN FIRST_VALUE(A.[USER ID]) OVER (Partition by  A.Mapping_Code ORDER BY  a.Mapping_Code desc) 
ELSE FIRST_VALUE(A.ASM2) OVER (Partition by  A.Mapping_Code ORDER BY  a.Mapping_Code desc) 
 END) AS [RSM],Qty,[Value(in Lakhs)],
(CASE WHEN C.[SFA Sub Cat]  is null OR C.[SFA Sub Cat]  = '0' 
THEN FIRST_VALUE(A.[SFA Category]) OVER (Partition by  a.Mapping_Code ORDER BY  a.Mapping_Code desc) ELSE C.[SFA Sub Cat]  END) AS Subgroup,
(CASE WHEN C.line1 is null OR C.line1 = '0' 
THEN FIRST_VALUE(A.Line1) OVER (Partition by  a.Mapping_Code ORDER BY  a.Mapping_Code desc) ELSE C.line1 END) AS Line1,
(CASE WHEN C.line2 is null OR C.line2 = '0' 
THEN FIRST_VALUE(A.Line2) OVER (Partition by  a.Mapping_Code ORDER BY  a.Mapping_Code desc)  ELSE C.line2 END) AS Line2,
(CASE WHEN C.line3 is null OR C.line3 = '0' 
THEN FIRST_VALUE(A.Line3) OVER (Partition by  a.Mapping_Code ORDER BY  a.Mapping_Code desc)  ELSE C.line3 END) AS Line3,
(CASE WHEN C.line4 is null OR C.line4 = '0' 
THEN FIRST_VALUE(A.Line4) OVER (Partition by  a.Mapping_Code ORDER BY  a.Mapping_Code desc)  ELSE C.line4 END) AS Line4,
([Value(in Lakhs)]*100000) AS [Value],[Channel Active List] as [Active Channel],[Active Key],ShPt,City,State
FROM Artsana.FAR.Distributor_SKU_Wise_Data A
LEFT JOIN Artsana.FAR.Active_Long B ON A.[Mapping_Code]+'_'+a.Channel = B.[key1]
LEFT JOIN Artsana.FAR.[SKU_Artsana] C ON A.[Mapping_Code] = C.[Mat Code]
--LEFT JOIN #DISTINCT_DISTRIBUTOR_FILE D ON A.[Mat Code] = D.[Mat Code]
) T  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(YEAR,-3, @ET)

--* for Artsana_Data details_base file-all channels-Sep END


----* for ALL the Aggregate functions in FC_details Start
DROP TABLE IF EXISTS #YTD_AVG_SALES,#Avg_12M_Sales,#Avg_6M_Sales,#Avg_3M_Sales,#L12Max,#L12Min,#LM_SALES,#LYSM1,#LYSM2,#LYSM3,#LYSM4,#LYSM5,#LYSM6,#M_2,#M_3

SELECT [key],SUM(Qty)/MONTH(@ET) as YTD_AVG_SALES_Q,SUM(Value)/MONTH(@ET) as YTD_AVG_SALES_V  INTO #YTD_AVG_SALES
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where YEAR(CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)) =YEAR( @ET)
GROUP BY [key]
SELECT [key],SUM(Qty)/12 as Avg_12M_Sales_Q,SUM([Value])/12 as Avg_12M_Sales_V INTO #Avg_12M_Sales 
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(YEAR,-1, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty)/6 as Avg_6M_Sales_Q,SUM(Value)/6 as Avg_6M_Sales_V  INTO #Avg_6M_Sales
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(Month,-6, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty)/3 as Avg_3M_Sales_Q,SUM(Value)/3 as Avg_3M_Sales_V  INTO #Avg_3M_Sales
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(Month,-3, @ET)
GROUP BY [key]
SELECT [key],MAX(Qty) as L12_Max_Q,MAX(Value) as L12_Max_V INTO #L12Max
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(YEAR,-1, @ET)
GROUP BY [key]
SELECT [key],MIN(Qty) as L12_Min_Q,MIN(Value) as L12_Min_V INTO #L12Min
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(YEAR,-1, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as LM_SALES_Q,SUM(Value) as LM_SALES_V INTO #LM_SALES
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = @ET
GROUP BY [key]
SELECT [key],SUM(Qty) as LYSM1_Q,SUM(Value) as LYSM1_V INTO #LYSM1
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-10, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as LYSM2_Q,SUM(Value) as LYSM2_V INTO #LYSM2
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-9, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as LYSM3_Q,SUM(Value) as LYSM3_V INTO #LYSM3
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-8, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as LYSM4_Q,SUM(Value) as LYSM4_V INTO #LYSM4
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-7, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as LYSM5_Q,SUM(Value) as LYSM5_V INTO #LYSM5
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-6, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as LYSM6_Q,SUM(Value) as LYSM6_V INTO #LYSM6
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-5, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as 'M-2'INTO #M_2
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-1, @ET)
GROUP BY [key]
SELECT [key],SUM(Qty) as 'M-3'INTO #M_3
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-2, @ET)
GROUP BY [key]


----* for ALL the Aggregate functions in FC_details END


----* for Creating Month seq START

DROP TABLE IF EXISTS  #Month_seq
SELECT Date,'QM'+CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as varchar) AS Month_Seq_Q,
'VM'+CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as varchar) AS Month_Seq_V INTO #Month_seq 
FROM (
SELECT DISTINCT CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) as [Date]  
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels ) a 
WHERE year([date]) >= YEAR(DATEADD(Year,-2, @ET))


----* for Creating Month seq END

----* for sales data excluiding KA and adding Month seq START

DROP TABLE IF EXISTS  #NOT_KA_QTY_ONLY
SELECT a.*,CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) as [Date],b.Month_Seq_Q,b.Month_Seq_V
INTO #NOT_KA_QTY_ONLY FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  a
LEFT JOIN #Month_seq b ON CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) = b.[Date]
where a.Channel != 'KA'--( 352953 rows affected) SELECT * FROM  #NOT_KA_QTY_ONLY

----* for sales data excluiding KA and adding Month seq END

----* for EXCLUDING KA pivot Quatity START

DROP TABLE IF EXISTS  #KA_EXCLUDE_WORKING_QTY
SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],
IsNull(QM1, 0) AS QM1,IsNull(QM2, 0) AS QM2,IsNull(QM3, 0) AS QM3,IsNull(QM4, 0) AS QM4,IsNull(QM5, 0) AS QM5,IsNull(QM6, 0) AS QM6,IsNull(QM7, 0) AS QM7,
IsNull(QM8, 0) AS QM8,IsNull(QM9, 0) AS QM9,IsNull(QM10, 0) AS QM10,IsNull(QM11, 0) AS QM11,IsNull(QM12, 0) AS QM12,IsNull(QM13, 0) AS QM13,IsNull(QM14, 0) AS QM14,
IsNull(QM15, 0) AS QM15,IsNull(QM16, 0) AS QM16,IsNull(QM17, 0) AS QM17,IsNull(QM18, 0) AS QM18,IsNull(QM19, 0) AS QM19,IsNull(QM20, 0) AS QM20,IsNull(QM21, 0) AS QM21,
IsNull(QM22, 0) AS QM22,IsNull(QM23, 0) AS QM23,IsNull(QM24, 0) AS QM24,IsNull(QM25, 0) AS QM25,IsNull(QM26, 0) AS QM26,IsNull(QM27, 0) AS QM27,IsNull(QM28, 0) AS QM28,
IsNull(QM29, 0) AS QM29,IsNull(QM30, 0) AS QM30,IsNull(QM31, 0) AS QM31,IsNull(QM32, 0) AS QM32,IsNull(QM33, 0) AS QM33,IsNull(QM34, 0) AS QM34,IsNull(QM35, 0) AS QM35,
IsNull(QM36,0) as QM36
into #KA_EXCLUDE_WORKING_QTY
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],Month_Seq_Q, [Qty] FROM #NOT_KA_QTY_ONLY) A  
PIVOT  
(  
SUM([Qty]) 
FOR [Month_Seq_Q] IN (
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36)
) B

----* for EXCLUDING KA pivot Quatity END

----* for EXCLUDING KA pivot VALUE START

DROP TABLE IF EXISTS  #KA_EXCLUDE_WORKING_VALUE
SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],
IsNull(VM1, 0) AS VM1,IsNull(VM2, 0) AS VM2,IsNull(VM3, 0) AS VM3,IsNull(VM4, 0) AS VM4,IsNull(VM5, 0) AS VM5,IsNull(VM6, 0) AS VM6,IsNull(VM7, 0) AS VM7,
IsNull(VM8, 0) AS VM8,IsNull(VM9, 0) AS VM9,IsNull(VM10, 0) AS VM10,IsNull(VM11, 0) AS VM11,IsNull(VM12, 0) AS VM12,IsNull(VM13, 0) AS VM13,IsNull(VM14, 0) AS VM14,
IsNull(VM15, 0) AS VM15,IsNull(VM16, 0) AS VM16,IsNull(VM17, 0) AS VM17,IsNull(VM18, 0) AS VM18,IsNull(VM19, 0) AS VM19,IsNull(VM20, 0) AS VM20,IsNull(VM21, 0) AS VM21,
IsNull(VM22, 0) AS VM22,IsNull(VM23, 0) AS VM23,IsNull(VM24, 0) AS VM24,IsNull(VM25, 0) AS VM25,IsNull(VM26, 0) AS VM26,IsNull(VM27, 0) AS VM27,IsNull(VM28, 0) AS VM28,
IsNull(VM29, 0) AS VM29,IsNull(VM30, 0) AS VM30,IsNull(VM31, 0) AS VM31,IsNull(VM32, 0) AS VM32,IsNull(VM33, 0) AS VM33,IsNull(VM34, 0) AS VM34,IsNull(VM35, 0) AS VM35,IsNull(VM36,0) as VM36
into #KA_EXCLUDE_WORKING_VALUE
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],Month_Seq_V, [Value] FROM #NOT_KA_QTY_ONLY) A  
PIVOT  
(  
SUM([Value])
FOR [Month_Seq_V] IN (
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36)
) B

----* for EXCLUDING KA pivot VALUE END

----* for sales data for KA and adding Month seq END

DROP TABLE IF EXISTS  #KA_QTY_ONLY
SELECT a.*,CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) as [Date],b.Month_Seq_Q,b.Month_Seq_V
INTO #KA_QTY_ONLY FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  a
LEFT JOIN #Month_seq b ON CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) = b.[Date]
where a.Channel = 'KA'

----* for sales data for KA and adding Month seq END

----* for Ka_contribution_Percentage START

SELECT [Key],Region,Qty,[Date] into #K_QTY FROM #KA_QTY_ONLY

SELECT [Key],North,South, East,West,
ROUND(ISNULL(East/NULLIF(East+north+south+west,0),0)*100,0) as East_Cont,
ROUND(ISNULL(North/NULLIF(East+north+south+west,0),0)*100,0) as North_Cont,
ROUND(ISNULL(West/NULLIF(East+north+south+west,0),0)*100,0) as South_Cont,
ROUND(ISNULL(South/NULLIF(East+north+south+west,0),0)*100,0) as West_Cont 
INTO #KA_Contribution FROM (
SELECT [kEy],ISNULL(SUM(NORTH),0) As North,ISNULL(SUM(EAST),0) as East,ISNULL(SUM(West),0) as West,ISNULL(SUM(South),0) as South 
FROM (
 SELECT [key],
(CASE WHEN Region = 'North' THEN SUM(QTY) ELSE NULL END ) as NORTH,
(CASE WHEN Region = 'East' THEN SUM(QTY) ELSE NULL END ) as EAST,
(CASE WHEN Region = 'West' THEN SUM(QTY) ELSE NULL END ) as West,
(CASE WHEN Region = 'South' THEN SUM(QTY) ELSE NULL END ) as South
FROM #K_QTY WHERE Date >= DATEADD(Month,-2, @ET)         
GROUP BY [key],Region )a  group by [key])b

----* for Ka_contribution_Percentage START

----* for  KA pivot Quatity START

DROP TABLE IF EXISTS  #KA_WORKING_QTY
SELECT [key], [Forecast Number], [FC Month],[FC Year],'KA' as Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],
IsNull(QM1, 0) AS QM1,IsNull(QM2, 0) AS QM2,IsNull(QM3, 0) AS QM3,IsNull(QM4, 0) AS QM4,IsNull(QM5, 0) AS QM5,IsNull(QM6, 0) AS QM6,IsNull(QM7, 0) AS QM7,
IsNull(QM8, 0) AS QM8,IsNull(QM9, 0) AS QM9,IsNull(QM10, 0) AS QM10,IsNull(QM11, 0) AS QM11,IsNull(QM12, 0) AS QM12,IsNull(QM13, 0) AS QM13,IsNull(QM14, 0) AS QM14,
IsNull(QM15, 0) AS QM15,IsNull(QM16, 0) AS QM16,IsNull(QM17, 0) AS QM17,IsNull(QM18, 0) AS QM18,IsNull(QM19, 0) AS QM19,IsNull(QM20, 0) AS QM20,IsNull(QM21, 0) AS QM21,
IsNull(QM22, 0) AS QM22,IsNull(QM23, 0) AS QM23,IsNull(QM24, 0) AS QM24,IsNull(QM25, 0) AS QM25,IsNull(QM26, 0) AS QM26,IsNull(QM27, 0) AS QM27,IsNull(QM28, 0) AS QM28,
IsNull(QM29, 0) AS QM29,IsNull(QM30, 0) AS QM30,IsNull(QM31, 0) AS QM31,IsNull(QM32, 0) AS QM32,IsNull(QM33, 0) AS QM33,IsNull(QM34, 0) AS QM34,IsNull(QM35, 0) AS QM35,IsNull(QM36,0) as QM36
into #KA_WORKING_QTY
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],Month_Seq_Q, [Qty] FROM #KA_QTY_ONLY) A  
PIVOT  
(  
SUM([Qty]) 
FOR [Month_Seq_Q] IN (
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36)
) B

----* for  KA pivot Quatity END

----* for  KA pivot VALUE START

DROP TABLE IF EXISTS  #KA_WORKING_VALUE
SELECT [key], [Forecast Number], [FC Month],[FC Year],'KA' as Region,Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],
IsNull(VM1, 0) AS VM1,IsNull(VM2, 0) AS VM2,IsNull(VM3, 0) AS VM3,IsNull(VM4, 0) AS VM4,IsNull(VM5, 0) AS VM5,IsNull(VM6, 0) AS VM6,IsNull(VM7, 0) AS VM7,
IsNull(VM8, 0) AS VM8,IsNull(VM9, 0) AS VM9,IsNull(VM10, 0) AS VM10,IsNull(VM11, 0) AS VM11,IsNull(VM12, 0) AS VM12,IsNull(VM13, 0) AS VM13,IsNull(VM14, 0) AS VM14,
IsNull(VM15, 0) AS VM15,IsNull(VM16, 0) AS VM16,IsNull(VM17, 0) AS VM17,IsNull(VM18, 0) AS VM18,IsNull(VM19, 0) AS VM19,IsNull(VM20, 0) AS VM20,IsNull(VM21, 0) AS VM21,
IsNull(VM22, 0) AS VM22,IsNull(VM23, 0) AS VM23,IsNull(VM24, 0) AS VM24,IsNull(VM25, 0) AS VM25,IsNull(VM26, 0) AS VM26,IsNull(VM27, 0) AS VM27,IsNull(VM28, 0) AS VM28,
IsNull(VM29, 0) AS VM29,IsNull(VM30, 0) AS VM30,IsNull(VM31, 0) AS VM31,IsNull(VM32, 0) AS VM32,IsNull(VM33, 0) AS VM33,IsNull(VM34, 0) AS VM34,IsNull(VM35, 0) AS VM35,IsNull(VM36,0) as VM36  
into #KA_WORKING_VALUE
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],Month_Seq_V, [Value] FROM #KA_QTY_ONLY) A  
PIVOT  
(  
SUM([Value]) 
FOR [Month_Seq_V] IN (
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36)
) B

----* for  KA pivot VALUE END

----* for UNIQUE Material_Description START

DROP TABLE IF EXISTS #UNIQUE_MAT_DCRPN
SELECT * INTO #UNIQUE_MAT_DCRPN FROM (
SELECT DISTINCT Mapping_Code as [Mapped Code],
(CASE WHEN B.[Material Description] is null 
	then FIRST_VALUE(A.[Material Description]) OVER (Partition by  Mapping_Code ORDER BY  Mapping_Code desc) 
else b.[Material Description] end) as [Material Description]
FROM Artsana.FAR.Distributor_SKU_Wise_Data A
LEFT JOIN Artsana.FAR.SKU_Artsana B ON A.Mapping_Code = b.[Mat Code]  )a 

----* for UNIQUE Material_Description END

----* for All_pivot_data QTY START --WHERE QM1+QM2+QM3+QM4+QM5+QM6+QM7+QM8+QM9+QM10+QM11+QM12+QM13+QM14+QM15+QM16+QM17+QM18+QM19+QM20+QM21+QM22+QM23+QM24+QM25+QM26+QM27+QM28+QM29+QM30+QM31+QM32+QM33+QM34+QM35+QM36 > 0

DROP TABLE IF EXISTS  #ALL_WORKING_QTY_NO_MAT_DCRPN
SELECT * INTO #ALL_WORKING_QTY_NO_MAT_DCRPN FROM (
SELECT * FROM  #KA_EXCLUDE_WORKING_QTY 
UNION 
SELECT * FROM #KA_WORKING_QTY 
)a

DROP TABLE IF EXISTS Artsana.FAR.ALL_WORKING_QTY
SELECT v.*,c.[Material Description] into Artsana.FAR.ALL_WORKING_QTY FROM #ALL_WORKING_QTY_NO_MAT_DCRPN v ---19054
LEFT JOIN #UNIQUE_MAT_DCRPN c ON v.Mapping_Code = c.[Mapped Code]



----* for All_pivot_data QTY END

----* for All_pivot_data Value START

DROP TABLE IF EXISTS  #ALL_WORKING_Value_NO_MAT_DCRPN --WHERE VM1+VM2+VM3+VM4+VM5+VM6+VM7+VM8+VM9+VM10+VM11+VM12+VM13+VM14+VM15+VM16+VM17+VM18+VM19+VM20+VM21+VM22+VM23+VM24+VM25+VM26+VM27+VM28+VM29+VM30+VM31+VM32+VM33+VM34+VM35+VM36 >0
SELECT * INTO #ALL_WORKING_Value_NO_MAT_DCRPN FROM (
SELECT * FROM  #KA_EXCLUDE_WORKING_Value 
UNION 
SELECT * FROM #KA_WORKING_VALUE 
)a

DROP TABLE IF EXISTS  Artsana.FAR.ALL_WORKING_Value
SELECT v.*,c.[Material Description] into Artsana.FAR.ALL_WORKING_Value FROM #ALL_WORKING_Value_NO_MAT_DCRPN v ---19054
LEFT JOIN #UNIQUE_MAT_DCRPN c ON v.Mapping_Code = c.[Mapped Code]

----* for All_pivot_data Value END


----* for Updating Forecast number in DOA START

Truncate TABLE Artsana.FAR.DOA_Final

INSERT INTO Artsana.FAR.DOA_Final (
		[Forecast Number],[FC Month],[FC Year],[RSM],[RSM_ID],[RSM UserLoginID],[Region],[ZSM Name],[ZSM UserLoginID],[HOD Name],[HOD UserLoginID],
		[Sales Planning Manager],[Sales Planning UserLoginID],[Planner],[Planner UserLoginID],[Channel])

SELECT 'RSM'+CAST([RSM_ID] AS Varchar) +(CASE WHEN Channel = 'KA' THEN '' when  Channel = 'EX' THEN 'E' ELSE LEFT(Region,1) END)
		+Cast(Month(GETDATE()) AS varchar)+cast(Year(GETDATE()) as varchar)+Channel AS [Forecast Number],Month(GETDATE()) AS [FC Month],Year(GETDATE()) AS [FC Year],
		RSM,RSM_ID,[RSM UserLoginID],Region,[ZSM Name],[ZSM UserLoginID],[HOD Name],[HOD UserLoginID],[Sales Planning Manager],[Sales Planning UserLoginID],Planner,[Planner UserLoginID],Channel  
		FROM Artsana.FAR.DOA_RAW

----* for Updating Forecast number in DOA END

----* for Working Classification START

DROP TABLE IF EXISTS  #Month_seq_Prof
SELECT Date,'QM'+CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as varchar) AS Month_Seq_Q,
'VM'+CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as varchar) AS Month_Seq_V 
INTO #Month_seq_Prof
FROM (
SELECT DISTINCT CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) as [Date]  
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels ) a 

DROP TABLE IF EXISTS  #Data_prof
SELECT a.*,CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) as [Date],b.Month_Seq_Q,b.Month_Seq_V
INTO #Data_prof
FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels  a
LEFT JOIN #Month_seq_Prof b ON CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) = b.[Date]

DROP TABLE IF EXISTS  #Data_prof_QTY
SELECT [key], [Forecast Number], [FC Month],[FC Year],'KA' as Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],
IsNull(QM1, 0) AS QM1,IsNull(QM2, 0) AS QM2,IsNull(QM3, 0) AS QM3,IsNull(QM4, 0) AS QM4,IsNull(QM5, 0) AS QM5,IsNull(QM6, 0) AS QM6,IsNull(QM7, 0) AS QM7,
IsNull(QM8, 0) AS QM8,IsNull(QM9, 0) AS QM9,IsNull(QM10, 0) AS QM10,IsNull(QM11, 0) AS QM11,IsNull(QM12, 0) AS QM12,IsNull(QM13, 0) AS QM13,IsNull(QM14, 0) AS QM14,
IsNull(QM15, 0) AS QM15,IsNull(QM16, 0) AS QM16,IsNull(QM17, 0) AS QM17,IsNull(QM18, 0) AS QM18,IsNull(QM19, 0) AS QM19,IsNull(QM20, 0) AS QM20,IsNull(QM21, 0) AS QM21,
IsNull(QM22, 0) AS QM22,IsNull(QM23, 0) AS QM23,IsNull(QM24, 0) AS QM24,IsNull(QM25, 0) AS QM25,IsNull(QM26, 0) AS QM26,IsNull(QM27, 0) AS QM27,IsNull(QM28, 0) AS QM28,
IsNull(QM29, 0) AS QM29,IsNull(QM30, 0) AS QM30,IsNull(QM31, 0) AS QM31,IsNull(QM32, 0) AS QM32,IsNull(QM33, 0) AS QM33,IsNull(QM34, 0) AS QM34,IsNull(QM35, 0) AS QM35,IsNull(QM36,0) as QM36
into #Data_prof_QTY
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],Month_Seq_Q, [Qty] FROM #Data_prof) A  
PIVOT  
(  
SUM([Qty]) 
FOR [Month_Seq_Q] IN (
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36)
) B

DROP TABLE IF EXISTS  #Data_prof_value
SELECT [key], [Forecast Number], [FC Month],[FC Year],'KA' as Region,Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],
IsNull(VM1, 0) AS VM1,IsNull(VM2, 0) AS VM2,IsNull(VM3, 0) AS VM3,IsNull(VM4, 0) AS VM4,IsNull(VM5, 0) AS VM5,IsNull(VM6, 0) AS VM6,IsNull(VM7, 0) AS VM7,
IsNull(VM8, 0) AS VM8,IsNull(VM9, 0) AS VM9,IsNull(VM10, 0) AS VM10,IsNull(VM11, 0) AS VM11,IsNull(VM12, 0) AS VM12,IsNull(VM13, 0) AS VM13,IsNull(VM14, 0) AS VM14,
IsNull(VM15, 0) AS VM15,IsNull(VM16, 0) AS VM16,IsNull(VM17, 0) AS VM17,IsNull(VM18, 0) AS VM18,IsNull(VM19, 0) AS VM19,IsNull(VM20, 0) AS VM20,IsNull(VM21, 0) AS VM21,
IsNull(VM22, 0) AS VM22,IsNull(VM23, 0) AS VM23,IsNull(VM24, 0) AS VM24,IsNull(VM25, 0) AS VM25,IsNull(VM26, 0) AS VM26,IsNull(VM27, 0) AS VM27,IsNull(VM28, 0) AS VM28,
IsNull(VM29, 0) AS VM29,IsNull(VM30, 0) AS VM30,IsNull(VM31, 0) AS VM31,IsNull(VM32, 0) AS VM32,IsNull(VM33, 0) AS VM33,IsNull(VM34, 0) AS VM34,IsNull(VM35, 0) AS VM35,IsNull(VM36,0) as VM36  
into #Data_prof_value
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],[Category 1],Month_Seq_V, [Value] FROM #Data_prof) A  
PIVOT  
(  
SUM([Value]) 
FOR [Month_Seq_V] IN (
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36)
) B

DROP TABLE IF EXISTS  Artsana.FAR.Working_classification
SELECT A.Category,a.Channel,a.Mapping_Code as [Material_Code],a.[RSM ID],c.[ZSM UserLoginID],
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36,
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36
INTO Artsana.FAR.Working_classification 
FROM #Data_prof_QTY A
INNER JOIN #Data_prof_value B ON A.[key] = b.[key]
INNER JOIN Artsana.FAR.DOA_Final C ON A.[RSM ID] =c.RSM_ID

----* for Working Classification END

----* for Tab: Avg_6_Month_Sale-Stock_Till ---*[Qty]* START


DROP TABLE IF EXISTS  Artsana.FAR.[Avg_6_Month_Sale-Stock_Till] 

	SELECT [Mapping_Code] ,M1,M2,M3,M4,M5,M6,[Grand Total], ROUND(([Grand Total]/6),0) AS [Average Sales],[Total Stock] ,
	ROUND(ISNULL([Total Stock]/NULLIF(([Grand Total]/6),0),0),0) AS [Month of Stock] ,
	(CASE WHEN ROUND(ISNULL([Total Stock]/NULLIF(([Grand Total]/6),0),0),0) >= 1 THEN DATEADD(Month,CASE WHEN ROUND(ISNULL([Total Stock]/NULLIF(([Grand Total]/6),0),0),0) >19999 THEN 19999
	ELSE ROUND(ISNULL([Total Stock]/NULLIF(([Grand Total]/6),0),0),0) END, GETDATE()) ELSE NULL END)  As [Stock Till]
INTO Artsana.FAR.[Avg_6_Month_Sale-Stock_Till]
 FROM
	(
	SELECT a.[Mapping_Code], ISNULL(SUM(M1),0)AS M1,ISNULL(SUM(M2),0)AS M2,ISNULL(SUM(M3),0)AS M3,ISNULL(SUM(M4),0)AS M4,ISNULL(SUM(M5),0)AS M5,ISNULL(SUM(M6),0) AS M6,
	(ISNULL(SUM(M1),0) + ISNULL(SUM(M2),0)+ ISNULL(SUM(M3),0)+ ISNULL(SUM(M4),0)+ ISNULL(SUM(M5),0)+ ISNULL(SUM(M6),0)) AS [Grand Total],ISNULL((u.Stock),0) as [Total Stock]
	FROM   
		(
SELECT [Mapping_Code],
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-5, @ET  ) THEN ISNULL([Qty],0)  END) AS 'M1',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-4, @ET   ) THEN ISNULL([Qty],0)  END) AS 'M2',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-3, @ET   ) THEN ISNULL([Qty],0)  END) AS 'M3',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-2, @ET   ) THEN ISNULL([Qty],0)  END) AS 'M4',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = DATEADD(Month,-1, @ET   ) THEN ISNULL([Qty],0)  END) AS 'M5',
			(CASE WHEN CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) = @ET  THEN [Qty]  END) AS 'M6' 
		FROM Artsana.FAR.Artsana_Data_details_base_file_all_channels 
			--where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) BETWEEN @ST AND @ET
		)a 
	 LEFT JOIN 
		(SELECT (CASE WHEN b.[Mapped Code] is null THEN a.Material ELSE b.[Mapped Code] END) AS [Mapped Code], SUM(a.[Total Stock]) As Stock FROM Artsana.FAR.Warehouse_Stock_Report a
		LEFT JOIN Artsana.FAR.Mapping_File_PBI b ON a.Material = b.[Material Code]
		GROUP BY (CASE WHEN b.[Mapped Code] is null THEN a.Material ELSE b.[Mapped Code] END)) u ON a.[Mapping_Code] = u.[Mapped Code]
GROUP BY a.[Mapping_Code],u.Stock)t
	
----* for Tab: Avg_6_Month_Sale-Stock_Till ---*[Qty]* END

----* for Data Detail base file START
DROP TABLE IF EXISTS Artsana.FAR.Data_detail_base
SELECT A.*,YEAR(DATEADD(Year,-2, @ET)) as [Year-1],YEAR(DATEADD(Year,-1, @ET)) as [Year-2],YEAR(DATEADD(Year,0, @ET)) as [Year-3],
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36,
IsNull(YTD_AVG_SALES_Q,0) as YTD_AVG_SALES_Q ,IsNull(YTD_AVG_SALES_V,0) AS YTD_AVG_SALES_V ,IsNull(d.Avg_12M_Sales_Q,0) AS Avg_12M_Sales_Q ,IsNull(d.Avg_12M_Sales_V,0) AS Avg_12M_Sales_V ,
IsNull(e.Avg_6M_Sales_Q,0) AS Avg_6M_Sales_Q ,IsNull(e.Avg_6M_Sales_V,0) AS Avg_6M_Sales_V ,IsNull(f.Avg_3M_Sales_Q,0) AS Avg_3M_Sales_Q ,IsNull(f.Avg_3M_Sales_V,0) AS Avg_3M_Sales_V ,
IsNull(g.LM_SALES_Q,0) AS LM_SALES_Q ,IsNull(g.LM_SALES_V,0) AS LM_SALES_V ,IsNull(h.LYSM1_Q,0) AS LYSM1_Q ,IsNull(h.LYSM1_V,0) AS LYSM1_V ,IsNull(i.LYSM2_Q,0) AS LYSM2_Q ,
IsNull(i.LYSM2_V,0) AS LYSM2_V ,IsNull(j.LYSM3_Q,0) AS LYSM3_Q ,IsNull(j.LYSM3_V,0) AS LYSM3_V ,IsNull(k.LYSM4_Q,0) AS LYSM4_Q ,IsNull(k.LYSM4_V,0) AS LYSM4_V ,IsNull(l.LYSM5_Q,0) AS LYSM5_Q ,
IsNull(l.LYSM5_V,0) AS LYSM5_V ,IsNull(m.LYSM6_Q,0) AS LYSM6_Q ,IsNull(m.LYSM6_V,0) AS LYSM6_V ,IsNull(n.L12_Max_Q,0) AS L12_Max_Q ,IsNull(n.L12_Max_V,0) AS L12_Max_V ,
IsNull(o.L12_Min_Q,0) AS L12_Min_Q ,IsNull(o.L12_Min_V,0) as L12_Min_V,IsNull(P.[M-2],0) as [M-2],IsNull(q.[M-3],0) as [M-3],r.[Stock Till],s.East_Cont,s.North_Cont,s.South_Cont,s.West_Cont
INTO Artsana.FAR.Data_detail_base
FROM Artsana.FAR.ALL_WORKING_QTY A
INNER JOIN Artsana.FAR.ALL_WORKING_Value B ON A.[key] = b.[key]
LEFT JOIN #YTD_AVG_SALES C ON A.[key] = C.[key]
LEFT JOIN #Avg_12M_Sales D ON a.[Key] = d.[key]
LEFT JOIN #Avg_6M_Sales E ON a.[Key] = e.[key]
Left JOIN #Avg_3M_Sales F ON A.[Key] = f.[Key]
LEFT JOIN #LM_SALES G ON a.[Key] = g.[Key]
LEFT JOIN #LYSM1 H ON a.[Key] = h.[Key]
LEFT JOIN #LYSM2 i ON a.[Key] = i.[Key]
LEFT JOIN #LYSM3 j ON a.[Key] = j.[Key]
LEFT JOIN #LYSM4 k ON a.[Key] = k.[Key]
LEFT JOIN #LYSM5 l ON a.[Key] = l.[Key]
LEFT JOIN #LYSM6 m ON a.[Key] = m.[Key]
LEFT JOIN #L12Max n ON a.[Key] = n.[Key]
LEFT JOIN #L12Min o ON a.[Key] = o.[Key]
LEFT JOIN #M_2 p ON a.[Key] = p.[Key]
LEFT JOIN #M_3 q ON a.[Key] = q.[Key]
LEFT JOIN Artsana.FAR.[Avg_6_Month_Sale-Stock_Till] r ON a.Mapping_Code =r.Mapping_Code
LEFT JOIN #KA_Contribution s ON a.[key] = s.[key]

----* for Data Detail base file END

END