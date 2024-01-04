SELECT TOP 100 
	PO.ordernr as ordernr,
	PO.levwijze as levwijze,
	PO.afldat as planned_deliveryDate,
	PO.crdnr as purchaseCreditor,
	cpo.numberfield2 as additionalDelDays,
	ctr.crdnr as transporterCreditor,
	-- double check
	PO.magcode,
	PO.afgehandld,
	PO.del_debtor_name as purchaseDebtorName,
	cpo.cmp_name as purchaseCreditor_Name,
	ol.oms40_0 as deliveryTransporterName,
	docs.id as receive_doc_id,
	docs.CreatedDate as receive_date
	-- DEV
	 , *
FROM orkrg as PO WITH (NOLOCK)
--INNER JOIN orsrg POl WITH (NOLOCK)
--	ON PO.ordernr = POl.ordernr
LEFT JOIN BacoDiscussions as docs WITH (NOLOCK)
	ON PO.ordernr = docs.OrderNumber
	AND docs.[type] = 40
LEFT JOIN cicmpy as cpo WITH(NOLOCK)
	ON PO.CrdNr = cpo.CrdNr
LEFT JOIN Ordlev as ol WITH(NOLOCK)
	on ol.levwijze = po.levwijze
INNER JOIN cicmpy as ctr WITH(NOLOCK)
	ON ol.oms40_0 = ctr.cmp_name
WHERE 1=1
	AND PO.Ord_Soort = 'B'
	AND PO.magcode = 99
	AND PO.afldat >= '2023-02-01'
ORDER BY PO.sysmodified DESC


/*
SELECT TOP 100 * 
FROM BacoDiscussions 
ORDER BY CreatedDate DESC
*/

/*
SELECT TOP 100 
	i.lev_crdnr as transportCreditor,
	i.Condition, *
FROM Items i WITH (NOLOCK)
INNER JOIN cicmpy as ctr WITH(NOLOCK)
	ON i.lev_crdnr = ctr.crdnr
WHERE ctr.cmp_name LIKE '%ROTRA%'

--INNER JOIN orkrg as PO WITH (NOLOCK)
	--ON PO.levwijze = ctr.cmp_name
*/

/*
SELECT TOP 100 
	ol.levwijze, ol.oms40_0,
	ctr.crdnr,	ctr.cmp_code, ctr.cmp_name
FROM Ordlev as ol WITH(NOLOCK)
INNER JOIN cicmpy as ctr WITH(NOLOCK)
	ON ol.oms40_0 = ctr.cmp_name
*/

/*
SELECT *
FROM cicmpy as ctr WITH(NOLOCK)
WHERE ctr.cmp_name LIKE '%ROTRA%'
	OR ctr.cmp_name LIKE '%DHL%'
	OR ctr.cmp_name LIKE '%FedEx%'

*/

/*
SELECT COUNT(PO.del_debtor_name), PO.del_  PO.del_debtor_name as purchaseDebtor
FROM orkrg as PO WITH (NOLOCK)
WHERE 1=1
	AND PO.Ord_Soort = 'B'
	AND PO.magcode = 99
GROUP BY PO.del_debtor_name
*/

/*
DECLARE @someDate datetime = '2023-05-13'
DECLARE @additional float = 42
SELECT DATEADD(d, CONVERT(int, @additional), @someDate)
*/

