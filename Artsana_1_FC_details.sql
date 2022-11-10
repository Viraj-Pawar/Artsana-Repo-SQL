USE [Artsana]
GO
/****** Object:  StoredProcedure [Test].[Artsana_1_Model_Input]    Script Date: 09-11-2022 10:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----RAW FILES USED
--1) 
--2) 
--3) 
--4) 
--5) 

ALTER PROCEDURE [Test].[Artsana_1_FC_Details]
----EXEC  [Test].[Artsana_1_Model_Input]
AS
BEGIN

----* for mapping file_extracolumn START----	

	DROP TABLE IF EXISTS Artsana.test.[mapping file_extracolumn]
		select *  into Artsana.test.[mapping file_extracolumn] from 
			(SELECT * ,ROW_NUMBER() OVER(partition by [Mapped Code] order by [Mapped Code]) AS RN from 
				(SELECT a.*,b.[sfa category] AS Subgroup,line1,line2,line3,line4
					FROM   Artsana.test.[mapping file] a
				LEFT JOIN (SELECT DISTINCT [Mapping_Code],[sfa category],line1,line2,line3,line4
							FROM   Artsana.test.distributor_sku_wise_data) b
			ON a.[Mapped Code] = b.[Mapping_Code]) t1) t
		WHERE  RN = 1

----* for mapping file_extracolumn END----


----* for Artsana_Data details_base file-all channels-Sep START

DECLARE @ET AS Date
SELECT @ET = (DATEADD(Month,0,(SELECT TOP 1 CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) FROM Artsana.Test.Sales_Data
									ORDER BY CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date)DESC)))

								

DROP TABLE IF EXISTS Artsana.Test.Artsana_Data_details_base_file_all_channels -- (597522 rows affected)
SELECT * into Artsana.Test.Artsana_Data_details_base_file_all_channels FROM
(
SELECT [Key],[Year],[Month],A.[Mapping_Code],
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
([Value(in Lakhs)]*100000) AS [Value],[Channel Active List] as [Active Channel],[Active Key],ShPt,City,State
FROM Artsana.Test.Distributor_SKU_Wise_Data A
LEFT JOIN Artsana.Test.active_list_Sequence B ON A.[Mapping_Code] = B.[Material Code]
LEFT JOIN Artsana.Test.[mapping file_extracolumn] C ON A.[Mapping_Code] = C.[Mapped Code]
) T  where CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) > DATEADD(YEAR,-3, @ET)


----* for Artsana_Data details_base file-all channels-Sep END

----* for Creating Month seq START

DROP TABLE IF EXISTS  #Month_seq
SELECT Date,'QM'+CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as varchar) AS Month_Seq_Q,
'VM'+CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as varchar) AS Month_Seq_V INTO #Month_seq FROM (
SELECT DISTINCT CAST((CAST([Year] AS VARCHAR)+'-'+CAST([Month] AS VARCHAR)+'-01') AS date) as [Date]  
FROM Artsana.Test.Artsana_Data_details_base_file_all_channels ) a 

----* for Creating Month seq END

----* for sales data excluiding KA and adding Month seq START

DROP TABLE IF EXISTS  #NOT_KA_QTY_ONLY
SELECT a.*,CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) as [Date],b.Month_Seq_Q,b.Month_Seq_V
INTO #NOT_KA_QTY_ONLY FROM Artsana.Test.Artsana_Data_details_base_file_all_channels  a
LEFT JOIN #Month_seq b ON CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) = b.[Date]
where a.Channel != 'KA'--( 352953 rows affected) SELECT * FROM  #NOT_KA_QTY_ONLY

----* for sales data excluiding KA and adding Month seq END

----* for EXCLUDING KA pivot Quatity START

DROP TABLE IF EXISTS  #KA_EXCLUDE_WORKING_QTY
SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Description, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36  into #KA_EXCLUDE_WORKING_QTY
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Description, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,Month_Seq_Q, [Qty] FROM #NOT_KA_QTY_ONLY) A  
PIVOT  
(  
SUM([Qty]) 
FOR [Month_Seq_Q] IN (
QM1,QM2,QM3,QM4,QM5,QM6,QM7,QM8,QM9,QM10,QM11,QM12,QM13,QM14,QM15,QM16,QM17,QM18,QM19,QM20,QM21,QM22,QM23,QM24,QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36)
) B

----* for EXCLUDING KA pivot Quatity END

----* for EXCLUDING KA pivot VALUE START

DROP TABLE IF EXISTS  #KA_EXCLUDE_WORKING_VALUE
SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Description, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36  into #KA_EXCLUDE_WORKING_VALUE
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Description, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,Month_Seq_V, [Value] FROM #NOT_KA_QTY_ONLY) A  
PIVOT  
(  
SUM([Value]) 
FOR [Month_Seq_V] IN (
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36)
) B

----* for EXCLUDING KA pivot VALUE END

END