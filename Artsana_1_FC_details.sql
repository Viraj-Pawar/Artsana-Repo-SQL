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

ALTER PROCEDURE [Test].[Artsana_1_FC_Details_Base]
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
(CASE WHEN B.[Category1] is null THEN A.Category ELSE B.Category1 END) AS Category,
(CASE WHEN B.[Category] is null THEN A.Category1 ELSE B.Category END) AS Category1,
(CASE WHEN B.[Material Status] is null THEN 'Inactive' ELSE B.[Material Status] END) AS [Material Status],
(CASE WHEN B.[Purchasing Source (Imported/ Domestic)] is null THEN 'Inactive' ELSE B.[Purchasing Source (Imported/ Domestic)] END) AS [Domestic/Import],
Channel,[RSM ID],[FC Month],[FC Year],[Forecast Number],(CASE WHEN Channel = 'EX' THEN 'EXPORT' ELSE Zone END) AS Region,A.[NSM ],[RSM/ZSM ],A.[USER ID] AS [ABC (Qty)],
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
--LEFT JOIN #DISTINCT_DISTRIBUTOR_FILE D ON A.[Mat Code] = D.[Mat Code]
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
SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,
IsNull(QM1, 0) AS QM1,IsNull(QM2, 0) AS QM2,IsNull(QM3, 0) AS QM3,IsNull(QM4, 0) AS QM4,IsNull(QM5, 0) AS QM5,IsNull(QM6, 0) AS QM6,IsNull(QM7, 0) AS QM7,
IsNull(QM8, 0) AS QM8,IsNull(QM9, 0) AS QM9,IsNull(QM10, 0) AS QM10,IsNull(QM11, 0) AS QM11,IsNull(QM12, 0) AS QM12,IsNull(QM13, 0) AS QM13,IsNull(QM14, 0) AS QM14,
IsNull(QM15, 0) AS QM15,IsNull(QM16, 0) AS QM16,IsNull(QM17, 0) AS QM17,IsNull(QM18, 0) AS QM18,IsNull(QM19, 0) AS QM19,IsNull(QM20, 0) AS QM20,IsNull(QM21, 0) AS QM21,
IsNull(QM22, 0) AS QM22,IsNull(QM23, 0) AS QM23,IsNull(QM24, 0) AS QM24,IsNull(QM25, 0) AS QM25,IsNull(QM26, 0) AS QM26,IsNull(QM27, 0) AS QM27,IsNull(QM28, 0) AS QM28,
IsNull(QM29, 0) AS QM29,IsNull(QM30, 0) AS QM30,IsNull(QM31, 0) AS QM31,IsNull(QM32, 0) AS QM32,IsNull(QM33, 0) AS QM33,IsNull(QM34, 0) AS QM34,IsNull(QM35, 0) AS QM35,
IsNull(QM36,0) as QM36
into #KA_EXCLUDE_WORKING_QTY
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
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
SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,
IsNull(VM1, 0) AS VM1,IsNull(VM2, 0) AS VM2,IsNull(VM3, 0) AS VM3,IsNull(VM4, 0) AS VM4,IsNull(VM5, 0) AS VM5,IsNull(VM6, 0) AS VM6,IsNull(VM7, 0) AS VM7,
IsNull(VM8, 0) AS VM8,IsNull(VM9, 0) AS VM9,IsNull(VM10, 0) AS VM10,IsNull(VM11, 0) AS VM11,IsNull(VM12, 0) AS VM12,IsNull(VM13, 0) AS VM13,IsNull(VM14, 0) AS VM14,
IsNull(VM15, 0) AS VM15,IsNull(VM16, 0) AS VM16,IsNull(VM17, 0) AS VM17,IsNull(VM18, 0) AS VM18,IsNull(VM19, 0) AS VM19,IsNull(VM20, 0) AS VM20,IsNull(VM21, 0) AS VM21,
IsNull(VM22, 0) AS VM22,IsNull(VM23, 0) AS VM23,IsNull(VM24, 0) AS VM24,IsNull(VM25, 0) AS VM25,IsNull(VM26, 0) AS VM26,IsNull(VM27, 0) AS VM27,IsNull(VM28, 0) AS VM28,
IsNull(VM29, 0) AS VM29,IsNull(VM30, 0) AS VM30,IsNull(VM31, 0) AS VM31,IsNull(VM32, 0) AS VM32,IsNull(VM33, 0) AS VM33,IsNull(VM34, 0) AS VM34,IsNull(VM35, 0) AS VM35,IsNull(VM36,0) as VM36
into #KA_EXCLUDE_WORKING_VALUE
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,Month_Seq_V, [Value] FROM #NOT_KA_QTY_ONLY) A  
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
INTO #KA_QTY_ONLY FROM Artsana.Test.Artsana_Data_details_base_file_all_channels  a
LEFT JOIN #Month_seq b ON CAST((CAST(a.[Year] AS VARCHAR)+'-'+CAST(a.[Month] AS VARCHAR)+'-01') AS date) = b.[Date]
where a.Channel = 'KA'

