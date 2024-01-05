DECLARE @stepName [varchar](255) = 'EG: Check for new PurchaseOrder Deliveries'

INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Log] (ExactDbNum, jobid, jobstepid, runid, SYSCREATED, SUBJECT, MESSAGE )
VALUES (%param_eg_division%, %jobid%, %jobstepid%, '%runid%', CURRENT_TIMESTAMP, @stepName, 'Looking for newly delivered initial Purchase Orders.')

DECLARE @numToProcess int

INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Initial_PurchaseOrder_Receipts] 
    (syscreated, sysmodified, runId, rowstatus, sysmessage, ExactDbNum,
        [bkstnr], -- varchar(20) NOT NULL, -- ontvangst boeking nummer (varchar(20))
        [datumOntvangst],-- datetime NOT NULL,
        [ordernr], --CHAR(8) NOT NULL,
        [levwijze], --CHAR(5) NOT NULL,
        [planned_deliveryDate], -- datetime NOT NULL,
        [purchaseCreditor], --  CHAR(6) NOT NULL,
        [additionalDelDays], -- float NOT NULL default 42,
        [transporterCreditor], -- CHAR(6) NOT NULL
        [orderLineID], -- int NOT NULL,
        [artcode], -- varchar(30) NOT NULL
        [aantal], -- float NOT NULL default 0,
        [magcode_FoB] --char(4) NULL  -- FO-48 Extend CD 04.345.682
    )
SELECT
    CURRENT_TIMESTAMP as syscreated, CURRENT_TIMESTAMP as [sysmodified], '%runid%' as runId, 0 as rowstatus, @stepName as sysmessage, %param_eg_division% as ExactDbNum,
    receipts.bkstnr -- ontvangst boeking nummer (varchar(20))
    , receipts.datum as datumOntvangst
    , receipts.ordernr
    , receipts.levwijze
    , receipts.afldat as planned_deliveryDate
    , receipts.crdnr as purchaseCreditor
    , ISNULL(cpo.numberfield2, 42) as additionalDelDays
    , CASE UPPER(receipts.levwijze)
            WHEN 'DHL' THEN '   356'
            WHEN 'ROTRA' THEN '  3379'
            WHEN 'FEDEX' THEN '   842'
            ELSE '%param_default_transporterCreditor%'
        END as transporterCreditor
    , POline.ID as orderLineID --(int)
    , GM.artcode -- (varchar(30))
    , GM.aantal  -- float
    , GM.warehuse -- [magcode_FoB] -- FO-48 Extend CD 04.345.682
FROM  (SELECT DISTINCT TOP  %param_number_of_records_per_run%            -- MAX num records: bkstnr: Receipt slips
            currentRunGM.bkstnr
            , currentRunGM.datum
            , POHead.ordernr
            , POHead.levwijze
            , POHead.afldat
            , POHead.CrdNr
        FROM [%abeisourcedb%].[dbo].[gbkmut] AS currentRunGM WITH (NOLOCK)
        INNER JOIN [%abeisourcedb%].[dbo].[Items] AS currentRunIT WITH (NOLOCK)
            ON currentRunIT.ItemCode = currentRunGM.artcode
            AND currentRunGM.reknr = currentRunIT.GLAccountDistribution         -- Filter voorraad boekingen
        INNER JOIN [%abeisourcedb%].[dbo].[orkrg] AS POHead WITH (NOLOCK)
            ON POHead.ordernr = currentRunGM.bkstnr_sub
        LEFT JOIN [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Initial_PurchaseOrder_Receipts] AS iPOr WITH (NOLOCK)
            ON currentRunGM.bkstnr = iPOr.bkstnr            -- in process
        WHERE 1=1
            -- Filter receipts in Warehouse 03
            AND currentRunGM.transtype = 'N'                -- Gerealiseerd (itt Gepland 'B')
            AND currentRunGM.transsubtype = 'A'             -- Spullen
            AND (
            (currentRunGM.warehouse ='99' AND currentRunGM.datum >='%param_from_receive_date_99%')   -- Received in WareHouse 99 & Start date from 
                OR
                (currentRunGM.warehouse ='98' AND currentRunGM.datum >='%param_from_receive_date_98%')   -- Received in WareHouse 98: -- FO-48 Extend CD 04.345.682
            )

            -- Filter Purchase  Orders
            AND POHead.ord_soort = 'B'                  -- Purchase Order
            AND POHead.magcode IN ('99','98')                     -- Warehouse 99 /98  PO was meant for Warehouse 99 /98(Filter Free On Board PO's) Warehouse 98: -- FO-48 Extend CD 04.345.682
            AND UPPER(POHead.levwijze) in ('TNT', 'DHL', 'ROTRA', 'FEDEX') -- FILTER ONLY 'Known' LEVWijze for WareHouse 99 / 98
            -- NOT already in process
            AND iPOr.ID IS NULL
        ORDER BY currentRunGM.datum ASC
    ) as receipts
INNER JOIN [%abeisourcedb%].[dbo].[gbkmut] AS GM WITH (NOLOCK)
    ON GM.bkstnr = receipts.bkstnr
INNER JOIN [%abeisourcedb%].[dbo].[orsrg] AS POline WITH (NOLOCK)
    on POline.sysguid = GM.LinkedLine
INNER JOIN [%abeisourcedb%].[dbo].[Items] AS IT WITH (NOLOCK)
    ON IT.ItemCode = GM.artcode
    AND GM.reknr = IT.GLAccountDistribution         -- Filter voorraad boekingen
LEFT JOIN [%abeisourcedb%].[dbo].cicmpy AS cpo WITH(NOLOCK)
    ON cpo.CrdNr = receipts.CrdNr





SELECT @numToProcess=@@ROWCOUNT

INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Log] (ExactDbNum, jobid, jobstepid, runid, SYSCREATED, SUBJECT, MESSAGE )
VALUES (%param_eg_division%, %jobid%, %jobstepid%, '%runid%', CURRENT_TIMESTAMP, @stepName, 'Found: ' + CONVERT(varchar(10), @numToProcess)+ ' newly delivered initial Purchase Orders' )


-- 'Transaction Log' for T-Shoot and insight in retries....
INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Log] (ExactDbNum, jobid, jobstepid, runid, SYSCREATED, SUBJECT
, bkstnr
, ordernr
, orderLineID
, MESSAGE )
SELECT %param_eg_division%, %jobid%, %jobstepid%, '%runid%', CURRENT_TIMESTAMP, @stepName
, iPOr.bkstnr
, iPOr.ordernr
, iPOr.orderLineID
, 'Receipt for initial Purchase Order detected.'
FROM [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
WHERE iPOr.rowstatus = 0 -- TODO
AND '%runid%' = iPOr.runid --Explicitely this run only
