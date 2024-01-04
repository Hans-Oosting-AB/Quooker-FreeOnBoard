SELECT DISTINCT
         iPOr.artcode as ItemCode
        , iPOr.transporterCreditor as crdnr

FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
LEFT JOIN [115].[dbo].[ItemAccounts] as IA WITH (NOLOCK)
	ON IA.crdnr = iPOr.transporterCreditor
	AND IA.ItemCode = iPOr.artcode
 WHERE iPOr.rowstatus = 1
	AND IA.ID IS NULL


SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
LEFT JOIN [115].[dbo].[ItemAccounts] as IA WITH (NOLOCK)
	ON IA.crdnr = iPOr.transporterCreditor
	AND IA.ItemCode = iPOr.artcode
WHERE IA.ID >= 7085
  AND IA.ID <= 7090

SELECT *
FROM [ABSC].[dbo].[_AB_tb_W99_FoB_Created_TransportOrder_Receipts]AS cTOr WITH (NOLOCK)
INNER JOIN [ABSC].[dbo].[_AB_tb_W99_FoB_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
	ON iPOr.ordernr = cTOr.[initalPurchaseOrderNr]
	AND iPOr.orderLineID = cTOr.[initalPurchaseOrderLineId]
INNER JOIN [115].[dbo].[ItemAccounts] as IA WITH (NOLOCK)
	ON IA.crdnr = iPOr.transporterCreditor
	AND IA.ItemCode = iPOr.artcode
WHERE cTOr.ordernr='90055000'
--WHERE IA.ID >= 7085
--  AND IA.ID <= 7090	
/*
	Test Run:
	3:45:14 PM SeqNo 100: Lines retrieved
3:45:15 PM SeqNo 100: Created ItemAccount, ID:7085
3:45:16 PM SeqNo 100: Created ItemAccount, ID:7086
3:45:16 PM SeqNo 100: Created ItemAccount, ID:7087
3:45:17 PM SeqNo 100: Created ItemAccount, ID:7088
3:45:18 PM SeqNo 100: Created ItemAccount, ID:7089
3:45:18 PM SeqNo 100: Created ItemAccount, ID:7090
3:45:19 PM SeqNo 101: Lines retrieved
3:45:20 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49951
3:45:21 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49952
3:45:26 PM SeqNo 101: Created PurchaseOrderHeader, PurchaseOrderNumber:90054997
3:45:26 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49953
3:45:30 PM SeqNo 101: Created PurchaseOrderHeader, PurchaseOrderNumber:90054998
3:45:31 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49950
3:45:35 PM SeqNo 101: Created PurchaseOrderHeader, PurchaseOrderNumber:90054999
3:45:35 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49946
3:45:36 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49947
3:45:37 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49948
3:45:38 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49949
3:45:42 PM SeqNo 101: Created PurchaseOrderHeader, PurchaseOrderNumber:90055000
3:45:43 PM SeqNo 101: Created PurchaseOrderLine, Recordvalue:49945
3:45:46 PM SeqNo 101: Created PurchaseOrderHeader, PurchaseOrderNumber:90055001
*/