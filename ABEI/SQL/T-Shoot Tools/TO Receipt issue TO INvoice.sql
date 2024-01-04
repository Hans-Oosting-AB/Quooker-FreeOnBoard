/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000)*
  FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Created_TransportOrder_Receipts] (nolock)
  WHERE   
  bkstnr  IN (23614977 ,23982429 , 23917283)
 --WHERE (syscreated > '2023-11-15 09:15'AND syscreated < '2023-11-15 09:25')
 --OR (sysmodified > '2023-11-15 09:22'AND sysmodified < '2023-11-15 09:25')
 OR [ordernr] = 90059387 