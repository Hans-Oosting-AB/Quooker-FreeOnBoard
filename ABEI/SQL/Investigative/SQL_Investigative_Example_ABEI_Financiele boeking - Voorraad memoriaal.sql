
-- EG: Create Fin Mem Debet Inventory (Lines)
/* Examnple ABEI taak:
SELECT 'ABAC' as HeaderID 
	, glaccountdistribution  as  reknr
	,  itemcode
	, -1 as quantity
	, -1 *CostPriceStandard as amount
	,  'A01' as warehouselocation
	, WareHouse
	, packagedescription as unitcode 
	, 'G' as entrytype  
	, 'ABEI Telling' as description 
FROM items WITH (NOLOCK) 
WHERE itemcode = 'BEK0002'
*/
SELECT [bkstnr]  as HeaderID 
    , orderLineID as referenceKey
    , GLAccountDistribution  as  reknr
    , [artcode] --as itemcode
    , -1 * [aantal] as [aantal] --quantity
    , -1 *[aantal] * CostPriceStandard as bedrag --amount
    , [PackageDescription] as unitcode 
    , '99' as WareHouse
        --,  'A01' as warehouselocation
    , [datumOntvangst] as datum
    , [ordernr] as OrderNumber -- List Transport Ordert Number as PO number for mutation. or prefer: [initalPurchaseOrderNr]    
    , 'N' as TransType 
    , 'A' as TranssubType -- entrytype  
        , 'ABEI ' +
        'Receipt :' + [bkstnr] + ', ' +
        'TO :' + cTOr.[ordernr] + ', ' +
        'TO Line :' + CAST([orderLineID] as varchar(20)) + ', ' +
        'PO :'  + [initalPurchaseOrderNr] + ', ' +
        'PO Line :'  + CAST([initalPurchaseOrderLineId] as varchar(20)) +  ', Job Id %jobid% MAG %param_default_warehouse%. ' 
    as oms25 -- description
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] as cTOr WITH (NOLOCK)
WHERE cTOr.rowstatus = 1



-- EG: Create Fin Mem Debet Cost (Lines)
/* Examnple ABEI taak:
SELECT 'ABAC' as HeaderID 
	, glaccountcost  as  reknr
	,  itemcode
	, 1 as quantity
	, CostPriceStandard as amount
	,  'A01' as warehouselocation
	, WareHouse 
	, packagedescription as unitcode 
	, 'G' as entrytype 
	, 'ABEI Telling' as description 
FROM items WITH (NOLOCK) 
WHERE itemcode = 'BEK0002'
*/

SELECT [bkstnr] as HeaderID 
    , -1 * orderLineID as referenceKey
    , GLAccountCost  as  reknr
    , [artcode] --as itemcode
    , [aantal] as [aantal] --quantity
    , [aantal] * CostPriceStandard as bedrag --amount
    , [PackageDescription] as unitcode 
    , '99' as WareHouse
        --,  'A01' as warehouselocation
    , [datumOntvangst] as datum
    , [ordernr] as OrderNumber -- List Transport Ordert Number as PO number for mutation. or prefer: [initalPurchaseOrderNr]    
    , 'N' as TransType 
    , 'A' as TranssubType -- entrytype  
        , 'ABEI ' +
        'Receipt :' + [bkstnr] + ', ' +
        'TO :' + cTOr.[ordernr] + ', ' +
        'TO Line :' + CAST([orderLineID] as varchar(20)) + ', ' +
        'PO :'  + [initalPurchaseOrderNr] + ', ' +
        'PO Line :'  + CAST([initalPurchaseOrderLineId] as varchar(20)) +  ', Job Id %jobid% MAG %param_default_warehouse%. '  
    as oms25 -- description
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] as cTOr WITH (NOLOCK)
WHERE cTOr.rowstatus = 1