----* for sales data for KA and adding Month seq END

----* for  KA pivot Quatity START

DROP TABLE IF EXISTS  #KA_WORKING_QTY
SELECT [key], [Forecast Number], [FC Month],[FC Year],'KA' as Region,Channel,Mapping_Code, Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,
IsNull(QM1, 0) AS QM1,IsNull(QM2, 0) AS QM2,IsNull(QM3, 0) AS QM3,IsNull(QM4, 0) AS QM4,IsNull(QM5, 0) AS QM5,IsNull(QM6, 0) AS QM6,IsNull(QM7, 0) AS QM7,
IsNull(QM8, 0) AS QM8,IsNull(QM9, 0) AS QM9,IsNull(QM10, 0) AS QM10,IsNull(QM11, 0) AS QM11,IsNull(QM12, 0) AS QM12,IsNull(QM13, 0) AS QM13,IsNull(QM14, 0) AS QM14,
IsNull(QM15, 0) AS QM15,IsNull(QM16, 0) AS QM16,IsNull(QM17, 0) AS QM17,IsNull(QM18, 0) AS QM18,IsNull(QM19, 0) AS QM19,IsNull(QM20, 0) AS QM20,IsNull(QM21, 0) AS QM21,
IsNull(QM22, 0) AS QM22,IsNull(QM23, 0) AS QM23,IsNull(QM24, 0) AS QM24,IsNull(QM25, 0) AS QM25,IsNull(QM26, 0) AS QM26,IsNull(QM27, 0) AS QM27,IsNull(QM28, 0) AS QM28,
IsNull(QM29, 0) AS QM29,IsNull(QM30, 0) AS QM30,IsNull(QM31, 0) AS QM31,IsNull(QM32, 0) AS QM32,IsNull(QM33, 0) AS QM33,IsNull(QM34, 0) AS QM34,IsNull(QM35, 0) AS QM35,IsNull(QM36,0) as QM36
into #KA_WORKING_QTY
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,Month_Seq_Q, [Qty] FROM #KA_QTY_ONLY) A  
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
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,
IsNull(VM1, 0) AS VM1,IsNull(VM2, 0) AS VM2,IsNull(VM3, 0) AS VM3,IsNull(VM4, 0) AS VM4,IsNull(VM5, 0) AS VM5,IsNull(VM6, 0) AS VM6,IsNull(VM7, 0) AS VM7,
IsNull(VM8, 0) AS VM8,IsNull(VM9, 0) AS VM9,IsNull(VM10, 0) AS VM10,IsNull(VM11, 0) AS VM11,IsNull(VM12, 0) AS VM12,IsNull(VM13, 0) AS VM13,IsNull(VM14, 0) AS VM14,
IsNull(VM15, 0) AS VM15,IsNull(VM16, 0) AS VM16,IsNull(VM17, 0) AS VM17,IsNull(VM18, 0) AS VM18,IsNull(VM19, 0) AS VM19,IsNull(VM20, 0) AS VM20,IsNull(VM21, 0) AS VM21,
IsNull(VM22, 0) AS VM22,IsNull(VM23, 0) AS VM23,IsNull(VM24, 0) AS VM24,IsNull(VM25, 0) AS VM25,IsNull(VM26, 0) AS VM26,IsNull(VM27, 0) AS VM27,IsNull(VM28, 0) AS VM28,
IsNull(VM29, 0) AS VM29,IsNull(VM30, 0) AS VM30,IsNull(VM31, 0) AS VM31,IsNull(VM32, 0) AS VM32,IsNull(VM33, 0) AS VM33,IsNull(VM34, 0) AS VM34,IsNull(VM35, 0) AS VM35,IsNull(VM36,0) as VM36  
into #KA_WORKING_VALUE
FROM  
(SELECT [key], [Forecast Number], [FC Month],[FC Year],Channel,Mapping_Code,Category,RSM,[RSM ID],
[Material Status],[Domestic/Import],[ABC (Qty)],Category1,Month_Seq_V, [Value] FROM #KA_QTY_ONLY) A  
PIVOT  
(  
SUM([Value]) 
FOR [Month_Seq_V] IN (
VM1,VM2,VM3,VM4,VM5,VM6,VM7,VM8,VM9,VM10,VM11,VM12,VM13,VM14,VM15,VM16,VM17,VM18,VM19,VM20,VM21,VM22,VM23,VM24,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36)
) B

----* for  KA pivot VALUE END

----* for UNIQUE Material_Description START

DROP TABLE IF EXISTS #DISTINCT_DISTRIBUTOR_FILE
SELECT * INTO #DISTINCT_DISTRIBUTOR_FILE FROM  (
SELECT DISTINCT [Mat Code],Mapping_Code, FIRST_VALUE([Material Description]) OVER (Partition by  [Mat Code] ORDER BY  [Mat Code]) as [Material_Description],
FIRST_VALUE([Category1]) OVER (Partition by  [Mat Code] ORDER BY  [Mat Code]) as [Category1],FIRST_VALUE([Category]) OVER (Partition by  [Mat Code] ORDER BY  [Mat Code]) as [Category]
FROM Artsana.Test.Distributor_SKU_Wise_Data)a 
where [Mat Code] = Mapping_Code 

