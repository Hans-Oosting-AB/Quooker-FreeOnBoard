
SELECT TOP (1000) OrdDbl.ordernr, L.*
  FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Log] L (nolock)
INNER JOIN (
		SELECT TOP (1000) runid
		FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Log] L2 (nolock)
		WHERE message = 'Found: 2 newly delivered created Transport Orders'
	) L2Runs -- Runs that detect 2 TO's in one run
	ON L2Runs.RunId = L.RunId
INNER JOIN (
		SELECT TOP 1000 Ldbl.ordernr, Ldbl.runid, orderLineID-- COUNT (DISTINCT orderLineID) as uniqueOrderLinesCount
		FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Log] Ldbl (nolock)
		WHERE  message = 'Start processing this Transport Order in this run'
		GROUP BY ordernr, runid, orderLineID
		HAVING COUNT (orderLineID)  > 1
	) as OrdDbl
	ON OrdDbl.RunId = L2Runs.RunId
					
WHERE OrdDbl.ordernr IS NOT NULL 
ORDER BY L.ID DESC
/*  
	syscreated > '2023-11-15 09:22'AND syscreated < '2023-11-15 09:25'
  --bkstnr  IN (23614977 ,23982429 , 23917283)
  --OR transportOrderNr = '9007610'
  --  OR transportOrderNr = '9007610'

  SELECT *
  FROM [115].dbo.gbkmut gm (nolock)
  WHERE --bkstnr -- IN (23614977 ,23982429 , 23917283)
   oms25 = '23982423, 90059387, 613726, 90057610, 549300'
  ORDER BY bkstnr
  */