-- EG: Create Fininancial Memorial (Header)
/* Examnple ABEI taak:
SELECT '90' as journal
	, 'ABAC' as HeaderID 
	, 'ABEI Telling' as description
*/
SELECT DISTINCT [bkstnr] as HeaderID 
    , '%param_inventory_journal%' as dagbknr --Journal -- TODO: Param
    , iPO.crdnr
    --    , iPO.debnr
    --, [ordernr] as OrderNumber -- List Transport Ordert Number as PO number for mutation. or prefer: [initalPurchaseOrderNr]   
   ,  [initalPurchaseOrderNr] as FreeField1
   , '%param_TransportOrder_SelectionCode%' as selcode
    , 'ABEI ' +
        'Receipt :' + [bkstnr] + ', ' +
        'TO :' + cTOr.[ordernr] + ', ' +
        'PO :'  + [initalPurchaseOrderNr] + ', Job Id %jobid% MAG %param_default_warehouse%. ' 
        as oms25 -- description 
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] as cTOr WITH (NOLOCK)
INNER JOIN [115].[dbo].[orkrg] AS iPO WITH (NOLOCK)
	ON iPO.ordernr = cTOr.initalPurchaseOrderNr
WHERE cTOr.rowstatus = 1


SELECT TOP 100 --%param_number_of_records_per_run% 
    --CURRENT_TIMESTAMP as syscreated, CURRENT_TIMESTAMP as [sysmodified], '%runid%' as runId, 0 as rowstatus, @stepName as sysmessage, %param_eg_division% as ExactDbNum,
      GM.bkstnr -- ontvangst boeking nummer (varchar(20))
    , GM.artcode -- (varchar(30))
    , GM.aantal  -- float
    , GM.datum as datumOntvangst
	, IT.GLAccountDistribution	-- varchar(9) null
	, IT.GLAccountCost			-- varchar(9) null
	, ITG.GLPriceDifference
	, IT.CostPriceStandard    -- float -- or [PurchasePrice] -- float not null
	, IT.PackageDescription		-- char(8) null
	, IT.[CostPriceCurrency]  -- varchar(3) -- or [PurchaseCurrency]  -- char(3) null
    , TOLine.ID as orderLineID --(int)
    , TOHead.ordernr
    --, TOHead.levwijze as levwijze
    --, TOHead.afldat as planned_deliveryDate
    , oht.Field09 --[%param_order_Header_additionalfield_name%] as [initalPurchaseOrderNr]        -- Field09 
    , olt.Field09 --[%param_order_Line_additionalfield_name%] as [initalPurchaseOrderLineId]      -- Field09
	, cTOr.*
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] AS cTOr WITH (NOLOCK)
INNER JOIN [115].[dbo].[gbkmut] AS GM WITH (NOLOCK)
	ON GM.bkstnr = cTOr.bkstnr 
INNER JOIN [115].[dbo].[orkrg] AS TOHead WITH (NOLOCK)
    ON TOHead.ordernr = GM.bkstnr_sub
    AND TOHead.ord_soort = 'B'
    AND TOHead.selcode = 'TR'--'%param_TransportOrder_SelectionCode%' -- Marked selcode by Task01 Step 100  - %param_TransportOrder_SelectionCode%
INNER JOIN [115].[dbo].[orsrg] AS TOLine WITH (NOLOCK)
    on TOLine.sysguid = GM.LinkedLine
INNER JOIN [115].[dbo].[Items] AS IT WITH (NOLOCK)
    ON IT.ItemCode = GM.artcode
    AND GM.reknr = IT.GLAccountDistribution         -- Filter voorraad boekingen
INNER JOIN [115].[dbo].[ItemAssortment] as ITG WITH (NOLOCK)
	ON IT.Assortment = ITG.Assortment
INNER JOIN [115].dbo.AdditionalOrderHeader oht
    ON oht.OrderNumber = TOLine.ordernr
    AND oht.Field09  IS NOT NULL                     -- [%param_order_Header_additionalfield_name%] Field09
