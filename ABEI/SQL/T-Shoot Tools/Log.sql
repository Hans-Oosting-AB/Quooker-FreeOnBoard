
SELECT TOP (1000) *
  FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Log] L (nolock)
INNER JOIN (
SELECT TOP (1000) runid
  FROM [ABSC].[dbo].[_AB_tb_FO-48-FreeOnBoard_Log] L2 (nolock)
  WHERE message = 'Found: 2 newly delivered created Transport Orders'
  ) L2Runs
  ON L2Runs.RunId = L.RunId
ORDER BY L.ID DESC
