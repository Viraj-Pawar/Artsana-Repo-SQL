import pandas as pd
import pyodbc

# Connect to SQL Server
conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=db.3scsolution.lan;'
                      'Database=Artsana;'
                      'Trusted_Connection=yes;')

# Read the table into a pandas DataFrame
Data_detail = pd.read_sql("SELECT  * FROM FAR.Data_detail", conn)

# Sort the DataFrame by the 'Salary' column in ascending order
Data_detail = Data_detail.sort_values('Sequence')

# Adding IsActive column to table
Data_detail['IsActive'] = Data_detail['Sequence'].apply(lambda x: '1' if x >=1 else '0')

# Rearrange the columns and create an alias for the column
Data_detail = Data_detail.reindex(columns=['key', 'Forecast Number', 'FC Month', 'FC Year', 'Region', 'Channel', 'Material_Code', 'Material Description', 'Category', 'ASM_Class', 'ASP', 'RSM', 
                                           'RSM ID', 'Material Status', 'YTD_AVG_SALES_Q', 'Avg_12M_Sales_Q', 'Avg_6M_Sales_Q', 'Avg_3M_Sales_Q', 'LM_SALES_Q', 'LYSM1_Q', 'LYSM2_Q', 'LYSM3_Q', 
                                           'M1_QTY_3SC', 'M2_QTY_3SC', 'M3_QTY_3SC', 'M4_QTY_3SC', 'M5_QTY_3SC', 'M6_QTY_3SC', 'M7_QTY_3SC', 'M8_QTY_3SC', 'M9_QTY_3SC', 'M10_QTY_3SC', 'M11_QTY_3SC',
                                           'M12_QTY_3SC', 'M1_Qty', 'M2_Qty', 'M3_Qty', 'M4_Qty', 'M5_Qty', 'M6_Qty', 'M7_Qty', 'M8_Qty', 'M9_Qty', 'M10_Qty', 'M11_Qty', 'M12_Qty', 'L12_Min_Q',
                                           'L12_Max_Q', 'M-1', 'M-2', 'M-3', 'LYSM4_Q', 'LYSM5_Q', 'LYSM6_Q', 'Status', 'Domestic/Import', 'ABC (Qty)', 'AVG_6M_Forecast', 'Stock Till', 'Sub_Group',
                                           'Line1', 'Line2', 'Line3', 'Line4', 'Year-1_Q', 'QM1', 'QM2', 'QM3', 'QM4', 'QM5', 'QM6', 'QM7', 'QM8', 'QM9', 'QM10',
                                  'QM11', 'QM12', 'Year-2_Q', 'QM13', 'QM14', 'QM15', 'QM16', 'QM17', 'QM18', 'QM19', 'QM20', 'QM21', 'QM22', 'QM23', 'QM24', 'Year-3_Q', 'QM25', 'QM26', 'QM27',
                                  'QM28', 'QM29', 'QM30', 'QM31', 'QM32', 'QM33', 'QM34', 'QM35', 'QM36', 'YTD_AVG_SALES_V', 'Avg_12M_Sales_V', 'L12_Max_V', 'L12_Min_V', 'Avg_6M_Sales_V', 
                                  'Avg_3M_Sales_V', 'LM_SALES_V', 'LYSM1_V', 'LYSM2_V', 'LYSM3_V', 'LYSM4_V', 'LYSM5_V', 'LYSM6_V', 'Year-1_V', 'VM1', 'VM2', 'VM3', 'VM4', 'VM5', 'VM6', 'VM7',
                                  'VM8', 'VM9', 'VM10', 'VM11', 'VM12', 'Year-2_V', 'VM13', 'VM14', 'VM15', 'VM16', 'VM17', 'VM18', 'VM19', 'VM20', 'VM21', 'VM22', 'VM23', 'VM24', 'Year-3_V', 
                                  'VM25', 'VM26', 'VM27', 'VM28', 'VM29', 'VM30', 'VM31', 'VM32', 'VM33', 'VM34', 'VM35', 'VM36', 'Category 1', 'East_Cont', 'North_Cont', 'South_Cont', 'West_Cont',
                                  'IsActive','ZSM_class', 'NSM_class', 'National_level_class', 'ZSM UserLoginID', 'Sequence']).rename(
                                      columns={'Forecast Number':'Forecast No','FC Month':'FC_Month','FC Year':'FC_Year','Region':'Region','Channel':'Channel','Material_Code':'Material Code',
                                               'Material Description':'Material Description','Category':'Category','ASM_Class':'Class','ASP':'ASP','RSM':'RSM','RSM ID':'RSM_ID','Material Status':'Material Status',
                                               'YTD_AVG_SALES_Q':'YTD_Avg_Sales','Avg_12M_Sales_Q':'12M_Avg_Sales','Avg_6M_Sales_Q':'6M_Avg_Sales','Avg_3M_Sales_Q':'3M_Avg_Sales','LM_SALES_Q':'LM_Sales','LYSM1_Q':'LYSM1_Sales',
                                               'LYSM2_Q':'LYSM2_Sales','LYSM3_Q':'LYSM3_Sales','M1_QTY_3SC':'M1_QTY_3SC','M2_QTY_3SC':'M2_QTY_3SC','M3_QTY_3SC':'M3_QTY_3SC','M4_QTY_3SC':'M4_QTY_3SC','M5_QTY_3SC':'M5_QTY_3SC',
                                               'M6_QTY_3SC':'M6_QTY_3SC','M7_QTY_3SC':'M7_QTY_3SC','M8_QTY_3SC':'M8_QTY_3SC','M9_QTY_3SC':'M9_QTY_3SC','M10_QTY_3SC':'M10_QTY_3SC','M11_QTY_3SC':'M11_QTY_3SC',
                                               'M12_QTY_3SC':'M12_QTY_3SC','M1_Qty':'M1_Qty','M2_Qty':'M2_Qty','M3_Qty':'M3_Qty','M4_Qty':'M4_Qty','M5_Qty':'M5_Qty','M6_Qty':'M6_Qty','M7_Qty':'M7_Qty','M8_Qty':'M8_Qty',
                                               'M9_Qty':'M9_Qty','M10_Qty':'M10_Qty','M11_Qty':'M11_Qty','M12_Qty':'M12_Qty','L12_Min_Q':'L12Min','L12_Max_Q':'L12Max','M-1':'M-1','M-2':'M-2','M-3':'M-3','LYSM4_Q':'LYSM4_Sales',
                                               'LYSM5_Q':'LYSM5_Sales','LYSM6_Q':'LYSM6_Sales','Status':'Status','Domestic/Import':'Domestic/Import','ABC (Qty)':'ABC (Qty)','AVG_6M_Forecast':'6M_Avg_Forecast',
                                               'Stock Till':'Stock Till','Sub_Group':'Subgroup','Line1':'Line1','Line2':'Line2','Line3':'Line3','Line4':'Line4','Year-1_Q':'Y2020','QM1':'Y202001','QM2':'Y202002','QM3':'Y202003',
                                               'QM4':'Y202004','QM5':'Y202005','QM6':'Y202006','QM7':'Y202007','QM8':'Y202008','QM9':'Y202009','QM10':'Y202010','QM11':'Y202011','QM12':'Y202012','Year-2_Q':'Y2021',
                                               'QM13':'Y202101','QM14':'Y202102','QM15':'Y202103','QM16':'Y202104','QM17':'Y202105','QM18':'Y202106','QM19':'Y202107','QM20':'Y202108','QM21':'Y202109','QM22':'Y202110',
                                               'QM23':'Y202111','QM24':'Y202112','Year-3_Q':'Y2022','QM25':'Y202201','QM26':'Y202202','QM27':'Y202203','QM28':'Y202204','QM29':'Y202205','QM30':'Y202206','QM31':'Y202207',
                                               'QM32':'Y202208','QM33':'Y202209','QM34':'Y202210','QM35':'Y202211','QM36':'Y202212','YTD_AVG_SALES_V':'YTD_Avg_Sales_V','Avg_12M_Sales_V':'12M_Avg_Sales_V','L12_Max_V':'L12Max_V',
                                               'L12_Min_V':'L12Min_V','Avg_6M_Sales_V':'6M_Avg_Sales_V','Avg_3M_Sales_V':'3M_Avg_Sales_V','LM_SALES_V':'LM_Sales_V','LYSM1_V':'LYSM1_Sales_V','LYSM2_V':'LYSM2_Sales_V',
                                               'LYSM3_V':'LYSM3_Sales_V','LYSM4_V':'LYSM4_Sales_V','LYSM5_V':'LYSM5_Sales_V','LYSM6_V':'LYSM6_Sales_V','Year-1_V':'VY2021','VM1':'VY202101','VM2':'VY202102','VM3':'VY202103',
                                               'VM4':'VY202104','VM5':'VY202105','VM6':'VY202106','VM7':'VY202107','VM8':'VY202108','VM9':'VY202109','VM10':'VY202110','VM11':'VY202111','VM12':'VY202112','Year-2_V':'VY2022',
                                               'VM13':'VY202201','VM14':'VY202202','VM15':'VY202203','VM16':'VY202204','VM17':'VY202205','VM18':'VY202206','VM19':'VY202207','VM20':'VY202208','VM21':'VY202209','VM22':'VY202210',
                                               'VM23':'VY202211','VM24':'VY202212','Year-3_V':'VY2023','VM25':'VY202301','VM26':'VY202302','VM27':'VY202303','VM28':'VY202304','VM29':'VY202305','VM30':'VY202306','VM31':'VY202307',
                                               'VM32':'VY202308','VM33':'VY202309','VM34':'VY202310','VM35':'VY202311','VM36':'VY202312','Category 1':'Category1','East_Cont':'East_Cont','North_Cont':'North_Cont',
                                               'South_Cont':'South_Cont','West_Cont':'West_Cont','IsActive':'IsActive','ZSM_class':'ZSM Class','NSM_class':'NSM Class','National_level_class':'National Level Class'})