INNER JOIN [115].dbo.AdditionalOrderLines olt WITH (NOLOCK)
    ON olt.OrderNumber = TOLine.ordernr
        AND olt.LineNumber = TOLine.regel
        AND olt.Field09 IS NOT NULL                   -- [%param_order_Line_additionalfield_name%]  Field9
--WHERE 1=1
--        --AND cTOr.ID IS NULL
----		AND cTOr.ID IS NOT NULL
--        AND GM.transtype = 'N'                      -- Gerealiseerd (itt Gepland 'B')
--        AND GM.transsubtype = 'A'                   -- Spullen
--        AND GM.warehouse = '03'--'%param_default_warehouse%'                     -- Received in WareHouse 03  %param_default_warehouse%
--        AND GM.datum >= '2023-01-17' --'%param_from_afldat%'         -- Filter for starting in Production
ORDER BY GM.datum DESC



-- From SQL_FO-PO99-01T_Step60_Check-For-New-Deliveries-Purchase-Order
/*
SELECT TOP 100 
   -- CURRENT_TIMESTAMP as syscreated, CURRENT_TIMESTAMP as [sysmodified], '%runid%' as runId, 0 as rowstatus, @stepName as sysmessage, %param_eg_division% as ExactDbNum,
      GM.bkstnr -- ontvangst boeking nummer (varchar(20))
    , GM.artcode -- (varchar(30))
    , GM.aantal  -- float
    , GM.datum as datumOntvangst
	, IT.GLAccountDistribution
	, IT.GLAccountCost
	, IT.CostPriceStandard
    , POline.ID as orderLineID --(int)
    , PO.ordernr
    , PO.levwijze as levwijze
    , PO.afldat as planned_deliveryDate
    , PO.crdnr as purchaseCreditor
    --, ISNULL(cpo.numberfield2, 42) as additionalDelDays
--    , ISNULL(ctr.crdnr, '%param_default_transporterCreditor%')  as transporterCreditor
FROM [115].[dbo].[gbkmut] AS GM WITH (NOLOCK)
INNER JOIN [115].[dbo].[orkrg] AS PO WITH (NOLOCK)
    ON PO.ordernr = GM.bkstnr_sub
    AND PO.ord_soort = 'B'
    AND PO.magcode = 99     -- Warehouse 99   PO was meant for Warehouse 99 (Filter Free On Board PO's)
INNER JOIN [115].[dbo].[orsrg] AS POline WITH (NOLOCK)
    on POline.sysguid = GM.LinkedLine
INNER JOIN [115].[dbo].[Items] AS IT WITH (NOLOCK)
    ON IT.ItemCode = GM.artcode
    AND GM.reknr = IT.GLAccountDistribution         -- Filter voorraad boekingen
--LEFT JOIN [115].[dbo].cicmpy AS cpo WITH(NOLOCK)
--    ON PO.CrdNr = cpo.CrdNr
--LEFT JOIN [115].[dbo].Ordlev AS ol WITH(NOLOCK)
--    on ol.levwijze = po.levwijze
--LEFT JOIN [115].[dbo].cicmpy AS ctr WITH(NOLOCK)
--    ON ol.oms40_0 = ctr.cmp_name
LEFT JOIN [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts] AS iPOr WITH (NOLOCK)
    ON GM.bkstnr = iPOr.bkstnr                      -- NOT already in process
WHERE 1=1
        AND iPOr.ID IS NOT NULL
        --AND ctr.crdnr IS NOT NULL                              -- FILTER ONLY 'Known' Creditors for WareHouse 99
        AND GM.transtype = 'N'                      -- Gerealiseerd (itt Gepland 'B')
        AND GM.transsubtype = 'A'                   -- Spullen
        AND GM.warehouse = '99'                     -- Received in WareHouse 99
        AND PO.afldat >= '2023-01-17'      -- Filter for starting in Production
ORDER BY GM.datum DESC
*/