SELECT TOP 100
	  GM.bkstnr -- ontvangst boeking nummer (varchar(20))
	, GM.artcode -- (varchar(30))
	, GM.aantal  -- float
	, GM.datum
	, POline.ID as orderLineID --(int)
	, PO.ordernr
    , PO.levwijze as levwijze
    , PO.afldat as planned_deliveryDate
    , PO.crdnr as purchaseCreditor
    , ISNULL(cpo.numberfield2, 42) as additionalDelDays
    , ISNULL(ctr.crdnr, '%param_default_transporterCreditor%')  as transporterCreditor
/*
    -- double check
    , PO.magcode
	, POline.artcode
	, POLine.aant_gelev
    , PO.afgehandld
    , PO.del_debtor_name as purchaseDebtorName
    , cpo.cmp_name as purchaseCreditor_Name
    , ol.oms40_0 as deliveryTransporterName

    -- DEV
     , GM.*
	 , PO.*
	 , POLine.*
	 , IT.*
	 , cpo.*
	 , ctr.*
*/
FROM [115].[dbo].[gbkmut] GM WITH (NOLOCK)
INNER JOIN [115].[dbo].[orkrg] PO WITH (NOLOCK)
	ON PO.ordernr = GM.bkstnr_sub
	AND PO.ord_soort = 'B'
INNER JOIN [115].[dbo].[orsrg]  POline WITH (NOLOCK)
	on POline.sysguid = GM.LinkedLine
INNER JOIN [115].[dbo].[Items] IT WITH (NOLOCK)
	ON IT.ItemCode = GM.artcode
	AND GM.reknr = IT.GLAccountDistribution			-- Filter voorraad boekingen
LEFT JOIN [115].[dbo].cicmpy as cpo WITH(NOLOCK)
    ON PO.CrdNr = cpo.CrdNr
LEFT JOIN [115].[dbo].Ordlev as ol WITH(NOLOCK)
    on ol.levwijze = po.levwijze
LEFT JOIN [115].[dbo].cicmpy as ctr WITH(NOLOCK)
    ON ol.oms40_0 = ctr.cmp_name
WHERE 1=1
		AND ctr.crdnr IS NOT NULL   
		and GM.transtype = 'N'
		and GM.transsubtype = 'A'
		and GM.warehouse = '99'
		AND PO.afldat >= '2023-01-17'
ORDER BY GM.datum DESC