SELECT 
	cTOr.artcode,	
	GMiPOreceive.datum as initialPOReceiveDate,
	GMiPOreceive.aantal as initialPOReceiveCount,
	GMiPOreceive.bdr_val as initialPOReceiveAmount,
	
	GMartRecount.datum as recountDate,
	GMartRecount.aantal as recountCount,
	GMartRecount.bdr_val as recountAmount,

	CASE WHEN ISNULL(GMiPOreceive.aantal, 0) = 0
		THEN ISNULL(GMiPOreceive.bdr_val, 0) 
		ELSE ROUND(ISNULL(GMiPOreceive.bdr_val, 0) / GMiPOreceive.aantal, 3) -- 3 digits
	END as initialPOReceiveCostPrice,
	CASE WHEN ISNULL(GMartRecount.aantal, 0) = 0
		THEN ISNULL(GMartRecount.bdr_val, 0) 
		ELSE ROUND(ISNULL(GMartRecount.bdr_val, 0) / GMartRecount.aantal, 3) -- 3 digits
	END as recountCostPrice,
	CASE WHEN GMartRecount.aantal IS NULL
		THEN CASE WHEN ISNULL(GMiPOreceive.aantal, 0) = 0
				THEN ISNULL(GMiPOreceive.bdr_val, 0) 
				ELSE ROUND(ISNULL(GMiPOreceive.bdr_val, 0) / GMiPOreceive.aantal, 3) -- 3 digits
			END
		ELSE CASE WHEN ISNULL(GMartRecount.aantal, 0) = 0
				THEN ISNULL(GMartRecount.bdr_val, 0) 
				ELSE ROUND(ISNULL(GMartRecount.bdr_val, 0) / GMartRecount.aantal, 3) -- 3 digits
			END
	END as currentInventoryCostPrice,
	cTOr.CostPriceStandard as currentItemCostPrice,
	--GMiPOreceive.*,
	cTOr.* 
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] cTOr WITH (NOLOCK)
INNER JOIN [115].[dbo].[orsrg] iPOline WITH (NOLOCK)
	ON iPOline.ID  = cTOr.initalPurchaseOrderLineId
	--AND  iPOline.ordernr = cTOr.initalPurchaseOrderNr			-- double check
INNER JOIN [115].[dbo].[gbkmut] GMiPOreceive
	ON GMiPOreceive.LinkedLine = iPOline.sysguid 
	AND GMiPOreceive.reknr = cTOr.GLAccountDistribution -- actual Inventory Line (as opposed to NOG/NSF)
	--AND GMiPOreceive.bkstnr_sub = cTOr.initalPurchaseOrderNr	-- double check
	--AND GMiPOreceive.artcode = cTOr.artcode					-- double check
	--AND GMiPOreceive.transtype = 'N'							-- double check
	--AND GMiPOreceive.transsubtype = 'A'						-- double check
	--AND GMiPOreceive.warehouse = '99'							-- double check
OUTER APPLY (SELECT TOP 1 
			GM.artcode, GM.datum, GM.aantal, GM.bdr_val 
		FROM [115].[dbo].[gbkmut] GM
		WHERE 	GM.artcode = cTOr.artcode	
			AND GM.reknr = cTOr.GLAccountDistribution
			AND GM.transtype = 'N'
			AND GM.transsubtype = 'G'
			AND GM.warehouse = '99'
			AND GM.datum >= GMiPOreceive.datum
			AND GM.datum <= cTOr.datumOntvangst
		ORDER BY GM.ID DESC
	) as GMartRecount
ORDER BY cTOr.artcode

/*
SELECT	oh.ordernr
		, oh.ord_soort
		, ol.*
FROM	orkrg oh (nolock)
		inner join dbo.orsrg as ol (nolock) on oh.ordernr = ol.ordernr 
where	1=1
		and oh.ord_soort = 'B'
--		and oh.ordernr = '   50035'

select	TOP 100
		gm.bkstnr_sub
		, gm.bkstnr
		, gm.artcode
		, gm.aantal
		, gm.bdr_hfl
		, gm.reknr
		, gm.transtype
		, gm.transsubtype
		, gm.warehouse
		, gm.LinkedLine
		, oh.levwijze
		, gm.datum
		, ol.*

from	dbo.orkrg as oh (nolock)
		inner join dbo.gbkmut as gm (nolock) on oh.ordernr = gm.bkstnr_sub
		inner join dbo.items as it (nolock) on gm.artcode = it.ItemCode	and gm.reknr = it.GLAccountDistribution
		inner join dbo.orsrg as ol (nolock) on ol.sysguid = gm.LinkedLine
where	1=1
		and oh.ord_soort = 'B'
--		and gm.bkstnr_sub = '90054986' --   50035'
		and gm.transtype = 'N'
		and gm.transsubtype = 'A'
		and gm.warehouse = '03'--'99'
		and oh.selcode = 'tr'
ORDER BY gm.datum DESC

select *
from ordlev

select it.itemcode, lev_crdnr, *
from items as it (nolock)
where 1=1
	and exists (select 1 from ordlev where levwijze = it.itemcode and it.type = 'P')

select *
from DDTests 
where Tablename = 'gbkmut'

*/