------
DROP TABLE IF EXISTS #UNIQUE_MAT_DCRPN
SELECT *  INTO #UNIQUE_MAT_DCRPN FROM (
select [Mapped Code],[Material Description] from Artsana.Test.[mapping file_extracolumn]
UNION 
select DISTINCT Mapping_Code as [Mapped Code], Material_Description as [Material Description]   
from 
(
SELECT a.*,b.* FROM #DISTINCT_DISTRIBUTOR_FILE a
LEFT JOIN Artsana.Test.[mapping file_extracolumn] b ON a.Mapping_Code = b.[Mapped Code]
)t WHERE RN is null) e

----* for UNIQUE Material_Description END

----* for All_pivot_data QTY START --WHERE QM1+QM2+QM3+QM4+QM5+QM6+QM7+QM8+QM9+QM10+QM11+QM12+QM13+QM14+QM15+QM16+QM17+QM18+QM19+QM20+QM21+QM22+QM23+QM24+QM25+QM26+QM27+QM28+QM29+QM30+QM31+QM32+QM33+QM34+QM35+QM36 > 0

DROP TABLE IF EXISTS  #ALL_WORKING_QTY_NO_MAT_DCRPN
SELECT * INTO #ALL_WORKING_QTY_NO_MAT_DCRPN FROM (
SELECT * FROM  #KA_EXCLUDE_WORKING_QTY 
UNION 
SELECT * FROM #KA_WORKING_QTY 
)a

DROP TABLE IF EXISTS Artsana.Test.ALL_WORKING_QTY
SELECT v.*,c.[Material Description] into Artsana.Test.ALL_WORKING_QTY FROM #ALL_WORKING_QTY_NO_MAT_DCRPN v ---19054
LEFT JOIN #UNIQUE_MAT_DCRPN c ON v.Mapping_Code = c.[Mapped Code]


----* for All_pivot_data QTY END

----* for All_pivot_data Value START

DROP TABLE IF EXISTS  #ALL_WORKING_Value_NO_MAT_DCRPN --WHERE VM1+VM2+VM3+VM4+VM5+VM6+VM7+VM8+VM9+VM10+VM11+VM12+VM13+VM14+VM15+VM16+VM17+VM18+VM19+VM20+VM21+VM22+VM23+VM24+VM25+VM26+VM27+VM28+VM29+VM30+VM31+VM32+VM33+VM34+VM35+VM36 >0
SELECT * INTO #ALL_WORKING_Value_NO_MAT_DCRPN FROM (
SELECT * FROM  #KA_EXCLUDE_WORKING_Value 
UNION 
SELECT * FROM #KA_WORKING_VALUE 
)a

DROP TABLE IF EXISTS  Artsana.Test.ALL_WORKING_Value
SELECT v.*,c.[Material Description] into Artsana.Test.ALL_WORKING_Value FROM #ALL_WORKING_Value_NO_MAT_DCRPN v ---19054
LEFT JOIN #UNIQUE_MAT_DCRPN c ON v.Mapping_Code = c.[Mapped Code]

----* for All_pivot_data Value END


----* for Updating Forecast number in DOA START

DROP TABLE IF EXISTS  Artsana.test.DOA_Final
SELECT 'RSM'+CAST([RSM_ID] AS Varchar) +(CASE WHEN Channel = 'KA' THEN '' when  Channel = 'EX' THEN 'E' ELSE LEFT(Region,1) END)
		+Cast(Month(GETDATE()) AS varchar)+cast(Year(GETDATE()) as varchar)+Channel AS [Forecast Number],Month(GETDATE()) AS [FC Month],Year(GETDATE()) AS [FC Year],
		RSM,RSM_ID,[RSM UserLoginID],Region,[ZSM Name],[ZSM UserLoginID],[HOD Name],[HOD UserLoginID],[Sales Planning Manager],[Sales Planning UserLoginID],Planner,[Planner UserLoginID],Channel  
		into Artsana.test.DOA_Final FROM (
SELECT * FROM Artsana.test.DOA_RAW) a

----* for Updating Forecast number in DOA END


SELECT A.Category,a.Channel,a.Mapping_Code as [Material_Code],a.[RSM ID],
QM25,QM26,QM27,QM28,QM29,QM30,QM31,QM32,QM33,QM34,QM35,QM36,VM25,VM26,VM27,VM28,VM29,VM30,VM31,VM32,VM33,VM34,VM35,VM36 FROM Artsana.Test.ALL_WORKING_QTY A
RIGHT JOIN Artsana.Test.ALL_WORKING_Value B ON A.[key] = b.[key]

END


