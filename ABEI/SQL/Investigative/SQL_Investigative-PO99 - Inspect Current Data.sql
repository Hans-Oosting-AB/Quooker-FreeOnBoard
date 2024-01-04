
-- What's up with the Job?
-- functional insight
SELECT TOP (1000)*
  FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Log] WITH (NOLOCK)
  WHERE --bkstnr IS NULL
	runid = 'd776d62b-da07-4c4e-9f16-96ab3d4af5fd'
  --and syscreated >'2023-06-19 11:00:00.000'
  --and [message] LIKE '%newly delivered initial Purchase Orders'
  ORDER BY ID DESC

  -- Job Flow  insight
SELECT TOP (1000)*
  FROM [ABEI].dbo._AB_Entity_Log WITH (NOLOCK)
  WHERE jobid = 1331
  and syscreated >'2023-06-19 11:00:00.000'
  ORDER BY ID DESC

SELECT TOP (1000)*
  FROM [ABEI].dbo._AB_Entity_results_log WITH (NOLOCK)
  WHERE jobid = 1331
  and syscreated >'2023-06-19  13:00:00.000'
  ORDER BY ID DESC

-- What Happened With (initial) Purchase Order???
SELECT TOP (1000) l.ExactDbNum
	, l.syscreated as logTime
	, l.subject
	, l.message
	,  iPOr.*
	, l.runid as logRunId
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts] iPOr WITH (NOLOCK)
LEFT JOIN [ABSC].[dbo].[_AB_tb_W99_FoB_Log] L WITH (NOLOCK)
	ON l.bkstnr = iPOr.bkstnr
	AND l.ExactDbNum = iPOr.ExactDbNum
WHERE 1=1 
	--AND iPOr.rowstatus = 0
	--AND (iPOr.rowstatus = 1 -- processing
	--	OR iPOr.rowstatus = -1) -- FAIL
	--AND iPOr.ordernr = '90055007'
ORDER BY iPOr.bkstnr DESC, l.ID DESC

-- last created transport order
SELECT --TOP (1) 
	iPOr.*
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts] iPOr WITH (NOLOCK)
--WHERE iPOr.rowstatus = 2
ORDER BY iPOr.OrderNr DESC

-- last processed purchase orders
SELECT TOP (100) iPOr.*
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts] iPOr WITH (NOLOCK)
WHERE iPOr.rowstatus = 0
ORDER BY iPOr.ordernr DESC
	
-- What Happened With (created) Transport Order???
SELECT TOP (1000) l.ExactDbNum
	, l.syscreated as logTime
	, l.subject
	, l.message
	,  cTOr.*
	, l.runid as logRunId
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] cTOr WITH (NOLOCK)
LEFT JOIN [ABSC].[dbo].[_AB_tb_W99_FoB_Log] L WITH (NOLOCK)
	ON l.bkstnr = cTOr.bkstnr
	AND l.ExactDbNum = cTOr.ExactDbNum
WHERE 1=1 
	--AND (iPOr.rowstatus = 1 -- processing
	--	OR iPOr.rowstatus = -1) -- FAIL
	--AND iPOr.bkstnr = '23492771'
ORDER BY cTOr.syscreated DESC, l.ID DESC

-- Correlate some Transport Order with initial Purchase Order
SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts]AS cTOr WITH (NOLOCK)
INNER JOIN [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
	ON iPOr.ordernr = cTOr.[initalPurchaseOrderNr]
	AND iPOr.orderLineID = cTOr.[initalPurchaseOrderLineId]
WHERE cTOr.ordernr='90055000'

-- Which current processed or processing records fulfill some criteria?
 SELECT TOP (1000) *
  FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts] WITH (NOLOCK)
  where 1=1
	AND retry_counter > 2
	AND rowstatus = 1 -- processing
  ORDER BY sysmodified DESC


SELECT *
FROM [ABEI].dbo._AB_Entity_results WITH (NOLOCK)
WHERE jobid = 1331
ORDER BY syscreated DESC

SELECT --DISTINCT
        iPOr.ordernr
        , 'Deleting test records for changing additional fields' as DeletionReason
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts] as iPOr WITH (NOLOCK)
WHERE iPOr.transportOrderNr IS NULL

-- Result for RunId
SELECT TOP (1000)*
  FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Log] WITH (NOLOCK)
  WHERE --bkstnr IS NULL
	runid = '337a6ecf-5055-4503-884e-5e2344341be3'
  --and syscreated >'2023-06-19 11:00:00.000'
  --and [message] LIKE '%newly delivered initial Purchase Orders'
  ORDER BY ID DESC

SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] AS cTOr WITH (NOLOCK)
--WHERE ctor.runid = '5146bb6d-8f18-4f0c-919d-44c8f84ff1c8' 
WHERE ID = 18


SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
WHERE iPOr.runid = '70250d89-2642-448f-a797-86b591d50ad1' 

SELECT *
FROM [ABEI].dbo._AB_Entity_results WITH (NOLOCK)
WHERE runid = '337a6ecf-5055-4503-884e-5e2344341be3'
ORDER BY syscreated DESC

SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] AS cTOr WITH (NOLOCK)
--WHERE PurchaseInvoice_LineENtry IS NOT NULL
--	OR PurchaseInvoice_HeaderEntry IS NOT NULL
WHERE (AmutakID IS NOT NULL OR createdBkstnr IS NOT NULL)
ORDER BY sysmodified DESC

	SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] AS cTOr WITH (NOLOCK)
WHERE ctor.rowstatus <> 2

/*
UPDATE cTOr
--	SELECT *
	SET rowstatus = -1
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] AS cTOr --WITH (NOLOCK)
WHERE ctor.rowstatus <> 2

UPDATE iPOr
--	SELECT *
	SET rowstatus = -1
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
WHERE iPOr.rowstatus <> 2
*/