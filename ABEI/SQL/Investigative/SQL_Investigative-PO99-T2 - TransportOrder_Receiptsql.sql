SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts] AS cTOr WITH (NOLOCK)
WHERE cTOr.rowstatus = 1

SELECT DISTINCT [bkstnr] as HeaderID 
    , '61' as dagbknr --Journal -- TODO: Param
    , iPO.crdnr
    --    , iPO.debnr
    , 'ABEI Automated recount triggered by Job Id %jobid% due to receiving goods in Warehouse %param_default_warehouse%. ' +
        'Receipt :' + [bkstnr] + ', ' +
        'TO :' + cTOr.[ordernr] + ', ' +
        'PO :'  + [initalPurchaseOrderNr] + ', ' 
        as oms25 -- description 
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts]AS cTOr WITH (NOLOCK)
INNER JOIN [115].[dbo].[orkrg] AS iPO WITH (NOLOCK)
    ON iPO.ordernr = cTOr.initalPurchaseOrderNr
WHERE cTOr.rowstatus = 1