Data_D = Data_detail[['Forecast No','FC_Month','FC_Year','Region','Channel','Material Code','Material Description','Category','Class','ASP','RSM','RSM_ID','Material Status','YTD_Avg_Sales','12M_Avg_Sales',
       '6M_Avg_Sales','3M_Avg_Sales','LM_Sales','LYSM1_Sales','LYSM2_Sales','LYSM3_Sales','M1_QTY_3SC','M2_QTY_3SC','M3_QTY_3SC','M4_QTY_3SC','M5_QTY_3SC','M6_QTY_3SC','M7_QTY_3SC','M8_QTY_3SC',
       'M9_QTY_3SC','M10_QTY_3SC','M11_QTY_3SC','M12_QTY_3SC','M1_Qty','M2_Qty','M3_Qty','M4_Qty','M5_Qty','M6_Qty','M7_Qty','M8_Qty','M9_Qty','M10_Qty','M11_Qty','M12_Qty','L12Min','L12Max',
       'M-1','M-2','M-3','LYSM4_Sales','LYSM5_Sales','LYSM6_Sales','Status','Domestic/Import','ABC (Qty)','6M_Avg_Forecast','Stock Till','Subgroup','Line1','Line2','Line3','Line4','Y2020',
       'Y202001','Y202002','Y202003','Y202004','Y202005','Y202006','Y202007','Y202008','Y202009','Y202010','Y202011','Y202012','Y2021','Y202101','Y202102','Y202103','Y202104','Y202105','Y202106',
       'Y202107','Y202108','Y202109','Y202110','Y202111','Y202112','Y2022','Y202201','Y202202','Y202203','Y202204','Y202205','Y202206','Y202207','Y202208','Y202209','Y202210','Y202211','Y202212',
       'YTD_Avg_Sales_V','12M_Avg_Sales_V','L12Max_V','L12Min_V','6M_Avg_Sales_V','3M_Avg_Sales_V','LM_Sales_V','LYSM1_Sales_V','LYSM2_Sales_V','LYSM3_Sales_V','LYSM4_Sales_V','LYSM5_Sales_V',
       'LYSM6_Sales_V','VY2021','VY202101','VY202102','VY202103','VY202104','VY202105','VY202106','VY202107','VY202108','VY202109','VY202110','VY202111','VY202112','VY2022','VY202201','VY202202',
       'VY202203','VY202204','VY202205','VY202206','VY202207','VY202208','VY202209','VY202210','VY202211','VY202212','VY2023','VY202301','VY202302','VY202303','VY202304','VY202305','VY202306',
       'VY202307','VY202308','VY202309','VY202310','VY202311','VY202312','Category1','East_Cont','North_Cont','South_Cont','West_Cont','IsActive','ZSM Class','NSM Class','National Level Class']]


