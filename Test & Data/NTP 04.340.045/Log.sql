
SELECT TOP (1000) *
  FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Log] L (nolock)
INNER JOIN (
SELECT TOP (1000) runid
  FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Log] L2 (nolock)
  WHERE message = 'Found: 2 newly delivered created Transport Orders'
  ) L2Runs
  ON L2Runs.RunId = L.RunId
ORDER BY L.ID DESC
  
	syscreated > '2023-11-15 09:22'AND syscreated < '2023-11-15 09:25'
  --bkstnr  IN (23614977 ,23982429 , 23917283)
  --OR transportOrderNr = '9007610'
  --  OR transportOrderNr = '9007610'

  SELECT *
  FROM [115].dbo.gbkmut gm (nolock)
  WHERE --bkstnr -- IN (23614977 ,23982429 , 23917283)
   oms25 = '23982423, 90059387, 613726, 90057610, 549300'
  ORDER BY bkstnr