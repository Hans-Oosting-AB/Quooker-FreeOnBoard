SELECT * 
FROM DDTests
where TableNAME = 'gbkmut'


SELECT * 
FROM ABEI.dbo._AB_Entity_results
WHERE jobid = 1335
ORDER BY syscreated DESC

SELECT TOP 100 * 
FROM [115].dbo.gbkmut WITH (NOLOCK)
WHERE datum = '2023-08-14'
ORDER BY ID DESC