# Group the DataFrame by the values in the 'column_name' column
groups = Data_D.groupby('Channel')

# Iterate over the groups and save each one to a separate Excel file
for name, group in groups:
    # Create a new Excel file for the group
    filename = f"{name}_DD.xlsx"
    writer = pd.ExcelWriter(filename, engine='xlsxwriter')
    
    # Write the group to a new sheet in the Excel file
    group.to_excel(writer, sheet_name='Sheet1', index=False)
    
    # Save the Excel file
    writer.save()

    # Read the table into a pandas SKU_Master
    SKU_Master = pd.read_sql("SELECT  * FROM FAR.SKU_Master", conn)

    #adding Additional required column
    SKU_Master['SKU_Class'] = ''
    SKU_Master['Seasonal'] = ''
    SKU_Master['Business_Type'] = SKU_Master['Channel'] 

    # Rearrange the columns and create an alias for the column
    SKU_Master = SKU_Master.reindex(columns=['Material_Code','Material Description','Category','SKU_Class','Seasonal','Business_Type','Channel','ASP','Status']).rename(
                                      columns={'Material_Code':'Material Code'})
    
    # Group the DataFrame by the values in the 'column_name' column
    groups = SKU_Master.groupby('Channel')


    # Iterate over the groups and save each one to a separate Excel file
for name, group in groups:
    # Create a new Excel file for the group
    filename = f"{name}_SKU.xlsx"
    writer = pd.ExcelWriter(filename, engine='xlsxwriter')
    
    # Write the group to a new sheet in the Excel file
    group.to_excel(writer, sheet_name='Sheet1', index=False)
    
    # Save the Excel file
    writer.save()

    # Read the table into a pandas SKU_Master
    DOA = pd.read_sql("SELECT  * FROM FAR.DOA_Final", conn)

    DOA = DOA.reindex(columns=['Forecast Number',	'FC Month',	'FC Year',	'RSM',	'RSM_ID',	'RSM UserLoginID',	'Region',	'ZSM Name',	'ZSM UserLoginID',	'HOD Name',	'HOD UserLoginID',	'Sales Planning Manager',	'Sales Planning UserLoginID',	'Planner',	'Planner UserLoginID',	'Channel'
                           ]) .rename(columns={'Forecast Number':'Forecast No','FC Month':'FC_Month','FC Year':'FC_Year'})
    # Group the DataFrame by the values in the 'column_name' column
    groups = DOA.groupby('Channel')

    # Iterate over the groups and save each one to a separate Excel file
for name, group in groups:
    # Create a new Excel file for the group
    filename = f"{name}_DOA.xlsx"
    writer = pd.ExcelWriter(filename, engine='xlsxwriter')
    
    # Write the group to a new sheet in the Excel file
    group.to_excel(writer, sheet_name='Sheet1', index=False)
    
    # Save the Excel file
    writer.save()
